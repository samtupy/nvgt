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
#include <reactphysics3d/collision/shapes/AABB.h>
#include <angelscript.h>
#include <scriptarray.h>
#include <scripthandle.h>
#include "misc_functions.h" // script_memory_buffer
#include "nvgt.h" // g_ScriptEngine
#include "nvgt_angelscript.h" // get_array_type
#include "nvgt_plugin.h"      // pack_interface
#include "sound.h"
#include "sound_nodes.h"
#include "pack.h"
#include "datastreams.h"
#include <miniaudio_wdl_resampler.h>
#include <atomic>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <cstdint>
#include <miniaudio_libvorbis.h>
#include <miniaudio_libopus.h>
#include <iostream>
using namespace std;

class sound_impl;
void wait(int ms);
// Globals, currently NVGT does not support instanciating multiple miniaudio contexts and NVGT provides a global sound engine.
static ma_context g_sound_context;
audio_engine *g_audio_engine = nullptr;
mixer* g_audio_mixer = nullptr;
static std::atomic_flag g_soundsystem_initialized;
std::atomic<ma_result> g_soundsystem_last_error = MA_SUCCESS;
static unordered_map<ma_data_source*, audio_data_source*> g_data_sources_map; // Only allow one audio_data_source wrapper per ma_data_source, should never be populated enough to be a performance hit.
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
	add_decoder(ma_decoding_backend_libopus);
	g_soundsystem_initialized.test_and_set();
	refresh_audio_devices();
	g_audio_engine = new_audio_engine(audio_engine::PERCENTAGE_ATTRIBUTES | audio_engine::NO_CLIP);
	return true;
}
void uninit_sound() {
	if (!g_soundsystem_initialized.test())
		return;
	garbage_collect_inline_sounds();
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
ma_format ma_format_from_angelscript_type(int type_id) {
	if (type_id == asTYPEID_FLOAT)
		return ma_format_f32;
	else if (type_id == asTYPEID_INT32)
		return ma_format_s32;
	else if (type_id == asTYPEID_INT16)
		return ma_format_s16;
	else if (type_id == asTYPEID_UINT8)
		return ma_format_u8;
	else
		return ma_format_unknown;
}

// The following function based on ma_sound_get_direction_to_listener.
MA_API float ma_sound_get_distance_to_listener(const ma_sound *pSound) {
	ma_vec3f relativePos;
	if (pSound == NULL)
		return 0;
	ma_engine *pEngine = ma_sound_get_engine(pSound);
	if (pEngine == NULL)
		return 0;
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

// The following code manages inlined, one-shot sounds. While miniaudio does provide support for this, it is subpar when considering what NVGT users wish for, namely it cannot return the ma_sound that was created.
unordered_set<sound*> g_inlined_sounds;
mutex g_inlined_sounds_mutex;
void garbage_collect_inline_sounds() {
	auto it = g_inlined_sounds.begin();
	while (it != g_inlined_sounds.end()) {
		if ((*it)->get_playing()) ++it;
		else {
			unique_lock<mutex> lock(g_inlined_sounds_mutex);
			(*it)->release();
			it = g_inlined_sounds.erase(it);
		}
	}
}

// Sound shapes let mixer/sound::set_position_3d position the sound as though it was more than one tile wide in each direction.
typedef sound_shape* sound_shape_setup_callback(mixer* connected_sound, CScriptHandle* shape_reference);
std::unordered_map<int, sound_shape_setup_callback*> g_sound_shape_setup_callbacks;
std::unordered_set<sound_shape*> g_blocking_sound_shapes; // Most built-in shapes are threadsafe, thus when the listener moves we can safely update the sound position from audio processing threads. Sometimes however such as in the case of script callbacks, we wish to insilate the scripter from being threadsafe, and we store all such non-threadsafe shapes here.
bool register_blocking_sound_shape(sound_shape* shape, mixer* connected_sound) {
	if (!shape || !connected_sound) return false;
	shape->connected_sound = connected_sound;
	g_blocking_sound_shapes.insert(shape);
	return true;
}
bool unregister_blocking_sound_shape(sound_shape* shape) {
	auto it = g_blocking_sound_shapes.find(shape);
	if (it == g_blocking_sound_shapes.end()) return false;
	shape->connected_sound = nullptr;
	g_blocking_sound_shapes.erase(it);
	return true;
}
void update_blocking_sound_shapes() {
	for (sound_shape* s : g_blocking_sound_shapes) s->connected_sound->set_position_3d_vector(s->get_position());
}
sound_shape* sound_shape_builtin_standard_setup(mixer* snd, CScriptHandle* shape_ref) {
	// This assumes that the shape object has already been created by the scripter and is contained within the CScriptHandle we've received.
	sound_shape* shape = (sound_shape*)(shape_ref->GetRef());
	shape->duplicate();
	return shape;
}
class sound_aabb_shape : public sound_shape {
public:
	int left_range, right_range, backward_range, forward_range, lower_range, upper_range;
	sound_aabb_shape(int left_range, int right_range, int backward_range, int forward_range, int lower_range, int upper_range) : sound_shape(), left_range(left_range), right_range(right_range), backward_range(backward_range), forward_range(forward_range), lower_range(lower_range), upper_range(upper_range) {}
	bool contains(const reactphysics3d::Vector3& listener_position, reactphysics3d::Vector3& sound_position) override {
		reactphysics3d::AABB bounds(reactphysics3d::Vector3(sound_position - reactphysics3d::Vector3(left_range, backward_range, lower_range)), reactphysics3d::Vector3(sound_position + reactphysics3d::Vector3(right_range, forward_range, upper_range)));
		if (bounds.contains(listener_position)) return true;
		sound_position.x = clamp(listener_position.x, bounds.getMin().x, bounds.getMax().x);
		sound_position.y = clamp(listener_position.y, bounds.getMin().y, bounds.getMax().y);
		sound_position.z = clamp(listener_position.z, bounds.getMin().z, bounds.getMax().z);
		return false;
	}
};
sound_aabb_shape* create_sound_aabb_shape(int left_range, int right_range, int backward_range, int forward_range, int lower_range, int upper_range) { return new sound_aabb_shape(left_range, right_range, backward_range, forward_range, lower_range, upper_range); }

// Miniaudio objects must be allocated on the heap as nvgt's API introduces the concept of an uninitialized sound, which a stack based system would make more difficult to implement.
class audio_engine_impl final : public audio_node_impl, public virtual audio_engine {
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
		}
		engine->release();
	}

public:
	engine_flags flags;
	audio_engine_impl(int flags, int sample_rate, int channels) : audio_node_impl(nullptr, this), engine(nullptr), resource_manager(nullptr), script_data_callback(nullptr), engine_endpoint(nullptr), flags(static_cast<engine_flags>(flags)) {
		if (channels > MA_MAX_CHANNELS) throw runtime_error(Poco::format("exceeded maximum channel count of %d", MA_MAX_CHANNELS));
		init_sound();
		engine = std::make_unique<ma_engine>();
		// We need a self-managed device because at least on Windows, we can't meet low-latency requirements without specific configurations.
		if ((flags & NO_DEVICE) == 0) {
			device = std::make_unique<ma_device>();
			ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
			cfg.playback.channels = channels;
			cfg.playback.format = ma_format_f32;
			cfg.sampleRate = sample_rate;
			cfg.noClip = (flags & engine_flags::NO_CLIP)? MA_TRUE : MA_FALSE;
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
				throw runtime_error(Poco::format("failed to initialize sound engine device %d", int(g_soundsystem_last_error)));
			}
		}

		// We need a self managed resource manager because we need to plug decoders in and configure the job thread count.
		{
			ma_resource_manager_config cfg = ma_resource_manager_config_init();
			// Attach the resource manager to the sound service so that it can receive audio from custom sources.
			cfg.pVFS = g_sound_service->get_vfs();
			// This is the sample rate that sounds will be resampled to if necessary during loading. We set this equal to whatever sample rate the device got. This is maximally efficient as long as the user doesn't switch devices to one that runs at a different rate. When they do, a single resampler kicks in.
			cfg.decodedSampleRate = device && !sample_rate? device->playback.internalSampleRate : sample_rate;
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
				throw runtime_error(Poco::format("failed to initialize sound engine resource manager %d", int(g_soundsystem_last_error)));
			}
		}
		ma_engine_config cfg = ma_engine_config_init();
		cfg.pContext = &g_sound_context;
		cfg.pResourceManager = &*resource_manager;
		cfg.noAutoStart = (flags & NO_AUTO_START) ? MA_TRUE : MA_FALSE;
		cfg.periodSizeInFrames = SOUNDSYSTEM_FRAMESIZE; // Steam Audio requires fixed sized updates. We can make this not be a magic constant if anyone has some reason for wanting to change it.
		if ((flags & NO_DEVICE) == 0) cfg.pDevice = &*device;
		else {
			cfg.noDevice = MA_TRUE;
			cfg.channels = channels;
			cfg.sampleRate = sample_rate;
		}
		if ((g_soundsystem_last_error = ma_engine_init(&cfg, &*engine)) != MA_SUCCESS) {
			engine.reset();
			throw runtime_error(Poco::format("failed to initialize sound engine %d", int(g_soundsystem_last_error)));
		}
		node = (ma_node_base*)&*engine;
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
	ma_engine *get_ma_engine() const override { return engine.get(); }
	audio_node *get_endpoint() const override { return engine_endpoint; }
	int get_flags() const override { return flags; }
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
		cfg.noClip = MA_TRUE;
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
		update_blocking_sound_shapes();
	}
	void set_listener_position_vector(unsigned int index, const reactphysics3d::Vector3 &position) override {
		if (engine)
			ma_engine_listener_set_position(&*engine, index, position.x, position.y, position.z);
		update_blocking_sound_shapes();
	}
	reactphysics3d::Vector3 get_listener_position(unsigned int index) const override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_position(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_direction(unsigned int index, float x, float y, float z) override {
		if (engine)
			ma_engine_listener_set_direction(&*engine, index, x, y, z);
	}
	void set_listener_direction_vector(unsigned int index, const reactphysics3d::Vector3 &direction) override {
		if (engine)
			ma_engine_listener_set_direction(&*engine, index, direction.x, direction.y, direction.z);
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
	}
	void set_listener_world_up_vector(unsigned int index, const reactphysics3d::Vector3 &world_up) override {
		if (engine)
			ma_engine_listener_set_world_up(&*engine, index, world_up.x, world_up.y, world_up.z);
	}
	reactphysics3d::Vector3 get_listener_world_up(unsigned int index) const override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_world_up(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_enabled(unsigned int index, bool enabled) override {
		if (engine)
			ma_engine_listener_set_enabled(&*engine, index, enabled);
	}
	bool get_listener_enabled(unsigned int index) const override { return ma_engine_listener_is_enabled(&*engine, index); }
	sound* play(const string& path, const reactphysics3d::Vector3& position, float volume, float pan, float pitch, mixer* mix, const pack_interface* pack_file, bool autoplay) override {
		garbage_collect_inline_sounds();
		sound* snd = new_sound();
		if (!snd) return nullptr;
		if (!snd->load(path, pack_file)) {
			snd->release();
			return nullptr;
		}
		if (mix) snd->set_mixer(mix);
		if (position.x != FLT_MAX || position.y != FLT_MAX || position.z != FLT_MAX) snd->set_position_3d_vector(position);
		snd->set_volume(volume);
		snd->set_pan(pan);
		snd->set_pitch(pitch);
		if (autoplay) snd->play();
		snd->set_autoclose();
		return snd;
	}
	mixer *new_mixer() override { return ::new_mixer(this); }
	sound *new_sound() override { return ::new_sound(this); }
};
class audio_data_source_impl;
audio_data_source* audio_data_source_get(ma_data_source* ptr, audio_engine* engine);
class audio_data_source_impl : public audio_node_impl, public virtual audio_data_source {
	unique_ptr<ma_data_source_node> src;
	audio_data_source* src_cur;
	audio_data_source* src_next;
protected:
	bool set_ma_data_source(ma_data_source* new_src) {
		reset();
		if (!new_src) return true;
		ma_data_source_node_config cfg = ma_data_source_node_config_init(new_src);
		src = make_unique<ma_data_source_node>();
		if ((g_soundsystem_last_error = ma_data_source_node_init((ma_node_graph*)get_engine()->get_ma_engine(), &cfg, nullptr, &*src)) != MA_SUCCESS) {
			reset();
			return false;
		}
		node = (ma_node_base*)&*src;
		g_data_sources_map[new_src] = this;
		return true;
	}
	void reset() {	
		if (src) {
			auto it = g_data_sources_map.find(src->pDataSource);
			if (it != g_data_sources_map.end()) g_data_sources_map.erase(it);
			node = nullptr;
			ma_data_source_node_uninit(&*src, nullptr);
			src.reset();
		}
		src_cur = src_next = nullptr;
	}
public:
	audio_data_source_impl(audio_engine* e, ma_data_source* initial_src = nullptr) : audio_node_impl(nullptr, e), src_cur(nullptr), src_next(nullptr), src(nullptr) { if (initial_src) set_ma_data_source(initial_src); }
	ma_data_source* get_ma_data_source() const override { return src? src->pDataSource : nullptr; }
	unsigned long long read(void* buffer, unsigned long long frame_count) override {
		if (!src || !detach_all_output_buses()) return 0;
		ma_uint64 frames_read;
		if ((g_soundsystem_last_error = ma_data_source_read_pcm_frames(src->pDataSource, buffer, frame_count, &frames_read)) != MA_SUCCESS) return 0;
		return frames_read;
	}
	CScriptArray* read_script(unsigned long long frame_count) override {
		unsigned int channels;
		if (!get_data_format(nullptr, &channels, nullptr)) return nullptr;
		CScriptArray* array = CScriptArray::Create(get_array_type("array<float>"), frame_count * channels);
		unsigned long long frames_read = read(array->GetBuffer(), frame_count);
		array->Resize(frames_read * channels);
		return array;
	}
	unsigned long long skip_frames(unsigned long long frame_count) override {
		ma_uint64 frames_skipped;
		if (!src) return 0;
		if ((g_soundsystem_last_error = ma_data_source_seek_pcm_frames(src->pDataSource, frame_count, &frames_skipped)) != MA_SUCCESS) return 0;
		return frames_skipped;
	}
	float skip_milliseconds(float ms) override {
		float skipped;
		if (!src) return 0;
		if ((g_soundsystem_last_error = ma_data_source_seek_seconds(src->pDataSource, ms / 1000, &skipped)) != MA_SUCCESS) return 0;
		return skipped * 1000;
	}
	bool seek_frames(unsigned long long frame_index) override { return src? (g_soundsystem_last_error = ma_data_source_seek_to_pcm_frame(src->pDataSource, frame_index)) == MA_SUCCESS : false; }
	bool seek_milliseconds(float ms) override { return src? (g_soundsystem_last_error = ma_data_source_seek_to_second(src->pDataSource, ms / 1000)) == MA_SUCCESS : false; }
	unsigned long long get_cursor_frames() const override {
		ma_uint64 cursor;
		return (g_soundsystem_last_error = ma_data_source_get_cursor_in_pcm_frames(src->pDataSource, &cursor)) == MA_SUCCESS? cursor : 0;
	}
	float get_cursor_milliseconds() const override {
		float cursor;
		return (g_soundsystem_last_error = ma_data_source_get_cursor_in_seconds(src->pDataSource, &cursor)) == MA_SUCCESS? cursor * 1000 : 0;
	}
	unsigned long long get_length_frames() const override {
		ma_uint64 length;
		return (g_soundsystem_last_error = ma_data_source_get_length_in_pcm_frames(src->pDataSource, &length)) == MA_SUCCESS? length : 0;
	}
	float get_length_milliseconds() const override {
		float length;
		return (g_soundsystem_last_error = ma_data_source_get_length_in_seconds(src->pDataSource, &length)) == MA_SUCCESS? length * 1000 : 0;
	}
	bool set_looping(bool looping) override { return src? (g_soundsystem_last_error = ma_data_source_set_looping(src->pDataSource, looping)) == MA_SUCCESS : false; }
	bool get_looping() const override { return src? ma_data_source_is_looping(src->pDataSource) : false; }
	bool set_range(unsigned long long start_frame, unsigned long long end_frame) override { return src? (g_soundsystem_last_error = ma_data_source_set_range_in_pcm_frames(src->pDataSource, start_frame, end_frame)) == MA_SUCCESS : false; }
	void get_range(unsigned long long* start_frame, unsigned long long* end_frame) const override { if (src) ma_data_source_get_range_in_pcm_frames(src->pDataSource, start_frame, end_frame); }
	bool set_loop_point(unsigned long long start_frame, unsigned long long end_frame) override { return src? (g_soundsystem_last_error = ma_data_source_set_loop_point_in_pcm_frames(src->pDataSource, start_frame, end_frame)) == MA_SUCCESS : false; }
	void get_loop_point(unsigned long long* start_frame, unsigned long long* end_frame) const override { if (src) ma_data_source_get_loop_point_in_pcm_frames(src->pDataSource, start_frame, end_frame); }
	bool set_current(audio_data_source* new_current) override {
		if (!src) return false;
		if ((g_soundsystem_last_error = ma_data_source_set_current(src->pDataSource, new_current? new_current->get_ma_data_source() : nullptr)) != MA_SUCCESS) {
			if (new_current) new_current->release();
			return false;
		}
		if (src_cur) src_cur->release();
		src_cur = new_current;
		return true;
	}
	audio_data_source* get_current() const override {  return src_cur? src_cur : src? audio_data_source_get(ma_data_source_get_current(src->pDataSource), get_engine()) : nullptr; }
	bool set_next(audio_data_source* new_next) override {
		if (!src) return false;
		if ((g_soundsystem_last_error = ma_data_source_set_next(src->pDataSource, new_next? new_next->get_ma_data_source() : nullptr)) != MA_SUCCESS) {
			if (new_next) new_next->release();
			return false;
		}
		if (src_next) src_next->release();
		src_next = new_next;
		return true;
	}
	audio_data_source* get_next() const override {  return src_next? src_next : src? audio_data_source_get(ma_data_source_get_next(src->pDataSource), get_engine()) : nullptr; }
	bool get_data_format(ma_format *format, unsigned int *channels, unsigned int *sample_rate) const override { return src? (g_soundsystem_last_error = ma_data_source_get_data_format(src->pDataSource, format, channels, sample_rate, nullptr, 0)) == MA_SUCCESS : false; }
	bool get_active() const override { return src != nullptr; }
};
audio_data_source* audio_data_source_get(ma_data_source* ptr, audio_engine* engine) {
	if (!ptr) return nullptr;
	if (!engine) engine = g_audio_engine;
	auto it = g_data_sources_map.find(ptr);
	if (it != g_data_sources_map.end()) {
		it->second->duplicate();
		return it->second;
	}
	return new audio_data_source_impl(engine, ptr);
}
class audio_decoder_impl : public audio_data_source_impl, public virtual audio_decoder {
	unique_ptr<ma_decoder> decoder;
	datastream* datastream_ref; // If the user opens a datastream, we must maintain a reference to it encase the user drops their handle.
	static ma_result on_read_datastream(ma_decoder *pDecoder, void *pDst, size_t sizeInBytes, size_t *pBytesRead) {
		if (pBytesRead) *pBytesRead = 0;
		datastream* ds = static_cast<datastream*>(pDecoder->pUserData);
		if (!ds) return MA_ERROR;
		istream* stream = ds->get_istr();
		if (!stream) return MA_ERROR;
		if (!stream->good()) return MA_AT_END;
		stream->read((char *)pDst, sizeInBytes);
		if (pBytesRead) *pBytesRead = stream->gcount();
		return MA_SUCCESS;
	}
	static ma_result on_seek_datastream(ma_decoder *pDecoder, ma_int64 offset, ma_seek_origin origin) {
		datastream* ds = static_cast<datastream*>(pDecoder->pUserData);
		if (!ds) return MA_ERROR;
		istream* stream = ds->get_istr();
		if (!stream) return MA_ERROR;
		stream->clear();
		std::ios_base::seekdir dir;
		switch (origin) {
			case ma_seek_origin_start:
				dir = stream->beg;
				break;
			case ma_seek_origin_current:
				dir = stream->cur;
				break;
			case ma_seek_origin_end:
				dir = stream->end;
				break;
			default: // Should never get here.
				return MA_ERROR;
		}
		stream->seekg(offset, dir);
		return MA_SUCCESS;
	}
	static ma_result on_tell_datastream(ma_decoder *pDecoder, ma_int64 *pCursor) {
		datastream* ds = static_cast<datastream*>(pDecoder->pUserData);
		if (!ds) return MA_ERROR;
		istream* stream = ds->get_istr();
		if (!stream) return MA_ERROR;
		*pCursor = stream->tellg();
		return MA_SUCCESS;
	}
	ma_decoder_config decoder_config_init(unsigned int sample_rate, unsigned int channels) {
		init_sound();
		ma_decoder_config cfg = ma_decoder_config_init(ma_format_f32, channels, sample_rate);
		cfg.resampling.algorithm = ma_resample_algorithm_custom;
		cfg.resampling.pBackendVTable = &wdl_resampler_backend_vtable;
		if (!g_decoders.empty()) {
			cfg.ppCustomBackendVTables = &g_decoders[0];
			cfg.customBackendCount = g_decoders.size();
		}
		if (!decoder) decoder = make_unique<ma_decoder>();
		return cfg;
	}
public:
	audio_decoder_impl(audio_engine* e) : audio_data_source_impl(nullptr, e), decoder(nullptr), datastream_ref(nullptr) {}
	~audio_decoder_impl() { close(); }
	virtual bool open(const std::string& filename, const pack_interface* pack_file, unsigned int sample_rate, unsigned int channels) override {
		if (decoder && !close()) return false;
		ma_decoder_config cfg = decoder_config_init(sample_rate, channels);
		std::string triplet = g_sound_service->prepare_triplet(filename, pack_file && pack_file->get_is_active()? g_pack_protocol_slot : 0, pack_file && pack_file->get_is_active()? std::shared_ptr < const pack_interface > (pack_file->make_immutable()) : nullptr, 0, nullptr);
		if ((g_soundsystem_last_error = ma_decoder_init_vfs(g_sound_service->get_vfs(), triplet.c_str(), &cfg, &*decoder)) != MA_SUCCESS) decoder.reset();
		else set_ma_data_source((ma_data_source*)&*decoder);
		g_sound_service->cleanup_triplet(triplet);
		return g_soundsystem_last_error == MA_SUCCESS;
	}
	virtual bool open_stream(datastream* ds, unsigned int sample_rate = 0, unsigned int channels = 0) override {
		if (!ds || !ds->get_istr() || decoder && !close()) {
			if (ds) ds->release();
			return false;
		}
		ma_decoder_config cfg = decoder_config_init(sample_rate, channels);
		if ((g_soundsystem_last_error = ma_decoder_init(on_read_datastream, on_seek_datastream, on_tell_datastream, ds, &cfg, &*decoder)) != MA_SUCCESS) {
			decoder.reset();
			ds->release();
		} else {
			datastream_ref = ds;
			set_ma_data_source((ma_data_source*)&*decoder);
		}
		return g_soundsystem_last_error == MA_SUCCESS;
	}
	virtual bool close() override {
		reset();
		if (!decoder) return false;
		if (datastream_ref) {
			datastream_ref->release();
			datastream_ref = nullptr;
		}
		if ((g_soundsystem_last_error = ma_decoder_uninit(&*decoder)) != MA_SUCCESS ) return false;
		decoder.reset();
		return true;
	}
	virtual unsigned int get_sample_rate() const override { return decoder? decoder->outputSampleRate : 0; }
	virtual unsigned int get_channels() const override { return decoder? decoder->outputChannels : 0; }
};
audio_decoder* audio_decoder::create(audio_engine* e) { return new audio_decoder_impl(e); }
class mixer_impl : public audio_node_impl, public virtual mixer {
	friend class audio_node_impl;
	// In miniaudio, a sound_group is really just a sound. A typical ma_sound_group_x function looks like float ma_sound_group_get_pan(const ma_sound_group* pGroup) { return ma_sound_get_pan(pGroup); }.
	// Furthermore ma_sound_group is just a typedef for ma_sound. As such, for the sake of less code and better inheritance, we will directly call the ma_sound APIs in this class even though it deals with sound groups and not sounds.
protected:
	unique_ptr<ma_sound> snd;
	mixer *parent_mixer;
	sound_shape* shape;
	mutable audio_spatializer *spatializer;
	mutex spatialization_params_mutex;
	audio_node_chain* node_chain;
	audio_node_chain* effects_chain;
public:
	mixer_impl(audio_engine *e, bool sound_group = true) : audio_node_impl(nullptr, e), snd(nullptr), shape(nullptr), node_chain(audio_node_chain::create(nullptr, nullptr, e)), effects_chain(nullptr), parent_mixer(nullptr), spatializer(nullptr) {
		init_sound();
		node_chain->set_endpoint(e->get_endpoint());
		if (!sound_group) return;
		snd = make_unique<ma_sound>();
		ma_sound_group_init(e->get_ma_engine(), 0, nullptr, &*snd);
		node = (ma_node_base *)&*snd;
		set_max_distance(70);
		ma_sound_group_set_rolloff(&*snd, 0); // Our own spatializer controls attenuation.
		ma_sound_group_set_directional_attenuation_factor(&*snd, 0); // Our spatializer also controls panning.
		attach_output_bus(0, node_chain, 0);
		play();
	}
	~mixer_impl() {
		stop();
		unique_lock<mutex> lock(spatialization_params_mutex);
		if (spatializer) {
			node_chain->remove_node(spatializer);
			spatializer->release();
		}
		if (parent_mixer)
			parent_mixer->release();
		if (node_chain)
			node_chain->release();
		if (effects_chain)
			effects_chain->release();
		if (shape) {
			if (shape->connected_sound) unregister_blocking_sound_shape(shape);
			shape->release();
		}
		if (snd)
			ma_sound_group_uninit(&*snd);
	}
	audio_spatializer* get_spatializer() const {
		if (!spatializer) {
			spatializer = audio_spatializer::create(const_cast<mixer_impl*>(this), get_engine());
			node_chain->add_node(spatializer);
		}
		return spatializer;
	}
	inline void duplicate() override { audio_node_impl::duplicate(); }
	inline void release() override { audio_node_impl::release(); }
	bool set_mixer(mixer *mix) override {
		if (mix == parent_mixer)
			return false;
		if (parent_mixer) {
			parent_mixer->release();
			parent_mixer = nullptr;
		}
		if (mix) {
			parent_mixer = mix;
			node_chain->set_endpoint(mix);
			return node_chain->get_endpoint() == mix;
		} else {
			node_chain->set_endpoint(get_engine()->get_endpoint());
			return node_chain->get_endpoint() == get_engine()->get_endpoint();
		}
		return false;
	}
	mixer *get_mixer() const override { return parent_mixer; }
	void set_3d_panner(int panner_id) override {
		get_spatializer()->set_panner_by_id(panner_id);
	}
	int get_3d_panner() const override { return get_spatializer()->get_current_panner_id(); }
	void set_3d_attenuator(int attenuator_id) override {
		get_spatializer()->set_attenuator_by_id(attenuator_id);
	}
	int get_3d_attenuator() const override { return get_spatializer()->get_current_attenuator_id(); }
	int get_preferred_3d_panner() const override { return get_spatializer()->get_preferred_panner_id(); }
	int get_preferred_3d_attenuator() const override { return get_spatializer()->get_preferred_attenuator_id(); }
	void set_hrtf(bool enabled) override {
		if (enabled) {
			get_spatializer()->set_panner_by_id(g_audio_phonon_hrtf_panner);
			get_spatializer()->set_attenuator_by_id(g_audio_phonon_attenuator);
		} else {
			get_spatializer()->set_panner_by_id(g_audio_basic_panner);
			get_spatializer()->set_attenuator_by_id(g_audio_basic_attenuator);
		}
	}
	bool get_hrtf() const override { return get_spatializer()->get_preferred_panner_id() == g_audio_phonon_hrtf_panner && get_spatializer()->get_preferred_attenuator_id() == g_audio_phonon_attenuator; }
	bool set_shape(CScriptHandle* new_shape) override {
		// release old shape.
		sound_shape* old_shape = shape;
		shape = nullptr;
		if (old_shape) old_shape->release();
		if (!new_shape) return true;
		int ot = new_shape->GetTypeId();
		ot ^= asTYPEID_OBJHANDLE;
		if (!g_sound_shape_setup_callbacks.contains(ot)) return false;
		sound_shape* new_shape_obj = g_sound_shape_setup_callbacks[ot](this, new_shape);
		if (!new_shape_obj) return false;
		new_shape_obj->set_shape(new_shape);
		new_shape_obj->set_position(get_position_3d());
		shape = new_shape_obj;
		return true;
	}
	CScriptHandle* get_shape() const override {
		if (!shape) return nullptr;
		return shape->get_shape();
	}
	sound_shape* get_shape_object() const override { return shape; }
	void set_reverb3d(reverb3d* verb) override { get_spatializer()->set_reverb3d(verb); }
	void set_reverb3d_at(reverb3d* verb, audio_spatializer_reverb3d_placement placement) override { get_spatializer()->set_reverb3d(verb, placement); }
	reverb3d* get_reverb3d() const override { return get_spatializer()->get_reverb3d(); }
	splitter_node* get_reverb3d_attachment() const override { return get_spatializer()->get_reverb3d_attachment(); }
	audio_spatializer_reverb3d_placement get_reverb3d_placement() const override { return get_spatializer()->get_reverb3d_placement(); }
	audio_node_chain* get_effects_chain() override {
		if (!effects_chain) {
			effects_chain = audio_node_chain::create(nullptr, nullptr, get_engine());
			node_chain->add_node(effects_chain);
		}
		return effects_chain;
	}
	audio_node_chain* get_internal_node_chain() override { return node_chain; }
	bool get_spatialization_parameters(audio_spatialization_parameters& params) override {
		if (!snd || !get_spatialization_enabled() || !spatialization_params_mutex.try_lock()) return false;
		reactphysics3d::Vector3 listener_pos = get_engine()->get_listener_position(get_listener()), listener_dir = get_direction_to_listener(), pos = get_position_3d();
		params.listener_x = listener_pos.x;
		params.listener_y = listener_pos.y;
		params.listener_z = listener_pos.z;
		params.listener_direction_x = listener_dir.x * -1;
		params.listener_direction_y = listener_dir.y * -1;
		params.listener_direction_z = listener_dir.z * -1;
		params.listener_distance = get_distance_to_listener();
		params.sound_x = pos.x;
		params.sound_y = pos.y;
		params.sound_z = pos.z;
		params.min_distance = get_min_distance();
		params.max_distance = get_max_distance();
		params.min_volume = get_min_gain();
		params.max_volume = get_max_gain();
		params.rolloff = get_rolloff();
		params.distance_model = linear;
		spatialization_params_mutex.unlock();
		return true;
	}
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
			ma_sound_set_volume(&*snd, get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES? ma_volume_db_to_linear(volume) : volume);
	}
	float get_volume() const override { return snd ? (get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_volume_linear_to_db(ma_sound_get_volume(&*snd)) : ma_sound_get_volume(&*snd)) : NAN; }
	void set_pan(float pan) override {
		if (snd)
			ma_sound_set_pan(&*snd, get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES ? pan_db_to_linear(pan) : pan);
	}
	float get_pan() const override {
		return snd ? (get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES ? pan_linear_to_db(ma_sound_get_pan(&*snd)) : ma_sound_get_pan(&*snd)) : NAN;
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
			ma_sound_set_pitch(&*snd, get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES ? pitch / 100.0f : pitch);
	}
	float get_pitch() const override {
		return snd ? (get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_sound_get_pitch(&*snd) * 100 : ma_sound_get_pitch(&*snd)) : NAN;
	}
	void set_spatialization_enabled(bool enabled) override {
		if (snd)
			ma_sound_set_spatialization_enabled(&*snd, enabled);
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
	float get_distance_to_listener() const override { return snd && get_spatialization_enabled()? ma_sound_get_distance_to_listener(&*snd) : 0.0; }
	void set_position_3d(float x, float y, float z) override {
		if (!snd)
			return;
		set_spatialization_enabled(true);
		if (sound_get_default_3d_panner() >= 0 && get_preferred_3d_panner() < 0) set_3d_panner(sound_get_default_3d_panner());
		if (sound_get_default_3d_attenuator() >= 0 && get_preferred_3d_attenuator() < 0) set_3d_attenuator(sound_get_default_3d_attenuator());
		if (shape) {
			reactphysics3d::Vector3 pos(x, y, z);
			reactphysics3d::Vector3 listener = get_engine()->get_listener_position(get_listener());
			bool is_contained = shape->is_in_shape(listener, pos);
			if (!is_contained) ma_sound_set_position(&*snd, pos.x, pos.y, pos.z);
			else ma_sound_set_position(&*snd, listener.x, listener.y, listener.z);
		} else ma_sound_set_position(&*snd, x, y, z);
	}
	void set_position_3d_vector(const reactphysics3d::Vector3& position) override { set_position_3d(position.x, position.y, position.z); }
	reactphysics3d::Vector3 get_position_3d() const override {
		if (!snd)
			return reactphysics3d::Vector3();
		if (shape) return shape->get_position(); // True sound position is stored in the shape because the position stored in miniaudio may have been altered by the shape.
		const auto pos = ma_sound_get_position(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(pos.x, pos.y, pos.z);
		return res;
	}
	void set_direction(float x, float y, float z) override {
		if (!snd)
			return;
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
	void set_positioning(ma_positioning positioning) override {
		if (snd)
			ma_sound_set_positioning(&*snd, positioning);
	}
	ma_positioning get_positioning() const override {
		return snd ? ma_sound_get_positioning(&*snd) : ma_positioning_absolute;
	}
	void set_rolloff(float rolloff) override { get_spatializer()->set_rolloff(rolloff); }
	float get_rolloff() const override { return get_spatializer()->get_rolloff(); }
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
	void set_directional_attenuation_factor(float factor) override { get_spatializer()->set_directional_attenuation_factor(factor); }
	float get_directional_attenuation_factor() const override { return get_spatializer()->get_directional_attenuation_factor(); }
	void set_fade(float start_volume, float end_volume, ma_uint64 length) override {
		if (!snd)
			return;
		if (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES)
			set_fade_in_frames(start_volume, end_volume, length);
		else
			set_fade_in_milliseconds(start_volume, end_volume, length);
	}
	void set_fade_in_frames(float start_volume, float end_volume, ma_uint64 frames) override {
		if (!snd)
			return;
		if (get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES) {
			start_volume = start_volume == FLT_MAX ? -1 : ma_volume_db_to_linear(start_volume);
			end_volume = ma_volume_db_to_linear(end_volume);
		}
		ma_sound_set_fade_in_pcm_frames(&*snd, start_volume, end_volume, frames);
	}
	void set_fade_in_milliseconds(float start_volume, float end_volume, ma_uint64 milliseconds) override {
		if (!snd)
			return;
		if (get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES) {
			start_volume = start_volume == FLT_MAX ? -1 : ma_volume_db_to_linear(start_volume);
			end_volume = ma_volume_db_to_linear(end_volume);
		}
		ma_sound_set_fade_in_milliseconds(&*snd, start_volume, end_volume, milliseconds);
	}
	float get_current_fade_volume() const override {
		return snd ? (get_engine()->get_flags() & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_volume_linear_to_db(ma_sound_get_current_fade_volume(&*snd)) : ma_sound_get_current_fade_volume(&*snd)) : NAN;
	}
	void set_start_time(ma_uint64 absolute_time) override {
		if (!snd)
			return;
		if (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES)
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
		if (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES)
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
		return snd ? ((get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES) ? get_time_in_frames() : get_time_in_milliseconds()) : 0;
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
	unique_ptr<ma_pcm_rb> pcm_stream;
	bool paused;
	bool should_autoclose; // If this is true, the release method defers sound destruction until playback has complete.
	mutable audio_data_source* datasource; // Avoid the need to keep looking up the pointer to the c++ ma_data_source wrapper associated with this sound.
	inline void postload(const string& filename, bool async_load = false) {
		loaded_filename = filename;
		node = (ma_node_base *)&*snd;
		set_spatialization_enabled(false);                  // The user must call set_position_3d or manually enable spatialization or else their ambience and UI sounds will be spatialized.
		set_max_distance(70);
		ma_sound_set_rolloff(&*snd, 0);
		ma_sound_set_directional_attenuation_factor(&*snd, 0);
		attach_output_bus(0, node_chain, 0);
		// If we didn't load our sound asynchronously or if we streamed it, then we simply mark it as load_completed or we'll end up with a deadlock at destruction time.
		if (!async_load) load_completed.test_and_set();
	}
public:
	static void async_notification_callback(ma_async_notification *pNotification) {
		async_notification_callbacks *anc = (async_notification_callbacks *)pNotification;
		anc->pAtomicFlag->test_and_set();
	}
	sound_impl(audio_engine *e) : paused(false), should_autoclose(false), datasource(nullptr), pcm_stream(nullptr), mixer_impl(dynamic_cast <audio_engine_impl*> (e), false), pcm_buffer() {
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
	inline void release() override {
		if (asAtomicDec(refcount) < 1) {
			if (!should_autoclose || !get_playing()) delete this;
			else {
				should_autoclose = false;
				duplicate();
				unique_lock<mutex> lock(g_inlined_sounds_mutex);
				g_inlined_sounds.insert(this); // Freed with garbage_collect_inline_sounds();
			}
		}
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
		else postload(filename, (cfg.flags & MA_SOUND_FLAG_ASYNC));
		// Sound service has to store data pertaining to our triplet, and this is the earliest point at which it's safe to clean that up.
		g_sound_service->cleanup_triplet(triplet);
		return g_soundsystem_last_error == MA_SUCCESS;
	}
	bool load(const string &filename, const pack_interface* pack_file) override {
		return load_special(filename, pack_file && pack_file->get_is_active()? g_pack_protocol_slot : 0, pack_file && pack_file->get_is_active()? std::shared_ptr < const pack_interface > (pack_file->make_immutable()) : nullptr, 0, nullptr, MA_SOUND_FLAG_DECODE | MA_SOUND_FLAG_ASYNC);
	}
	bool stream(const std::string &filename, const pack_interface* pack_file) override {
		return load_special(filename, pack_file && pack_file->get_is_active()? g_pack_protocol_slot : 0, pack_file && pack_file->get_is_active()? std::shared_ptr < const pack_interface > (pack_file->make_immutable()) : nullptr, 0, nullptr, MA_SOUND_FLAG_STREAM);
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
	bool load_pcm_script_array(CScriptArray *buffer, int samplerate, int channels) override {
		if (!buffer)
			return false;
		ma_format format = ma_format_from_angelscript_type(buffer->GetElementTypeId());
		if (format == ma_format_unknown) return false;
		return load_pcm(buffer->GetBuffer(), buffer->GetSize() * buffer->GetElementSize(), format, samplerate, channels);
	}
	bool load_pcm_script_memory_buffer(script_memory_buffer* buffer, int samplerate, int channels) override {
		if (!buffer)
			return false;
		ma_format format = ma_format_from_angelscript_type(buffer->subtypeid);
		if (format == ma_format_unknown) return false;
		return load_pcm(buffer->ptr, buffer->size * buffer->get_element_size(), format, samplerate, channels);
	}
	bool stream_pcm(const void* data, unsigned int size_in_frames, ma_format format, unsigned int sample_rate, unsigned int channels, unsigned int buffer_size) override {
		if (format != ma_format_unknown) {
			if (snd) close();
			if (!buffer_size) buffer_size = size_in_frames * 2;
			if (!buffer_size) return false;
			if (!channels) channels = get_engine()->get_channels();
			if (!sample_rate) sample_rate = get_engine()->get_sample_rate();
			pcm_stream = make_unique<ma_pcm_rb>();
			if ((g_soundsystem_last_error = ma_pcm_rb_init(format, channels, buffer_size, nullptr, nullptr, &*pcm_stream)) != MA_SUCCESS) {
				pcm_stream.reset();
				return false;
			}
			ma_pcm_rb_set_sample_rate(&*pcm_stream, sample_rate);
			snd = make_unique<ma_sound>();
			if ((g_soundsystem_last_error = ma_sound_init_from_data_source(get_engine()->get_ma_engine(), &*pcm_stream, 0, nullptr, &*snd)) != MA_SUCCESS) {
				snd.reset();
				ma_pcm_rb_uninit(&*pcm_stream);
				pcm_stream.reset();
				return false;
			}
			postload(":pcm", false);
			play(true);
		}
		if (!pcm_stream) return false;
		const char* input = (const char*)data;
		unsigned int frames_written = 0;
		unsigned int frame_size = ma_get_bytes_per_frame(ma_pcm_rb_get_format(&*pcm_stream), ma_pcm_rb_get_channels(&*pcm_stream));
		while (size_in_frames) {
			void* buffer_ptr = nullptr;
			unsigned int frames_requested = size_in_frames;
			if ((g_soundsystem_last_error = ma_pcm_rb_acquire_write(&*pcm_stream, &frames_requested, &buffer_ptr)) != MA_SUCCESS || !buffer_ptr) return false;
			memcpy(buffer_ptr, input + (frames_written * frame_size), frames_requested * frame_size);
			if ((g_soundsystem_last_error = ma_pcm_rb_commit_write(&*pcm_stream, frames_requested)) != MA_SUCCESS) return false;
			frames_written += frames_requested;
			size_in_frames -= frames_requested;
		}
		return true;
	}
	bool stream_pcm_script_array(CScriptArray *buffer, unsigned int sample_rate, unsigned int channels, unsigned int buffer_size) override {
		if (!buffer)
			return false;
		ma_format format = pcm_stream? ma_format_unknown : ma_format_from_angelscript_type(buffer->GetElementTypeId());
		int nchannels = pcm_stream? ma_pcm_rb_get_channels(&*pcm_stream) : channels? channels : get_engine()->get_channels();
		return stream_pcm(buffer->GetBuffer(), buffer->GetSize() / nchannels, format, sample_rate, channels, buffer_size);
	}
	bool stream_pcm_script_memory_buffer(script_memory_buffer* buffer, unsigned int sample_rate, unsigned int channels, unsigned int buffer_size) override {
		if (!buffer)
			return false;
		ma_format format = pcm_stream? ma_format_unknown : ma_format_from_angelscript_type(buffer->subtypeid);
		int nchannels = pcm_stream? ma_pcm_rb_get_channels(&*pcm_stream) : channels? channels : get_engine()->get_channels();
		return stream_pcm(buffer->ptr, buffer->size / nchannels, format, sample_rate, channels, buffer_size);
	}
	bool open(audio_data_source* ds) override {
		if (!ds || !ds->get_active()) return false;
		if (snd) close();
		snd = make_unique<ma_sound>();
		if ((g_soundsystem_last_error = ma_sound_init_from_data_source(get_engine()->get_ma_engine(), ds->get_ma_data_source(), 0, nullptr, &*snd)) != MA_SUCCESS) {
			snd.reset();
			return false;
		}
		datasource = ds;
		postload(":datasource", false);
		return true;
	}
	bool is_load_completed() const override {
		return load_completed.test();
	}
	bool close() override {
		if (!snd) return false;
		// It's possible that this sound could still be loading in a job thread when we try to destroy it. Unfortunately there isn't a way to cancel this, so we have to just wait.
		if (!load_completed.test()) ma_fence_wait(&fence);
		if (spatializer) {
			unique_lock<mutex> lock(spatialization_params_mutex);
			node_chain->remove_node(spatializer);
			spatializer->release();
			spatializer = nullptr;
		}
		ma_sound_uninit(&*snd);
		snd.reset();
		if (datasource) {
			datasource->release();
			datasource = nullptr;
		}
		node = nullptr;
		if (pcm_stream) ma_pcm_rb_uninit(&*pcm_stream);
		pcm_stream.reset();
		pcm_buffer.resize(0);
		loaded_filename.clear();
		load_completed.clear();
		paused = should_autoclose = false;
		return true;
	}
	void set_autoclose(bool enabled) override { should_autoclose = enabled; }
	bool get_autoclose() const override { return should_autoclose; }
	const std::string &get_loaded_filename() const override { return loaded_filename; }
	audio_data_source* get_datasource() const override {
		if (!datasource && snd && (datasource = audio_data_source_get(snd->pDataSource, get_engine())) == nullptr) return nullptr;
		return datasource;
	}
	bool get_active() override {
		return snd ? true : false;
	}
	bool get_paused() override {
		return snd ? !ma_sound_is_playing(&*snd) && paused : false;
	}
	bool play(bool reset_loop_state = true) override {
		paused = false;
		if (pcm_stream) ma_pcm_rb_reset(&*pcm_stream);
		return mixer_impl::play(reset_loop_state);
	}
	bool play_looped() override {
		if (pcm_stream) return false;
		paused = false;
		return mixer_impl::play_looped();
	}
	bool play_wait() override {
		if (pcm_stream || !play())
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
		if (snd && !pcm_stream) {
			g_soundsystem_last_error = ma_sound_stop(&*snd);
			if (g_soundsystem_last_error == MA_SUCCESS)
				paused = true;
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	bool pause_fade(unsigned long long length) override {
		return (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES) ? pause_fade_in_frames(length) : pause_fade_in_milliseconds(length);
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
		return (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES) ? set_timed_fade_in_frames(start_volume, end_volume, length, absolute_time) : set_timed_fade_in_milliseconds(start_volume, end_volume, length, absolute_time);
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
		return (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES) ? set_stop_time_with_fade_in_frames(absolute_time, fade_length) : set_stop_time_with_fade_in_milliseconds(absolute_time, fade_length);
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
		if (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES)
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
		if (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES)
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
		if (get_engine()->get_flags() & audio_engine::DURATIONS_IN_FRAMES)
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

class microphone_impl : public audio_data_source_impl, public virtual microphone {
	unique_ptr<ma_device> capture_device;
	int device_index;
	ma_pcm_rb ring_buffer;
	static void capture_data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount) {
		microphone_impl* node = (microphone_impl*)pDevice->pUserData;
		if (node && pInput && frameCount > 0) {
			ma_uint32 framesToWrite = frameCount;
			void* pWriteBuffer;
			if (ma_pcm_rb_acquire_write(&node->ring_buffer, &framesToWrite, &pWriteBuffer) == MA_SUCCESS) {
				if (framesToWrite) ma_copy_pcm_frames(pWriteBuffer, pInput, framesToWrite, node->ring_buffer.format, node->ring_buffer.channels);
				ma_pcm_rb_commit_write(&node->ring_buffer, framesToWrite);
			}
		}
	}
public:
	microphone_impl(audio_engine* e, int device) : audio_data_source_impl(e), capture_device(make_unique<ma_device>()), device_index(device) {
		ma_uint32 channels = e->get_channels();
		if (ma_pcm_rb_init(ma_format_f32, channels, 8192, nullptr, nullptr, &ring_buffer) != MA_SUCCESS) throw std::runtime_error("failed to initialize ring buffer");
		ma_device_config device_config = ma_device_config_init(ma_device_type_capture);
		device_config.capture.format = ma_format_f32;
		device_config.capture.channels = channels;
		device_config.sampleRate = e->get_sample_rate();
		device_config.dataCallback = capture_data_callback;
		device_config.pUserData = this;
		device_config.periodSizeInFrames = SOUNDSYSTEM_FRAMESIZE * 2;
		device_config.capture.pDeviceID = (device >= 0 && device < g_sound_input_devices.size()) ? &g_sound_input_devices[device_index].id : nullptr;
		if ((g_soundsystem_last_error = ma_device_init(nullptr, &device_config, &*capture_device)) != MA_SUCCESS) {
			ma_pcm_rb_uninit(&ring_buffer);
			throw std::runtime_error("failed to initialize capture device");
		}
		set_ma_data_source((ma_data_source*)&ring_buffer);
		if ((g_soundsystem_last_error = ma_device_start(&*capture_device)) != MA_SUCCESS) audio_node_impl::set_state(ma_node_state_stopped);
	}
	~microphone_impl() {
		reset();
		if (capture_device) ma_device_uninit(&*capture_device);
		ma_pcm_rb_uninit(&ring_buffer);
	}
	bool set_device(int device) override {
		if (device == device_index) return true;
		if (device < -1 || device >= int(g_sound_input_devices.size())) return false;
		if (capture_device) {
			ma_device_stop(&*capture_device);
			ma_device_uninit(&*capture_device);
			capture_device.reset();
		}
		ma_device_config device_config = ma_device_config_init(ma_device_type_capture);
		device_config.capture.format = ma_format_f32;
		device_config.capture.channels = get_engine()->get_channels();
		device_config.sampleRate = get_engine()->get_sample_rate();
		device_config.dataCallback = capture_data_callback;
		device_config.pUserData = this;
		device_config.capture.pDeviceID = (device >= 0 && device < int(g_sound_input_devices.size())) ? &g_sound_input_devices[device].id : nullptr;
		if ((g_soundsystem_last_error = ma_device_init(nullptr, &device_config, &*capture_device)) != MA_SUCCESS) return false;
		device_index = device;
		if ((g_soundsystem_last_error = ma_device_start(&*capture_device)) != MA_SUCCESS) {
			audio_node_impl::set_state(ma_node_state_stopped);
			return false;
		}
		return true;
	}
	int get_device() const override { return device_index; }
	bool set_state(ma_node_state state) override {
		bool ret = audio_node_impl::set_state(state);
		if (!capture_device) return ret;
		if (!ret) return false;
		if (state == ma_node_state_stopped) return ma_device_stop(&*capture_device) == MA_SUCCESS;
		else if (state == ma_node_state_started) {
			ma_pcm_rb_reset(&ring_buffer);
			return ma_device_start(&*capture_device) == MA_SUCCESS;
		}
		return false;
	}
};
microphone* microphone::create(int device, audio_engine* engine) { return new microphone_impl(engine, device); }

audio_engine *new_audio_engine(int flags, int sample_rate, int channels) { return new audio_engine_impl(flags, sample_rate, channels); }
mixer *new_mixer(audio_engine *engine) { return new mixer_impl(engine); }
sound *new_sound(audio_engine *engine) { return new sound_impl(engine); }
mixer *new_global_mixer() {
	init_sound();
	return new mixer_impl(g_audio_engine);
}
sound *new_global_sound() {
	init_sound();
	sound* s = new sound_impl(g_audio_engine);
	if (!s) return nullptr;
	if (g_audio_mixer) s->set_mixer(g_audio_mixer);
	return s;
}
int get_sound_output_device() {
	init_sound();
	return g_audio_engine->get_device();
}
void set_sound_output_device(int device) {
	init_sound();
	g_audio_engine->set_device(device);
}
sound* sound_play(const string& path, const reactphysics3d::Vector3& position, float volume, float pan, float pitch, mixer* mix, const pack_interface* pack_file, bool autoplay) {
	if (!init_sound()) return nullptr;
	return g_audio_engine->play(path, position, volume, pan, pitch, mix, pack_file, autoplay);
}
reactphysics3d::Vector3 sound_get_listener_position(unsigned int listener_index = 0) {
	if (!init_sound()) return reactphysics3d::Vector3(0, 0, 0);
	return g_audio_engine->get_listener_position(listener_index);
}
bool sound_set_listener_position(float x, float y, float z, unsigned int listener_index = 0) {
	if (!init_sound()) return false;
	g_audio_engine->set_listener_position(listener_index, x, y, z);
	return true;
}
bool sound_set_listener_position_vector(const reactphysics3d::Vector3& position, unsigned int listener_index = 0) {
	if (!init_sound()) return false;
	g_audio_engine->set_listener_position_vector(listener_index, position);
	return true;
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
string get_soundsystem_last_error_text() {
	const char* msg = ma_result_description(g_soundsystem_last_error);
	return msg? msg : "";
}
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
audio_engine* get_sound_default_engine() {
	init_sound();
	return g_audio_engine;
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
template < class T > inline void RegisterSoundsystemAudioNode(asIScriptEngine *engine, const std::string &type) {
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
	if constexpr (!std::is_same < T, audio_node >::value) {
		engine->RegisterObjectMethod(type.c_str(), "audio_node@ opImplCast()", asFUNCTION((op_cast < T, audio_node >)), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectMethod("audio_node", Poco::format("%s@ opCast()", type).c_str(), asFUNCTION((op_cast < audio_node, T >)), asCALL_CDECL_OBJFIRST);
	}
}
template < class T > inline void RegisterSoundsystemDataSource(asIScriptEngine *engine, const std::string &type) {
	RegisterSoundsystemAudioNode<T>(engine, type);
	engine->RegisterObjectMethod(type.c_str(), "float[]@ read(uint64 frame_count)", asFUNCTION((virtual_call<T, &T::read_script, CScriptArray*, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint64 skip_frames(uint64 frame_count)", asFUNCTION((virtual_call<T, &T::skip_frames, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float skip_milliseconds(float ms)", asFUNCTION((virtual_call<T, &T::skip_milliseconds, float, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool seek_frames(uint64 frame_index)", asFUNCTION((virtual_call<T, &T::seek_frames, bool, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint64 get_cursor_frames() const property", asFUNCTION((virtual_call<T, &T::get_cursor_frames, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool seek_milliseconds(float ms)", asFUNCTION((virtual_call<T, &T::seek_milliseconds, bool, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_cursor_milliseconds() const property", asFUNCTION((virtual_call<T, &T::get_cursor_milliseconds, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint64 get_length_frames() const property", asFUNCTION((virtual_call<T, &T::get_length_frames, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_length_milliseconds() const property", asFUNCTION((virtual_call<T, &T::get_length_milliseconds, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_looping(bool looping)", asFUNCTION((virtual_call<T, &T::set_looping, bool, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_looping() const property", asFUNCTION((virtual_call<T, &T::get_looping, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_range(uint64 start_frame, uint64 end_frame)", asFUNCTION((virtual_call<T, &T::set_range, bool, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void get_range(uint64&out start_frame, uint64&out end_frame) const", asFUNCTION((virtual_call<T, &T::get_range, void, unsigned long long*, unsigned long long*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_loop_point(uint64 start_frame, uint64 end_frame)", asFUNCTION((virtual_call<T, &T::set_loop_point, bool, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void get_loop_point(uint64&out start_frame, uint64&out end_frame) const", asFUNCTION((virtual_call<T, &T::get_loop_point, void, unsigned long long*, unsigned long long*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_current(audio_data_source@ new_current)", asFUNCTION((virtual_call<T, &T::set_current, bool, audio_data_source*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_data_source@+ get_current() const property", asFUNCTION((virtual_call<T, &T::get_current, audio_data_source*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_next(audio_data_source@ new_next)", asFUNCTION((virtual_call<T, &T::set_next, bool, audio_data_source*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_data_source@+ get_next() const property", asFUNCTION((virtual_call<T, &T::get_next, audio_data_source*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_active() const property", asFUNCTION((virtual_call<T, &T::get_active, bool>)), asCALL_CDECL_OBJFIRST);
	if constexpr (!std::is_same < T, audio_data_source >::value) {
		engine->RegisterObjectMethod(type.c_str(), "audio_data_source@ opImplCast()", asFUNCTION((op_cast<T, audio_data_source>)), asCALL_CDECL_OBJFIRST);
		engine->RegisterObjectMethod("audio_data_source", Poco::format("%s@ opCast()", type).c_str(), asFUNCTION((op_cast<audio_data_source, T>)), asCALL_CDECL_OBJFIRST);
	}
}
void RegisterSoundsystemEngine(asIScriptEngine *engine) {
	RegisterSoundsystemAudioNode<audio_engine>(engine, "audio_engine");
	engine->RegisterFuncdef("void audio_engine_processing_callback(audio_engine@ engine, memory_buffer<float>& data, uint64 frames)");
	engine->RegisterObjectBehaviour("audio_engine", asBEHAVE_FACTORY, "audio_engine@ e(int flags, int sample_rate = 0, int channels = 0)", asFUNCTION(new_audio_engine), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_engine", "int get_flags() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_flags, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "int get_device() const", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_device, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "bool set_device(int device)", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_device, bool, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "audio_node@+ get_endpoint() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_endpoint, audio_node * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "float[]@ read(uint64 frame_count)", asFUNCTION((virtual_call < audio_engine, &audio_engine::read_script, CScriptArray *, unsigned long long >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "void set_processing_callback(audio_engine_processing_callback@ cb) property", asFUNCTION((virtual_call < audio_engine, &audio_engine::set_processing_callback, void, asIScriptFunction*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "audio_engine_processing_callback@+ get_processing_callback() const property", asFUNCTION((virtual_call < audio_engine, &audio_engine::get_processing_callback, asIScriptFunction* >)), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterGlobalFunction("audio_engine@+ get_sound_default_engine() property", asFUNCTION(get_sound_default_engine), asCALL_CDECL);
}
void RegisterSoundsystemDataSources(asIScriptEngine* engine) {
	RegisterSoundsystemDataSource<audio_data_source>(engine, "audio_data_source");
	RegisterSoundsystemDataSource<audio_decoder>(engine, "audio_decoder");
	engine->RegisterObjectBehaviour("audio_decoder", asBEHAVE_FACTORY, "audio_decoder@ d(audio_engine@ engine = sound_default_engine)", asFUNCTION(audio_decoder::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_decoder", "bool open(const string&in filename, const pack_interface@+ pack_file = sound_default_pack, uint sample_rate = 0, uint channels = 0)", asFUNCTION((virtual_call < audio_decoder, &audio_decoder::open, bool, const string&, const pack_interface*, unsigned int, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_decoder", "bool open(datastream@ stream, uint sample_rate = 0, uint channels = 0)", asFUNCTION((virtual_call < audio_decoder, &audio_decoder::open_stream, bool, datastream*, unsigned int, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_decoder", "bool close()", asFUNCTION((virtual_call < audio_decoder, &audio_decoder::close, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_decoder", "uint get_sample_rate() const property", asFUNCTION((virtual_call < audio_decoder, &audio_decoder::get_sample_rate, unsigned int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_decoder", "uint get_channels() const property", asFUNCTION((virtual_call < audio_decoder, &audio_decoder::get_channels, unsigned int >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemDataSource<microphone>(engine, "microphone");
	engine->RegisterObjectBehaviour("microphone", asBEHAVE_FACTORY, "microphone@ m(int device = -1, audio_engine@ engine = sound_default_engine)", asFUNCTION(microphone::create), asCALL_CDECL);
	engine->RegisterObjectMethod("microphone", "bool set_device(int device)", asFUNCTION((virtual_call < microphone, &microphone::set_device, bool, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("microphone", "int get_device() const property", asFUNCTION((virtual_call < microphone, &microphone::get_device, int>)), asCALL_CDECL_OBJFIRST);
}
template < class T > void RegisterSoundsystemMixer(asIScriptEngine *engine, const string &type) {
	RegisterSoundsystemAudioNode < T > (engine, type);
	engine->RegisterObjectMethod(type.c_str(), "audio_engine@+ get_engine() const property", asFUNCTION((virtual_call < T, &T::get_engine, audio_engine * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_mixer(mixer@ parent_mixer)", asFUNCTION((virtual_call < T, &T::set_mixer, bool, mixer * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "mixer@+ get_mixer() const", asFUNCTION((virtual_call < T, &T::get_mixer, mixer * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_3d_panner(int panner_id)", asFUNCTION((virtual_call < T, &T::set_3d_panner, void, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "int get_3d_panner() const property", asFUNCTION((virtual_call < T, &T::get_3d_panner, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_3d_attenuator(int attenuator_id)", asFUNCTION((virtual_call < T, &T::set_3d_attenuator, void, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "int get_3d_attenuator() const property", asFUNCTION((virtual_call < T, &T::get_3d_attenuator, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "int get_preferred_3d_panner() const property", asFUNCTION((virtual_call < T, &T::get_preferred_3d_panner, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "int get_preferred_3d_attenuator() const property", asFUNCTION((virtual_call < T, &T::get_preferred_3d_attenuator, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_hrtf(bool enabled) property", asFUNCTION((virtual_call < T, &T::set_hrtf, void, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_hrtf() const property", asFUNCTION((virtual_call < T, &T::get_hrtf, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_shape(ref@ shape)", asFUNCTION((virtual_call < T, &T::set_shape, bool, CScriptHandle*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "ref@ get_shape() const property", asFUNCTION((virtual_call < T, &T::get_shape, CScriptHandle*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_reverb3d(reverb3d@ reverb) property", asFUNCTION((virtual_call < T, &T::set_reverb3d, void, reverb3d*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_reverb3d_at(reverb3d@ reverb, reverb3d_placement placement)", asFUNCTION((virtual_call < T, &T::set_reverb3d_at, void, reverb3d*, audio_spatializer_reverb3d_placement>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "reverb3d@+ get_reverb3d() const property", asFUNCTION((virtual_call < T, &T::get_reverb3d, reverb3d*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_splitter_node@+ get_reverb3d_attachment() const property", asFUNCTION((virtual_call < T, &T::get_reverb3d_attachment, splitter_node*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "reverb3d_placement get_reverb3d_placement() const property", asFUNCTION((virtual_call < T, &T::get_reverb3d_placement, audio_spatializer_reverb3d_placement>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_node_chain@+ get_effects_chain() property", asFUNCTION((virtual_call < T, &T::get_effects_chain, audio_node_chain*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_node_chain@+ get_internal_node_chain() property", asFUNCTION((virtual_call < T, &T::get_internal_node_chain, audio_node_chain*>)), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterObjectBehaviour("audio_node_chain", asBEHAVE_FACTORY, "audio_node_chain@ c(audio_node@ source = null, audio_node@ endpoint = null, audio_engine@+ engine = sound_default_engine)", asFUNCTION(audio_node_chain::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_node_chain", "bool add_node(audio_node@+ node, audio_node@+ after = null, uint input_bus_index = 0)", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::add_node, bool, audio_node*, audio_node*, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "bool add_node(audio_node@+ node, int after, uint input_bus_index = 0)", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::add_node_at, bool, audio_node*, int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "bool remove_node(audio_node@+ node)", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::remove_node, bool, audio_node*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "bool remove_node(uint index)", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::remove_node_at, bool, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "bool clear(bool detach_nodes = true)", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::clear, bool, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "void set_endpoint(audio_node@+ endpoint, uint input_bus_index = 0)", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::set_endpoint, void, audio_node*, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "audio_node@+ get_endpoint() const property", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::get_endpoint, audio_node*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "audio_node@+ get_first() const property", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::first, audio_node*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "audio_node@+ get_last() const property", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::last, audio_node*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "audio_node@+ opIndex(uint index) const", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::operator[], audio_node*, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "int find(audio_node@+ node) const", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::index_of, int, audio_node*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_node_chain", "uint get_node_count() const property", asFUNCTION((virtual_call < audio_node_chain, &audio_node_chain::get_node_count, unsigned int >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode < phonon_binaural_node > (engine, "phonon_binaural_node");
	engine->RegisterObjectBehaviour("phonon_binaural_node", asBEHAVE_FACTORY, "phonon_binaural_node@ n(audio_engine@ engine, int channels, int sample_rate, int frame_size = 0)", asFUNCTION(phonon_binaural_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_direction(float x, float y, float z, float distance)", asFUNCTION((virtual_call < phonon_binaural_node, &phonon_binaural_node::set_direction, void, float, float, float, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_direction(const vector&in direction, float distance)", asFUNCTION((virtual_call < phonon_binaural_node, &phonon_binaural_node::set_direction_vector, void, const reactphysics3d::Vector3 &, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_spatial_blend_max_distance(float max_distance)", asFUNCTION((virtual_call < phonon_binaural_node, &phonon_binaural_node::set_spatial_blend_max_distance, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("bool set_sound_global_hrtf(bool enabled)", asFUNCTION(set_global_hrtf), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_sound_global_hrtf() property", asFUNCTION(get_global_hrtf), asCALL_CDECL);
	engine->RegisterObjectBehaviour("audio_splitter_node", asBEHAVE_FACTORY, "audio_splitter_node@ n(audio_engine@ engine, int channels)", asFUNCTION(splitter_node::create), asCALL_CDECL);
	RegisterSoundsystemAudioNode <low_pass_filter_node> (engine, "audio_low_pass_filter");
	engine->RegisterObjectBehaviour("audio_low_pass_filter", asBEHAVE_FACTORY, "audio_low_pass_filter@ f(double cutoff_frequency, uint order, audio_engine@ engine = sound_default_engine)", asFUNCTION(low_pass_filter_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_low_pass_filter", "void set_cutoff_frequency(double frequency) property", asFUNCTION((virtual_call < low_pass_filter_node, &low_pass_filter_node::set_cutoff_frequency, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_low_pass_filter", "double get_cutoff_frequency() const property", asFUNCTION((virtual_call < low_pass_filter_node, &low_pass_filter_node::get_cutoff_frequency, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_low_pass_filter", "void set_order(uint order) property", asFUNCTION((virtual_call < low_pass_filter_node, &low_pass_filter_node::set_order, void, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_low_pass_filter", "uint get_order() const property", asFUNCTION((virtual_call < low_pass_filter_node, &low_pass_filter_node::get_order, unsigned int >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode <high_pass_filter_node> (engine, "audio_high_pass_filter");
	engine->RegisterObjectBehaviour("audio_high_pass_filter", asBEHAVE_FACTORY, "audio_high_pass_filter@ f(double cutoff_frequency, uint order, audio_engine@ engine = sound_default_engine)", asFUNCTION(high_pass_filter_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_high_pass_filter", "void set_cutoff_frequency(double frequency) property", asFUNCTION((virtual_call < high_pass_filter_node, &high_pass_filter_node::set_cutoff_frequency, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_high_pass_filter", "double get_cutoff_frequency() const property", asFUNCTION((virtual_call < high_pass_filter_node, &high_pass_filter_node::get_cutoff_frequency, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_high_pass_filter", "void set_order(uint order) property", asFUNCTION((virtual_call < high_pass_filter_node, &high_pass_filter_node::set_order, void, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_high_pass_filter", "uint get_order() const property", asFUNCTION((virtual_call < high_pass_filter_node, &high_pass_filter_node::get_order, unsigned int >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode <band_pass_filter_node> (engine, "audio_band_pass_filter");
	engine->RegisterObjectBehaviour("audio_band_pass_filter", asBEHAVE_FACTORY, "audio_band_pass_filter@ f(double cutoff_frequency, uint order, audio_engine@ engine = sound_default_engine)", asFUNCTION(band_pass_filter_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_band_pass_filter", "void set_cutoff_frequency(double frequency) property", asFUNCTION((virtual_call < band_pass_filter_node, &band_pass_filter_node::set_cutoff_frequency, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_band_pass_filter", "double get_cutoff_frequency() const property", asFUNCTION((virtual_call < band_pass_filter_node, &band_pass_filter_node::get_cutoff_frequency, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_band_pass_filter", "void set_order(uint order) property", asFUNCTION((virtual_call < band_pass_filter_node, &band_pass_filter_node::set_order, void, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_band_pass_filter", "uint get_order() const property", asFUNCTION((virtual_call < band_pass_filter_node, &band_pass_filter_node::get_order, unsigned int >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode <notch_filter_node> (engine, "audio_notch_filter");
	engine->RegisterObjectBehaviour("audio_notch_filter", asBEHAVE_FACTORY, "audio_notch_filter@ f(double q, double frequency, audio_engine@ engine = sound_default_engine)", asFUNCTION(notch_filter_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_notch_filter", "void set_q(double q) property", asFUNCTION((virtual_call < notch_filter_node, &notch_filter_node::set_q, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_notch_filter", "double get_q() const property", asFUNCTION((virtual_call < notch_filter_node, &notch_filter_node::get_q, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_notch_filter", "void set_frequency(double frequency) property", asFUNCTION((virtual_call < notch_filter_node, &notch_filter_node::set_frequency, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_notch_filter", "double get_frequency() const property", asFUNCTION((virtual_call < notch_filter_node, &notch_filter_node::get_frequency, double >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode <peak_filter_node> (engine, "audio_peak_filter");
	engine->RegisterObjectBehaviour("audio_peak_filter", asBEHAVE_FACTORY, "audio_peak_filter@ f(double gain_db, double q, double frequency, audio_engine@ engine = sound_default_engine)", asFUNCTION(peak_filter_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_peak_filter", "void set_gain(double gain) property", asFUNCTION((virtual_call < peak_filter_node, &peak_filter_node::set_gain, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_peak_filter", "double get_gain() const property", asFUNCTION((virtual_call < peak_filter_node, &peak_filter_node::get_gain, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_peak_filter", "void set_q(double q) property", asFUNCTION((virtual_call < peak_filter_node, &peak_filter_node::set_q, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_peak_filter", "double get_q() const property", asFUNCTION((virtual_call < peak_filter_node, &peak_filter_node::get_q, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_peak_filter", "void set_frequency(double frequency) property", asFUNCTION((virtual_call < peak_filter_node, &peak_filter_node::set_frequency, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_peak_filter", "double get_frequency() const property", asFUNCTION((virtual_call < peak_filter_node, &peak_filter_node::get_frequency, double >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode <low_shelf_filter_node> (engine, "audio_low_shelf_filter");
	engine->RegisterObjectBehaviour("audio_low_shelf_filter", asBEHAVE_FACTORY, "audio_low_shelf_filter@ f(double gain_db, double q, double frequency, audio_engine@ engine = sound_default_engine)", asFUNCTION(low_shelf_filter_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_low_shelf_filter", "void set_gain(double gain) property", asFUNCTION((virtual_call < low_shelf_filter_node, &low_shelf_filter_node::set_gain, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_low_shelf_filter", "double get_gain() const property", asFUNCTION((virtual_call < low_shelf_filter_node, &low_shelf_filter_node::get_gain, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_low_shelf_filter", "void set_q(double q) property", asFUNCTION((virtual_call < low_shelf_filter_node, &low_shelf_filter_node::set_q, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_low_shelf_filter", "double get_q() const property", asFUNCTION((virtual_call < low_shelf_filter_node, &low_shelf_filter_node::get_q, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_low_shelf_filter", "void set_frequency(double frequency) property", asFUNCTION((virtual_call < low_shelf_filter_node, &low_shelf_filter_node::set_frequency, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_low_shelf_filter", "double get_frequency() const property", asFUNCTION((virtual_call < low_shelf_filter_node, &low_shelf_filter_node::get_frequency, double >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode <high_shelf_filter_node> (engine, "audio_high_shelf_filter");
	engine->RegisterObjectBehaviour("audio_high_shelf_filter", asBEHAVE_FACTORY, "audio_high_shelf_filter@ f(double gain_db, double q, double frequency, audio_engine@ engine = sound_default_engine)", asFUNCTION(high_shelf_filter_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_high_shelf_filter", "void set_gain(double gain) property", asFUNCTION((virtual_call < high_shelf_filter_node, &high_shelf_filter_node::set_gain, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_high_shelf_filter", "double get_gain() const property", asFUNCTION((virtual_call < high_shelf_filter_node, &high_shelf_filter_node::get_gain, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_high_shelf_filter", "void set_q(double q) property", asFUNCTION((virtual_call < high_shelf_filter_node, &high_shelf_filter_node::set_q, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_high_shelf_filter", "double get_q() const property", asFUNCTION((virtual_call < high_shelf_filter_node, &high_shelf_filter_node::get_q, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_high_shelf_filter", "void set_frequency(double frequency) property", asFUNCTION((virtual_call < high_shelf_filter_node, &high_shelf_filter_node::set_frequency, void, double >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_high_shelf_filter", "double get_frequency() const property", asFUNCTION((virtual_call < high_shelf_filter_node, &high_shelf_filter_node::get_frequency, double >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode <delay_node> (engine, "audio_delay_node");
	engine->RegisterObjectBehaviour("audio_delay_node", asBEHAVE_FACTORY, "audio_delay_node@ d(uint delay_in_frames, float decay, audio_engine@ engine = sound_default_engine)", asFUNCTION(delay_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_delay_node", "void set_wet(float wet) property", asFUNCTION((virtual_call < delay_node, &delay_node::set_wet, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_delay_node", "float get_wet() const property", asFUNCTION((virtual_call < delay_node, &delay_node::get_wet, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_delay_node", "void set_dry(float dry) property", asFUNCTION((virtual_call < delay_node, &delay_node::set_dry, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_delay_node", "float get_dry() const property", asFUNCTION((virtual_call < delay_node, &delay_node::get_dry, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_delay_node", "void set_decay(float decay) property", asFUNCTION((virtual_call < delay_node, &delay_node::set_decay, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_delay_node", "float get_decay() const property", asFUNCTION((virtual_call < delay_node, &delay_node::get_decay, float >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemAudioNode <freeverb_node> (engine, "audio_freeverb_node");
	engine->RegisterObjectBehaviour("audio_freeverb_node", asBEHAVE_FACTORY, "audio_freeverb_node@ n(audio_engine@ engine = sound_default_engine)", asFUNCTION(freeverb_node::create), asCALL_CDECL);
	engine->RegisterObjectMethod("audio_freeverb_node", "void set_room_size(float size) property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::set_room_size, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "float get_room_size() const property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::get_room_size, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "void set_damping(float damping) property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::set_damping, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "float get_damping() const property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::get_damping, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "void set_width(float width) property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::set_width, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "float get_width() const property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::get_width, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "void set_wet(float wet) property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::set_wet, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "float get_wet() const property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::get_wet, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "void set_dry(float dry) property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::set_dry, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "float get_dry() const property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::get_dry, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "void set_input_width(float width) property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::set_input_width, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "float get_input_width() const property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::get_input_width, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "void set_frozen(bool frozen) property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::set_frozen, void, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_freeverb_node", "bool get_frozen() const property", asFUNCTION((virtual_call < freeverb_node, &freeverb_node::get_frozen, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("reverb3d", asBEHAVE_FACTORY, "reverb3d@ n(audio_node@ reverb, mixer@ destination = mixer(), audio_engine@+ engine = sound_default_engine)", asFUNCTION(reverb3d::create), asCALL_CDECL);
	engine->RegisterObjectMethod("reverb3d", "void set_reverb(audio_node@ reverb) property", asFUNCTION((virtual_call < reverb3d, &reverb3d::set_reverb, void, audio_node*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "audio_node@+ get_reverb() const property", asFUNCTION((virtual_call < reverb3d, &reverb3d::get_reverb, audio_node*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "void set_mixer(mixer@ mix) property", asFUNCTION((virtual_call < reverb3d, &reverb3d::set_mixer, void, mixer*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "mixer@+ get_mixer() const property", asFUNCTION((virtual_call < reverb3d, &reverb3d::get_mixer, mixer*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "void set_min_volume(float min_volume) property", asFUNCTION((virtual_call < reverb3d, &reverb3d::set_min_volume, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "float get_min_volume() const property", asFUNCTION((virtual_call < reverb3d, &reverb3d::get_min_volume, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "void set_max_volume(float max_volume) property", asFUNCTION((virtual_call < reverb3d, &reverb3d::set_max_volume, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "float get_max_volume() const property", asFUNCTION((virtual_call < reverb3d, &reverb3d::get_max_volume, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "void set_max_volume_distance(float distance) property", asFUNCTION((virtual_call < reverb3d, &reverb3d::set_max_volume_distance, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "float get_max_volume_distance() const property", asFUNCTION((virtual_call < reverb3d, &reverb3d::get_max_volume_distance, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "void set_max_audible_distance(float distance) property", asFUNCTION((virtual_call < reverb3d, &reverb3d::set_max_audible_distance, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "float get_max_audible_distance() const property", asFUNCTION((virtual_call < reverb3d, &reverb3d::get_max_audible_distance, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "void set_volume_curve(float volume_curve) property", asFUNCTION((virtual_call < reverb3d, &reverb3d::set_volume_curve, void, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "float get_volume_curve() const property", asFUNCTION((virtual_call < reverb3d, &reverb3d::get_volume_curve, float >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "float get_volume_at(float distance) const", asFUNCTION((virtual_call < reverb3d, &reverb3d::get_volume_at, float, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("reverb3d", "audio_splitter_node@ create_attachment(audio_node@+ dry_input = null, audio_node@+ dry_output = null)", asFUNCTION((virtual_call < reverb3d, &reverb3d::create_attachment, splitter_node*, audio_node*, audio_node*>)), asCALL_CDECL_OBJFIRST);
}
void RegisterSoundsystemShapes(asIScriptEngine* engine) {
	int ot = engine->RegisterObjectType("sound_aabb_shape", 0, asOBJ_REF); assert(ot >= 0);
	g_sound_shape_setup_callbacks[ot] = sound_shape_builtin_standard_setup;
	engine->RegisterObjectBehaviour("sound_aabb_shape", asBEHAVE_FACTORY, "sound_aabb_shape@ s(int left_range, int right_range, int backward_range, int forward_range, int lower_range, int upper_range)", asFUNCTION(create_sound_aabb_shape), asCALL_CDECL);
	engine->RegisterObjectBehaviour("sound_aabb_shape", asBEHAVE_ADDREF, "void f()", asMETHOD(sound_aabb_shape, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("sound_aabb_shape", asBEHAVE_RELEASE, "void f()", asMETHOD(sound_aabb_shape, release), asCALL_THISCALL);
	engine->RegisterObjectProperty("sound_aabb_shape", "int left_range", asOFFSET(sound_aabb_shape, left_range));
	engine->RegisterObjectProperty("sound_aabb_shape", "int right_range", asOFFSET(sound_aabb_shape, right_range));
	engine->RegisterObjectProperty("sound_aabb_shape", "int backward_range", asOFFSET(sound_aabb_shape, backward_range));
	engine->RegisterObjectProperty("sound_aabb_shape", "int forward_range", asOFFSET(sound_aabb_shape, forward_range));
	engine->RegisterObjectProperty("sound_aabb_shape", "int lower_range", asOFFSET(sound_aabb_shape, lower_range));
	engine->RegisterObjectProperty("sound_aabb_shape", "int upper_range", asOFFSET(sound_aabb_shape, upper_range));
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
	engine->RegisterEnum("audio_engine_flags");
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_DURATIONS_IN_FRAMES", audio_engine::DURATIONS_IN_FRAMES);
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_NO_AUTO_START", audio_engine::NO_AUTO_START);
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_NO_DEVICE", audio_engine::NO_DEVICE);
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_NO_CLIP", audio_engine::NO_CLIP);
	engine->RegisterEnumValue("audio_engine_flags", "AUDIO_ENGINE_PERCENTAGE_ATTRIBUTES", audio_engine::PERCENTAGE_ATTRIBUTES);
	engine->RegisterEnum("audio_panner");
	engine->RegisterEnumValue("audio_panner", "audio_panner_basic", g_audio_basic_panner);
	engine->RegisterEnumValue("audio_panner", "audio_panner_phonon_hrtf", g_audio_phonon_hrtf_panner);
	engine->RegisterEnum("audio_attenuator");
	engine->RegisterEnumValue("audio_attenuator", "audio_attenuator_basic", g_audio_basic_attenuator);
	engine->RegisterEnumValue("audio_attenuator", "audio_attenuator_phonon", g_audio_phonon_attenuator);
	engine->RegisterEnum("reverb3d_placement");
	engine->RegisterEnumValue("reverb3d_placement", "reverb3d_prepan", prepan);
	engine->RegisterEnumValue("reverb3d_placement", "reverb3d_postpan", postpan);
	engine->RegisterEnumValue("reverb3d_placement", "reverb3d_postattenuate", postattenuate);
	RegisterSoundsystemAudioNode < audio_node > (engine, "audio_node");
	RegisterSoundsystemEngine(engine);
	RegisterSoundsystemAudioNode < audio_node_chain > (engine, "audio_node_chain");
	RegisterSoundsystemAudioNode < splitter_node > (engine, "audio_splitter_node");
	RegisterSoundsystemAudioNode <reverb3d> (engine, "reverb3d");
	RegisterSoundsystemMixer < mixer > (engine, "mixer");
	engine->RegisterObjectBehaviour("mixer", asBEHAVE_FACTORY, "mixer@ m()", asFUNCTION(new_global_mixer), asCALL_CDECL);
	RegisterSoundsystemMixer < sound > (engine, "sound");
	engine->RegisterObjectMethod("audio_engine", "sound@ play(const string&in path, const vector&in position = vector(FLOAT_MAX, FLOAT_MAX, FLOAT_MAX), float volume = 0.0, float pan = 0.0, float pitch = 100.0, mixer@ mix = null, const pack_interface@ pack_file = sound_default_pack, bool autoplay = true)", asFUNCTION((virtual_call < audio_engine, &audio_engine::play, sound*, const string &, const reactphysics3d::Vector3&, float, float, float, mixer*, const pack_interface*, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "mixer@ mixer()", asFUNCTION((virtual_call < audio_engine, &audio_engine::new_mixer, mixer * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("audio_engine", "sound@ sound()", asFUNCTION((virtual_call < audio_engine, &audio_engine::new_sound, sound * >)), asCALL_CDECL_OBJFIRST);
	RegisterSoundsystemDataSources(engine);
	RegisterSoundsystemNodes(engine);
	RegisterSoundsystemShapes(engine);
	engine->RegisterObjectBehaviour("sound", asBEHAVE_FACTORY, "sound@ s()", asFUNCTION(new_global_sound), asCALL_CDECL);
	engine->RegisterObjectMethod("sound", "bool load(const string&in filename, const pack_interface@ pack = null)", asFUNCTION((virtual_call < sound, &sound::load, bool, const string &, pack_interface * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream(const string&in filename, const pack_interface@ pack = null)", asFUNCTION((virtual_call < sound, &sound::stream, bool, const string &, pack_interface * >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_memory(const string&in data)", asFUNCTION((virtual_call < sound, &sound::load_string, bool, const string & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const float[]@ data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script_array, bool, CScriptArray *, int, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const int[]@ data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script_array, bool, CScriptArray *, int, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const int16[]@ data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script_array, bool, CScriptArray *, int, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const uint8[]@ data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script_array, bool, CScriptArray *, int, int >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const memory_buffer<float>&in data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script_memory_buffer, bool, script_memory_buffer*, int, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const memory_buffer<int>&in data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script_memory_buffer, bool, script_memory_buffer*, int, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const memory_buffer<int16>&in data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script_memory_buffer, bool, script_memory_buffer*, int, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_pcm(const memory_buffer<uint8>&in data, int samplerate, int channels)", asFUNCTION((virtual_call < sound, &sound::load_pcm_script_memory_buffer, bool, script_memory_buffer*, int, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream_pcm(const float[]@ data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0)", asFUNCTION((virtual_call < sound, &sound::stream_pcm_script_array, bool, CScriptArray*, unsigned int, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream_pcm(const int[]@ data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0)", asFUNCTION((virtual_call < sound, &sound::stream_pcm_script_array, bool, CScriptArray*, unsigned int, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream_pcm(const int16[]@ data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0)", asFUNCTION((virtual_call < sound, &sound::stream_pcm_script_array, bool, CScriptArray*, unsigned int, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream_pcm(const uint8[]@ data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0)", asFUNCTION((virtual_call < sound, &sound::stream_pcm_script_array, bool, CScriptArray*, unsigned int, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream_pcm(const memory_buffer<float>&in data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0)", asFUNCTION((virtual_call < sound, &sound::stream_pcm_script_memory_buffer, bool, script_memory_buffer*, unsigned int, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream_pcm(const memory_buffer<int>&in data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0)", asFUNCTION((virtual_call < sound, &sound::stream_pcm_script_memory_buffer, bool, script_memory_buffer*, unsigned int, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream_pcm(const memory_buffer<int16>&in data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0)", asFUNCTION((virtual_call < sound, &sound::stream_pcm_script_memory_buffer, bool, script_memory_buffer*, unsigned int, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream_pcm(const memory_buffer<uint8>&in data, uint sample_rate = 0, uint channels = 0, uint buffer_size = 0)", asFUNCTION((virtual_call < sound, &sound::stream_pcm_script_memory_buffer, bool, script_memory_buffer*, unsigned int, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool open(audio_data_source@ datasource)", asFUNCTION((virtual_call<sound, &sound::open, bool, audio_data_source*>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool close()", asFUNCTION((virtual_call < sound, &sound::close, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_autoclose(bool enabled = true) property", asFUNCTION((virtual_call < sound, &sound::set_autoclose, void, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_autoclose() const property", asFUNCTION((virtual_call < sound, &sound::get_autoclose, bool >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "const string& get_loaded_filename() const property", asFUNCTION((virtual_call < sound, &sound::get_loaded_filename, const std::string & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "audio_data_source@+ get_datasource() const property", asFUNCTION((virtual_call < sound, &sound::get_datasource, audio_data_source*>)), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterGlobalProperty("mixer@ sound_default_mixer", (void*)&g_audio_mixer);
	engine->RegisterGlobalFunction("void set_sound_output_device(int device) property", asFUNCTION(set_sound_output_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("sound@ sound_play(const string&in path, const vector&in position = vector(FLOAT_MAX, FLOAT_MAX, FLOAT_MAX), float volume = 0.0, float pan = 0.0, float pitch = 100.0, mixer@ mix = null, const pack_interface@ pack_file = sound_default_pack, bool autoplay = true)", asFUNCTION(sound_play), asCALL_CDECL);
	engine->RegisterGlobalFunction("vector sound_get_listener_position(uint listener_index = 0)", asFUNCTION(sound_get_listener_position), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool sound_set_listener_position(float x, float y, float z, uint listener_index = 0)", asFUNCTION(sound_set_listener_position), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool sound_set_listener_position(const vector&in position, uint listener_index = 0)", asFUNCTION(sound_set_listener_position_vector), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_default_decryption_key(const string& in key) property", asFUNCTION(set_default_decryption_key), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_default_pack(pack_interface@ storage) property", asFUNCTION(set_sound_default_storage), asCALL_CDECL);
	engine->RegisterGlobalFunction("pack_interface@ get_sound_default_pack() property", asFUNCTION(get_sound_default_storage), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_master_volume(float db) property", asFUNCTION(set_sound_master_volume), asCALL_CDECL);
	engine->RegisterGlobalFunction("float get_sound_master_volume() property", asFUNCTION(get_sound_master_volume), asCALL_CDECL);
	engine->RegisterGlobalFunction("audio_error_state get_SOUNDSYSTEM_LAST_ERROR() property", asFUNCTION(get_soundsystem_last_error), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_SOUNDSYSTEM_LAST_ERROR_TEXT() property", asFUNCTION(get_soundsystem_last_error_text), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_default_3d_panner(int panner_id)", asFUNCTION(sound_set_default_3d_panner), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_sound_default_3d_panner() property", asFUNCTION(sound_get_default_3d_panner), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_default_3d_attenuator(int attenuator_id)", asFUNCTION(sound_set_default_3d_attenuator), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_sound_default_3d_attenuator() property", asFUNCTION(sound_get_default_3d_attenuator), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_3d_panner_enabled(int panner_id, bool enabled)", asFUNCTION(set_audio_panner_enabled), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_sound_3d_panner_enabled(int panner_id)", asFUNCTION(get_audio_panner_enabled), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_3d_attenuator_enabled(int attenuator_id, bool enabled)", asFUNCTION(set_audio_attenuator_enabled), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_sound_3d_attenuator_enabled(int attenuator_id)", asFUNCTION(get_audio_attenuator_enabled), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool sound_set_spatialization(int panner, int attenuator, bool disable_previous = false, bool set_default = true)", asFUNCTION(sound_set_spatialization), asCALL_CDECL);
}
void nvgt_audio_plugin_node_register(const string& nodename) { RegisterSoundsystemAudioNode<plugin_node>(g_ScriptEngine, nodename); }
plugin_node* nvgt_audio_plugin_node_create(audio_plugin_node_interface* impl, unsigned char input_bus_count, unsigned char output_bus_count, unsigned int flags, audio_engine* engine) { return plugin_node::create(impl, input_bus_count, output_bus_count, flags, engine); }
audio_plugin_node_interface* nvgt_audio_plugin_node_get(plugin_node* node) { return node->get_plugin_interface(); }
