/* nvgt_phonon.cpp - the nvgt_phonon plugin's entry point and Steam Audio context, see nvgt_phonon.h
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

#include "../../src/nvgt_plugin.h"
#include <mutex>
#include "../../src/sound.h"
#include "nvgt_phonon.h"
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#else
#include <dlfcn.h>
#endif

static IPLAudioSettings g_audio_settings{44100, SOUNDSYSTEM_FRAMESIZE};
static api::IContext* g_context = nullptr;
static api::IHRTF* g_hrtf = nullptr;
static std::mutex g_init_mutex;

audio_engine* phonon_default_engine() { return nvgt_get_default_audio_engine(); }
bool phonon_init() { // Creates the context and default HRTF on first use, as the default audio engine's sample rate is only known once sound is initialized.
	std::lock_guard<std::mutex> l(g_init_mutex);
	if (g_context) return true;
	audio_engine* engine = phonon_default_engine();
	if (!engine) return false;
	g_audio_settings = {(IPLint32)engine->get_sample_rate(), SOUNDSYSTEM_FRAMESIZE};
	IPLContextSettings context_settings{};
	context_settings.version = STEAMAUDIO_VERSION;
	IPLContext context = nullptr;
	if (iplContextCreate(&context_settings, &context) != IPL_STATUS_SUCCESS) return false;
	api::IContext* ctx = reinterpret_cast<api::IContext*>(context);
	IPLHRTFSettings hrtf_settings{};
	hrtf_settings.type = IPL_HRTFTYPE_DEFAULT;
	hrtf_settings.volume = 1.0f;
	if (ctx->createHRTF(&g_audio_settings, &hrtf_settings, &g_hrtf) != IPL_STATUS_SUCCESS) {
		ctx->release();
		return false;
	}
	g_context = ctx;
	return true;
}
api::IContext* phonon_context() { return g_context; }
api::IHRTF* phonon_hrtf() { return g_hrtf; }
const IPLAudioSettings& phonon_audio_settings() { return g_audio_settings; }

static bool steam_audio_is_shared_library() { // Whether Steam Audio was linked as a shared library that must ship with a compiled game, rather than statically.
	#ifdef _WIN32
	return GetModuleHandleA("phonon.dll") != nullptr;
	#else
	for (const char* name : {"libphonon.so", "libphonon.dylib"}) {
		if (void* lib = dlopen(name, RTLD_NOW | RTLD_NOLOAD)) {
			dlclose(lib);
			return true;
		}
	}
	return false;
	#endif
}

static void phonon_shutdown() { // Objects still holding references keep the context alive until they are released.
	std::lock_guard<std::mutex> l(g_init_mutex);
	if (g_hrtf) g_hrtf->release();
	if (g_context) g_context->release();
	g_hrtf = nullptr;
	g_context = nullptr;
}

plugin_main(nvgt_plugin_shared* shared) {
	if (!prepare_plugin(shared)) return false;
	if (steam_audio_is_shared_library()) nvgt_bundle_shared_library("phonon");
	nvgt_register_shutdown_notification(phonon_shutdown);
	RegisterPhononNodes(shared->script_engine);
	RegisterSoundEnvironment(shared->script_engine);
	return true;
}
