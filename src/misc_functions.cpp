/* misc_functions.cpp - code for any wrapped functions that we don't currently have a better place for
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#define NOMINMAX
#include <string>
#include <algorithm>
#include <vector>
#include <regex>
#include <math.h>
#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#include <windows.h>
	#include <direct.h>
#else
	#include <unistd.h>
#endif
#include <Poco/AutoPtr.h>
#include <Poco/Exception.h>
#include <Poco/TextConverter.h>
#include <Poco/TextIterator.h>
#include <Poco/UnicodeConverter.h>
#include <Poco/UTF8Encoding.h>
#include <ctime>
#include <sstream>
#include <angelscript.h>
#include <scriptarray.h>
#include <SDL3/SDL.h>
#include <tinyexpr.h>
#include <dbgtools.h>
#include "datastreams.h"
#include "nvgt_angelscript.h"
#include "nvgt.h"
#include "UI.h" // wait
#include "bl_number_to_words.h"
#include "obfuscate.h"
#include "input.h"
#include "misc_functions.h"
#include <fast_float/fast_float.h>
#include <system_error>

bool ChDir(const std::string& d) {
	#ifdef _WIN32
	return _chdir(d.c_str()) == 0;
	#else
	return chdir(d.c_str()) == 0;
	#endif
}
asBYTE character_to_ascii(const std::string& character) {
	if (character == "") return 0;
	return character[0];
}
std::string ascii_to_character(asBYTE ascii) {
	return std::string(1, ascii);
}
// next ffunction mostly from the cpptotp project:
std::string base32_normalize(const std::string& unnorm) {
	std::string ret;
	for (char c : unnorm) {
		if (c == ' ' || c == '\n' || c == '-') {
			// skip separators
		} else if (std::islower(c)) {
			// make uppercase
			char u = std::toupper(c);
			ret.push_back(u);
		} else
			ret.push_back(c);
	}
	while (ret.size() % 8 != 0)
		ret.push_back('=');
	return ret;
}
asQWORD timestamp() {
	return time(0);
}
std::string get_command_line() {
	return g_CommandLine;
}
float fRound(float n, int p) {
	int P = powf(10, fabs(p));
	if (p > 0)
		return roundf(n * P) / P;
	else if (p < 0)
		return roundf(n / P) * P;
	return roundf(n);
}
double Round(double n, int p) {
	int P = pow(10, abs(p));
	if (p > 0)
		return round(n * P) / P;
	else if (p < 0)
		return round(n / P) * P;
	return round(n);
}
enum process_flags {
	PROCESS_PIPE_STDIN = 1,        // connect stdin to a writable datastream
	PROCESS_PIPE_STDOUT = 2,       // connect stdout to a readable datastream
	PROCESS_PIPE_STDERR = 4,       // connect stderr to a readable datastream
	PROCESS_STDERR_TO_STDOUT = 8,  // redirect stderr into stdout (ignored if PROCESS_PIPE_STDERR is set)
	PROCESS_BACKGROUND = 16,       // run process detached from the console
	PROCESS_WAIT = 32,             // block until the process exits (used by the bool run() overload)
	PROCESS_FAIL_EXCEPTION = 64,   // throw a Poco::RuntimeException containing SDL_GetError() if the process fails to launch
	PROCESS_CAPTURE = 128,         // convenience flag: forces PROCESS_PIPE_STDOUT | PROCESS_PIPE_STDERR
};

// close_cb called by datastream when closing. Detaches the underlying SDL_IOStream handle so that close doesn't try to SDL_CloseIO a stream owned by SDL_Process.
static void process_stream_detach_cb(datastream* ds) {
	if (ds->user) static_cast<sdl_file_ios*>(ds->user)->detach(); // user is then nulled by datastream::close() after calling the callback; the stream itself is deleted by the datastream as it owns _istr/_ostr.
}

class process {
	SDL_Process* _proc;
	Poco::AutoPtr<datastream> _stdin_ds;
	Poco::AutoPtr<datastream> _stdout_ds;
	Poco::AutoPtr<datastream> _stderr_ds;
	mutable int _refcount;
	datastream* make_stream(SDL_IOStream* io, std::ios::openmode mode) {
		if (!io) return nullptr;
		datastream* ds = mode & std::ios::in? new datastream(new sdl_file_input_stream(io), nullptr, "", Poco::BinaryReader::NATIVE_BYTE_ORDER, nullptr) : new datastream(nullptr, new sdl_file_output_stream(io), "", Poco::BinaryReader::NATIVE_BYTE_ORDER, nullptr);
		ds->set_close_callback(process_stream_detach_cb);
		ds->binary = false;
		ds->skip_eof = true;
		if (mode & std::ios::out) ds->autoflush = true;
		return ds;
	}
	void detach_stream(Poco::AutoPtr<datastream>& ds) {
		sdl_file_ios* fs = nullptr;
		if (ds && ds->get_istr()) fs = dynamic_cast<sdl_file_ios*>(ds->get_istr());
		else if (ds && ds->get_ostr()) fs = dynamic_cast<sdl_file_ios*>(ds->get_ostr());
		if (fs) fs->detach();
	}
public:
	process(SDL_Process* proc) : _proc(proc), _refcount(1) {}
	~process() {
		// Detach all stdio wrappers before destroying the SDL process; SDL_DestroyProcess frees the underlying SDL_IOStreams.
		detach_stream(_stdin_ds);
		detach_stream(_stdout_ds);
		detach_stream(_stderr_ds);
		if (_proc) SDL_DestroyProcess(_proc);
	}
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	bool is_valid() const { return _proc != nullptr; }
	Sint64 get_pid() const {
		if (!_proc) return -1;
		return SDL_GetNumberProperty(SDL_GetProcessProperties(_proc), SDL_PROP_PROCESS_PID_NUMBER, -1);
	}
	bool kill(bool force = true) { return _proc && SDL_KillProcess(_proc, force); }
	bool running() const { return _proc && !SDL_WaitProcess(_proc, false, nullptr); }
	int wait() { int code = -1; if (_proc) SDL_WaitProcess(_proc, true, &code); return code; }
	std::string read() {
		if (!_proc) return "";
		size_t datasize = 0;
		void* data = SDL_ReadProcess(_proc, &datasize, nullptr);
		if (!data) return "";
		std::string result(static_cast<char*>(data), datasize);
		SDL_free(data);
		return result;
	}
	datastream* get_stdin() {
		if (!_proc) return nullptr;
		if (!_stdin_ds) {
			SDL_IOStream* io = SDL_GetProcessInput(_proc);
			datastream* ds = make_stream(io, std::ios::out);
			if (ds) _stdin_ds = ds;
			else return nullptr;
		}
		return _stdin_ds.get();
	}
	datastream* get_stdout() {
		if (!_proc) return nullptr;
		if (!_stdout_ds) {
			SDL_IOStream* io = SDL_GetProcessOutput(_proc);
			datastream* ds = make_stream(io, std::ios::in);
			if (ds) _stdout_ds = ds;
			else return nullptr;
		}
		return _stdout_ds.get();
	}
	datastream* get_stderr() {
		if (!_proc) return nullptr;
		if (!_stderr_ds) {
			SDL_PropertiesID props = SDL_GetProcessProperties(_proc);
			SDL_IOStream* io = props ? static_cast<SDL_IOStream*>(SDL_GetPointerProperty(props, SDL_PROP_PROCESS_STDERR_POINTER, nullptr)) : nullptr;
			datastream* ds = make_stream(io, std::ios::in);
			if (ds) _stderr_ds = ds;
			else return nullptr;
		}
		return _stderr_ds.get();
	}
};

process* run(const std::vector<std::string>& args, int flags, const std::string& workdir) {
	if (args.empty()) return nullptr;
	// Expand convenience flags and auto-pipe stdout/stderr when no console is available (e.g. GUI subsystem on Windows, where DuplicateHandle on invalid stdio handles would otherwise cause CreateProcessWithProperties to fail).
	if ((flags & PROCESS_CAPTURE) || !is_console_available()) flags |= PROCESS_PIPE_STDOUT | PROCESS_PIPE_STDERR;
	std::vector<const char*> argv;
	argv.reserve(args.size() + 1);
	for (const auto& a : args) argv.push_back(a.c_str());
	argv.push_back(nullptr);
	SDL_PropertiesID props = SDL_CreateProperties();
	if (!props) return nullptr;
	SDL_SetPointerProperty(props, SDL_PROP_PROCESS_CREATE_ARGS_POINTER, argv.data());
	if (!workdir.empty()) SDL_SetStringProperty(props, SDL_PROP_PROCESS_CREATE_WORKING_DIRECTORY_STRING, workdir.c_str());
	if (flags & PROCESS_PIPE_STDIN) SDL_SetNumberProperty(props, SDL_PROP_PROCESS_CREATE_STDIN_NUMBER, SDL_PROCESS_STDIO_APP);
	if (flags & PROCESS_PIPE_STDOUT) SDL_SetNumberProperty(props, SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER, SDL_PROCESS_STDIO_APP);
	if (flags & PROCESS_PIPE_STDERR) SDL_SetNumberProperty(props, SDL_PROP_PROCESS_CREATE_STDERR_NUMBER, SDL_PROCESS_STDIO_APP);
	if ((flags & PROCESS_STDERR_TO_STDOUT) && !(flags & PROCESS_PIPE_STDERR)) SDL_SetBooleanProperty(props, SDL_PROP_PROCESS_CREATE_STDERR_TO_STDOUT_BOOLEAN, true);
	if (flags & PROCESS_BACKGROUND) SDL_SetBooleanProperty(props, SDL_PROP_PROCESS_CREATE_BACKGROUND_BOOLEAN, true);
	SDL_Process* proc = SDL_CreateProcessWithProperties(props);
	SDL_DestroyProperties(props);
	if (!proc) {
		if (flags & PROCESS_FAIL_EXCEPTION) throw Poco::RuntimeException("process launch failed", SDL_GetError());
		return nullptr;
	}
	process* result = new process(proc);
	if (flags & PROCESS_WAIT) result->wait();
	return result;
}

static process* run_script(CScriptArray* args, int flags = 0, const std::string& workdir = "") {
	if (!args) return nullptr;
	std::vector<std::string> vargs;
	vargs.reserve(args->GetSize());
	for (asUINT i = 0; i < args->GetSize(); i++) vargs.push_back(*static_cast<std::string*>(args->At(i)));
	return run(vargs, flags, workdir);
}

bool run(const std::string& filename, const std::string& cmdline, bool wait_for_completion, bool background) {
	std::vector<std::string> args;
	args.push_back(filename);
	if (!cmdline.empty()) {
		std::istringstream iss(cmdline);
		std::string token;
		while (iss >> token) args.push_back(token);
	}
	int flags = (wait_for_completion ? PROCESS_WAIT : 0) | (background ? PROCESS_BACKGROUND : 0);
	Poco::AutoPtr<process> proc(run(args, flags, ""));
	return proc != nullptr;
}
double tinyexpr(const std::string& expr) {
	return te_interp(expr.c_str(), NULL);
}

std::string number_to_words(asINT64 number, bool include_and) {
	if (number < 0) return "negative " + number_to_words(number * -1, include_and);
	std::string output(128, '\0');
	size_t size = bl_number_to_words(number, &output[0], 96, include_and);
	if (size > 96) {
		output.resize(size);
		size = bl_number_to_words(number, &output[0], size, include_and);
	}
	output.resize(size - 1); // It appears bl_number_to_words includes a trailing null byte in it's size calculation.
	return output;
}
int get_last_error() {
	int e = g_LastError;
	g_LastError = 0;
	return e;
}
asQWORD get_process_id() {
	#ifdef _WIN32
	return GetCurrentProcessId();
	#else
	return getpid();
	#endif
}

double range_convert(double old_value, double old_min, double old_max, double new_min, double new_max) {
	return ((old_value - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min;
}
float range_convert(float old_value, float old_min, float old_max, float new_min, float new_max) {
	return ((old_value - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min;
}
float range_convert_midpoint(float old_value, float old_min, float old_midpoint, float old_max, float new_min, float new_midpoint, float new_max) {
	if (old_value < old_midpoint) return range_convert(old_value, old_min, old_midpoint, new_min, new_midpoint);
	else return range_convert(old_value, old_midpoint, old_max, new_midpoint, new_max);
}
std::string float_to_bytes(float f) {
	return std::string((char*)&f, 4);
}
float bytes_to_float(const std::string& s) {
	if (s.size() != 4) return 0;
	return *((float*)&s[0]);
}
std::string double_to_bytes(double d) {
	return std::string((char*)&d, 8);
}
double bytes_to_double(const std::string& s) {
	if (s.size() != 8) return 0;
	return *((double*)&s[0]);
}

std::string string_to_upper_case(std::string s) {
	for (int i = 0; i < (int)s.length(); i++)
		s[i] = toupper(s[i]);
	return s;
}

//Following function originally from https://stackoverflow.com/questions/642213/how-to-implement-a-natural-sort-algorithm-in-c
bool natural_number_sort(const std::string& a, const std::string& b) {
	if (a.empty())
		return true;
	if (b.empty())
		return false;
	if (isdigit(a[0]) && !isdigit(b[0]))
		return true;
	if (!isdigit(a[0]) && isdigit(b[0]))
		return false;
	if (!isdigit(a[0]) && !isdigit(b[0])) {
		if (a[0] == b[0])
			return natural_number_sort(a.substr(1), b.substr(1));
		return (string_to_upper_case(a) < string_to_upper_case(b));
	}
	std::istringstream issa(a);
	std::istringstream issb(b);
	int ia, ib;
	issa >> ia;
	issb >> ib;
	if (ia != ib)
		return ia < ib;
	std::string anew, bnew;
	std::getline(issa, anew);
	std::getline(issb, bnew);
	return (natural_number_sort(anew, bnew));
}

refstring* new_refstring() {
	return new refstring();
}

template<typename T> typename T::size_type LevenshteinDistance(const T& source, const T& target, typename T::size_type insert_cost = 1, typename T::size_type delete_cost = 1, typename T::size_type replace_cost = 1) {
	if (source.size() > target.size())
		return LevenshteinDistance(target, source, delete_cost, insert_cost, replace_cost);
	using TSizeType = typename T::size_type;
	const TSizeType min_size = source.size(), max_size = target.size();
	std::vector<TSizeType> lev_dist(min_size + 1);
	lev_dist[0] = 0;
	for (TSizeType i = 1; i <= min_size; ++i)
		lev_dist[i] = lev_dist[i - 1] + delete_cost;
	for (TSizeType j = 1; j <= max_size; ++j) {
		TSizeType previous_diagonal = lev_dist[0], previous_diagonal_save;
		lev_dist[0] += insert_cost;
		for (TSizeType i = 1; i <= min_size; ++i) {
			previous_diagonal_save = lev_dist[i];
			if (source[i - 1] == target[j - 1])
				lev_dist[i] = previous_diagonal;
			else
				lev_dist[i] = std::min(std::min(lev_dist[i - 1] + delete_cost, lev_dist[i] + insert_cost), previous_diagonal + replace_cost);
			previous_diagonal = previous_diagonal_save;
		}
	}
	return lev_dist[min_size];
}
int string_distance(const std::string& a, const std::string& b, unsigned int insert_cost = 1, unsigned int delete_cost = 1, unsigned int replace_cost = 1) {
	return LevenshteinDistance<std::string>(a, b, insert_cost, delete_cost, replace_cost);
}
int utf8prev(const std::string& text, int offset = 0) {
	if (offset < 1 || offset > text.size()) return offset - 1;
	offset--;
	char b = text[offset];
	while ((b & (1 << 7)) != 0 && (b & (1 << 6)) == 0) { // UTF8 continuation char
		offset--;
		if (offset < 0) break;
		b = text[offset];
	}
	return offset;
}
int utf8size(const std::string& character) {
	if (character.size() < 1) return 0;
	char b = character[0];
	if (b & 1 << 7) {
		if (b & 1 << 6) {
			if (b & 1 << 5) {
				if (b & 1 << 4) {
					return 4; // because bit pattern 1111
				}
				return 3; // because bit pattern 111
			}
			return 2; // because bit pattern 11
		}
		return 1; // apparently stuck in the middle of a character
	}
	return 1; // char is less than 128
}
int utf8next(const std::string& text, int offset = 0) {
	if (offset < 0) return offset - 1;
	if (offset >= text.size()) return offset + 1;
	return offset + utf8size(text.substr(offset, 1));
}

/**
 * Checks whether a string is valid UTF-8.
 * Can also prohibit strings containing ASCII special characters.
 * Used internally by pack file, sound service.
 * written by Caturria.
 */
bool is_valid_utf8(const std::string &text, bool ban_ascii_special) {
	Poco::UTF8Encoding encoding;
	Poco::TextIterator i(text, encoding);
	Poco::TextIterator end(text);
	while (i != end) {
		// Reject entirely invalid characters:
		if (*i == -1)
			return false;
		// Also reject ASCII 0 - 31 and 127 as these are not printable characters:
		if ((*i < 32 || *i == 127) && ban_ascii_special)
			return false;
		i++;
	}
	return true;
}
CScriptArray* get_preferred_locales() {
	asITypeInfo* arrayType = get_array_type("array<string>");
	CScriptArray* array = CScriptArray::Create(arrayType);
	int count;
	SDL_Locale** locales = SDL_GetPreferredLocales(&count);
	if (!locales) return array;
	for (int i = 0; i < count; i++) {
		std::string tmp = locales[i]->language;
		if (locales[i]->country) tmp += std::string("-") + locales[i]->country;
		array->Resize(array->GetSize() + 1);
		((std::string*)(array->At(array->GetSize() - 1)))->assign(tmp);
	}
	SDL_free(locales);
	return array;
}

float parse_float(const std::string& val) {
	float res = 0.0;
	const auto[valPtr, valEc] = fast_float::from_chars(val.data(), val.data() + val.size(), res);
	if (valEc != std::errc()) return 0.0;
	return res;
}
double parse_double(const std::string& val) {
	double res = 0.0;
	const auto[valPtr, valEc] = fast_float::from_chars(val.data(), val.data() + val.size(), res);
	if (valEc != std::errc()) return 0.0;
	return res;
}

// Small wrapper which allows statically typed read-write access to an arbitrary memory buffer from scripts.
// It should be implicitly understood by the scripter that this interface is low level, contains minimal handholding and is not subject to sandboxing!
const void* script_memory_buffer::at(size_t index) const {
	if (!ptr) throw std::invalid_argument("memory buffer null pointer access");
	int typesize = g_ScriptEngine->GetSizeOfPrimitiveType(subtypeid);
	if (size && index >= size) throw std::out_of_range("index out of bounds");
	return (void*)(((char*)ptr) + (index * typesize));
}
void* script_memory_buffer::at(size_t index) { return const_cast<void*>(const_cast<const script_memory_buffer*>(this)->at(index)); }
CScriptArray* script_memory_buffer::to_array() const {
	CScriptArray* array = CScriptArray::Create(g_ScriptEngine->GetTypeInfoByDecl(Poco::format("array<%s>", std::string(g_ScriptEngine->GetTypeDeclaration(subtypeid, false))).c_str()), size);
	if (!array) return nullptr;
	std::memcpy(array->GetBuffer(), ptr, size * g_ScriptEngine->GetSizeOfPrimitiveType(subtypeid));
	return array;
}
script_memory_buffer& script_memory_buffer::from_array(CScriptArray* array) {
	if (!array) std::memset(ptr, 0, size * g_ScriptEngine->GetSizeOfPrimitiveType(subtypeid));
	else std::memcpy(ptr, array->GetBuffer(), (array->GetSize() < size? array->GetSize() : size) * g_ScriptEngine->GetSizeOfPrimitiveType(subtypeid));
	return *this;
}
int script_memory_buffer::get_element_size() const {return g_ScriptEngine->GetSizeOfPrimitiveType(subtypeid); }
void script_memory_buffer::make(script_memory_buffer* mem, asITypeInfo* subtype, void* ptr, int size) { new(mem) script_memory_buffer(subtype, ptr, size); }
void script_memory_buffer::copy(script_memory_buffer* mem, asITypeInfo* subtype, const script_memory_buffer& other) { new(mem) script_memory_buffer(other); }
void script_memory_buffer::destroy(script_memory_buffer* mem) { mem->~script_memory_buffer(); }
bool script_memory_buffer::verify(asITypeInfo *subtype, bool& no_gc) {
	if (subtype->GetSubTypeId() & asTYPEID_MASK_OBJECT ) return false;
	return no_gc = true;
}
void script_memory_buffer::angelscript_register(asIScriptEngine* engine) {
	engine->RegisterObjectType("memory_buffer<class T>", sizeof(script_memory_buffer), asOBJ_VALUE | asOBJ_TEMPLATE | asGetTypeTraits<script_memory_buffer>());
	engine->RegisterObjectBehaviour("memory_buffer<T>", asBEHAVE_CONSTRUCT, "void f(int&in subtype, uint64 ptr, uint64 size)", asFUNCTION(make), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("memory_buffer<T>", asBEHAVE_CONSTRUCT, "void f(int&in subtype, const memory_buffer<T>&in other)", asFUNCTION(copy), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("memory_buffer<T>", asBEHAVE_TEMPLATE_CALLBACK, "bool f(int&in subtype, bool&out no_gc)", asFUNCTION(verify), asCALL_CDECL);
	engine->RegisterObjectBehaviour("memory_buffer<T>", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(destroy), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectProperty("memory_buffer<T>", "uint64 address", asOFFSET(script_memory_buffer, ptr));
	engine->RegisterObjectProperty("memory_buffer<T>", "uint64 size", asOFFSET(script_memory_buffer, size));
	engine->RegisterObjectMethod("memory_buffer<T>", "T& opIndex(uint64 index)", asMETHODPR(script_memory_buffer, at, (size_t), void*), asCALL_THISCALL);
	engine->RegisterObjectMethod("memory_buffer<T>", "const T& opIndex(uint64 index) const", asMETHODPR(script_memory_buffer, at, (size_t) const, const void*), asCALL_THISCALL);
	engine->RegisterObjectMethod("memory_buffer<T>", "array<T>@ opImplConv() const", asMETHOD(script_memory_buffer, to_array), asCALL_THISCALL);
	engine->RegisterObjectMethod("memory_buffer<T>", "memory_buffer<T>& opAssign(array<T>@ array)", asMETHOD(script_memory_buffer, from_array), asCALL_THISCALL);
	engine->RegisterObjectMethod("memory_buffer<T>", "int get_element_size() const property", asMETHOD(script_memory_buffer, get_element_size), asCALL_THISCALL);
}
void* string_get_address(std::string& str) {
	if (str.size() < 1) return nullptr;
	return &str[0];
}

void RegisterMiscFunctions(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_OS);
	engine->RegisterGlobalFunction(_O("bool chdir(const string& in directory)"), asFUNCTION(ChDir), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	engine->RegisterGlobalFunction(_O("uint8 character_to_ascii(const string&in character)"), asFUNCTION(character_to_ascii), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string ascii_to_character(uint8 character_code)"), asFUNCTION(ascii_to_character), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_base32_normalize(const string& in base32encoded)"), asFUNCTION(base32_normalize), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATETIME);
	engine->RegisterGlobalFunction(_O("uint64 get_TIME_STAMP() property"), asFUNCTION(timestamp), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_OS);
	engine->RegisterGlobalFunction(_O("string[]@ get_preferred_locales()"), asFUNCTION(get_preferred_locales), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_COMMAND_LINE() property"), asFUNCTION(get_command_line), asCALL_CDECL);
	engine->RegisterEnum(_O("process_flags"));
	engine->RegisterEnumValue(_O("process_flags"), _O("PROCESS_PIPE_STDIN"), PROCESS_PIPE_STDIN);
	engine->RegisterEnumValue(_O("process_flags"), _O("PROCESS_PIPE_STDOUT"), PROCESS_PIPE_STDOUT);
	engine->RegisterEnumValue(_O("process_flags"), _O("PROCESS_PIPE_STDERR"), PROCESS_PIPE_STDERR);
	engine->RegisterEnumValue(_O("process_flags"), _O("PROCESS_STDERR_TO_STDOUT"), PROCESS_STDERR_TO_STDOUT);
	engine->RegisterEnumValue(_O("process_flags"), _O("PROCESS_BACKGROUND"), PROCESS_BACKGROUND);
	engine->RegisterEnumValue(_O("process_flags"), _O("PROCESS_WAIT"), PROCESS_WAIT);
	engine->RegisterEnumValue(_O("process_flags"), _O("PROCESS_FAIL_EXCEPTION"), PROCESS_FAIL_EXCEPTION);
	engine->RegisterEnumValue(_O("process_flags"), _O("PROCESS_CAPTURE"), PROCESS_CAPTURE);
	engine->RegisterObjectType(_O("process"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("process"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(process, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("process"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(process, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("bool get_valid() const property"), asMETHOD(process, is_valid), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("int64 get_pid() const property"), asMETHOD(process, get_pid), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("bool get_running() const property"), asMETHOD(process, running), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("bool kill(bool force = true)"), asMETHOD(process, kill), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("int wait()"), asMETHOD(process, wait), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("string read()"), asMETHOD(process, read), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("datastream@+ get_stdin() property"), asMETHOD(process, get_stdin), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("datastream@+ get_stdout() property"), asMETHOD(process, get_stdout), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("process"), _O("datastream@+ get_stderr() property"), asMETHOD(process, get_stderr), asCALL_THISCALL);
	engine->RegisterGlobalFunction(_O("process@ run(const string[]& in args, int flags = 0, const string& in workdir = \"\")"), asFUNCTION(run_script), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool run(const string& in filename, const string& in arguments, bool wait_for_completion, bool background)"), asFUNCTIONPR(run, (const std::string&, const std::string&, bool, bool), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool is_debugger_present()"), asFUNCTION(debugger_present), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int get_last_error()"), asFUNCTION(get_last_error), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 get_process_id()"), asFUNCTION(get_process_id), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterGlobalFunction(_O("double round(double number, int place)"), asFUNCTION(Round), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("double tinyexpr(const string &in expression)"), asFUNCTION(tinyexpr), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	engine->RegisterGlobalFunction(_O("string number_to_words(int64 number, bool include_and = true)"), asFUNCTION(number_to_words), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint string_distance(const string&in string1, const string&in string2, uint insert_cost = 1, uint delete_cost = 1, uint replace_cost = 1)"), asFUNCTION(string_distance), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string float_to_bytes(float number)"), asFUNCTION(float_to_bytes), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("float bytes_to_float(const string&in data)"), asFUNCTION(bytes_to_float), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string double_to_bytes(double number)"), asFUNCTION(double_to_bytes), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("double bytes_to_double(const string&in data)"), asFUNCTION(bytes_to_double), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool natural_number_sort(const string&in string1, const string&in string2)"), asFUNCTION(natural_number_sort), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int utf8prev(const string&in text, int cursor)"), asFUNCTION(utf8prev), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int utf8next(const string&in text, int cursor)"), asFUNCTION(utf8next), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int utf8size(const string&in character)"), asFUNCTION(utf8size), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool utf8valid(const string&in text, bool ban_ascii_special = true)"), asFUNCTION(is_valid_utf8), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterObjectType(_O("refstring"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("refstring"), asBEHAVE_FACTORY, _O("refstring @s()"), asFUNCTION(new_refstring), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("refstring"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(refstring, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("refstring"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(refstring, Release), asCALL_THISCALL);
	engine->RegisterObjectProperty(_O("refstring"), _O("string str"), asOFFSET(refstring, str));
	engine->RegisterGlobalFunction(_O("uint64 memory_allocate(uint64 size)"), asFUNCTION(malloc), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 memory_allocate_units(uint64 unit_size, uint64 unit_count)"), asFUNCTION(calloc), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 memory_reallocate(uint64 ptr, uint64 size)"), asFUNCTION(realloc), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void memory_free(uint64 ptr)"), asFUNCTION(free), asCALL_CDECL);
	engine->RegisterGlobalFunction("float parse_float(const string &in number)", asFUNCTION(parse_float), asCALL_CDECL);
	engine->RegisterGlobalFunction("double parse_double(const string &in number)", asFUNCTION(parse_double), asCALL_CDECL);
	engine->RegisterEnum("system_power_state");
	engine->RegisterEnumValue("system_power_state", "POWER_STATE_ERROR", SDL_POWERSTATE_ERROR);
	engine->RegisterEnumValue("system_power_state", "POWER_STATE_UNKNOWN", SDL_POWERSTATE_UNKNOWN);
	engine->RegisterEnumValue("system_power_state", "POWER_STATE_ON_BATTERY", SDL_POWERSTATE_ON_BATTERY);
	engine->RegisterEnumValue("system_power_state", "POWER_STATE_NO_BATTERY", SDL_POWERSTATE_NO_BATTERY);
	engine->RegisterEnumValue("system_power_state", "POWER_STATE_CHARGING", SDL_POWERSTATE_CHARGING);
	engine->RegisterEnumValue("system_power_state", "POWER_STATE_CHARGED", SDL_POWERSTATE_CHARGED);
	engine->RegisterGlobalFunction("system_power_state system_power_info(int&out seconds = void, int&out percent = void)", asFUNCTION(SDL_GetPowerInfo), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_RAW_MEMORY);
	script_memory_buffer::angelscript_register(engine);
	engine->RegisterObjectMethod("string", "uint64 get_address() const property", asFUNCTION(string_get_address), asCALL_CDECL_OBJFIRST);
}
