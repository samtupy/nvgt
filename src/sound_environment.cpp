/* sound_environment.cpp - Steam Audio scene simulation (occlusion, transmission and reflections) for 3d sounds
 * The design follows Steam Audio's own engine integrations. Every sound or mixer created by or attached to a sound_environment is sent through the environment's reverb3d, whose attachment handler gives each of them a sound_environment_source node. That node applies the simulated occlusion and transmission to the sound's dry signal, like the spatialize effect of the FMOD integration. Reflections are simulated for a limited pool of reflection groups rather than for every sound: each sound adds its signal to the group nearest to it (see reflection_group), and the reverb3d's reverb node, the environment's return node, applies each group's reflection effect into a reflection mixer shared by the whole environment and decodes the resulting ambisonic sound field once, like the FMOD integration's mix return effect.
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

// A simulated reflection source shared by every sound near its position. Sounds don't convolve their own reflections: each adds its mono signal to the input of the group it belongs to, and the return node applies one reflection effect per group, so the cost of reflections depends on the number of groups rather than the number of sounds, and a sound that ends simply stops adding to its group while the group's reverb tail rings on. The environment keeps a pool of max_sources groups and assigns sounds to them every update, nearest sounds first. Sounds farther from the listener share groups over larger distances, and when every group is taken, sounds join the nearest group they can or the listener's group, whose reflections are simulated at the listener's position.
struct reflection_group {
	// Script thread state.
	source_slot source; // A Steam Audio reflections source, simulated at the group's position while it has members.
	atomic<unsigned int> ready_at = 0; // The reflection simulation after which the group's reflections match its position, 0 if none has been scheduled since it was moved.
	float x = 0.0f, y = 0.0f, z = 0.0f; // The simulated position, the centroid of the members.
	float sum_x = 0.0f, sum_y = 0.0f, sum_z = 0.0f, nearest = 0.0f; // Gathered while assigning sounds. nearest is the distance from the listener of the nearest member, which decides which group gives way when a nearer sound needs one.
	int members = 0;
	atomic<unsigned int> placement = 0; // Raised whenever the group is moved to a new place, so that the audio thread clears its effect of the old place's sound.
	atomic<bool> ringing = false; // Whether the group had input or a reverb tail at the last audio pass, so that groups are preferably not reused until their tails end.
	// Audio thread state.
	unsigned int audio_placement = 0;
	audio_config config;
	ipl_ref<api::IReflectionEffect> effect;
	ipl_ref<api::IAmbisonicsDecodeEffect> decode;
	ipl_buffer send; // Mono sum of the members' signals this audio pass.
	bool send_active = false, tail = false;
	bool ready(unsigned int runs) const {
		unsigned int at = ready_at;
		return at && runs >= at;
	}
	void place(float px, float py, float pz) { // Script thread, moves the group to where a new member is.
		x = px;
		y = py;
		z = pz;
		ready_at = 0;
		placement++;
	}
};
static constexpr int MAX_REFLECTION_GROUPS = 1024;

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
	atomic<int> rays = 2048, bounces = 32, order = 1, max_sources = 16, threads, diffuse_samples = 32, max_occlusion_samples = 16;
	atomic<float> duration = 1.0f, irradiance_min_distance = 1.0f, interval = 0.1f, hybrid_transition_time = 1.0f, hybrid_overlap = 0.25f;
	atomic<float> reflection_grouping = 0.25f; // Sounds within this fraction of their distance from the listener of each other can share a reflection group.
	atomic<bool> use_reflection_mixer = true, binaural = true, use_listener_reverb = true;
	atomic<float> reflections_level = 0.5f, reflections_width = 4.0f, reflections_highpass = 160.0f; // Toned down from physically accurate levels and widened from Steam Audio's binaural decoding, which tends to sound overpowering and narrow in games.
	atomic<unsigned long long> published_config = audio_config().pack(); // Audio effects are recreated when its generation changes.
	// Listener orientation for ambisonic decoding, published by update.
	mutex listener_mutex;
	IPLCoordinateSpace3 listener{{1, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 0, 0}};
	// Reflection groups. Groups are created as max_sources grows and live as long as the environment, so sources and the audio thread can refer to them without counting references. The listener's group is used by sounds without a group of their own, so that new sounds, footsteps for example, reverberate straight away.
	reflection_group listener_group;
	reflection_group* groups[MAX_REFLECTION_GROUPS] = {};
	atomic<int> group_count = 0; // Groups are published to the audio thread by storing the pointer before raising the count.
	atomic<int> active_groups = 0;
	// Probes, at which reverb and the paths sound takes between them can be baked ahead of time. Steam Audio can't list the probes of a batch, so their spheres are kept to know whether the listener is among them and to rebuild the batch when probes change, which discards its baked data. Script thread state.
	vector<IPLSphere> probe_spheres;
	ipl_ref<api::IProbeBatch> probes;
	bool baked_reverb = false, baked_paths = false;
	atomic<bool> use_baked_reverb = true, pathing = false;
	atomic<float> pathing_level = 1.0f, pathing_time = 0.0f;
	ipl_ref<api::ISimulator> path_simulator; // Only while pathing is enabled and paths are baked.
	// Audio thread state.
	api::IReflectionMixer* audio_mixer = nullptr; // Owned by the return node.
	IPLCoordinateSpace3 audio_listener{{1, 0, 0}, {0, 0, 1}, {0, 1, 0}, {0, 0, 0}};
	// Simulation state, owned by the script thread. The reflection simulator is also used by the worker thread while it runs reflections, during which it can't be changed, so direct simulation (occlusion and transmission) has a simulator of its own that new sources can always be added to straight away.
	ipl_ref<api::IScene> scene;
	ipl_ref<api::ISimulator> simulator, direct_simulator;
	nvgt_raycast_provider* provider = nullptr; // Retained, the raycaster the next scene will use.
	nvgt_raycast_provider* scene_provider = nullptr; // Retained for as long as the current scene, which may still be in use by a simulation, refers to it.
	bool rebuild_needed = true, scene_needed = true;
	mutex sources_mutex; // Guards the following, as sources can be released from any thread.
	vector<environment_source*> sources;
	vector<api::ISource*> removed_direct_sources, removed_path_sources; // Retained sources whose nodes were destroyed, removed from their simulators by the next update.
	thread worker;
	mutex worker_mutex;
	condition_variable worker_cv;
	bool worker_run = false, worker_stop = false;
	atomic<bool> worker_busy = false;
	atomic<unsigned int> reflection_runs = 0; // Completed reflection simulations, the run scheduled next is number reflection_runs + 1.
	atomic<float> reflection_time = 0, direct_time = 0; // Milliseconds the most recent reflection and direct simulations took.
	chrono::steady_clock::time_point last_reflections, last_pathing;
	bool shut_down = false;

	environment_core(audio_engine* e) : engine(e), context(phonon_get_context()), channels(e->get_channels()) {
		engine->duplicate();
		context->retain();
		audio_settings = {(IPLint32)engine->get_sample_rate(), SOUNDSYSTEM_FRAMESIZE};
		threads = max(1, (int)thread::hardware_concurrency() / 2);
		if (phonon_get_audio_settings().samplingRate == audio_settings.samplingRate) hrtf.reset(phonon_get_hrtf()->retain());
		else {
			IPLHRTFSettings hrtf_settings{};
			hrtf_settings.type = IPL_HRTFTYPE_DEFAULT;
			hrtf_settings.volume = 1.0f;
			context->createHRTF(&audio_settings, &hrtf_settings, hrtf.put());
		}
		listener_group.send.allocate(context, 1, audio_settings.frameSize);
		listener_group.send.clear();
	}
	~environment_core() {
		shutdown();
		for (api::ISource* s : removed_direct_sources) s->release();
		for (api::ISource* s : removed_path_sources) s->release();
		for (int i = 0; i < group_count; i++) delete groups[i];
		listener_group.source.publish(nullptr);
		simulator.reset();
		direct_simulator.reset();
		path_simulator.reset();
		probes.reset();
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
			auto start = chrono::steady_clock::now();
			simulator->runReflections();
			reflection_time = chrono::duration<float, milli>(chrono::steady_clock::now() - start).count();
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
	void remove_sources(api::ISource* direct, api::ISource* path) { // The node's references are handed over and released once the sources are removed from their simulators.
		lock_guard<mutex> l(sources_mutex);
		if (direct) removed_direct_sources.push_back(direct);
		if (path) removed_path_sources.push_back(path);
	}
	void wait_until_idle() { // Script thread, for changes that can't be made while the worker simulates reflections.
		while (worker_busy) this_thread::sleep_for(chrono::milliseconds(1));
	}
	bool listener_among_probes(float x, float y, float z) const {
		for (const IPLSphere& p : probe_spheres) if ((x - p.center.x) * (x - p.center.x) + (y - p.center.y) * (y - p.center.y) + (z - p.center.z) * (z - p.center.z) <= p.radius * p.radius) return true;
		return false;
	}
	bool visible(float ax, float ay, float az, float bx, float by, float bz) { // Script thread, whether nothing blocks the straight line between two points.
		if (!provider) return true;
		float dx = bx - ax, dy = by - ay, dz = bz - az, length = sqrt(dx * dx + dy * dy + dz * dz);
		if (length < 0.001f) return true;
		nvgt_ray ray{{ax, ay, az}, {dx / length, dy / length, dz / length}};
		float min_distance = 0.0f;
		unsigned char occluded = 0;
		provider->any_hits(1, &ray, &min_distance, &length, &occluded);
		return !occluded;
	}
	bool ensure_scene();
	bool rebuild_probes();
	bool rebuild();
	void attach_new_sources();
	void assign_groups(const vector<environment_source*>& current, float lx, float ly, float lz);
	void update();
};

// The node every sound attached to an environment is sent through, published to scripts as sound_environment_source. Bus 0 carries the sound's dry signal with occlusion and transmission applied. The sound's reflections are applied by its reflection group in the environment's return node, so bus 1, the send to the environment's reverb3d, only carries the sound's pathing, which the path effect has already spatialized.
class environment_source : public effect_node_impl, public virtual splitter_node {
	// Audio thread state.
	audio_config config;
	ipl_ref<api::IDirectEffect> direct_effect;
	ipl_buffer in_buffer, out_buffer, mono_buffer;
	float previous_level = 0.0f;
	reflection_group* sending = nullptr; // The group this source's signal is added to, which changes with a crossfade over one frame.
	ipl_ref<api::IPathEffect> path_effect; // Created once pathing is first used.
	float previous_path_weight = 0.0f;
	bool path_tail = false;
public:
	environment_core* core;
	source_slot direct_source, path_source;
	atomic<bool> has_position = false;
	atomic<bool> direct_ready = false; // Whether the direct source has been simulated, before which its outputs read as fully occluded, muting the start of new sounds when their first audio was processed before the simulation.
	atomic<float> x = 0.0f, y = 0.0f, z = 0.0f;
	atomic<float> min_distance = 0.0f, max_distance = 0.0f, min_volume = 0.0f, max_volume = 1.0f, rolloff = 1.0f; // The sound's distance attenuation settings, for pathing.
	reflection_group* assigned = nullptr; // Script thread, the source's reflection group or null for the listener's.
	atomic<reflection_group*> group = nullptr; // assigned, published to the audio thread.
	// Settings.
	atomic<bool> apply_occlusion = true, apply_transmission = true, apply_reflections = true, apply_pathing = true;
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
		core->remove_sources(direct_source.detach_script(), path_source.detach_script());
		core->release();
	}
	void release() override { // The environment's update duplicates its sources while holding sources_mutex, so a source must leave that list under the same lock before it can be deleted, or update could revive one whose last reference is being released.
		environment_core* c = core;
		{
			lock_guard<mutex> l(c->sources_mutex);
			if (asAtomicDec(refcount) > 0) return;
			c->sources.erase(std::remove(c->sources.begin(), c->sources.end(), this), c->sources.end());
		}
		delete this;
	}
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		const unsigned int frames = *frame_count_out, channels = core->channels;
		const unsigned int available = frames_in && frames_in[0] ? min(*frame_count_in, frames) : 0; // With MA_NODE_FLAG_ALLOW_NULL_INPUT the input array itself is null once nothing is attached.
		float* dry = frames_out[0];
		if (available) memcpy(dry, frames_in[0], available * channels * sizeof(float)); // The input is processed in place in the dry output, each chunk being read before it is written.
		if (available < frames) memset(dry + available * channels, 0, (frames - available) * channels * sizeof(float));
		memset(frames_out[1], 0, frames * channels * sizeof(float));
		api::ISource* direct = direct_source.take();
		api::ISource* path = path_source.take();
		if (!direct || !prepare()) return;
		api::IContext* ctx = core->context;
		const int frame_size = core->audio_settings.frameSize;
		const unsigned int runs = core->reflection_runs;
		reflection_group* target = group.load();
		if (!target || !target->ready(runs)) target = core->use_listener_reverb && core->listener_group.ready(runs) ? &core->listener_group : nullptr; // Until a group's reflections have been simulated where it is, its members are heard with the listener's.
		if (!apply_reflections) target = nullptr;
		for (unsigned int offset = 0; offset < frames; offset += frame_size) {
			const int n = (int)min<unsigned int>(frame_size, frames - offset);
			in_buffer.b.numSamples = out_buffer.b.numSamples = n;
			ctx->deinterleaveAudioBuffer(dry + offset * channels, &in_buffer.b);
			// Dry path: occlusion and transmission.
			IPLSimulationOutputs outputs{};
			direct->getOutputs(IPL_SIMULATIONFLAGS_DIRECT, &outputs);
			IPLDirectEffectParams direct_params = outputs.direct;
			direct_params.flags = (IPLDirectEffectFlags)((apply_occlusion ? IPL_DIRECTEFFECTFLAGS_APPLYOCCLUSION : 0) | (apply_occlusion && apply_transmission ? IPL_DIRECTEFFECTFLAGS_APPLYTRANSMISSION : 0));
			direct_params.transmissionType = IPL_TRANSMISSIONTYPE_FREQDEPENDENT;
			if (direct_params.flags && direct_ready) {
				direct_effect->apply(&direct_params, &in_buffer.b, &out_buffer.b);
				ctx->interleaveAudioBuffer(&out_buffer.b, dry + offset * channels);
			}
			if (n != frame_size) continue; // Steam Audio's effects can only be applied to whole frames.
			if (path && (path_tail || core->pathing)) apply_path(path, direct_params.occlusion, frames_out[1] + offset * channels);
			// Reflections, applied by each group to exactly one frame per audio graph pass.
			reflection_group* previous = sending;
			sending = target;
			if (!target && !previous) continue;
			bool silent = true; // Skipping silence saves the downmix, the groups ring on by themselves.
			for (int c = 0; c < in_buffer.b.numChannels && silent; c++) for (int i = 0; i < n; i++) if (in_buffer.b.data[c][i] != 0.0f) {
				silent = false;
				break;
			}
			if (silent) continue;
			ctx->downmixAudioBuffer(&in_buffer.b, &mono_buffer.b);
			float level = reflections_level * core->reflections_level;
			const float* mono = mono_buffer.b.data[0];
			if (previous == target) { // Ramp level changes to avoid clicks.
				float* send = target->send.b.data[0];
				for (int i = 0; i < n; i++) send[i] += mono[i] * (previous_level + (level - previous_level) * (i / (float)n));
				target->send_active = true;
			} else { // Crossfade from the previous group to the new one.
				if (previous) {
					float* send = previous->send.b.data[0];
					for (int i = 0; i < n; i++) send[i] += mono[i] * previous_level * (1.0f - i / (float)n);
					previous->send_active = true;
				}
				if (target) {
					float* send = target->send.b.data[0];
					for (int i = 0; i < n; i++) send[i] += mono[i] * level * (i / (float)n);
					target->send_active = true;
				}
			}
			previous_level = level;
		}
	}
	void apply_path(api::ISource* path, float occlusion, float* out) { // Sound reaching the listener around obstacles. Steam Audio's paths include the direct path whenever the source is in view, which the dry signal already carries, so pathing is heard in proportion to how much the direct sound is occluded.
		api::IContext* ctx = core->context;
		const int n = core->audio_settings.frameSize;
		float weight = core->pathing && apply_pathing && apply_occlusion && direct_ready ? (1.0f - occlusion) * core->pathing_level * 3.5449f : 0.0f; // Steam Audio's path coefficients are normalized spherical harmonics, whose omnidirectional term of 1 / sqrt(4 pi) leaves the path effect 11dB quieter than the dry sound of a source at the same distance.
		if (weight <= 0.0f && previous_path_weight <= 0.0f && !path_tail) return;
		if (!path_effect) {
			IPLPathEffectSettings settings{1, IPL_TRUE, speaker_layout_for_channels(core->channels), reinterpret_cast<IPLHRTF>(core->hrtf.get())};
			if (ctx->createPathEffect(&core->audio_settings, &settings, path_effect.put()) != IPL_STATUS_SUCCESS) return;
		}
		IPLSimulationOutputs outputs{};
		path->getOutputs(IPL_SIMULATIONFLAGS_PATHING, &outputs);
		IPLPathEffectParams params = outputs.pathing;
		params.order = 1;
		params.binaural = core->binaural && core->channels == 2 ? IPL_TRUE : IPL_FALSE;
		params.hrtf = reinterpret_cast<IPLHRTF>(core->hrtf.get());
		params.listener = core->audio_listener;
		params.normalizeEQ = IPL_FALSE;
		IPLAudioEffectState state;
		if (weight > 0.0f || previous_path_weight > 0.0f) {
			ctx->downmixAudioBuffer(&in_buffer.b, &mono_buffer.b);
			for (int i = 0; i < n; i++) mono_buffer.b.data[0][i] *= previous_path_weight + (weight - previous_path_weight) * (i / (float)n);
			state = path_effect->apply(&params, &mono_buffer.b, &out_buffer.b);
		} else state = path_effect->getTail(&out_buffer.b);
		previous_path_weight = weight;
		path_tail = state == IPL_AUDIOEFFECTSTATE_TAILREMAINING;
		ctx->interleaveAudioBuffer(&out_buffer.b, out);
	}
	bool prepare() { // Creates or recreates the audio thread's effects when the environment's configuration changed.
		audio_config c = audio_config::unpack(core->published_config);
		if (c.generation == config.generation && direct_effect) return true;
		config.generation = 0; // Invalid until everything is created.
		api::IContext* ctx = core->context;
		IPLAudioSettings settings = core->audio_settings;
		IPLDirectEffectSettings direct_settings{core->channels};
		if (!direct_effect && ctx->createDirectEffect(&settings, &direct_settings, direct_effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (!in_buffer.allocate(ctx, core->channels, settings.frameSize) || !out_buffer.allocate(ctx, core->channels, settings.frameSize) || !mono_buffer.allocate(ctx, 1, settings.frameSize)) return false;
		config = c;
		return true;
	}
	void update_position(const audio_spatialization_parameters& params) {
		x = params.sound_x;
		y = params.sound_y;
		z = params.sound_z;
		min_distance = params.min_distance;
		max_distance = params.max_distance;
		min_volume = params.min_volume;
		max_volume = params.max_volume;
		rolloff = params.rolloff;
		has_position = true;
	}
	static float IPLCALL distance_attenuation(IPLfloat32 distance, void* user) { // Pathed sound is attenuated over the length of its path like NVGT's attenuators attenuate a dry sound over the same distance, rather than by Steam Audio's own physical model.
		const environment_source* s = static_cast<const environment_source*>(user);
		const float min_d = s->min_distance, max_d = s->max_distance, min_v = s->min_volume, max_v = s->max_volume;
		if (get_global_hrtf()) { // The phonon attenuator, inverse distance over positions scaled by its rolloff.
			if (distance > max_d) return min_v;
			return clamp(1.0f / max(distance * s->rolloff * 0.7f, max(min_d, 0.0001f)), min_v, max_v);
		}
		float d = distance >= min_d ? distance - min_d : distance; // The basic attenuator, decibels per meter.
		return clamp(d <= max_d - min_d ? ma_volume_db_to_linear(-d * s->rolloff * 1.75f) : 0.0f, min_v, max_v);
	}
	IPLSimulationInputs direct_inputs() const {
		IPLSimulationInputs in{};
		in.flags = IPL_SIMULATIONFLAGS_DIRECT;
		in.directFlags = (IPLDirectSimulationFlags)(IPL_DIRECTSIMULATIONFLAGS_OCCLUSION | IPL_DIRECTSIMULATIONFLAGS_TRANSMISSION);
		in.source = {{1, 0, 0}, {0, 0, 1}, {0, 1, 0}, {x, y, z}};
		in.distanceAttenuationModel.type = IPL_DISTANCEATTENUATIONTYPE_DEFAULT;
		in.airAbsorptionModel.type = IPL_AIRABSORPTIONTYPE_DEFAULT;
		in.occlusionType = (IPLOcclusionType)occlusion_type.load();
		in.occlusionRadius = occlusion_radius;
		in.numOcclusionSamples = min<int>(occlusion_samples, core->max_occlusion_samples);
		in.numTransmissionRays = transmission_rays;
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
		reflection_group* g = assigned ? assigned : &core->listener_group;
		if (g->source.script && g->ready(core->reflection_runs)) {
			g->source.script->getOutputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &out);
			for (int i = 0; i < 3; i++) reverb_times[i] = out.reflections.reverbTimes[i];
		}
	}
	// Script accessors.
	bool get_apply_occlusion() const { return apply_occlusion; }
	void set_apply_occlusion(bool v) { apply_occlusion = v; }
	bool get_apply_transmission() const { return apply_transmission; }
	void set_apply_transmission(bool v) { apply_transmission = v; }
	bool get_apply_pathing() const { return apply_pathing; }
	void set_apply_pathing(bool v) { apply_pathing = v; }
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
	bool get_reflections_simulated() const { return assigned && assigned->ready(core->reflection_runs); }
	int get_reflection_group() const {
		for (int i = 0; i < core->group_count; i++) if (core->groups[i] == assigned) return i;
		return -1;
	}
	float get_occlusion() const { return occlusion; }
	float get_transmission(int band) const { return band >= 0 && band < 3 ? transmission[band].load() : 0.0f; }
	float get_reverb_time(int band) const { return band >= 0 && band < 3 ? reverb_times[band].load() : 0.0f; }
};

static ipl_ref<api::ISimulator>& create_simulator(api::IContext* context, IPLSimulationSettings& settings, ipl_ref<api::ISimulator>& out) {
	if (context->createSimulator(&settings, out.put()) != IPL_STATUS_SUCCESS) out.reset();
	return out;
}
static api::ISource* create_reflection_source(api::ISimulator* simulator) {
	IPLSourceSettings source_settings{IPL_SIMULATIONFLAGS_REFLECTIONS};
	api::ISource* created = nullptr;
	if (simulator->createSource(&source_settings, &created) != IPL_STATUS_SUCCESS) return nullptr;
	created->add(simulator);
	return created;
}
bool environment_core::ensure_scene() { // Script thread, only while the worker is idle. Creates the scene for the current raycaster.
	if (!scene_needed && scene) return true;
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
	rebuild_needed = true; // The simulators must use the new scene.
	return true;
}
bool environment_core::rebuild_probes() { // Script thread. Makes a new probe batch from probe_spheres, without baked data.
	probes.reset();
	baked_reverb = baked_paths = false;
	rebuild_needed = true;
	if (probe_spheres.empty()) return true;
	if (context->createProbeBatch(probes.put()) != IPL_STATUS_SUCCESS) return false;
	for (const IPLSphere& p : probe_spheres) probes->addProbe(p);
	probes->commit();
	return true;
}
bool environment_core::rebuild() { // Script thread, only while the worker is idle.
	vector<environment_source*> current;
	{
		lock_guard<mutex> l(sources_mutex);
		current = sources;
		for (api::ISource* s : removed_direct_sources) s->release(); // The old simulators are going away with them.
		for (api::ISource* s : removed_path_sources) s->release();
		removed_direct_sources.clear();
		removed_path_sources.clear();
		for (environment_source* s : current) {
			s->direct_source.publish(nullptr);
			s->path_source.publish(nullptr);
			s->direct_ready = false;
		}
	}
	listener_group.source.publish(nullptr);
	listener_group.ready_at = 0;
	for (int i = 0; i < group_count; i++) {
		groups[i]->source.publish(nullptr);
		groups[i]->ready_at = 0;
	}
	if (!ensure_scene()) return false;
	IPLSimulationSettings settings{};
	settings.flags = IPL_SIMULATIONFLAGS_REFLECTIONS;
	settings.sceneType = IPL_SCENETYPE_CUSTOM;
	settings.reflectionType = (IPLReflectionEffectType)reflection_type.load();
	settings.maxNumOcclusionSamples = max_occlusion_samples;
	settings.maxNumRays = rays;
	settings.numDiffuseSamples = diffuse_samples;
	settings.maxDuration = duration;
	settings.maxOrder = order;
	settings.maxNumSources = max_sources + 1; // Including the listener's group.
	settings.numThreads = threads;
	settings.rayBatchSize = 64; // Rays reach the raycast provider in batches of this many. Larger batches spread the provider's per call costs, such as Jolt's broadphase lock, over more rays, while 2048 rays still make 32 jobs to share among the simulation threads.
	settings.samplingRate = audio_settings.samplingRate;
	settings.frameSize = audio_settings.frameSize;
	if (!create_simulator(context, settings, simulator)) return false;
	settings.flags = IPL_SIMULATIONFLAGS_DIRECT;
	settings.numThreads = 1;
	if (!create_simulator(context, settings, direct_simulator)) return false;
	simulator->setScene(scene.get());
	direct_simulator->setScene(scene.get());
	if (probes && baked_reverb) simulator->addProbeBatch(probes.get()); // For the listener's baked reverb.
	path_simulator.reset();
	if (pathing && probes && baked_paths) {
		settings.flags = IPL_SIMULATIONFLAGS_PATHING;
		settings.numVisSamples = 4; // For checking whether baked paths are still open, and finding alternatives when they aren't.
		if (create_simulator(context, settings, path_simulator)) {
			path_simulator->setScene(scene.get());
			path_simulator->addProbeBatch(probes.get());
			path_simulator->commit();
		}
	}
	// The pool of groups, each with a reflections source that is simulated while the group has members.
	const int pool = max_sources;
	while (group_count < pool) {
		reflection_group* g = new reflection_group();
		g->send.allocate(context, 1, audio_settings.frameSize);
		g->send.clear();
		groups[group_count] = g;
		group_count++;
	}
	if (api::ISource* s = create_reflection_source(simulator.get())) {
		listener_group.source.publish(s);
		s->release();
	}
	for (int i = 0; i < pool; i++) {
		if (api::ISource* s = create_reflection_source(simulator.get())) {
			groups[i]->source.publish(s);
			s->release();
		}
	}
	simulator->commit();
	direct_simulator->commit();
	audio_config c = audio_config::unpack(published_config);
	const int ir_size = max(1, (int)ceil(duration * audio_settings.samplingRate));
	if (!c.generation || c.type != reflection_type || c.order != order || c.ir_size != ir_size) { // Recreating the audio effects cuts off every reverb tail, so they are only recreated when what they were created with changed rather than any setting of the simulator.
		c.generation++;
		c.type = reflection_type;
		c.order = order;
		c.ir_size = ir_size;
		published_config = c.pack();
	}
	rebuild_needed = false;
	return true;
}
void environment_core::attach_new_sources() { // Script thread. Direct and path sources can be added to their simulators at any time, as only the script thread uses them.
	bool direct_changed = false, path_changed = false;
	vector<api::ISource*> removed_direct, removed_path;
	auto add = [](api::ISimulator* simulator, IPLSimulationFlags flags, source_slot& slot) {
		IPLSourceSettings source_settings{flags};
		api::ISource* created = nullptr;
		if (simulator->createSource(&source_settings, &created) != IPL_STATUS_SUCCESS) return false;
		created->add(simulator);
		slot.publish(created);
		created->release();
		return true;
	};
	{
		lock_guard<mutex> l(sources_mutex);
		removed_direct.swap(removed_direct_sources);
		removed_path.swap(removed_path_sources);
		for (environment_source* s : sources) {
			if (!s->direct_source.script && add(direct_simulator.get(), IPL_SIMULATIONFLAGS_DIRECT, s->direct_source)) {
				s->direct_ready = false;
				direct_changed = true;
			}
			if (path_simulator && !s->path_source.script && add(path_simulator.get(), IPL_SIMULATIONFLAGS_PATHING, s->path_source)) path_changed = true;
		}
	}
	for (api::ISource* s : removed_direct) {
		s->remove(direct_simulator.get());
		s->release();
		direct_changed = true;
	}
	for (api::ISource* s : removed_path) { // Path sources outlive their simulator when pathing was turned off since.
		if (path_simulator) s->remove(path_simulator.get());
		s->release();
		path_changed = true;
	}
	if (direct_changed) direct_simulator->commit();
	if (path_changed && path_simulator) path_simulator->commit();
}
void environment_core::assign_groups(const vector<environment_source*>& current, float lx, float ly, float lz) { // Script thread. Assigns every source with reflections to a reflection group, see reflection_group.
	struct candidate {
		environment_source* s;
		float x, y, z, distance, radius;
	};
	vector<candidate> candidates;
	candidates.reserve(current.size());
	const float grouping = reflection_grouping;
	for (environment_source* s : current) {
		if (!s->has_position || !s->apply_reflections) {
			s->assigned = nullptr;
			s->group = nullptr;
			continue;
		}
		float x = s->x, y = s->y, z = s->z;
		float distance = sqrt((x - lx) * (x - lx) + (y - ly) * (y - ly) + (z - lz) * (z - lz));
		candidates.push_back({s, x, y, z, distance, max(0.25f, distance * grouping)});
	}
	sort(candidates.begin(), candidates.end(), [](const candidate& a, const candidate& b) { return a.distance < b.distance; }); // Nearer sounds have the first claim on groups.
	const int pool = min<int>(max_sources, group_count);
	for (int i = 0; i < pool; i++) {
		reflection_group* g = groups[i];
		g->members = 0;
		g->sum_x = g->sum_y = g->sum_z = 0.0f;
	}
	auto join = [](candidate& c, reflection_group* g) {
		if (!g->members) g->nearest = c.distance;
		g->members++;
		g->sum_x += c.x;
		g->sum_y += c.y;
		g->sum_z += c.z;
		c.s->assigned = g;
	};
	auto distance_to = [](const candidate& c, const reflection_group* g) { return sqrt((c.x - g->x) * (c.x - g->x) + (c.y - g->y) * (c.y - g->y) + (c.z - g->z) * (c.z - g->z)); };
	// Sources stay in their group while they remain near it and in view of it, so that groups don't change from one update to the next.
	vector<candidate*> unassigned;
	for (candidate& c : candidates) {
		reflection_group* g = c.s->assigned;
		bool keep = false;
		for (int i = 0; i < pool && !keep; i++) keep = groups[i] == g;
		if (keep && distance_to(c, g) <= c.radius * 1.5f && visible(c.x, c.y, c.z, g->x, g->y, g->z)) join(c, g);
		else {
			c.s->assigned = nullptr;
			unassigned.push_back(&c);
		}
	}
	for (candidate* c : unassigned) {
		// Join the nearest group in reach, or take a free group, or when every group is taken, take over the group whose nearest member is much farther away than this sound, or join a group a little farther out than usual. Failing all of those, the sound uses the listener's group.
		reflection_group* best = nullptr;
		float best_distance = 0.0f;
		for (int i = 0; i < pool; i++) {
			reflection_group* g = groups[i];
			if (!g->members) continue;
			float d = distance_to(*c, g);
			if (d <= c->radius && (!best || d < best_distance) && visible(c->x, c->y, c->z, g->x, g->y, g->z)) {
				best = g;
				best_distance = d;
			}
		}
		if (best) {
			join(*c, best);
			continue;
		}
		reflection_group* free_group = nullptr; // Groups still ringing are left to finish their tails where they are, and are only taken when nothing else is free.
		for (int i = 0; i < pool && !free_group; i++) if (!groups[i]->members && !groups[i]->ringing) free_group = groups[i];
		if (!free_group) {
			reflection_group* farthest = nullptr;
			for (int i = 0; i < pool; i++) if (!farthest || groups[i]->nearest > farthest->nearest) farthest = groups[i];
			if (farthest && farthest->nearest > c->distance * 2.0f) {
				for (candidate& other : candidates) if (other.s->assigned == farthest) other.s->assigned = nullptr; // They look for another group at the next update.
				free_group = farthest;
				free_group->members = 0;
				free_group->sum_x = free_group->sum_y = free_group->sum_z = 0.0f;
			}
		}
		for (int i = 0; i < pool && !free_group; i++) if (!groups[i]->members) free_group = groups[i];
		if (free_group) {
			free_group->place(c->x, c->y, c->z);
			join(*c, free_group);
			continue;
		}
		for (int i = 0; i < pool; i++) {
			reflection_group* g = groups[i];
			float d = distance_to(*c, g);
			if (d <= c->radius * 3.0f && (!best || d < best_distance) && visible(c->x, c->y, c->z, g->x, g->y, g->z)) {
				best = g;
				best_distance = d;
			}
		}
		if (best) join(*c, best);
	}
	int active = 0;
	for (int i = 0; i < pool; i++) {
		reflection_group* g = groups[i];
		if (!g->members) continue;
		active++;
		g->x = g->sum_x / g->members;
		g->y = g->sum_y / g->members;
		g->z = g->sum_z / g->members;
	}
	active_groups = active;
	for (candidate& c : candidates) c.s->group = c.s->assigned;
}
void environment_core::update() { // Script thread.
	if (shut_down) return;
	bool idle = !worker_busy;
	if (idle && (rebuild_needed || scene_needed || !simulator)) {
		if (!rebuild()) return;
	}
	if (!simulator || !direct_simulator) return;
	attach_new_sources();
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
	auto direct_start = chrono::steady_clock::now();
	direct_simulator->setSharedInputs(IPL_SIMULATIONFLAGS_DIRECT, &shared);
	for (environment_source* s : current) {
		if (!s->direct_source.script || !s->has_position) continue;
		IPLSimulationInputs in = s->direct_inputs();
		s->direct_source.script->setInputs(IPL_SIMULATIONFLAGS_DIRECT, &in);
	}
	direct_simulator->runDirect();
	for (environment_source* s : current) {
		if (!s->has_position) continue;
		s->read_results();
		if (s->direct_source.script) s->direct_ready = true;
	}
	direct_time = chrono::duration<float, milli>(chrono::steady_clock::now() - direct_start).count();
	assign_groups(current, pos.GetX(), pos.GetY(), pos.GetZ());
	// Reflections on the worker thread at the configured interval, inputs can only be changed while it is idle. Groups without members aren't simulated.
	auto now = chrono::steady_clock::now();
	if (idle && chrono::duration<float>(now - last_reflections).count() >= interval) {
		last_reflections = now;
		const unsigned int run = reflection_runs + 1;
		simulator->setSharedInputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &shared);
		auto set_inputs = [&](reflection_group* g, bool active, const IPLCoordinateSpace3& space, bool baked = false) {
			if (!g->source.script) return;
			IPLSimulationInputs in{};
			in.flags = active ? IPL_SIMULATIONFLAGS_REFLECTIONS : (IPLSimulationFlags)0;
			in.source = space;
			if (baked) { // Reverb looked up from the probes around the listener rather than simulated.
				in.baked = IPL_TRUE;
				in.bakedDataIdentifier = {IPL_BAKEDDATATYPE_REFLECTIONS, IPL_BAKEDDATAVARIATION_REVERB, {}};
			}
			in.distanceAttenuationModel.type = IPL_DISTANCEATTENUATIONTYPE_DEFAULT;
			in.airAbsorptionModel.type = IPL_AIRABSORPTIONTYPE_DEFAULT;
			in.reverbScale[0] = in.reverbScale[1] = in.reverbScale[2] = 1.0f;
			in.hybridReverbTransitionTime = hybrid_transition_time;
			in.hybridReverbOverlapPercent = hybrid_overlap;
			g->source.script->setInputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &in);
			if (active && !g->ready_at) g->ready_at = run;
		};
		set_inputs(&listener_group, use_listener_reverb, listener_space, use_baked_reverb && baked_reverb && listener_among_probes(pos.GetX(), pos.GetY(), pos.GetZ()));
		const int pool = min<int>(max_sources, group_count);
		for (int i = 0; i < pool; i++) {
			reflection_group* g = groups[i];
			set_inputs(g, g->members > 0, IPLCoordinateSpace3{{1, 0, 0}, {0, 0, 1}, {0, 1, 0}, {g->x, g->y, g->z}});
		}
		if (!worker.joinable()) worker = thread(&environment_core::worker_loop, this);
		worker_busy = true;
		{
			lock_guard<mutex> l(worker_mutex);
			worker_run = true;
		}
		worker_cv.notify_one();
	}
	// Pathing on the script thread at the same interval, finding the paths sound takes around obstacles from the paths baked between probes.
	if (path_simulator && chrono::duration<float>(now - last_pathing).count() >= interval) {
		last_pathing = now;
		auto pathing_start = chrono::steady_clock::now();
		path_simulator->setSharedInputs(IPL_SIMULATIONFLAGS_PATHING, &shared);
		bool any = false;
		for (environment_source* s : current) {
			if (!s->path_source.script || !s->has_position) continue;
			IPLSimulationInputs in{};
			in.flags = s->apply_pathing ? IPL_SIMULATIONFLAGS_PATHING : (IPLSimulationFlags)0;
			in.source = {{1, 0, 0}, {0, 0, 1}, {0, 1, 0}, {s->x, s->y, s->z}};
			in.distanceAttenuationModel.type = IPL_DISTANCEATTENUATIONTYPE_CALLBACK;
			in.distanceAttenuationModel.callback = environment_source::distance_attenuation;
			in.distanceAttenuationModel.userData = s;
			in.airAbsorptionModel.type = IPL_AIRABSORPTIONTYPE_DEFAULT;
			in.pathingProbes = reinterpret_cast<IPLProbeBatch>(probes.get());
			in.visRadius = 0.5f;
			in.visThreshold = 0.1f;
			in.visRange = 1000.0f;
			in.pathingOrder = 1;
			in.enableValidation = IPL_TRUE; // Baked paths blocked since baking, by a closed door for example, are checked for and replaced by others where there are any.
			in.findAlternatePaths = IPL_TRUE;
			s->path_source.script->setInputs(IPL_SIMULATIONFLAGS_PATHING, &in);
			any = any || s->apply_pathing;
		}
		if (any) path_simulator->runPathing();
		pathing_time = chrono::duration<float, milli>(chrono::steady_clock::now() - pathing_start).count();
	}
	for (environment_source* s : current) s->release();
}

// The reverb node of the environment's reverb3d. It applies every reflection group's reflection effect to the signal its members added this pass, into the reflection mixer when it's in use, and decodes the ambisonic result once for all of them.
class environment_return : public effect_node_impl {
	environment_core* core;
	audio_config config;
	bool mixer_wanted = false;
	ipl_ref<api::IReflectionMixer> mixer;
	ipl_ref<api::IAmbisonicsDecodeEffect> decode_effect;
	ipl_buffer ambisonics_buffer, decoded_buffer;
	ma_hpf highpass;
	bool highpass_ready = false;
	float highpass_cutoff = 0;
public:
	environment_return(environment_core* core) : effect_node_impl(core->engine, 0, 0, 1, 1, MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT), core(core) { core->retain(); }
	~environment_return() {
		destroy_node();
		if (highpass_ready) ma_hpf_uninit(&highpass, nullptr);
		core->audio_mixer = nullptr;
		mixer.reset();
		core->release();
	}
	bool prepare() {
		audio_config c = audio_config::unpack(core->published_config);
		bool want_mixer = core->use_reflection_mixer && c.type == reflections_convolution; // Steam Audio's reflection mixer only implements convolution, parametric and hybrid reflections applied to it are silently dropped, so those are decoded per group.
		if (c.generation == config.generation && want_mixer == mixer_wanted && (!want_mixer || mixer)) return c.generation != 0;
		core->audio_mixer = nullptr;
		mixer.reset();
		mixer_wanted = want_mixer;
		config = c;
		if (!c.generation) return false;
		api::IContext* ctx = core->context;
		IPLReflectionEffectSettings effect_settings{(IPLReflectionEffectType)c.type, c.ir_size, c.channels()};
		IPLAmbisonicsDecodeEffectSettings decode_settings{speaker_layout_for_channels(core->channels), reinterpret_cast<IPLHRTF>(core->hrtf.get()), c.order};
		if (ctx->createAmbisonicsDecodeEffect(&core->audio_settings, &decode_settings, decode_effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (!ambisonics_buffer.allocate(ctx, c.channels(), core->audio_settings.frameSize) || !decoded_buffer.allocate(ctx, core->channels, core->audio_settings.frameSize)) return false;
		if (want_mixer) {
			if (ctx->createReflectionMixer(&core->audio_settings, &effect_settings, mixer.put()) != IPL_STATUS_SUCCESS) return false;
			core->audio_mixer = mixer.get();
		}
		return true;
	}
	bool prepare_group(reflection_group* g) { // Creates or recreates a group's effects when the environment's configuration changed.
		if (g->config.generation == config.generation && g->effect) return true;
		g->config.generation = 0;
		g->tail = false;
		api::IContext* ctx = core->context;
		IPLReflectionEffectSettings effect_settings{(IPLReflectionEffectType)config.type, config.ir_size, config.channels()};
		IPLAmbisonicsDecodeEffectSettings decode_settings{speaker_layout_for_channels(core->channels), reinterpret_cast<IPLHRTF>(core->hrtf.get()), config.order};
		if (ctx->createReflectionEffect(&core->audio_settings, &effect_settings, g->effect.put()) != IPL_STATUS_SUCCESS) return false;
		if (ctx->createAmbisonicsDecodeEffect(&core->audio_settings, &decode_settings, g->decode.put()) != IPL_STATUS_SUCCESS) return false;
		g->config = config;
		return true;
	}
	void add_decoded(float* out, unsigned int frames) {
		const int channels = core->channels;
		for (unsigned int i = 0; i < frames; i++) for (int c = 0; c < channels; c++) out[i * channels + c] += decoded_buffer.b.data[c][i];
	}
	void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		render(frames_out[0], *frame_count_out);
		filter(frames_out[0], *frame_count_out);
		// The sends of the sources, their pathing, pass through unfiltered.
		const unsigned int available = frames_in && frames_in[0] ? min(*frame_count_in, *frame_count_out) : 0; // With MA_NODE_FLAG_ALLOW_NULL_INPUT the input array itself is null once nothing is attached.
		for (unsigned int i = 0; i < available * core->channels; i++) frames_out[0][i] += frames_in[0][i];
	}
	void filter(float* out, unsigned int frames) {
		// Binaurally decoded reverb is quite correlated between the ears and sounds narrow, so its side signal is scaled for a wider room.
		// The low end of simulated reflections tends to sound boomy, so it can be filtered out.
		float cutoff = core->reflections_highpass;
		if (cutoff > 0) {
			if (!highpass_ready || cutoff != highpass_cutoff) {
				ma_hpf_config cfg = ma_hpf_config_init(ma_format_f32, core->channels, core->audio_settings.samplingRate, cutoff, 2);
				if (highpass_ready) ma_hpf_reinit(&cfg, &highpass);
				else highpass_ready = ma_hpf_init(&cfg, nullptr, &highpass) == MA_SUCCESS;
				highpass_cutoff = cutoff;
			}
			if (highpass_ready) ma_hpf_process_pcm_frames(&highpass, out, out, frames);
		}
		float width = core->reflections_width;
		if (core->channels != 2 || width == 1.0f) return;
		for (unsigned int i = 0; i < frames; i++) {
			float mid = (out[i * 2] + out[i * 2 + 1]) * 0.5f, side = (out[i * 2] - out[i * 2 + 1]) * 0.5f * width;
			out[i * 2] = mid + side;
			out[i * 2 + 1] = mid - side;
		}
	}
	void render_group(reflection_group* g, float* out, unsigned int frames, IPLAmbisonicsDecodeEffectParams& decode) {
		const bool send_active = g->send_active;
		g->send_active = false;
		const unsigned int placement = g->placement;
		if (placement != g->audio_placement) { // A group moved elsewhere while ringing would play the rest of its old tail through its new place's reflections, so the tail is cut instead.
			g->audio_placement = placement;
			if (g->effect) g->effect->reset();
			g->tail = false;
		}
		api::ISource* src = g->source.take();
		if ((send_active || g->tail) && src && prepare_group(g)) {
			IPLSimulationOutputs outputs{};
			src->getOutputs(IPL_SIMULATIONFLAGS_REFLECTIONS, &outputs);
			IPLReflectionEffectParams params = outputs.reflections;
			params.type = (IPLReflectionEffectType)config.type;
			params.numChannels = config.channels();
			params.irSize = config.ir_size;
			IPLAudioEffectState state = send_active ? g->effect->apply(&params, &g->send.b, &ambisonics_buffer.b, mixer.get()) : g->effect->getTail(&ambisonics_buffer.b, mixer.get()); // apply would keep reporting a tail for as long as it's called, so silence counts the tail down through getTail.
			if (!mixer) {
				if (g->decode->apply(&decode, &ambisonics_buffer.b, &decoded_buffer.b) == IPL_AUDIOEFFECTSTATE_TAILREMAINING) state = IPL_AUDIOEFFECTSTATE_TAILREMAINING;
				add_decoded(out, frames);
			}
			g->tail = state == IPL_AUDIOEFFECTSTATE_TAILREMAINING;
			if (!send_active && !g->tail) g->effect->reset(); // Steam Audio's convolution keeps the input it was given after its tail has ended, and would play that again with the group's next input.
		}
		g->ringing = send_active || g->tail;
		if (send_active) g->send.clear();
	}
	void render(float* out, unsigned int frames) { // The reflections of every group.
		memset(out, 0, frames * core->channels * sizeof(float));
		{
			unique_lock<mutex> l(core->listener_mutex, try_to_lock); // Never block the audio thread, the previous orientation is fine if update holds the lock.
			if (l.owns_lock()) core->audio_listener = core->listener;
		}
		const int group_count = core->group_count;
		if (!prepare() || frames != (unsigned int)core->audio_settings.frameSize) {
			core->listener_group.send.clear();
			core->listener_group.send_active = false;
			for (int i = 0; i < group_count; i++) {
				core->groups[i]->send.clear();
				core->groups[i]->send_active = false;
			}
			return;
		}
		IPLAmbisonicsDecodeEffectParams decode{config.order, reinterpret_cast<IPLHRTF>(core->hrtf.get()), core->audio_listener, core->binaural && core->channels == 2 ? IPL_TRUE : IPL_FALSE};
		render_group(&core->listener_group, out, frames, decode);
		for (int i = 0; i < group_count; i++) render_group(core->groups[i], out, frames, decode);
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
	// Probes and baking. Probes mark places the listener can be, and baking simulates ahead of time the reverb at each of them and the paths sound can take between them, so that the listener's reverb is looked up rather than simulated and sounds can be heard around obstacles. Changing the probes discards baked data.
	unsigned int generate_probes(const vector3& minimum, const vector3& maximum, float spacing, float height) { // Places probes height meters above every floor within a box, spacing meters apart, returning how many were placed.
		if (!core->provider || spacing <= 0.0f) return 0;
		core->wait_until_idle();
		if (!core->ensure_scene()) return 0;
		ipl_ref<api::IProbeArray> array;
		if (core->context->createProbeArray(array.put()) != IPL_STATUS_SUCCESS) return 0;
		vector3 size = maximum - minimum, center = (minimum + maximum) * 0.5f;
		IPLProbeGenerationParams params{};
		params.type = IPL_PROBEGENERATIONTYPE_UNIFORMFLOOR;
		params.spacing = spacing;
		params.height = height;
		// Steam Audio generates probes in a unit cube centered on the origin transformed by this row major matrix, looking for floors along the cube's negative y axis. NVGT's up is z, so the cube's y axis is mapped to z and its z axis to y.
		params.transform = {{{size.GetX(), 0, 0, center.GetX()}, {0, 0, size.GetY(), center.GetY()}, {0, size.GetZ(), 0, center.GetZ()}, {0, 0, 0, 1}}};
		array->generateProbes(core->scene.get(), &params);
		const int count = array->getNumProbes();
		for (int i = 0; i < count; i++) core->probe_spheres.push_back(array->getProbe(i));
		core->rebuild_probes();
		return count;
	}
	void add_probe(const vector3& position, float radius) {
		core->wait_until_idle();
		core->probe_spheres.push_back({{position.GetX(), position.GetY(), position.GetZ()}, max(0.01f, radius)});
		core->rebuild_probes();
	}
	void clear_probes() {
		core->wait_until_idle();
		core->probe_spheres.clear();
		core->rebuild_probes();
	}
	unsigned int get_probe_count() const { return (unsigned int)core->probe_spheres.size(); }
	bool get_has_baked_reverb() const { return core->baked_reverb; }
	bool get_has_baked_paths() const { return core->baked_paths; }
	struct bake_progress {
		asIScriptFunction* callback;
		float start, span, last;
	};
	static void IPLCALL report_progress(IPLfloat32 fraction, void* user) { // Steam Audio reports progress on the thread that bakes.
		bake_progress* p = static_cast<bake_progress*>(user);
		float progress = p->start + p->span * clamp(fraction, 0.0f, 1.0f);
		if (!p->callback || progress < p->last + 0.01f) return;
		p->last = progress;
		asIScriptContext* ctx = asGetActiveContext();
		bool nested = ctx && ctx->PushState() >= 0;
		if (!nested) ctx = p->callback->GetEngine()->RequestContext();
		if (!ctx) return;
		if (ctx->Prepare(p->callback) >= 0) {
			ctx->SetArgFloat(0, progress);
			ctx->Execute();
		}
		if (nested) ctx->PopState();
		else p->callback->GetEngine()->ReturnContext(ctx);
	}
	bool bake(asIScriptFunction* callback) { // Bakes the reverb at every probe and the paths between them with the environment's reflection settings, reporting progress from 0 to 1 to the callback if given. This blocks until baking is done.
		bake_progress progress{callback, 0.0f, 0.75f, -1.0f};
		bool ok = core->provider && !core->probe_spheres.empty();
		if (ok) {
			core->wait_until_idle();
			ok = core->ensure_scene() && (core->probes || core->rebuild_probes()) && core->probes;
		}
		if (ok) {
			const int threads = max(1, (int)thread::hardware_concurrency());
			IPLReflectionsBakeParams reflections{};
			reflections.scene = reinterpret_cast<IPLScene>(core->scene.get());
			reflections.probeBatch = reinterpret_cast<IPLProbeBatch>(core->probes.get());
			reflections.sceneType = IPL_SCENETYPE_CUSTOM;
			reflections.identifier = {IPL_BAKEDDATATYPE_REFLECTIONS, IPL_BAKEDDATAVARIATION_REVERB, {}};
			reflections.bakeFlags = (IPLReflectionsBakeFlags)(IPL_REFLECTIONSBAKEFLAGS_BAKECONVOLUTION | IPL_REFLECTIONSBAKEFLAGS_BAKEPARAMETRIC);
			reflections.numRays = core->rays * 2; // Baking is done once, so it can afford more rays than real time simulation.
			reflections.numDiffuseSamples = core->diffuse_samples;
			reflections.numBounces = core->bounces;
			reflections.simulatedDuration = reflections.savedDuration = core->duration;
			reflections.order = core->order;
			reflections.numThreads = threads;
			reflections.rayBatchSize = 64;
			reflections.irradianceMinDistance = core->irradiance_min_distance;
			reflections.bakeBatchSize = 1;
			core->context->bakeReflections(&reflections, report_progress, &progress);
			IPLPathBakeParams paths{};
			paths.scene = reflections.scene;
			paths.probeBatch = reflections.probeBatch;
			paths.identifier = {IPL_BAKEDDATATYPE_PATHING, IPL_BAKEDDATAVARIATION_DYNAMIC, {}};
			paths.numSamples = 1;
			paths.radius = 0.5f;
			paths.threshold = 0.1f;
			paths.visRange = 1000.0f;
			paths.pathRange = 1000.0f;
			paths.numThreads = threads;
			progress.start = 0.75f;
			progress.span = 0.25f;
			core->context->bakePaths(&paths, report_progress, &progress);
			core->baked_reverb = core->baked_paths = true;
			core->rebuild_needed = true;
			progress.last = -1.0f;
			report_progress(1.0f, &progress);
		}
		if (callback) callback->Release();
		return ok;
	}
	// Baked data is saved as the probes followed by Steam Audio's serialized probe batch.
	static constexpr char BAKED_DATA_MAGIC[8] = {'N', 'V', 'G', 'T', 'S', 'E', 'N', 'V'};
	static constexpr unsigned int BAKED_DATA_VERSION = 1;
	string save_baked_data() const {
		string data(BAKED_DATA_MAGIC, sizeof(BAKED_DATA_MAGIC));
		auto put = [&data](const void* p, size_t size) { data.append(static_cast<const char*>(p), size); };
		unsigned int header[3] = {BAKED_DATA_VERSION, (core->baked_reverb ? 1u : 0u) | (core->baked_paths ? 2u : 0u), (unsigned int)core->probe_spheres.size()};
		put(header, sizeof(header));
		if (!core->probe_spheres.empty()) put(core->probe_spheres.data(), core->probe_spheres.size() * sizeof(IPLSphere));
		ipl_ref<api::ISerializedObject> serialized;
		IPLSerializedObjectSettings settings{};
		unsigned long long size = 0;
		if (core->probes && core->context->createSerializedObject(&settings, serialized.put()) == IPL_STATUS_SUCCESS) {
			core->probes->save(serialized.get());
			size = serialized->getSize();
		}
		put(&size, sizeof(size));
		if (size) put(serialized->getData(), size);
		return data;
	}
	bool load_baked_data(const string& data) {
		size_t offset = 0;
		auto get = [&](void* p, size_t size) {
			if (offset + size > data.size()) return false;
			memcpy(p, data.data() + offset, size);
			offset += size;
			return true;
		};
		char magic[sizeof(BAKED_DATA_MAGIC)];
		unsigned int header[3];
		if (!get(magic, sizeof(magic)) || memcmp(magic, BAKED_DATA_MAGIC, sizeof(magic)) || !get(header, sizeof(header)) || header[0] != BAKED_DATA_VERSION) return false;
		vector<IPLSphere> spheres(header[2]);
		unsigned long long size = 0;
		if ((header[2] && !get(spheres.data(), spheres.size() * sizeof(IPLSphere))) || !get(&size, sizeof(size)) || offset + size != data.size()) return false;
		ipl_ref<api::IProbeBatch> batch;
		if (size) {
			IPLSerializedObjectSettings settings{reinterpret_cast<IPLbyte*>(const_cast<char*>(data.data() + offset)), (IPLsize)size};
			ipl_ref<api::ISerializedObject> serialized;
			if (core->context->createSerializedObject(&settings, serialized.put()) != IPL_STATUS_SUCCESS || core->context->loadProbeBatch(serialized.get(), batch.put()) != IPL_STATUS_SUCCESS) return false;
			batch->commit();
		}
		core->wait_until_idle();
		core->probe_spheres = move(spheres);
		core->probes.reset(batch.get() ? batch.get()->retain() : nullptr);
		core->baked_reverb = batch && (header[1] & 1);
		core->baked_paths = batch && (header[1] & 2);
		core->rebuild_needed = true;
		return true;
	}
	bool get_use_baked_reverb() const { return core->use_baked_reverb; }
	void set_use_baked_reverb(bool v) { core->use_baked_reverb = v; }
	bool get_pathing() const { return core->pathing; }
	void set_pathing(bool v) { if (v != core->pathing) { core->pathing = v; core->rebuild_needed = true; } }
	float get_pathing_level() const { return core->pathing_level; }
	void set_pathing_level(float v) { core->pathing_level = max(0.0f, v); }
	float get_pathing_simulation_time() const { return core->pathing_time; }
	void update() { core->update(); }
	reverb3d* get_reverb3d() const { return verb; }
	audio_engine* get_engine() const { return core->engine; }
	mixer* get_output_mixer() const { return verb->get_mixer(); }
	void set_output_mixer(mixer* m) { verb->set_mixer(m); }
	unsigned int get_reflection_simulations() const { return core->reflection_runs; }
	bool get_simulating_reflections() const { return core->worker_busy; }
	float get_reflection_simulation_time() const { return core->reflection_time; }
	float get_direct_simulation_time() const { return core->direct_time; }
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
	void set_max_sources(int v) { v = clamp(v, 0, MAX_REFLECTION_GROUPS); if (v != core->max_sources) { core->max_sources = v; core->rebuild_needed = true; } }
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
	unsigned int get_active_reflection_groups() const { return core->active_groups; }
	float get_reflection_grouping() const { return core->reflection_grouping; }
	void set_reflection_grouping(float v) { core->reflection_grouping = clamp(v, 0.0f, 10.0f); }
	bool get_use_reflection_mixer() const { return core->use_reflection_mixer; }
	void set_use_reflection_mixer(bool v) { core->use_reflection_mixer = v; }
	bool get_binaural() const { return core->binaural; }
	void set_binaural(bool v) { core->binaural = v; }
	float get_reflections_width() const { return core->reflections_width; }
	void set_reflections_width(float v) { core->reflections_width = clamp(v, 0.0f, 8.0f); }
	float get_reflections_highpass() const { return core->reflections_highpass; }
	void set_reflections_highpass(float v) { core->reflections_highpass = clamp(v, 0.0f, core->audio_settings.samplingRate * 0.45f); }
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
	engine->RegisterObjectMethod("sound_environment_source", "int get_reflection_group() const property", asFUNCTION((source_call<&environment_source::get_reflection_group, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_occlusion() const property", asFUNCTION((source_call<&environment_source::get_occlusion, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_transmission_low() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_transmission, 0>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_transmission_mid() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_transmission, 1>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_transmission_high() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_transmission, 2>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_reverb_time_low() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_reverb_time, 0>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_reverb_time_mid() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_reverb_time, 1>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "float get_reverb_time_high() const property", asFUNCTION((band_getter<environment_source, &environment_source::get_reverb_time, 2>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "bool get_apply_pathing() const property", asFUNCTION((source_call<&environment_source::get_apply_pathing, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound_environment_source", "void set_apply_pathing(bool enabled) property", asFUNCTION((source_call<&environment_source::set_apply_pathing, void, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectType("sound_environment", 0, asOBJ_REF);
	engine->RegisterFuncdef("void sound_environment_bake_callback(float progress)");
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
	engine->RegisterObjectMethod("sound_environment", "uint generate_probes(const vector&in minimum, const vector&in maximum, float spacing = 2, float height = 1.5)", asMETHOD(sound_environment, generate_probes), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "void add_probe(const vector&in position, float radius = 2)", asMETHOD(sound_environment, add_probe), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "void clear_probes()", asMETHOD(sound_environment, clear_probes), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "uint get_probe_count() const property", asMETHOD(sound_environment, get_probe_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool bake(sound_environment_bake_callback@ progress = null)", asMETHOD(sound_environment, bake), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool get_has_baked_reverb() const property", asMETHOD(sound_environment, get_has_baked_reverb), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool get_has_baked_paths() const property", asMETHOD(sound_environment, get_has_baked_paths), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "string save_baked_data() const", asMETHOD(sound_environment, save_baked_data), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool load_baked_data(const string&in data)", asMETHOD(sound_environment, load_baked_data), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "float get_pathing_simulation_time() const property", asMETHOD(sound_environment, get_pathing_simulation_time), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "reverb3d@+ get_reverb3d() const property", asMETHOD(sound_environment, get_reverb3d), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "audio_engine@+ get_engine() const property", asMETHOD(sound_environment, get_engine), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "mixer@+ get_output_mixer() const property", asMETHOD(sound_environment, get_output_mixer), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "void set_output_mixer(mixer@+ mix) property", asMETHOD(sound_environment, set_output_mixer), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "uint get_reflection_simulations() const property", asMETHOD(sound_environment, get_reflection_simulations), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool get_simulating_reflections() const property", asMETHOD(sound_environment, get_simulating_reflections), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "float get_reflection_simulation_time() const property", asMETHOD(sound_environment, get_reflection_simulation_time), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "float get_direct_simulation_time() const property", asMETHOD(sound_environment, get_direct_simulation_time), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "uint get_source_count() const property", asMETHOD(sound_environment, get_source_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "uint get_active_reflection_groups() const property", asMETHOD(sound_environment, get_active_reflection_groups), asCALL_THISCALL);
	#define ENV_PROPERTY(type, name) \
		engine->RegisterObjectMethod("sound_environment", #type " get_" #name "() const property", asMETHOD(sound_environment, get_##name), asCALL_THISCALL); \
		engine->RegisterObjectMethod("sound_environment", "void set_" #name "(" #type " value) property", asMETHOD(sound_environment, set_##name), asCALL_THISCALL);
	ENV_PROPERTY(sound_environment_reflection_type, reflection_type)
	ENV_PROPERTY(int, reflection_rays)
	ENV_PROPERTY(float, reflection_duration)
	ENV_PROPERTY(int, reflection_order)
	ENV_PROPERTY(int, reflection_bounces)
	ENV_PROPERTY(int, max_sources)
	ENV_PROPERTY(float, reflection_grouping)
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
	ENV_PROPERTY(float, reflections_width)
	ENV_PROPERTY(float, reflections_highpass)
	ENV_PROPERTY(bool, use_baked_reverb)
	ENV_PROPERTY(bool, pathing)
	ENV_PROPERTY(float, pathing_level)
	#undef ENV_PROPERTY
}
