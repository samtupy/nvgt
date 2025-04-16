/* sound_nodes.cpp - audio nodes implementation
 * This contains code for hooking all effects and other nodes up to miniaudio, from hrtf to reverb to filters to tone synthesis and more.
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

#include <exception>
#include <memory>
#include "sound_nodes.h"

using namespace std;

static IPLAudioSettings g_phonon_audio_settings {44100, SOUNDSYSTEM_FRAMESIZE}; // We will update samplerate later in phonon_init.
static IPLContext g_phonon_context = nullptr;
static IPLHRTF g_phonon_hrtf = nullptr;
atomic<bool> g_hrtf_enabled = false;

bool phonon_init() {
	if (g_phonon_context) return true;
	if (!init_sound()) return false;
	g_phonon_audio_settings = {g_audio_engine->get_sample_rate(), SOUNDSYSTEM_FRAMESIZE};
	IPLContextSettings phonon_context_settings{};
	phonon_context_settings.version = STEAMAUDIO_VERSION;
	if (iplContextCreate(&phonon_context_settings, &g_phonon_context) != IPL_STATUS_SUCCESS) return false;
	IPLHRTFSettings phonon_hrtf_settings{};
	phonon_hrtf_settings.type = IPL_HRTFTYPE_DEFAULT;
	phonon_hrtf_settings.volume = 1.0;
	if (iplHRTFCreate(g_phonon_context, &g_phonon_audio_settings, &phonon_hrtf_settings, &g_phonon_hrtf) != IPL_STATUS_SUCCESS) {
		iplContextRelease(&g_phonon_context);
		g_phonon_context = nullptr;
		return false;
	}
	return true;
}

bool set_global_hrtf(bool enabled) {
	if (!enabled && !g_hrtf_enabled || enabled && g_hrtf_enabled) return true;
	if (!phonon_init()) return false;
	g_hrtf_enabled = enabled;
	return true;
}
bool get_global_hrtf() { return g_hrtf_enabled; }

class phonon_binaural_node_impl : public audio_node_impl, public virtual phonon_binaural_node {
	unique_ptr<ma_phonon_binaural_node> bn;
	public:
		phonon_binaural_node_impl(audio_engine* e, int channels, int sample_rate, int frame_size = 0) {
			if (!e) throw std::exception("no engine provided");
			if (!phonon_init()) throw std::exception("Steam Audio was not initialized");
			if (!frame_size) frame_size = SOUNDSYSTEM_FRAMESIZE;
			bn = make_unique<ma_phonon_binaural_node>();
			IPLAudioSettings audio_settings {sample_rate, frame_size};
			ma_phonon_binaural_node_config cfg = ma_phonon_binaural_node_config_init(channels, audio_settings, g_phonon_context, g_phonon_hrtf);
			if ((g_soundsystem_last_error = ma_phonon_binaural_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*bn)) != MA_SUCCESS) throw std::exception("phonon_binaural_node was not created");
			node = (ma_node_base*)&*bn;
		}
		~phonon_binaural_node_impl() {
			if (bn) ma_phonon_binaural_node_uninit(&*bn, nullptr);
		}
		void set_direction(float x, float y, float z) override { ma_phonon_binaural_node_set_direction(&*bn, x, y, z); }
		void set_direction_vector(const reactphysics3d::Vector3& direction) override { ma_phonon_binaural_node_set_direction(&*bn, direction.x, direction.y, direction.z); }
		void set_spatial_blend_max_distance(float max_distance) override { ma_phonon_binaural_node_set_spatial_blend_max_distance(&*bn, max_distance); }
};
phonon_binaural_node* phonon_binaural_node::create(audio_engine* e, int channels, int sample_rate, int frame_size) { return new phonon_binaural_node_impl(e, channels, sample_rate, frame_size); }

// The following node updates the HRTF state for anything it is attached to, and can perform any other checks on a mixer or sound if needed.
typedef struct {
	ma_node_base base;
	mixer* m;
} ma_mixer_monitor_node;
static void ma_mixer_monitor_node_process_pcm_frames(ma_node* pNode, const float** ppFramesIn, ma_uint32* pFrameCountIn, float** ppFramesOut, ma_uint32* pFrameCountOut) {
	mixer* m = ((ma_mixer_monitor_node*)(pNode))->m;
	if (m->get_hrtf()) {
		if (!g_hrtf_enabled) m->set_hrtf(false);
		else dynamic_cast<phonon_binaural_node*>(m->get_hrtf_node())->set_direction_vector(m->get_direction_to_listener() * -1);
	} else if (g_hrtf_enabled && m->get_hrtf_desired()) m->set_hrtf(true);
}
static ma_node_vtable ma_mixer_monitor_node_vtable = { ma_mixer_monitor_node_process_pcm_frames, nullptr, 1, 1, MA_NODE_FLAG_PASSTHROUGH | MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT };
class mixer_monitor_node_impl : public audio_node_impl, public virtual mixer_monitor_node {
	unique_ptr<ma_mixer_monitor_node> mn;
	public:
	mixer_monitor_node_impl(mixer* m) : mn(make_unique<ma_mixer_monitor_node>()) {
		ma_node_config cfg = ma_node_config_init();
		ma_uint32 channels = m->get_engine()->get_channels();
		cfg.vtable          = &ma_mixer_monitor_node_vtable;
		cfg.pInputChannels  = &channels;
		cfg.pOutputChannels = &channels;
		if ((g_soundsystem_last_error = ma_node_init(ma_engine_get_node_graph(m->get_engine()->get_ma_engine()), &cfg, nullptr, (ma_node_base*)&*mn)) != MA_SUCCESS) throw std::exception("failed to create mixer_monitor_node");
		mn->m = m;
		node = (ma_node_base*)&*mn;
		attach_output_bus(0, m->get_engine()->get_endpoint(), 0);
	}
	~mixer_monitor_node_impl() {
		if (node) ma_node_uninit(node, nullptr);
	}
};
mixer_monitor_node* mixer_monitor_node::create(mixer* m) { return new mixer_monitor_node_impl(m); }


class splitter_node_impl : public audio_node_impl, public virtual splitter_node {
	unique_ptr<ma_splitter_node> sn;
	public:
	splitter_node_impl(audio_engine* e, int channels) {
		sn = make_unique<ma_splitter_node>();
		ma_splitter_node_config cfg = ma_splitter_node_config_init(channels);
		if ((g_soundsystem_last_error = ma_splitter_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*sn)) != MA_SUCCESS) throw std::exception("ma_splitter_node was not initialized");
		node = (ma_node_base*)&*sn;
	}
	~splitter_node_impl() {
		if (sn) ma_splitter_node_uninit(&*sn, nullptr);
	}
};
splitter_node* splitter_node::create(audio_engine* e, int channels) { return new splitter_node_impl(e, channels); }

