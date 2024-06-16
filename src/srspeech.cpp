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
#elif defined(__linux__) || defined(__unix__) || \
      defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__OpenBSD__) || defined(__DragonFly__)
    #include <speech-dispatcher/libspeechd.h>
#else
    #error Unknown platform detected
#endif
#include <string>
#include <Poco/AtomicFlag.h>
#include "srspeech.h"

Poco::AtomicFlag g_SRSpeechLoaded;
Poco::AtomicFlag g_SRSpeechAvailable;

#if defined(__linux__) || defined(__unix__) || \
    defined(__FreeBSD__) || defined(__NetBSD__) || \
    defined(__OpenBSD__) || defined(__DragonFly__)
    SPDConnection *conn = nullptr;
#endif

bool ScreenReaderLoad() {
#if defined(_WIN32)
    g_SRSpeechAvailable.set();
    if (!g_SRSpeechAvailable) return false;
    if (g_SRSpeechLoaded) return true;
    __try {
        Tolk_Load();
    } __except (1) {
        g_SRSpeechAvailable.reset();
        return false;
    }
    g_SRSpeechLoaded.set();
    return true;
#elif defined(__APPLE__)
    g_SRSpeechLoaded.set();
    return true; // Voice over or libraries to access it don't need loading.
#elif defined(__linux__) || defined(__unix__) || \
      defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__OpenBSD__) || defined(__DragonFly__)
    const char* addr = spd_get_default_address(nullptr);
    if (!addr) {
        g_SRSpeechAvailable.reset();
        return false;
    }
    conn = spd_open2("NVGT", nullptr, nullptr, SPD_MODE_THREADED, addr, true, nullptr);
    if (!conn) {
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
#if defined(_WIN32)
    if (!g_SRSpeechLoaded) return;
    Tolk_Unload();
    g_SRSpeechLoaded.reset();
#elif defined(__APPLE__)
    voice_over_speech_shutdown(); // Really just stops a hacky thread intended to get speech event queuing working.
#elif defined(__linux__) || defined(__unix__) || \
      defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__OpenBSD__) || defined(__DragonFly__)
    spd_close(conn);
    conn = nullptr;
#endif
}

std::string ScreenReaderDetect() {
#if defined(_WIN32)
    if (!ScreenReaderLoad()) return "";
    const wchar_t* srname = Tolk_DetectScreenReader();
    if (srname == NULL) return "";
    char srnameA[64];
    memset(srnameA, 0, sizeof(srnameA));
    WideCharToMultiByte(CP_UTF8, 0, srname, wcslen(srname), srnameA, sizeof(srnameA), NULL, NULL);
    return std::string(srnameA);
#elif defined(__APPLE__)
    return voice_over_is_running() ? "VoiceOver" : "";
#elif defined(__linux__) || defined(__unix__) || \
      defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__OpenBSD__) || defined(__DragonFly__)
    return conn != nullptr ? "Speech dispatcher" : "";
#else
    return "";
#endif
}

bool ScreenReaderHasSpeech() {
#if defined(_WIN32)
    if (!ScreenReaderLoad()) return false;
    return Tolk_HasSpeech();
#elif defined(__APPLE__)
    return voice_over_is_running();
#elif defined(__linux__) || defined(__unix__) || \
      defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__OpenBSD__) || defined(__DragonFly__)
    return conn != nullptr && spd_fd(conn) > 0;
#else
    return false;
#endif
}

bool ScreenReaderHasBraille() {
#if defined(_WIN32)
    if (!ScreenReaderLoad()) return false;
    return Tolk_HasBraille();
#elif defined(__APPLE__)
    return voice_over_is_running();
#else
    return false;
#endif
}

bool ScreenReaderIsSpeaking() {
#if defined(_WIN32)
    if (!ScreenReaderLoad()) return false;
    return Tolk_IsSpeaking();
#else
    return false;
#endif
}

bool ScreenReaderOutput(std::string& text, bool interrupt) {
#if defined(_WIN32)
    if (!ScreenReaderLoad()) return false;
    std::wstring textW(text.begin(), text.end());
    return Tolk_Output(textW.c_str(), interrupt);
#elif defined(__APPLE__)
    return voice_over_speak(text, interrupt);
#elif defined(__linux__) || defined(__unix__) || \
      defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__OpenBSD__) || defined(__DragonFly__)
    if (interrupt) {
        if (!spd_stop(conn)) return false;
        if (!spd_cancel(conn)) return false;
    }
    return spd_say(conn, SPD_TEXT, text.c_str());
#else
    return false;
#endif
}

bool ScreenReaderSpeak(std::string& text, bool interrupt) {
#if defined(_WIN32)
    if (!ScreenReaderLoad()) return false;
    std::wstring textW(text.begin(), text.end());
    return Tolk_Speak(textW.c_str(), interrupt);
#elif defined(__APPLE__)
    return voice_over_speak(text, interrupt);
#elif defined(__linux__) || defined(__unix__) || \
      defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__OpenBSD__) || defined(__DragonFly__)
    if (interrupt) {
        if (!spd_stop(conn)) return false;
        if (!spd_cancel(conn)) return false;
    }
    return spd_say(conn, SPD_TEXT, text.c_str());
#else
    return false;
#endif
}

bool ScreenReaderBraille(std::string& text) {
#if defined(_WIN32)
    if (!ScreenReaderLoad()) return false;
    std::wstring textW(text.begin(), text.end());
    return Tolk_Braille(textW.c_str());
#else
    return false;
#endif
}

bool ScreenReaderSilence() {
#if defined(_WIN32)
    if (!ScreenReaderLoad()) return false;
    return Tolk_Silence();
#elif defined(__APPLE__)
    return voice_over_speak("", true);
#elif defined(__linux__) || defined(__unix__) || \
      defined(__FreeBSD__) || defined(__NetBSD__) || \
      defined(__OpenBSD__) || defined(__DragonFly__)
    if (!spd_stop(conn)) return false;
    if (!spd_cancel(conn)) return false;
    return true;
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
