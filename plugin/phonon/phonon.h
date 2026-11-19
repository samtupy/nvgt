/* phonon.h - shared declarations of the nvgt_phonon plugin
 * nvgt_phonon provides Steam Audio to NVGT: its HRTF panner and attenuator, phonon_binaural_node and sound_environment, which simulates occlusion, transmission, reflections and pathing through a game's world. It creates its own Steam Audio context and uses it only through the object interfaces of phonon_interfaces.h, and uses NVGT's audio only through the plugin API and the virtual methods of NVGT's audio objects, so that it works whether it is loaded as a shared library or linked statically.
 * Every compilation unit of the plugin must include nvgt_plugin.h (with NVGT_PLUGIN_INCLUDE defined) before this header.
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

#pragma once
#define STEAMAUDIO_SKIP_API_FUNCTIONS // Steam Audio's own C API is linked, phonon_interfaces.h must not define it again.
#include <phonon_interfaces.h>

class asIScriptEngine;
class audio_engine;

// Holds a reference to a Steam Audio object.
template <class T> class ipl_ref {
	T* p = nullptr;
public:
	ipl_ref() = default;
	ipl_ref(const ipl_ref&) = delete;
	ipl_ref& operator=(const ipl_ref&) = delete;
	~ipl_ref() { reset(); }
	T* get() const { return p; }
	T* operator->() const { return p; }
	explicit operator bool() const { return p != nullptr; }
	T** put() { reset(); return &p; } // For create functions that write a new reference.
	void reset(T* retained = nullptr) {
		if (p) p->release();
		p = retained;
	}
};
// An IPLAudioBuffer that frees itself.
struct ipl_buffer {
	api::IContext* context = nullptr;
	IPLAudioBuffer b{};
	~ipl_buffer() { free(); }
	bool allocate(api::IContext* ctx, int channels, int samples) {
		if (b.data && b.numChannels == channels && b.numSamples == samples) return true;
		free();
		context = ctx;
		return context->allocateAudioBuffer(channels, samples, &b) == IPL_STATUS_SUCCESS;
	}
	void free() {
		if (b.data) context->freeAudioBuffer(&b);
		b = {};
	}
	void clear() { for (int i = 0; i < b.numChannels; i++) for (int j = 0; j < b.numSamples; j++) b.data[i][j] = 0.0f; }
};
inline IPLSpeakerLayout speaker_layout_for_channels(int channels) {
	IPLSpeakerLayout layout{};
	layout.type = channels == 1 ? IPL_SPEAKERLAYOUTTYPE_MONO : channels == 4 ? IPL_SPEAKERLAYOUTTYPE_QUADRAPHONIC : channels == 6 ? IPL_SPEAKERLAYOUTTYPE_SURROUND_5_1 : channels == 8 ? IPL_SPEAKERLAYOUTTYPE_SURROUND_7_1 : IPL_SPEAKERLAYOUTTYPE_STEREO;
	return layout;
}

// The plugin's Steam Audio context and default HRTF, created when the plugin is loaded for the default audio engine's sample rate.
bool phonon_init();
api::IContext* phonon_context();
api::IHRTF* phonon_hrtf();
const IPLAudioSettings& phonon_audio_settings();
audio_engine* phonon_default_engine();

extern int g_phonon_hrtf_panner, g_phonon_attenuator; // The ids scripts select the phonon spatializer components by.
void RegisterPhononNodes(asIScriptEngine* engine);
void RegisterSoundEnvironment(asIScriptEngine* engine);
