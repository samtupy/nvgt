/* sound_environment.cpp - Steam Audio scene simulation (occlusion, transmission and reflections) for 3d sounds
 * The design follows Steam Audio's own engine integrations. Every sound or mixer created by or attached to a sound_environment is sent through the environment's reverb3d, whose attachment handler gives each of them a sound_environment_source node. That node applies the simulated occlusion and transmission to the sound's dry signal, and sends the sound to a per source reflection effect that accumulates into a reflection mixer shared by the whole environment, like the spatialize effect of the FMOD integration. The reverb3d's reverb node is the environment's return node, which applies the reflection mixer and decodes the resulting ambisonic sound field once for all sources, like the FMOD integration's mix return effect.
 * Simulation is scheduled like the Unity integration: sound_environment::update, called by the script each frame, runs the cheap direct simulation (occlusion and transmission) on the script thread and periodically hands the expensive reflection simulation to a worker thread, while changes to the simulator such as adding or removing sources are only made when that thread is idle. The scene is a Steam Audio custom scene that traces rays through an nvgt_raycast_provider such as a physics_world, so Steam Audio's own simulation threads and the provider (Jolt's narrow phase queries for physics_world) work in parallel.
 * This file only uses public NVGT interfaces and talks to Steam Audio through the object interfaces in phonon_interfaces.h, so that it could be moved into a plugin that receives the Steam Audio context from NVGT.
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

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include <condition_variable>
#include <cstddef>
#include <cstring>
#include <mutex>
#include <thread>
#include <vector>
#include <angelscript.h>
#include <scripthandle.h>
#include "nvgt.h"
#include "nvgt_plugin.h"
#include "sound.h"
#include "sound_nodes.h"
#include "sound_environment.h"
#define STEAMAUDIO_SKIP_API_FUNCTIONS
#include <phonon_interfaces.h>

using namespace std;

static_assert(sizeof(nvgt_acoustic_material) == sizeof(IPLMaterial) && offsetof(nvgt_acoustic_material, scattering) == offsetof(IPLMaterial, scattering) && offsetof(nvgt_acoustic_material, transmission) == offsetof(IPLMaterial, transmission), "nvgt_acoustic_material must be laid out like IPLMaterial");
static_assert(sizeof(nvgt_ray) == sizeof(IPLRay) && offsetof(nvgt_ray, direction) == offsetof(IPLRay, direction), "nvgt_ray must be laid out like IPLRay");
static_assert(sizeof(nvgt_ray_hit) == sizeof(IPLHit) && offsetof(nvgt_ray_hit, normal) == offsetof(IPLHit, normal) && offsetof(nvgt_ray_hit, material) == offsetof(IPLHit, material), "nvgt_ray_hit must be laid out like IPLHit");

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
	void clear() { for (int i = 0; i < b.numChannels; i++) memset(b.data[i], 0, b.numSamples * sizeof(float)); }
};

static IPLSpeakerLayout speaker_layout_for_channels(int channels) {
	IPLSpeakerLayout layout{};
	layout.type = channels == 1 ? IPL_SPEAKERLAYOUTTYPE_MONO : channels == 4 ? IPL_SPEAKERLAYOUTTYPE_QUADRAPHONIC : channels == 6 ? IPL_SPEAKERLAYOUTTYPE_SURROUND_5_1 : channels == 8 ? IPL_SPEAKERLAYOUTTYPE_SURROUND_7_1 : IPL_SPEAKERLAYOUTTYPE_STEREO;
	return layout;
}
static inline int ambisonic_channels(int order) { return (order + 1) * (order + 1); }
// The configuration the audio thread's effects are created with, published by the script thread whenever the simulator is rebuilt. It is packed into one atomic value so that the audio thread can never see a mix of old and new values.
struct audio_config {
	unsigned int generation = 0;
	int type = IPL_REFLECTIONEFFECTTYPE_CONVOLUTION, order = 1, ir_size = 1;
	unsigned long long pack() const { return (unsigned long long)generation << 32 | (unsigned long long)(ir_size & 0xffffff) << 8 | (order & 0xf) << 4 | (type & 0xf); }
	static audio_config unpack(unsigned long long v) { return {(unsigned int)(v >> 32), (int)(v & 0xf), (int)(v >> 4 & 0xf), (int)(v >> 8 & 0xffffff)}; }
	int channels() const { return ambisonic_channels(order); }
};

// Scene callbacks forwarding Steam Audio's ray queries to the environment's raycast provider. The structures are binary compatible, see the static_asserts above.
class empty_raycast_provider : public nvgt_raycast_provider { // Used when an environment has no raycaster, making the scene empty.
public:
	void retain() override {}
	void release() override {}
	void closest_hits(int count, const nvgt_ray* rays, const float* min_distances, const float* max_distances, nvgt_ray_hit* hits) override { for (int i = 0; i < count; i++) hits[i] = {INFINITY, -1, -1, -1, {0, 0, 0}, nullptr}; }
	void any_hits(int count, const nvgt_ray* rays, const float* min_distances, const float* max_distances, unsigned char* occluded) override { for (int i = 0; i < count; i++) occluded[i] = max_distances[i] <= min_distances[i] ? 1 : 0; }
};
static empty_raycast_provider g_empty_raycast_provider;
static void IPLCALL scene_closest_hit(const IPLRay* ray, IPLfloat32 min_distance, IPLfloat32 max_distance, IPLHit* hit, void* provider) { static_cast<nvgt_raycast_provider*>(provider)->closest_hits(1, reinterpret_cast<const nvgt_ray*>(ray), &min_distance, &max_distance, reinterpret_cast<nvgt_ray_hit*>(hit)); }
static void IPLCALL scene_any_hit(const IPLRay* ray, IPLfloat32 min_distance, IPLfloat32 max_distance, IPLuint8* occluded, void* provider) { static_cast<nvgt_raycast_provider*>(provider)->any_hits(1, reinterpret_cast<const nvgt_ray*>(ray), &min_distance, &max_distance, occluded); }
static void IPLCALL scene_batched_closest_hit(IPLint32 count, const IPLRay* rays, const IPLfloat32* min_distances, const IPLfloat32* max_distances, IPLHit* hits, void* provider) { static_cast<nvgt_raycast_provider*>(provider)->closest_hits(count, reinterpret_cast<const nvgt_ray*>(rays), min_distances, max_distances, reinterpret_cast<nvgt_ray_hit*>(hits)); }
static void IPLCALL scene_batched_any_hit(IPLint32 count, const IPLRay* rays, const IPLfloat32* min_distances, const IPLfloat32* max_distances, IPLuint8* occluded, void* provider) { static_cast<nvgt_raycast_provider*>(provider)->any_hits(count, reinterpret_cast<const nvgt_ray*>(rays), min_distances, max_distances, occluded); }

enum sound_environment_reflection_type { reflections_convolution = IPL_REFLECTIONEFFECTTYPE_CONVOLUTION, reflections_parametric = IPL_REFLECTIONEFFECTTYPE_PARAMETRIC, reflections_hybrid = IPL_REFLECTIONEFFECTTYPE_HYBRID };
enum sound_environment_occlusion_type { occlusion_raycast = IPL_OCCLUSIONTYPE_RAYCAST, occlusion_volumetric = IPL_OCCLUSIONTYPE_VOLUMETRIC };

class environment_source;

// A Steam Audio source shared between the script thread, which owns the simulation side of it, and the audio thread, which reads its outputs. The script thread publishes a new source by retaining it once for each thread, the audio thread takes over its reference before its next use.
struct source_slot {
	api::ISource* script = nullptr;
	atomic<api::ISource*> pending = nullptr;
	api::ISource* audio = nullptr;
	void publish(api::ISource* s) { // Script thread.
		if (script) script->release();
		script = s;
		if (s) {
			s->retain();
			s->retain();
		}
		if (api::ISource* old = pending.exchange(s)) old->release();
	}
	api::ISource* take() { // Audio thread.
		if (api::ISource* p = pending.exchange(nullptr)) {
			if (audio) audio->release();
			audio = p;
		}
		return audio;
	}
	api::ISource* detach_script() { // Hands over the script thread's reference.
		api::ISource* s = script;
		script = nullptr;
		return s;
	}
	~source_slot() {
		if (script) script->release();
		if (api::ISource* p = pending.exchange(nullptr)) p->release();
		if (audio) audio->release();
	}
};

// State shared by a sound_environment, its sources and its return node. Members marked as audio thread state are only touched from the thread processing the environment's audio engine, everything published from the script thread to the audio thread is atomic.
class environment_core {
	atomic<int> refcount = 1;
public:
	audio_engine* engine;
	api::IContext* context;
	IPLAudioSettings audio_settings;
	ipl_ref<api::IHRTF> hrtf;
	int channels;
	// Settings, set from the script thread. Changing those that the simulators or the audio effects are created with causes them to be rebuilt. The defaults are Unity's, except that fewer rays with many more bounces are traced for a similar cost, as the length of the reverb tail depends on the number of bounces while Steam Audio averages out the noise of fewer rays across simulations.
	atomic<int> reflection_type = reflections_convolution;
	atomic<int> rays = 2048, bounces = 32, order = 1, max_sources = 32, threads, diffuse_samples = 32, max_occlusion_samples = 16;
	atomic<float> duration = 1.0f, irradiance_min_distance = 1.0f, interval = 0.1f, hybrid_transition_time = 1.0f, hybrid_overlap = 0.25f;
	atomic<bool> use_reflection_mixer = true, binaural = true, use_listener_reverb = true;
	atomic<float> reflections_level = 1.0f;
	atomic<unsigned long long> published_config = audio_config().pack(); // Audio effects are recreated when its generation changes.
	// Listener orientation for ambisonic decoding, published by update.
	mutex listener_mutex;
	IPLCoordinateSpace3 listener{{1, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 0, 0}};
	// Reverb simulated at the listener's position, which sources use until their own reflections have been simulated so that new sounds, footsteps for example, reverberate immediately.
	source_slot listener_source;
	atomic<unsigned int> listener_ready_at = 0;
	// Audio thread state.
	api::IReflectionMixer* audio_mixer = nullptr; // Owned by the return node.
	unsigned int audio_mixer_generation = 0; // Sources only write into the mixer if it was created for the same configuration as their effects.
	IPLCoordinateSpace3 audio_listener{{1, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 0, 0}};
	ipl_buffer listener_send; // Mono sum of the sources sent to the listener reverb this audio pass, applied by the return node.
	bool listener_send_active = false;
	unsigned int listener_reverb_generation = 0; // The configuration generation the return node's listener reverb is ready for, 0 if it isn't.
	// Simulation state, owned by the script thread. The reflection simulator is also used by the worker thread while it runs reflections, during which it can't be changed, so direct simulation (occlusion and transmission) has a simulator of its own that new sources can always be added to straight away.
	ipl_ref<api::IScene> scene;
	ipl_ref<api::ISimulator> simulator, direct_simulator;
	nvgt_raycast_provider* provider = nullptr; // Retained, the raycaster the next scene will use.
	nvgt_raycast_provider* scene_provider = nullptr; // Retained for as long as the current scene, which may still be in use by a simulation, refers to it.
	bool rebuild_needed = true, scene_needed = true;
	mutex sources_mutex; // Guards the following, as sources can be released from any thread.
	vector<environment_source*> sources;
	vector<environment_source*> retired; // Sources released while their reverb tail was still playing, owned here until it finishes.
	vector<api::ISource*> removed_sources, removed_direct_sources; // Retained sources whose nodes were destroyed, removed from their simulators later.
	thread worker;
	mutex worker_mutex;
	condition_variable worker_cv;
	bool worker_run = false, worker_stop = false;
	atomic<bool> worker_busy = false;
	atomic<unsigned int> reflection_runs = 0; // Completed reflection simulations, the run scheduled next is number reflection_runs + 1.
	chrono::steady_clock::time_point last_reflections;
	bool shut_down = false;

	environment_core(audio_engine* e) : engine(e), context(reinterpret_cast<api::IContext*>(phonon_get_context())), channels(e->get_channels()) {
		engine->duplicate();
		context->retain();
		audio_settings = {(IPLint32)engine->get_sample_rate(), SOUNDSYSTEM_FRAMESIZE};
		threads = max(1, (int)thread::hardware_concurrency() / 2);
		if (phonon_get_audio_settings().samplingRate == audio_settings.samplingRate) hrtf.reset(reinterpret_cast<api::IHRTF*>(phonon_get_hrtf())->retain());
		else {
			IPLHRTFSettings hrtf_settings{};
			hrtf_settings.type = IPL_HRTFTYPE_DEFAULT;
			hrtf_settings.volume = 1.0f;
			context->createHRTF(&audio_settings, &hrtf_settings, hrtf.put());
		}
		listener_send.allocate(context, 1, audio_settings.frameSize);
		listener_send.clear();
	}
	~environment_core() {
		shutdown();
		for (api::ISource* s : removed_sources) s->release();
		for (api::ISource* s : removed_direct_sources) s->release();
		listener_source.publish(nullptr);
		simulator.reset();
		direct_simulator.reset();
		scene.reset();
		if (provider) provider->release();
		if (scene_provider) scene_provider->release();
		hrtf.reset();
		context->release();
		engine->release();
	}
	void retain() { refcount++; }
	void release() { if (--refcount < 1) delete this; }
	void shutdown() {
		if (shut_down) return;
		shut_down = true;
		{
			lock_guard<mutex> l(worker_mutex);
			worker_stop = true;
		}
		worker_cv.notify_all();
		if (worker.joinable()) worker.join();
	}
	void worker_loop() {
		unique_lock<mutex> l(worker_mutex);
		while (true) {
			worker_cv.wait(l, [this] { return worker_run || worker_stop; });
			if (worker_stop) break;
			worker_run = false;
			l.unlock();
			simulator->runReflections();
			reflection_runs++;
			worker_busy = false;
			l.lock();
		}
	}
	void set_provider(nvgt_raycast_provider* p) { // Takes ownership of a retained provider.
		if (provider) provider->release();
		provider = p;
		scene_needed = true;
	}
	void add_source(environment_source* s) {
		lock_guard<mutex> l(sources_mutex);
		sources.push_back(s);
	}
	void retire_sources(api::ISource* simulated, api::ISource* direct) {
		lock_guard<mutex> l(sources_mutex);
		if (simulated) removed_sources.push_back(simulated); // The node's references are handed over and released once the sources are removed from their simulators.
		if (direct) removed_direct_sources.push_back(direct);
	}
	void release_retired(bool all);
	bool rebuild();
	void attach_new_sources(bool idle);
	void update();
};

// The node every sound attached to an environment is sent through, published to scripts as sound_environment_source. Bus 0 carries the sound's dry signal with occlusion and transmission applied, bus 1 is the send to the environment's reverb3d, which is silent while the reflection mixer or listener reverb is in use as those are applied by the environment's return node.
class environment_source : public effect_node_impl, public virtual splitter_node {
	// Audio thread state.
	audio_config config;
	ipl_ref<api::IDirectEffect> direct_effect;
	ipl_ref<api::IReflectionEffect> reflection_effect;
	ipl_ref<api::IAmbisonicsDecodeEffect> decode_effect;
	ipl_buffer in_buffer, out_buffer, mono_buffer, ambisonics_buffer, decoded_buffer;
	float previous_level = 0.0f;
public:
	environment_core* core;
	source_slot reflection_source, direct_source;
	atomic<unsigned int> ready_at = 0; // The reflection simulation after which this source's own reflections are available, 0 if none has been scheduled yet.
	atomic<bool> has_position = false, tail_remaining = false;
	atomic<bool> direct_ready = false; // Whether the direct source has been simulated, before which its outputs read as fully occluded, muting the start of new sounds when their first audio was processed before the simulation.
	atomic<float> x = 0.0f, y = 0.0f, z = 0.0f;
	bool retired = false; // Guarded by the core's sources_mutex.
	chrono::steady_clock::time_point retired_at;
	// Settings.
	atomic<bool> apply_occlusion = true, apply_transmission = true, apply_reflections = true;
	atomic<float> reflections_level = 1.0f, occlusion_radius = 1.0f;
	atomic<int> occlusion_type = occlusion_raycast, occlusion_samples = 16, transmission_rays = 3;
	// Simulation results, copied after each direct simulation for scripts to read.
	atomic<bool> simulated = false;
	atomic<float> occlusion = 1.0f, transmission[3] = {1.0f, 1.0f, 1.0f}, reverb_times[3] = {0.0f, 0.0f, 0.0f};

	environment_source(environment_core* core) : effect_node_impl(core->engine, 0, 0, 1, 2, MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT), core(core) {
		core->retain();
		set_output_bus_volume(1, 1.0f);
		core->add_source(this);
	}
	~environment_source() {
		destroy_node(); // Stop processing before tearing down audio state.
		core->retire_sources(reflection_source.detach_script(), direct_source.detach_script());
		core->release();
	}
	void release() override { // The environment's update duplicates its sources while holding sources_mutex, so a source must leave that list under the same lock before it can be deleted, or update could revive one whose last reference is being released. A source whose reflections are still ringing out is kept alive by the environment until they finish.
		environment_core* c = core;
		{
			lock_guard<mutex> l(c->sources_mutex);
			if (asAtomicDec(refcount) > 0) return;
			c->sources.erase(std::remove(c->sources.begin(), c->sources.end(), this), c->sources.end());
			if (!retired && tail_remaining && !c->shut_down) {
				retired = true;
				retired_at = chrono::steady_clock::now();
				asAtomicInc(refcount);
				c->retired.push_back(this);
				return;
			}
		}
		delete this;
	}
	bool own_reflections_ready() const {
		unsigned int at = ready_at;
		return at && core->reflection_runs >= at;
	}
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		// Always produce every requested frame, treating missing input as silence, so that reflection tails continue after the sound stops.
		const unsigned int frames = *frame_count_out, channels = core->channels;
		const unsigned int available = frames_in && frames_in[0] ? min(*frame_count_in, frames) : 0; // With MA_NODE_FLAG_ALLOW_NULL_INPUT the input array itself is null once nothing is attached, as for a retired source finishing its reverb tail.
		float* dry = frames_out[0];
		float* send = frames_out[1];
		if (available) memcpy(dry, frames_in[0], available * channels * sizeof(float)); // The input is processed in place in the dry output, each chunk being read before it is written.
		if (available < frames) memset(dry + available * channels, 0, (frames - available) * channels * sizeof(float));
		const float* in = dry;
		memset(send, 0, frames * channels * sizeof(float));
		api::ISource* direct = direct_source.take();
		api::ISource* reflections_src = reflection_source.take();
		if (!direct || !prepare(frames)) return;
		api::IContext* ctx = core->context;
		const int frame_size = core->audio_settings.frameSize;
		const bool own_ready = reflections_src && own_reflections_ready();
		for (unsigned int offset = 0; offset < frames; offset += frame_size) {
			const int n = (int)min<unsigned int>(frame_size, frames - offset);
			in_buffer.b.numSamples = out_buffer.b.numSamples = n;
			ctx->deinterleaveAudioBuffer(const_cast<float*>(in) + offset * core->channels, &in_buffer.b);
			// Dry path: occlusion and transmission.
			IPLSimulationOutputs outputs{};
			direct->getOutputs(IPL_SIMULATIONFLAGS_DIRECT, &outputs);
			IPLDirectEffectParams direct_params = outputs.direct;
			direct_params.flags = (IPLDirectEffectFlags)((apply_occlusion ? IPL_DIRECTEFFECTFLAGS_APPLYOCCLUSION : 0) | (apply_occlusion && apply_transmission ? IPL_DIRECTEFFECTFLAGS_APPLYTRANSMISSION : 0));
			direct_params.transmissionType = IPL_TRANSMISSIONTYPE_FREQDEPENDENT;
			if (direct_params.flags && direct_ready) {
				direct_effect->apply(&direct_params, &in_buffer.b, &out_buffer.b);
				ctx->interleaveAudioBuffer(&out_buffer.b, dry + offset * core->channels);
			}
			// Reflections, only on whole Steam Audio frames as the reflection mixer and listener reverb accumulate exactly one frame per source per audio graph pass.
			if (!apply_reflections || n != frame_size) continue;
			api::IReflectionMixer* mixer = core->audio_mixer_generation == config.generation ? core->audio_mixer : nullptr; // While the return node hasn't caught up with a new configuration this source decodes its own reflections.
			bool silent = true; // A stopped or retired sound, whose input may still be attached but silent. Steam Audio's effects only count their tails down through getTail, as apply keeps reporting a tail for as long as it's called, and skipping silence entirely once the tail is over saves the convolution.
			for (int c = 0; c < in_buffer.b.numChannels && silent; c++) for (int i = 0; i < n; i++) if (in_buffer.b.data[c][i] != 0.0f) {
				silent = false;
				break;
			}
			if (silent) {
				if (!own_ready || !tail_remaining) continue;
				IPLAudioEffectState state = reflection_effect->getTail(&ambisonics_buffer.b, mixer);
				if (!mixer) {
					IPLAmbisonicsDecodeEffectParams decode{config.order, reinterpret_cast<IPLHRTF>(core->hrtf.get()), core->audio_listener, core->binaural && core->channels == 2 ? IPL_TRUE : IPL_FALSE};
					decode_effect->apply(&decode, &ambisonics_buffer.b, &decoded_buffer.b);
					ctx->interleaveAudioBuffer(&decoded_buffer.b, send + offset * core->channels);
				}
				tail_remaining = state == IPL_AUDIOEFFECTSTATE_TAILREMAINING;
				continue;
			}
			ctx->downmixAudioBuffer(&in_buffer.b, &mono_buffer.b);
			float level = reflections_level * core->reflections_level;
			for (int i = 0; i < n; i++) mono_buffer.b.data[0][i] *= previous_level + (level - previous_level) * (i / (float)n); // Ramp level changes to avoid clicks.
			previous_level = level;
			if (!own_ready) { // Until this source's own reflections have been simulated, it is heard with the reverb at the listener's position.
				if (core->use_listener_reverb && core->listener_reverb_generation == config.generation) {
					for (int i = 0; i < n; i++) core->listener_send.b.data[0][i] += mono_buffer.b.data[0][i];
					core->listener_send_active = true;
				}
				continue;
			}
			reflections_src->getOutputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &outputs);
			IPLReflectionEffectParams reflections = outputs.reflections;
			reflections.type = (IPLReflectionEffectType)config.type;
			reflections.numChannels = config.channels();
			reflections.irSize = config.ir_size;
			IPLAudioEffectState state = reflection_effect->apply(&reflections, &mono_buffer.b, &ambisonics_buffer.b, mixer);
			if (!mixer) {
				IPLAmbisonicsDecodeEffectParams decode{config.order, reinterpret_cast<IPLHRTF>(core->hrtf.get()), core->audio_listener, core->binaural && core->channels == 2 ? IPL_TRUE : IPL_FALSE};
				if (decode_effect->apply(&decode, &ambisonics_buffer.b, &decoded_buffer.b) == IPL_AUDIOEFFECTSTATE_TAILREMAINING) state = IPL_AUDIOEFFECTSTATE_TAILREMAINING;
				ctx->interleaveAudioBuffer(&decoded_buffer.b, send + offset * core->channels);
			}
			tail_remaining = state == IPL_AUDIOEFFECTSTATE_TAILREMAINING;
		}
	}
	bool prepare(unsigned int frames) { // Creates or recreates the audio thread's effects when the environment's configuration changed.
		audio_config c = audio_config::unpack(core->published_config);
		if (c.generation == config.generation && direct_effect) return true;
		config.generation = 0; // Invalid until everything is created.
		tail_remaining = false;
		api::IContext* ctx = core->context;
		IPLAudioSettings settings = core->audio_settings;
		int order = c.order, ambisonics = c.channels();
		IPLDirectEffectSettings direct_settings{core->channels};
		IPLReflectionEffectSettings reflection_settings{(IPLReflectionEffectType)c.type, c.ir_size, ambisonics};
		IPLAmbisonicsDecodeEffectSettings decode_settings{speaker_layout_for_channels(core->channels), reinterpret_cast<IPLHRTF>(core->hrtf.get()), order};
		if (!direct_effect && ctx->createDirectEffect(&settings, &direct_settings, direct_effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (ctx->createReflectionEffect(&settings, &reflection_settings, reflection_effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (ctx->createAmbisonicsDecodeEffect(&settings, &decode_settings, decode_effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (!in_buffer.allocate(ctx, core->channels, settings.frameSize) || !out_buffer.allocate(ctx, core->channels, settings.frameSize) || !mono_buffer.allocate(ctx, 1, settings.frameSize) || !ambisonics_buffer.allocate(ctx, ambisonics, settings.frameSize) || !decoded_buffer.allocate(ctx, core->channels, settings.frameSize)) return false;
		config = c;
		return true;
	}
	void update_position(const audio_spatialization_parameters& params) {
		x = params.sound_x;
		y = params.sound_y;
		z = params.sound_z;
		has_position = true;
	}
	IPLSimulationInputs inputs(IPLSimulationFlags flags) const {
		IPLSimulationInputs in{};
		in.flags = flags;
		in.directFlags = (IPLDirectSimulationFlags)(IPL_DIRECTSIMULATIONFLAGS_OCCLUSION | IPL_DIRECTSIMULATIONFLAGS_TRANSMISSION);
		in.source = {{1, 0, 0}, {0, 0, 1}, {0, 1, 0}, {x, y, z}};
		in.distanceAttenuationModel.type = IPL_DISTANCEATTENUATIONTYPE_DEFAULT;
		in.airAbsorptionModel.type = IPL_AIRABSORPTIONTYPE_DEFAULT;
		in.occlusionType = (IPLOcclusionType)occlusion_type.load();
		in.occlusionRadius = occlusion_radius;
		in.numOcclusionSamples = min<int>(occlusion_samples, core->max_occlusion_samples);
		in.numTransmissionRays = transmission_rays;
		in.reverbScale[0] = in.reverbScale[1] = in.reverbScale[2] = 1.0f;
		in.hybridReverbTransitionTime = core->hybrid_transition_time;
		in.hybridReverbOverlapPercent = core->hybrid_overlap;
		return in;
	}
	void read_results() { // Script thread, after a direct simulation.
		IPLSimulationOutputs out{};
		if (direct_source.script) {
			direct_source.script->getOutputs(IPL_SIMULATIONFLAGS_DIRECT, &out);
			occlusion = out.direct.occlusion;
			for (int i = 0; i < 3; i++) transmission[i] = out.direct.transmission[i];
			simulated = true;
		}
		if (reflection_source.script) {
			reflection_source.script->getOutputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &out);
			for (int i = 0; i < 3; i++) reverb_times[i] = out.reflections.reverbTimes[i];
		}
	}
	// Script accessors.
	bool get_apply_occlusion() const { return apply_occlusion; }
	void set_apply_occlusion(bool v) { apply_occlusion = v; }
	bool get_apply_transmission() const { return apply_transmission; }
	void set_apply_transmission(bool v) { apply_transmission = v; }
	bool get_apply_reflections() const { return apply_reflections; }
	void set_apply_reflections(bool v) { apply_reflections = v; }
	float get_reflections_level() const { return reflections_level; }
	void set_reflections_level(float v) { reflections_level = max(0.0f, v); }
	int get_occlusion_type() const { return occlusion_type; }
	void set_occlusion_type(int v) { occlusion_type = v == occlusion_volumetric ? occlusion_volumetric : occlusion_raycast; }
	float get_occlusion_radius() const { return occlusion_radius; }
	void set_occlusion_radius(float v) { occlusion_radius = max(0.0f, v); }
	int get_occlusion_samples() const { return occlusion_samples; }
	void set_occlusion_samples(int v) { occlusion_samples = clamp(v, 1, 1024); }
	int get_transmission_rays() const { return transmission_rays; }
	void set_transmission_rays(int v) { transmission_rays = clamp(v, 1, 64); }
	bool get_simulated() const { return simulated; }
	bool get_reflections_simulated() const { return own_reflections_ready(); }
	float get_occlusion() const { return occlusion; }
	float get_transmission(int band) const { return band >= 0 && band < 3 ? transmission[band].load() : 0.0f; }
	float get_reverb_time(int band) const { return band >= 0 && band < 3 ? reverb_times[band].load() : 0.0f; }
};

void environment_core::release_retired(bool all) { // Script thread. Releases retired sources whose reverb tails have finished, or all of them.
	vector<environment_source*> done;
	{
		lock_guard<mutex> l(sources_mutex);
		auto now = chrono::steady_clock::now();
		for (auto it = retired.begin(); it != retired.end();) {
			environment_source* s = *it;
			if (all || !s->tail_remaining || chrono::duration<float>(now - s->retired_at).count() > duration + 1.0f) { // The time limit is a safety net should the audio thread stop processing the source.
				done.push_back(s);
				it = retired.erase(it);
			} else ++it;
		}
	}
	for (environment_source* s : done) s->release(); // Retired sources are deleted on their final release.
}
static ipl_ref<api::ISimulator>& create_simulator(api::IContext* context, IPLSimulationSettings& settings, ipl_ref<api::ISimulator>& out) {
	if (context->createSimulator(&settings, out.put()) != IPL_STATUS_SUCCESS) out.reset();
	return out;
}
bool environment_core::rebuild() { // Script thread, only while the worker is idle.
	vector<environment_source*> current;
	{
		lock_guard<mutex> l(sources_mutex);
		current = sources;
		for (api::ISource* s : removed_sources) s->release(); // The old simulators are going away with them.
		for (api::ISource* s : removed_direct_sources) s->release();
		removed_sources.clear();
		removed_direct_sources.clear();
		for (environment_source* s : current) {
			s->reflection_source.publish(nullptr);
			s->direct_source.publish(nullptr);
			s->direct_ready = false;
			s->ready_at = 0;
		}
	}
	listener_source.publish(nullptr);
	listener_ready_at = 0;
	if (scene_needed || !scene) {
		IPLSceneSettings scene_settings{};
		scene_settings.type = IPL_SCENETYPE_CUSTOM;
		scene_settings.closestHitCallback = scene_closest_hit;
		scene_settings.anyHitCallback = scene_any_hit;
		scene_settings.batchedClosestHitCallback = scene_batched_closest_hit;
		scene_settings.batchedAnyHitCallback = scene_batched_any_hit;
		scene_settings.userData = provider ? provider : &g_empty_raycast_provider;
		if (context->createScene(&scene_settings, scene.put()) != IPL_STATUS_SUCCESS) return false;
		if (provider) provider->retain();
		if (scene_provider) scene_provider->release();
		scene_provider = provider;
		scene->commit();
		scene_needed = false;
	}
	IPLSimulationSettings settings{};
	settings.flags = IPL_SIMULATIONFLAGS_REFLECTIONS;
	settings.sceneType = IPL_SCENETYPE_CUSTOM;
	settings.reflectionType = (IPLReflectionEffectType)reflection_type.load();
	settings.maxNumOcclusionSamples = max_occlusion_samples;
	settings.maxNumRays = rays;
	settings.numDiffuseSamples = diffuse_samples;
	settings.maxDuration = duration;
	settings.maxOrder = order;
	settings.maxNumSources = max_sources + 1; // Including the listener reverb.
	settings.numThreads = threads;
	settings.rayBatchSize = 16;
	settings.samplingRate = audio_settings.samplingRate;
	settings.frameSize = audio_settings.frameSize;
	if (!create_simulator(context, settings, simulator)) return false;
	settings.flags = IPL_SIMULATIONFLAGS_DIRECT;
	settings.numThreads = 1;
	if (!create_simulator(context, settings, direct_simulator)) return false;
	simulator->setScene(scene.get());
	direct_simulator->setScene(scene.get());
	simulator->commit();
	direct_simulator->commit();
	audio_config c = audio_config::unpack(published_config);
	c.generation++;
	c.type = reflection_type;
	c.order = order;
	c.ir_size = max(1, (int)ceil(duration * audio_settings.samplingRate));
	published_config = c.pack();
	rebuild_needed = false;
	return true;
}
void environment_core::attach_new_sources(bool idle) { // Script thread. Direct sources can always be attached, reflection sources only while the worker is idle.
	bool direct_changed = false, reflections_changed = false;
	vector<api::ISource*> removed, removed_direct;
	{
		lock_guard<mutex> l(sources_mutex);
		removed_direct.swap(removed_direct_sources);
		if (idle) removed.swap(removed_sources);
		for (environment_source* s : sources) {
			if (!s->direct_source.script) {
				IPLSourceSettings source_settings{IPL_SIMULATIONFLAGS_DIRECT};
				api::ISource* created = nullptr;
				if (direct_simulator->createSource(&source_settings, &created) == IPL_STATUS_SUCCESS) {
					created->add(direct_simulator.get());
					s->direct_ready = false;
					s->direct_source.publish(created);
					created->release();
					direct_changed = true;
				}
			}
			if (idle && !s->reflection_source.script) {
				IPLSourceSettings source_settings{IPL_SIMULATIONFLAGS_REFLECTIONS};
				api::ISource* created = nullptr;
				if (simulator->createSource(&source_settings, &created) == IPL_STATUS_SUCCESS) {
					created->add(simulator.get());
					s->reflection_source.publish(created);
					created->release();
					reflections_changed = true;
				}
			}
		}
	}
	if (idle && !listener_source.script) {
		IPLSourceSettings source_settings{IPL_SIMULATIONFLAGS_REFLECTIONS};
		api::ISource* created = nullptr;
		if (simulator->createSource(&source_settings, &created) == IPL_STATUS_SUCCESS) {
			created->add(simulator.get());
			listener_source.publish(created);
			created->release();
			reflections_changed = true;
		}
	}
	for (api::ISource* s : removed_direct) {
		s->remove(direct_simulator.get());
		s->release();
		direct_changed = true;
	}
	for (api::ISource* s : removed) {
		s->remove(simulator.get());
		s->release();
		reflections_changed = true;
	}
	if (direct_changed) direct_simulator->commit();
	if (reflections_changed) simulator->commit();
}
void environment_core::update() { // Script thread.
	if (shut_down) return;
	release_retired(false);
	bool idle = !worker_busy;
	if (idle && (rebuild_needed || scene_needed || !simulator)) {
		if (!rebuild()) return;
	}
	if (!simulator || !direct_simulator) return;
	attach_new_sources(idle);
	// The listener, taken from the audio engine's first listener. Steam Audio's coordinate system is right handed, so right is the cross product of ahead and up.
	vector3 pos = engine->get_listener_position(0), ahead = engine->get_listener_direction(0), up = engine->get_listener_world_up(0);
	if (ahead.IsNearZero()) ahead = vector3(0, 1, 0);
	if (up.IsNearZero()) up = vector3(0, 0, 1);
	ahead = ahead.Normalized();
	vector3 right = ahead.Cross(up);
	if (right.IsNearZero()) right = ahead.Cross(vector3(0, 1, 0)).IsNearZero() ? vector3(1, 0, 0) : ahead.Cross(vector3(0, 1, 0));
	right = right.Normalized();
	up = right.Cross(ahead).Normalized();
	IPLCoordinateSpace3 listener_space{{right.GetX(), right.GetY(), right.GetZ()}, {up.GetX(), up.GetY(), up.GetZ()}, {ahead.GetX(), ahead.GetY(), ahead.GetZ()}, {pos.GetX(), pos.GetY(), pos.GetZ()}};
	{
		lock_guard<mutex> l(listener_mutex);
		listener = listener_space;
	}
	IPLSimulationSharedInputs shared{};
	shared.listener = listener_space;
	shared.numRays = rays;
	shared.numBounces = bounces;
	shared.duration = duration;
	shared.order = order;
	shared.irradianceMinDistance = irradiance_min_distance;
	vector<environment_source*> current;
	{
		lock_guard<mutex> l(sources_mutex);
		current = sources;
		for (environment_source* s : current) s->duplicate(); // Keep them alive while we use them without the lock.
	}
	// Direct simulation every update, on its own simulator so that it never waits for reflections.
	direct_simulator->setSharedInputs(IPL_SIMULATIONFLAGS_DIRECT, &shared);
	for (environment_source* s : current) {
		if (!s->direct_source.script || !s->has_position) continue;
		IPLSimulationInputs in = s->inputs(IPL_SIMULATIONFLAGS_DIRECT);
		s->direct_source.script->setInputs(IPL_SIMULATIONFLAGS_DIRECT, &in);
	}
	direct_simulator->runDirect();
	for (environment_source* s : current) {
		if (!s->has_position) continue;
		s->read_results();
		if (s->direct_source.script) s->direct_ready = true;
	}
	// Reflections on the worker thread at the configured interval, inputs can only be changed while it is idle.
	auto now = chrono::steady_clock::now();
	if (idle && chrono::duration<float>(now - last_reflections).count() >= interval) {
		last_reflections = now;
		const unsigned int run = reflection_runs + 1;
		simulator->setSharedInputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &shared);
		bool any = false;
		for (environment_source* s : current) {
			if (!s->reflection_source.script || !s->has_position) continue;
			IPLSimulationInputs in = s->inputs(s->apply_reflections ? IPL_SIMULATIONFLAGS_REFLECTIONS : (IPLSimulationFlags)0);
			s->reflection_source.script->setInputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &in);
			if (!s->ready_at && s->apply_reflections) s->ready_at = run;
			any = true;
		}
		if (listener_source.script && use_listener_reverb) {
			IPLSimulationInputs in{};
			in.flags = IPL_SIMULATIONFLAGS_REFLECTIONS;
			in.source = listener_space;
			in.distanceAttenuationModel.type = IPL_DISTANCEATTENUATIONTYPE_DEFAULT;
			in.airAbsorptionModel.type = IPL_AIRABSORPTIONTYPE_DEFAULT;
			in.reverbScale[0] = in.reverbScale[1] = in.reverbScale[2] = 1.0f;
			in.hybridReverbTransitionTime = hybrid_transition_time;
			in.hybridReverbOverlapPercent = hybrid_overlap;
			listener_source.script->setInputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &in);
			if (!listener_ready_at) listener_ready_at = run;
			any = true;
		}
		if (any) {
			if (!worker.joinable()) worker = thread(&environment_core::worker_loop, this);
			worker_busy = true;
			{
				lock_guard<mutex> l(worker_mutex);
				worker_run = true;
			}
			worker_cv.notify_one();
		}
	}
	for (environment_source* s : current) s->release();
}

// The reverb node of the environment's reverb3d. It applies the listener reverb to the sources sent to it, then the reflection mixer, and decodes the ambisonic result for all sources at once while passing the sends of its input through.
class environment_return : public effect_node_impl {
	environment_core* core;
	audio_config config;
	bool mixer_wanted = false, listener_tail = false;
	ipl_ref<api::IReflectionMixer> mixer;
	ipl_ref<api::IReflectionEffect> listener_effect;
	ipl_ref<api::IAmbisonicsDecodeEffect> decode_effect, listener_decode_effect;
	ipl_buffer ambisonics_buffer, decoded_buffer;
public:
	environment_return(environment_core* core) : effect_node_impl(core->engine, 0, 0, 1, 1, MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT), core(core) { core->retain(); }
	~environment_return() {
		destroy_node();
		core->audio_mixer = nullptr;
		core->audio_mixer_generation = 0;
		core->listener_reverb_generation = 0;
		mixer.reset();
		core->release();
	}
	bool prepare() {
		audio_config c = audio_config::unpack(core->published_config);
		bool want_mixer = core->use_reflection_mixer && c.type == reflections_convolution; // Steam Audio's reflection mixer only implements convolution, parametric and hybrid reflections applied to it are silently dropped, so those are always decoded per source.
		if (c.generation == config.generation && want_mixer == mixer_wanted && (!want_mixer || mixer)) return c.generation != 0;
		core->audio_mixer = nullptr;
		core->audio_mixer_generation = 0;
		core->listener_reverb_generation = 0;
		mixer.reset();
		listener_tail = false;
		mixer_wanted = want_mixer;
		config = c;
		if (!c.generation) return false;
		api::IContext* ctx = core->context;
		int order = c.order, ambisonics = c.channels();
		IPLReflectionEffectSettings effect_settings{(IPLReflectionEffectType)c.type, c.ir_size, ambisonics};
		IPLAmbisonicsDecodeEffectSettings decode_settings{speaker_layout_for_channels(core->channels), reinterpret_cast<IPLHRTF>(core->hrtf.get()), order};
		if (ctx->createReflectionEffect(&core->audio_settings, &effect_settings, listener_effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (ctx->createAmbisonicsDecodeEffect(&core->audio_settings, &decode_settings, decode_effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (ctx->createAmbisonicsDecodeEffect(&core->audio_settings, &decode_settings, listener_decode_effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (!ambisonics_buffer.allocate(ctx, ambisonics, core->audio_settings.frameSize) || !decoded_buffer.allocate(ctx, core->channels, core->audio_settings.frameSize)) return false;
		if (want_mixer) {
			if (ctx->createReflectionMixer(&core->audio_settings, &effect_settings, mixer.put()) != IPL_STATUS_SUCCESS) return false;
			core->audio_mixer = mixer.get();
			core->audio_mixer_generation = c.generation;
		}
		return true;
	}
	void add_decoded(float* out, unsigned int frames) {
		const int channels = core->channels;
		for (unsigned int i = 0; i < frames; i++) for (int c = 0; c < channels; c++) out[i * channels + c] += decoded_buffer.b.data[c][i];
	}
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		const unsigned int frames = *frame_count_out;
		const unsigned int available = frames_in && frames_in[0] ? min(*frame_count_in, frames) : 0; // With MA_NODE_FLAG_ALLOW_NULL_INPUT the input array itself is null once nothing is attached, as for a retired source finishing its reverb tail.
		float* out = frames_out[0];
		if (available) memcpy(out, frames_in[0], available * core->channels * sizeof(float));
		if (available < frames) memset(out + available * core->channels, 0, (frames - available) * core->channels * sizeof(float));
		{
			unique_lock<mutex> l(core->listener_mutex, try_to_lock); // Never block the audio thread, the previous orientation is fine if update holds the lock.
			if (l.owns_lock()) core->audio_listener = core->listener;
		}
		api::ISource* listener = core->listener_source.take();
		bool send_active = core->listener_send_active;
		core->listener_send_active = false;
		if (!prepare() || frames != (unsigned int)core->audio_settings.frameSize) {
			core->listener_send.clear();
			return;
		}
		IPLAmbisonicsDecodeEffectParams decode{config.order, reinterpret_cast<IPLHRTF>(core->hrtf.get()), core->audio_listener, core->binaural && core->channels == 2 ? IPL_TRUE : IPL_FALSE};
		// The listener reverb for sources whose own reflections aren't simulated yet, applied into the reflection mixer when it's in use.
		unsigned int ready_at = core->listener_ready_at;
		bool listener_ready = listener && ready_at && core->reflection_runs >= ready_at;
		core->listener_reverb_generation = listener_ready && core->use_listener_reverb ? config.generation : 0;
		if (listener_ready && (send_active || listener_tail)) {
			IPLSimulationOutputs outputs{};
			listener->getOutputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &outputs);
			IPLReflectionEffectParams params = outputs.reflections;
			params.type = (IPLReflectionEffectType)config.type;
			params.numChannels = config.channels();
			params.irSize = config.ir_size;
			IPLAudioEffectState state = send_active ? listener_effect->apply(&params, &core->listener_send.b, &ambisonics_buffer.b, mixer.get()) : listener_effect->getTail(&ambisonics_buffer.b, mixer.get()); // apply would keep reporting a tail for as long as it's called.
			if (!mixer) {
				if (listener_decode_effect->apply(&decode, &ambisonics_buffer.b, &decoded_buffer.b) == IPL_AUDIOEFFECTSTATE_TAILREMAINING) state = IPL_AUDIOEFFECTSTATE_TAILREMAINING;
				add_decoded(out, frames);
			}
			listener_tail = state == IPL_AUDIOEFFECTSTATE_TAILREMAINING;
		}
		core->listener_send.clear();
		if (!mixer) return;
		IPLReflectionEffectParams params{};
		params.type = (IPLReflectionEffectType)config.type;
		params.numChannels = config.channels();
		params.irSize = config.ir_size;
		mixer->apply(&params, &ambisonics_buffer.b);
		decode_effect->apply(&decode, &ambisonics_buffer.b, &decoded_buffer.b);
		add_decoded(out, frames);
	}
};

class environment_attachment_handler : public reverb3d_attachment_handler {
	environment_core* core;
public:
	environment_attachment_handler(environment_core* core) : core(core) { core->retain(); }
	~environment_attachment_handler() { core->release(); }
	splitter_node* create_attachment(reverb3d* verb, mixer* source) override { return new environment_source(core); }
	void update_attachment(reverb3d* verb, splitter_node* attachment, const audio_spatialization_parameters& params) override { if (environment_source* s = dynamic_cast<environment_source*>(attachment)) s->update_position(params); } // dynamic_cast as splitter_node is a virtual base.
};

// The script facing environment.
class sound_environment {
	atomic<int> refcount = 1;
	environment_core* core;
	reverb3d* verb;
	CScriptHandle raycaster;
public:
	sound_environment(audio_engine* engine) {
		if (!engine) engine = g_audio_engine;
		if (!phonon_init()) throw runtime_error("Steam Audio could not be initialized");
		core = new environment_core(engine);
		environment_return* ret = new environment_return(core);
		verb = reverb3d::create_with_handler(new environment_attachment_handler(core), ret, nullptr, engine);
		ret->release(); // The reverb3d owns it through its output connection.
	}
	~sound_environment() {
		core->shutdown(); // Join the simulation thread here rather than wherever the last source happens to release the core.
		core->release_retired(true); // They hold references to the core, and without the environment nothing would release them.
		verb->release();
		core->release();
	}
	void add_ref() { refcount++; }
	void release() { if (--refcount < 1) delete this; }
	static sound_environment* create(audio_engine* engine) {
		try {
			return new sound_environment(engine);
		} catch (exception& e) {
			if (asIScriptContext* ctx = asGetActiveContext()) ctx->SetException(e.what());
			return nullptr;
		}
	}
	bool set_raycaster(CScriptHandle h) {
		if (!h.GetRef()) {
			raycaster = CScriptHandle();
			core->set_provider(nullptr);
			return true;
		}
		nvgt_raycast_provider* p = nvgt_get_raycast_provider(h.GetRef(), h.GetTypeId());
		if (!p) return false;
		raycaster = h;
		core->set_provider(p);
		return true;
	}
	CScriptHandle get_raycaster() const { return raycaster; }
	bool attach(mixer* m) {
		if (!m) return false;
		m->set_reverb3d_at(verb, prepan); // Before panning so that the sound reaching the source node is the sound itself.
		return m->get_reverb3d() == verb;
	}
	void detach(mixer* m) { if (m && m->get_reverb3d() == verb) m->set_reverb3d(nullptr); }
	sound* new_sound() {
		sound* s = core->engine->new_sound();
		if (s) attach(s);
		return s;
	}
	mixer* new_mixer() {
		mixer* m = core->engine->new_mixer();
		if (m) attach(m);
		return m;
	}
	environment_source* get_source(mixer* m) const {
		if (!m || m->get_reverb3d() != verb) return nullptr;
		environment_source* s = dynamic_cast<environment_source*>(m->get_reverb3d_attachment());
		if (s) s->duplicate();
		return s;
	}
	void update() { core->update(); }
	reverb3d* get_reverb3d() const { return verb; }
	audio_engine* get_engine() const { return core->engine; }
	mixer* get_output_mixer() const { return verb->get_mixer(); }
	void set_output_mixer(mixer* m) { verb->set_mixer(m); }
	unsigned int get_reflection_simulations() const { return core->reflection_runs; }
	bool get_simulating_reflections() const { return core->worker_busy; }
	unsigned int get_source_count() const {
		lock_guard<mutex> l(core->sources_mutex);
		return (unsigned int)core->sources.size();
	}
	// Settings. Those the simulator and audio effects are created with rebuild them at the next update.
	int get_reflection_type() const { return core->reflection_type; }
	void set_reflection_type(int v) { if (v != core->reflection_type && (v == reflections_convolution || v == reflections_parametric || v == reflections_hybrid)) { core->reflection_type = v; core->rebuild_needed = true; } }
	int get_reflection_rays() const { return core->rays; }
	void set_reflection_rays(int v) { v = clamp(v, 1, 1 << 16); if (v != core->rays) { core->rays = v; core->rebuild_needed = true; } }
	float get_reflection_duration() const { return core->duration; }
	void set_reflection_duration(float v) { v = clamp(v, 0.1f, 10.0f); if (v != core->duration) { core->duration = v; core->rebuild_needed = true; } }
	int get_reflection_order() const { return core->order; }
	void set_reflection_order(int v) { v = clamp(v, 0, 3); if (v != core->order) { core->order = v; core->rebuild_needed = true; } }
	int get_reflection_bounces() const { return core->bounces; }
	void set_reflection_bounces(int v) { core->bounces = clamp(v, 1, 64); }
	int get_max_sources() const { return core->max_sources; }
	void set_max_sources(int v) { v = clamp(v, 1, 1024); if (v != core->max_sources) { core->max_sources = v; core->rebuild_needed = true; } }
	int get_simulation_threads() const { return core->threads; }
	void set_simulation_threads(int v) { v = clamp(v, 1, 64); if (v != core->threads) { core->threads = v; core->rebuild_needed = true; } }
	int get_diffuse_samples() const { return core->diffuse_samples; }
	void set_diffuse_samples(int v) { v = clamp(v, 1, 4096); if (v != core->diffuse_samples) { core->diffuse_samples = v; core->rebuild_needed = true; } }
	float get_irradiance_min_distance() const { return core->irradiance_min_distance; }
	void set_irradiance_min_distance(float v) { core->irradiance_min_distance = max(0.01f, v); }
	float get_simulation_interval() const { return core->interval; }
	void set_simulation_interval(float v) { core->interval = max(0.0f, v); }
	float get_hybrid_transition_time() const { return core->hybrid_transition_time; }
	void set_hybrid_transition_time(float v) { core->hybrid_transition_time = max(0.0f, v); }
	float get_hybrid_overlap() const { return core->hybrid_overlap; }
	void set_hybrid_overlap(float v) { core->hybrid_overlap = clamp(v, 0.0f, 1.0f); }
	bool get_use_listener_reverb() const { return core->use_listener_reverb; }
	void set_use_listener_reverb(bool v) { core->use_listener_reverb = v; }
	unsigned int get_retired_source_count() const {
		lock_guard<mutex> l(core->sources_mutex);
		return (unsigned int)core->retired.size();
	}
	bool get_use_reflection_mixer() const { return core->use_reflection_mixer; }
	void set_use_reflection_mixer(bool v) { core->use_reflection_mixer = v; }
	bool get_binaural() const { return core->binaural; }
	void set_binaural(bool v) { core->binaural = v; }
	float get_reflections_level() const { return core->reflections_level; }
	void set_reflections_level(float v) { core->reflections_level = max(0.0f, v); }
};

// Scripts can't implicitly convert a sound handle to a mixer handle, so the functions taking either are also registered for sounds.
static bool environment_attach_sound(sound_environment* env, sound* s) { return env->attach(s); }
static void environment_detach_sound(sound_environment* env, sound* s) { env->detach(s); }
static environment_source* environment_get_sound_source(const sound_environment* env, sound* s) { return env->get_source(s); }
template <class T, float (T::*getter)(int) const, int band> static float band_getter(const T* obj) { return (obj->*getter)(band); }
// environment_source has virtual bases, and Angelscript can't call through pointers to members of such classes on every compiler, so its methods are registered through these.
template <auto method, typename R, typename... Args> static R source_call(environment_source* s, Args... args) { return (s->*method)(args...); }
static void source_add_ref(environment_source* s) { s->duplicate(); }
static void source_release(environment_source* s) { s->release(); }

void RegisterSoundEnvironment(asIScriptEngine* engine) {
	engine->RegisterEnum("sound_environment_reflection_type");
	engine->RegisterEnumValue("sound_environment_reflection_type", "SOUND_ENVIRONMENT_REFLECTIONS_CONVOLUTION", reflections_convolution);
	engine->RegisterEnumValue("sound_environment_reflection_type", "SOUND_ENVIRONMENT_REFLECTIONS_PARAMETRIC", reflections_parametric);
	engine->RegisterEnumValue("sound_environment_reflection_type", "SOUND_ENVIRONMENT_REFLECTIONS_HYBRID", reflections_hybrid);
	engine->RegisterEnum("sound_environment_occlusion_type");
	engine->RegisterEnumValue("sound_environment_occlusion_type", "SOUND_ENVIRONMENT_OCCLUSION_RAYCAST", occlusion_raycast);
	engine->RegisterEnumValue("sound_environment_occlusion_type", "SOUND_ENVIRONMENT_OCCLUSION_VOLUMETRIC", occlusion_volumetric);
	// sound_environment_source is only obtained from an environment, so it has no factory.
	engine->RegisterObjectType("sound_environment_source", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("sound_environment_source", asBEHAVE_ADDREF, "void f()", asFUNCTION(source_add_ref), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("sound_environment_source", asBEHAVE_RELEASE, "void f()", asFUNCTION(source_release), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "bool get_apply_occlusion() const property", asFUNCTION((source_call<&environment_source::get_apply_occlusion, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_apply_occlusion(bool enabled) property", asFUNCTION((source_call<&environment_source::set_apply_occlusion, void, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "bool get_apply_transmission() const property", asFUNCTION((source_call<&environment_source::get_apply_transmission, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_apply_transmission(bool enabled) property", asFUNCTION((source_call<&environment_source::set_apply_transmission, void, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "bool get_apply_reflections() const property", asFUNCTION((source_call<&environment_source::get_apply_reflections, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_apply_reflections(bool enabled) property", asFUNCTION((source_call<&environment_source::set_apply_reflections, void, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_reflections_level() const property", asFUNCTION((source_call<&environment_source::get_reflections_level, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_reflections_level(float level) property", asFUNCTION((source_call<&environment_source::set_reflections_level, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "sound_environment_occlusion_type get_occlusion_type() const property", asFUNCTION((source_call<&environment_source::get_occlusion_type, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_occlusion_type(sound_environment_occlusion_type type) property", asFUNCTION((source_call<&environment_source::set_occlusion_type, void, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_occlusion_radius() const property", asFUNCTION((source_call<&environment_source::get_occlusion_radius, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_occlusion_radius(float radius) property", asFUNCTION((source_call<&environment_source::set_occlusion_radius, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "int get_occlusion_samples() const property", asFUNCTION((source_call<&environment_source::get_occlusion_samples, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_occlusion_samples(int samples) property", asFUNCTION((source_call<&environment_source::set_occlusion_samples, void, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "int get_transmission_rays() const property", asFUNCTION((source_call<&environment_source::get_transmission_rays, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_transmission_rays(int rays) property", asFUNCTION((source_call<&environment_source::set_transmission_rays, void, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "bool get_simulated() const property", asFUNCTION((source_call<&environment_source::get_simulated, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "bool get_reflections_simulated() const property", asFUNCTION((source_call<&environment_source::get_reflections_simulated, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_occlusion() const property", asFUNCTION((source_call<&environment_source::get_occlusion, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_transmission_low() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_transmission, 0>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_transmission_mid() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_transmission, 1>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_transmission_high() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_transmission, 2>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_reverb_time_low() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_reverb_time, 0>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_reverb_time_mid() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_reverb_time, 1>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_reverb_time_high() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_reverb_time, 2>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectType("sound_environment", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("sound_environment", asBEHAVE_FACTORY, "sound_environment@ f(audio_engine@+ engine = sound_default_engine)", asFUNCTION(sound_environment::create), asCALL_CDECL);
	engine->RegisterObjectBehaviour("sound_environment", asBEHAVE_ADDREF, "void f()", asMETHOD(sound_environment, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("sound_environment", asBEHAVE_RELEASE, "void f()", asMETHOD(sound_environment, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool set_raycaster(ref@ raycaster)", asMETHOD(sound_environment, set_raycaster), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "ref@ get_raycaster() const property", asMETHOD(sound_environment, get_raycaster), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "sound@ new_sound()", asMETHOD(sound_environment, new_sound), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "mixer@ new_mixer()", asMETHOD(sound_environment, new_mixer), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool attach(mixer@+ sound_or_mixer)", asMETHOD(sound_environment, attach), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "void detach(mixer@+ sound_or_mixer)", asMETHOD(sound_environment, detach), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "sound_environment_source@ get_source(mixer@+ sound_or_mixer) const", asMETHOD(sound_environment, get_source), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool attach(sound@+ snd)", asFUNCTION(environment_attach_sound), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment", "void detach(sound@+ snd)", asFUNCTION(environment_detach_sound), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment", "sound_environment_source@ get_source(sound@+ snd) const", asFUNCTION(environment_get_sound_source), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment", "void update()", asMETHOD(sound_environment, update), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "reverb3d@+ get_reverb3d() const property", asMETHOD(sound_environment, get_reverb3d), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "audio_engine@+ get_engine() const property", asMETHOD(sound_environment, get_engine), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "mixer@+ get_output_mixer() const property", asMETHOD(sound_environment, get_output_mixer), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "void set_output_mixer(mixer@+ mix) property", asMETHOD(sound_environment, set_output_mixer), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "uint get_reflection_simulations() const property", asMETHOD(sound_environment, get_reflection_simulations), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool get_simulating_reflections() const property", asMETHOD(sound_environment, get_simulating_reflections), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "uint get_source_count() const property", asMETHOD(sound_environment, get_source_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "uint get_retired_source_count() const property", asMETHOD(sound_environment, get_retired_source_count), asCALL_THISCALL);
	#define ENV_PROPERTY(type, name) \
		engine->RegisterObjectMethod("sound_environment", #type " get_" #name "() const property", asMETHOD(sound_environment, get_##name), asCALL_THISCALL); \
		engine->RegisterObjectMethod("sound_environment", "void set_" #name "(" #type " value) property", asMETHOD(sound_environment, set_##name), asCALL_THISCALL);
	ENV_PROPERTY(sound_environment_reflection_type, reflection_type)
	ENV_PROPERTY(int, reflection_rays)
	ENV_PROPERTY(float, reflection_duration)
	ENV_PROPERTY(int, reflection_order)
	ENV_PROPERTY(int, reflection_bounces)
	ENV_PROPERTY(int, max_sources)
	ENV_PROPERTY(int, simulation_threads)
	ENV_PROPERTY(int, diffuse_samples)
	ENV_PROPERTY(float, irradiance_min_distance)
	ENV_PROPERTY(float, simulation_interval)
	ENV_PROPERTY(float, hybrid_transition_time)
	ENV_PROPERTY(float, hybrid_overlap)
	ENV_PROPERTY(bool, use_reflection_mixer)
	ENV_PROPERTY(bool, use_listener_reverb)
	ENV_PROPERTY(bool, binaural)
	ENV_PROPERTY(float, reflections_level)
	#undef ENV_PROPERTY
}
