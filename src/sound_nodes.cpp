/* sound_nodes.cpp - audio nodes implementation
 * This contains code for hooking all effects and other nodes up to miniaudio, from hrtf to reverb to filters to tone synthesis and more.
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

#include <exception>
#include <algorithm>
#include <atomic>
#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <chrono>
#include <memory>
#include <mutex>
#include <thread>
#include <unordered_set>
#include <Poco/NotificationQueue.h>
#include <Poco/Thread.h>
#include <ma_reverb_node.h>
#include "misc_functions.h" // range_convert
#include "sound_nodes.h"

using namespace std;

static int phonon_reflection_order = 1;
static int phonon_reflection_rays = 1024;
static int phonon_reflection_bounces = 1;
static int phonon_reflection_diffuse_samples = 16;
static int phonon_reflection_max_sources = 8;
static int phonon_reflection_threads = 4;
static float phonon_reflection_duration = 0.25f;
static float phonon_reflection_wet_gain = 0.65f;
static float phonon_reflection_silence_threshold = 0.000001f;
static float phonon_reflection_tail_padding = 0.0f;
static const IPLReflectionEffectType phonon_reflection_effect_type = IPL_REFLECTIONEFFECTTYPE_CONVOLUTION;
static const bool phonon_reflection_log_audio_chunks = false;

static int phonon_reflection_ir_size();
static std::atomic<int> g_phonon_reflection_debug_lines{0};
static std::atomic<unsigned long long> g_phonon_reflection_next_debug_id{1};

static void phonon_reflection_debug_log(const char* fmt, ...) {
	int line = g_phonon_reflection_debug_lines.fetch_add(1);
	if (line >= 500) return;
	FILE* f = std::fopen("phonon_reflection_debug.log", "ab");
	if (!f) return;
	std::va_list args;
	va_start(args, fmt);
	std::vfprintf(f, fmt, args);
	va_end(args);
	std::fprintf(f, "\r\n");
	std::fclose(f);
}

static bool phonon_reflection_buffer_has_signal(const float* frames, ma_uint32 frame_count, ma_uint32 channels) {
	if (!frames || frame_count == 0 || channels == 0) return false;
	ma_uint32 samples = frame_count * channels;
	for (ma_uint32 i = 0; i < samples; i++) {
		float sample = frames[i];
		if (sample > phonon_reflection_silence_threshold || sample < -phonon_reflection_silence_threshold) return true;
	}
	return false;
}
static float phonon_reflection_buffer_peak(const IPLAudioBuffer& buffer) {
	float peak = 0.0f;
	for (IPLint32 channel = 0; channel < buffer.numChannels; channel++) {
		if (!buffer.data[channel]) continue;
		for (IPLint32 sample = 0; sample < buffer.numSamples; sample++) {
			float v = std::fabs(buffer.data[channel][sample]);
			if (v > peak) peak = v;
		}
	}
	return peak;
}
static const char* phonon_reflection_effect_type_name() {
	switch (phonon_reflection_effect_type) {
		case IPL_REFLECTIONEFFECTTYPE_CONVOLUTION: return "convolution";
		case IPL_REFLECTIONEFFECTTYPE_PARAMETRIC: return "parametric";
		case IPL_REFLECTIONEFFECTTYPE_HYBRID: return "hybrid";
		case IPL_REFLECTIONEFFECTTYPE_TAN: return "tan";
		default: return "unknown";
	}
}
static int phonon_reflection_effect_channels() {
	return phonon_reflection_effect_type == IPL_REFLECTIONEFFECTTYPE_PARAMETRIC ? 1 : (phonon_reflection_order + 1) * (phonon_reflection_order + 1);
}

static int clamp_int(int value, int min_value, int max_value) {
	return std::max(min_value, std::min(max_value, value));
}
static float clamp_float(float value, float min_value, float max_value) {
	return std::max(min_value, std::min(max_value, value));
}

bool phonon_reflection_set_settings(int rays, int bounces, float duration, int order, int diffuse_samples, int max_sources, int threads, float default_wet_gain, float silence_threshold, float tail_padding) {
	phonon_reflection_rays = clamp_int(rays, 64, 8192);
	phonon_reflection_bounces = clamp_int(bounces, 1, 64);
	phonon_reflection_duration = clamp_float(duration, 0.10f, 4.0f);
	phonon_reflection_order = clamp_int(order, 1, 3);
	phonon_reflection_diffuse_samples = clamp_int(diffuse_samples, 8, 256);
	phonon_reflection_max_sources = clamp_int(max_sources, 1, 64);
	phonon_reflection_threads = clamp_int(threads, 1, 16);
	phonon_reflection_wet_gain = clamp_float(default_wet_gain, 0.0f, 8.0f);
	phonon_reflection_silence_threshold = clamp_float(silence_threshold, 0.0f, 0.01f);
	phonon_reflection_tail_padding = clamp_float(tail_padding, 0.0f, 2.0f);
	return true;
}
int phonon_reflection_get_order() { return phonon_reflection_order; }
int phonon_reflection_get_channels() { return phonon_reflection_effect_channels(); }
int phonon_reflection_get_rays() { return phonon_reflection_rays; }
int phonon_reflection_get_bounces() { return phonon_reflection_bounces; }
int phonon_reflection_get_diffuse_samples() { return phonon_reflection_diffuse_samples; }
int phonon_reflection_get_max_sources() { return phonon_reflection_max_sources; }
int phonon_reflection_get_threads() { return phonon_reflection_threads; }
float phonon_reflection_get_duration() { return phonon_reflection_duration; }
float phonon_reflection_get_default_wet_gain() { return phonon_reflection_wet_gain; }
float phonon_reflection_get_silence_threshold() { return phonon_reflection_silence_threshold; }
float phonon_reflection_get_tail_padding() { return phonon_reflection_tail_padding; }

// This node allows easy creation of miniaudio nodes in C++.
static void ma_effect_node_process_pcm_frames(ma_node* pNode, const float** ppFramesIn, ma_uint32* pFrameCountIn, float** ppFramesOut, ma_uint32* pFrameCountOut) {
	ma_effect_node* node = (ma_effect_node*)pNode;
	if (!node->node) return;
	node->node->process(ppFramesIn, pFrameCountIn, ppFramesOut, pFrameCountOut);
}
static ma_result ma_effect_node_get_required_input_frame_count(ma_node* pNode, ma_uint32 outputFrameCount, ma_uint32* input_frame_count) {
	ma_effect_node* node = (ma_effect_node*)pNode;
	if (!node->node) return MA_ERROR;
	*input_frame_count = node->node->required_input_frame_count(outputFrameCount);
	return MA_SUCCESS;
}
effect_node_impl::effect_node_impl(audio_engine* e, ma_uint8 input_channel_count, ma_uint8 output_channel_count, ma_uint8 input_bus_count, ma_uint8 output_bus_count, unsigned int flags) : n(make_unique<ma_effect_node>()), audio_node_impl(nullptr, e), vtable({&ma_effect_node_process_pcm_frames, &ma_effect_node_get_required_input_frame_count, input_bus_count, output_bus_count, flags}) {
	if (!input_channel_count) input_channel_count = e->get_channels();
	if (!output_channel_count) output_channel_count = e->get_channels();
	ma_node_config cfg = ma_node_config_init();
	vector<ma_uint32> channels_in(input_bus_count, input_channel_count), channels_out(output_bus_count, output_channel_count);
	cfg.vtable          = &vtable;
	if (input_bus_count > 0) cfg.pInputChannels  = &channels_in[0];
	if (output_bus_count > 0) cfg.pOutputChannels = &channels_out[0];
	if ((g_soundsystem_last_error = ma_node_init(ma_engine_get_node_graph(e->get_ma_engine()), &cfg, nullptr, (ma_node_base*)&*n)) != MA_SUCCESS) throw std::runtime_error("failed to create effect node");
	n->node = this;
	node = (ma_node_base*)&*n;
}
effect_node_impl::~effect_node_impl() { destroy_node(); }
void effect_node_impl::destroy_node() {
	if (n) ma_node_uninit((ma_node_base*)&*n, nullptr);
	n.reset();
}
void effect_node_impl::process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) {} // override in subclasses.
unsigned int effect_node_impl::required_input_frame_count(unsigned int output_frame_count) const { return output_frame_count; }

// The following node acts as a simple passthrough, with a callback that does nothing. The purpose is for any object that exists between or in any way handles nodes to be able to exist in the node graph.
// For example a reverb3d node acts as a high level API to applying reverb to 3d sounds. We want the user to be able to swap underlying reverb effect nodes that all sounds attached to the reverb3d objects are using, but prefferably without keeping track of sounds to reattach. Therefor, reverb3d acts as a passthrough node which all connected sounds are attached to, allowing us to swap the underlying reverb effect in one place rather than for all connected sounds.
class passthrough_node_impl : public effect_node_impl, public virtual passthrough_node {
	public:
	passthrough_node_impl(audio_engine* e) : effect_node_impl(e, 0, 0, 1, 1, MA_NODE_FLAG_PASSTHROUGH | MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT) {}
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

static int phonon_reflection_ir_size() {
	int size = int(g_phonon_audio_settings.samplingRate * phonon_reflection_duration);
	return size > SOUNDSYSTEM_FRAMESIZE ? size : SOUNDSYSTEM_FRAMESIZE;
}
static ma_uint32 phonon_reflection_tail_limit_frames() {
	int size = int(g_phonon_audio_settings.samplingRate * (phonon_reflection_duration + phonon_reflection_tail_padding));
	if (size < SOUNDSYSTEM_FRAMESIZE) size = SOUNDSYSTEM_FRAMESIZE;
	return (ma_uint32)size;
}

bool phonon_init() {
	if (g_phonon_context) return true;
	if (!init_sound()) return false;
	g_phonon_audio_settings = {g_audio_engine->get_sample_rate(), SOUNDSYSTEM_FRAMESIZE};
	g_phonon_reflection_debug_lines.store(0);
	if (FILE* f = std::fopen("phonon_reflection_debug.log", "wb")) std::fclose(f);
	phonon_reflection_debug_log("phonon_init engine_rate=%d engine_channels=%d phonon_rate=%d frame_size=%d", g_audio_engine ? g_audio_engine->get_sample_rate() : -1, g_audio_engine ? g_audio_engine->get_channels() : -1, g_phonon_audio_settings.samplingRate, g_phonon_audio_settings.frameSize);
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
	if (enabled == get_global_hrtf()) return true;
	if (enabled) {
		if (!phonon_init()) return false;
		if (!sound_set_spatialization(g_audio_phonon_hrtf_panner, g_audio_phonon_attenuator)) return false;
	} else return sound_set_spatialization(g_audio_basic_panner, g_audio_basic_attenuator, true, false);
	return true;
}
bool get_global_hrtf() { return get_audio_panner_enabled(g_audio_phonon_hrtf_panner) && get_audio_attenuator_enabled(g_audio_phonon_attenuator); }

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
	freeverb_node_impl(audio_engine* e) : rn(make_unique<ma_reverb_node>()), audio_node_impl(nullptr, e) {
		ma_reverb_node_config cfg = ma_reverb_node_config_init(e->get_channels(), e->get_sample_rate());
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
freeverb_node* freeverb_node::create(audio_engine* e) { return new freeverb_node_impl(e); }

class sound_environment_impl;
class phonon_reflection_mixer_node_impl;

class phonon_reflection_node_impl : public effect_node_impl, public virtual phonon_reflection_node {
	sound_environment_impl* environment;
	IPLSource source;
	IPLReflectionEffect reflection_effect;
	IPLAmbisonicsDecodeEffect decode_effect;
	IPLAudioBuffer input_buffer;
	IPLAudioBuffer mono_input_buffer;
	IPLAudioBuffer reflections_buffer;
	IPLAudioBuffer decoded_buffer;
	reactphysics3d::Vector3 position;
	std::atomic<bool> enabled;
	bool ready;
	std::atomic<bool> tail_remaining;
	std::atomic<bool> tail_draining;
	std::atomic<bool> tail_retired;
	ma_uint32 tail_frames_processed;
	std::atomic<bool> has_received_signal;
	bool source_inputs_dirty;
	float wet_gain;
	unsigned long long debug_id;
	int debug_process_count;
	bool debug_no_ir_logged;
	std::mutex effect_mutex;

	void release_steam_audio();
	bool create_steam_audio();
	void update_source_inputs_locked();
	void reset_effects_locked();
	bool drain_tail_chunk(ma_uint32 frame_count);
public:
	phonon_reflection_node_impl(sound_environment* environment, audio_engine* engine);
	~phonon_reflection_node_impl();
	bool set_environment(sound_environment* environment) override;
	sound_environment* get_environment() const override;
	void set_position(float x, float y, float z) override;
	void set_position_vector(const reactphysics3d::Vector3& position) override;
	reactphysics3d::Vector3 get_position() const override { return position; }
	void set_enabled(bool value) override {
		bool previous = enabled.exchange(value);
		if (previous == value) return;
		if (!value) {
			std::lock_guard<std::mutex> lock(effect_mutex);
			reset_effects_locked();
		}
	}
	bool get_enabled() const override { return enabled.load(); }
	bool get_has_tail() const override { return tail_remaining.load() || tail_draining.load(); }
	bool finish_tail() override;
	void set_wet_gain(float gain) override {
		wet_gain = std::max(0.0f, gain);
		if (debug_process_count < 2) phonon_reflection_debug_log("node_wet_gain id=%llu wet=%.3f", debug_id, wet_gain);
	}
	float get_wet_gain() const override { return wet_gain; }
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override;
	friend class sound_environment_impl;
};

class phonon_reflection_mixer_node_impl : public effect_node_impl {
	sound_environment_impl* environment;
	IPLAmbisonicsDecodeEffect decode_effect;
	IPLAudioBuffer reflections_buffer;
	IPLAudioBuffer decoded_buffer;
	std::mutex effect_mutex;
public:
	phonon_reflection_mixer_node_impl(sound_environment_impl* environment, audio_engine* engine);
	~phonon_reflection_mixer_node_impl();
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override;
	void shutdown();
};

class sound_environment_impl : public virtual sound_environment {
	int refcount;
	audio_engine* engine;
	IPLScene scene;
	IPLSimulator simulator;
	IPLReflectionMixer reflection_mixer;
	phonon_reflection_mixer_node_impl* mixer_node;
	IPLSimulationSharedInputs shared_inputs;
	std::unordered_map<std::string, IPLMaterial> materials;
	std::vector<IPLStaticMesh> meshes;
	std::unordered_set<phonon_reflection_node_impl*> nodes;
	std::unordered_set<phonon_reflection_node_impl*> tail_nodes;
	bool active;
	bool scene_needs_commit;
	bool shared_inputs_dirty;
	std::atomic<bool> simulation_stop;
	std::thread simulation_thread;
	std::mutex simulation_mutex;
	std::mutex mixer_mutex;
	float listener_x, listener_y, listener_z, listener_rotation;
	friend class phonon_reflection_node_impl;
	friend class phonon_reflection_mixer_node_impl;
	void cleanup_steam_audio_objects() {
		if (mixer_node) {
			mixer_node->shutdown();
			mixer_node->release();
			mixer_node = nullptr;
		}
		if (reflection_mixer) iplReflectionMixerRelease(&reflection_mixer);
		for (auto mesh : meshes) {
			if (mesh) iplStaticMeshRelease(&mesh);
		}
		meshes.clear();
		if (scene) iplSceneRelease(&scene);
		if (simulator) iplSimulatorRelease(&simulator);
		scene = nullptr;
		simulator = nullptr;
		reflection_mixer = nullptr;
		active = false;
	}
	bool run_simulation_tick(bool reflections) {
		std::unique_lock<std::mutex> sim_lock(simulation_mutex);
		IPLSimulator sim = nullptr;
		{
			std::lock_guard<std::mutex> lock(mutex);
			if (!simulator) return false;
			if (scene_needs_commit) {
				iplSceneCommit(scene);
				iplSimulatorCommit(simulator);
				scene_needs_commit = false;
			}
			if (shared_inputs_dirty) {
				iplSimulatorSetSharedInputs(simulator, IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS), &shared_inputs);
				shared_inputs_dirty = false;
			}
			for (auto* node : nodes) {
				if (node && node->source && node->source_inputs_dirty) {
					node->update_source_inputs_locked();
					node->source_inputs_dirty = false;
				}
			}
			sim = simulator;
		}
		iplSimulatorRunDirect(sim);
		if (reflections) iplSimulatorRunReflections(sim);
		return true;
	}
	void simulation_loop() {
		while (!simulation_stop.load()) {
			run_simulation_tick(true);
			std::this_thread::sleep_for(std::chrono::milliseconds(10));
		}
	}
	void reset_reflection_mixer() {
		std::lock_guard<std::mutex> lock(mixer_mutex);
		if (reflection_mixer) iplReflectionMixerReset(reflection_mixer);
	}
public:
	std::mutex mutex;

	sound_environment_impl(audio_engine* engine) : refcount(1), engine(engine ? engine : g_audio_engine), scene(nullptr), simulator(nullptr), reflection_mixer(nullptr), mixer_node(nullptr), shared_inputs{}, active(false), scene_needs_commit(false), shared_inputs_dirty(false), simulation_stop(false), listener_x(0), listener_y(0), listener_z(0), listener_rotation(0) {
		if (!this->engine) throw std::invalid_argument("no audio engine provided");
		this->engine->duplicate();
		try {
			if (!phonon_init()) throw std::runtime_error("Steam Audio initialization failed");
			IPLSimulationSettings simulation_settings{};
			simulation_settings.flags = IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS);
			simulation_settings.sceneType = IPL_SCENETYPE_DEFAULT;
			simulation_settings.reflectionType = phonon_reflection_effect_type;
			simulation_settings.maxNumRays = phonon_reflection_rays;
			simulation_settings.numDiffuseSamples = phonon_reflection_diffuse_samples;
			simulation_settings.maxDuration = phonon_reflection_duration;
			simulation_settings.maxOrder = phonon_reflection_order;
			simulation_settings.maxNumSources = phonon_reflection_max_sources;
			simulation_settings.numThreads = phonon_reflection_threads;
			simulation_settings.samplingRate = g_phonon_audio_settings.samplingRate;
			simulation_settings.frameSize = g_phonon_audio_settings.frameSize;
			if (iplSimulatorCreate(g_phonon_context, &simulation_settings, &simulator) != IPL_STATUS_SUCCESS) throw std::runtime_error("failed to create Steam Audio simulator");
			IPLReflectionEffectSettings mixer_settings{phonon_reflection_effect_type, phonon_reflection_ir_size(), phonon_reflection_effect_channels()};
			if (iplReflectionMixerCreate(g_phonon_context, &g_phonon_audio_settings, &mixer_settings, &reflection_mixer) != IPL_STATUS_SUCCESS) throw std::runtime_error("failed to create Steam Audio reflection mixer");
			IPLSceneSettings scene_settings{};
			scene_settings.type = IPL_SCENETYPE_DEFAULT;
			if (iplSceneCreate(g_phonon_context, &scene_settings, &scene) != IPL_STATUS_SUCCESS) throw std::runtime_error("failed to create Steam Audio scene");
			shared_inputs.numRays = phonon_reflection_rays;
			shared_inputs.numBounces = phonon_reflection_bounces;
			shared_inputs.duration = phonon_reflection_duration;
			shared_inputs.order = phonon_reflection_order;
			shared_inputs.irradianceMinDistance = 1.0f;
			add_material("air", 0, 0, 0, 0, 1, 1, 1, true);
			add_material("generic", 0.10f, 0.20f, 0.30f, 0.05f, 0.100f, 0.050f, 0.030f, true);
			add_material("brick", 0.03f, 0.04f, 0.07f, 0.05f, 0.015f, 0.015f, 0.015f, true);
			add_material("concrete", 0.05f, 0.07f, 0.08f, 0.05f, 0.015f, 0.002f, 0.001f, true);
			add_material("ceramic", 0.01f, 0.02f, 0.02f, 0.05f, 0.060f, 0.044f, 0.011f, true);
			add_material("gravel", 0.60f, 0.70f, 0.80f, 0.05f, 0.031f, 0.012f, 0.008f, true);
			add_material("carpet", 0.24f, 0.69f, 0.73f, 0.05f, 0.020f, 0.005f, 0.003f, true);
			add_material("glass", 0.06f, 0.03f, 0.02f, 0.05f, 0.060f, 0.044f, 0.011f, true);
			add_material("plaster", 0.12f, 0.06f, 0.04f, 0.05f, 0.056f, 0.056f, 0.004f, true);
			add_material("wood", 0.11f, 0.07f, 0.06f, 0.05f, 0.070f, 0.014f, 0.005f, true);
			add_material("metal", 0.20f, 0.07f, 0.06f, 0.05f, 0.200f, 0.025f, 0.010f, true);
			add_material("rock", 0.13f, 0.20f, 0.24f, 0.05f, 0.015f, 0.002f, 0.001f, true);
			iplSimulatorSetScene(simulator, scene);
			iplSimulatorCommit(simulator);
			mixer_node = new phonon_reflection_mixer_node_impl(this, this->engine);
			if (!mixer_node->attach_output_bus(0, this->engine->get_endpoint(), 0)) throw std::runtime_error("failed to attach Steam Audio reflection bus");
			active = true;
			simulation_thread = std::thread(&sound_environment_impl::simulation_loop, this);
		} catch (...) {
			simulation_stop.store(true);
			if (simulation_thread.joinable()) simulation_thread.join();
			cleanup_steam_audio_objects();
			this->engine->release();
			this->engine = nullptr;
			throw;
		}
	}
	~sound_environment_impl() {
		simulation_stop.store(true);
		if (simulation_thread.joinable()) simulation_thread.join();
		phonon_reflection_mixer_node_impl* node_to_release = nullptr;
		if (mixer_node) {
			node_to_release = mixer_node;
			mixer_node = nullptr;
		}
		if (node_to_release) {
			node_to_release->shutdown();
			node_to_release->release();
		}
		std::lock_guard<std::mutex> lock(mutex);
		for (auto* node : nodes) {
			if (node) node->environment = nullptr;
		}
		nodes.clear();
		std::vector<phonon_reflection_node_impl*> tail_nodes_to_release;
		for (auto* node : tail_nodes) {
			if (node) node->environment = nullptr;
			if (node) tail_nodes_to_release.push_back(node);
		}
		tail_nodes.clear();
		cleanup_steam_audio_objects();
		for (auto* node : tail_nodes_to_release) {
			if (node) node->release();
		}
		if (engine) engine->release();
	}
	void duplicate() override { asAtomicInc(refcount); }
	void release() override { if (asAtomicDec(refcount) < 1) delete this; }
	bool get_active() const override { return active; }
	bool add_material(const std::string& name, float absorption_low, float absorption_mid, float absorption_high, float scattering, float transmission_low, float transmission_mid, float transmission_high, bool replace_if_existing = false) override {
		std::lock_guard<std::mutex> lock(mutex);
		if (!replace_if_existing && materials.find(name) != materials.end()) return false;
		materials[name] = IPLMaterial{{absorption_low, absorption_mid, absorption_high}, scattering, {transmission_low, transmission_mid, transmission_high}};
		return true;
	}
	bool add_box(const std::string& material, float minx, float maxx, float miny, float maxy, float minz, float maxz) override {
		std::lock_guard<std::mutex> sim_lock(simulation_mutex);
		std::lock_guard<std::mutex> lock(mutex);
		auto it = materials.find(material);
		if (it == materials.end() || !scene) return false;
		IPLVector3 vertices[8] = {{minx, miny, minz}, {maxx, miny, minz}, {maxx, maxy, minz}, {minx, maxy, minz}, {minx, miny, maxz}, {maxx, miny, maxz}, {maxx, maxy, maxz}, {minx, maxy, maxz}};
		IPLTriangle triangles[12] = {{0, 1, 2}, {0, 2, 3}, {0, 1, 5}, {0, 5, 4}, {1, 5, 6}, {1, 6, 2}, {2, 6, 7}, {2, 7, 3}, {3, 7, 0}, {3, 0, 4}, {4, 5, 6}, {4, 6, 7}};
		IPLint32 material_indexes[12] = {0};
		IPLStaticMeshSettings mesh_settings{8, 12, 1, vertices, triangles, material_indexes, &it->second};
		IPLStaticMesh mesh = nullptr;
		if (iplStaticMeshCreate(scene, &mesh_settings, &mesh) != IPL_STATUS_SUCCESS || !mesh) return false;
		iplStaticMeshAdd(mesh, scene);
		meshes.push_back(mesh);
		scene_needs_commit = true;
		return true;
	}
	bool commit_scene() override {
		std::lock_guard<std::mutex> sim_lock(simulation_mutex);
		std::lock_guard<std::mutex> lock(mutex);
		if (!scene || !simulator) return false;
		if (scene_needs_commit) {
			iplSceneCommit(scene);
			iplSimulatorCommit(simulator);
			scene_needs_commit = false;
		}
		return true;
	}
	void set_listener(float x, float y, float z, float rotation) override {
		std::lock_guard<std::mutex> lock(mutex);
		listener_x = x;
		listener_y = y;
		listener_z = z;
		listener_rotation = rotation;
		shared_inputs.listener.right = IPLVector3{1, 0, 0};
		shared_inputs.listener.up = IPLVector3{0, 0, 1};
		shared_inputs.listener.ahead = IPLVector3{sin(rotation), cos(rotation), 0};
		shared_inputs.listener.origin = IPLVector3{x, y, z};
		shared_inputs_dirty = true;
	}
	void set_listener_vector(const reactphysics3d::Vector3& position, float rotation) override { set_listener(position.x, position.y, position.z, rotation); }
	bool update(bool reflections = true) override {
		std::lock_guard<std::mutex> lock(mutex);
		return simulator != nullptr;
	}
	phonon_reflection_node* create_reflection_node(audio_engine* engine = g_audio_engine) override { return phonon_reflection_node::create(this, engine ? engine : this->engine); }
	bool attach(phonon_reflection_node_impl* node) {
		if (!node || !simulator) return false;
		std::lock_guard<std::mutex> lock(mutex);
		nodes.insert(node);
		return true;
	}
	void detach(phonon_reflection_node_impl* node) {
		std::lock_guard<std::mutex> lock(mutex);
		nodes.erase(node);
	}
	bool add_tail_node(phonon_reflection_node_impl* node) {
		if (!node) return false;
		std::lock_guard<std::mutex> lock(mutex);
		if (tail_nodes.insert(node).second) node->duplicate();
		return true;
	}
	void retire_tail_node(phonon_reflection_node_impl* node) {
		bool should_release = false;
		{
			std::lock_guard<std::mutex> lock(mutex);
			should_release = tail_nodes.erase(node) > 0;
		}
		if (should_release) node->release();
	}
	void drain_tail_nodes(ma_uint32 frame_count) {
		std::vector<phonon_reflection_node_impl*> current_tail_nodes;
		{
			std::lock_guard<std::mutex> lock(mutex);
			current_tail_nodes.reserve(tail_nodes.size());
			for (auto* node : tail_nodes) {
				if (node) current_tail_nodes.push_back(node);
			}
		}
		for (auto* node : current_tail_nodes) {
			if (node) node->drain_tail_chunk(frame_count);
		}
		std::vector<phonon_reflection_node_impl*> retired_tail_nodes;
		{
			std::lock_guard<std::mutex> lock(mutex);
			for (auto it = tail_nodes.begin(); it != tail_nodes.end();) {
				phonon_reflection_node_impl* node = *it;
				if (node && node->tail_retired.load()) {
					retired_tail_nodes.push_back(node);
					it = tail_nodes.erase(it);
				} else {
					++it;
				}
			}
		}
		for (auto* node : retired_tail_nodes) {
			if (node) node->release();
		}
	}
	IPLSimulator get_simulator() const { return simulator; }
	IPLSimulationSharedInputs get_shared_inputs() const { return shared_inputs; }
};

phonon_reflection_mixer_node_impl::phonon_reflection_mixer_node_impl(sound_environment_impl* environment, audio_engine* engine) : effect_node_impl(engine ? engine : g_audio_engine, 0, 0, 1, 1, MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT), environment(environment), decode_effect(nullptr), reflections_buffer{}, decoded_buffer{} {
	IPLAmbisonicsDecodeEffectSettings decode_settings{};
	decode_settings.maxOrder = phonon_reflection_order;
	decode_settings.hrtf = g_phonon_hrtf;
	decode_settings.speakerLayout = IPLSpeakerLayout{IPL_SPEAKERLAYOUTTYPE_STEREO};
	if (iplAmbisonicsDecodeEffectCreate(g_phonon_context, &g_phonon_audio_settings, &decode_settings, &decode_effect) != IPL_STATUS_SUCCESS) throw std::runtime_error("failed to create Steam Audio reflection mixer decoder");
	if (iplAudioBufferAllocate(g_phonon_context, phonon_reflection_effect_channels(), g_phonon_audio_settings.frameSize, &reflections_buffer) != IPL_STATUS_SUCCESS ||
		iplAudioBufferAllocate(g_phonon_context, 2, g_phonon_audio_settings.frameSize, &decoded_buffer) != IPL_STATUS_SUCCESS) {
		shutdown();
		throw std::runtime_error("failed to allocate Steam Audio reflection mixer buffers");
	}
}
phonon_reflection_mixer_node_impl::~phonon_reflection_mixer_node_impl() {
	shutdown();
}
void phonon_reflection_mixer_node_impl::shutdown() {
	detach_output_bus(0);
	std::lock_guard<std::mutex> lock(effect_mutex);
	if (decode_effect) iplAmbisonicsDecodeEffectRelease(&decode_effect);
	if (reflections_buffer.data) iplAudioBufferFree(g_phonon_context, &reflections_buffer);
	if (decoded_buffer.data) iplAudioBufferFree(g_phonon_context, &decoded_buffer);
	decode_effect = nullptr;
	reflections_buffer = {};
	decoded_buffer = {};
	environment = nullptr;
}
void phonon_reflection_mixer_node_impl::process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) {
	if (!frame_count_out || !frames_out || !frames_out[0]) return;
	audio_engine* e = get_engine();
	ma_uint32 channels = e ? e->get_channels() : 0;
	ma_uint32 output_frames = *frame_count_out;
	if (channels == 0 || output_frames == 0) return;
	std::memset(frames_out[0], 0, output_frames * channels * sizeof(float));
	std::lock_guard<std::mutex> effect_lock(effect_mutex);
	if (!environment || !environment->reflection_mixer || !decode_effect || channels != 2) return;
	if (!reflections_buffer.data || !decoded_buffer.data || g_phonon_audio_settings.frameSize <= 0) return;
	IPLCoordinateSpace3 decode_orientation{};
	{
		std::lock_guard<std::mutex> lock(environment->mutex);
		decode_orientation = environment->get_shared_inputs().listener;
	}
	IPLAmbisonicsDecodeEffectParams decode_params{};
	decode_params.order = phonon_reflection_order;
	decode_params.hrtf = g_phonon_hrtf;
	decode_params.orientation = decode_orientation;
	decode_params.binaural = IPL_TRUE;
	IPLReflectionEffectParams mixer_params{};
	mixer_params.type = phonon_reflection_effect_type;
	mixer_params.numChannels = phonon_reflection_effect_channels();
	mixer_params.irSize = phonon_reflection_ir_size();
	if (!environment || !environment->reflection_mixer || !decode_effect || !reflections_buffer.data || !decoded_buffer.data) return;
	ma_uint32 processed = 0;
	while (processed < output_frames) {
		ma_uint32 frames_this_time = output_frames - processed;
		if (frames_this_time > (ma_uint32)g_phonon_audio_settings.frameSize) frames_this_time = (ma_uint32)g_phonon_audio_settings.frameSize;
		reflections_buffer.numSamples = frames_this_time;
		decoded_buffer.numSamples = frames_this_time;
		for (IPLint32 i = 0; i < reflections_buffer.numChannels; i++) {
			std::memset(reflections_buffer.data[i], 0, frames_this_time * sizeof(float));
		}
		for (IPLint32 i = 0; i < decoded_buffer.numChannels; i++) {
			std::memset(decoded_buffer.data[i], 0, frames_this_time * sizeof(float));
		}
		environment->drain_tail_nodes(frames_this_time);
		{
			std::lock_guard<std::mutex> mixer_lock(environment->mixer_mutex);
			iplReflectionMixerApply(environment->reflection_mixer, &mixer_params, &reflections_buffer);
		}
		iplAmbisonicsDecodeEffectApply(decode_effect, &decode_params, &reflections_buffer, &decoded_buffer);
		iplAudioBufferInterleave(g_phonon_context, &decoded_buffer, ma_offset_pcm_frames_ptr_f32(frames_out[0], processed, 2));
		processed += frames_this_time;
	}
}

phonon_reflection_node_impl::phonon_reflection_node_impl(sound_environment* environment, audio_engine* engine) : effect_node_impl(engine ? engine : g_audio_engine, 0, 0, 1, 1, MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT), environment(nullptr), source(nullptr), reflection_effect(nullptr), decode_effect(nullptr), input_buffer{}, mono_input_buffer{}, reflections_buffer{}, decoded_buffer{}, position(0, 0, 0), enabled(true), ready(false), tail_remaining(false), tail_draining(false), tail_retired(false), tail_frames_processed(0), has_received_signal(false), source_inputs_dirty(true), wet_gain(phonon_reflection_wet_gain), debug_id(g_phonon_reflection_next_debug_id.fetch_add(1)), debug_process_count(0), debug_no_ir_logged(false) {
	if (!phonon_init()) throw std::runtime_error("Steam Audio initialization failed");
	set_environment(environment);
}
phonon_reflection_node_impl::~phonon_reflection_node_impl() {
	set_environment(nullptr);
	release_steam_audio();
}
bool phonon_reflection_node_impl::create_steam_audio() {
	if (!environment || ready) return ready;
	audio_engine* e = get_engine();
	if (!e || e->get_channels() != 2) return false;
	IPLReflectionEffectSettings reflection_settings{phonon_reflection_effect_type, phonon_reflection_ir_size(), phonon_reflection_effect_channels()};
	if (iplReflectionEffectCreate(g_phonon_context, &g_phonon_audio_settings, &reflection_settings, &reflection_effect) != IPL_STATUS_SUCCESS) return false;
	if (iplAudioBufferAllocate(g_phonon_context, 2, g_phonon_audio_settings.frameSize, &input_buffer) != IPL_STATUS_SUCCESS ||
		iplAudioBufferAllocate(g_phonon_context, 1, g_phonon_audio_settings.frameSize, &mono_input_buffer) != IPL_STATUS_SUCCESS ||
		iplAudioBufferAllocate(g_phonon_context, phonon_reflection_effect_channels(), g_phonon_audio_settings.frameSize, &reflections_buffer) != IPL_STATUS_SUCCESS) {
		release_steam_audio();
		return false;
	}
	IPLSourceSettings source_settings{IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS)};
	if (iplSourceCreate(environment->get_simulator(), &source_settings, &source) != IPL_STATUS_SUCCESS || !source) {
		release_steam_audio();
		return false;
	}
	{
		std::lock_guard<std::mutex> sim_lock(environment->simulation_mutex);
		std::lock_guard<std::mutex> lock(environment->mutex);
		update_source_inputs_locked();
		source_inputs_dirty = false;
		iplSourceAdd(source, environment->get_simulator());
		iplSimulatorCommit(environment->get_simulator());
	}
	ready = true;
	phonon_reflection_debug_log("node_create id=%llu type=%s engine_rate=%d engine_channels=%d phonon_rate=%d frame_size=%d ir_size=%d tail_size=%d order=%d channels=%d rays=%d bounces=%d diffuse=%d max_sources=%d threads=%d duration=%.3f wet=%.3f tail_padding=%.3f", debug_id, phonon_reflection_effect_type_name(), e ? e->get_sample_rate() : -1, e ? e->get_channels() : -1, g_phonon_audio_settings.samplingRate, g_phonon_audio_settings.frameSize, phonon_reflection_ir_size(), reflection_effect ? iplReflectionEffectGetTailSize(reflection_effect) : -1, phonon_reflection_order, phonon_reflection_effect_channels(), phonon_reflection_rays, phonon_reflection_bounces, phonon_reflection_diffuse_samples, phonon_reflection_max_sources, phonon_reflection_threads, phonon_reflection_duration, wet_gain, phonon_reflection_tail_padding);
	return true;
}
void phonon_reflection_node_impl::release_steam_audio() {
	if (ready) phonon_reflection_debug_log("node_release id=%llu tail_remaining=%d process_count=%d", debug_id, tail_remaining.load() ? 1 : 0, debug_process_count);
	sound_environment_impl* release_environment = environment;
	if (source && environment) {
		std::lock_guard<std::mutex> sim_lock(environment->simulation_mutex);
		std::lock_guard<std::mutex> lock(environment->mutex);
		if (environment->get_simulator()) {
			iplSourceRemove(source, environment->get_simulator());
			iplSimulatorCommit(environment->get_simulator());
		}
	}
	{
		std::lock_guard<std::mutex> effect_lock(effect_mutex);
		reset_effects_locked();
		if (source) iplSourceRelease(&source);
		if (decode_effect) iplAmbisonicsDecodeEffectRelease(&decode_effect);
		if (reflection_effect) iplReflectionEffectRelease(&reflection_effect);
		if (input_buffer.data) iplAudioBufferFree(g_phonon_context, &input_buffer);
		if (mono_input_buffer.data) iplAudioBufferFree(g_phonon_context, &mono_input_buffer);
		if (reflections_buffer.data) iplAudioBufferFree(g_phonon_context, &reflections_buffer);
		if (decoded_buffer.data) iplAudioBufferFree(g_phonon_context, &decoded_buffer);
	}
	source = nullptr;
	decode_effect = nullptr;
	reflection_effect = nullptr;
	input_buffer = {};
	mono_input_buffer = {};
	reflections_buffer = {};
	decoded_buffer = {};
	ready = false;
	tail_remaining.store(false);
	tail_draining.store(false);
	tail_retired.store(false);
	tail_frames_processed = 0;
	has_received_signal.store(false);
	source_inputs_dirty = false;
}
void phonon_reflection_node_impl::update_source_inputs_locked() {
	if (!source || !environment) return;
	IPLSimulationInputs inputs{};
	inputs.flags = IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS);
	inputs.directFlags = IPLDirectSimulationFlags(IPL_DIRECTSIMULATIONFLAGS_DISTANCEATTENUATION | IPL_DIRECTSIMULATIONFLAGS_AIRABSORPTION | IPL_DIRECTSIMULATIONFLAGS_OCCLUSION | IPL_DIRECTSIMULATIONFLAGS_TRANSMISSION);
	inputs.distanceAttenuationModel = IPLDistanceAttenuationModel{IPL_DISTANCEATTENUATIONTYPE_DEFAULT};
	inputs.airAbsorptionModel = IPLAirAbsorptionModel{IPL_AIRABSORPTIONTYPE_DEFAULT};
	inputs.source = IPLCoordinateSpace3{IPLVector3{1, 0, 0}, IPLVector3{0, 0, 1}, IPLVector3{0, 1, 0}, IPLVector3{position.x, position.y, position.z}};
	inputs.occlusionType = IPL_OCCLUSIONTYPE_RAYCAST;
	iplSourceSetInputs(source, IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS), &inputs);
}
void phonon_reflection_node_impl::reset_effects_locked() {
	if (reflection_effect) iplReflectionEffectReset(reflection_effect);
	if (decode_effect) iplAmbisonicsDecodeEffectReset(decode_effect);
	tail_remaining.store(false);
	tail_draining.store(false);
	tail_retired.store(false);
	tail_frames_processed = 0;
	has_received_signal.store(false);
	debug_no_ir_logged = false;
}
bool phonon_reflection_node_impl::set_environment(sound_environment* env) {
	sound_environment_impl* next = dynamic_cast<sound_environment_impl*>(env);
	if (next == environment) return true;
	if (environment) {
		release_steam_audio();
		environment->detach(this);
		environment->release();
	}
	environment = next;
	if (!environment) return true;
	environment->duplicate();
	if (!environment->attach(this)) {
		environment->release();
		environment = nullptr;
		return false;
	}
	return create_steam_audio();
}
sound_environment* phonon_reflection_node_impl::get_environment() const {
	if (environment) environment->duplicate();
	return environment;
}
bool phonon_reflection_node_impl::finish_tail() {
	if (!environment || !ready || !reflection_effect || !has_received_signal.load()) return false;
	if (tail_draining.load()) return true;
	{
		std::lock_guard<std::mutex> effect_lock(effect_mutex);
		tail_remaining.store(true);
		tail_draining.store(true);
		tail_retired.store(false);
		tail_frames_processed = 0;
		enabled.store(true);
	}
	if (!environment->add_tail_node(this)) {
		tail_draining.store(false);
		return false;
	}
	phonon_reflection_debug_log("node_tail_begin id=%llu limit_frames=%u", debug_id, phonon_reflection_tail_limit_frames());
	return true;
}
bool phonon_reflection_node_impl::drain_tail_chunk(ma_uint32 frame_count) {
	if (!tail_draining.load() || tail_retired.load()) return false;
	std::lock_guard<std::mutex> effect_lock(effect_mutex);
	if (!tail_draining.load() || tail_retired.load()) return false;
	if (!environment || !ready || !reflection_effect || !reflections_buffer.data || !environment->reflection_mixer) {
		tail_draining.store(false);
		tail_remaining.store(false);
		tail_retired.store(true);
		return false;
	}
	ma_uint32 frames_remaining = phonon_reflection_tail_limit_frames() > tail_frames_processed ? phonon_reflection_tail_limit_frames() - tail_frames_processed : 0;
	ma_uint32 frames_this_time = std::min<ma_uint32>(frame_count, frames_remaining);
	if (frames_this_time == 0) {
		reset_effects_locked();
		tail_retired.store(true);
		phonon_reflection_debug_log("node_tail_end id=%llu", debug_id);
		return false;
	}
	reflections_buffer.numSamples = frames_this_time;
	for (IPLint32 i = 0; i < reflections_buffer.numChannels; i++) {
		std::memset(reflections_buffer.data[i], 0, frames_this_time * sizeof(float));
	}
	{
		std::lock_guard<std::mutex> mixer_lock(environment->mixer_mutex);
		iplReflectionEffectGetTail(reflection_effect, &reflections_buffer, environment->reflection_mixer);
	}
	tail_frames_processed += frames_this_time;
	tail_remaining.store(true);
	if (tail_frames_processed >= phonon_reflection_tail_limit_frames()) {
		reset_effects_locked();
		tail_retired.store(true);
		phonon_reflection_debug_log("node_tail_end id=%llu", debug_id);
		return false;
	}
	return true;
}
void phonon_reflection_node_impl::set_position(float x, float y, float z) {
	if (!environment || !source) {
		position = reactphysics3d::Vector3(x, y, z);
		return;
	}
	std::lock_guard<std::mutex> lock(environment->mutex);
	position = reactphysics3d::Vector3(x, y, z);
	source_inputs_dirty = true;
}
void phonon_reflection_node_impl::set_position_vector(const reactphysics3d::Vector3& pos) { set_position(pos.x, pos.y, pos.z); }
void phonon_reflection_node_impl::process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) {
	if (!frame_count_out || !frames_out || !frames_out[0]) return;
	audio_engine* e = get_engine();
	ma_uint32 channels = e ? e->get_channels() : 0;
	if (channels == 0) return;
	ma_uint32 output_frames = *frame_count_out;
	ma_uint32 input_frames = (frame_count_in ? *frame_count_in : 0);
	int process_index = debug_process_count++;
	if (phonon_reflection_log_audio_chunks && process_index < 16) {
		phonon_reflection_debug_log("process_enter id=%llu engine_rate=%d phonon_rate=%d output=%u input=%u has_in=%d tail_before=%d ready=%d enabled=%d", debug_id, e ? e->get_sample_rate() : -1, g_phonon_audio_settings.samplingRate, output_frames, input_frames, (frames_in && frames_in[0] && input_frames > 0) ? 1 : 0, tail_remaining.load() ? 1 : 0, ready ? 1 : 0, enabled.load() ? 1 : 0);
	}
	bool has_input = frames_in && frames_in[0] && input_frames > 0;
	ma_uint32 input_copy_frames = has_input ? min(input_frames, output_frames) : 0;
	bool input_has_signal = has_input && phonon_reflection_buffer_has_signal(frames_in[0], input_copy_frames, channels);
	if (input_has_signal) has_received_signal.store(true);
	bool has_tail = tail_remaining.load() || tail_draining.load();
	bool has_reflection_input = has_input && input_has_signal;
	if (input_copy_frames > 0) ma_copy_pcm_frames(frames_out[0], frames_in[0], input_copy_frames, ma_format_f32, channels);
	if (output_frames > input_copy_frames) {
		std::memset(ma_offset_pcm_frames_ptr_f32(frames_out[0], input_copy_frames, channels), 0, (output_frames - input_copy_frames) * channels * sizeof(float));
	}
	ma_uint32 total_frames = has_reflection_input ? input_copy_frames : (has_tail ? output_frames : 0);
	if (total_frames == 0) return;
	if (!enabled.load() || !environment || !ready || !source || !reflection_effect || channels != 2) return;
	if (!input_buffer.data || !mono_input_buffer.data || !reflections_buffer.data) return;
	if (g_phonon_audio_settings.frameSize <= 0) return;
	IPLSimulationOutputs outputs{};
	IPLReflectionEffectParams reflect_params{};
	if (has_reflection_input) {
		std::lock_guard<std::mutex> lock(environment->mutex);
		if (!source || !environment) return;
		iplSourceGetOutputs(source, IPLSimulationFlags(IPL_SIMULATIONFLAGS_REFLECTIONS), &outputs);
		reflect_params = outputs.reflections;
		if (phonon_reflection_effect_type != IPL_REFLECTIONEFFECTTYPE_PARAMETRIC && !reflect_params.ir) {
			if (!debug_no_ir_logged) {
				phonon_reflection_debug_log("process_no_ir id=%llu engine_rate=%d phonon_rate=%d output=%u input=%u", debug_id, e ? e->get_sample_rate() : -1, g_phonon_audio_settings.samplingRate, output_frames, input_frames);
				debug_no_ir_logged = true;
			}
			return;
		}
		reflect_params.type = phonon_reflection_effect_type;
		reflect_params.numChannels = phonon_reflection_effect_channels();
		reflect_params.irSize = phonon_reflection_ir_size();
	}
	std::unique_lock<std::mutex> effect_lock(effect_mutex);
	if (!enabled.load() || !ready || !reflection_effect || channels != 2) return;
	if (!input_buffer.data || !mono_input_buffer.data || !reflections_buffer.data || !environment || !environment->reflection_mixer) return;
	ma_uint32 processed = 0;
	while (processed < total_frames) {
		ma_uint32 frames_this_time = total_frames - processed;
		if (frames_this_time > (ma_uint32)g_phonon_audio_settings.frameSize) frames_this_time = (ma_uint32)g_phonon_audio_settings.frameSize;
		input_buffer.numSamples = frames_this_time;
		mono_input_buffer.numSamples = frames_this_time;
		reflections_buffer.numSamples = frames_this_time;
		for (IPLint32 i = 0; i < reflections_buffer.numChannels; i++) {
			std::memset(reflections_buffer.data[i], 0, frames_this_time * sizeof(float));
		}
		IPLAudioEffectState state = IPL_AUDIOEFFECTSTATE_TAILCOMPLETE;
		if (has_reflection_input) {
			tail_frames_processed = 0;
			iplAudioBufferDeinterleave(g_phonon_context, (float*)ma_offset_pcm_frames_const_ptr_f32(frames_in[0], processed, 2), &input_buffer);
			iplAudioBufferDownmix(g_phonon_context, &input_buffer, &mono_input_buffer);
			if (wet_gain != 1.0f && mono_input_buffer.data[0]) {
				for (IPLint32 sample = 0; sample < mono_input_buffer.numSamples; sample++) {
					mono_input_buffer.data[0][sample] *= wet_gain;
				}
			}
			{
				std::lock_guard<std::mutex> mixer_lock(environment->mixer_mutex);
				state = iplReflectionEffectApply(reflection_effect, &reflect_params, &mono_input_buffer, &reflections_buffer, environment->reflection_mixer);
			}
		} else {
			tail_frames_processed += frames_this_time;
			if (tail_frames_processed >= phonon_reflection_tail_limit_frames()) {
				reset_effects_locked();
				break;
			}
			for (IPLint32 i = 0; i < input_buffer.numChannels; i++) {
				std::memset(input_buffer.data[i], 0, frames_this_time * sizeof(float));
			}
			{
				std::lock_guard<std::mutex> mixer_lock(environment->mixer_mutex);
				state = iplReflectionEffectGetTail(reflection_effect, &reflections_buffer, environment->reflection_mixer);
			}
		}
		tail_remaining.store(input_has_signal || tail_draining.load() || state == IPL_AUDIOEFFECTSTATE_TAILREMAINING);
		if (phonon_reflection_log_audio_chunks && process_index < 16) {
			phonon_reflection_debug_log("process_chunk id=%llu type=%s render=mixer chunk=%u has_in=%d signal=%d tail_mode=%d state=%d tail_after=%d ir=%p ir_size=%d tail_size=%d gain=%.3f mixer=%p", debug_id, phonon_reflection_effect_type_name(), frames_this_time, has_input ? 1 : 0, input_has_signal ? 1 : 0, has_reflection_input ? 0 : 1, int(state), tail_remaining.load() ? 1 : 0, has_reflection_input ? (void*)reflect_params.ir : nullptr, has_reflection_input ? reflect_params.irSize : -1, reflection_effect ? iplReflectionEffectGetTailSize(reflection_effect) : -1, wet_gain, environment ? (void*)environment->reflection_mixer : nullptr);
		}
		processed += frames_this_time;
	}
}

sound_environment* sound_environment::create(audio_engine* engine) { return new sound_environment_impl(engine); }
phonon_reflection_node* phonon_reflection_node::create(sound_environment* environment, audio_engine* engine) { return new phonon_reflection_node_impl(environment, engine); }

class reverb3d_impl : public passthrough_node_impl, public virtual reverb3d {
	audio_node* reverb;
	mixer* output_mixer;
	float min_volume, max_volume, max_volume_distance, max_audible_distance, volume_curve;
public:
	reverb3d_impl(audio_engine* e, audio_node* reverb, mixer* destination) : passthrough_node_impl(e), output_mixer(destination), reverb(reverb), min_volume(-7), max_volume(-5), max_volume_distance(7), max_audible_distance(60), volume_curve(0.4) {
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
		if (distance <= max_volume_distance) v = range_convert(distance, 0, max_volume_distance, min_volume, max_volume);
		else {
			if (volume_curve <= 0) return ma_volume_db_to_linear(max_volume);
			else if (volume_curve >= 1) return ma_volume_db_to_linear(min_volume);
			v = range_convert(distance, max_volume_distance, max_audible_distance, 1, 0);
			v = (1.0 - volume_curve) * ((v <= volume_curve? v : volume_curve) / volume_curve) + volume_curve * ((v > volume_curve? v - volume_curve : 0) / (1 - volume_curve));
			v = range_convert(v, 0, 1, -60, max_volume);
		}
		return ma_volume_db_to_linear(clamp(v, -70.0f, max_volume));
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

static std::unordered_map<int, spatializer_component> g_audio_panners;
static std::unordered_map<int, spatializer_component> g_audio_attenuators;
static int g_next_panner_id = 0;
static int g_next_attenuator_id = 0;
static int g_default_3d_panner = -1;
static int g_default_3d_attenuator = -1;
static std::unordered_set<audio_spatializer*> g_tracked_spatializers;

int register_audio_panner(spatializer_component_node_factory factory, bool default_enabled) {
	int id = g_next_panner_id++;
	g_audio_panners[id] = {factory, default_enabled};
	return id;
}

int register_audio_attenuator(spatializer_component_node_factory factory, bool default_enabled) {
	int id = g_next_attenuator_id++;
	g_audio_attenuators[id] = {factory, default_enabled};
	return id;
}

spatializer_component_node* create_audio_panner(int id, audio_spatializer* spatializer, audio_engine* engine) {
	auto it = g_audio_panners.find(id);
	if (it == g_audio_panners.end() || !it->second.enabled) return nullptr;
	return it->second.factory(spatializer, engine);
}

spatializer_component_node* create_audio_attenuator(int id, audio_spatializer* spatializer, audio_engine* engine) {
	auto it = g_audio_attenuators.find(id);
	if (it == g_audio_attenuators.end() || !it->second.enabled) return nullptr;
	return it->second.factory(spatializer, engine);
}

void set_audio_panner_enabled(int id, bool enabled) {
	auto it = g_audio_panners.find(id);
	if (it != g_audio_panners.end()) {
		bool was_enabled = it->second.enabled;
		it->second.enabled = enabled;
		if (was_enabled != enabled) {
			for (auto* spatializer : g_tracked_spatializers) {
				if (spatializer) spatializer->on_panner_enabled_changed(id, enabled);
			}
		}
	}
}

void set_audio_attenuator_enabled(int id, bool enabled) {
	auto it = g_audio_attenuators.find(id);
	if (it != g_audio_attenuators.end()) {
		bool was_enabled = it->second.enabled;
		it->second.enabled = enabled;
		if (was_enabled != enabled) {
			for (auto* spatializer : g_tracked_spatializers) {
				if (spatializer) spatializer->on_attenuator_enabled_changed(id, enabled);
			}
		}
	}
}

bool get_audio_panner_enabled(int id) {
	auto it = g_audio_panners.find(id);
	return it != g_audio_panners.end() && it->second.enabled;
}

bool get_audio_attenuator_enabled(int id) {
	auto it = g_audio_attenuators.find(id);
	return it != g_audio_attenuators.end() && it->second.enabled;
}

void sound_set_default_3d_panner(int panner_id) {
	g_default_3d_panner = panner_id;
}

int sound_get_default_3d_panner() {
	return g_default_3d_panner;
}

void sound_set_default_3d_attenuator(int attenuator_id) {
	g_default_3d_attenuator = attenuator_id;
}

int sound_get_default_3d_attenuator() {
	return g_default_3d_attenuator;
}

// Global  spatializer component registrations
int g_audio_basic_panner = g_default_3d_panner = register_audio_panner(basic_panner::create, true);
int g_audio_phonon_hrtf_panner = register_audio_panner(phonon_hrtf_panner::create, false);
int g_audio_basic_attenuator = g_default_3d_attenuator = register_audio_attenuator(basic_attenuator::create, true);
int g_audio_phonon_attenuator = register_audio_attenuator(phonon_attenuator::create, false);

bool sound_set_spatialization(int panner, int attenuator, bool disable_previous, bool set_default) {
	bool panner_success = false, attenuator_success = false;
	int prev_panner = g_default_3d_panner, prev_attenuator = g_default_3d_attenuator;
	auto panner_it = g_audio_panners.find(panner);
	if (panner_it != g_audio_panners.end()) {
		if (!panner_it->second.enabled) set_audio_panner_enabled(panner, true);
		if (set_default) sound_set_default_3d_panner(panner);
		panner_success = true;
		if (panner != prev_panner && disable_previous) set_audio_panner_enabled(prev_panner, false);
	}
	auto attenuator_it = g_audio_attenuators.find(attenuator);
	if (attenuator_it != g_audio_attenuators.end()) {
		if (!attenuator_it->second.enabled) set_audio_attenuator_enabled(attenuator, true);
		if (set_default) sound_set_default_3d_attenuator(attenuator);
		attenuator_success = true;
		if (attenuator != prev_attenuator && disable_previous) set_audio_attenuator_enabled(prev_attenuator, false);
	}
	return panner_success && attenuator_success;
}

class audio_spatializer_impl : public audio_node_chain_impl, public virtual audio_spatializer {
private:
	spatializer_component_node* panner;
	spatializer_component_node* attenuator;
	reverb3d* reverb;
	splitter_node* reverb_attachment;
	audio_spatializer_reverb3d_placement reverb_placement;
	mixer* attached_mixer;
	audio_spatialization_parameters spatialization_params;
	bool parameters_valid;
	int preferred_panner_id, preferred_attenuator_id;
	int current_panner_id, current_attenuator_id;
	void position_reverb() {
		if (!reverb_attachment) return;
		remove_node(reverb_attachment);
		switch (reverb_placement) {
			case prepan:
				add_node(reverb_attachment, nullptr, 0);
				break;
			case postpan:
				if (panner) add_node(reverb_attachment, panner, 0);
				else add_node(reverb_attachment, nullptr, 0);
				break;
			case postattenuate:
				if (attenuator) add_node(reverb_attachment, attenuator, 0);
				else if (panner) add_node(reverb_attachment, panner, 0);
				else add_node(reverb_attachment, nullptr, 0);
				break;
		}
	}
	bool set_fallback_panner() {
		for (const auto& pair : g_audio_panners) {
			if (!pair.second.enabled) continue;
			spatializer_component_node* fallback_panner = create_audio_panner(pair.first, this, get_engine());
			if (!fallback_panner) continue;
			current_panner_id = pair.first;
			set_panner(fallback_panner);
			return true;
		}
		return false;
	}
	bool set_fallback_attenuator() {
		for (const auto& pair : g_audio_attenuators) {
			if (!pair.second.enabled) continue;
			spatializer_component_node* fallback_attenuator = create_audio_attenuator(pair.first, this, get_engine());
			if (!fallback_attenuator) continue;
			current_attenuator_id = pair.first;
			set_attenuator(fallback_attenuator);
			return true;
		}
		return false;
	}
public:
	audio_spatializer_impl(mixer* mixer, audio_engine* engine) : audio_node_chain_impl(nullptr, nullptr, engine), panner(nullptr), attenuator(nullptr), reverb(nullptr), reverb_attachment(nullptr), reverb_placement(postpan), attached_mixer(mixer), spatialization_params{}, parameters_valid(true), preferred_panner_id(-1), preferred_attenuator_id(-1), current_panner_id(-1), current_attenuator_id(-1) {
		if (!mixer) throw std::invalid_argument("mixer cannot be null");
		spatialization_params.rolloff = 1.0f;
		spatialization_params.directional_attenuation_factor = 1.0f;
		g_tracked_spatializers.insert(this);
	}
	~audio_spatializer_impl() {
		destroy_node();
		g_tracked_spatializers.erase(this);
		if (panner) panner->release();
		if (attenuator) attenuator->release();
		if (reverb_attachment) reverb_attachment->release();
		if (reverb) reverb->release();
	}
	void set_panner(spatializer_component_node* new_panner) override {
		if (panner) {
			remove_node(panner);
			panner->release();
		}
		panner = new_panner;
		if (panner) {
			if (reverb_attachment && reverb_placement == prepan) add_node(panner, reverb_attachment, 0);
			else add_node(panner, nullptr, 0);
		}
	}
	void set_attenuator(spatializer_component_node* new_attenuator) override {
		if (attenuator) {
			remove_node(attenuator);
			attenuator->release();
		}
		attenuator = new_attenuator;
		if (attenuator) {
			if (panner && (!reverb_attachment || reverb_placement != postpan)) add_node(attenuator, panner, 0);
			else if (reverb_attachment && reverb_placement == postpan) add_node(attenuator, reverb_attachment, 0);
			else if (!panner && reverb_attachment && reverb_placement == prepan) add_node(attenuator, reverb_attachment, 0);
			else add_node(attenuator, nullptr, 0);
		}
	}
	void set_reverb3d(reverb3d* new_reverb, audio_spatializer_reverb3d_placement placement = postpan) override {
		if (new_reverb == reverb) {
			if (new_reverb) new_reverb->release();
			return;
		}
		audio_node* tmp;
		if (reverb) {
			tmp = reverb;
			reverb = nullptr;
			tmp->release();
			if (reverb_attachment) {
				remove_node(reverb_attachment);
				tmp = reverb_attachment;
				reverb_attachment = nullptr;
				tmp->release();
			}
		}
		if (new_reverb) {
			reverb_attachment = new_reverb->create_attachment();
			if (!reverb_attachment) {
				new_reverb->release();
				return;
			}
			if (attached_mixer && parameters_valid) reverb_attachment->set_output_bus_volume(1, new_reverb->get_volume_at(spatialization_params.listener_distance));
			reverb_placement = placement;
			position_reverb();
		}
		reverb = new_reverb;
	}
	spatializer_component_node* get_panner() const override { return panner; }
	spatializer_component_node* get_attenuator() const override { return attenuator; }
	reverb3d* get_reverb3d() const override { return reverb; }
	splitter_node* get_reverb3d_attachment() const override { return reverb_attachment; }
	audio_spatializer_reverb3d_placement get_reverb3d_placement() const override { return reverb_placement; }
	mixer* get_mixer() const override { return attached_mixer; }
	void set_panner_by_id(int panner_id) override {
		preferred_panner_id = panner_id;
		spatializer_component_node* new_panner = create_audio_panner(panner_id, this, get_engine());
		if (new_panner) {
			current_panner_id = panner_id;
			set_panner(new_panner);
		} else if (!set_fallback_panner()) {
			current_panner_id = -1;
			set_panner(nullptr);
		}
	}
	void set_attenuator_by_id(int attenuator_id) override {
		preferred_attenuator_id = attenuator_id;
		spatializer_component_node* new_attenuator = create_audio_attenuator(attenuator_id, this, get_engine());
		if (new_attenuator) {
			current_attenuator_id = attenuator_id;
			set_attenuator(new_attenuator);
		} else if (!set_fallback_attenuator()) {
			current_attenuator_id = -1;
			set_attenuator(nullptr);
		}
	}
	int get_current_panner_id() const override { return current_panner_id; }
	int get_current_attenuator_id() const override { return current_attenuator_id; }
	int get_preferred_panner_id() const override { return preferred_panner_id; }
	int get_preferred_attenuator_id() const override { return preferred_attenuator_id; }
	void set_rolloff(float rolloff) override { spatialization_params.rolloff = clamp(rolloff, 0.0f, 100.0f); }
	float get_rolloff() const override { return spatialization_params.rolloff; }
	void set_directional_attenuation_factor(float factor) override { spatialization_params.directional_attenuation_factor = clamp(factor, 0.0f, 100.0f); }
	float get_directional_attenuation_factor() const override { return spatialization_params.directional_attenuation_factor; }
	bool get_parameters(audio_spatialization_parameters& params) override {
		if (!parameters_valid) return false;
		params = spatialization_params;
		return true;
	}
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		if (attached_mixer && (panner || attenuator || reverb)) {
			parameters_valid = attached_mixer->get_spatialization_parameters(spatialization_params);
			if (parameters_valid && reverb) reverb_attachment->set_output_bus_volume(1, reverb->get_volume_at(spatialization_params.listener_distance));
		} else parameters_valid = false;
	}
	void on_panner_enabled_changed(int panner_id, bool enabled) override {
		if (enabled) {
			if (preferred_panner_id == panner_id && preferred_panner_id != current_panner_id) {
				spatializer_component_node* new_panner = create_audio_panner(panner_id, this, get_engine());
				if (new_panner) {
					current_panner_id = panner_id;
					set_panner(new_panner);
				}
			}
		} else {
			if (current_panner_id == panner_id && !set_fallback_panner()) {
				current_panner_id = -1;
				set_panner(nullptr);
			}
		}
	}
	void on_attenuator_enabled_changed(int attenuator_id, bool enabled) override {
		if (enabled) {
			if (preferred_attenuator_id == attenuator_id && preferred_attenuator_id != current_attenuator_id) {
				spatializer_component_node* new_attenuator = create_audio_attenuator(attenuator_id, this, get_engine());
				if (new_attenuator) {
					current_attenuator_id = attenuator_id;
					set_attenuator(new_attenuator);
				}
			}
		} else {
			if (current_attenuator_id == attenuator_id && !set_fallback_attenuator()) {
				current_attenuator_id = -1;
				set_attenuator(nullptr);
			}
		}
	}
};
audio_spatializer* audio_spatializer::create(mixer* mixer, audio_engine* engine) { return new audio_spatializer_impl(mixer, engine); }

class spatializer_component_node_impl : public effect_node_impl, public virtual spatializer_component_node {
protected:
	audio_spatializer* spatializer;
public:
	spatializer_component_node_impl(audio_spatializer* spatializer, audio_engine* e, unsigned int input_channels = 0, unsigned int output_channels = 0, unsigned int input_bus_count = 1, unsigned int output_bus_count = 1, unsigned int flags = MA_NODE_FLAG_CONTINUOUS_PROCESSING) : effect_node_impl(e, input_channels, output_channels, input_bus_count, output_bus_count, flags), spatializer(spatializer) {
		if (!spatializer) throw std::invalid_argument("spatializer cannot be null");
	}
	audio_spatializer* get_spatializer() const override { return spatializer; }
};

class basic_panner_impl : public spatializer_component_node_impl, public virtual basic_panner {
	ma_panner panner;
public:
	basic_panner_impl(audio_spatializer* spatializer, audio_engine* e) : spatializer_component_node_impl(spatializer, e, 0, 2) {
		ma_panner_config panner_config = ma_panner_config_init(ma_format_f32, 2);
		if (ma_panner_init(&panner_config, &panner) != MA_SUCCESS) throw std::runtime_error("Failed to initialize panner");
	}
	~basic_panner_impl() { destroy_node(); }
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		ma_uint32 frameCount = *frame_count_out;
		if (!spatializer) goto fail;
		audio_spatialization_parameters params;
		if (!spatializer->get_parameters(params)) goto fail;
		ma_panner_set_pan(&panner, pan_db_to_linear((params.listener_direction_x * params.listener_distance) * params.directional_attenuation_factor * 1.75));
		if (frameCount > *frame_count_in) frameCount = *frame_count_in;
		ma_panner_process_pcm_frames(&panner, frames_out[0], frames_in[0], frameCount);
		return;
		fail:
			ma_copy_pcm_frames(frames_out[0], frames_in[0], *frame_count_in, ma_format_f32, get_engine()->get_channels());
	}
};
spatializer_component_node* basic_panner::create(audio_spatializer* spatializer, audio_engine* engine) { return new basic_panner_impl(spatializer, engine); }

class phonon_hrtf_panner_impl : public spatializer_component_node_impl, public virtual phonon_hrtf_panner {
	IPLBinauralEffect iplEffect;
	IPLBinauralEffectParams iplEffectParams;
	IPLAudioBuffer inputBuffer;
	IPLAudioBuffer outputBuffer;
public:
	phonon_hrtf_panner_impl(audio_spatializer* spatializer, audio_engine* e) : spatializer_component_node_impl(spatializer, e, 0, 2), iplEffect(nullptr) {
		if (!phonon_init()) throw std::runtime_error("Steam Audio initialization failed");
		IPLBinauralEffectSettings effectSettings{};
		effectSettings.hrtf = g_phonon_hrtf;
		iplEffectParams = {};
		iplEffectParams.interpolation = IPL_HRTFINTERPOLATION_NEAREST;
		iplEffectParams.spatialBlend = 1.0;
		iplEffectParams.hrtf = g_phonon_hrtf;
		if (iplBinauralEffectCreate(g_phonon_context, &g_phonon_audio_settings, &effectSettings, &iplEffect) != IPL_STATUS_SUCCESS) throw std::runtime_error("Failed to create binaural effect");
		ma_uint32 channelsIn = e->get_channels();
		if (iplAudioBufferAllocate(g_phonon_context, channelsIn, g_phonon_audio_settings.frameSize, &inputBuffer) != IPL_STATUS_SUCCESS) {
			iplBinauralEffectRelease(&iplEffect);
			throw std::runtime_error("Failed to allocate input audio buffer");
		}
		if (iplAudioBufferAllocate(g_phonon_context, 2, g_phonon_audio_settings.frameSize, &outputBuffer) != IPL_STATUS_SUCCESS) {
			iplAudioBufferFree(g_phonon_context, &inputBuffer);
			iplBinauralEffectRelease(&iplEffect);
			throw std::runtime_error("Failed to allocate output audio buffer");
		}
	}
	~phonon_hrtf_panner_impl() {	
		destroy_node();
		if (iplEffect) iplBinauralEffectRelease(&iplEffect);
		iplAudioBufferFree(g_phonon_context, &inputBuffer);
		iplAudioBufferFree(g_phonon_context, &outputBuffer);
	}
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		ma_uint32 totalFramesToProcess = *frame_count_out;
		ma_uint32 totalFramesProcessed = 0;
		float fully_spatialized_distance = 5; // Make this configurable once spatializer components have a property system.
		if (fully_spatialized_distance < 0.1) fully_spatialized_distance = 0.1;
		if (!spatializer || !iplEffect) goto fail;
		audio_spatialization_parameters params;
		if (!spatializer->get_parameters(params)) goto fail;
		iplEffectParams.direction.x = params.listener_direction_x * params.directional_attenuation_factor;
		iplEffectParams.direction.y = params.listener_direction_y * params.directional_attenuation_factor;
		iplEffectParams.direction.z = params.listener_direction_z * params.directional_attenuation_factor;
		iplEffectParams.spatialBlend = clamp(params.listener_distance * (params.directional_attenuation_factor / fully_spatialized_distance), 0.0f, 1.0f);
		while (totalFramesProcessed < totalFramesToProcess) {
			ma_uint32 framesToProcessThisIteration = totalFramesToProcess - totalFramesProcessed;
			if (framesToProcessThisIteration > (ma_uint32)g_phonon_audio_settings.frameSize) framesToProcessThisIteration = (ma_uint32)g_phonon_audio_settings.frameSize;
			inputBuffer.numSamples = framesToProcessThisIteration;
			outputBuffer.numSamples = framesToProcessThisIteration;
			iplAudioBufferDeinterleave(g_phonon_context, (float*)ma_offset_pcm_frames_const_ptr_f32(frames_in[0], totalFramesProcessed, inputBuffer.numChannels), &inputBuffer);
			iplBinauralEffectApply(iplEffect, &iplEffectParams, &inputBuffer, &outputBuffer);
			iplAudioBufferInterleave(g_phonon_context, &outputBuffer, ma_offset_pcm_frames_ptr_f32(frames_out[0], totalFramesProcessed, 2));
			totalFramesProcessed += framesToProcessThisIteration;
		}
		return;
		fail:
			ma_copy_pcm_frames(frames_out[0], frames_in[0], *frame_count_in, ma_format_f32, get_engine()->get_channels());
	}
};
spatializer_component_node* phonon_hrtf_panner::create(audio_spatializer* spatializer, audio_engine* engine) { return new phonon_hrtf_panner_impl(spatializer, engine); }

class basic_attenuator_impl : public spatializer_component_node_impl, public virtual basic_attenuator {
	ma_gainer gainer;
public:
	basic_attenuator_impl(audio_spatializer* spatializer, audio_engine* e) : spatializer_component_node_impl(spatializer, e) {
		ma_gainer_config gainer_config = ma_gainer_config_init(e->get_channels(), 1.0f);
		if (ma_gainer_init(&gainer_config, nullptr, &gainer) != MA_SUCCESS) {
			throw std::runtime_error("Failed to initialize gainer");
		}
	}
	~basic_attenuator_impl() {
		destroy_node();
		ma_gainer_uninit(&gainer, nullptr);
	}
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		float distance = 0, volume = 0;
		ma_uint32 frameCount = *frame_count_out;
		if (!spatializer) goto fail;
		audio_spatialization_parameters params;
		if (!spatializer->get_parameters(params)) goto fail;
		distance = params.listener_distance;
		if (distance >= params.min_distance) distance -= params.min_distance;
		volume = clamp(distance <= params.max_distance - params.min_distance? ma_volume_db_to_linear(-distance * params.rolloff * 1.75) : 0, params.min_volume, params.max_volume);
		ma_gainer_set_master_volume(&gainer, volume);
		if (frameCount > *frame_count_in) frameCount = *frame_count_in;
		ma_gainer_process_pcm_frames(&gainer, frames_out[0], frames_in[0], frameCount);
		return;
		fail:
			ma_copy_pcm_frames(frames_out[0], frames_in[0], *frame_count_in, ma_format_f32, get_engine()->get_channels());
	}
};
spatializer_component_node* basic_attenuator::create(audio_spatializer* spatializer, audio_engine* engine) { return new basic_attenuator_impl(spatializer, engine); }

class phonon_attenuator_impl : public spatializer_component_node_impl, public virtual phonon_attenuator {
	IPLDirectEffect iplEffect;
	IPLDirectEffectParams iplEffectParams;
	IPLAudioBuffer inputBuffer;
	IPLAudioBuffer outputBuffer;
	IPLDistanceAttenuationModel distanceModel;
	IPLAirAbsorptionModel airAbsorptionModel;
public:
	phonon_attenuator_impl(audio_spatializer* spatializer, audio_engine* e) : spatializer_component_node_impl(spatializer, e), iplEffect(nullptr) {
		if (!phonon_init()) throw std::runtime_error("Steam Audio initialization failed");
		distanceModel = {};
		distanceModel.type = IPL_DISTANCEATTENUATIONTYPE_INVERSEDISTANCE;
		distanceModel.minDistance = 1.0f;
		airAbsorptionModel = {};
		airAbsorptionModel.type = IPL_AIRABSORPTIONTYPE_DEFAULT;
		IPLDirectEffectSettings effectSettings{};
		effectSettings.numChannels = e->get_channels();
		iplEffectParams = {};
		iplEffectParams.flags = static_cast<IPLDirectEffectFlags>(IPL_DIRECTEFFECTFLAGS_APPLYDISTANCEATTENUATION | IPL_DIRECTEFFECTFLAGS_APPLYAIRABSORPTION);
		iplEffectParams.directivity = 1.0f;
		if (iplDirectEffectCreate(g_phonon_context, &g_phonon_audio_settings, &effectSettings, &iplEffect) != IPL_STATUS_SUCCESS) throw std::runtime_error("Failed to create direct effect");
		ma_uint32 channelsIn = e->get_channels();
		if (iplAudioBufferAllocate(g_phonon_context, channelsIn, g_phonon_audio_settings.frameSize, &inputBuffer) != IPL_STATUS_SUCCESS) {
			iplDirectEffectRelease(&iplEffect);
			throw std::runtime_error("Failed to allocate input audio buffer");
		}
		if (iplAudioBufferAllocate(g_phonon_context, channelsIn, g_phonon_audio_settings.frameSize, &outputBuffer) != IPL_STATUS_SUCCESS) {
			iplAudioBufferFree(g_phonon_context, &inputBuffer);
			iplDirectEffectRelease(&iplEffect);
			throw std::runtime_error("Failed to allocate output audio buffer");
		}
	}
	~phonon_attenuator_impl() {
		destroy_node();
		if (iplEffect) iplDirectEffectRelease(&iplEffect);
		iplAudioBufferFree(g_phonon_context, &inputBuffer);
		iplAudioBufferFree(g_phonon_context, &outputBuffer);
	}
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		IPLVector3 sourcePos, listenerPos;
		ma_uint32 totalFramesToProcess = *frame_count_out;
		ma_uint32 totalFramesProcessed = 0;
		if (!spatializer || !iplEffect) goto fail;
		audio_spatialization_parameters params;
		if (!spatializer->get_parameters(params)) goto fail;
		distanceModel.minDistance = params.min_distance;
		distanceModel.type = IPL_DISTANCEATTENUATIONTYPE_INVERSEDISTANCE;
		params.rolloff *= 0.7; // Attenuators apply internal factors sometimes to try making it so that rolloff at a constant value will cause a similar volume reduction regardless of the attenuator in use.
		sourcePos = {params.sound_x * params.rolloff, params.sound_y * params.rolloff, params.sound_z * params.rolloff};
		listenerPos = {params.listener_x * params.rolloff, params.listener_y * params.rolloff, params.listener_z * params.rolloff};
		iplEffectParams.distanceAttenuation = params.listener_distance <= params.max_distance? clamp(iplDistanceAttenuationCalculate(g_phonon_context, sourcePos, listenerPos, &distanceModel), params.min_volume, params.max_volume) : params.min_volume;
		iplAirAbsorptionCalculate(g_phonon_context, sourcePos, listenerPos, &airAbsorptionModel, iplEffectParams.airAbsorption);
		while (totalFramesProcessed < totalFramesToProcess) {
			ma_uint32 framesToProcessThisIteration = totalFramesToProcess - totalFramesProcessed;
			if (framesToProcessThisIteration > (ma_uint32)g_phonon_audio_settings.frameSize) framesToProcessThisIteration = (ma_uint32)g_phonon_audio_settings.frameSize;
			inputBuffer.numSamples = framesToProcessThisIteration;
			outputBuffer.numSamples = framesToProcessThisIteration;
			iplAudioBufferDeinterleave(g_phonon_context, (float*)ma_offset_pcm_frames_const_ptr_f32(frames_in[0], totalFramesProcessed, inputBuffer.numChannels), &inputBuffer);
			iplDirectEffectApply(iplEffect, &iplEffectParams, &inputBuffer, &outputBuffer);
			iplAudioBufferInterleave(g_phonon_context, &outputBuffer, ma_offset_pcm_frames_ptr_f32(frames_out[0], totalFramesProcessed, outputBuffer.numChannels));
			totalFramesProcessed += framesToProcessThisIteration;
		}
		return;
		fail:
			ma_copy_pcm_frames(frames_out[0], frames_in[0], *frame_count_in, ma_format_f32, get_engine()->get_channels());
	}
};
spatializer_component_node* phonon_attenuator::create(audio_spatializer* spatializer, audio_engine* engine) { return new phonon_attenuator_impl(spatializer, engine); }
