/* screen_reader.cpp - speech and braille output through screen readers using Prism
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2026 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#ifdef __APPLE__
#include <TargetConditionals.h>
#endif
#if defined(_WIN32) || (defined(__APPLE__) && !TARGET_OS_IOS) || (defined(__linux__) && !defined(__ANDROID__))
#include <atomic>
#include <string>
#include <Poco/Mutex.h>
#include <prism.h>
#include "tts.h"

static PrismContext* g_prism = nullptr;
static PrismBackend* g_screen_reader = nullptr;
static std::atomic<bool> g_screen_reader_stale{true};
static Poco::FastMutex g_screen_reader_mutex;

// Screen reader output should never silently fall back to a plain text to speech engine, so these backends are skipped.
static bool is_speech_engine(PrismBackendId id) {
	return id == PRISM_BACKEND_SAPI || id == PRISM_BACKEND_ONE_CORE || id == PRISM_BACKEND_AV_SPEECH || id == PRISM_BACKEND_WEB_SPEECH || id == PRISM_BACKEND_ANDROID_TTS;
}

static void PRISM_CALL screen_reader_availability_changed(void* userdata, PrismBackendId backend, const char* name, bool available) {
	g_screen_reader_stale = true;
}

static PrismBackend* select_screen_reader() {
	for (size_t i = 0; i < prism_registry_count(g_prism); i++) {
		PrismBackendId id = prism_registry_id_at(g_prism, i);
		if (is_speech_engine(id)) continue;
		PrismBackend* backend = prism_registry_create(g_prism, id);
		if (!backend) continue;
		PrismError result = prism_backend_initialize(backend);
		if (result == PRISM_OK || result == PRISM_ERROR_ALREADY_INITIALIZED) return backend;
		prism_backend_free(backend);
	}
	return nullptr;
}

static PrismBackend* get_screen_reader() {
	if (!g_prism) {
		PrismConfig config = prism_config_init();
		config.availability_callback = screen_reader_availability_changed;
		g_prism = prism_init(&config);
		if (!g_prism) return nullptr;
	}
	if (g_screen_reader_stale.exchange(false)) {
		if (g_screen_reader) prism_backend_free(g_screen_reader);
		g_screen_reader = select_screen_reader();
	}
	return g_screen_reader;
}

static bool screen_reader_supports(uint64_t feature) {
	PrismBackend* backend = get_screen_reader();
	return backend && (prism_backend_get_features(backend) & feature);
}

static bool screen_reader_succeeded(PrismError result) {
	if (result != PRISM_OK) g_screen_reader_stale = true;
	return result == PRISM_OK;
}

bool screen_reader_load() {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	return get_screen_reader() != nullptr;
}
void screen_reader_unload() {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	if (g_screen_reader) prism_backend_free(g_screen_reader);
	g_screen_reader = nullptr;
	if (g_prism) prism_shutdown(g_prism);
	g_prism = nullptr;
	g_screen_reader_stale = true;
}
std::string screen_reader_detect() {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	PrismBackend* backend = get_screen_reader();
	if (!backend) return "";
	const char* name = prism_backend_name(backend);
	return name ? name : "";
}
bool screen_reader_has_speech() {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	return screen_reader_supports(PRISM_BACKEND_SUPPORTS_SPEAK);
}
bool screen_reader_has_braille() {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	return screen_reader_supports(PRISM_BACKEND_SUPPORTS_BRAILLE);
}
bool screen_reader_is_speaking() {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	if (!screen_reader_supports(PRISM_BACKEND_SUPPORTS_IS_SPEAKING)) return false;
	bool speaking = false;
	return prism_backend_is_speaking(g_screen_reader, &speaking) == PRISM_OK && speaking;
}
bool screen_reader_output(const std::string& text, bool interrupt) {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	PrismBackend* backend = get_screen_reader();
	return backend && screen_reader_succeeded(prism_backend_output(backend, text.c_str(), interrupt));
}
bool screen_reader_speak(const std::string& text, bool interrupt) {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	PrismBackend* backend = get_screen_reader();
	return backend && screen_reader_succeeded(prism_backend_speak(backend, text.c_str(), interrupt));
}
bool screen_reader_braille(const std::string& text) {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	if (!screen_reader_supports(PRISM_BACKEND_SUPPORTS_BRAILLE)) return false;
	return screen_reader_succeeded(prism_backend_braille(g_screen_reader, text.c_str()));
}
bool screen_reader_silence() {
	Poco::FastMutex::ScopedLock lock(g_screen_reader_mutex);
	if (!screen_reader_supports(PRISM_BACKEND_SUPPORTS_STOP)) return false;
	return screen_reader_succeeded(prism_backend_stop(g_screen_reader));
}

#endif
