/* environment_script.cpp - the script facing sound_environment and sound_environment_source, see environment.h
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
#include <scripthandle.h>
#include <string>
#include "environment.h"

class environment_attachment_handler : public reverb3d_attachment_handler {
	environment_core* core;
public:
	environment_attachment_handler(environment_core* core) : core(core) { core->retain(); }
	~environment_attachment_handler() { core->release(); }
	audio_node* create_attachment(reverb3d* verb, mixer* source) override {
		environment_source* s = new environment_source(core);
		if (s->node) return s->node; // The node owns the source.
		s->release();
		return nullptr;
	}
	void update_attachment(reverb3d* verb, audio_node* attachment, const audio_spatialization_parameters& params) override { if (environment_source* s = environment_source::from_node(attachment)) s->update_position(params); }
};

// The script facing environment.
class sound_environment {
	atomic<int> refcount = 1;
	environment_core* core;
	reverb3d* verb;
	CScriptHandle raycaster;
public:
	sound_environment(audio_engine* engine) {
		if (!engine) engine = phonon_default_engine();
		if (!engine || !phonon_init()) throw runtime_error("Steam Audio could not be initialized");
		core = new environment_core(engine);
		audio_node* ret = create_environment_return(core);
		verb = ret ? nvgt_reverb3d_create_with_handler(new environment_attachment_handler(core), ret, nullptr, engine) : nullptr;
		if (ret) ret->release(); // The reverb3d owns it through its output connection.
		if (!verb) {
			core->release();
			throw runtime_error("the environment's reverb3d could not be created");
		}
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
		environment_source* s = environment_source::from_node(m->get_reverb3d_attachment());
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
	float get_reflection_group_size() const { return core->reflection_group_size; }
	void set_reflection_group_size(float v) { core->reflection_group_size = clamp(v, 0.0f, 1000.0f); }
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
	ENV_PROPERTY(float, reflection_group_size)
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
