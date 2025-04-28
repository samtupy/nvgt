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
#include <Poco/NotificationQueue.h>
#include <Poco/Thread.h>
#include "sound_nodes.h"

using namespace std;

static IPLAudioSettings g_phonon_audio_settings {44100, SOUNDSYSTEM_FRAMESIZE}; // We will update samplerate later in phonon_init.
static IPLContext g_phonon_context = nullptr;
static IPLHRTF g_phonon_hrtf = nullptr;
static atomic<bool> g_hrtf_enabled = false;
static atomic<int> g_sound_position_changed; // We increase this value every time the listener moves. All mixer_monitor_nodes read it and, when it defers from their stored copy, they update the hrtf direction and distance.

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
	if (enabled && !phonon_init()) return false;
	g_hrtf_enabled = enabled;
	return true;
}
bool get_global_hrtf() { return g_hrtf_enabled; }

class phonon_binaural_node_impl : public audio_node_impl, public virtual phonon_binaural_node {
	unique_ptr<ma_phonon_binaural_node> bn;
	public:
		phonon_binaural_node_impl(audio_engine* e, int channels, int sample_rate, int frame_size = 0) {
			if (!e) throw std::invalid_argument("no engine provided");
			if (!phonon_init()) throw std::runtime_error("Steam Audio was not initialized");
			if (!frame_size) frame_size = SOUNDSYSTEM_FRAMESIZE;
			bn = make_unique<ma_phonon_binaural_node>();
			IPLAudioSettings audio_settings {sample_rate, frame_size};
			ma_phonon_binaural_node_config cfg = ma_phonon_binaural_node_config_init(channels, audio_settings, g_phonon_context, g_phonon_hrtf);
			if ((g_soundsystem_last_error = ma_phonon_binaural_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*bn)) != MA_SUCCESS) throw std::runtime_error("phonon_binaural_node was not created");
			node = (ma_node_base*)&*bn;
		}
		~phonon_binaural_node_impl() {
			if (bn) ma_phonon_binaural_node_uninit(&*bn, nullptr);
		}
		void set_direction(float x, float y, float z, float distance) override { ma_phonon_binaural_node_set_direction(&*bn, x, y, z, distance); }
		void set_direction_vector(const reactphysics3d::Vector3& direction, float distance) override { ma_phonon_binaural_node_set_direction(&*bn, direction.x, direction.y, direction.z, distance); }
		void set_spatial_blend_max_distance(float max_distance) override { ma_phonon_binaural_node_set_spatial_blend_max_distance(&*bn, max_distance); }
};
phonon_binaural_node* phonon_binaural_node::create(audio_engine* e, int channels, int sample_rate, int frame_size) { return new phonon_binaural_node_impl(e, channels, sample_rate, frame_size); }

// If a user globally disables HRTF or does anything which should result in an automatic update to the node graph, we need to make sure such changes happen outside of a node processing callback. The only other option to change multiple node states at once would be to maintain a list of known mixers that we'd loop through at the time of such a change. Both seem just as annoying to manage so we'll just pick an option.
class hrtf_update : public Poco::Notification {
	public:
	mixer* m;
	bool hrtf;
	hrtf_update(mixer* m, bool hrtf) : m(m), hrtf(hrtf) { if (m) m->duplicate(); }
	~hrtf_update() { if (m) m->release(); }
	void process() { m->set_hrtf_internal(hrtf); }
};
Poco::NotificationQueue g_hrtf_update_notifications;
Poco::Thread g_mixer_monitor_thread;
void mixer_monitor_thread(void* u) {
	while (true) {
		Poco::Notification::Ptr nptr = g_hrtf_update_notifications.waitDequeueNotification();
		hrtf_update* n = dynamic_cast<hrtf_update*>(&*nptr);
		if (!n->m) return;
		n->process();
	}
}

// The following node updates the HRTF state for anything it is attached to, and can perform any other checks on a mixer or sound if needed.
typedef struct {
	ma_node_base base;
	mixer* m;
	int position_changed;
} ma_mixer_monitor_node;
static void ma_mixer_monitor_node_process_pcm_frames(ma_node* pNode, const float** ppFramesIn, ma_uint32* pFrameCountIn, float** ppFramesOut, ma_uint32* pFrameCountOut) {
	ma_mixer_monitor_node* pMonitorNode = (ma_mixer_monitor_node*) pNode;
	mixer* m = pMonitorNode->m;
	if (!m->get_ma_sound()) return; // Sound is closing, unsafe to access it's properties.
	if (m->get_hrtf()) {
		if (!g_hrtf_enabled || !m->get_spatialization_enabled()) g_hrtf_update_notifications.enqueueNotification(new hrtf_update(m, false));
		else if (g_sound_position_changed != pMonitorNode->position_changed || pMonitorNode->position_changed == -1) {
			dynamic_cast<phonon_binaural_node*>(m->get_hrtf_node())->set_direction_vector(m->get_direction_to_listener() * -1, m->get_distance_to_listener());
			pMonitorNode->position_changed = g_sound_position_changed;
		}
	} else if (g_hrtf_enabled && m->get_hrtf_desired() && m->get_spatialization_enabled()) g_hrtf_update_notifications.enqueueNotification(new hrtf_update(m, true));
	else m->set_directional_attenuation_factor(std::clamp(m->get_distance_to_listener() / 4, 0.0f, 1.0f)); // Should we make 4 a configurable factor?
}
static ma_node_vtable ma_mixer_monitor_node_vtable = { ma_mixer_monitor_node_process_pcm_frames, nullptr, 1, 1, MA_NODE_FLAG_PASSTHROUGH | MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT };
class mixer_monitor_node_impl : public audio_node_impl, public virtual mixer_monitor_node {
	unique_ptr<ma_mixer_monitor_node> mn;
	int position_changed;
	public:
	mixer_monitor_node_impl(mixer* m) : mn(make_unique<ma_mixer_monitor_node>()), position_changed(0) {
		if (!g_mixer_monitor_thread.isRunning()) g_mixer_monitor_thread.start(mixer_monitor_thread, nullptr);
		ma_node_config cfg = ma_node_config_init();
		ma_uint32 channels = m->get_engine()->get_channels();
		cfg.vtable          = &ma_mixer_monitor_node_vtable;
		cfg.pInputChannels  = &channels;
		cfg.pOutputChannels = &channels;
		if ((g_soundsystem_last_error = ma_node_init(ma_engine_get_node_graph(m->get_engine()->get_ma_engine()), &cfg, nullptr, (ma_node_base*)&*mn)) != MA_SUCCESS) throw std::runtime_error("failed to create mixer_monitor_node");
		mn->m = m;
		mn->position_changed = -1;
		node = (ma_node_base*)&*mn;
		attach_output_bus(0, m->get_engine()->get_endpoint(), 0);
	}
	~mixer_monitor_node_impl() {
		if (node) ma_node_uninit(node, nullptr);
	}
	void set_position_changed() override { position_changed = -1; }
};
mixer_monitor_node* mixer_monitor_node::create(mixer* m) { return new mixer_monitor_node_impl(m); }

// When an engine's listener moves, all hrtf nodes need to get their position updated, as we don't want to recalculate the listener's direction every frame.
// The solution is to store a global integer that changes whenever any listener moves, and to store a copy of that integer in every mixer_monitor_node. When the global value defers from the stored one in each node, that node can update in it's callback.
// This is OK as a global because even when a listener update on engine B causes sounds to update for engine A, this is still quite far less extraneous than each frame recalculating the listener direction needlessly every time.
void set_sound_position_changed() { g_sound_position_changed += 1; if (g_sound_position_changed == -1) g_sound_position_changed += 1; }

class splitter_node_impl : public audio_node_impl, public virtual splitter_node {
	unique_ptr<ma_splitter_node> sn;
	public:
	splitter_node_impl(audio_engine* e, int channels) {
		sn = make_unique<ma_splitter_node>();
		ma_splitter_node_config cfg = ma_splitter_node_config_init(channels);
		if ((g_soundsystem_last_error = ma_splitter_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*sn)) != MA_SUCCESS) throw std::runtime_error("ma_splitter_node was not initialized");
		node = (ma_node_base*)&*sn;
	}
	~splitter_node_impl() {
		if (sn) ma_splitter_node_uninit(&*sn, nullptr);
	}
};
splitter_node* splitter_node::create(audio_engine* e, int channels) { return new splitter_node_impl(e, channels); }

