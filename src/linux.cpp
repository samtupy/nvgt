/* linux.cpp - module containing functions only applicable to Linux and Unix platforms
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

#if !defined(__ANDROID__) && (defined(__linux__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__))
#include "linux.h"
#include "tts.h"
#include <memory>
#include <mutex>
#include <vector>
#include <Poco/SharedLibrary.h>
#include <stdexcept>
#include <sdbus-c++/sdbus-c++.h>
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

// Experimental SUPPORT for Orca DBus service. See documentation at: https://gitlab.gnome.org/GNOME/orca/-/blob/main/docs/remote-controller.md
static std::mutex g_orca_mutex;
static std::unique_ptr<sdbus::IConnection> g_orca_connection = nullptr;
static std::unique_ptr<sdbus::IProxy> g_orca_service_proxy = nullptr;
static std::unique_ptr<sdbus::IProxy> g_orca_speech_proxy = nullptr;
static bool g_orca_initialized = false;

static bool initialize_orca_dbus() {
	std::lock_guard<std::mutex> lock(g_orca_mutex);
	if (g_orca_initialized){
		return g_orca_connection && g_orca_service_proxy && g_orca_speech_proxy;
	}
	g_orca_connection.reset();
	g_orca_service_proxy.reset();
	g_orca_speech_proxy.reset();

	try {
		g_orca_connection = sdbus::createSessionBusConnection();
		if (!g_orca_connection) {
			return false;
		}
		g_orca_service_proxy = sdbus::createProxy(
			*g_orca_connection,
			sdbus::ServiceName{"org.gnome.Orca.Service"},
			sdbus::ObjectPath{"/org/gnome/Orca/Service"}
		);
		if (!g_orca_service_proxy) {
			return false;
		}
		// Orca 49: /org/gnome/Orca/Service/SpeechAndVerbosityManager
		// Orca 50: /org/gnome/Orca/Service/SpeechManager
		static const std::vector<sdbus::ObjectPath> speech_paths = {
			sdbus::ObjectPath{"/org/gnome/Orca/Service/SpeechManager"},
			sdbus::ObjectPath{"/org/gnome/Orca/Service/SpeechAndVerbosityManager"}
		};

		for (const auto& path : speech_paths) {
			try {
				auto proxy = sdbus::createProxy(
					*g_orca_connection,
					sdbus::ServiceName{"org.gnome.Orca.Service"},
					path
				);
				if (!proxy) continue;
				auto method = proxy->createMethodCall(
					sdbus::InterfaceName{"org.gnome.Orca.Module"},
					sdbus::MethodName{"ExecuteCommand"}
				);
				method << std::string("InterruptSpeech");
				method << false;
				proxy->callMethod(method);
				g_orca_speech_proxy = std::move(proxy);
				g_orca_initialized = true;
				return true;
			} catch (...) {
				continue;
			}
		}
		g_orca_speech_proxy.reset();
		g_orca_service_proxy.reset();
		g_orca_connection.reset();
		return false;
	} catch (...) {
		g_orca_speech_proxy.reset();
		g_orca_service_proxy.reset();
		g_orca_connection.reset();
		return false;
	}
}

bool orca_is_available(){
	if (!g_orca_initialized) {
		return initialize_orca_dbus();
	}
	std::lock_guard<std::mutex> lock(g_orca_mutex);
	if (!g_orca_connection || !g_orca_service_proxy || !g_orca_speech_proxy) return false;

	try {
		auto method = g_orca_service_proxy->createMethodCall(
			sdbus::InterfaceName{"org.gnome.Orca.Service"},
			sdbus::MethodName{"GetVersion"}
		);
		auto reply = g_orca_service_proxy->callMethod(method);
		return true;
	} catch (...) {
		g_orca_speech_proxy.reset();
		g_orca_service_proxy.reset();
		g_orca_connection.reset();
		g_orca_initialized = false;
		return false;
	}
}

static bool orca_silence_nolock() {
	if (!g_orca_speech_proxy) return false;
	try {
		auto method = g_orca_speech_proxy->createMethodCall(
			sdbus::InterfaceName{"org.gnome.Orca.Module"},
			sdbus::MethodName{"ExecuteCommand"}
		);
		method << std::string("InterruptSpeech");
		method << false;
		auto reply = g_orca_speech_proxy->callMethod(method);
		bool success;
		reply >> success;
		return success;
	} catch (...) {
		g_orca_speech_proxy.reset();
		g_orca_service_proxy.reset();
		g_orca_connection.reset();
		g_orca_initialized = false;
		return false;
	}
}

bool orca_silence() {
	if (!orca_is_available()) return false;
	std::lock_guard<std::mutex> lock(g_orca_mutex);
	if (orca_silence_nolock()) return true;
	g_orca_initialized = false;
	if (!initialize_orca_dbus()) return false;
	return orca_silence_nolock();
}

bool orca_present_message(const std::string& message, bool interrupt) {
	if (!orca_is_available() || message.empty()) return false;
	std::lock_guard<std::mutex> lock(g_orca_mutex);
	if (interrupt) {
		orca_silence_nolock();
	}

	if (!g_orca_service_proxy) return false;

	try {
		auto method = g_orca_service_proxy->createMethodCall(
			sdbus::InterfaceName{"org.gnome.Orca.Service"},
			sdbus::MethodName{"PresentMessage"}
		);
		method << message;
		auto reply = g_orca_service_proxy->callMethod(method);
		bool success;
		reply >> success;
		return success;
	} catch (...) {
		g_orca_speech_proxy.reset();
		g_orca_service_proxy.reset();
		g_orca_connection.reset();
		g_orca_initialized = false;
		return false;
	}
}

static Poco::SharedLibrary g_speechd_lib;
static bool g_speechd_lib_loaded = false;

static bool load_speechd_library() {
	if (g_speechd_lib_loaded) return true;
	try {
		try {
			g_speechd_lib.load("libspeechd.so.2");
		} catch (Poco::Exception&) {
			g_speechd_lib.load("libspeechd.so");
		}
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

bool speechd_engine::is_available() {
	return loaded && connection != nullptr;
}

bool speechd_engine::speak(const std::string &text, bool interrupt, bool blocking) {
	if (!is_available() || text.empty()) return false;
	if (interrupt) {
		spd_stop((SPDConnection*)connection);
		spd_cancel((SPDConnection*)connection);
	}
	return spd_say((SPDConnection*)connection, interrupt ? SPD_IMPORTANT : SPD_MESSAGE, text.c_str()) >= 0;
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

void screen_reader_unload() {
	std::lock_guard<std::mutex> lock(g_orca_mutex);
	g_orca_speech_proxy.reset();
	g_orca_service_proxy.reset();
	g_orca_connection.reset();
	g_orca_initialized = false;
}

bool screen_reader_load() {
	return initialize_orca_dbus() && orca_is_available();
}

std::string screen_reader_detect() {
	if(orca_is_available()) return "Orca";
	return "";
}

bool screen_reader_has_speech() {
	return orca_is_available();
}

bool screen_reader_has_braille() { return false; }

bool screen_reader_output(const std::string& text, bool interrupt) {
	return orca_present_message(text, interrupt);
}

bool screen_reader_speak(const std::string& text, bool interrupt) {
	return orca_present_message(text, interrupt);
}

bool screen_reader_braille(const std::string& text){ return false; }

bool screen_reader_silence() {
	return orca_silence();
}
#endif
