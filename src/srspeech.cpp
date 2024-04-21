/* srspeech.cpp - code for screen reader speech
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

#ifdef _WIN32
	#include <windows.h>
	#include <Tolk.h>
#elif defined(__APPLE__)
	#include "apple.h"
#endif
#include <string>
#include "srspeech.h"

bool g_SRSpeechLoaded = false;
bool g_SRSpeechAvailable = true;
bool ScreenReaderLoad() {
	#ifdef _WIN32
	if (!g_SRSpeechAvailable) return false;
	if (g_SRSpeechLoaded) return true;
	__try {
		Tolk_Load();
	} __except (1) {
		g_SRSpeechAvailable = false;
		return false;
	}
	g_SRSpeechLoaded = true;
	return true;
	#elif defined(__APPLE__)
	return true; // Voice over or libraries to access it don't need loading.
	#else
	return false;
	#endif
}
void ScreenReaderUnload() {
	#ifdef _WIN32
	if (!g_SRSpeechLoaded) return;
	Tolk_Unload();
	g_SRSpeechLoaded = false;
	#elif defined(__APPLE__)
	voice_over_speech_shutdown(); // Really just stops a hacky thread intended to get speech event queuing working.
	#endif
}
std::string ScreenReaderDetect() {
	#ifdef _WIN32
	if (!ScreenReaderLoad()) return "";
	const wchar_t* srname = Tolk_DetectScreenReader();
	if (srname == NULL) return "";
	char srnameA[64];
	memset(srnameA, 0, 64);
	WideCharToMultiByte(CP_UTF8, 0, srname, wcslen(srname), srnameA, 64, NULL, NULL);
	return std::string(srnameA);
	#elif defined(__APPLE__)
	return voice_over_is_running() ? "VoiceOver" : ""; // If we ever get a library on macos that can speak to multiple screen readers, we can talk about improving this.
	#else
	return "";
	#endif
}
bool ScreenReaderHasSpeech() {
	#ifdef _WIN32
	if (!ScreenReaderLoad()) return false;
	return Tolk_HasSpeech();
	#elif defined(__APPLE__)
	return voice_over_is_running();
	#else
	return false;
	#endif
}
bool ScreenReaderHasBraille() {
	#ifdef _WIN32
	if (!ScreenReaderLoad()) return false;
	return Tolk_HasBraille();
	#elif defined(__APPLE__)
	return voice_over_is_running();
	#else
	return false;
	#endif
}
bool ScreenReaderIsSpeaking() {
	#ifdef _WIN32
	if (!ScreenReaderLoad()) return false;
	return Tolk_IsSpeaking();
	#else
	return false;
	#endif
}
bool ScreenReaderOutput(std::string& text, bool interrupt) {
	#ifdef _WIN32
	if (!ScreenReaderLoad()) return false;
	wchar_t* textW = (wchar_t*)malloc((text.size() * 3) + 2);
	MultiByteToWideChar(CP_UTF8, 0, text.c_str(), text.size() + 1, textW, text.size() + 1);
	bool r = Tolk_Output(textW, interrupt);
	free(textW);
	return r;
	#elif defined(__APPLE__)
	return voice_over_speak(text, interrupt);
	#else
	return false;
	#endif
}
bool ScreenReaderSpeak(std::string& text, bool interrupt) {
	#ifdef _WIN32
	if (!ScreenReaderLoad()) return false;
	wchar_t* textW = (wchar_t*)malloc((text.size() * 3) + 2);
	MultiByteToWideChar(CP_UTF8, 0, text.c_str(), text.size() + 1, textW, text.size() + 1);
	bool r = Tolk_Speak(textW, interrupt);
	free(textW);
	return r;
	#elif defined(__APPLE__)
	return voice_over_speak(text, interrupt);
	#else
	return false;
	#endif
}
bool ScreenReaderBraille(std::string& text) {
	#ifdef _WIN32
	if (!ScreenReaderLoad()) return false;
	wchar_t* textW = (wchar_t*)malloc((text.size() * 3) + 2);
	MultiByteToWideChar(CP_UTF8, 0, text.c_str(), text.size() + 1, textW, text.size() + 1);
	bool r = Tolk_Braille(textW);
	free(textW);
	return r;
	#else
	return false;
	#endif
}
bool ScreenReaderSilence() {
	#ifdef _WIN32
	if (!ScreenReaderLoad()) return false;
	return Tolk_Silence();
	#elif defined(__APPLE__)
	return voice_over_speak("", true);
	#else
	return false;
	#endif
}
void RegisterScreenReaderSpeech(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction("bool get_SCREEN_READER_AVAILABLE() property", asFUNCTION(ScreenReaderLoad), asCALL_CDECL);
	engine->RegisterGlobalFunction("string screen_reader_detect()", asFUNCTION(ScreenReaderDetect), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_has_speech()", asFUNCTION(ScreenReaderHasSpeech), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_has_braille()", asFUNCTION(ScreenReaderHasBraille), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_is_speaking()", asFUNCTION(ScreenReaderIsSpeaking), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_output(const string &in, bool)", asFUNCTION(ScreenReaderOutput), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_speak(const string &in, bool)", asFUNCTION(ScreenReaderSpeak), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_braille(const string &in)", asFUNCTION(ScreenReaderBraille), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_silence()", asFUNCTION(ScreenReaderSilence), asCALL_CDECL);
}
