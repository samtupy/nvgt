/* misc_functions.cpp - code for any wrapped functions that we don't currently have a better place for
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

#define NOMINMAX
#include <string>
#include <algorithm>
#include <vector>
#include <regex>
#include <math.h>
#ifdef _WIN32
	#include "InputBox.h"
	#define WIN32_LEAN_AND_MEAN
	#include <windows.h>
	#include <direct.h>
#else
	#include <unistd.h>
	#include <sys/types.h>
	#include <sys/wait.h>
#endif
#ifdef __APPLE__
	#include "apple.h"
#endif
#include <Poco/Exception.h>
#include <Poco/UnicodeConverter.h>
#include <ctime>
#include <sstream>
#include <angelscript.h>
#include <scriptarray.h>
#include <SDL2/SDL.h>
#include <tinyexpr.h>
#include <dbgtools.h>
#include "nvgt.h"
#include "bl_number_to_words.h"
#include "obfuscate.h"
#include "input.h"
#include "misc_functions.h"
#include "window.h"


int message_box(const std::string& title, const std::string& text, const std::vector<std::string>& buttons, unsigned int mb_flags) {
	// Start with the buttons.
	std::vector<SDL_MessageBoxButtonData> sdlbuttons;
	for (int i = 0; i < buttons.size(); i++) {
		std::string btn = buttons[i];
		int skip = 0;
		unsigned int button_flag = 0;
		if (btn.substr(0, 1) == "`") {
			button_flag |= SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT;
			skip += 1;
		}
		if (btn.substr(skip, 1) == "~") {
			button_flag |= SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT;
			skip += 1;
		}
		SDL_MessageBoxButtonData& sdlbtn = sdlbuttons.emplace_back();
		sdlbtn.flags = button_flag;
		sdlbtn.buttonid = i + 1;
		sdlbtn.text = buttons[i].c_str() + skip;
	}
	SDL_MessageBoxData box = {mb_flags, g_WindowHandle, title.c_str(), text.c_str(), int(sdlbuttons.size()), sdlbuttons.data(), NULL};
	int ret;
	if (SDL_ShowMessageBox(&box, &ret) != 0) return 0; // failure.
	return ret;
}
int message_box_script(const std::string& title, const std::string& text, CScriptArray* buttons, unsigned int flags) {
	std::vector<std::string> v_buttons(buttons->GetSize());
	for (unsigned int i = 0; i < buttons->GetSize(); i++) v_buttons[i] = (*(std::string*)(buttons->At(i)));
	return message_box(title, text, v_buttons, flags);
}
int alert(const std::string& title, const std::string& text, bool can_cancel, unsigned int flags) {
	std::vector<std::string> buttons = {can_cancel ? "`OK" : "`~OK"};
	if (can_cancel) buttons.push_back("~Cancel");
	return message_box(title, text, buttons, flags);
}
int question(const std::string& title, const std::string& text, bool can_cancel, unsigned int flags) {
	std::vector<std::string> buttons = {"`Yes", "No"};
	if (can_cancel) buttons.push_back("~Cancel");
	return message_box(title, text, buttons, flags);
}
BOOL ChDir(const std::string& d) {
	#ifdef _WIN32
	return _chdir(d.c_str()) == 0;
	#else
	return chdir(d.c_str()) == 0;
	#endif
}
std::string ClipboardGetText() {
	InputInit();
	char* r = SDL_GetClipboardText();
	std::string cb_text(r);
	SDL_free(r);
	return cb_text;
}
BOOL ClipboardSetText(const std::string& text) {
	InputInit();
	return SDL_SetClipboardText(text.c_str()) == 0;
}
BOOL ClipboardSetRawText(const std::string& text) {
	#ifdef _WIN32
	if (!OpenClipboard(nullptr))
		return FALSE;
	EmptyClipboard();
	if (text == "") {
		CloseClipboard();
		return TRUE;
	}
	HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, text.size() + 1);
	if (!hMem) {
		CloseClipboard();
		return FALSE;
	}
	char* cbText = (char*)GlobalLock(hMem);
	memcpy(cbText, text.c_str(), text.size());
	cbText[text.size()] = 0;
	GlobalUnlock(hMem);
	SetClipboardData(CF_TEXT, hMem);
	CloseClipboard();
	return TRUE;
	#else
	return FALSE;
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
	return g_command_line;
}
double Round(double n, int p) {
	int P = powf(10, fabs(p));
	if (p > 0)
		return round(n * P) / P;
	else if (p < 0)
		return round(n / P) * P;
	return round(n);
}
bool run(const std::string& filename, const std::string& cmdline, bool wait_for_completion, bool background) {
	#ifdef _WIN32
	PROCESS_INFORMATION info;
	STARTUPINFO si;
	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	si.dwFlags = STARTF_USESHOWWINDOW;
	si.wShowWindow = (background ? SW_HIDE : SW_SHOW);
	char c_cmdline[32768];
	c_cmdline[0] = 0;
	if (cmdline.size() > 0) {
		std::string tmp = "\"";
		tmp += filename;
		tmp += "\" ";
		tmp += cmdline;
		strncpy(c_cmdline, tmp.c_str(), tmp.size());
		c_cmdline[tmp.size()] = 0;
	}
	BOOL r = CreateProcess(filename.c_str(), c_cmdline, NULL, NULL, FALSE, INHERIT_CALLER_PRIORITY, NULL, NULL, &si, &info);
	if (r == FALSE)
		return false;
	if (wait_for_completion) {
		while (WaitForSingleObject(info.hProcess, 0) == WAIT_TIMEOUT)
			wait(5);
	}
	CloseHandle(info.hProcess);
	CloseHandle(info.hThread);
	return true;
	#else
	int status;
	pid_t pid = fork();
	if (pid < 0) return false;
	else if (pid == 0) {
		std::string cmd = filename;
		cmd += " ";
		cmd += cmdline;
		execl("/bin/sh", "/bin/sh", "-c", cmd.c_str(), NULL);
		_exit(EXIT_FAILURE);
	} else {
		if (!wait_for_completion) return true;
		else return waitpid(pid, &status, 0) == pid;
	}
	#endif
}
bool urlopen(const std::string& url) {
	return !SDL_OpenURL(url.c_str());
}
double tinyexpr(const std::string& expr) {
	return te_interp(expr.c_str(), NULL);
}

void next_keyboard_layout() {
	#ifdef _WIN32
	ActivateKeyboardLayout((HKL)HKL_NEXT, 0);
	#endif
}
std::string number_to_words(asINT64 number, bool include_and) {
	if (number < 0) return "negative " + number_to_words(number * -1, include_and);
	std::string output(128, '\0');
	size_t size = bl_number_to_words(number, &output[0], 96, include_and);
	if (size > 96) {
		output.resize(size);
		size = bl_number_to_words(number, &output[0], size, include_and);
	}
	output.resize(size);
	return output;
}
std::string input_box(const std::string& title, const std::string& text, const std::string& default_value) {
	#ifdef _WIN32
	std::wstring titleU, textU, defaultU;
	Poco::UnicodeConverter::convert(title, titleU);
	Poco::UnicodeConverter::convert(text, textU);
	Poco::UnicodeConverter::convert(default_value, defaultU);
	std::wstring r = InputBox(titleU, textU, defaultU);
	if (r == L"\xff") {
		g_LastError = -12;
		return "";
	}
	std::string resultA;
	Poco::UnicodeConverter::convert(r, resultA);
	return resultA;
	#elif defined(__APPLE__)
	std::string r = apple_input_box(title, text, default_value, false, false);
	if (g_WindowHandle) SDL_RaiseWindow(g_WindowHandle);
	if (r == "\xff") {
		g_LastError = -12;
		return "";
	}
	return r;
	#else
	return "";
	#endif
}
bool info_box(const std::string& title, const std::string& text, const std::string& value) {
	#ifdef _WIN32
	std::wstring titleU, textU, valueU;
	Poco::UnicodeConverter::convert(title, titleU);
	Poco::UnicodeConverter::convert(text, textU);
	Poco::UnicodeConverter::convert(value, valueU);
	return InfoBox(titleU, textU, valueU);
	#elif defined(__APPLE__)
	apple_input_box(title, text, value, false, false);
	return true;
	#else
	return false;
	#endif
}
int get_last_error() {
	int e = g_LastError;
	g_LastError = 0;
	return e;
}

double range_convert(double old_value, double old_min, double old_max, double new_min, double new_max) {
	return ((old_value - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min;
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

CScriptArray* get_preferred_locales() {
	asITypeInfo* arrayType = g_ScriptEngine->GetTypeInfoByDecl("array<string>");
	CScriptArray* array = CScriptArray::Create(arrayType);
	SDL_Locale* locales = SDL_GetPreferredLocales();
	if (!locales) return array;
	for (int i = 0; locales[i].language; i++) {
		std::string tmp = locales[i].language;
		if (locales[i].country) tmp += std::string("-") + locales[i].country;
		array->Resize(array->GetSize() + 1);
		((std::string*)(array->At(array->GetSize() - 1)))->assign(tmp);
	}
	SDL_free(locales);
	return array;
}

void RegisterMiscFunctions(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_UI);
	engine->RegisterEnum(_O("message_box_flags"));
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_ERROR"), SDL_MESSAGEBOX_ERROR);
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_WARNING"), SDL_MESSAGEBOX_WARNING);
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_INFORMATION"), SDL_MESSAGEBOX_INFORMATION);
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_BUTTONS_LEFT_TO_RIGHT"), SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT);
	engine->RegisterEnumValue(_O("message_box_flags"), _O("MESSAGE_BOX_BUTTONS_RIGHT_TO_LEFT"), SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT);
	engine->RegisterGlobalFunction(_O("int message_box(const string& in, const string& in, string[]@, uint = 0)"), asFUNCTION(message_box_script), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int alert(const string &in, const string &in, bool = false, uint = 0)"), asFUNCTION(alert), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int question(const string& in, const string& in, bool = false, uint = 0)"), asFUNCTION(question), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_OS);
	engine->RegisterGlobalFunction(_O("bool chdir(const string& in)"), asFUNCTION(ChDir), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string clipboard_get_text()"), asFUNCTION(ClipboardGetText), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool clipboard_set_text(const string& in)"), asFUNCTION(ClipboardSetText), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool clipboard_set_raw_text(const string& in)"), asFUNCTION(ClipboardSetRawText), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_UI);
	engine->RegisterGlobalFunction(_O("string input_box(const string& in, const string& in, const string& in = '', uint64 = 0)"), asFUNCTION(input_box), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool info_box(const string& in, const string& in, const string& in, uint64 = 0)"), asFUNCTION(info_box), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	engine->RegisterGlobalFunction(_O("uint8 character_to_ascii(const string&in)"), asFUNCTION(character_to_ascii), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string ascii_to_character(uint8)"), asFUNCTION(ascii_to_character), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string string_base32_normalize(const string& in)"), asFUNCTION(base32_normalize), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATETIME);
	engine->RegisterGlobalFunction(_O("uint64 get_TIME_STAMP() property"), asFUNCTION(timestamp), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_OS);
	engine->RegisterGlobalFunction(_O("string[]@ get_preferred_locales()"), asFUNCTION(get_preferred_locales), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string get_COMMAND_LINE() property"), asFUNCTION(get_command_line), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool run(const string& in, const string& in, bool, bool)"), asFUNCTION(run), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool urlopen(const string &in)"), asFUNCTION(urlopen), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool is_debugger_present()"), asFUNCTION(debugger_present), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void next_keyboard_layout()"), asFUNCTION(next_keyboard_layout), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int get_last_error()"), asFUNCTION(get_last_error), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterGlobalFunction(_O("double round(double, int)"), asFUNCTION(Round), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("double tinyexpr(const string &in)"), asFUNCTION(tinyexpr), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATA);
	engine->RegisterGlobalFunction(_O("string number_to_words(int64, bool = true)"), asFUNCTION(number_to_words), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint string_distance(const string&in, const string&in, uint=1, uint=1, uint=1)"), asFUNCTION(string_distance), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string float_to_bytes(float)"), asFUNCTION(float_to_bytes), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("float bytes_to_float(const string&in)"), asFUNCTION(bytes_to_float), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string double_to_bytes(double)"), asFUNCTION(double_to_bytes), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("double bytes_to_double(const string&in)"), asFUNCTION(bytes_to_double), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool natural_number_sort(const string&in, const string&in)"), asFUNCTION(natural_number_sort), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int utf8prev(const string&in, int)"), asFUNCTION(utf8prev), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int utf8next(const string&in, int)"), asFUNCTION(utf8next), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("int utf8size(const string&in)"), asFUNCTION(utf8size), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_GENERAL);
	engine->RegisterObjectType(_O("refstring"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("refstring"), asBEHAVE_FACTORY, _O("refstring @s()"), asFUNCTION(new_refstring), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("refstring"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(refstring, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("refstring"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(refstring, Release), asCALL_THISCALL);
	engine->RegisterObjectProperty(_O("refstring"), _O("string str"), asOFFSET(refstring, str));
	engine->RegisterGlobalFunction(_O("uint64 memory_allocate(uint64)"), asFUNCTION(malloc), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 memory_allocate_units(uint64, uint64)"), asFUNCTION(calloc), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 memory_reallocate(uint64, uint64)"), asFUNCTION(realloc), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void memory_free(uint64)"), asFUNCTION(free), asCALL_CDECL);
}
