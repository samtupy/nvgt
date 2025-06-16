#include "scriptbuilder.h"
#ifdef __ANDROID__
	#include "android_fopen.h"
#endif
#include <vector>
#include <tuple>
#include <string>
#include <assert.h>
#ifdef _WIN32
	#include <windows.h> // MultiByteToWideChar()
#endif
using namespace std;

#include <stdio.h>
#if defined(_MSC_VER) && !defined(_WIN32_WCE) && !defined(__S3E__)
	#include <direct.h>
#endif
#ifdef _WIN32_WCE
	#include <windows.h> // For GetModuleFileName()
#endif

#if defined(__S3E__) || defined(__APPLE__) || defined(__GNUC__)
	#include <unistd.h> // For getcwd()
#endif

BEGIN_AS_NAMESPACE

// Helper functions
static string GetCurrentDir();
static string GetAbsolutePath(const string &path);


CScriptBuilder::CScriptBuilder() {
	engine = 0;
	module = 0;
	includeCallback = 0;
	includeParam = 0;
	pragmaCallback = 0;
	pragmaParam = 0;
}

void CScriptBuilder::SetIncludeCallback(INCLUDECALLBACK_t callback, void* userParam) {
	includeCallback = callback;
	includeParam = userParam;
}

void CScriptBuilder::SetPragmaCallback(PRAGMACALLBACK_t callback, void* userParam) {
	pragmaCallback = callback;
	pragmaParam = userParam;
}

int CScriptBuilder::StartNewModule(asIScriptEngine *inEngine, const char* moduleName) {
	if (inEngine == 0) return -1;
	engine = inEngine;
	module = inEngine->GetModule(moduleName, asGM_ALWAYS_CREATE);
	if (module == 0)
		return -1;
	ClearAll();
	return 0;
}

asIScriptEngine* CScriptBuilder::GetEngine() {
	return engine;
}

asIScriptModule* CScriptBuilder::GetModule() {
	return module;
}

unsigned int CScriptBuilder::GetSectionCount() const {
	return (unsigned int)(includedScripts.size());
}

string CScriptBuilder::GetSectionName(unsigned int idx) const {
	if (idx >= includedScripts.size()) return "";
	#ifdef _WIN32
	set<string, ci_less>::const_iterator it = includedScripts.begin();
	#else
	set<string>::const_iterator it = includedScripts.begin();
	#endif
	while (idx-- > 0) it++;
	return *it;
}

// Returns 1 if the section was included
// Returns 0 if the section was not included because it had already been included before
// Returns <0 if there was an error
int CScriptBuilder::AddSectionFromFile(const char* filename) {
	// The file name stored in the set should be the fully resolved name because
	// it is possible to name the same file in multiple ways using relative paths.
	string fullpath = GetAbsolutePath(filename);
	if (IncludeIfNotAlreadyIncluded(fullpath.c_str())) {
		int r = LoadScriptSection(fullpath.c_str());
		if (r < 0)
			return r;
		else
			return 1;
	}
	return 0;
}

// Returns 1 if the section was included
// Returns 0 if the section was not included because it had already been included before
// Returns <0 if there was an error
int CScriptBuilder::AddSectionFromMemory(const char* sectionName, const char* scriptCode, unsigned int scriptLength, int lineOffset) {
	if (IncludeIfNotAlreadyIncluded(sectionName)) {
		int r = ProcessScriptSection(scriptCode, scriptLength, sectionName, lineOffset);
		if (r < 0)
			return r;
		else
			return 1;
	}
	return 0;
}

int CScriptBuilder::BuildModule() {
	return Build();
}

void CScriptBuilder::DefineWord(const char* word) {
	string sword = word;
	if (definedWords.find(sword) == definedWords.end())
		definedWords.insert(sword);
}

void CScriptBuilder::SetMainScript(const char* filename) {
	mainScript = filename;
}

void CScriptBuilder::ClearAll() {
	includedScripts.clear();
	mainScript.clear();
	#if AS_PROCESS_METADATA == 1
	currentClass = "";
	currentNamespace = "";
	foundDeclarations.clear();
	typeMetadataMap.clear();
	funcMetadataMap.clear();
	varMetadataMap.clear();
	#endif
}

bool CScriptBuilder::IncludeIfNotAlreadyIncluded(const char* filename) {
	string scriptFile = filename;
	if (includedScripts.find(scriptFile) != includedScripts.end()) {
		// Already included
		return false;
	}
	// Add the file to the set of included sections
	includedScripts.insert(scriptFile);
	return true;
}

int CScriptBuilder::LoadScriptSection(const char* filename) {
	// Open the script file
	string scriptFile = filename;
	#if _MSC_VER >= 1500 && !defined(__S3E__)
	#ifdef _WIN32
	// Convert the filename from UTF8 to UTF16
	wchar_t bufUTF16_name[10000] = {0};
	wchar_t bufUTF16_mode[10] = {0};
	MultiByteToWideChar(CP_UTF8, 0, filename, -1, bufUTF16_name, 10000);
	MultiByteToWideChar(CP_UTF8, 0, "rb", -1, bufUTF16_mode, 10);
	FILE *f = 0;
	_wfopen_s(&f, bufUTF16_name, bufUTF16_mode);
	#else
	FILE* f = 0;
	fopen_s(&f, scriptFile.c_str(), "rb");
	#endif
	#elif defined(__ANDROID__)
	FILE *f = fdopen(android_fopen(scriptFile.c_str(), "rb"), "rb");
	#else
	FILE *f = fopen(scriptFile.c_str(), "rb");
	#endif
	if (f == 0) {
		// Write a message to the engine's message callback
		string msg = "Failed to open script file '" + GetAbsolutePath(scriptFile) + "'";
		engine->WriteMessage(filename, 0, 0, asMSGTYPE_ERROR, msg.c_str());
		// TODO: Write the file where this one was included from
		return -1;
	}
	// Determine size of the file
	fseek(f, 0, SEEK_END);
	int len = ftell(f);
	fseek(f, 0, SEEK_SET);
	// On Win32 it is possible to do the following instead
	// int len = _filelength(_fileno(f));
	// Read the entire file
	string code;
	size_t c = 0;
	if (len > 0) {
		code.resize(len);
		c = fread(&code[0], len, 1, f);
	}
	fclose(f);
	if (c == 0 && len > 0) {
		// Write a message to the engine's message callback
		string msg = "Failed to load script file '" + GetAbsolutePath(scriptFile) + "'";
		engine->WriteMessage(filename, 0, 0, asMSGTYPE_ERROR, msg.c_str());
		return -1;
	}
	// Process the script section even if it is zero length so that the name is registered
	return ProcessScriptSection(code.c_str(), (unsigned int)(code.length()), filename, 0);
}

int CScriptBuilder::CalculateLineNumber(const string &script, int pos) {
	int line = 1;
	for (int i = 0; i < pos && i < (int)script.size(); i++) {
		if (script[i] == '\n')
			line++;
	}
	return line;
}

int CScriptBuilder::ProcessScriptSection(const char* script, unsigned int length, const char* sectionname, int lineOffset) {
	// Save the current state of modifiedScript before we modify it
	string savedModifiedScript = modifiedScript;
	// Perform a superficial parsing of the script first to store the metadata
	if (length)
		modifiedScript.assign(script, length);
	else
		modifiedScript = script;
	// Store the current file being processed
	currentFile = sectionname;
	currentLineOffset = lineOffset;
	// First pass: Process ALL preprocessor directives throughout the file
	unsigned int pos = 0;
	int nested = 0;
	// ifStack stores: (condition_was_true, else_seen, line_number_of_if)
	std::vector<std::tuple<bool, bool, int>> ifStack;
	while(pos < modifiedScript.size()) {
		asUINT len = 0;
		if(modifiedScript[pos] == '#' && (pos + 1 < modifiedScript.size())) {
			int start = pos++;
			asETokenClass t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
			if (t == asTC_IDENTIFIER || t == asTC_KEYWORD) {
				string token;
				token.assign(&modifiedScript[pos], len);
				if (token == "include") {
					pos += len;
					t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					if (t == asTC_WHITESPACE) {
						pos += len;
						t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					}
					if (t == asTC_VALUE && len > 2 && (modifiedScript[pos] == '"' || modifiedScript[pos] == '\'')) {
						// Get the include file
						string includefile;
						includefile.assign(&modifiedScript[pos + 1], len - 2);
						pos += len;
						// Make sure the includeFile doesn't contain any line breaks
						size_t p = includefile.find('\n');
						if (p != string::npos) {
							int line = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
							string str = "Invalid file name for #include; it contains a line-break: '" + includefile.substr(0, p) + "'";
							engine->WriteMessage(currentFile.c_str(), line, 0, asMSGTYPE_ERROR, str.c_str());
						} else {
							// Overwrite the include directive with space characters to avoid compiler error
							OverwriteCode(start, pos - start);
							// Process the include immediately
							int r = 0;
							if (includeCallback)
								r = includeCallback(includefile.c_str(), sectionname, this, includeParam);
							else {
								// By default we try to load the included file from the relative directory of the current file
								string path = sectionname;
								size_t posOfSlash = path.find_last_of("/\\");
								if (posOfSlash != string::npos)
									path.resize(posOfSlash + 1);
								else
									path = "";
								// If the include is a relative path, then prepend the path of the originating script
								string fullIncludePath = includefile;
								if (fullIncludePath.find_first_of("/\\") != 0 &&
								    fullIncludePath.find_first_of(":") == string::npos)
									fullIncludePath = path + fullIncludePath;
								// Include the script section
								r = AddSectionFromFile(fullIncludePath.c_str());
							}
							if (r < 0)
								return r;
						}
					}
				} else if (token == "if" || token == "if_not") {
					bool if_not = token == "if_not";
					pos += len;
					t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					if (t == asTC_WHITESPACE) {
						pos += len;
						t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					}
					if (t == asTC_IDENTIFIER) {
						string word;
						word.assign(&modifiedScript[pos], len);
						// Overwrite the #if directive with space characters to avoid compiler error
						pos += len;
						OverwriteCode(start, pos - start);
						// Special handling for __main__
						bool word_exists;
						if (word == "__main__") {
							// __main__ is true only if this is the main script
							word_exists = (!mainScript.empty() && currentFile == mainScript);
						} else {
							// Regular symbol lookup
							word_exists = definedWords.find(word) != definedWords.end();
						}
						bool condition = if_not ? !word_exists : word_exists;
						// Push the state for this #if block with line number
						int ifLine = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
						ifStack.push_back(std::make_tuple(condition, false, ifLine));
						if (!condition) {
							// Exclude all the code until #else, #elif or #endif
							ExcludeCodeResult result;
							pos = ExcludeCode(pos, result);
							// If we consumed an #endif, we need to pop from the stack
							if (result == EXCLUDE_FOUND_ENDIF)
								ifStack.pop_back();
							// If we stopped at #else or #elif, we're still in the same if block
							// and the directive will be processed in the next iteration
						} else {
							// Condition is true, continue processing normally
							nested++;
						}
					}
				} else if (token == "elif") {
					pos += len;
					if (!ifStack.empty()) {
						bool prevConditionTrue = std::get<0>(ifStack.back());
						bool elseAlreadySeen = std::get<1>(ifStack.back());
						if (elseAlreadySeen) {
							int line = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
							engine->WriteMessage(currentFile.c_str(), line, 0, asMSGTYPE_ERROR, "Unexpected #elif after #else");
							return -1;
						}
						t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
						if (t == asTC_WHITESPACE) {
							pos += len;
							t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
						}
						if (t == asTC_IDENTIFIER) {
							string word;
							word.assign(&modifiedScript[pos], len);
							pos += len;
							OverwriteCode(start, pos - start);
							// Special handling for __main__
							bool word_exists;
							if (word == "__main__") {
								// __main__ is true only if this is the main script
								word_exists = (!mainScript.empty() && currentFile == mainScript);
							} else {
								// Regular symbol lookup
								word_exists = definedWords.find(word) != definedWords.end();
							}
							if (!prevConditionTrue && word_exists)
								std::get<0>(ifStack.back()) = true;
							else if (prevConditionTrue || !word_exists) {
								ExcludeCodeResult result;
								pos = ExcludeCode(pos, result);
								// If we consumed an #endif, we need to pop from the stack
								if (result == EXCLUDE_FOUND_ENDIF)
									ifStack.pop_back();
							}
						}
					} else {
						for (; pos < modifiedScript.size() && modifiedScript[pos] != '\n'; pos++);
						OverwriteCode(start, pos - start);
					}
				} else if (token == "else") {
					pos += len;
					if (!ifStack.empty()) {
						bool prevConditionTrue = std::get<0>(ifStack.back());
						bool elseAlreadySeen = std::get<1>(ifStack.back());
						if (elseAlreadySeen) {
							int line = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
							engine->WriteMessage(currentFile.c_str(), line, 0, asMSGTYPE_ERROR, "Unexpected #else after #else");
							return -1;
						}
						std::get<1>(ifStack.back()) = true;
						OverwriteCode(start, pos - start);
						if (prevConditionTrue) {
							ExcludeCodeResult result;
							pos = ExcludeCode(pos, result);
							// If we consumed an #endif, we need to pop from the stack
							if (result == EXCLUDE_FOUND_ENDIF)
								ifStack.pop_back();
						}
					} else
						OverwriteCode(start, pos - start);
				} else if (token == "endif") {
					pos += len;
					OverwriteCode(start, pos - start);
					if (!ifStack.empty()) {
						ifStack.pop_back();
						if (nested > 0)
							nested--;
					}
				} else if (token == "define") {
					pos += len;
					t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					if (t == asTC_WHITESPACE) {
						pos += len;
						t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					}
					if (t == asTC_IDENTIFIER) {
						string macroName;
						macroName.assign(&modifiedScript[pos], len);
						pos += len;
						bool hasValue = false;
						if (pos < modifiedScript.size() && modifiedScript[pos] != '\n' && modifiedScript[pos] != '\r') {
							asUINT wsLen = 0;
							t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &wsLen);
							if (t == asTC_WHITESPACE) {
								pos += wsLen;
								if (pos < modifiedScript.size() && modifiedScript[pos] != '\n' && modifiedScript[pos] != '\r')
									hasValue = true;
							} else
								hasValue = true;
						}
						int valueEndPos = pos;
						while (valueEndPos < modifiedScript.size() && modifiedScript[valueEndPos] != '\n' && modifiedScript[valueEndPos] != '\r')
							valueEndPos++;
						if (valueEndPos < modifiedScript.size() && (modifiedScript[valueEndPos] == '\n' || modifiedScript[valueEndPos] == '\r')) {
							valueEndPos++;
							if (valueEndPos < modifiedScript.size() && modifiedScript[valueEndPos - 1] == '\r' && modifiedScript[valueEndPos] == '\n')
								valueEndPos++;
						}
						if (hasValue) {
							string value = modifiedScript.substr(pos, valueEndPos - pos);
							size_t firstNonWhitespace = value.find_first_not_of(" \t\r\n");
							if (firstNonWhitespace != string::npos) {
								string msg = "Value assignment in #define is not supported. Use '#define " + macroName + "' without a value.";
								int line = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
								engine->WriteMessage(currentFile.c_str(), line, 0, asMSGTYPE_ERROR, msg.c_str());
								return -1;
							}
						}
						// Check if trying to define __main__
						if (macroName == "__main__") {
							string msg = "Cannot define '__main__' - it is a reserved preprocessor symbol";
							int line = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
							engine->WriteMessage(currentFile.c_str(), line, 0, asMSGTYPE_ERROR, msg.c_str());
							return -1;
						}
						if (definedWords.find(macroName) != definedWords.end()) {
							string msg = "Redefinition of symbol '" + macroName + "'";
							int line = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
							engine->WriteMessage(currentFile.c_str(), line, 0, asMSGTYPE_ERROR, msg.c_str());
							return -1;
						}
						definedWords.insert(macroName);
						OverwriteCode(start, valueEndPos - start);
						pos = valueEndPos;
						continue;
					}
				} else if (token == "undef") {
					pos += len;
					t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					if (t == asTC_WHITESPACE) {
						pos += len;
						t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					}
					if (t == asTC_IDENTIFIER) {
						string macroName;
						macroName.assign(&modifiedScript[pos], len);
						pos += len;
						// Check if trying to undefine __main__
						if (macroName == "__main__") {
							string msg = "Cannot undefine '__main__' - it is a reserved preprocessor symbol";
							int line = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
							engine->WriteMessage(currentFile.c_str(), line, 0, asMSGTYPE_ERROR, msg.c_str());
							return -1;
						}
						definedWords.erase(macroName);
						OverwriteCode(start, pos - start);
					}
				} else if (token == "pragma") {
					// Read until the end of the line
					for (; pos < modifiedScript.size() && modifiedScript[pos] != '\n'; pos++);
					// Call the pragma callback
					string pragmaText(&modifiedScript[start + 7], pos - start - 7);
					int r = pragmaCallback ? pragmaCallback(pragmaText, *this, pragmaParam) : -1;
					if (r < 0) {
						int line = CalculateLineNumber(modifiedScript, start) + currentLineOffset;
						engine->WriteMessage(currentFile.c_str(), line, 0, asMSGTYPE_ERROR, "Invalid #pragma directive");
						return r;
					}
					// Overwrite the pragma directive with space characters to avoid compiler error
					OverwriteCode(start, pos - start);
				}
			}
		} else {
			asETokenClass t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
			pos += len;
		}
	}
	// Check for unmatched #if directives
	if (!ifStack.empty()) {
		// Report the line number of the last (innermost) unclosed #if
		// We use back() because that's the most recent unclosed #if on the stack
		int unclosedIfLine = std::get<2>(ifStack.back());
		string msg = "Unmatched #if directive at line " + std::to_string(unclosedIfLine) + " - missing #endif";
		engine->WriteMessage(currentFile.c_str(), unclosedIfLine, 0, asMSGTYPE_ERROR, msg.c_str());
		return -1;
	}
	// Second pass: Process metadata and build the script sections
	pos = 0;
	#if AS_PROCESS_METADATA == 1
	// Preallocate memory
	string name, declaration;
	vector<string> metadata;
	declaration.reserve(100);
	#endif
	while (pos < modifiedScript.size()) {
		asUINT len = 0;
		asETokenClass t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
		// All preprocessor directives have already been processed in the first pass
		// The modifiedScript should have all directives overwritten with spaces
		// and all excluded code also overwritten with spaces
		if (t == asTC_COMMENT || t == asTC_WHITESPACE) {
			pos += len;
			continue;
		}
		string token;
		token.assign(&modifiedScript[pos], len);
		#if AS_PROCESS_METADATA == 1
		// Skip possible decorators before class and interface declarations
		if (token == "shared" || token == "abstract" || token == "mixin" || token == "external") {
			pos += len;
			continue;
		}
		// Check if class or interface so the metadata for members can be gathered
		if (currentClass == "" && (token == "class" || token == "interface")) {
			// Get the identifier after "class"
			do {
				pos += len;
				if (pos >= modifiedScript.size()) {
					t = asTC_UNKNOWN;
					break;
				}
				t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
			} while (t == asTC_COMMENT || t == asTC_WHITESPACE);
			if (t == asTC_IDENTIFIER) {
				currentClass = modifiedScript.substr(pos, len);
				// Search until first { or ; is encountered
				while (pos < modifiedScript.length()) {
					engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
					// If start of class section encountered stop
					if (modifiedScript[pos] == '{') {
						pos += len;
						break;
					} else if (modifiedScript[pos] == ';') {
						// The class declaration has ended and there are no children
						currentClass = "";
						pos += len;
						break;
					}
					// Check next symbol
					pos += len;
				}
			}
			continue;
		}
		// Check if end of class
		if (currentClass != "" && token == "}") {
			currentClass = "";
			pos += len;
			continue;
		}
		// Check if namespace so the metadata for members can be gathered
		if (token == "namespace") {
			// Get the identifier after "namespace"
			do {
				pos += len;
				t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
			} while (t == asTC_COMMENT || t == asTC_WHITESPACE);
			if (currentNamespace != "")
				currentNamespace += "::";
			currentNamespace += modifiedScript.substr(pos, len);
			// Search until first { is encountered
			while (pos < modifiedScript.length()) {
				engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
				// If start of namespace section encountered stop
				if (modifiedScript[pos] == '{') {
					pos += len;
					break;
				}
				// Check next symbol
				pos += len;
			}
			continue;
		}
		// Check if end of namespace
		if (currentNamespace != "" && token == "}") {
			size_t found = currentNamespace.rfind("::");
			if (found != string::npos)
				currentNamespace.erase(found);
			else
				currentNamespace = "";
			pos += len;
			continue;
		}
		// Is this the start of metadata?
		if (token == "[") {
			// Get the metadata string
			pos = ExtractMetadata(pos, metadata);
			// Determine what this metadata is for
			int type;
			ExtractDeclaration(pos, name, declaration, type);
			// Store away the declaration in a map for lookup after the build has completed
			if (type > 0) {
				SMetadataDecl decl(metadata, name, declaration, type, currentClass, currentNamespace);
				foundDeclarations.push_back(decl);
			}
			continue;
		}
		#endif
		// Move to next token
		pos += len;
	}
	// Build the actual script
	engine->SetEngineProperty(asEP_COPY_SCRIPT_SECTIONS, true);
	module->AddScriptSection(sectionname, modifiedScript.c_str(), modifiedScript.size(), lineOffset);
	// Restore the original modifiedScript state
	modifiedScript = savedModifiedScript;
	return 0;
}

int CScriptBuilder::Build() {
	int r = module->Build();
	if (r < 0)
		return r;
	#if AS_PROCESS_METADATA == 1
	// After the script has been built, the metadata strings should be
	// stored for later lookup by function id, type id, and variable index
	for (int n = 0; n < (int)foundDeclarations.size(); n++) {
		SMetadataDecl *decl = &foundDeclarations[n];
		module->SetDefaultNamespace(decl->nameSpace.c_str());
		if (decl->type == MDT_TYPE) {
			// Find the type id
			int typeId = module->GetTypeIdByDecl(decl->declaration.c_str());
			assert(typeId >= 0);
			if (typeId >= 0)
				typeMetadataMap.insert(map<int, vector<string>>::value_type(typeId, decl->metadata));
		} else if (decl->type == MDT_FUNC) {
			if (decl->parentClass == "") {
				// Find the function id
				asIScriptFunction *func = module->GetFunctionByDecl(decl->declaration.c_str());
				assert(func);
				if (func)
					funcMetadataMap.insert(map<int, vector<string>>::value_type(func->GetId(), decl->metadata));
			} else {
				// Find the method id
				int typeId = module->GetTypeIdByDecl(decl->parentClass.c_str());
				assert(typeId > 0);
				map<int, SClassMetadata>::iterator it = classMetadataMap.find(typeId);
				if (it == classMetadataMap.end()) {
					classMetadataMap.insert(map<int, SClassMetadata>::value_type(typeId, SClassMetadata(decl->parentClass)));
					it = classMetadataMap.find(typeId);
				}
				asITypeInfo *type = engine->GetTypeInfoById(typeId);
				asIScriptFunction *func = type->GetMethodByDecl(decl->declaration.c_str());
				assert(func);
				if (func)
					it->second.funcMetadataMap.insert(map<int, vector<string>>::value_type(func->GetId(), decl->metadata));
			}
		} else if (decl->type == MDT_VIRTPROP) {
			if (decl->parentClass == "") {
				// Find the global virtual property accessors
				asIScriptFunction *func = module->GetFunctionByName(("get_" + decl->declaration).c_str());
				if (func)
					funcMetadataMap.insert(map<int, vector<string>>::value_type(func->GetId(), decl->metadata));
				func = module->GetFunctionByName(("set_" + decl->declaration).c_str());
				if (func)
					funcMetadataMap.insert(map<int, vector<string>>::value_type(func->GetId(), decl->metadata));
			} else {
				// Find the method virtual property accessors
				int typeId = module->GetTypeIdByDecl(decl->parentClass.c_str());
				assert(typeId > 0);
				map<int, SClassMetadata>::iterator it = classMetadataMap.find(typeId);
				if (it == classMetadataMap.end()) {
					classMetadataMap.insert(map<int, SClassMetadata>::value_type(typeId, SClassMetadata(decl->parentClass)));
					it = classMetadataMap.find(typeId);
				}
				asITypeInfo *type = engine->GetTypeInfoById(typeId);
				asIScriptFunction *func = type->GetMethodByName(("get_" + decl->declaration).c_str());
				if (func)
					it->second.funcMetadataMap.insert(map<int, vector<string>>::value_type(func->GetId(), decl->metadata));
				func = type->GetMethodByName(("set_" + decl->declaration).c_str());
				if (func)
					it->second.funcMetadataMap.insert(map<int, vector<string>>::value_type(func->GetId(), decl->metadata));
			}
		} else if (decl->type == MDT_VAR) {
			if (decl->parentClass == "") {
				// Find the global variable index
				int varIdx = module->GetGlobalVarIndexByName(decl->declaration.c_str());
				assert(varIdx >= 0);
				if (varIdx >= 0)
					varMetadataMap.insert(map<int, vector<string>>::value_type(varIdx, decl->metadata));
			} else {
				int typeId = module->GetTypeIdByDecl(decl->parentClass.c_str());
				assert(typeId > 0);
				// Add the classes if needed
				map<int, SClassMetadata>::iterator it = classMetadataMap.find(typeId);
				if (it == classMetadataMap.end()) {
					classMetadataMap.insert(map<int, SClassMetadata>::value_type(typeId, SClassMetadata(decl->parentClass)));
					it = classMetadataMap.find(typeId);
				}
				// Add the variable to class
				asITypeInfo *objectType = engine->GetTypeInfoById(typeId);
				int idx = -1;
				// Search through all properties to get proper declaration
				for (asUINT i = 0; i < (asUINT)objectType->GetPropertyCount(); ++i) {
					const char* name;
					objectType->GetProperty(i, &name);
					if (decl->declaration == name) {
						idx = i;
						break;
					}
				}
				// If found, add it
				assert(idx >= 0);
				if (idx >= 0) it->second.varMetadataMap.insert(map<int, vector<string>>::value_type(idx, decl->metadata));
			}
		} else if (decl->type == MDT_FUNC_OR_VAR) {
			if (decl->parentClass == "") {
				// Find the global variable index
				int varIdx = module->GetGlobalVarIndexByName(decl->name.c_str());
				if (varIdx >= 0)
					varMetadataMap.insert(map<int, vector<string>>::value_type(varIdx, decl->metadata));
				else {
					asIScriptFunction *func = module->GetFunctionByDecl(decl->declaration.c_str());
					assert(func);
					if (func)
						funcMetadataMap.insert(map<int, vector<string>>::value_type(func->GetId(), decl->metadata));
				}
			} else {
				int typeId = module->GetTypeIdByDecl(decl->parentClass.c_str());
				assert(typeId > 0);
				// Add the classes if needed
				map<int, SClassMetadata>::iterator it = classMetadataMap.find(typeId);
				if (it == classMetadataMap.end()) {
					classMetadataMap.insert(map<int, SClassMetadata>::value_type(typeId, SClassMetadata(decl->parentClass)));
					it = classMetadataMap.find(typeId);
				}
				// Add the variable to class
				asITypeInfo *objectType = engine->GetTypeInfoById(typeId);
				int idx = -1;
				// Search through all properties to get proper declaration
				for (asUINT i = 0; i < (asUINT)objectType->GetPropertyCount(); ++i) {
					const char* name;
					objectType->GetProperty(i, &name);
					if (decl->name == name) {
						idx = i;
						break;
					}
				}
				// If found, add it
				if (idx >= 0)
					it->second.varMetadataMap.insert(map<int, vector<string>>::value_type(idx, decl->metadata));
				else {
					// Look for the matching method instead
					asITypeInfo *type = engine->GetTypeInfoById(typeId);
					asIScriptFunction *func = type->GetMethodByDecl(decl->declaration.c_str());
					if (func)
						it->second.funcMetadataMap.insert(map<int, vector<string>>::value_type(func->GetId(), decl->metadata));
				}
			}
		}
	}
	module->SetDefaultNamespace("");
	#endif
	return 0;
}

int CScriptBuilder::SkipStatement(int pos) {
	asUINT len = 0;
	// Skip until ; or { whichever comes first
	while (pos < (int)modifiedScript.length() && modifiedScript[pos] != ';' && modifiedScript[pos] != '{') {
		engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
		pos += len;
	}
	// Skip entire statement block
	if (pos < (int)modifiedScript.length() && modifiedScript[pos] == '{') {
		pos += 1;
		// Find the end of the statement block
		int level = 1;
		while (level > 0 && pos < (int)modifiedScript.size()) {
			asETokenClass t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
			if (t == asTC_KEYWORD) {
				if (modifiedScript[pos] == '{')
					level++;
				else if (modifiedScript[pos] == '}')
					level--;
			}
			pos += len;
		}
	} else
		pos += 1;
	return pos;
}

// Overwrite all code with blanks until the matching #endif
int CScriptBuilder::ExcludeCode(int pos, ExcludeCodeResult &result) {
	asUINT len = 0;
	int nested = 0;
	result = EXCLUDE_REACHED_END;
	while (pos < (int)modifiedScript.size()) {
		asETokenClass t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
		if (modifiedScript[pos] == '#') {
			int startPos = pos; // Save position of #
			modifiedScript[pos] = ' ';
			pos++;
			// Is it an #if, #else, #elif or #endif directive?
			engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
			string token;
			token.assign(&modifiedScript[pos], len);
			if (token == "if" || token == "if_not") {
				OverwriteCode(pos, len);
				nested++;
			} else if (token == "endif") {
				OverwriteCode(pos, len);
				if (nested-- == 0) {
					pos += len;
					result = EXCLUDE_FOUND_ENDIF;
					break;
				}
			} else if ((token == "else" || token == "elif") && nested == 0) {
				// We've reached an else/elif at our nesting level, stop excluding
				// Don't overwrite these tokens as they need to be processed by the main loop
				// Restore the # character we overwrote
				modifiedScript[startPos] = '#';
				// Position at the # so the main loop can process this directive
				pos = startPos;
				result = (token == "else") ? EXCLUDE_FOUND_ELSE : EXCLUDE_FOUND_ELIF;
				break;
			} else {
				// Other directive, overwrite it
				OverwriteCode(pos, len);
			}
		} else if (modifiedScript[pos] != '\n')
			OverwriteCode(pos, len);
		pos += len;
	}
	return pos;
}

// Overwrite all characters except line breaks with blanks
void CScriptBuilder::OverwriteCode(int start, int len) {
	char* code = &modifiedScript[start];
	for (int n = 0; n < len; n++) {
		if (*code != '\n')
			*code = ' ';
		code++;
	}
}

#if AS_PROCESS_METADATA == 1
int CScriptBuilder::ExtractMetadata(int pos, vector<string>& metadata) {
	metadata.clear();
	// Extract all metadata. They can be separated by whitespace and comments
	for (;;) {
		string metadataString = "";
		// Overwrite the metadata with space characters to allow compilation
		modifiedScript[pos] = ' ';
		// Skip opening brackets
		pos += 1;
		int level = 1;
		asUINT len = 0;
		while (level > 0 && pos < (int)modifiedScript.size()) {
			asETokenClass t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
			if (t == asTC_KEYWORD) {
				if (modifiedScript[pos] == '[')
					level++;
				else if (modifiedScript[pos] == ']')
					level--;
			}
			// Copy the metadata to our buffer
			if (level > 0)
				metadataString.append(&modifiedScript[pos], len);
			// Overwrite the metadata with space characters to allow compilation
			if (t != asTC_WHITESPACE)
				OverwriteCode(pos, len);
			pos += len;
		}
		metadata.push_back(metadataString);
		// Check for more metadata. Possibly separated by comments
		asETokenClass t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
		while (t == asTC_COMMENT || t == asTC_WHITESPACE) {
			pos += len;
			t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
		}
		if (modifiedScript[pos] != '[')
			break;
	}
	return pos;
}

int CScriptBuilder::ExtractDeclaration(int pos, string &name, string &declaration, int& type) {
	declaration = "";
	type = 0;
	int start = pos;
	std::string token;
	asUINT len = 0;
	asETokenClass t = asTC_WHITESPACE;
	// Skip white spaces, comments, and leading decorators
	do {
		pos += len;
		t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
		token.assign(&modifiedScript[pos], len);
	} while (t == asTC_WHITESPACE || t == asTC_COMMENT ||
	         token == "private" || token == "protected" ||
	         token == "shared" || token == "external" ||
	         token == "final" || token == "abstract");
	// We're expecting, either a class, interface, function, or variable declaration
	if (t == asTC_KEYWORD || t == asTC_IDENTIFIER) {
		token.assign(&modifiedScript[pos], len);
		if (token == "interface" || token == "class" || token == "enum") {
			// Skip white spaces and comments
			do {
				pos += len;
				t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
			} while (t == asTC_WHITESPACE || t == asTC_COMMENT);
			if (t == asTC_IDENTIFIER) {
				type = MDT_TYPE;
				declaration.assign(&modifiedScript[pos], len);
				pos += len;
				return pos;
			}
		} else {
			// For function declarations, store everything up to the start of the
			// statement block, except for succeeding decorators (final, override, etc)
			// For variable declaration store just the name as there can only be one
			// We'll only know if the declaration is a variable or function declaration
			// when we see the statement block, or absense of a statement block.
			bool hasParenthesis = false;
			int nestedParenthesis = 0;
			declaration.append(&modifiedScript[pos], len);
			pos += len;
			for (; pos < (int)modifiedScript.size();) {
				t = engine->ParseToken(&modifiedScript[pos], modifiedScript.size() - pos, &len);
				token.assign(&modifiedScript[pos], len);
				if (t == asTC_KEYWORD) {
					if (token == "{" && nestedParenthesis == 0) {
						if (hasParenthesis) {
							// We've found the end of a function signature
							type = MDT_FUNC;
						} else {
							// We've found a virtual property. Just keep the name
							declaration = name;
							type = MDT_VIRTPROP;
						}
						return pos;
					}
					if ((token == "=" && !hasParenthesis) || token == ";") {
						if (hasParenthesis) {
							// The declaration is ambigous. It can be a variable with initialization, or a function prototype
							type = MDT_FUNC_OR_VAR;
						} else {
							// Substitute the declaration with just the name
							declaration = name;
							type = MDT_VAR;
						}
						return pos;
					} else if (token == "(") {
						nestedParenthesis++;
						// This is the first parenthesis we encounter. If the parenthesis isn't followed
						// by a statement block, then this is a variable declaration, in which case we
						// should only store the type and name of the variable, not the initialization parameters.
						hasParenthesis = true;
					} else if (token == ")")
						nestedParenthesis--;
				} else if (t == asTC_IDENTIFIER)
					name = token;
				// Skip trailing decorators
				if (!hasParenthesis || nestedParenthesis > 0 || t != asTC_IDENTIFIER || (token != "final" && token != "override" && token != "delete" && token != "property"))
					declaration += token;
				pos += len;
			}
		}
	}
	return start;
}

vector<string> CScriptBuilder::GetMetadataForType(int typeId) {
	map<int, vector<string>>::iterator it = typeMetadataMap.find(typeId);
	if (it != typeMetadataMap.end())
		return it->second;
	return vector<string>();
}

vector<string> CScriptBuilder::GetMetadataForFunc(asIScriptFunction *func) {
	if (func) {
		map<int, vector<string>>::iterator it = funcMetadataMap.find(func->GetId());
		if (it != funcMetadataMap.end())
			return it->second;
	}
	return vector<string>();
}

vector<string> CScriptBuilder::GetMetadataForVar(int varIdx) {
	map<int, vector<string>>::iterator it = varMetadataMap.find(varIdx);
	if (it != varMetadataMap.end())
		return it->second;
	return vector<string>();
}

vector<string> CScriptBuilder::GetMetadataForTypeProperty(int typeId, int varIdx) {
	map<int, SClassMetadata>::iterator typeIt = classMetadataMap.find(typeId);
	if (typeIt == classMetadataMap.end()) return vector<string>();
	map<int, vector<string>>::iterator propIt = typeIt->second.varMetadataMap.find(varIdx);
	if (propIt == typeIt->second.varMetadataMap.end()) return vector<string>();
	return propIt->second;
}

vector<string> CScriptBuilder::GetMetadataForTypeMethod(int typeId, asIScriptFunction *method) {
	if (method) {
		map<int, SClassMetadata>::iterator typeIt = classMetadataMap.find(typeId);
		if (typeIt == classMetadataMap.end()) return vector<string>();
		map<int, vector<string>>::iterator methodIt = typeIt->second.funcMetadataMap.find(method->GetId());
		if (methodIt == typeIt->second.funcMetadataMap.end()) return vector<string>();
		return methodIt->second;
	}
	return vector<string>();
}
#endif

string GetAbsolutePath(const string &file) {
	string str = file;
	// If this is a relative path, complement it with the current path
	if (!((str.length() > 0 && (str[0] == '/' || str[0] == '\\')) ||
	      str.find(":") != string::npos))
		str = GetCurrentDir() + "/" + str;
	// Replace backslashes for forward slashes
	size_t pos = 0;
	while ((pos = str.find("\\", pos)) != string::npos)
		str[pos] = '/';
	// Replace /./ with /
	pos = 0;
	while ((pos = str.find("/./", pos)) != string::npos)
		str.erase(pos + 1, 2);
	// For each /../ remove the parent dir and the /../
	pos = 0;
	while ((pos = str.find("/../")) != string::npos) {
		size_t pos2 = str.rfind("/", pos - 1);
		if (pos2 != string::npos)
			str.erase(pos2, pos + 3 - pos2);
		else {
			// The path is invalid
			break;
		}
	}
	return str;
}

string GetCurrentDir() {
	char buffer[1024];
	#if defined(_MSC_VER) || defined(_WIN32)
	#ifdef _WIN32_WCE
	static TCHAR apppath[MAX_PATH] = TEXT("");
	if (!apppath[0]) {
		GetModuleFileName(NULL, apppath, MAX_PATH);
		int appLen = _tcslen(apppath);
		// Look for the last backslash in the path, which would be the end
		// of the path itself and the start of the filename.  We only want
		// the path part of the exe's full-path filename
		// Safety is that we make sure not to walk off the front of the
		// array (in case the path is nothing more than a filename)
		while (appLen > 1) {
			if (apppath[appLen - 1] == TEXT('\\'))
				break;
			appLen--;
		}
		// Terminate the string after the trailing backslash
		apppath[appLen] = TEXT('\0');
	}
	#ifdef _UNICODE
	wcstombs(buffer, apppath, min(1024, wcslen(apppath)*sizeof(wchar_t)));
	#else
	memcpy(buffer, apppath, min(1024, strlen(apppath)));
	#endif
	return buffer;
	#elif defined(__S3E__)
	// Marmalade uses its own portable C library
	return getcwd(buffer, (int)1024);
	#elif _XBOX_VER >= 200
	// XBox 360 doesn't support the getcwd function, just use the root folder
	return "game:/";
	#elif defined(_M_ARM)
	// TODO: How to determine current working dir on Windows Phone?
	return "";
	#else
	return _getcwd(buffer, (int)1024);
	#endif // _MSC_VER
	#elif defined(__APPLE__) || defined(__linux__)
	return getcwd(buffer, 1024);
	#else
	return "";
	#endif
}

END_AS_NAMESPACE


