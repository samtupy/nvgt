/* srspeech.cpp - code for screen reader speech
 * Thanks to Ethin P for the speech dispatcher support!
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
	#include <UniversalSpeech.h>
#elif defined(__APPLE__)
	#include "apple.h"
#elif !defined(__ANDROID__) && (defined(__linux__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__))
	#define using_speechd
#elif defined(__ANDROID__)
	#include "android.h"
#endif
#include <string>
#include <Poco/AtomicFlag.h>
#include <Poco/SharedLibrary.h>
#include <Poco/UnicodeConverter.h>
#include "srspeech.h"

Poco::AtomicFlag g_SRSpeechLoaded;
Poco::AtomicFlag g_SRSpeechAvailable;

#ifdef using_speechd
	// Define the functions we want to use from speech-dispatcher with some temporary macro replacements that allow the libspeechd header to still be usable while turning the function definitions into pointers. Not perfectly ideal, but still the cleanest I can find at this time.
	#define spd_get_default_address (*spd_get_default_address)
	#define spd_open2 (*spd_open2)
	#define spd_close (*spd_close)
	#define spd_say (*spd_say)
	#define spd_stop (*spd_stop)
	#define spd_cancel (*spd_cancel)
	#include <speech-dispatcher/libspeechd.h>
	#undef spd_get_default_address
	#undef spd_open2
	#undef spd_close
	#undef spd_say
	#undef spd_stop
	#undef spd_cancel
	SPDConnection*  g_SpeechdConn = nullptr;
	Poco::SharedLibrary g_SpeechdLib;
#endif

bool ScreenReaderLoad() {
	#if defined(_WIN32)
	if (g_SRSpeechLoaded) return true;
	speechSetValue(SP_ENABLE_NATIVE_SPEECH, 0);
	g_SRSpeechAvailable.set();
	g_SRSpeechLoaded.set();
	return true;
	#elif defined(__APPLE__) || defined(__ANDROID__)
	g_SRSpeechLoaded.set();
	return true; // Voice over or libraries to access it don't need loading, same with Android accessibility manager.
	#elif defined(using_speechd)
	if (g_SRSpeechLoaded) return true;
	try {
		g_SpeechdLib.load("libspeechd.so");
		*(void**)&spd_get_default_address = g_SpeechdLib.getSymbol("spd_get_default_address");
		*(void**)&spd_open2 = g_SpeechdLib.getSymbol("spd_open2");
		*(void**)&spd_close = g_SpeechdLib.getSymbol("spd_close");
		*(void**)&spd_say = g_SpeechdLib.getSymbol("spd_say");
		*(void**)&spd_stop = g_SpeechdLib.getSymbol("spd_stop");
		*(void**)&spd_cancel = g_SpeechdLib.getSymbol("spd_cancel");
	} catch (Poco::Exception&) {
		g_SRSpeechAvailable.reset();
		return false;
	}
	const auto *addr = spd_get_default_address(nullptr);
	if (!addr) {
		g_SRSpeechAvailable.reset();
		return false;
	}
	g_SpeechdConn = spd_open2("NVGT", nullptr, nullptr, SPD_MODE_THREADED, addr, true, nullptr);
	if (!g_SpeechdConn) {
		g_SRSpeechAvailable.reset();
		return false;
	}
	g_SRSpeechAvailable.set();
	return true;
	#else
	return false;
	#endif
}

void ScreenReaderUnload() {
	if (!g_SRSpeechLoaded) return;
	#if defined(_WIN32)
	g_SRSpeechLoaded.reset();
	#elif defined(__APPLE__)
	voice_over_speech_shutdown(); // Really just stops a hacky thread intended to get speech event queuing working.
	#elif defined(using_speechd)
	spd_close(g_SpeechdConn);
	g_SpeechdConn = nullptr;
	g_SpeechdLib.unload();
	#endif
}

std::string ScreenReaderDetect() {
	#if defined(_WIN32)
	if (!ScreenReaderLoad()) return "";
	int engine = speechGetValue(SP_ENGINE);
	if (engine < 0) return "";
	const std::wstring srname = speechGetString(SP_ENGINE + engine);
	std::string result;
	Poco::UnicodeConverter::convert(srname, result);
	return result;
	#elif defined(__APPLE__)
	return voice_over_is_running() ? "VoiceOver" : "";
	#elif defined(using_speechd)
	return g_SpeechdConn != nullptr ? "Speech dispatcher" : "";
	#elif defined(__ANDROID__)
	return android_screen_reader_detect();
	#else
	return "";
	#endif
}

bool ScreenReaderHasSpeech() {
	#if defined(_WIN32)
	if (!ScreenReaderLoad()) return false;
	return speechGetValue(SP_ENGINE) > -1;
	#elif defined(__APPLE__)
	return voice_over_is_running();
	#elif defined(using_speechd)
	return g_SpeechdConn != nullptr;
	#elif defined(__ANDROID__)
	return android_is_screen_reader_active();
	#else
	return false;
	#endif
}

bool ScreenReaderHasBraille() {
	#if defined(_WIN32)
	if (!ScreenReaderLoad()) return false;
	return speechGetValue(SP_ENGINE) > -1;
	#elif defined(__APPLE__)
	return voice_over_is_running();
	#else
	return false;
	#endif
}

bool ScreenReaderIsSpeaking() {
	#if defined(_WIN32)
	if (!ScreenReaderLoad()) return false;
	return speechGetValue(SP_BUSY) != 0;
	#else
	return false;
	#endif
}

bool ScreenReaderOutput(const std::string& text, bool interrupt) {
	if (!ScreenReaderLoad()) return false;
	#if defined(_WIN32)
	std::wstring textW;
	Poco::UnicodeConverter::convert(text, textW);
	return speechSay(textW.c_str(), interrupt) != 0 && brailleDisplay(textW.c_str()) != 0;
	#elif defined(__APPLE__)
	return voice_over_speak(text, interrupt);
	#elif defined(using_speechd)
	if (interrupt) {
		spd_stop(g_SpeechdConn);
		spd_cancel(g_SpeechdConn);
	}
	return spd_say(g_SpeechdConn, interrupt ? SPD_IMPORTANT : SPD_TEXT, text.c_str());
	#elif defined(__ANDROID__)
	return android_screen_reader_speak(text, interrupt);
	#else
	return false;
	#endif
}

bool ScreenReaderSpeak(const std::string& text, bool interrupt) {
	if (!ScreenReaderLoad()) return false;
	#if defined(_WIN32)
	std::wstring textW;
	Poco::UnicodeConverter::convert(text, textW);
	return speechSay(textW.c_str(), interrupt) != 0;
	#elif defined(__APPLE__)
	return voice_over_speak(text, interrupt);
	#elif defined(using_speechd)
	if (interrupt) {
		spd_stop(g_SpeechdConn);
		spd_cancel(g_SpeechdConn);
	}
	return spd_say(g_SpeechdConn, interrupt ? SPD_IMPORTANT : SPD_TEXT, text.c_str());
	#elif defined(__ANDROID__)
	return android_screen_reader_speak(text, interrupt);
	#else
	return false;
	#endif
}

bool ScreenReaderBraille(const std::string& text) {
	if (!ScreenReaderLoad()) return false;
	#if defined(_WIN32)
	std::wstring textW(text.begin(), text.end());
	return brailleDisplay(textW.c_str()) != 0;
	#else
	return false;
	#endif
}

bool ScreenReaderSilence() {
	if (!ScreenReaderLoad()) return false;
	#if defined(_WIN32)
	return speechStop();
	#elif defined(__APPLE__)
	return voice_over_speak("", true);
	#elif defined(using_speechd)
	spd_cancel(g_SpeechdConn);
	spd_stop(g_SpeechdConn);
	return true;
	#elif defined(__ANDROID__)
	return android_screen_reader_silence();
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
	engine->RegisterGlobalFunction("bool screen_reader_output(const string &in text, bool interrupt = true)", asFUNCTION(ScreenReaderOutput), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_speak(const string &in text, bool interrupt = true)", asFUNCTION(ScreenReaderSpeak), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_braille(const string &in text)", asFUNCTION(ScreenReaderBraille), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool screen_reader_silence()", asFUNCTION(ScreenReaderSilence), asCALL_CDECL);
}
