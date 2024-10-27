/* filesystem.cpp - filesystem functions code
 * Originally these consisted of Angelscript's filesystem addon but with the class removed, however are in the process of being replaced with Poco::File.
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include <array>
#include <string>
#include <angelscript.h> // the actual Angelscript header
#include <scriptarray.h>
#include <Poco/Exception.h>
#include <Poco/File.h>
#include <Poco/Glob.h>
#include <Poco/Path.h>
#include <Poco/Timestamp.h>
#include <Poco/UnicodeConverter.h>
#include <SDL3/SDL.h>
#include "nvgt_angelscript.h" // nvgt's Angelscript implementation needed for get_array_type

using namespace std;
using namespace Poco;

#include <string.h>

bool FileHardLink(const std::string& source, const std::string& target) {
	try {
		Poco::File(source).linkTo(target, Poco::File::LINK_HARD);
	} catch (Poco::Exception) {
		return false;
	}
	return false;
}

bool FNMatch(const std::string& file, const std::string& pattern) {
	try {
		return Glob(pattern).match(file);
	} catch(Exception& e) { return false; }
}

// Includes below only used for this function, the Angelscript filesystem functions are faster than Poco's directory iterators where we have to repeatedly call GetFileAttributes to determine whether each item is a file or directory.
#ifdef _WIN32
#include <windows.h>
#else
#include <sys/stat.h>
#include <dirent.h>
#endif

CScriptArray* FindFiles(const string& path) {
	// Obtain a pointer to the engine
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();

	// TODO: This should only be done once
	// TODO: This assumes that CScriptArray was already registered
	asITypeInfo* arrayType = get_array_type("array<string>");

	// Create the array object
	CScriptArray* array = CScriptArray::Create(arrayType);

	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	WIN32_FIND_DATAW ffd;
	HANDLE hFind = FindFirstFileExW(bufUTF16, FindExInfoStandard, &ffd, FindExSearchNameMatch, NULL, FIND_FIRST_EX_LARGE_FETCH);
	if (INVALID_HANDLE_VALUE == hFind)
		return array;

	do {
		// Skip directories
		if ((ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			continue;

		// Convert the file name back to UTF8
		char bufUTF8[1024];
		WideCharToMultiByte(CP_UTF8, 0, ffd.cFileName, -1, bufUTF8, 1024, 0, 0);

		// Add the file to the array
		array->Resize(array->GetSize() + 1);
		((string*)(array->At(array->GetSize() - 1)))->assign(bufUTF8);
	} while (FindNextFileW(hFind, &ffd) != 0);

	FindClose(hFind);
	#else
	int wildcard = path.rfind('/');
	if (wildcard == std::string::npos) wildcard = path.rfind('\\');
	string currentPath = path;
	string Wildcard = "*";
	if (wildcard != std::string::npos) {
		currentPath = path.substr(0, wildcard + 1);
		Wildcard = path.substr(wildcard + 1);
	} else {
		currentPath = "./";
		Wildcard = path;
	}
	dirent* ent = 0;
	DIR* dir = opendir(currentPath.c_str());
	if (!dir) return array;
	while ((ent = readdir(dir)) != NULL) {
		const string filename = ent->d_name;

		// Skip . and ..
		if (filename[0] == '.')
			continue;

		// Skip sub directories
		string fullname = currentPath + filename;
		struct stat st;
		if (stat(fullname.c_str(), &st) == -1)
			continue;
		if ((st.st_mode & S_IFDIR) != 0)
			continue;

		// wildcard matching
		if (!FNMatch(filename, Wildcard)) continue;

		// Add the file to the array
		array->Resize(array->GetSize() + 1);
		((string*)(array->At(array->GetSize() - 1)))->assign(filename);
	}
	closedir(dir);
	#endif

	return array;
}

CScriptArray* FindDirectories(const string& path) {
	// Obtain a pointer to the engine
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();

	// TODO: This assumes that CScriptArray was already registered
	asITypeInfo* arrayType = get_array_type("array<string>");

	// Create the array object
	CScriptArray* array = CScriptArray::Create(arrayType);

	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	WIN32_FIND_DATAW ffd;
	HANDLE hFind = FindFirstFileExW(bufUTF16, FindExInfoStandard, &ffd, FindExSearchNameMatch, NULL, FIND_FIRST_EX_LARGE_FETCH);
	if (INVALID_HANDLE_VALUE == hFind)
		return array;

	do {
		// Skip files
		if (!(ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			continue;

		// Convert the file name back to UTF8
		char bufUTF8[1024];
		WideCharToMultiByte(CP_UTF8, 0, ffd.cFileName, -1, bufUTF8, 1024, 0, 0);

		if (strcmp(bufUTF8, ".") == 0 || strcmp(bufUTF8, "..") == 0)
			continue;

		// Add the dir to the array
		array->Resize(array->GetSize() + 1);
		((string*)(array->At(array->GetSize() - 1)))->assign(bufUTF8);
	} while (FindNextFileW(hFind, &ffd) != 0);

	FindClose(hFind);
	#else
	int wildcard = path.rfind('/');
	if (wildcard == std::string::npos) wildcard = path.rfind('\\');
	string currentPath = path;
	string Wildcard = "*";
	if (wildcard != std::string::npos) {
		currentPath = path.substr(0, wildcard + 1);
		Wildcard = path.substr(wildcard + 1);
	} else {
		currentPath = "./";
		Wildcard = path;
	}
	dirent* ent = 0;
	DIR* dir = opendir(currentPath.c_str());
	if (!dir) return array;
	while ((ent = readdir(dir)) != NULL) {
		const string filename = ent->d_name;

		// Skip . and ..
		if (filename[0] == '.')
			continue;

		// Skip files
		string fullname = currentPath + filename;
		struct stat st;
		if (stat(fullname.c_str(), &st) == -1)
			continue;
		if ((st.st_mode & S_IFDIR) == 0)
			continue;

		// wildcard matching
		if (!FNMatch(filename, Wildcard)) continue;

		// Add the dir to the array
		array->Resize(array->GetSize() + 1);
		((string*)(array->At(array->GetSize() - 1)))->assign(filename);
	}
	closedir(dir);
	#endif

	return array;
}

CScriptArray* script_glob(const string& pattern, int options) {
	// Expected to have been called from a script.
	CScriptArray* array = CScriptArray::Create(get_array_type("array<string>"));
	set<string> files;
	try {
		Glob::glob(pattern, files, options);
		array->Reserve(files.size());
		for (const std::string& path : files) array->InsertLast((void*)&path);
	} catch(Exception&) {}
	return array;
}
bool DirectoryExists(const string& path) {
	try {
		File f(path);
		return f.exists() && f.isDirectory();
	} catch(Exception& e) { return false; }
}

bool FileExists(const string& path) {
	#ifdef _WIN32
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	// Check if the path exists and is a directory
	DWORD attrib = GetFileAttributesW(bufUTF16);
	if (attrib == INVALID_FILE_ATTRIBUTES || (attrib & FILE_ATTRIBUTE_DIRECTORY))
		return false;
	return true;
	#else
	// Check if the path exists and is a file
	struct stat st;
	if (stat(path.c_str(), &st) == -1)
		return false;
	if ((st.st_mode & S_IFDIR) != 0)
		return false;
	return true;
	#endif
	return false;
}

asINT64 FileGetSize(const string& path) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	// Get the size of the file
	WIN32_FILE_ATTRIBUTE_DATA attrs;
	if (!GetFileAttributesExW(bufUTF16, GetFileExInfoStandard, &attrs))
		return -1;
	LARGE_INTEGER size;
	size.HighPart = attrs.nFileSizeHigh;
	size.LowPart = attrs.nFileSizeLow;
	return size.QuadPart;
	#else
	// Get the size of the file
	struct stat st;
	if (stat(path.c_str(), &st) == -1)
		return -1;
	return asINT64(st.st_size);
	#endif
}

bool DirectoryCreate(const string& path) {
	try {
		Poco::File(path).createDirectories();
	} catch (Poco::Exception& e) {
		return false;
	}
	return true;
}

bool DirectoryDelete(const string& path, bool recursive) {
	try {
		File(path).remove(recursive);
		return true;
	} catch(Exception& e) { return false; }
}

bool FileDelete(const string& path) {
	return DirectoryDelete(path, false);
}

bool FileCopy(const string& source, const string& target, bool overwrite) {
	try {
		File(source).copyTo(target, !overwrite? File::OPT_FAIL_ON_OVERWRITE : 0);
		return true;
	} catch(Exception& e) { return false; }
}

bool FileMove(const string& source, const string& target, bool overwrite) {
	try {
		File(source).renameTo(target, File::OPT_FAIL_ON_OVERWRITE);
		return true;
	} catch(Exception& e) { return false; }
}

Timestamp FileGetCreated(const string& path) {
	return File(path).created();
}

Timestamp FileGetModified(const string& path) {
	return File(path).getLastModified();
}

std::string get_preferences_path(const std::string& org, const std::string& app) {
	char* p = SDL_GetPrefPath(org.c_str(), app.c_str());
	if (!p) return "";
	std::string result = p;
	SDL_free(p);
	return result;
}
std::string file_get_contents(const std::string& filename) {
	SDL_IOStream* stream = SDL_IOFromFile(filename.c_str(), "rb");
	if (!stream) return ""; // sigh we really need to figure out a get_last_error situation or something here.
	std::array<char, 4096> buffer;
	std::string result;
	Sint64 size;
	while ((size = SDL_ReadIO(stream, buffer.data(), buffer.size())) > 0) result.append(buffer.begin(), buffer.begin() + size);
	SDL_CloseIO(stream);
	return result;
}
bool file_put_contents(const std::string& filename, const std::string& contents, bool append) {
	SDL_IOStream* stream = SDL_IOFromFile(filename.c_str(), append? "ab" : "wb");
	if (!stream) return false;
	bool result = SDL_WriteIO(stream, contents.data(), contents.size()) == contents.size();
	SDL_CloseIO(stream);
	return result;
}


void RegisterScriptFileSystemFunctions(asIScriptEngine* engine) {
	engine->RegisterEnum("glob_options");
	engine->RegisterEnumValue("glob_options", "GLOB_DEFAULT", Glob::GLOB_DEFAULT);
	engine->RegisterEnumValue("glob_options", "GLOB_IGNORE_HIDDEN", Glob::GLOB_DOT_SPECIAL);
	engine->RegisterEnumValue("glob_options", "GLOB_FOLLOW_SYMLINKS", Glob::GLOB_FOLLOW_SYMLINKS);
	engine->RegisterEnumValue("glob_options", "GLOB_CASELESS", Glob::GLOB_CASELESS);
	engine->RegisterGlobalFunction("bool directory_exists(const string& in path)", asFUNCTION(DirectoryExists), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool directory_create(const string& in path)", asFUNCTION(DirectoryCreate), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool directory_delete(const string& in path, bool recursive = true)", asFUNCTION(DirectoryDelete), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_exists(const string& in path)", asFUNCTION(FileExists), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_delete(const string& in path)", asFUNCTION(FileDelete), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_copy(const string& in source, const string& in destination, bool)", asFUNCTION(FileCopy), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_hard_link(const string& in source, const string&in destination)", asFUNCTION(FileHardLink), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_move(const string& in source, const string& in destination)", asFUNCTION(FileMove), asCALL_CDECL);
	engine->RegisterGlobalFunction("string[]@ find_directories(const string& in pattern)", asFUNCTION(FindDirectories), asCALL_CDECL);
	engine->RegisterGlobalFunction("string[]@ find_files(const string& in pattern)", asFUNCTION(FindFiles), asCALL_CDECL);
	engine->RegisterGlobalFunction("string[]@ glob(const string& in pattern, glob_options options = GLOB_DEFAULT)", asFUNCTION(script_glob), asCALL_CDECL);
	engine->RegisterGlobalFunction("int64 file_get_size(const string& in path)", asFUNCTION(FileGetSize), asCALL_CDECL);
	engine->RegisterGlobalFunction("timestamp file_get_date_created(const string& in path)", asFUNCTION(FileGetCreated), asCALL_CDECL);
	engine->RegisterGlobalFunction("timestamp file_get_date_modified(const string& in path)", asFUNCTION(FileGetModified), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool fnmatch(const string& in text, const string& in pattern)", asFUNCTION(FNMatch), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_preferences_path(const string&in company_name, const string&in application_name)", asFUNCTION(get_preferences_path), asCALL_CDECL);
	engine->RegisterGlobalFunction("string DIRECTORY_PREFERENCES(const string&in company_name, const string&in application_name)", asFUNCTION(get_preferences_path), asCALL_CDECL);
	engine->RegisterGlobalFunction("string file_get_contents(const string&in filename)", asFUNCTION(file_get_contents), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_put_contents(const string&in filename, const string&in contents, bool append = false)", asFUNCTION(file_put_contents), asCALL_CDECL);
}
