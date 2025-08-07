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
#include <ma_reverb_node.h>
#include "misc_functions.h" // range_convert
#include "sound_nodes.h"

using namespace std;

// The following node acts as a simple passthrough, with a callback that does nothing. The purpose is for any object that exists between or in any way handles nodes to be able to exist in the node graph.
// For example a reverb3d node acts as a high level API to applying reverb to 3d sounds. We want the user to be able to swap underlying reverb effect nodes that all sounds attached to the reverb3d objects are using, but prefferably without keeping track of sounds to reattach. Therefor, reverb3d acts as a passthrough node which all connected sounds are attached to, allowing us to swap the underlying reverb effect in one place rather than for all connected sounds.
typedef struct {
	ma_node_base base;
} ma_passthrough_node;
static void ma_passthrough_node_process_pcm_frames(ma_node* pNode, const float** ppFramesIn, ma_uint32* pFrameCountIn, float** ppFramesOut, ma_uint32* pFrameCountOut) {}
static ma_node_vtable ma_passthrough_node_vtable = { ma_passthrough_node_process_pcm_frames, nullptr, 1, 1, MA_NODE_FLAG_PASSTHROUGH | MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT };
class passthrough_node_impl : public audio_node_impl, public virtual passthrough_node {
	public:
	unique_ptr<ma_passthrough_node> pn;
	passthrough_node_impl(audio_engine* e) : pn(make_unique<ma_passthrough_node>()), audio_node_impl(nullptr, e) {
		ma_node_config cfg = ma_node_config_init();
		ma_uint32 channels = e->get_channels();
		cfg.vtable          = &ma_passthrough_node_vtable;
		cfg.pInputChannels  = &channels;
		cfg.pOutputChannels = &channels;
		if ((g_soundsystem_last_error = ma_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, (ma_node_base*)&*pn)) != MA_SUCCESS) throw std::runtime_error("failed to create passthrough node");
		node = (ma_node_base*)&*pn;
	}
	~passthrough_node_impl() {
		if (pn) ma_node_uninit((ma_node_base*)&*pn, nullptr);
	}
};
passthrough_node* passthrough_node::create(audio_engine* engine) { return new passthrough_node_impl(engine); }

class audio_node_chain_impl : public passthrough_node_impl, public virtual audio_node_chain {
	audio_node* source;
	std::vector<audio_node*> nodes;
	audio_node* endpoint;
	unsigned int endpoint_input_bus_index;
public:
	audio_node_chain_impl(audio_node* source, audio_node* endpoint, audio_engine* e) : passthrough_node_impl(e), endpoint(endpoint) {
		if (source) source->attach_output_bus(0, this, 0);
		if (endpoint) attach_output_bus(0, endpoint, 0);
	}
	~audio_node_chain_impl() {
		// We only release references, all attachments are kept in tact. Call clear(true) to detach all known nodes instead.
		for (audio_node* node: nodes) node->release();
		if (endpoint) endpoint->release();
	}
	bool attach_output_bus(unsigned int bus_index, audio_node* node, unsigned int input_bus_index) override {
		set_endpoint(node, input_bus_index);
		return endpoint == node;
	}
	bool detach_output_bus(unsigned int bus_index) override { set_endpoint(nullptr, 0); return endpoint == nullptr; }
	bool detach_all_output_buses() override { return detach_output_bus(0); }
	bool add_node(audio_node* node, audio_node* after, unsigned int input_bus_index) override {
		if (!node) return false;
		unsigned int new_idx = 0;
		if (after) {
			new_idx = index_of(after);
			if (new_idx == -1) return false;
			else new_idx += 1; // Be sure to insert after this position rather than before.
		}
		audio_node* prev = new_idx? nodes[new_idx -1] : nullptr;
		audio_node* next = new_idx? (new_idx < nodes.size()? nodes[new_idx] : endpoint) : (!nodes.empty()? first() : endpoint);
		if (prev && !prev->attach_output_bus(0, node, 0)) return false;
		else if (!prev && !audio_node_impl::attach_output_bus(0, node, 0)) return false;
		if (next && !node->attach_output_bus(0, next, input_bus_index)) return false;
		nodes.insert(nodes.begin() + new_idx, node);
		node->duplicate();
		return true;
	}
	bool add_node_at(audio_node* node, int after, unsigned int input_bus_index) override {
		if (after < -1 || after >= nodes.size()) return false;
		audio_node* insert_after = after > -1? nodes[after] : nullptr;
		return add_node(node, insert_after, input_bus_index);
	}
	bool remove_node(audio_node* node) override {
		if (!node) return false;
		auto it = find(nodes.begin(), nodes.end(), node);
		if (it == nodes.end()) return false;
		audio_node* prev = (*it) != nodes.front()? *(it -1) : nullptr;
		audio_node* next = (*it) != nodes.back()? *(it + 1) : endpoint;
		if (prev && next && !prev->attach_output_bus(0, next, 0)) return false;
		else if (!prev && next && !audio_node_impl::attach_output_bus(0, next, 0)) return false;
		nodes.erase(it);
		bool success = node->detach_output_bus(0);
		node->release();
		return success;
	}
	bool remove_node_at(unsigned int index) override {
		if (index >= nodes.size()) return false;
		return remove_node(nodes[index]);
	}
	bool clear(bool detach_nodes) override {
		bool success = audio_node_impl::detach_output_bus(0);
		for (audio_node* node : nodes) {
			if (success && detach_nodes) success = node->detach_output_bus(0);
			node->release();
		}
		if (success && endpoint) success = audio_node_impl::attach_output_bus(0, endpoint, 0);
		nodes.clear();
		return success;
	}
	void set_endpoint(audio_node* node, unsigned int input_bus_index) override {
		if (endpoint) {
			if (!nodes.empty()) last()->detach_output_bus(0);
			else audio_node_impl::detach_output_bus(0);
			endpoint->release();
		}
		endpoint = node;
		if (endpoint) {
			if (!nodes.empty()) last()->attach_output_bus(0, endpoint, input_bus_index);
			else audio_node_impl::attach_output_bus(0, endpoint, input_bus_index);
			endpoint->duplicate();
		}
	}
	audio_node* get_endpoint() const override { return endpoint; }
	audio_node* first() const override {
		if (nodes.empty()) return nullptr;
		return nodes[0];
	}
	audio_node* last() const override {
		if (nodes.empty()) return nullptr;
		return nodes[nodes.size() -1];
	}
	audio_node* operator[](unsigned int index) const override {
		if (nodes.size() <= index) return nullptr;
		return nodes[index];
	}
	int index_of(audio_node* node) const override {
		auto it = find(nodes.begin(), nodes.end(), node);
		if (it == nodes.end()) return -1;
		return distance(nodes.begin(), it);
	}
	unsigned int get_node_count() const override { return nodes.size(); }
};
audio_node_chain* audio_node_chain::create(audio_node* source, audio_node* endpoint, audio_engine* engine) { return new audio_node_chain_impl(source, endpoint, engine); }

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
		phonon_binaural_node_impl(audio_engine* e, int channels, int sample_rate, int frame_size = 0) : bn(make_unique<ma_phonon_binaural_node>()), audio_node_impl(nullptr, e) {
			if (!e) throw std::invalid_argument("no engine provided");
			if (!phonon_init()) throw std::runtime_error("Steam Audio was not initialized");
			if (!frame_size) frame_size = SOUNDSYSTEM_FRAMESIZE;
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

// The following node updates the HRTF state for anything it is attached to as well as the reverb3d distance if reverb is set up on the source, and can perform any other checks on a mixer or sound if needed.
typedef struct {
	ma_node_base base;
	mixer* m;
	int position_changed;
} ma_mixer_monitor_node;
static void ma_mixer_monitor_node_process_pcm_frames(ma_node* pNode, const float** ppFramesIn, ma_uint32* pFrameCountIn, float** ppFramesOut, ma_uint32* pFrameCountOut) {
	ma_mixer_monitor_node* pMonitorNode = (ma_mixer_monitor_node*) pNode;
	mixer* m = pMonitorNode->m;
	if (!m->get_ma_sound()) return; // Sound is closing, unsafe to access it's properties.
	bool listener_moved = g_sound_position_changed != pMonitorNode->position_changed && pMonitorNode->position_changed != -1, sound_moved = pMonitorNode->position_changed == -1;
	if (listener_moved && m->get_shape_object() && !m->get_shape_object()->connected_sound) m->set_position_3d_vector(m->get_position_3d()); // Force the sound to update it's position based on the shape.
	pMonitorNode->position_changed = g_sound_position_changed; // Indicate that we've processed all changes for this frame.
	float listener_dist = m->get_distance_to_listener();
	if ((listener_moved || sound_moved) && m->get_reverb3d() && m->get_reverb3d_attachment()) m->get_reverb3d_attachment()->set_output_bus_volume(1, m->get_reverb3d()->get_volume_at(listener_dist));
	phonon_binaural_node* hrtf_node = dynamic_cast<phonon_binaural_node*>(m->get_hrtf_node());
	if (m->get_hrtf()) {
		if (!g_hrtf_enabled || !m->get_spatialization_enabled()) g_hrtf_update_notifications.enqueueNotification(new hrtf_update(m, false));
		else if ((listener_moved || sound_moved) && hrtf_node) hrtf_node->set_direction_vector(m->get_direction_to_listener() * -1, listener_dist);
	} else if (g_hrtf_enabled && m->get_hrtf_desired() && m->get_spatialization_enabled()) g_hrtf_update_notifications.enqueueNotification(new hrtf_update(m, true));
	else m->set_directional_attenuation_factor(std::clamp(m->get_distance_to_listener() / 4, 0.0f, 1.0f)); // Should we make 4 a configurable factor?
}
static ma_node_vtable ma_mixer_monitor_node_vtable = { ma_mixer_monitor_node_process_pcm_frames, nullptr, 1, 1, MA_NODE_FLAG_PASSTHROUGH | MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT };
class mixer_monitor_node_impl : public audio_node_impl, public virtual mixer_monitor_node {
	unique_ptr<ma_mixer_monitor_node> mn;
	public:
	mixer_monitor_node_impl(mixer* m) : mn(make_unique<ma_mixer_monitor_node>()), audio_node_impl(nullptr, m->get_engine()) {
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
	}
	~mixer_monitor_node_impl() {
		if (node) ma_node_uninit(node, nullptr);
	}
	void set_position_changed() override { if (mn) mn->position_changed = -1; }
};
mixer_monitor_node* mixer_monitor_node::create(mixer* m) { return new mixer_monitor_node_impl(m); }

// When an engine's listener moves, all hrtf nodes need to get their position updated, as we don't want to recalculate the listener's direction every frame.
// The solution is to store a global integer that changes whenever any listener moves, and to store a copy of that integer in every mixer_monitor_node. When the global value defers from the stored one in each node, that node can update in it's callback.
// This is OK as a global because even when a listener update on engine B causes sounds to update for engine A, this is still quite far less extraneous than each frame recalculating the listener direction needlessly every time.
void set_sound_position_changed() { g_sound_position_changed += 1; if (g_sound_position_changed == -1) g_sound_position_changed += 1; }

class splitter_node_impl : public audio_node_impl, public virtual splitter_node {
	unique_ptr<ma_splitter_node> sn;
	public:
	splitter_node_impl(audio_engine* e, int channels) : sn(make_unique<ma_splitter_node>()), audio_node_impl(nullptr, e) {
		ma_splitter_node_config cfg = ma_splitter_node_config_init(channels);
		if ((g_soundsystem_last_error = ma_splitter_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*sn)) != MA_SUCCESS) throw std::runtime_error("ma_splitter_node was not initialized");
		node = (ma_node_base*)&*sn;
	}
	~splitter_node_impl() {
		if (sn) ma_splitter_node_uninit(&*sn, nullptr);
	}
};
splitter_node* splitter_node::create(audio_engine* e, int channels) { return new splitter_node_impl(e, channels); }

class low_pass_filter_node_impl : public audio_node_impl, public virtual low_pass_filter_node {
	unique_ptr<ma_lpf_node> fn;
	ma_lpf_node_config cfg;
	public:
	low_pass_filter_node_impl(double cutoff_frequency, int order, audio_engine* e) : fn(make_unique<ma_lpf_node>()), audio_node_impl(nullptr, e) {
		cfg = ma_lpf_node_config_init(e->get_channels(), e->get_sample_rate(), cutoff_frequency, order);
		if ((g_soundsystem_last_error = ma_lpf_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*fn)) != MA_SUCCESS) throw std::runtime_error("ma_low_pass_filter_node was not initialized");
		node = (ma_node_base*)&*fn;
	}
	~low_pass_filter_node_impl() {
		if (fn) ma_lpf_node_uninit(&*fn, nullptr);
	}
	void set_cutoff_frequency(double freq) override {
		cfg.lpf.cutoffFrequency = freq;
		ma_lpf_node_reinit(&cfg.lpf, &*fn);
	}
	double get_cutoff_frequency() const override { return cfg.lpf.cutoffFrequency; }
	void set_order(unsigned int order) override {
		cfg.lpf.order = order;
		ma_lpf_node_reinit(&cfg.lpf, &*fn);
	}
	unsigned int get_order() const override { return cfg.lpf.order; }
};
low_pass_filter_node* low_pass_filter_node::create(double cutoff_frequency, unsigned int order, audio_engine* engine) { return new low_pass_filter_node_impl(cutoff_frequency, order, engine); }

class high_pass_filter_node_impl : public audio_node_impl, public virtual high_pass_filter_node {
	unique_ptr<ma_hpf_node> fn;
	ma_hpf_node_config cfg;
	public:
	high_pass_filter_node_impl(double cutoff_frequency, int order, audio_engine* e) : fn(make_unique<ma_hpf_node>()), audio_node_impl(nullptr, e) {
		cfg = ma_hpf_node_config_init(e->get_channels(), e->get_sample_rate(), cutoff_frequency, order);
		if ((g_soundsystem_last_error = ma_hpf_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*fn)) != MA_SUCCESS) throw std::runtime_error("ma_high_pass_filter_node was not initialized");
		node = (ma_node_base*)&*fn;
	}
	~high_pass_filter_node_impl() {
		if (fn) ma_hpf_node_uninit(&*fn, nullptr);
	}
	void set_cutoff_frequency(double freq) override {
		cfg.hpf.cutoffFrequency = freq;
		ma_hpf_node_reinit(&cfg.hpf, &*fn);
	}
	double get_cutoff_frequency() const override { return cfg.hpf.cutoffFrequency; }
	void set_order(unsigned int order) override {
		cfg.hpf.order = order;
		ma_hpf_node_reinit(&cfg.hpf, &*fn);
	}
	unsigned int get_order() const override { return cfg.hpf.order; }
};
high_pass_filter_node* high_pass_filter_node::create(double cutoff_frequency, unsigned int order, audio_engine* engine) { return new high_pass_filter_node_impl(cutoff_frequency, order, engine); }

class band_pass_filter_node_impl : public audio_node_impl, public virtual band_pass_filter_node {
	unique_ptr<ma_bpf_node> fn;
	ma_bpf_node_config cfg;
	public:
	band_pass_filter_node_impl(double cutoff_frequency, int order, audio_engine* e) : fn(make_unique<ma_bpf_node>()), audio_node_impl(nullptr, e) {
		cfg = ma_bpf_node_config_init(e->get_channels(), e->get_sample_rate(), cutoff_frequency, order);
		if ((g_soundsystem_last_error = ma_bpf_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*fn)) != MA_SUCCESS) throw std::runtime_error("ma_band_pass_filter_node was not initialized");
		node = (ma_node_base*)&*fn;
	}
	~band_pass_filter_node_impl() {
		if (fn) ma_bpf_node_uninit(&*fn, nullptr);
	}
	void set_cutoff_frequency(double freq) override {
		cfg.bpf.cutoffFrequency = freq;
		ma_bpf_node_reinit(&cfg.bpf, &*fn);
	}
	double get_cutoff_frequency() const override { return cfg.bpf.cutoffFrequency; }
	void set_order(unsigned int order) override {
		cfg.bpf.order = order;
		ma_bpf_node_reinit(&cfg.bpf, &*fn);
	}
	unsigned int get_order() const override { return cfg.bpf.order; }
};
band_pass_filter_node* band_pass_filter_node::create(double cutoff_frequency, unsigned int order, audio_engine* engine) { return new band_pass_filter_node_impl(cutoff_frequency, order, engine); }

class notch_filter_node_impl : public audio_node_impl, public virtual notch_filter_node {
	unique_ptr<ma_notch_node> fn;
	ma_notch_node_config cfg;
	public:
	notch_filter_node_impl(double q, double frequency, audio_engine* e) : fn(make_unique<ma_notch_node>()), audio_node_impl(nullptr, e) {
		cfg = ma_notch_node_config_init(e->get_channels(), e->get_sample_rate(), q, frequency);
		if ((g_soundsystem_last_error = ma_notch_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*fn)) != MA_SUCCESS) throw std::runtime_error("ma_notch_filter_node was not initialized");
		node = (ma_node_base*)&*fn;
	}
	~notch_filter_node_impl() {
		if (fn) ma_notch_node_uninit(&*fn, nullptr);
	}
	void set_q(double q) override {
		cfg.notch.q = q;
		ma_notch_node_reinit(&cfg.notch, &*fn);
	}
	double get_q() const override { return cfg.notch.q; }
	void set_frequency(double freq) override {
		cfg.notch.frequency = freq;
		ma_notch_node_reinit(&cfg.notch, &*fn);
	}
	double get_frequency() const override { return cfg.notch.frequency; }
};
notch_filter_node* notch_filter_node::create(double q, double frequency, audio_engine* engine) { return new notch_filter_node_impl(q, frequency, engine); }

class peak_filter_node_impl : public audio_node_impl, public virtual peak_filter_node {
	unique_ptr<ma_peak_node> fn;
	ma_peak_node_config cfg;
	public:
	peak_filter_node_impl(double gain_db, double q, double frequency, audio_engine* e) : fn(make_unique<ma_peak_node>()), audio_node_impl(nullptr, e) {
		cfg = ma_peak_node_config_init(e->get_channels(), e->get_sample_rate(), gain_db, q, frequency);
		if ((g_soundsystem_last_error = ma_peak_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*fn)) != MA_SUCCESS) throw std::runtime_error("ma_peak_filter_node was not initialized");
		node = (ma_node_base*)&*fn;
	}
	~peak_filter_node_impl() {
		if (fn) ma_peak_node_uninit(&*fn, nullptr);
	}
	void set_gain(double gain) override {
		cfg.peak.gainDB = gain;
		ma_peak_node_reinit(&cfg.peak, &*fn);
	}
	double get_gain() const override { return cfg.peak.gainDB; }
	void set_q(double q) override {
		cfg.peak.q = q;
		ma_peak_node_reinit(&cfg.peak, &*fn);
	}
	double get_q() const override { return cfg.peak.q; }
	void set_frequency(double freq) override {
		cfg.peak.frequency = freq;
		ma_peak_node_reinit(&cfg.peak, &*fn);
	}
	double get_frequency() const override { return cfg.peak.frequency; }
};
peak_filter_node* peak_filter_node::create(double gain_db, double q, double frequency, audio_engine* engine) { return new peak_filter_node_impl(gain_db, q, frequency, engine); }

class low_shelf_filter_node_impl : public audio_node_impl, public virtual low_shelf_filter_node {
	unique_ptr<ma_loshelf_node> fn;
	ma_loshelf_node_config cfg;
	public:
	low_shelf_filter_node_impl(double gain_db, double q, double frequency, audio_engine* e) : fn(make_unique<ma_loshelf_node>()), audio_node_impl(nullptr, e) {
		cfg = ma_loshelf_node_config_init(e->get_channels(), e->get_sample_rate(), gain_db, q, frequency);
		if ((g_soundsystem_last_error = ma_loshelf_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*fn)) != MA_SUCCESS) throw std::runtime_error("ma_low_shelf_filter_node was not initialized");
		node = (ma_node_base*)&*fn;
	}
	~low_shelf_filter_node_impl() {
		if (fn) ma_loshelf_node_uninit(&*fn, nullptr);
	}
	void set_gain(double gain) override {
		cfg.loshelf.gainDB = gain;
		ma_loshelf_node_reinit(&cfg.loshelf, &*fn);
	}
	double get_gain() const override { return cfg.loshelf.gainDB; }
	void set_q(double q) override {
		cfg.loshelf.shelfSlope = q;
		ma_loshelf_node_reinit(&cfg.loshelf, &*fn);
	}
	double get_q() const override { return cfg.loshelf.shelfSlope; }
	void set_frequency(double freq) override {
		cfg.loshelf.frequency = freq;
		ma_loshelf_node_reinit(&cfg.loshelf, &*fn);
	}
	double get_frequency() const override { return cfg.loshelf.frequency; }
};
low_shelf_filter_node* low_shelf_filter_node::create(double gain_db, double q, double frequency, audio_engine* engine) { return new low_shelf_filter_node_impl(gain_db, q, frequency, engine); }

class high_shelf_filter_node_impl : public audio_node_impl, public virtual high_shelf_filter_node {
	unique_ptr<ma_hishelf_node> fn;
	ma_hishelf_node_config cfg;
	public:
	high_shelf_filter_node_impl(double gain_db, double q, double frequency, audio_engine* e) : fn(make_unique<ma_hishelf_node>()), audio_node_impl(nullptr, e) {
		cfg = ma_hishelf_node_config_init(e->get_channels(), e->get_sample_rate(), gain_db, q, frequency);
		if ((g_soundsystem_last_error = ma_hishelf_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*fn)) != MA_SUCCESS) throw std::runtime_error("ma_high_shelf_filter_node was not initialized");
		node = (ma_node_base*)&*fn;
	}
	~high_shelf_filter_node_impl() {
		if (fn) ma_hishelf_node_uninit(&*fn, nullptr);
	}
	void set_gain(double gain) override {
		cfg.hishelf.gainDB = gain;
		ma_hishelf_node_reinit(&cfg.hishelf, &*fn);
	}
	double get_gain() const override { return cfg.hishelf.gainDB; }
	void set_q(double q) override {
		cfg.hishelf.shelfSlope = q;
		ma_hishelf_node_reinit(&cfg.hishelf, &*fn);
	}
	double get_q() const override { return cfg.hishelf.shelfSlope; }
	void set_frequency(double freq) override {
		cfg.hishelf.frequency = freq;
		ma_hishelf_node_reinit(&cfg.hishelf, &*fn);
	}
	double get_frequency() const override { return cfg.hishelf.frequency; }
};
high_shelf_filter_node* high_shelf_filter_node::create(double gain_db, double q, double frequency, audio_engine* engine) { return new high_shelf_filter_node_impl(gain_db, q, frequency, engine); }

class delay_node_impl : public audio_node_impl, public virtual delay_node {
	unique_ptr<ma_delay_node> dn;
	public:
	delay_node_impl(unsigned int delay_in_frames, float decay, audio_engine* e) : dn(make_unique<ma_delay_node>()), audio_node_impl(nullptr, e) {
		ma_delay_node_config cfg = ma_delay_node_config_init(e->get_channels(), e->get_sample_rate(), delay_in_frames, decay);
		if ((g_soundsystem_last_error = ma_delay_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*dn)) != MA_SUCCESS) throw std::runtime_error("ma_delay_node was not initialized");
		node = (ma_node_base*)&*dn;
	}
	~delay_node_impl() {
		if (dn) ma_delay_node_uninit(&*dn, nullptr);
	}
	void set_wet(float wet) override { ma_delay_node_set_wet(&*dn, wet); }
	float get_wet() const override { return ma_delay_node_get_wet(&*dn); }
	void set_dry(float dry) override { ma_delay_node_set_dry(&*dn, dry); }
	float get_dry() const override { return ma_delay_node_get_dry(&*dn); }
	void set_decay(float decay) override { ma_delay_node_set_decay(&*dn, decay); }
	float get_decay() const override { return ma_delay_node_get_decay(&*dn); }
};
delay_node* delay_node::create(unsigned int delay_in_frames, float decay, audio_engine* engine) { return new delay_node_impl(delay_in_frames, decay, engine); }

class freeverb_node_impl : public audio_node_impl, public virtual freeverb_node {
	unique_ptr<ma_reverb_node> rn;
	public:
	freeverb_node_impl(audio_engine* e, int channels) : rn(make_unique<ma_reverb_node>()), audio_node_impl(nullptr, e) {
		ma_reverb_node_config cfg = ma_reverb_node_config_init(channels, g_audio_engine->get_sample_rate());
		if ((g_soundsystem_last_error = ma_reverb_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, &*rn)) != MA_SUCCESS) throw std::runtime_error("ma_reverb_node was not initialized");
		node = (ma_node_base*)&*rn;
	}
	~freeverb_node_impl() {
		if (rn) ma_reverb_node_uninit(&*rn, nullptr);
	}
	void set_room_size(float size) override { if (rn) verblib_set_room_size(&rn->reverb, size); }
	float get_room_size() const override { return rn? verblib_get_room_size(&rn->reverb) : -1; }
	void set_damping(float damping) override { if (rn) verblib_set_damping(&rn->reverb, damping); }
	float get_damping() const override { return rn? verblib_get_damping(&rn->reverb) : -1; }
	void set_width(float width) override { if (rn) verblib_set_width(&rn->reverb, width); }
	float get_width() const override { return rn? verblib_get_width(&rn->reverb) : -1; }
	void set_wet(float wet) override { if (rn) verblib_set_wet(&rn->reverb, wet); }
	float get_wet() const override { return rn? verblib_get_wet(&rn->reverb) : -1; }
	void set_dry(float dry) override { if (rn) verblib_set_dry(&rn->reverb, dry); }
	float get_dry() const override { return rn? verblib_get_dry(&rn->reverb) : -1; }
	void set_input_width(float width) override { if (rn) verblib_set_input_width(&rn->reverb, width); }
	float get_input_width() const override { return rn? verblib_get_input_width(&rn->reverb) : -1; }
	void set_frozen(bool frozen) override { if (rn) verblib_set_mode(&rn->reverb, frozen? 1 : 0); }
	bool get_frozen() const override { return rn? verblib_get_mode(&rn->reverb) >= 0.5 : false; }
};
freeverb_node* freeverb_node::create(audio_engine* e, int channels) { return new freeverb_node_impl(e, channels); }

class reverb3d_impl : public passthrough_node_impl, public virtual reverb3d {
	audio_node* reverb;
	mixer* output_mixer;
	float min_volume, max_volume, max_volume_distance, max_audible_distance, volume_curve;
public:
	reverb3d_impl(audio_engine* e, audio_node* reverb, mixer* destination) : passthrough_node_impl(e), output_mixer(destination), reverb(reverb), min_volume(0.5), max_volume(70.0), max_volume_distance(50.0), max_audible_distance(500.0), volume_curve(0.7) {
		if (reverb) {
			attach_output_bus(0, reverb, 0);
			if (output_mixer) reverb->attach_output_bus(0, output_mixer, 0);
			else reverb->attach_output_bus(0, e->get_endpoint(), 0);
		}
	}
	~reverb3d_impl() {
		if (output_mixer) output_mixer->release();
		if (reverb) reverb->release();
	}
	void set_reverb(audio_node* verb) override {
		if (reverb) {
			detach_output_bus(0);
			if (output_mixer) reverb->detach_output_bus(0);
			reverb->release();
		}
		reverb = verb;
		if (verb) {
			attach_output_bus(0, verb, 0);
			if (output_mixer) verb->attach_output_bus(0, output_mixer, 0);
		}
	}
	audio_node* get_reverb() const override { return reverb; }
	void set_mixer(mixer* mix) override {
		if (output_mixer) {
			if (reverb) reverb->detach_output_bus(0);
			output_mixer->release();
		}
		output_mixer = mix;
		if (mix && reverb) reverb->attach_output_bus(0, mix, 0);
		else if (reverb) reverb->attach_output_bus(0, get_engine()->get_endpoint(), 0);
	}
	mixer* get_mixer() const override { return output_mixer; }
	void set_min_volume(float value) override { min_volume = value; }
	float get_min_volume() const override { return min_volume; }
	void set_max_volume(float value) override { max_volume = value; }
	float get_max_volume() const override { return max_volume; }
	void set_max_volume_distance(float value) override { max_volume_distance = value; }
	float get_max_volume_distance() const override { return max_volume_distance; }
	void set_max_audible_distance(float value) override { max_audible_distance = value; }
	float get_max_audible_distance() const override { return max_audible_distance; }
	void set_volume_curve(float value) override { volume_curve = value; }
	float get_volume_curve() const override { return volume_curve; }
	float get_volume_at(float distance) const override {
		if (distance > max_audible_distance) distance = max_audible_distance;
		float v;
		if (distance <= max_volume_distance) {
			if (volume_curve <= 0) return max_volume;
			else if (volume_curve >= 1) return min_volume;
			v = range_convert(distance, 0, max_volume_distance, 0, 1);
			v = (1.0 - volume_curve) * ((v <= volume_curve? v : volume_curve) / volume_curve) + volume_curve * ((v > volume_curve? v - volume_curve : 0) / (1 - volume_curve));
			v = range_convert(v, 0, 1, min_volume, max_volume);
		} else v = max_volume - range_convert(distance, max_volume_distance, max_audible_distance, 0, max_volume);
		return clamp(v, 0.0f, max_volume);
	}
	splitter_node* create_attachment(audio_node* dry_input, audio_node* dry_output) override {
		splitter_node* splitter = splitter_node::create(get_engine(), get_output_channels(0));
		if (dry_output && !splitter->attach_output_bus(0, dry_output, 0)) {
			splitter->release();
			return nullptr;
		}
		if (!splitter->attach_output_bus(1, this, 0)) {
			splitter->release();
			return nullptr;
		}
		if (dry_input && !dry_input->attach_output_bus(0, splitter, 0)) {
			splitter->release();
			return nullptr;
		}
		return splitter;
	}
};
reverb3d* reverb3d::create(audio_node* reverb, mixer* destination, audio_engine* e) { return new reverb3d_impl(e, reverb, destination); }

typedef struct {
	ma_node_base base;
	plugin_node* impl;
} ma_plugin_node;
static void ma_plugin_node_process_pcm_frames(ma_node* pNode, const float** ppFramesIn, ma_uint32* pFrameCountIn, float** ppFramesOut, ma_uint32* pFrameCountOut) {
	ma_plugin_node* n = (ma_plugin_node*)pNode;
	if (n->impl) n->impl->process(ppFramesIn, pFrameCountIn, ppFramesOut, pFrameCountOut);
}
class plugin_node_impl : public audio_node_impl, public virtual plugin_node {
	unique_ptr<ma_plugin_node> pn;
	audio_plugin_node_interface* impl;
	ma_node_vtable vtable; // The user should be able to configure custom settings.
	public:
	plugin_node_impl(audio_plugin_node_interface* impl, unsigned char input_bus_count, unsigned char output_bus_count, unsigned int flags, audio_engine* engine) : pn(make_unique<ma_plugin_node>()), audio_node_impl(nullptr, engine), impl(impl) {
		vtable = { ma_plugin_node_process_pcm_frames, nullptr, input_bus_count, output_bus_count, flags };
		ma_node_config cfg = ma_node_config_init();
		ma_uint32 channels = engine->get_channels();
		cfg.vtable          = &vtable;
		cfg.pInputChannels  = &channels;
		cfg.pOutputChannels = &channels;
		if ((g_soundsystem_last_error = ma_node_init(ma_engine_get_node_graph(engine->get_ma_engine()), &cfg, nullptr, (ma_node_base*)&*pn)) != MA_SUCCESS) throw std::runtime_error("failed to create plugin_node");
		node = (ma_node_base*)&*pn;
	}
	~plugin_node_impl() {
		if (pn) ma_node_uninit(&*pn, nullptr);
	}
	audio_plugin_node_interface* get_plugin_interface() const override { return impl; }
	virtual void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		if (impl) impl->process(impl, frames_in, frame_count_in, frames_out, frame_count_out);
	}
};
plugin_node* plugin_node::create(audio_plugin_node_interface* impl, unsigned char input_bus_count, unsigned char output_bus_count, unsigned int flags,audio_engine* engine) { return new plugin_node_impl(impl, input_bus_count, output_bus_count, flags, engine); }
