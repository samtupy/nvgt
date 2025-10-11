/* linux.cpp - module containing functions only applicable to Linux and Unix platforms
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#if !defined(__ANDROID__) && (defined(__linux__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__))
#include "linux.h"
#include "tts.h"
#include <memory>
#include <Poco/SharedLibrary.h>
#include <stdexcept>
using namespace std;

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

static Poco::SharedLibrary g_speechd_lib;
static bool g_speechd_lib_loaded = false;

static bool load_speechd_library() {
	if (g_speechd_lib_loaded) return true;
	try {
		g_speechd_lib.load("libspeechd.so");
		*(void**)&spd_get_default_address = g_speechd_lib.getSymbol("spd_get_default_address");
		*(void**)&spd_open2 = g_speechd_lib.getSymbol("spd_open2");
		*(void**)&spd_close = g_speechd_lib.getSymbol("spd_close");
		*(void**)&spd_say = g_speechd_lib.getSymbol("spd_say");
		*(void**)&spd_stop = g_speechd_lib.getSymbol("spd_stop");
		*(void**)&spd_cancel = g_speechd_lib.getSymbol("spd_cancel");
		g_speechd_lib_loaded = true;
		return true;
	} catch (Poco::Exception&) {
		return false;
	}
}

speechd_engine::speechd_engine() : tts_engine_impl("Speech Dispatcher"), connection(nullptr), loaded(false) {
	if (!load_speechd_library()) return;
	const auto *addr = spd_get_default_address(nullptr);
	if (!addr) return;
	connection = spd_open2("NVGT", nullptr, nullptr, SPD_MODE_THREADED, addr, true, nullptr);
	if (!connection) return;
	loaded = true;
}

speechd_engine::~speechd_engine() {
	if (connection) {
		spd_close((SPDConnection*)connection);
		connection = nullptr;
	}
}

bool speechd_engine::is_available() { return loaded && connection != nullptr; }

bool speechd_engine::speak(const std::string &text, bool interrupt, bool blocking) {
	if (!is_available() || text.empty()) return false;
	if (interrupt) {
		spd_stop((SPDConnection*)connection);
		spd_cancel((SPDConnection*)connection);
	}
	return spd_say((SPDConnection*)connection, interrupt ? SPD_IMPORTANT : SPD_TEXT, text.c_str()) >= 0;
}

bool speechd_engine::is_speaking() { return false; }

bool speechd_engine::stop() {
	if (!is_available()) return false;
	spd_cancel((SPDConnection*)connection);
	spd_stop((SPDConnection*)connection);
	return true;
}

bool screen_reader_is_speaking() { return false; }

void register_native_tts() { tts_engine_register("speechd", []() -> shared_ptr<tts_engine> { return make_shared<speechd_engine>(); }); }

static tts_voice* g_screen_reader_voice = nullptr;

bool screen_reader_load() {
	if (g_screen_reader_voice) return true;
	g_screen_reader_voice = new tts_voice("speechd");
	return g_screen_reader_voice != nullptr && g_screen_reader_voice->get_voice_count() > 0;
}

void screen_reader_unload() {
	if (g_screen_reader_voice) {
		g_screen_reader_voice->Release();
		g_screen_reader_voice = nullptr;
	}
}

std::string screen_reader_detect() {
	if (!screen_reader_load()) return "";
	return g_screen_reader_voice->get_voice_count() > 0 ? "Speech Dispatcher" : "";
}

bool screen_reader_has_speech() {
	if (!screen_reader_load()) return false;
	return g_screen_reader_voice->get_voice_count() > 0;
}

bool screen_reader_has_braille() { return false; }

bool screen_reader_output(const std::string& text, bool interrupt) {
	if (!screen_reader_load()) return false;
	return g_screen_reader_voice->speak(text, interrupt);
}

bool screen_reader_speak(const std::string& text, bool interrupt) {
	if (!screen_reader_load()) return false;
	return g_screen_reader_voice->speak(text, interrupt);
}

bool screen_reader_braille(const std::string& text) { return false; }

bool screen_reader_silence() {
	if (!screen_reader_load()) return false;
	return g_screen_reader_voice->stop();
}

#endif
