/* sound.cpp - sound system implementation code
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

#define NOMINMAX
#include <memory>
#include <string>
#include <thread>
#include <vector>
#include <Poco/FileStream.h>
#include <Poco/Format.h>
#include <Poco/MemoryStream.h>
#include <angelscript.h>
#include <scriptarray.h>
#include "misc_functions.h" // script_memory_buffer
#include "nvgt.h" // g_ScriptEngine
#include "nvgt_angelscript.h" // get_array_type
#include "nvgt_plugin.h"      // pack_interface
#include "sound.h"
#include "sound_nodes.h"
#include "pack.h"
#include <miniaudio_wdl_resampler.h>
#include <atomic>
#include <utility>
#include <cstdint>
#include <miniaudio_libvorbis.h>
#include <iostream>
using namespace std;

class sound_impl;
void wait(int ms);
// Globals, currently NVGT does not support instanciating multiple miniaudio contexts and NVGT provides a global sound engine.
static ma_context g_sound_context;
audio_engine *g_audio_engine = nullptr;
static std::atomic_flag g_soundsystem_initialized;
std::atomic<ma_result> g_soundsystem_last_error = MA_SUCCESS;
static std::unique_ptr<sound_service> g_sound_service;
// These slots are what you use to refer to protocols (which are data sources like archives) and filters (which are transformations like encryption) after they've been plugged into the sound service.
static size_t g_encryption_filter_slot = 0;
static size_t g_pack_protocol_slot = 0;
static size_t g_memory_protocol_slot = 0;
static std::vector<ma_decoding_backend_vtable *> g_decoders;
bool add_decoder(ma_decoding_backend_vtable *vtable) {
	try {
		g_decoders.push_back(vtable);
		return true;
	} catch (std::exception &) {
		return false;
	}
}
bool init_sound() {
	if (g_soundsystem_initialized.test())
		return true;
	if ((g_soundsystem_last_error = ma_context_init(nullptr, 0, nullptr, &g_sound_context)) != MA_SUCCESS)
		return false;
	g_sound_service = sound_service::make();
	if (g_sound_service == nullptr) {
		ma_context_uninit(&g_sound_context);
		return false;
	}
	// Register encryption support:
	g_sound_service->register_filter(encryption_filter::get_instance(), g_encryption_filter_slot);
	// And access to packs, et al:
	g_sound_service->register_protocol(pack_protocol::get_instance(), g_pack_protocol_slot);
	g_sound_service->register_protocol(memory_protocol::get_instance(), g_memory_protocol_slot);
	// Install default decoders into miniaudio.
	add_decoder(ma_decoding_backend_libvorbis);
	g_soundsystem_initialized.test_and_set();
	refresh_audio_devices();
	g_audio_engine = new_audio_engine(audio_engine::PERCENTAGE_ATTRIBUTES);
	return true;
}
void uninit_sound() {
	if (!g_soundsystem_initialized.test())
		return;
	if (g_audio_engine != nullptr) {
		g_audio_engine->release();
		g_audio_engine = nullptr;
	}
}

// audio device enumeration, we'll just maintain a global list of available devices, vectors of ma_device_info structures for the c++ side and CScriptArrays of device names on the Angelscript side. It is important that the data in these arrays is index aligned.
static vector<ma_device_info> g_sound_input_devices, g_sound_output_devices;
static CScriptArray *g_sound_script_input_devices = nullptr, *g_sound_script_output_devices = nullptr;
ma_bool32 ma_device_enum_callback(ma_context * /*ctx*/, ma_device_type type, const ma_device_info *info, void * /*user*/) {
	string devname;
	if (type == ma_device_type_playback) {
		g_sound_output_devices.push_back(*info);
		g_sound_script_output_devices->InsertLast(&(devname = info->name));
	} else if (type == ma_device_type_capture) {
		g_sound_input_devices.push_back(*info);
		g_sound_script_input_devices->InsertLast(&(devname = info->name));
	}
	return MA_TRUE;
}
bool refresh_audio_devices() {
	if (!g_soundsystem_initialized.test() && !init_sound())
		return false;
	g_sound_output_devices.clear();
	g_sound_input_devices.clear();
	if (!g_sound_script_output_devices)
		g_sound_script_output_devices = CScriptArray::Create(get_array_type("array<string>"));
	else
		g_sound_script_output_devices->Resize(0);
	if (!g_sound_script_input_devices)
		g_sound_script_input_devices = CScriptArray::Create(get_array_type("array<string>"));
	else
		g_sound_script_input_devices->Resize(0);
	return (g_soundsystem_last_error = ma_context_enumerate_devices(&g_sound_context, ma_device_enum_callback, nullptr)) == MA_SUCCESS;
}
CScriptArray *get_sound_input_devices() {
	if (!init_sound())
		return CScriptArray::Create(get_array_type("array<string>")); // Better to return an empty array instead of null for now.
	return g_sound_script_input_devices;
}
CScriptArray *get_sound_output_devices() {
	if (!init_sound())
		return CScriptArray::Create(get_array_type("array<string>"));
	return g_sound_script_output_devices;
}

reactphysics3d::Vector3 ma_vec3_to_rp_vec3(const ma_vec3f &v) { return reactphysics3d::Vector3(v.x, v.y, v.z); }

// The following function based on ma_sound_get_direction_to_listener.
MA_API float ma_sound_get_distance_to_listener(const ma_sound *pSound) {
	ma_vec3f relativePos;
	if (pSound == NULL)
		return FLT_MAX;
	ma_engine *pEngine = ma_sound_get_engine(pSound);
	if (pEngine == NULL)
		return FLT_MAX;
	ma_spatializer_get_relative_position_and_direction(&pSound->engineNode.spatializer, &pEngine->listeners[ma_sound_get_listener_index(pSound)], &relativePos, NULL);
	return sqrt(pow(relativePos.x, 2) + pow(relativePos.y, 2) + pow(relativePos.z, 2));
}

template <class A, class B>
static B *op_cast(A *from) {
	B *casted = dynamic_cast<B *>(from);
	if (!casted)
		return nullptr;
	casted->duplicate();
	return casted;
}

// BGT seems to have used db for it's pan, we need to emulate that if the user chooses to enable backward compatibility options.
float pan_linear_to_db(float linear) {
	linear = clamp(linear, -1.0f, 1.0f);
	float db = ma_volume_linear_to_db(linear > 0 ? 1.0f - linear : linear + 1.0f);
	return linear > 0 ? db * -1.0f : db;
}
float pan_db_to_linear(float db) {
	db = clamp(db, -100.0f, 100.0f);
	float l = ma_volume_db_to_linear(fabs(db) * -1.0f);
	return db > 0 ? 1.0f - l : -1.0f + l;
}
// Callbacks for MiniAudio to write raw PCM to wav in memory.
ma_result wav_write_proc(ma_encoder *pEncoder, const void *pBufferIn, size_t bytesToWrite, size_t *pBytesWritten) {
	std::ostream *stream = static_cast<std::ostream *>(pEncoder->pUserData);
	stream->write((const char *)pBufferIn, bytesToWrite);
	*pBytesWritten = bytesToWrite;
	return MA_SUCCESS;
}
ma_result wav_seek_proc(ma_encoder *pEncoder, ma_int64 offset, ma_seek_origin origin) {
	if (origin != ma_seek_origin_start)
		return MA_NOT_IMPLEMENTED;
	std::ostream *stream = static_cast<std::ostream *>(pEncoder->pUserData);
	stream->seekp(offset);
	if (!stream->good())
		return MA_ERROR;
	return MA_SUCCESS;
}

// Miniaudio objects must be allocated on the heap as nvgt's API introduces the concept of an uninitialized sound, which a stack based system would make more difficult to implement.
class audio_engine_impl final : public audio_engine {
	std::unique_ptr<ma_engine> engine;
	std::unique_ptr<ma_resource_manager> resource_manager;
	std::unique_ptr<ma_device> device;
	std::atomic<asIScriptFunction*> script_data_callback;
	audio_node *engine_endpoint; // Upon engine creation we'll call ma_engine_get_endpoint once so as to avoid creating more than one of our wrapper objects when our engine->get_endpoint() function is called.
	int refcount;
	static void data_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount) {
		audio_engine_impl* engine = reinterpret_cast<audio_engine_impl*>(pDevice->pUserData);
		engine->duplicate();
		ma_uint64 frames_read;
		engine->read(pOutput, frameCount, &frames_read);
		if (engine->script_data_callback) {
			asIScriptContext* ctx = g_ScriptEngine->RequestContext();
			if (!ctx || ctx->Prepare(engine->script_data_callback) < 0) {
				engine->release();
				return; // Todo: Maybe find a way to log error state here?
			}
			script_memory_buffer buf(g_ScriptEngine->GetTypeInfoByDecl("memory_buffer<float>"), pOutput, pDevice->playback.channels * frames_read); // Todo: Support all data formats.
			if (ctx->SetArgObject(0, engine) < 0 || ctx->SetArgObject(1, &buf) < 0 || ctx->SetArgQWord(2, frames_read) < 0) {
				engine->release();
				return;
			}
			ctx->Execute(); // Really not sure what to do about exceptions and errors taking place in the audio thread yet as we don't have a fully established logging facility set up.
			g_ScriptEngine->ReturnContext(ctx);
			engine->release();
		}
	}

public:
	engine_flags flags;
	audio_engine_impl(int flags)
		: audio_engine(),
		  engine(nullptr),
		  resource_manager(nullptr),
		  script_data_callback(nullptr),
		  engine_endpoint(nullptr),
		  flags(static_cast<engine_flags>(flags)),
		  refcount(1) {
		init_sound();
		engine = std::make_unique<ma_engine>();
		// We need a self-managed device because at least on Windows, we can't meet low-latency requirements without specific configurations.
		if ((flags & NO_DEVICE) == 0) {
			device = std::make_unique<ma_device>();
			ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
			// Just set to some hard-coded defaults for now.
			cfg.playback.channels = 2;
			cfg.playback.format = ma_format_f32;
			cfg.sampleRate = 0; // Let the device decide.
			cfg.periodSizeInFrames = SOUNDSYSTEM_FRAMESIZE;

			// Hook up high quality resampling, because we want the app to accommodate the device's sample rate, not the other way around.
			cfg.resampling.algorithm = ma_resample_algorithm_custom;
			cfg.resampling.pBackendVTable = &wdl_resampler_backend_vtable;
			cfg.wasapi.noAutoConvertSRC = true;

			cfg.dataCallback = data_callback;
			cfg.pUserData = this;
			g_soundsystem_last_error = ma_device_init(&g_sound_context, &cfg, &*device);
			if (g_soundsystem_last_error != MA_SUCCESS) {

				engine.reset();
				device.reset();
				return;
			}
		}

		// We need a self managed resource manager because we need to plug decoders in and configure the job thread count.
		{
			ma_resource_manager_config cfg = ma_resource_manager_config_init();
			// Attach the resource manager to the sound service so that it can receive audio from custom sources.
			cfg.pVFS = g_sound_service->get_vfs();
			// This is the sample rate that sounds will be resampled to if necessary during loading. We set this equal to whatever sample rate the device got. This is maximally efficient as long as the user doesn't switch devices to one that runs at a different rate. When they do, a single resampler kicks in.
			cfg.decodedSampleRate = device ? device->playback.internalSampleRate : 48000; // Todo: get rid of this magic number and set up a constructor argument.
			// Set the resampler used during decoding to a high quality one. At the time of writing this, this is relying on support that I added to MiniAudio myself and has not yet been merged upstream.
			cfg.resampling.algorithm = ma_resample_algorithm_custom;
			cfg.resampling.pBackendVTable = &wdl_resampler_backend_vtable;
			if (!g_decoders.empty()) {
				cfg.ppCustomDecodingBackendVTables = &g_decoders[0];
				cfg.customDecodingBackendCount = g_decoders.size();
			}
			cfg.jobThreadCount = std::thread::hardware_concurrency();
			resource_manager = std::make_unique<ma_resource_manager>();
			if ((g_soundsystem_last_error = ma_resource_manager_init(&cfg, &*resource_manager)) != MA_SUCCESS) {
				ma_device_uninit(&*device);
				device.reset();
				engine.reset();
				resource_manager.reset();
				return;
			}
		}
		ma_engine_config cfg = ma_engine_config_init();
		cfg.pContext = &g_sound_context; // Miniaudio won't let us quickly uninitilize then reinitialize a device sometimes when using the same context, so we won't manage it until we figure that out.
		cfg.pResourceManager = &*resource_manager;
		cfg.noAutoStart = (flags & NO_AUTO_START) ? MA_TRUE : MA_FALSE;
		cfg.periodSizeInFrames = SOUNDSYSTEM_FRAMESIZE; // Steam Audio requires fixed sized updates. We can make this not be a magic constant if anyone has some reason for wanting to change it.
		if ((flags & NO_DEVICE) == 0)
			cfg.pDevice = &*device;
		if ((g_soundsystem_last_error = ma_engine_init(&cfg, &*engine)) != MA_SUCCESS) {
			engine.reset();
			return;
		}
		// Set some default properties for spatialization.
		set_listener_direction(0, 0, 1, 0); // Y forward
		set_listener_world_up(0, 0, 0, 1);  // Z up
		engine_endpoint = new audio_node_impl(reinterpret_cast<ma_node_base *>(ma_engine_get_endpoint(&*engine)), this);
	}
	~audio_engine_impl() {
		if (script_data_callback) {
			script_data_callback.load()->Release();
			script_data_callback = nullptr;
		}
		if (device) {
			ma_device_stop(&*device);
			ma_device_uninit(&*device);
		}
		if (engine_endpoint)
			engine_endpoint->release();
		if (engine) {
			ma_engine_uninit(&*engine);
			engine = nullptr;
		}
		if (resource_manager)
			ma_resource_manager_uninit(&*resource_manager);
	}
	void duplicate() override { asAtomicInc(refcount); }
	void release() override {
		if (asAtomicDec(refcount) < 1)
			delete this;
	}
	ma_engine *get_ma_engine() const override { return engine.get(); }
	audio_node *get_endpoint() const override { return engine_endpoint; }
	int get_device() const override {
		if (!engine || flags & NO_DEVICE)
			return -1;
		ma_device *dev = ma_engine_get_device(&*engine);
		ma_device_info info;
		if (!dev || ma_device_get_info(dev, ma_device_type_playback, &info) != MA_SUCCESS)
			return -1;
		for (std::size_t i = 0; i < g_sound_output_devices.size(); i++) {
			if (memcmp(&g_sound_output_devices[i].id, &info.id, sizeof(ma_device_id)) == 0)
				return i;
		}
		return -1; // couldn't determine device?
	}
	bool set_device(int device) override {
		if (!engine || flags & NO_DEVICE || device < -1 || device >= int(g_sound_output_devices.size()))
			return false;
		ma_device *old_dev = ma_engine_get_device(&*engine);
		if (!old_dev || device > -1 && ma_device_id_equal(&old_dev->playback.id, &g_sound_output_devices[device].id))
			return false;
		ma_engine_stop(&*engine);
		ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
		if (device > -1)
			cfg.playback.pDeviceID = &g_sound_output_devices[device].id;
		cfg.playback.channels = old_dev->playback.channels;
		cfg.sampleRate = old_dev->sampleRate;
		cfg.periodSizeInFrames = SOUNDSYSTEM_FRAMESIZE;
		cfg.resampling.algorithm = ma_resample_algorithm_custom;
		cfg.resampling.pBackendVTable = &wdl_resampler_backend_vtable;
		cfg.wasapi.noAutoConvertSRC = true;
		cfg.notificationCallback = old_dev->onNotification;
		cfg.dataCallback = old_dev->onData;
		cfg.pUserData = old_dev->pUserData;
		ma_device_stop(old_dev);
		ma_device_uninit(old_dev);
		if ((g_soundsystem_last_error = ma_device_init(&g_sound_context, &cfg, old_dev)) != MA_SUCCESS)
			return false;
		return (g_soundsystem_last_error = ma_engine_start(&*engine)) == MA_SUCCESS;
	}
	bool read(void *buffer, unsigned long long frame_count, unsigned long long *frames_read) override { return engine ? (g_soundsystem_last_error = ma_engine_read_pcm_frames(&*engine, buffer, frame_count, frames_read)) == MA_SUCCESS : false; }
	CScriptArray *read_script(unsigned long long frame_count) override {
		if (!engine)
			return nullptr;
		CScriptArray *result = CScriptArray::Create(get_array_type("array<float>"), frame_count * ma_engine_get_channels(&*engine));
		unsigned long long frames_read;
		if (!read(result->GetBuffer(), frame_count, &frames_read)) {
			result->Resize(0);
			return result;
		}
		result->Resize(frames_read * ma_engine_get_channels(&*engine));
		return result;
	}
	void set_processing_callback(asIScriptFunction* cb) override {
		if (script_data_callback) script_data_callback.load()->Release();
		script_data_callback = cb;
	}
	asIScriptFunction* get_processing_callback() const override { return script_data_callback; }
	unsigned long long get_time() const override { return engine ? (flags & DURATIONS_IN_FRAMES ? get_time_in_frames() : get_time_in_milliseconds()) : 0; }
	bool set_time(unsigned long long time) override { return engine ? (flags & DURATIONS_IN_FRAMES) ? set_time_in_frames(time) : set_time_in_milliseconds(time) : false; }
	unsigned long long get_time_in_frames() const override { return engine ? ma_engine_get_time_in_pcm_frames(&*engine) : 0; }
	bool set_time_in_frames(unsigned long long time) override { return engine ? (g_soundsystem_last_error = ma_engine_set_time_in_pcm_frames(&*engine, time)) == MA_SUCCESS : false; }
	unsigned long long get_time_in_milliseconds() const override { return engine ? ma_engine_get_time_in_milliseconds(&*engine) : 0; }
	bool set_time_in_milliseconds(unsigned long long time) override { return engine ? (g_soundsystem_last_error = ma_engine_set_time_in_milliseconds(&*engine, time)) == MA_SUCCESS : false; }
	int get_channels() const override { return engine ? ma_engine_get_channels(&*engine) : 0; }
	int get_sample_rate() const override { return engine ? ma_engine_get_sample_rate(&*engine) : 0; }
	bool start() override { return engine ? (ma_engine_start(&*engine)) == MA_SUCCESS : false; }
	bool stop() override { return engine ? (ma_engine_stop(&*engine)) == MA_SUCCESS : false; }
	bool set_volume(float volume) override { return engine ? (g_soundsystem_last_error = ma_engine_set_volume(&*engine, volume)) == MA_SUCCESS : false; }
	float get_volume() const override { return engine ? ma_engine_get_volume(&*engine) : 0; }
	bool set_gain(float db) override { return engine ? (g_soundsystem_last_error = ma_engine_set_gain_db(&*engine, db)) == MA_SUCCESS : false; }
	float get_gain() const override { return engine ? ma_engine_get_gain_db(&*engine) : 0; }
	unsigned int get_listener_count() const override { return engine ? ma_engine_get_listener_count(&*engine) : 0; }
	int find_closest_listener(float x, float y, float z) const override { return engine ? ma_engine_find_closest_listener(&*engine, x, y, z) : -1; }
	int find_closest_listener_vector(const reactphysics3d::Vector3 &position) const override { return engine ? ma_engine_find_closest_listener(&*engine, position.x, position.y, position.z) : -1; }
	void set_listener_position(unsigned int index, float x, float y, float z) override {
		if (engine)
			ma_engine_listener_set_position(&*engine, index, x, y, z);
		set_sound_position_changed();
	}
	void set_listener_position_vector(unsigned int index, const reactphysics3d::Vector3 &position) override {
		if (engine)
			ma_engine_listener_set_position(&*engine, index, position.x, position.y, position.z);
		set_sound_position_changed();
	}
	reactphysics3d::Vector3 get_listener_position(unsigned int index) const override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_position(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_direction(unsigned int index, float x, float y, float z) override {
		if (engine)
			ma_engine_listener_set_direction(&*engine, index, x, y, z);
		set_sound_position_changed();
	}
	void set_listener_direction_vector(unsigned int index, const reactphysics3d::Vector3 &direction) override {
		if (engine)
			ma_engine_listener_set_direction(&*engine, index, direction.x, direction.y, direction.z);
		set_sound_position_changed();
	}
	reactphysics3d::Vector3 get_listener_direction(unsigned int index) const override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_direction(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_velocity(unsigned int index, float x, float y, float z) override {
		if (engine)
			ma_engine_listener_set_velocity(&*engine, index, x, y, z);
	}
	void set_listener_velocity_vector(unsigned int index, const reactphysics3d::Vector3 &velocity) override {
		if (engine)
			ma_engine_listener_set_velocity(&*engine, index, velocity.x, velocity.y, velocity.z);
	}
	reactphysics3d::Vector3 get_listener_velocity(unsigned int index) const override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_velocity(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_cone(unsigned int index, float inner_radians, float outer_radians, float outer_gain) override {
		if (engine)
			ma_engine_listener_set_cone(&*engine, index, inner_radians, outer_radians, outer_gain);
	}
	void get_listener_cone(unsigned int index, float *inner_radians, float *outer_radians, float *outer_gain) const override {
		if (engine)
			ma_engine_listener_get_cone(&*engine, index, inner_radians, outer_radians, outer_gain);
	}
	void set_listener_world_up(unsigned int index, float x, float y, float z) override {
		if (engine)
			ma_engine_listener_set_world_up(&*engine, index, x, y, z);
		set_sound_position_changed();
	}
	void set_listener_world_up_vector(unsigned int index, const reactphysics3d::Vector3 &world_up) override {
		if (engine)
			ma_engine_listener_set_world_up(&*engine, index, world_up.x, world_up.y, world_up.z);
		set_sound_position_changed();
	}
	reactphysics3d::Vector3 get_listener_world_up(unsigned int index) const override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_world_up(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_enabled(unsigned int index, bool enabled) override {
		if (engine)
			ma_engine_listener_set_enabled(&*engine, index, enabled);
		set_sound_position_changed();
	}
	bool get_listener_enabled(unsigned int index) const override { return ma_engine_listener_is_enabled(&*engine, index); }
	bool play_through_node(const string &filename, audio_node *node, unsigned int bus_index) override { return engine ? (g_soundsystem_last_error = ma_engine_play_sound_ex(&*engine, filename.c_str(), node ? node->get_ma_node() : nullptr, bus_index)) == MA_SUCCESS : false; }
	bool play(const string &filename, mixer *mixer) override { return engine ? (ma_engine_play_sound(&*engine, filename.c_str(), mixer ? mixer->get_ma_sound() : nullptr)) == MA_SUCCESS : false; }
	mixer *new_mixer() override { return ::new_mixer(this); }
	sound *new_sound() override { return ::new_sound(this); }
};
class mixer_impl : public audio_node_impl, public virtual mixer {
	friend class audio_node_impl;
	// In miniaudio, a sound_group is really just a sound. A typical ma_sound_group_x function looks like float ma_sound_group_get_pan(const ma_sound_group* pGroup) { return ma_sound_get_pan(pGroup); }.
	// Furthermore ma_sound_group is just a typedef for ma_sound. As such, for the sake of less code and better inheritance, we will directly call the ma_sound APIs in this class even though it deals with sound groups and not sounds.
protected:
	audio_engine_impl *engine;
	unique_ptr<ma_sound> snd;
	mutable mutex hrtf_toggle_mtx;
	mixer *parent_mixer;
	mixer_monitor_node *monitor;
	phonon_binaural_node *hrtf;
	bool hrtf_desired;
	audio_node *get_input_node() { return parent_mixer ? parent_mixer : engine->get_endpoint(); }
	audio_node *get_output_node() { return hrtf ? hrtf : dynamic_cast<audio_node *>(monitor); }

public:
	mixer_impl() : audio_node_impl(), snd(nullptr), parent_mixer(nullptr), monitor(mixer_monitor_node::create(this)), hrtf(nullptr), hrtf_desired(true) {}
	mixer_impl(audio_engine *e, bool sound_group = true) : engine(static_cast<audio_engine_impl *>(e)), audio_node_impl(), snd(nullptr), parent_mixer(nullptr), monitor(mixer_monitor_node::create(this)), hrtf(nullptr), hrtf_desired(true) {
		init_sound();
		if (sound_group) {
			snd = make_unique<ma_sound>();
			ma_sound_group_init(e->get_ma_engine(), 0, nullptr, &*snd);
			node = (ma_node_base *)&*snd;
			audio_node_impl::attach_output_bus(0, monitor, 0);
		}
		// set_attenuation_model(ma_attenuation_model_linear); // Investigate why this doesn't seem to work even though ma_attenuation_linear returns a correctly attenuated gain.
		set_rolloff(0.75);
		set_directional_attenuation_factor(1);
		if (sound_group)
			play();
	}
	~mixer_impl() {
		std::unique_lock<mutex> lock(hrtf_toggle_mtx); // Insure hrtf isn't getting toggled at the time we begin detaching nodes.
		stop();
		if (monitor)
			monitor->release();
		if (parent_mixer)
			parent_mixer->release();
		if (hrtf)
			hrtf->release();
		if (snd)
			ma_sound_group_uninit(&*snd);
	}
	inline void duplicate() override { audio_node_impl::duplicate(); }
	inline void release() override { audio_node_impl::release(); }
	bool attach_output_bus(unsigned int output_bus_index, audio_node *input_bus, unsigned int input_bus_index) override { return get_output_node()->attach_output_bus(output_bus_index, input_bus, input_bus_index); }
	bool detach_output_bus(unsigned int output_bus_index) override { return get_output_node()->detach_output_bus(output_bus_index); }
	bool detach_all_output_buses() override { return get_output_node()->detach_all_output_buses(); }
	bool set_mixer(mixer *mix) override {
		if (mix == parent_mixer)
			return false;
		if (parent_mixer) {
			if (!detach_output_bus(0))
				return false;
			parent_mixer->release();
			parent_mixer = nullptr;
		}
		if (mix) {
			if (!attach_output_bus(0, mix, 0))
				return false;
			parent_mixer = mix;
			return true;
		} else
			return attach_output_bus(0, get_engine()->get_endpoint(), 0);
	}
	mixer *get_mixer() const override { return parent_mixer; }
	bool set_hrtf_internal(bool enable) override {
		unique_lock<mutex> lock(hrtf_toggle_mtx);
		if (hrtf && enable or !hrtf && !enable)
			return true;
		audio_node *i = get_input_node(), *o = get_output_node();
		if (enable) {
			if ((hrtf = phonon_binaural_node::create(engine, engine->get_channels(), engine->get_sample_rate())) == nullptr)
				return false;
			if (!hrtf->attach_output_bus(0, i, 0))
				return false;
			if (!o->attach_output_bus(0, hrtf, 0))
				return false;
			set_directional_attenuation_factor(0);
		} else {
			set_directional_attenuation_factor(1);
			if (!monitor->attach_output_bus(0, i, 0))
				return false; // This chain will become more complex as we add a builtin reverb node.
			hrtf->release();
			hrtf = nullptr;
		}
		return true;
	}
	bool set_hrtf(bool enable) override {
		hrtf_desired = enable;
		return get_global_hrtf()? set_hrtf_internal(enable) : true;
	}
	bool get_hrtf() const override { return hrtf != nullptr; }
	bool get_hrtf_desired() const override { return hrtf_desired; }
	audio_node *get_hrtf_node() const override { return hrtf; }
	bool play(bool reset_loop_state = true) override {
		if (snd == nullptr)
			return false;
		if (reset_loop_state)
			ma_sound_set_looping(&*snd, MA_FALSE);
		return (g_soundsystem_last_error = ma_sound_start(&*snd)) == MA_SUCCESS;
	}
	bool play_looped() override {
		if (snd == nullptr)
			return false;
		ma_sound_set_looping(&*snd, true);
		return (g_soundsystem_last_error = ma_sound_start(&*snd)) == MA_SUCCESS;
	}
	ma_sound *get_ma_sound() const override { return &*snd; }
	audio_engine *get_engine() const override { return engine; }
	bool stop() override { return snd ? (g_soundsystem_last_error = ma_sound_stop(&*snd)) == MA_SUCCESS : false; }
	void set_volume(float volume) override {
		if (snd)
			ma_sound_set_volume(&*snd, std::min((engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_volume_db_to_linear(volume) : volume), 1.0f));
	}
	float get_volume() const override { return snd ? (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_volume_linear_to_db(ma_sound_get_volume(&*snd)) : ma_sound_get_volume(&*snd)) : NAN; }
	void set_pan(float pan) override {
		if (snd)
			ma_sound_set_pan(&*snd, engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? pan_db_to_linear(pan) : pan);
	}
	float get_pan() const override {
		return snd ? (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? pan_linear_to_db(ma_sound_get_pan(&*snd)) : ma_sound_get_pan(&*snd)) : NAN;
	}
	void set_pan_mode(ma_pan_mode mode) override {
		if (snd)
			ma_sound_set_pan_mode(&*snd, mode);
	}
	ma_pan_mode get_pan_mode() const override {
		return snd ? ma_sound_get_pan_mode(&*snd) : ma_pan_mode_balance;
	}
	void set_pitch(float pitch) override {
		if (snd)
			ma_sound_set_pitch(&*snd, engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? pitch / 100.0f : pitch);
	}
	float get_pitch() const override {
		return snd ? (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_sound_get_pitch(&*snd) * 100 : ma_sound_get_pitch(&*snd)) : NAN;
	}
	void set_spatialization_enabled(bool enabled) override {
		if (snd)
			ma_sound_set_spatialization_enabled(&*snd, enabled);
		set_hrtf_internal(enabled && hrtf_desired && get_global_hrtf()); // If desired, enable HRTF if we are enabling spatialization.
	}
	bool get_spatialization_enabled() const override {
		if (snd)
			return ma_sound_is_spatialization_enabled(&*snd);
		return false;
	}
	void set_pinned_listener(unsigned int index) override {
		if (snd)
			ma_sound_set_pinned_listener_index(&*snd, index);
	}
	unsigned int get_pinned_listener() const override {
		return snd ? ma_sound_get_pinned_listener_index(&*snd) : 0;
	}
	unsigned int get_listener() const override {
		return snd ? ma_sound_get_listener_index(&*snd) : 0;
	}
	reactphysics3d::Vector3 get_direction_to_listener() const override {
		if (!snd)
			return reactphysics3d::Vector3();
		const auto dir = ma_sound_get_direction_to_listener(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(dir.x, dir.y, dir.z);
		return res;
	}
	float get_distance_to_listener() const override { return snd ? ma_sound_get_distance_to_listener(&*snd) : FLT_MAX; }
	void set_position_3d(float x, float y, float z) override {
		if (!snd)
			return;
		if (monitor)
			monitor->set_position_changed();
		set_spatialization_enabled(true);
		return ma_sound_set_position(&*snd, x, y, z);
	}
	void set_position_3d_vector(const reactphysics3d::Vector3& position) override { set_position_3d(position.x, position.y, position.z); }
	reactphysics3d::Vector3 get_position_3d() const override {
		if (!snd)
			return reactphysics3d::Vector3();
		const auto pos = ma_sound_get_position(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(pos.x, pos.y, pos.z);
		return res;
	}
	void set_direction(float x, float y, float z) override {
		if (!snd)
			return;
		if (monitor)
			monitor->set_position_changed();
		return ma_sound_set_direction(&*snd, x, y, z);
	}
	void set_direction_vector(const reactphysics3d::Vector3& direction) override { set_direction(direction.x, direction.y, direction.z); }
	reactphysics3d::Vector3 get_direction() const override {
		if (!snd)
			return reactphysics3d::Vector3();
		const auto dir = ma_sound_get_direction(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(dir.x, dir.y, dir.z);
		return res;
	}
	void set_velocity(float x, float y, float z) override {
		if (!snd)
			return;
		return ma_sound_set_velocity(&*snd, x, y, z);
	}
	void set_velocity_vector(const reactphysics3d::Vector3& velocity) override { set_velocity(velocity.x, velocity.y, velocity.z); }
	reactphysics3d::Vector3 get_velocity() const override {
		if (!snd)
			return reactphysics3d::Vector3();
		const auto vel = ma_sound_get_velocity(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(vel.x, vel.y, vel.z);
		return res;
	}
	void set_attenuation_model(ma_attenuation_model model) override {
		if (snd)
			ma_sound_set_attenuation_model(&*snd, model);
	}
	ma_attenuation_model get_attenuation_model() const override {
		return snd ? ma_sound_get_attenuation_model(&*snd) : ma_attenuation_model_none;
	}
	void set_positioning(ma_positioning positioning) override {
		if (snd)
			ma_sound_set_positioning(&*snd, positioning);
		if (monitor)
			monitor->set_position_changed();
	}
	ma_positioning get_positioning() const override {
		return snd ? ma_sound_get_positioning(&*snd) : ma_positioning_absolute;
	}
	void set_rolloff(float rolloff) override {
		if (snd)
			ma_sound_set_rolloff(&*snd, rolloff);
	}
	float get_rolloff() const override {
		return snd ? ma_sound_get_rolloff(&*snd) : NAN;
	}
	void set_min_gain(float gain) override {
		if (snd)
			ma_sound_set_min_gain(&*snd, gain);
	}
	float get_min_gain() const override {
		return snd ? ma_sound_get_min_gain(&*snd) : NAN;
	}
	void set_max_gain(float gain) override {
		if (snd)
			ma_sound_set_max_gain(&*snd, gain);
	}
	float get_max_gain() const override {
		return snd ? ma_sound_get_max_gain(&*snd) : NAN;
	}
	void set_min_distance(float distance) override {
		if (snd)
			ma_sound_set_min_distance(&*snd, distance);
	}
	float get_min_distance() const override {
		return snd ? ma_sound_get_min_distance(&*snd) : NAN;
	}
	void set_max_distance(float distance) override {
		if (snd)
			ma_sound_set_max_distance(&*snd, distance);
	}
	float get_max_distance() const override {
		return snd ? ma_sound_get_max_distance(&*snd) : NAN;
	}
	void set_cone(float inner_radians, float outer_radians, float outer_gain) override {
		if (snd)
			ma_sound_set_cone(&*snd, inner_radians, outer_radians, outer_gain);
	}
	void get_cone(float *inner_radians, float *outer_radians, float *outer_gain) const override {
		if (snd)
			ma_sound_get_cone(&*snd, inner_radians, outer_radians, outer_gain);
		else {
			if (inner_radians)
				*inner_radians = NAN;
			if (outer_radians)
				*outer_radians = NAN;
			if (outer_gain)
				*outer_gain = NAN;
		}
	}
	void set_doppler_factor(float factor) override {
		if (snd)
			ma_sound_set_doppler_factor(&*snd, factor);
	}
	float get_doppler_factor() const override {
		return snd ? ma_sound_get_doppler_factor(&*snd) : NAN;
	}
	void set_directional_attenuation_factor(float factor) override {
		if (snd)
			ma_sound_set_directional_attenuation_factor(&*snd, factor);
	}
	float get_directional_attenuation_factor() const override {
		return snd ? ma_sound_get_directional_attenuation_factor(&*snd) : NAN;
	}
	void set_fade(float start_volume, float end_volume, ma_uint64 length) override {
		if (!snd)
			return;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			set_fade_in_frames(start_volume, end_volume, length);
		else
			set_fade_in_milliseconds(start_volume, end_volume, length);
	}
	void set_fade_in_frames(float start_volume, float end_volume, ma_uint64 frames) override {
		if (!snd)
			return;
		if (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES) {
			start_volume = start_volume == FLT_MAX ? -1 : ma_volume_db_to_linear(start_volume);
			end_volume = ma_volume_db_to_linear(end_volume);
		}
		ma_sound_set_fade_in_pcm_frames(&*snd, start_volume, end_volume, frames);
	}
	void set_fade_in_milliseconds(float start_volume, float end_volume, ma_uint64 milliseconds) override {
		if (!snd)
			return;
		if (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES) {
			start_volume = start_volume == FLT_MAX ? -1 : ma_volume_db_to_linear(start_volume);
			end_volume = ma_volume_db_to_linear(end_volume);
		}
		ma_sound_set_fade_in_milliseconds(&*snd, start_volume, end_volume, milliseconds);
	}
	float get_current_fade_volume() const override {
		return snd ? (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_volume_linear_to_db(ma_sound_get_current_fade_volume(&*snd)) : ma_sound_get_current_fade_volume(&*snd)) : NAN;
	}
	void set_start_time(ma_uint64 absolute_time) override {
		if (!snd)
			return;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			set_start_time_in_frames(absolute_time);
		else
			set_start_time_in_milliseconds(absolute_time);
	}
	void set_start_time_in_frames(ma_uint64 absolute_time) override {
		if (snd)
			ma_sound_set_start_time_in_pcm_frames(&*snd, absolute_time);
	}
	void set_start_time_in_milliseconds(ma_uint64 absolute_time) override {
		if (snd)
			ma_sound_set_start_time_in_milliseconds(&*snd, absolute_time);
	}
	void set_stop_time(ma_uint64 absolute_time) override {
		if (!snd)
			return;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			set_stop_time_in_frames(absolute_time);
		else
			set_stop_time_in_milliseconds(absolute_time);
	}
	void set_stop_time_in_frames(ma_uint64 absolute_time) override {
		if (snd)
			ma_sound_set_stop_time_in_pcm_frames(&*snd, absolute_time);
	}
	void set_stop_time_in_milliseconds(ma_uint64 absolute_time) override {
		if (snd)
			ma_sound_set_stop_time_in_milliseconds(&*snd, absolute_time);
	}
	ma_uint64 get_time() const override {
		return snd ? ((engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? get_time_in_frames() : get_time_in_milliseconds()) : 0;
	}
	ma_uint64 get_time_in_frames() const override {
		return snd ? ma_sound_get_time_in_pcm_frames(&*snd) : 0;
	}
	ma_uint64 get_time_in_milliseconds() const override {
		return snd ? ma_sound_get_time_in_milliseconds(&*snd) : 0ULL;
	}
	bool get_playing() const override {
		return snd ? ma_sound_is_playing(&*snd) : false;
	}
};
class sound_impl final : public mixer_impl, public virtual sound {
	// The following is so that MiniAudio can notify us when it finishes loading a sound. We also use a fence, but sometimes we just want to check without having to commit to blocking.
	typedef struct {
		ma_async_notification_callbacks cb;
		std::atomic_flag *pAtomicFlag;

	} async_notification_callbacks;
	std::string pcm_buffer;      // When loading from raw PCM (like TTS) we store the intermediate wav data here so we can take advantage of async loading to return quickly. Makes a substantial difference in the responsiveness of TTS calls.
	std::string loaded_filename; // Contains the loaded filename as passed in the load/stream method, used just for convenience.
	ma_fence fence;
	async_notification_callbacks notification_callbacks;
	mutable std::atomic_flag load_completed;
	bool paused;

public:
	static void async_notification_callback(ma_async_notification *pNotification) {
		async_notification_callbacks *anc = (async_notification_callbacks *)pNotification;
		anc->pAtomicFlag->test_and_set();
	}
	sound_impl(audio_engine *e) : paused(false), mixer_impl(static_cast < audio_engine_impl * > (e), false), pcm_buffer(), sound() {
		init_sound();
		snd = nullptr;
		ma_fence_init(&fence);
		notification_callbacks.cb.onSignal = &async_notification_callback;
		notification_callbacks.pAtomicFlag = &load_completed;
	}
	~sound_impl() {
		close();
		ma_fence_uninit(&fence);
	}
	bool load_special(const std::string &filename, const size_t protocol_slot = 0, directive_t protocol_directive = nullptr, const size_t filter_slot = 0, directive_t filter_directive = nullptr, ma_uint32 ma_flags = MA_SOUND_FLAG_DECODE) override {
		if (snd)
			close();
		snd = make_unique < ma_sound > ();
		// The sound service converts our file name into a "tripplet" which includes information about the origin an asset is expected to come from. This guarantees that we don't mistake assets from different origins as the same just because they have the same name.
		std::string triplet = g_sound_service->prepare_triplet(filename, protocol_slot, protocol_directive, filter_slot, filter_directive);
		if (triplet.empty()) {
			snd.reset();
			return false;
		}
		ma_sound_config cfg = ma_sound_config_init();
		ma_resource_manager_pipeline_notifications notifications = ma_resource_manager_pipeline_notifications_init();
		notifications.done.pFence = &fence;
		notifications.done.pNotification = &notification_callbacks;
		cfg.flags = ma_flags;
		cfg.pFilePath = triplet.c_str();
		cfg.initNotifications = notifications;
		/*
		MiniAudio currently returns an error code of MA_OUT_OF_MEMORY (-4) if sound initialization fails due to the job queue being at capacity.
		IMHO this is a poor choice of error code; MA_BUSY would be better as it conveys the temporary nature of the situation.
		I'll raise an issue with MA to see if he'd be okay with this change. For now we'll just wait a few milliseconds for the backlog to clear and fail permanently if we see multiple MA_OUT_OF_MEMORY conditions back  to back. This should give the job queue time
		*/
		for (int i = 0; i < 10; i++) {
			g_soundsystem_last_error = ma_sound_init_ex(engine->get_ma_engine(), &cfg, &*snd);
			if (g_soundsystem_last_error == MA_OUT_OF_MEMORY) {
				// See above; this is probably job queue backlog rather than an actual out of memory. Take a break and try again.
				wait(5);
				continue;
			}
			break; // Don't retry any other failure case.
		}
		// For the time being, give it one more try without any flags if we got -10 (MA_INVALID_FILE) because MA's support for loading mp3 is limited.
		if (g_soundsystem_last_error == MA_INVALID_FILE) {
			cfg.flags = 0;
			g_soundsystem_last_error = ma_sound_init_ex(engine->get_ma_engine(), &cfg, &*snd);
		}

		if (g_soundsystem_last_error != MA_SUCCESS)
			snd.reset();
		else {
			loaded_filename = filename;
			node = (ma_node_base *)&*snd;
			set_spatialization_enabled(false);                  // The user must call set_position_3d or manually enable spatialization or else their ambience and UI sounds will be spatialized.
			set_attenuation_model(ma_attenuation_model_linear); // If spatialization is enabled however lets use linear attenuation by default so that we focus more on hearing objects from further out in audio games as opposed to complete but hard to hear realism.
			audio_node_impl::attach_output_bus(0, monitor, 0);  // Connect the sound up to the node that monitors hrtf position changes etc.
			// If we didn't load our sound asynchronously or if we streamed it, then we simply mark it as load_completed or we'll end up with a deadlock at destruction time.
			if (!(cfg.flags & MA_SOUND_FLAG_ASYNC))
				load_completed.test_and_set();
		}
		// Sound service has to store data pertaining to our triplet, and this is the earliest point at which it's safe to clean that up.
		g_sound_service->cleanup_triplet(triplet);
		return g_soundsystem_last_error == MA_SUCCESS;
	}
	bool load(const string &filename, const pack_interface *pack_file) override {
		return load_special(filename, pack_file ? g_pack_protocol_slot : 0, pack_file ? std::shared_ptr < const pack_interface > (pack_file->make_immutable()) : nullptr, 0, nullptr, MA_SOUND_FLAG_DECODE | MA_SOUND_FLAG_ASYNC);
	}
	bool stream(const std::string &filename, const pack_interface *pack_file) override {
		return load_special(filename, pack_file ? g_pack_protocol_slot : 0, pack_file ? std::shared_ptr < const pack_interface > (pack_file->make_immutable()) : nullptr, 0, nullptr, MA_SOUND_FLAG_STREAM);
	}
	bool seek_in_milliseconds(unsigned long long offset) override { return snd ? (g_soundsystem_last_error = ma_sound_seek_to_pcm_frame(&*snd, offset * ma_engine_get_sample_rate(engine->get_ma_engine()) / 1000)) == MA_SUCCESS : false; }
	bool load_string(const std::string &data) override { return load_memory(data.data(), data.size()); }
	bool load_string_async(const std::string &data) override {
		// Same as load_pcm, but without the setup.
		pcm_buffer = data;
		return load_special(":quickstring", g_memory_protocol_slot, memory_protocol::directive(&pcm_buffer[0], pcm_buffer.size()), sound_service::null_filter_slot, nullptr, MA_SOUND_FLAG_DECODE | MA_SOUND_FLAG_ASYNC);
	}
	bool load_memory(const void *buffer, unsigned int size) override {
		return load_special("::memory", g_memory_protocol_slot, memory_protocol::directive(buffer, size));
	}
	bool load_pcm(void *buffer, unsigned int size, ma_format format, int samplerate, int channels) override {
		if (snd)
			close();
		pcm_buffer.clear();
		// At least for now, the strat here is just to write the PCM to wav and then load it the normal way.
		// Should optimization become necessary (this does result in a couple of copies), a protocol could be written that simulates its input having a RIFF header on it.
		pcm_buffer.resize(size + 44);
		if (!pcm_to_wav(buffer, size, format, samplerate, channels, &pcm_buffer[0]))
			return false;
		// At this point we can just use the sound service to load this. We use the low level API though because we need to be clear that no filters apply.
		// Also, our PCM buffer is a permanent class property so we can enjoy the speed of async loading.
		// Sam: Actually nno we can't right now, this causes the game to crash in the vfs read function on startup if sounds are playing while tts speaks. Haven't had time to debug this as I discovered it hours before an intended release.
		return load_special(":pcm", g_memory_protocol_slot, memory_protocol::directive(&pcm_buffer[0], pcm_buffer.size()), sound_service::null_filter_slot, nullptr, MA_SOUND_FLAG_DECODE | MA_SOUND_FLAG_ASYNC);
	}
	bool load_pcm_script(CScriptArray *buffer, int samplerate, int channels) override {
		if (!buffer)
			return false;
		ma_format format;
		if (buffer->GetElementTypeId() == asTYPEID_FLOAT)
			format = ma_format_f32;
		else if (buffer->GetElementTypeId() == asTYPEID_INT32)
			format = ma_format_s32;
		else if (buffer->GetElementTypeId() == asTYPEID_INT16)
			format = ma_format_s16;
		else if (buffer->GetElementTypeId() == asTYPEID_UINT8)
			format = ma_format_u8;
		else
			return false;
		return load_pcm(buffer->GetBuffer(), buffer->GetSize() * buffer->GetElementSize(), format, samplerate, channels);
	}
	bool is_load_completed() const override {
		return load_completed.test();
	}
	bool close() override {
		if (snd) {
			// It's possible that this sound could still be loading in a job thread when we try to destroy it. Unfortunately there isn't a way to cancel this, so we have to just wait.
			if (!load_completed.test())
				ma_fence_wait(&fence);
			ma_sound_uninit(&*snd);
			snd.reset();
			node = nullptr;
			pcm_buffer.resize(0);
			loaded_filename.clear();
			load_completed.clear();
			paused = false;
			return true;
		}
		return false;
	}
	const std::string &get_loaded_filename() const override { return loaded_filename; }
	bool get_active() override {
		return snd ? true : false;
	}
	bool get_paused() override {
		return snd ? !ma_sound_is_playing(&*snd) && paused : false;
	}
	bool play(bool reset_loop_state = true) override {
		paused = false;
		return mixer_impl::play(reset_loop_state);
	}
	bool play_looped() override {
		paused = false;
		return mixer_impl::play_looped();
	}
	bool play_wait() override {
		if (!play())
			return false;
		while (get_playing())
			wait(5);
		return true;
	}
	bool stop() override {
		paused = false;
		return mixer_impl::stop() && seek(0);
	}
	bool pause() override {
		if (snd) {
			g_soundsystem_last_error = ma_sound_stop(&*snd);
			if (g_soundsystem_last_error == MA_SUCCESS)
				paused = true;
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	bool pause_fade(unsigned long long length) override {
		return (engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? pause_fade_in_frames(length) : pause_fade_in_milliseconds(length);
	}
	bool pause_fade_in_frames(unsigned long long frames) override {
		if (snd) {
			g_soundsystem_last_error = ma_sound_stop_with_fade_in_pcm_frames(&*snd, frames);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	bool pause_fade_in_milliseconds(unsigned long long frames) override {
		if (snd) {
			g_soundsystem_last_error = ma_sound_stop_with_fade_in_milliseconds(&*snd, frames);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	void set_timed_fade(float start_volume, float end_volume, unsigned long long length, unsigned long long absolute_time) override {
		return (engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? set_timed_fade_in_frames(start_volume, end_volume, length, absolute_time) : set_timed_fade_in_milliseconds(start_volume, end_volume, length, absolute_time);
	}
	void set_timed_fade_in_frames(float start_volume, float end_volume, unsigned long long frames, unsigned long long absolute_time_in_frames) override {
		if (snd)
			ma_sound_set_fade_start_in_pcm_frames(&*snd, start_volume, end_volume, frames, absolute_time_in_frames);
	}
	void set_timed_fade_in_milliseconds(float start_volume, float end_volume, unsigned long long frames, unsigned long long absolute_time_in_frames) override {
		if (snd)
			ma_sound_set_fade_start_in_milliseconds(&*snd, start_volume, end_volume, frames, absolute_time_in_frames);
	}
	void set_stop_time_with_fade(unsigned long long absolute_time, unsigned long long fade_length) override {
		return (engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? set_stop_time_with_fade_in_frames(absolute_time, fade_length) : set_stop_time_with_fade_in_milliseconds(absolute_time, fade_length);
	}
	void set_stop_time_with_fade_in_frames(unsigned long long absolute_time, unsigned long long fade_length) override {
		if (snd)
			ma_sound_set_stop_time_with_fade_in_pcm_frames(&*snd, absolute_time, fade_length);
	}
	void set_stop_time_with_fade_in_milliseconds(unsigned long long absolute_time, unsigned long long fade_length) override {
		if (snd)
			ma_sound_set_stop_time_with_fade_in_milliseconds(&*snd, absolute_time, fade_length);
	}
	void set_looping(bool looping) override {
		if (snd)
			ma_sound_set_looping(&*snd, looping);
	}
	bool get_looping() override {
		return snd ? ma_sound_is_looping(&*snd) : false;
	}
	bool get_at_end() override {
		return snd ? ma_sound_at_end(&*snd) : false;
	}
	bool seek(unsigned long long position) override {
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			return seek_in_frames(position);
		else
			return seek_in_milliseconds(position);
	}
	bool seek_in_frames(unsigned long long position) override {
		if (snd) {
			g_soundsystem_last_error = ma_sound_seek_to_pcm_frame(&*snd, position);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	unsigned long long get_position() override {
		if (!snd)
			return 0;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			return get_position_in_frames();
		else
			return get_position_in_milliseconds();
	}
	unsigned long long get_position_in_frames() override {
		if (snd) {
			ma_uint64 pos = 0;
			g_soundsystem_last_error = ma_sound_get_cursor_in_pcm_frames(&*snd, &pos);
			return g_soundsystem_last_error == MA_SUCCESS ? pos : 0;
		}
		return 0;
	}
	unsigned long long get_position_in_milliseconds() override {
		if (snd) {
			float pos = 0.0f;
			g_soundsystem_last_error = ma_sound_get_cursor_in_seconds(&*snd, &pos);
			return g_soundsystem_last_error == MA_SUCCESS ? pos * 1000.0f : 0;
		}
		return 0;
	}
	unsigned long long get_length() override {
		if (!snd)
			return 0;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			return get_length_in_frames();
		else
			return get_length_in_milliseconds();
	}
	unsigned long long get_length_in_frames() override {
		if (snd) {
			ma_uint64 len;
			g_soundsystem_last_error = ma_sound_get_length_in_pcm_frames(&*snd, &len);
			return g_soundsystem_last_error == MA_SUCCESS ? len : 0;
		}
		return 0;
	}
	unsigned long long get_length_in_milliseconds() override {
		if (snd) {
			float len;
			g_soundsystem_last_error = ma_sound_get_length_in_seconds(&*snd, &len);
			return g_soundsystem_last_error == MA_SUCCESS ? len * 1000.0f : 0;
		}
		return 0;
	}
	bool get_data_format(ma_format *format, unsigned int *channels, unsigned int *sample_rate) override {
		if (snd) {
			g_soundsystem_last_error = ma_sound_get_data_format(&*snd, format, channels, sample_rate, nullptr, 0);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	// A completely pointless API here, but needed for code that relies on legacy BGT includes. Always returns 0.
	double get_pitch_lower_limit() override {
		return 0;
	}
};

audio_engine *new_audio_engine(int flags) { return new audio_engine_impl(flags); }
mixer *new_mixer(audio_engine *engine) { return new mixer_impl(engine); }
sound *new_sound(audio_engine *engine) { return new sound_impl(engine); }
mixer *new_global_mixer() {
	init_sound();
	return new mixer_impl(g_audio_engine);
}
sound *new_global_sound() {
	init_sound();
	return new sound_impl(g_audio_engine);
}
int get_sound_output_device() {
	init_sound();
	return g_audio_engine->get_device();
}
void set_sound_output_device(int device) {
	init_sound();
	g_audio_engine->set_device(device);
}
// Encryption.
void set_default_decryption_key(const std::string &key) {
	if (!init_sound())
		return;
	g_sound_service->set_filter_directive(g_encryption_filter_slot, std::make_shared < std::string > (key));
	g_sound_service->set_default_filter(key.empty() ? sound_service::null_filter_slot : g_encryption_filter_slot);
}
// Set default pack storage for future sounds. Null means go back to local file system.
// Note: a pack must be marked immutable in order to be used with sound service.
void set_sound_default_storage(pack_interface *obj) {
	if (!init_sound())
		return;
	if (obj == nullptr) {
		g_sound_service->set_default_protocol(sound_service::fs_protocol_slot);
		return;
	}
	g_sound_service->set_protocol_directive(g_pack_protocol_slot, std::shared_ptr < const pack_interface > (obj->make_immutable()));
	g_sound_service->set_default_protocol(g_pack_protocol_slot);
}
const pack_interface *get_sound_default_storage() {
	if (!init_sound() || !g_sound_service->is_default_protocol(g_pack_protocol_slot))
		return nullptr;
	std::shared_ptr < const pack_interface > obj = std::static_pointer_cast < const pack_interface>(g_sound_service->get_protocol_directive(g_pack_protocol_slot));
	if (!obj) return nullptr;
	return obj->get_mutable();
}
int get_soundsystem_last_error() { return g_soundsystem_last_error; }
void set_sound_master_volume(float db) {
	if (!g_soundsystem_initialized.test())
		return;
	if (db > 0 || db < -100)
		return;
	ma_engine_set_volume(g_audio_engine->get_ma_engine(), ma_volume_db_to_linear(db));
}
float get_sound_master_volume() {
	if (!g_soundsystem_initialized.test())
		return 0;
	return ma_volume_linear_to_db(ma_engine_get_volume(g_audio_engine->get_ma_engine()));
}
bool sound::pcm_to_wav(const void *buffer, unsigned int size, ma_format format, int samplerate, int channels, void *output) {
	int frame_size = 0;
	switch (format) {
		case ma_format_u8:
			frame_size = 1;
			break;
		case ma_format_s16:
			frame_size = 2;
			break;
		case ma_format_s24:
			frame_size = 3;
			break;
		case ma_format_s32:
			frame_size = 4;
			break;
		case ma_format_f32:
			frame_size = 4;
			break;
		default:
			return false;
	}
	frame_size *= channels;
	Poco::MemoryOutputStream stream((char *)output, size + 44);
	ma_encoder_config cfg = ma_encoder_config_init(ma_encoding_format_wav, format, channels, samplerate);
	ma_encoder encoder;
	g_soundsystem_last_error = ma_encoder_init(wav_write_proc, wav_seek_proc, &stream, &cfg, &encoder);
	if (g_soundsystem_last_error != MA_SUCCESS)
		return false;
	// Should be okay to push the content in one go:
	ma_uint64 frames_written;
	g_soundsystem_last_error = ma_encoder_write_pcm_frames(&encoder, buffer, size / frame_size, &frames_written);
	ma_encoder_uninit(&encoder);
	if (g_soundsystem_last_error != MA_SUCCESS)
		return false;
	return true;
}

template < class T, auto Function, typename ReturnType, typename... Args >
ReturnType virtual_call(T *object, Args... args) {
	return (object->*Function)(std::forward < Args > (args)...);
}
void RegisterSoundsystemEngine(asIScriptEngine *engine) {
	engine->RegisterObjectType("audio_engine", 0, asOBJ_REF);
	engine->RegisterFuncdef("void audio_engine_processing_callback(audio_engine@ engine, memory_buffer<float>& data, uint64 frames)");
	engine->RegisterObjectBehaviour("audio_engine", asBEHAVE_FACTORY, "audio_engine@ e(int flags)", asFUNCTION(new_audio_engine), asCALL_CDECL);
	engine->RegisterObjectBehaviour("audio_engine", asBEHAVE_ADDREF, "void f()", asFUNCTION((virtual_call < audio_engine, &audio_engine::duplicate, void >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("audio_engine", asBEHAVE_RELEASE, "void f()", asFUNCTION((virtual_call < audio_engine, &audio_engine::release, void >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "int get_device() const", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_device, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool set_device(int device)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_device, bool, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "audio_node@+ get_endpoint() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_endpoint, audio_node * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "float[]@ read(uint64 frame_count)", asFUNCTION((virtual_call < audio_engine, &audio_engine::read_script, CScriptArray *, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_processing_callback(audio_engine_processing_callback@ cb) property", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_processing_callback, void, asIScriptFunction*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "audio_engine_processing_callback@+ get_processing_callback() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_processing_callback, asIScriptFunction* >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "uint64 get_time() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_time, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool set_time(uint64 time)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_time, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "uint64 get_time_in_frames() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_time_in_frames, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool set_time_in_frames(uint64 time_frames)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_time_in_frames, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "uint64 get_time_in_milliseconds() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_time_in_milliseconds, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool set_time_in_milliseconds(uint64 time_ms)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_time_in_milliseconds, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "int get_channels() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_channels, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "int get_sample_rate() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_sample_rate, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool start()", asFUNCTION((virtual_call < audio_engine, &audio_engine::start, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool stop()", asFUNCTION((virtual_call < audio_engine, &audio_engine::stop, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool set_volume(float volume)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_volume, bool, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "float get_volume() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_volume, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool set_gain(float gain)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_gain, bool, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "float get_gain() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_gain, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "uint get_listener_count() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_listener_count, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "int find_closest_listener(float x, float y, float z) const", asFUNCTION((virtual_call < audio_engine, &audio_engine::find_closest_listener, int, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "int find_closest_listener(const vector&in position) const", asFUNCTION((virtual_call < audio_engine, &audio_engine::find_closest_listener_vector, int, const reactphysics3d::Vector3 & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_position(int index, float x, float y, float z)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_position, void, int, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_position(int index, const vector&in position)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_position_vector, void, int, const reactphysics3d::Vector3 & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "vector get_listener_position(int index) const", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_listener_position, reactphysics3d::Vector3, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_direction(int index, float x, float y, float z)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_direction, void, int, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_direction(int index, const vector&in direction)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_direction_vector, void, int, const reactphysics3d::Vector3 & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "vector get_listener_direction(int index) const", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_listener_direction, reactphysics3d::Vector3, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_velocity(int index, float x, float y, float z)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_velocity, void, int, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_velocity(int index, const vector&in velocity)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_velocity_vector, void, int, const reactphysics3d::Vector3 & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "vector get_listener_velocity(int index) const", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_listener_velocity, reactphysics3d::Vector3, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_cone(int index, float inner_radians, float outer_radians, float outer_gain)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_cone, void, int, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void get_listener_cone(int index, float&out inner_radians, float&out outer_radians, float&out outer_gain) const", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_listener_cone, void, int, float *, float *, float * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_world_up(int index, float x, float y, float z)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_world_up, void, int, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_world_up(int index, const vector&in world_up)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_world_up_vector, void, int, const reactphysics3d::Vector3 & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "vector get_listener_world_up(int index) const", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_listener_world_up, reactphysics3d::Vector3, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_listener_enabled(int index, bool enabled)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_listener_enabled, void, int, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool get_listener_enabled(int index) const", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_listener_enabled, bool, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool play(const string&in path, audio_node@ node, uint input_bus_index)", asFUNCTION((virtual_call < audio_engine, &audio_engine::play_through_node, bool, const string &, audio_node *, unsigned int >)), asCALL_CDECL_OBJFIRST);
	// the other play overload and the new_mixer/sound functions are registered later after the definitions of mixer and sound.
	engine->RegisterGlobalProperty("audio_engine@ sound_default_engine", (void*)&g_audio_engine);
}
template < class T >
inline void RegisterSoundsystemAudioNode(asIScriptEngine *engine, const std::string &type) {
	engine->RegisterObjectType(type.c_str(), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_ADDREF, "void f()", asFUNCTION((virtual_call < T, &T::duplicate, void >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_RELEASE, "void f()", asFUNCTION((virtual_call < T, &T::release, void >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_input_bus_count() const property", asFUNCTION((virtual_call < T, &T::get_input_bus_count, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_output_bus_count() const property", asFUNCTION((virtual_call < T, &T::get_output_bus_count, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_input_channels(uint bus) const", asFUNCTION((virtual_call < T, &T::get_input_channels, unsigned int, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_output_channels(uint bus) const", asFUNCTION((virtual_call < T, &T::get_output_channels, unsigned int, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool attach_output_bus(uint output_bus, audio_node@+ destination, uint destination_input_bus)", asFUNCTION((virtual_call < T, &T::attach_output_bus, bool, unsigned int, audio_node *, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool detach_output_bus(uint bus)", asFUNCTION((virtual_call < T, &T::detach_output_bus, bool, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool detach_all_output_buses()", asFUNCTION((virtual_call < T, &T::detach_all_output_buses, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_output_bus_volume(uint bus, float volume)", asFUNCTION((virtual_call < T, &T::set_output_bus_volume, bool, unsigned int, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_output_bus_volume(uint bus)", asFUNCTION((virtual_call < T, &T::get_output_bus_volume, float, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_state(audio_node_state state)", asFUNCTION((virtual_call < T, &T::set_state, bool, ma_node_state >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_node_state get_state()", asFUNCTION((virtual_call < T, &T::get_state, ma_node_state >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_state_time(audio_node_state state, uint64 time)", asFUNCTION((virtual_call < T, &T::set_state_time, bool, ma_node_state, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint64 get_state_time(uint64 global_time)", asFUNCTION((virtual_call < T, &T::get_state_time, unsigned long long, ma_node_state >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_node_state get_state_by_time(uint64 global_time)", asFUNCTION((virtual_call < T, &T::get_state_by_time, ma_node_state, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_node_state get_state_by_time_range(uint64 global_time_begin, uint64 global_time_end)", asFUNCTION((virtual_call < T, &T::get_state_by_time_range, ma_node_state, unsigned long long, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint64 get_time() const", asFUNCTION((virtual_call < T, &T::get_time, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_time(uint64 local_time)", asFUNCTION((virtual_call < T, &T::set_time, bool, ma_node_state >)), asCALL_CDECL_OBJFIRST);
	if constexpr (!std::is_same < T, audio_node >::value)
		engine->RegisterObjectMethod(type.c_str(), "audio_node@ opImplCast()", asFUNCTION((op_cast < T, audio_node >)), asCALL_CDECL_OBJFIRST);
}
template < class T >
void RegisterSoundsystemMixer(asIScriptEngine *engine, const string &type) {
	RegisterSoundsystemAudioNode < T > (engine, type);
	engine->RegisterObjectMethod(type.c_str(), "audio_engine@+ get_engine() const property", asFUNCTION((virtual_call < T, &T::get_engine, audio_engine * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_mixer(mixer@ parent_mixer)", asFUNCTION((virtual_call < T, &T::set_mixer, bool, mixer * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "mixer@+ get_mixer() const", asFUNCTION((virtual_call < T, &T::get_mixer, mixer * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_hrtf(bool hrtf = true)", asFUNCTION((virtual_call < T, &T::set_hrtf, bool, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_hrtf() const property", asFUNCTION((virtual_call < T, &T::get_hrtf, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_hrtf_desired() const property", asFUNCTION((virtual_call < T, &T::get_hrtf_desired, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool play(bool reset_loop_state = true)", asFUNCTION((virtual_call < T, &T::play, bool, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool play_looped()", asFUNCTION((virtual_call < T, &T::play_looped, bool >)), asCALL_CDECL_OBJFIRST);

	engine->RegisterObjectMethod(type.c_str(), "bool stop()", asFUNCTION((virtual_call < T, &T::stop, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_volume(float volume) property", asFUNCTION((virtual_call < T, &T::set_volume, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_volume() const property", asFUNCTION((virtual_call < T, &T::get_volume, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_pan(float pan) property", asFUNCTION((virtual_call < T, &T::set_pan, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_pan() const property", asFUNCTION((virtual_call < T, &T::get_pan, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_pan_mode(audio_pan_mode mode) property", asFUNCTION((virtual_call < T, &T::set_pan_mode, void, ma_pan_mode >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_pan_mode get_pan_mode() const property", asFUNCTION((virtual_call < T, &T::get_pan_mode, ma_pan_mode >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_pitch(float pitch) property", asFUNCTION((virtual_call < T, &T::set_pitch, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_pitch() const property", asFUNCTION((virtual_call < T, &T::get_pitch, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_spatialization_enabled(bool enabled) property", asFUNCTION((virtual_call < T, &T::set_spatialization_enabled, void, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_spatialization_enabled() const property", asFUNCTION((virtual_call < T, &T::get_spatialization_enabled, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_pinned_listener(uint index) property", asFUNCTION((virtual_call < T, &T::set_pinned_listener, void, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_pinned_listener() const property", asFUNCTION((virtual_call < T, &T::get_pinned_listener, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_listener() const property", asFUNCTION((virtual_call < T, &T::get_listener, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "vector get_direction_to_listener() const", asFUNCTION((virtual_call < T, &T::get_direction_to_listener, reactphysics3d::Vector3 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_distance_to_listener() const", asFUNCTION((virtual_call < T, &T::get_distance_to_listener, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_position_3d(float x, float y, float z)", asFUNCTION((virtual_call < T, &T::set_position_3d, void, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_position_3d(const vector&in position)", asFUNCTION((virtual_call < T, &T::set_position_3d_vector, void, const reactphysics3d::Vector3&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "vector get_position_3d() const", asFUNCTION((virtual_call < T, &T::get_position_3d, reactphysics3d::Vector3 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_direction(float x, float y, float z)", asFUNCTION((virtual_call < T, &T::set_direction, void, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_direction(const vector&in direction)", asFUNCTION((virtual_call < T, &T::set_direction_vector, void, const reactphysics3d::Vector3&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "vector get_direction() const", asFUNCTION((virtual_call < T, &T::get_direction, reactphysics3d::Vector3 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_velocity(float x, float y, float z)", asFUNCTION((virtual_call < T, &T::set_velocity, void, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_velocity(const vector&in velocity)", asFUNCTION((virtual_call < T, &T::set_velocity_vector, void, const reactphysics3d::Vector3&>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "vector get_velocity() const", asFUNCTION((virtual_call < T, &T::get_velocity, reactphysics3d::Vector3 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_attenuation_model(audio_attenuation_model model) property", asFUNCTION((virtual_call < T, &T::set_attenuation_model, void, ma_attenuation_model >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_attenuation_model get_attenuation_model() const property", asFUNCTION((virtual_call < T, &T::get_attenuation_model, ma_attenuation_model >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_positioning(audio_positioning_mode mode) property", asFUNCTION((virtual_call < T, &T::set_positioning, void, ma_positioning >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_positioning_mode get_positioning() const property", asFUNCTION((virtual_call < T, &T::get_positioning, ma_positioning >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_rolloff(float rolloff) property", asFUNCTION((virtual_call < T, &T::set_rolloff, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_rolloff() const property", asFUNCTION((virtual_call < T, &T::get_rolloff, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_min_gain(float gain) property", asFUNCTION((virtual_call < T, &T::set_min_gain, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_min_gain() const property", asFUNCTION((virtual_call < T, &T::get_min_gain, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_max_gain(float gain) property", asFUNCTION((virtual_call < T, &T::set_max_gain, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_max_gain() const property", asFUNCTION((virtual_call < T, &T::get_max_gain, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_min_distance(float distance) property", asFUNCTION((virtual_call < T, &T::set_min_distance, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_min_distance() const property", asFUNCTION((virtual_call < T, &T::get_min_distance, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_max_distance(float distance) property", asFUNCTION((virtual_call < T, &T::set_max_distance, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_max_distance() const property", asFUNCTION((virtual_call < T, &T::get_max_distance, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_cone(float inner_radians, float outer_radians, float outer_gain)", asFUNCTION((virtual_call < T, &T::set_cone, void, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void get_cone(float &out inner_radians, float &out outer_radians, float &out outer_gain)", asFUNCTION((virtual_call < T, &T::get_cone, void, float *, float *, float * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_doppler_factor(float factor) property", asFUNCTION((virtual_call < T, &T::set_doppler_factor, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_doppler_factor() const property", asFUNCTION((virtual_call < T, &T::get_doppler_factor, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_directional_attenuation_factor(float factor) property", asFUNCTION((virtual_call < T, &T::set_directional_attenuation_factor, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_directional_attenuation_factor() const property", asFUNCTION((virtual_call < T, &T::get_directional_attenuation_factor, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_fade(float start_volume, float end_volume, uint64 length)", asFUNCTION((virtual_call < T, &T::set_fade, void, float, float, ma_uint64 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_fade_in_frames(float start_volume, float end_volume, uint64 length_frames)", asFUNCTION((virtual_call < T, &T::set_fade_in_frames, void, float, float, ma_uint64 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_fade_in_milliseconds(float start_volume, float end_volume, uint64 length_ms)", asFUNCTION((virtual_call < T, &T::set_fade_in_milliseconds, void, float, float, ma_uint64 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_current_fade_volume() const property", asFUNCTION((virtual_call < T, &T::get_current_fade_volume, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_start_time(uint64 absolute_time) property", asFUNCTION((virtual_call < T, &T::set_start_time, void, ma_uint64 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_stop_time(uint64 absolute_time)", asFUNCTION((virtual_call < T, &T::set_stop_time, void, ma_uint64 >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_playing() const property", asFUNCTION((virtual_call < T, &T::get_playing, bool >)), asCALL_CDECL_OBJFIRST);
}
void RegisterSoundsystemNodes(asIScriptEngine *engine) {
	RegisterSoundsystemAudioNode < phonon_binaural_node > (engine, "phonon_binaural_node");
	engine->RegisterObjectBehaviour("phonon_binaural_node", asBEHAVE_FACTORY, "phonon_binaural_node@ n(audio_engine@ engine, int channels, int sample_rate, int frame_size = 0)", asFUNCTION(phonon_binaural_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_direction(float x, float y, float z, float distance)", asFUNCTION((virtual_call < phonon_binaural_node, &phonon_binaural_node::set_direction, void, float, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_direction(const vector&in direction, float distance)", asFUNCTION((virtual_call < phonon_binaural_node, &phonon_binaural_node::set_direction_vector, void, const reactphysics3d::Vector3 &, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_spatial_blend_max_distance(float max_distance)", asFUNCTION((virtual_call < phonon_binaural_node, &phonon_binaural_node::set_spatial_blend_max_distance, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("bool set_sound_global_hrtf(bool enabled)", asFUNCTION(set_global_hrtf), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_sound_global_hrtf() property", asFUNCTION(get_global_hrtf), asCALL_CDECL);
	RegisterSoundsystemAudioNode < splitter_node > (engine, "audio_splitter_node");
	engine->RegisterObjectBehaviour("audio_splitter_node", asBEHAVE_FACTORY, "audio_splitter_node@ n(audio_engine@ engine, int channels)", asFUNCTION(splitter_node::create), asCALL_CDECL);
}
void RegisterSoundsystem(asIScriptEngine *engine) {
	engine->RegisterEnum("audio_error_state");
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_SUCCESS", MA_SUCCESS);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_ERROR", MA_ERROR);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_INVALID_ARGS", MA_INVALID_ARGS);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_INVALID_OPERATION", MA_INVALID_OPERATION);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_OUT_OF_MEMORY", MA_OUT_OF_MEMORY);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_OUT_OF_RANGE", MA_OUT_OF_RANGE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_ACCESS_DENIED", MA_ACCESS_DENIED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_DOES_NOT_EXIST", MA_DOES_NOT_EXIST);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_ALREADY_EXISTS", MA_ALREADY_EXISTS);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_TOO_MANY_OPEN_FILES", MA_TOO_MANY_OPEN_FILES);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_INVALID_FILE", MA_INVALID_FILE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_TOO_BIG", MA_TOO_BIG);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_PATH_TOO_LONG", MA_PATH_TOO_LONG);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NAME_TOO_LONG", MA_NAME_TOO_LONG);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NOT_DIRECTORY", MA_NOT_DIRECTORY);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_IS_DIRECTORY", MA_IS_DIRECTORY);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_DIRECTORY_NOT_EMPTY", MA_DIRECTORY_NOT_EMPTY);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_AT_END", MA_AT_END);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NO_SPACE", MA_NO_SPACE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_BUSY", MA_BUSY);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_IO_ERROR", MA_IO_ERROR);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_INTERRUPT", MA_INTERRUPT);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_UNAVAILABLE", MA_UNAVAILABLE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_ALREADY_IN_USE", MA_ALREADY_IN_USE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_BAD_ADDRESS", MA_BAD_ADDRESS);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_BAD_SEEK", MA_BAD_SEEK);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_BAD_PIPE", MA_BAD_PIPE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_DEADLOCK", MA_DEADLOCK);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_TOO_MANY_LINKS", MA_TOO_MANY_LINKS);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NOT_IMPLEMENTED", MA_NOT_IMPLEMENTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NO_MESSAGE", MA_NO_MESSAGE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_BAD_MESSAGE", MA_BAD_MESSAGE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NO_DATA_AVAILABLE", MA_NO_DATA_AVAILABLE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_INVALID_DATA", MA_INVALID_DATA);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_TIMEOUT", MA_TIMEOUT);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NO_NETWORK", MA_NO_NETWORK);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NOT_UNIQUE", MA_NOT_UNIQUE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NOT_SOCKET", MA_NOT_SOCKET);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NO_ADDRESS", MA_NO_ADDRESS);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_BAD_PROTOCOL", MA_BAD_PROTOCOL);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_PROTOCOL_UNAVAILABLE", MA_PROTOCOL_UNAVAILABLE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_PROTOCOL_NOT_SUPPORTED", MA_PROTOCOL_NOT_SUPPORTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_PROTOCOL_FAMILY_NOT_SUPPORTED", MA_PROTOCOL_FAMILY_NOT_SUPPORTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_ADDRESS_FAMILY_NOT_SUPPORTED", MA_ADDRESS_FAMILY_NOT_SUPPORTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_SOCKET_NOT_SUPPORTED", MA_SOCKET_NOT_SUPPORTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_CONNECTION_RESET", MA_CONNECTION_RESET);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_ALREADY_CONNECTED", MA_ALREADY_CONNECTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NOT_CONNECTED", MA_NOT_CONNECTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_CONNECTION_REFUSED", MA_CONNECTION_REFUSED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NO_HOST", MA_NO_HOST);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_IN_PROGRESS", MA_IN_PROGRESS);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_CANCELLED", MA_CANCELLED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_MEMORY_ALREADY_MAPPED", MA_MEMORY_ALREADY_MAPPED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_CRC_MISMATCH", MA_CRC_MISMATCH);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_FORMAT_NOT_SUPPORTED", MA_FORMAT_NOT_SUPPORTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_DEVICE_TYPE_NOT_SUPPORTED", MA_DEVICE_TYPE_NOT_SUPPORTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_SHARE_MODE_NOT_SUPPORTED", MA_SHARE_MODE_NOT_SUPPORTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NO_BACKEND", MA_NO_BACKEND);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_NO_DEVICE", MA_NO_DEVICE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_API_NOT_FOUND", MA_API_NOT_FOUND);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_INVALID_DEVICE_CONFIG", MA_INVALID_DEVICE_CONFIG);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_LOOP", MA_LOOP);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_BACKEND_NOT_ENABLED", MA_BACKEND_NOT_ENABLED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_DEVICE_NOT_INITIALIZED", MA_DEVICE_NOT_INITIALIZED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_DEVICE_ALREADY_INITIALIZED", MA_DEVICE_ALREADY_INITIALIZED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_DEVICE_NOT_STARTED", MA_DEVICE_NOT_STARTED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_DEVICE_NOT_STOPPED", MA_DEVICE_NOT_STOPPED);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_FAILED_TO_INIT_BACKEND", MA_FAILED_TO_INIT_BACKEND);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_FAILED_TO_OPEN_BACKEND_DEVICE", MA_FAILED_TO_OPEN_BACKEND_DEVICE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_FAILED_TO_START_BACKEND_DEVICE", MA_FAILED_TO_START_BACKEND_DEVICE);
	engine->RegisterEnumValue("audio_error_state", "AUDIO_ERROR_STATE_FAILED_TO_STOP_BACKEND_DEVICE", MA_FAILED_TO_STOP_BACKEND_DEVICE);
	engine->RegisterEnum("audio_node_state");
	engine->RegisterEnumValue("audio_node_state", "AUDIO_NODE_STATE_STARTED", ma_node_state_started);
	engine->RegisterEnumValue("audio_node_state", "AUDIO_NODE_STATE_STOPPED", ma_node_state_stopped);
	engine->RegisterEnum("audio_format");
	engine->RegisterEnumValue("audio_format", "AUDIO_FORMAT_UNKNOWN", ma_format_unknown);
	engine->RegisterEnumValue("audio_format", "AUDIO_FORMAT_U8", ma_format_u8);
	engine->RegisterEnumValue("audio_format", "AUDIO_FORMAT_S16", ma_format_s16);
	engine->RegisterEnumValue("audio_format", "AUDIO_FORMAT_S24", ma_format_s24);
	engine->RegisterEnumValue("audio_format", "AUDIO_FORMAT_S32", ma_format_s32);
	engine->RegisterEnumValue("audio_format", "AUDIO_FORMAT_F32", ma_format_f32);
	engine->RegisterEnum("audio_pan_mode");
	engine->RegisterEnumValue("audio_pan_mode", "AUDIO_PAN_MODE_BALANCE", ma_pan_mode_balance);
	engine->RegisterEnumValue("audio_pan_mode", "AUDIO_PAN_MODE_PAN", ma_pan_mode_pan);
	engine->RegisterEnum("audio_positioning_mode");
	engine->RegisterEnumValue("audio_positioning_mode", "AUDIO_POSITIONING_ABSOLUTE", ma_positioning_absolute);
	engine->RegisterEnumValue("audio_positioning_mode", "AUDIO_POSITIONING_RELATIVE", ma_positioning_relative);
	engine->RegisterEnum("audio_attenuation_model");
	engine->RegisterEnumValue("audio_attenuation_model", "AUDIO_ATTENUATION_MODEL_NONE", ma_attenuation_model_none);
	engine->RegisterEnumValue("audio_attenuation_model", "AUDIO_ATTENUATION_MODEL_INVERSE", ma_attenuation_model_inverse);
	engine->RegisterEnumValue("audio_attenuation_model", "AUDIO_ATTENUATION_MODEL_LINEAR", ma_attenuation_model_linear);
	engine->RegisterEnumValue("audio_attenuation_model", "AUDIO_ATTENUATION_MODEL_EXPONENTIAL", ma_attenuation_model_exponential);
	engine->RegisterEnum("audio_engine_flags");
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_DURATIONS_IN_FRAMES", audio_engine::DURATIONS_IN_FRAMES);
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_NO_AUTO_START", audio_engine::NO_AUTO_START);
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_NO_DEVICE", audio_engine::NO_DEVICE);
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_PERCENTAGE_ATTRIBUTES", audio_engine::PERCENTAGE_ATTRIBUTES);
	RegisterSoundsystemAudioNode < audio_node > (engine, "audio_node");
	RegisterSoundsystemEngine(engine);
	RegisterSoundsystemMixer < mixer > (engine, "mixer");
	engine->RegisterObjectBehaviour("mixer", asBEHAVE_FACTORY, "mixer@ m()", asFUNCTION(new_global_mixer), asCALL_CDECL);
	RegisterSoundsystemMixer < sound > (engine, "sound");
	engine->RegisterObjectMethod("audio_engine", "bool play(const string&in path, mixer@ mix = null)", asFUNCTION((virtual_call < audio_engine, &audio_engine::play, bool, const string &, mixer * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "mixer@ mixer()", asFUNCTION((virtual_call < audio_engine, &audio_engine::new_mixer, mixer * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "sound@ sound()", asFUNCTION((virtual_call < audio_engine, &audio_engine::new_sound, sound * >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemNodes(engine);
	engine->RegisterObjectBehaviour("sound", asBEHAVE_FACTORY, "sound@ s()", asFUNCTION(new_global_sound), asCALL_CDECL);
	engine->RegisterObjectMethod("sound", "bool load(const string&in filename, const pack_interface@ pack = null)", asFUNCTION((virtual_call < sound, &sound::load, bool, const string &, pack_interface * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream(const string&in filename, const pack_interface@ pack = null)", asFUNCTION((virtual_call < sound, &sound::stream, bool, const string &, pack_interface * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_memory(const string&in data)", asFUNCTION((virtual_call < sound, &sound::load_string, bool, const string & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const float[]@ data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script, bool, CScriptArray *, int, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const int[]@ data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script, bool, CScriptArray *, int, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const int16[]@ data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script, bool, CScriptArray *, int, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const uint8[]@ data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script, bool, CScriptArray *, int, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool close()", asFUNCTION((virtual_call < sound, &sound::close, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "const string& get_loaded_filename() const property", asFUNCTION((virtual_call < sound, &sound::get_loaded_filename, const std::string & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_load_complete() const property", asFUNCTION((virtual_call < sound, &sound::is_load_completed, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_active() const property", asFUNCTION((virtual_call < sound, &sound::get_active, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_paused() const property", asFUNCTION((virtual_call < sound, &sound::get_paused, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool play_wait()", asFUNCTION((virtual_call < sound, &sound::play_wait, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool pause()", asFUNCTION((virtual_call < sound, &sound::pause, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool pause_fade(const uint64 length)", asFUNCTION((virtual_call < sound, &sound::pause_fade, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool pause_fade_in_frames(const uint64 length_in_frames)", asFUNCTION((virtual_call < sound, &sound::pause_fade_in_frames, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool pause_fade_in_milliseconds(const uint64 length_in_milliseconds)", asFUNCTION((virtual_call < sound, &sound::pause_fade_in_milliseconds, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_timed_fade(float start_volume, float end_volume, uint64 length, uint64 absolute_time)", asFUNCTION((virtual_call < sound, &sound::set_timed_fade, void, float, float, unsigned long long, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_timed_fade_in_frames(float start_volume, float end_volume, uint64 length, uint64 absolute_time)", asFUNCTION((virtual_call < sound, &sound::set_timed_fade_in_frames, void, float, float, unsigned long long, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_timed_fade_in_milliseconds(float start_volume, float end_volume, uint64 length, uint64 absolute_time)", asFUNCTION((virtual_call < sound, &sound::set_timed_fade_in_milliseconds, void, float, float, unsigned long long, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_stop_time_with_fade(uint64 absolute_time, uint64 fade_length)", asFUNCTION((virtual_call < sound, &sound::set_stop_time_with_fade, void, unsigned long long, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_stop_time_with_fade_in_frames(uint64 absolute_time, uint64 fade_length)", asFUNCTION((virtual_call < sound, &sound::set_stop_time_with_fade_in_frames, void, unsigned long long, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_stop_time_with_fade_in_milliseconds(uint64 absolute_time, uint64 fade_length)", asFUNCTION((virtual_call < sound, &sound::set_stop_time_with_fade_in_milliseconds, void, unsigned long long, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_looping(bool looping) property", asFUNCTION((virtual_call < sound, &sound::set_looping, void, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_looping() const property", asFUNCTION((virtual_call < sound, &sound::get_looping, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_at_end() const property", asFUNCTION((virtual_call < sound, &sound::get_looping, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool seek(const uint64 position)", asFUNCTION((virtual_call < sound, &sound::seek, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool seek_in_frames(const uint64 position)", asFUNCTION((virtual_call < sound, &sound::seek_in_frames, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool seek_in_milliseconds(const uint64 position)", asFUNCTION((virtual_call < sound, &sound::seek_in_milliseconds, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_position() property", asFUNCTION((virtual_call < sound, &sound::get_position, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_position_in_frames() const property", asFUNCTION((virtual_call < sound, &sound::get_position_in_frames, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_position_in_milliseconnds() const property", asFUNCTION((virtual_call < sound, &sound::get_position_in_milliseconds, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_length() property", asFUNCTION((virtual_call < sound, &sound::get_length, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_length_in_frames( ) const property", asFUNCTION((virtual_call < sound, &sound::get_length_in_frames, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_length_in_ms() const property", asFUNCTION((virtual_call < sound, &sound::get_length_in_milliseconds, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_data_format(audio_format&out format, uint32&out channels, uint32&out sample_rate)", asFUNCTION((virtual_call < sound, &sound::get_data_format, bool, ma_format *, unsigned int *, unsigned int * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "double get_pitch_lower_limit() const property", asFUNCTION((virtual_call < sound, &sound::get_pitch_lower_limit, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("const string[]@+ get_sound_input_devices() property", asFUNCTION(get_sound_input_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction("const string[]@+ get_sound_output_devices() property", asFUNCTION(get_sound_output_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_sound_output_device() property", asFUNCTION(get_sound_output_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_output_device(int device) property", asFUNCTION(set_sound_output_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_default_decryption_key(const string& in key) property", asFUNCTION(set_default_decryption_key), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_default_pack(pack_interface@ storage) property", asFUNCTION(set_sound_default_storage), asCALL_CDECL);
	engine->RegisterGlobalFunction("pack_interface@ get_sound_default_pack() property", asFUNCTION(get_sound_default_storage), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_master_volume(float db) property", asFUNCTION(set_sound_master_volume), asCALL_CDECL);
	engine->RegisterGlobalFunction("float get_sound_master_volume() property", asFUNCTION(get_sound_master_volume), asCALL_CDECL);

	engine->RegisterGlobalFunction("audio_error_state get_SOUNDSYSTEM_LAST_ERROR() property", asFUNCTION(get_soundsystem_last_error), asCALL_CDECL);
}
