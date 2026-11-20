/* environment.cpp - sound_environment's simulation and audio processing, see environment.h
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

#define NVGT_PLUGIN_INCLUDE
#include "../../src/nvgt_plugin.h"
#include "environment.h"

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
	const float radius = reflection_group_size;
	for (environment_source* s : current) {
		if (!s->has_position || !s->apply_reflections) {
			s->assigned = nullptr;
			s->group = nullptr;
			continue;
		}
		float x = s->x, y = s->y, z = s->z;
		float distance = sqrt((x - lx) * (x - lx) + (y - ly) * (y - ly) + (z - lz) * (z - lz));
		candidates.push_back({s, x, y, z, distance, radius});
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
		for (int i = 0; i < pool; i++) { // A group left empty near the sound, for example one it just left, keeps its simulation and its tail, so rejoining it beats moving another group here.
			reflection_group* g = groups[i];
			if (g->members || !g->ready_at) continue;
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
// A second order Butterworth high-pass filter for each channel of interleaved audio, from the Audio EQ Cookbook.
struct highpass_filter {
	float cutoff = 0.0f, b0 = 1.0f, b1 = 0.0f, b2 = 0.0f, a1 = 0.0f, a2 = 0.0f;
	vector<float> state; // Two values per channel.
	void configure(float frequency, float sample_rate, int channels) {
		if (state.size() != (size_t)channels * 2) state.assign(channels * 2, 0.0f);
		if (frequency == cutoff) return;
		cutoff = frequency;
		const float w0 = 2.0f * 3.14159265f * frequency / sample_rate, cosw = cos(w0), alpha = sin(w0) / (2.0f * 0.70710678f), a0 = 1.0f + alpha;
		b0 = (1.0f + cosw) / 2.0f / a0;
		b1 = -(1.0f + cosw) / a0;
		b2 = b0;
		a1 = -2.0f * cosw / a0;
		a2 = (1.0f - alpha) / a0;
	}
	void process(float* audio, unsigned int frames, int channels) {
		for (unsigned int i = 0; i < frames; i++) {
			for (int c = 0; c < channels; c++) {
				float& z1 = state[c * 2];
				float& z2 = state[c * 2 + 1];
				const float x = audio[i * channels + c], y = b0 * x + z1;
				z1 = b1 * x - a1 * y + z2;
				z2 = b2 * x - a2 * y;
				audio[i * channels + c] = y;
			}
		}
	}
};

class environment_return : public audio_plugin_node_interface {
	environment_core* core;
	audio_config config;
	bool mixer_wanted = false;
	ipl_ref<api::IReflectionMixer> mixer;
	ipl_ref<api::IAmbisonicsDecodeEffect> decode_effect;
	ipl_buffer ambisonics_buffer, decoded_buffer;
	highpass_filter highpass;
public:
	plugin_node* node; // Owns this.
	environment_return(environment_core* core) : core(core) {
		core->retain();
		node = nvgt_audio_plugin_node_create(this, 1, 1, MA_NODE_FLAG_CONTINUOUS_PROCESSING | MA_NODE_FLAG_ALLOW_NULL_INPUT, core->engine);
	}
	~environment_return() {
		core->audio_mixer = nullptr;
		mixer.reset();
		core->release();
	}
	void on_node_destroyed(plugin_node* destroyed) override { delete this; }
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
		g->tail = g->effect_tail = false;
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
	void process(audio_plugin_node_interface* self, const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
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
			highpass.configure(cutoff, (float)core->audio_settings.samplingRate, core->channels);
			highpass.process(out, frames, core->channels);
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
			g->tail = g->effect_tail = false;
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
			const bool effect_tail = state == IPL_AUDIOEFFECTSTATE_TAILREMAINING;
			bool decode_tail = false;
			if (!mixer) {
				decode_tail = g->decode->apply(&decode, &ambisonics_buffer.b, &decoded_buffer.b) == IPL_AUDIOEFFECTSTATE_TAILREMAINING;
				add_decoded(out, frames);
			}
			if (!send_active && !effect_tail && g->effect_tail) g->effect->reset(); // Steam Audio's convolution keeps the input it was given after its tail has ended, and would play that again with the group's next input. Only the reflection effect's own tail counts, as the decoder's can outlast it.
			g->effect_tail = send_active || effect_tail;
			g->tail = effect_tail || decode_tail;
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
audio_node* create_environment_return(environment_core* core) {
	environment_return* ret = new environment_return(core);
	if (ret->node) return ret->node;
	delete ret;
	return nullptr;
}
