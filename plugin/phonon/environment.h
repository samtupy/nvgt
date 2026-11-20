/* environment.h - sound_environment, Steam Audio scene simulation (occlusion, transmission, reflections and pathing) for 3d sounds
 * The design follows Steam Audio's own engine integrations. Every sound or mixer created by or attached to a sound_environment is sent through the environment's reverb3d, whose attachment handler gives each of them a node implemented by environment_source, published to scripts as sound_environment_source. That node applies the simulated occlusion and transmission to the sound's dry signal, like the spatialize effect of the FMOD integration. Reflections are simulated for a limited pool of reflection groups rather than for every sound: each sound adds its signal to the group nearest to it (see reflection_group), and the reverb3d's reverb node, the environment's return node, applies each group's reflection effect into a reflection mixer shared by the whole environment and decodes the resulting ambisonic sound field once, like the FMOD integration's mix return effect.
 * Simulation is scheduled like the Unity integration: sound_environment::update, called by the script each frame, runs the cheap direct simulation (occlusion and transmission) on the script thread and periodically hands the expensive reflection simulation to a worker thread, while changes to the simulator such as adding or removing sources are only made when that thread is idle. The scene is a Steam Audio custom scene that traces rays through an nvgt_raycast_provider such as a physics_world, so Steam Audio's own simulation threads and the provider (Jolt's broadphase for physics_world) work in parallel.
 * environment.cpp implements the simulation and the audio processing, environment_script.cpp the script facing sound_environment and its registration.
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
#include "../../src/sound_nodes.h"
#include "nvgt_phonon.h"

using namespace std;

static_assert(sizeof(nvgt_acoustic_material) == sizeof(IPLMaterial) && offsetof(nvgt_acoustic_material, scattering) == offsetof(IPLMaterial, scattering) && offsetof(nvgt_acoustic_material, transmission) == offsetof(IPLMaterial, transmission), "nvgt_acoustic_material must be laid out like IPLMaterial");
static_assert(sizeof(nvgt_ray) == sizeof(IPLRay) && offsetof(nvgt_ray, direction) == offsetof(IPLRay, direction), "nvgt_ray must be laid out like IPLRay");
static_assert(sizeof(nvgt_ray_hit) == sizeof(IPLHit) && offsetof(nvgt_ray_hit, normal) == offsetof(IPLHit, normal) && offsetof(nvgt_ray_hit, material) == offsetof(IPLHit, material), "nvgt_ray_hit must be laid out like IPLHit");

inline int ambisonic_channels(int order) { return (order + 1) * (order + 1); }
// The configuration the audio thread's effects are created with, published by the script thread whenever the simulator is rebuilt. It is packed into one atomic value so that the audio thread can never see a mix of old and new values.
struct audio_config {
	unsigned int generation = 0;
	int type = IPL_REFLECTIONEFFECTTYPE_CONVOLUTION, order = 1, ir_size = 1;
	unsigned long long pack() const { return (unsigned long long)generation << 32 | (unsigned long long)(ir_size & 0xffffff) << 8 | (order & 0xf) << 4 | (type & 0xf); }
	static audio_config unpack(unsigned long long v) { return {(unsigned int)(v >> 32), (int)(v & 0xf), (int)(v >> 4 & 0xf), (int)(v >> 8 & 0xffffff)}; }
	int channels() const { return ambisonic_channels(order); }
};

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

// A simulated reflection source shared by every sound near its position. Sounds don't convolve their own reflections: each adds its mono signal to the input of the group it belongs to, and the return node applies one reflection effect per group, so the cost of reflections depends on the number of groups rather than the number of sounds, and a sound that ends simply stops adding to its group while the group's reverb tail rings on. The environment keeps a pool of max_sources groups and assigns sounds to them every update, nearest sounds first. A sound joins a group within reflection_group_size meters of it that nothing blocks the view of, and otherwise gets a group of its own. When every group is taken, sounds join the nearest group they can or the listener's group, whose reflections are simulated at the listener's position.
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
	bool send_active = false, tail = false, effect_tail = false; // tail includes the decoder's, effect_tail is the reflection effect's alone.
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
	atomic<int> reflection_type = reflections_hybrid;
	atomic<int> rays = 2048, bounces = 32, order = 1, max_sources = 16, threads, diffuse_samples = 32, max_occlusion_samples = 16;
	atomic<float> duration = 1.0f, irradiance_min_distance = 0.25f, interval = 0.1f, hybrid_transition_time = 1.0f, hybrid_overlap = 0.25f;
	atomic<float> reflection_group_size = 3.0f; // Sounds within this many meters of a reflection group, and in view of it, can share it.
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

	environment_core(audio_engine* e) : engine(e), context(phonon_context()), channels(e->get_channels()) {
		engine->duplicate();
		context->retain();
		audio_settings = {(IPLint32)engine->get_sample_rate(), SOUNDSYSTEM_FRAMESIZE};
		threads = max(1, (int)thread::hardware_concurrency() / 2);
		if (phonon_audio_settings().samplingRate == audio_settings.samplingRate) hrtf.reset(phonon_hrtf()->retain());
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

// What every sound attached to an environment is sent through, published to scripts as sound_environment_source. Its node, an NVGT plugin_node with one input and two output buses, is the sound's reverb3d attachment. Bus 0 carries the sound's dry signal with occlusion and transmission applied. The sound's reflections are applied by its reflection group in the environment's return node, so bus 1, the send to the environment's reverb3d, only carries the sound's pathing, which the path effect has already spatialized.
// The node holds a reference to its environment_source and gives it up when it is destroyed, after the source has left the core's list of sources under sources_mutex, so that update never takes a reference to a source whose node is going away. Scripts hold references to the environment_source, which outlives its node if they keep it.
class environment_source : public audio_plugin_node_interface {
	atomic<int> refcount = 1; // The node's reference.
	// Audio thread state.
	audio_config config;
	ipl_ref<api::IDirectEffect> direct_effect;
	ipl_buffer in_buffer, out_buffer, mono_buffer;
	float previous_level = 0.0f;
	bool previous_silent = true; // Whether the last frame had no input, in which case the next frame needs no ramp or crossfade from it.
	reflection_group* sending = nullptr; // The group this source's signal is added to, which changes with a crossfade over one frame.
	unsigned int sending_placement = 0; // The placement of sending when this source started sending to it, to know whether it has moved since.
	ipl_ref<api::IPathEffect> path_effect; // Created once pathing is first used.
	float previous_path_weight = 0.0f;
	bool path_tail = false;
public:
	environment_core* core;
	plugin_node* node = nullptr; // Null once the node is destroyed.
	source_slot direct_source, path_source;
	atomic<bool> has_position = false;
	atomic<bool> direct_ready = false; // Whether the direct source has been simulated, before which its outputs read as fully occluded, muting the start of new sounds when their first audio was processed before the simulation.
	atomic<float> x = 0.0f, y = 0.0f, z = 0.0f;
	atomic<float> min_distance = 0.0f, max_distance = 0.0f, min_volume = 0.0f, max_volume = 1.0f, rolloff = 1.0f; // The sound's distance attenuation settings and attenuator, for pathing.
	atomic<int> attenuator = -1;
	reflection_group* assigned = nullptr; // Script thread, the source's reflection group or null for the listener's.
	atomic<reflection_group*> group = nullptr; // assigned, published to the audio thread.
	// Settings.
	atomic<bool> apply_occlusion = true, apply_transmission = true, apply_reflections = true, apply_pathing = true;
	atomic<float> reflections_level = 1.0f, occlusion_radius = 1.0f;
	atomic<int> occlusion_type = occlusion_raycast, occlusion_samples = 16, transmission_rays = 3;
	// Simulation results, copied after each direct simulation for scripts to read.
	atomic<bool> simulated = false;
	atomic<float> occlusion = 1.0f, transmission[3] = {1.0f, 1.0f, 1.0f}, reverb_times[3] = {0.0f, 0.0f, 0.0f};

	environment_source(environment_core* core) : core(core) {
		core->retain();
		node = nvgt_audio_plugin_node_create(this, 1, 2, MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT, core->engine);
		if (!node) return;
		node->set_output_bus_volume(1, 1.0f);
		core->add_source(this);
	}
	~environment_source() {
		core->remove_sources(direct_source.detach_script(), path_source.detach_script());
		core->release();
	}
	void duplicate() { refcount++; }
	void release() { if (--refcount < 1) delete this; }
	void on_node_destroyed(plugin_node* destroyed) override {
		{
			lock_guard<mutex> l(core->sources_mutex);
			core->sources.erase(std::remove(core->sources.begin(), core->sources.end(), this), core->sources.end());
			node = nullptr;
		}
		release();
	}
	static environment_source* from_node(audio_node* attachment) { // The source of a sound's reverb3d attachment, if it belongs to an environment.
		plugin_node* n = dynamic_cast<plugin_node*>(attachment);
		return n ? dynamic_cast<environment_source*>(n->get_plugin_interface()) : nullptr;
	}
	void process(audio_plugin_node_interface* self, const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
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
		if (target && !target->ready(runs)) target = nullptr;
		if (!target && sending && sending != &core->listener_group && sending->placement == sending_placement && sending->ready(runs)) target = sending; // Until a sound's new group has been simulated where it is, the sound stays with its old group if that hasn't moved, so that a sound moving from one place to another crossfades between two simulated places and the old place's tail rings out.
		float gain = 1.0f;
		if (!target && core->use_listener_reverb && core->listener_group.ready(runs)) { // Otherwise it is heard with the listener's reflections, which are simulated as if the sound were at the listener, so they are attenuated by the sound's distance as Steam Audio's default distance attenuation would, rather than a distant sound reverberating as loudly as one right by the listener.
			target = &core->listener_group;
			const IPLVector3 l = core->audio_listener.origin;
			const float dx = x - l.x, dy = y - l.y, dz = z - l.z;
			gain = 1.0f / max(1.0f, sqrt(dx * dx + dy * dy + dz * dz));
		}
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
			if (target != previous && target) sending_placement = target->placement;
			if (!target && !previous) continue;
			bool silent = true; // Skipping silence saves the downmix, the groups ring on by themselves.
			for (int c = 0; c < in_buffer.b.numChannels && silent; c++) for (int i = 0; i < n; i++) if (in_buffer.b.data[c][i] != 0.0f) {
				silent = false;
				break;
			}
			const float level = reflections_level * core->reflections_level * gain;
			if (silent) { // The level follows along while there is nothing to ramp, so that the start of the next sound, such as a footstep's onset, isn't faded in from whatever level the source was last heard at, or from silence the first time it is heard.
				previous_level = level;
				previous_silent = true;
				continue;
			}
			ctx->downmixAudioBuffer(&in_buffer.b, &mono_buffer.b);
			const float* mono = mono_buffer.b.data[0];
			if (target && (previous == target || previous_silent)) { // Ramp level changes to avoid clicks. After silence there is nothing to crossfade from another group.
				float* send = target->send.b.data[0];
				for (int i = 0; i < n; i++) send[i] += mono[i] * (previous_level + (level - previous_level) * (i / (float)n));
				target->send_active = true;
			} else if (!previous_silent) { // Crossfade from the previous group to the new one.
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
			previous_silent = false;
		}
	}
	void apply_path(api::ISource* path, float occlusion, float* out) { // Sound reaching the listener around obstacles. Steam Audio's paths include the direct path whenever the source is in view, which the dry signal already carries, so pathing is heard in proportion to how much the direct sound is occluded.
		api::IContext* ctx = core->context;
		const int n = core->audio_settings.frameSize;
		float weight = core->pathing && apply_pathing && apply_occlusion && direct_ready ? (1.0f - occlusion) * core->pathing_level : 0.0f; // Steam Audio's path coefficients are normalized spherical harmonics, whose omnidirectional term of 1 / sqrt(4 pi) leaves pathed sound about 11dB quieter than an unoccluded sound at the length of the path. That is left as it is, as sound bending around a doorway or a corner loses about that much, and making up for it made a sound heard around a corner as loud as with nothing in the way.
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
		attenuator = params.attenuator;
		has_position = true;
	}
	static float IPLCALL distance_attenuation(IPLfloat32 distance, void* user) { // Pathed sound is attenuated over the length of its path by the sound's own attenuator, as a dry sound would be over the same distance, rather than by Steam Audio's physical model.
		const environment_source* s = static_cast<const environment_source*>(user);
		audio_spatialization_parameters params{};
		params.min_distance = s->min_distance;
		params.max_distance = s->max_distance;
		params.min_volume = s->min_volume;
		params.max_volume = s->max_volume;
		params.rolloff = s->rolloff;
		params.directional_attenuation_factor = 1.0f;
		params.attenuator = s->attenuator;
		return nvgt_get_audio_attenuation(params.attenuator, &params, distance);
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
		in.numOcclusionSamples = occlusion_samples;
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
	void set_occlusion_samples(int v) { occlusion_samples = clamp(v, 1, core->max_occlusion_samples.load()); }
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
audio_node* create_environment_return(environment_core* core); // The node applying an environment's reflections, its reverb3d's reverb node.
