/* sound.cpp - sound system implementation code
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
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
#include <vector>
#include <Poco/MemoryStream.h>
#include <angelscript.h>
#include <scriptarray.h>
#include "nvgt_angelscript.h" // get_array_type
#include "sound.h"
#include "encryption_filter.h"
#include "pack_protocol.h"
#include "pack2.h"
#include "memory_protocol.h"
#include "resampler.h"
#include <atomic>
#include <utility>
#include <cstdint>
#include <miniaudio_libvorbis.h>
using namespace std;

class sound_impl;

// Globals, currently NVGT does not support instanciating multiple miniaudio contexts and NVGT provides a global sound engine.
static ma_context g_sound_context;
audio_engine *g_audio_engine = nullptr;
static std::atomic_flag g_soundsystem_initialized;
static std::atomic<ma_result> g_soundsystem_last_error = MA_SUCCESS;
static std::unique_ptr<sound_service> g_sound_service;
// These slots are what you use to refer to protocols (which are data sources like archives) and filters (which are transformations like encryption) after they've been plugged into the sound service.
static size_t g_encryption_filter_slot = 0;
static size_t g_pack_protocol_slot = 0;
static size_t g_memory_protocol_slot = 0;
static std::vector<ma_decoding_backend_vtable *> g_decoders;
bool add_decoder(ma_decoding_backend_vtable *vtable)
{
	try
	{
		g_decoders.push_back(vtable);
		return true;
	}
	catch (std::exception &)
	{
		return false;
	}
}
bool init_sound()
{
	if (g_soundsystem_initialized.test())
		return true;
	if ((g_soundsystem_last_error = ma_context_init(nullptr, 0, nullptr, &g_sound_context)) != MA_SUCCESS)
		return false;
	g_sound_service = sound_service::make();
	if (g_sound_service == nullptr)
	{
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

// audio device enumeration, we'll just maintain a global list of available devices, vectors of ma_device_info structures for the c++ side and CScriptArrays of device names on the Angelscript side. It is important that the data in these arrays is index aligned.
static vector<ma_device_info> g_sound_input_devices, g_sound_output_devices;
static CScriptArray *g_sound_script_input_devices = nullptr, *g_sound_script_output_devices = nullptr;
ma_bool32 ma_device_enum_callback(ma_context * /*ctx*/, ma_device_type type, const ma_device_info *info, void * /*user*/)
{
	string devname;
	if (type == ma_device_type_playback)
	{
		g_sound_output_devices.push_back(*info);
		g_sound_script_output_devices->InsertLast(&(devname = info->name));
	}
	else if (type == ma_device_type_capture)
	{
		g_sound_input_devices.push_back(*info);
		g_sound_script_input_devices->InsertLast(&(devname = info->name));
	}
	return MA_TRUE;
}
bool refresh_audio_devices()
{
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
CScriptArray *get_sound_input_devices()
{
	if (!init_sound())
		return CScriptArray::Create(get_array_type("array<string>")); // Better to return an emptry array instead of null for now.
	return g_sound_script_input_devices;
}
CScriptArray *get_sound_output_devices()
{
	if (!init_sound())
		return CScriptArray::Create(get_array_type("array<string>"));
	return g_sound_script_output_devices;
}

reactphysics3d::Vector3 ma_vec3_to_rp_vec3(const ma_vec3f &v) { return reactphysics3d::Vector3(v.x, v.y, v.z); }

// BGT seems to have used db for it's pan, we need to emulate that if the user chooses to enable backward compatibility options.
float pan_linear_to_db(float linear)
{
	linear = clamp(linear, -1.0f, 1.0f);
	float db = ma_volume_linear_to_db(linear > 0 ? 1.0f - linear : linear + 1.0f);
	return linear > 0 ? db * -1.0f : db;
}
float pan_db_to_linear(float db)
{
	db = clamp(db, -100.0f, 100.0f);
	float l = ma_volume_db_to_linear(fabs(db) * -1.0f);
	return db > 0 ? 1.0f - l : -1.0f + l;
}
// Callbacks for MiniAudio to write raw PCM to wav in memory.
ma_result wav_write_proc(ma_encoder *pEncoder, const void *pBufferIn, size_t bytesToWrite, size_t *pBytesWritten)
{
	std::ostream *stream = static_cast<std::ostream *>(pEncoder->pUserData);
	stream->write((const char *)pBufferIn, bytesToWrite);
	*pBytesWritten = bytesToWrite;
	return MA_SUCCESS;
}
ma_result wav_seek_proc(ma_encoder *pEncoder, ma_int64 offset, ma_seek_origin origin)
{
	if (origin != ma_seek_origin_start)
	{
		return MA_NOT_IMPLEMENTED;
	}
	std::ostream *stream = static_cast<std::ostream *>(pEncoder->pUserData);
	stream->seekp(offset);
	if (!stream->good())
	{
		return MA_ERROR;
	}
	return MA_SUCCESS;
}

// Miniaudio objects must be allocated on the heap as nvgt's API introduces the concept of an uninitialized sound, which a stack based system would make more difficult to implement.
class audio_node_impl : public virtual audio_node
{
	unique_ptr<ma_node_base> node;
	audio_engine *engine;
	int refcount;

public:
	audio_node_impl() : audio_node(), node(nullptr), refcount(1) {}
	audio_node_impl(ma_node_base *node, audio_engine *engine) : audio_node(), node(node), engine(engine), refcount(1) {}
	void duplicate() { asAtomicInc(refcount); }
	void release()
	{
		if (asAtomicDec(refcount) < 1)
			delete this;
	}
	audio_engine *get_engine() const { return engine; }
	ma_node_base *get_ma_node() { return &*node; }
	unsigned int get_input_bus_count() { return node ? ma_node_get_input_bus_count(&*node) : 0; }
	unsigned int get_output_bus_count() { return node ? ma_node_get_output_bus_count(&*node) : 0; }
	unsigned int get_input_channels(unsigned int bus) { return node ? ma_node_get_input_channels(&*node, bus) : 0; }
	unsigned int get_output_channels(unsigned int bus) { return node ? ma_node_get_output_channels(&*node, bus) : 0; }
	bool attach_output_bus(unsigned int output_bus, audio_node *destination, unsigned int destination_input_bus) { return node ? (g_soundsystem_last_error = ma_node_attach_output_bus(&*node, output_bus, destination, destination_input_bus)) == MA_SUCCESS : false; }
	bool detach_output_bus(unsigned int bus) { return node ? (g_soundsystem_last_error = ma_node_detach_output_bus(&*node, bus)) == MA_SUCCESS : false; }
	bool detach_all_output_buses() { return node ? (g_soundsystem_last_error = ma_node_detach_all_output_buses(&*node)) == MA_SUCCESS : false; }
	bool set_output_bus_volume(unsigned int bus, float volume) { return node ? (g_soundsystem_last_error = ma_node_set_output_bus_volume(&*node, bus, volume)) == MA_SUCCESS : false; }
	float get_output_bus_volume(unsigned int bus) { return node ? ma_node_get_output_bus_volume(&*node, bus) : 0; }
	bool set_state(ma_node_state state) { return node ? (g_soundsystem_last_error = ma_node_set_state(&*node, state)) == MA_SUCCESS : false; }
	ma_node_state get_state() { return node ? ma_node_get_state(&*node) : ma_node_state_stopped; }
	bool set_state_time(ma_node_state state, unsigned long long time) { return node ? (g_soundsystem_last_error = ma_node_set_state_time(&*node, state, time)) == MA_SUCCESS : false; }
	unsigned long long get_state_time(ma_node_state state) { return node ? ma_node_get_state_time(&*node, state) : static_cast<unsigned long long>(ma_node_state_stopped); }
	ma_node_state get_state_by_time(unsigned long long global_time) { return node ? ma_node_get_state_by_time(&*node, global_time) : ma_node_state_stopped; }
	ma_node_state get_state_by_time_range(unsigned long long global_time_begin, unsigned long long global_time_end) { return node ? ma_node_get_state_by_time_range(&*node, global_time_begin, global_time_end) : ma_node_state_stopped; }
	unsigned long long get_time() { return node ? ma_node_get_time(&*node) : 0; }
	bool set_time(unsigned long long local_time) { return node ? (g_soundsystem_last_error = ma_node_set_time(&*node, local_time)) == MA_SUCCESS : false; }
};
class audio_engine_impl final : public audio_engine
{
	std::unique_ptr<ma_engine> engine;
	std::unique_ptr<ma_resource_manager> resource_manager;
	audio_node *engine_endpoint; // Upon engine creation we'll call ma_engine_get_endpoint once so as to avoid creating more than one of our wrapper objects when our engine->get_endpoint() function is called.
	int refcount;

public:
	engine_flags flags;
	audio_engine_impl(int flags)
		: audio_engine(),
		  engine(nullptr),
		  resource_manager(nullptr),
		  engine_endpoint(nullptr),
		  flags(static_cast<engine_flags>(flags)),
		  refcount(1)
	{
		// We need a self managed resource manager because we need to plug decoders in.
		{
			ma_resource_manager_config cfg = ma_resource_manager_config_init();
			// Attach the resource manager to the sound service so that it can receive audio from custom sources.
			cfg.pVFS = g_sound_service->get_vfs();
			// Set a static decoded sample rate for now. We probably want to make this configurable.
			cfg.decodedSampleRate = 44100;

			cfg.resampling.algorithm = ma_resample_algorithm_custom;
			cfg.resampling.pBackendVTable = &wdl_resampler_backend_vtable;
			if (!g_decoders.empty())
			{
				cfg.ppCustomDecodingBackendVTables = &g_decoders[0];
				cfg.customDecodingBackendCount = g_decoders.size();
			}
			resource_manager = std::make_unique<ma_resource_manager>();
			if ((g_soundsystem_last_error = ma_resource_manager_init(&cfg, &*resource_manager)) != MA_SUCCESS)
			{
				resource_manager.reset();
				return;
			}
		}
		ma_engine_config cfg = ma_engine_config_init();
		// cfg.pContext = &g_sound_context; // Miniaudio won't let us quickly uninitilize then reinitialize a device sometimes when using the same context, so we won't manage it until we figure that out.
		cfg.pResourceManager = &*resource_manager;
		engine = std::make_unique<ma_engine>();
		if ((g_soundsystem_last_error = ma_engine_init(&cfg, &*engine)) != MA_SUCCESS)
		{
			engine.reset();
			return;
		}
		engine_endpoint = new audio_node_impl(reinterpret_cast<ma_node_base *>(ma_engine_get_endpoint(&*engine)), this);
	}
	~audio_engine_impl()
	{

		if (engine_endpoint)
			engine_endpoint->release();
		if (engine)
		{
			ma_engine_uninit(&*engine);
			engine = nullptr;
		}
	}
	void duplicate() override { asAtomicInc(refcount); }
	void release() override
	{

		if (asAtomicDec(refcount) < 1)
			delete this;
	}
	ma_engine *get_ma_engine() override { return engine.get(); }
	audio_node *get_endpoint() override { return engine_endpoint; } // Implement after audio_node
	int get_device() override
	{
		if (!engine)
			return -1;
		ma_device *dev = ma_engine_get_device(&*engine);
		ma_device_info info;
		if (!dev || ma_device_get_info(dev, ma_device_type_playback, &info) != MA_SUCCESS)
			return -1;
		for (std::size_t i = 0; i < g_sound_output_devices.size(); i++)
		{
			if (memcmp(&g_sound_output_devices[i].id, &info.id, sizeof(ma_device_id)) == 0)
				return i;
		}
		return -1; // couldn't determine device?
	}
	bool set_device(int device) override
	{
		if (!engine || device < 0 || device >= g_sound_output_devices.size())
			return false;
		ma_device *old_dev = ma_engine_get_device(&*engine);
		if (!old_dev || ma_device_id_equal(&old_dev->playback.id, &g_sound_output_devices[device].id))
			return false;
		ma_engine_stop(&*engine);
		ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
		cfg.playback.pDeviceID = &g_sound_output_devices[device].id;
		cfg.playback.channels = old_dev->playback.channels;
		cfg.sampleRate = old_dev->sampleRate;
		cfg.noPreSilencedOutputBuffer = old_dev->noPreSilencedOutputBuffer;
		cfg.noClip = old_dev->noClip;
		cfg.noDisableDenormals = old_dev->noDisableDenormals;
		cfg.noFixedSizedCallback = old_dev->noFixedSizedCallback;
		cfg.notificationCallback = old_dev->onNotification;
		cfg.dataCallback = old_dev->onData;
		cfg.pUserData = old_dev->pUserData;
		ma_device_stop(old_dev);
		ma_device_uninit(old_dev);
		if ((g_soundsystem_last_error = ma_device_init(nullptr, &cfg, old_dev)) != MA_SUCCESS)
			return false;
		return (g_soundsystem_last_error = ma_engine_start(&*engine)) == MA_SUCCESS;
	}
	bool read(void *buffer, unsigned long long frame_count, unsigned long long *frames_read) override { return engine ? (g_soundsystem_last_error = ma_engine_read_pcm_frames(&*engine, buffer, frame_count, frames_read)) == MA_SUCCESS : false; }
	CScriptArray *read(unsigned long long frame_count) override
	{
		if (!engine)
			return nullptr;
		CScriptArray *result = CScriptArray::Create(get_array_type("array<float>"), frame_count * ma_engine_get_channels(&*engine));
		unsigned long long frames_read;
		if (!read(result->GetBuffer(), frame_count, &frames_read))
		{
			result->Resize(0);
			return result;
		}
		result->Resize(frames_read * ma_engine_get_channels(&*engine));
		return result;
	}
	unsigned long long get_time() override { return engine ? (flags & DURATIONS_IN_FRAMES ? get_time_in_frames() : get_time_in_milliseconds()) : 0; }
	bool set_time(unsigned long long time) override { return engine ? (flags & DURATIONS_IN_FRAMES) ? set_time_in_frames(time) : set_time_in_milliseconds(time) : false; }
	unsigned long long get_time_in_frames() override { return engine ? ma_engine_get_time_in_pcm_frames(&*engine) : 0; }
	bool set_time_in_frames(unsigned long long time) override { return engine ? (g_soundsystem_last_error = ma_engine_set_time_in_pcm_frames(&*engine, time)) == MA_SUCCESS : false; }
	unsigned long long get_time_in_milliseconds() override { return engine ? ma_engine_get_time_in_milliseconds(&*engine) : 0; }
	bool set_time_in_milliseconds(unsigned long long time) override { return engine ? (g_soundsystem_last_error = ma_engine_set_time_in_milliseconds(&*engine, time)) == MA_SUCCESS : false; }
	int get_channels() override { return engine ? ma_engine_get_channels(&*engine) : 0; }
	int get_sample_rate() override { return engine ? ma_engine_get_sample_rate(&*engine) : 0; }
	bool start() override { return engine ? (ma_engine_start(&*engine)) == MA_SUCCESS : false; }
	bool stop() override { return engine ? (ma_engine_stop(&*engine)) == MA_SUCCESS : false; }
	bool set_volume(float volume) override { return engine ? (g_soundsystem_last_error = ma_engine_set_volume(&*engine, volume)) == MA_SUCCESS : false; }
	float get_volume() override { return engine ? ma_engine_get_volume(&*engine) : 0; }
	bool set_gain(float db) override { return engine ? (g_soundsystem_last_error = ma_engine_set_gain_db(&*engine, db)) == MA_SUCCESS : false; }
	float get_gain() override { return engine ? ma_engine_get_gain_db(&*engine) : 0; }
	unsigned int get_listener_count() override { return engine ? ma_engine_get_listener_count(&*engine) : 0; }
	int find_closest_listener(float x, float y, float z) override { return engine ? ma_engine_find_closest_listener(&*engine, x, y, z) : -1; }
	int find_closest_listener(const reactphysics3d::Vector3 &position) override { return engine ? ma_engine_find_closest_listener(&*engine, position.x, position.y, position.z) : -1; }
	void set_listener_position(unsigned int index, float x, float y, float z) override
	{
		if (engine)
			ma_engine_listener_set_position(&*engine, index, x, y, z);
	}
	void set_listener_position(unsigned int index, const reactphysics3d::Vector3 &position) override
	{
		if (engine)
			ma_engine_listener_set_position(&*engine, index, position.x, position.y, position.z);
	}
	reactphysics3d::Vector3 get_listener_position(unsigned int index) override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_position(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_direction(unsigned int index, float x, float y, float z) override
	{
		if (engine)
			ma_engine_listener_set_direction(&*engine, index, x, y, z);
	}
	void set_listener_direction(unsigned int index, const reactphysics3d::Vector3 &direction) override
	{
		if (engine)
			ma_engine_listener_set_direction(&*engine, index, direction.x, direction.y, direction.z);
	}
	reactphysics3d::Vector3 get_listener_direction(unsigned int index) override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_direction(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_velocity(unsigned int index, float x, float y, float z) override
	{
		if (engine)
			ma_engine_listener_set_velocity(&*engine, index, x, y, z);
	}
	void set_listener_velocity(unsigned int index, const reactphysics3d::Vector3 &velocity) override
	{
		if (engine)
			ma_engine_listener_set_velocity(&*engine, index, velocity.x, velocity.y, velocity.z);
	}
	reactphysics3d::Vector3 get_listener_velocity(unsigned int index) override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_velocity(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_cone(unsigned int index, float inner_radians, float outer_radians, float outer_gain) override
	{
		if (engine)
			ma_engine_listener_set_cone(&*engine, index, inner_radians, outer_radians, outer_gain);
	}
	void get_listener_cone(unsigned int index, float *inner_radians, float *outer_radians, float *outer_gain) override
	{
		if (engine)
			ma_engine_listener_get_cone(&*engine, index, inner_radians, outer_radians, outer_gain);
	}
	void set_listener_world_up(unsigned int index, float x, float y, float z) override
	{
		if (engine)
			ma_engine_listener_set_world_up(&*engine, index, x, y, z);
	}
	void set_listener_world_up(unsigned int index, const reactphysics3d::Vector3 &world_up) override
	{
		if (engine)
			ma_engine_listener_set_world_up(&*engine, index, world_up.x, world_up.y, world_up.z);
	}
	reactphysics3d::Vector3 get_listener_world_up(unsigned int index) override { return engine ? ma_vec3_to_rp_vec3(ma_engine_listener_get_world_up(&*engine, index)) : reactphysics3d::Vector3(); }
	void set_listener_enabled(unsigned int index, bool enabled) override
	{
		if (engine)
			ma_engine_listener_set_enabled(&*engine, index, enabled);
	}
	bool get_listener_enabled(unsigned int index) override { return ma_engine_listener_is_enabled(&*engine, index); }
	bool play(const string &filename, audio_node *node, unsigned int bus_index) override { return engine ? (g_soundsystem_last_error = ma_engine_play_sound_ex(&*engine, filename.c_str(), node ? node->get_ma_node() : nullptr, bus_index)) == MA_SUCCESS : false; }
	bool play(const string &filename, mixer *mixer) override { return engine ? (ma_engine_play_sound(&*engine, filename.c_str(), mixer ? mixer->get_ma_sound() : nullptr)) == MA_SUCCESS : false; }
	mixer *new_mixer() override { return ::new_mixer(this); }
	sound *new_sound() override { return ::new_sound(this); }
};
class mixer_impl : public audio_node_impl, public virtual mixer
{
	// In miniaudio, a sound_group is really just a sound. A typical ma_sound_group_x function looks like float ma_sound_group_get_pan(const ma_sound_group* pGroup) { return ma_sound_get_pan(pGroup); }.
	// Furthermore ma_sound_group is just a typedef for ma_sound. As such, for the sake of less code and better inheritance, we will directly call the ma_sound APIs in this class even though it deals with sound groups and not sounds.
protected:
	audio_engine_impl *engine;
	unique_ptr<ma_sound> snd;

public:
	mixer_impl() : mixer(), audio_node_impl(), snd(nullptr)
	{
		init_sound();
		engine = static_cast<audio_engine_impl *>(g_audio_engine);
	}
	mixer_impl(audio_engine *engine) : mixer(), audio_node_impl(), engine(static_cast<audio_engine_impl *>(engine)), snd(nullptr) {}
	inline void duplicate() override { audio_node_impl::duplicate(); }
	inline void release() override { audio_node_impl::release(); }
	bool play() override
	{
		if (snd == nullptr)
			return false;
		ma_sound_set_looping(&*snd, false);
		return ma_sound_start(&*snd) == MA_SUCCESS;
	}
	bool play_looped()
	{
		if (snd == nullptr)
			return false;
		ma_sound_set_looping(&*snd, true);
		return ma_sound_start(&*snd) == MA_SUCCESS;
	}
	ma_sound *get_ma_sound() override { return &*snd; }
	audio_engine *get_engine() override
	{
		return engine;
	}
	bool stop() override { return snd ? ma_sound_stop(&*snd) : false; }
	void set_volume(float volume) override
	{
		if (snd)
			ma_sound_set_volume(&*snd, engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_volume_db_to_linear(volume) : volume);
	}
	float get_volume() override { return snd ? (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_volume_linear_to_db(ma_sound_get_volume(&*snd)) : ma_sound_get_volume(&*snd)) : NAN; }
	void set_pan(float pan) override
	{
		if (snd)
			ma_sound_set_pan(&*snd, engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? pan_db_to_linear(pan) : pan);
	}
	float get_pan() override
	{
		return snd ? (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? pan_linear_to_db(ma_sound_get_pan(&*snd)) : ma_sound_get_pan(&*snd)) : NAN;
	}
	void set_pan_mode(ma_pan_mode mode) override
	{
		if (snd)
			ma_sound_set_pan_mode(&*snd, mode);
	}
	ma_pan_mode get_pan_mode() override
	{
		return snd ? ma_sound_get_pan_mode(&*snd) : ma_pan_mode_balance;
	}
	void set_pitch(float pitch) override
	{
		if (snd)
			ma_sound_set_pitch(&*snd, engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? pitch / 100.0f : pitch);
	}
	float get_pitch() override
	{
		return snd ? (engine->flags & audio_engine::PERCENTAGE_ATTRIBUTES ? ma_sound_get_pitch(&*snd) * 100 : ma_sound_get_pitch(&*snd)) : NAN;
	}
	void set_spatialization_enabled(bool enabled) override
	{
		if (snd)
			ma_sound_set_spatialization_enabled(&*snd, enabled);
	}
	bool get_spatialization_enabled() override
	{
		return snd ? ma_sound_is_spatialization_enabled(&*snd) : false;
	}
	void set_pinned_listener(unsigned int index) override
	{
		if (snd)
			ma_sound_set_pinned_listener_index(&*snd, index);
	}
	unsigned int get_pinned_listener() override
	{
		return snd ? ma_sound_get_pinned_listener_index(&*snd) : 0;
	}
	unsigned int get_listener() override
	{
		return snd ? ma_sound_get_listener_index(&*snd) : 0;
	}
	reactphysics3d::Vector3 get_direction_to_listener() override
	{
		if (!snd)
			return reactphysics3d::Vector3();
		const auto dir = ma_sound_get_direction_to_listener(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(dir.x, dir.y, dir.z);
		return res;
	}
	void set_position_3d(float x, float y, float z) override
	{
		if (!snd)
			return;
		return ma_sound_set_position(&*snd, x, y, z);
	}
	reactphysics3d::Vector3 get_position_3d() override
	{
		if (!snd)
			return reactphysics3d::Vector3();
		const auto pos = ma_sound_get_position(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(pos.x, pos.y, pos.z);
		return res;
	}
	void set_direction(float x, float y, float z) override
	{
		if (!snd)
			return;
		return ma_sound_set_direction(&*snd, x, y, z);
	}
	reactphysics3d::Vector3 get_direction() override
	{
		if (!snd)
			return reactphysics3d::Vector3();
		const auto dir = ma_sound_get_direction(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(dir.x, dir.y, dir.z);
		return res;
	}
	void set_velocity(float x, float y, float z) override
	{
		if (!snd)
			return;
		return ma_sound_set_velocity(&*snd, x, y, z);
	}
	reactphysics3d::Vector3 get_velocity() override
	{
		if (!snd)
			return reactphysics3d::Vector3();
		const auto vel = ma_sound_get_velocity(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(vel.x, vel.y, vel.z);
		return res;
	}
	void set_attenuation_model(ma_attenuation_model model) override
	{
		if (snd)
			ma_sound_set_attenuation_model(&*snd, model);
	}
	ma_attenuation_model get_attenuation_model() override
	{
		return snd ? ma_sound_get_attenuation_model(&*snd) : ma_attenuation_model_none;
	}
	void set_positioning(ma_positioning positioning) override
	{
		if (snd)
			ma_sound_set_positioning(&*snd, positioning);
	}
	ma_positioning get_positioning() override
	{
		return snd ? ma_sound_get_positioning(&*snd) : ma_positioning_absolute;
	}
	void set_rolloff(float rolloff) override
	{
		if (snd)
			ma_sound_set_rolloff(&*snd, rolloff);
	}
	float get_rolloff() override
	{
		return snd ? ma_sound_get_rolloff(&*snd) : NAN;
	}
	void set_min_gain(float gain) override
	{
		if (snd)
			ma_sound_set_min_gain(&*snd, gain);
	}
	float get_min_gain() override
	{
		return snd ? ma_sound_get_min_gain(&*snd) : NAN;
	}
	void set_max_gain(float gain) override
	{
		if (snd)
			ma_sound_set_max_gain(&*snd, gain);
	}
	float get_max_gain() override
	{
		return snd ? ma_sound_get_max_gain(&*snd) : NAN;
	}
	void set_min_distance(float distance) override
	{
		if (snd)
			ma_sound_set_min_distance(&*snd, distance);
	}
	float get_min_distance() override
	{
		return snd ? ma_sound_get_min_distance(&*snd) : NAN;
	}
	void set_max_distance(float distance) override
	{
		if (snd)
			ma_sound_set_max_distance(&*snd, distance);
	}
	float get_max_distance() override
	{
		return snd ? ma_sound_get_max_distance(&*snd) : NAN;
	}
	void set_cone(float inner_radians, float outer_radians, float outer_gain) override
	{
		if (snd)
			ma_sound_set_cone(&*snd, inner_radians, outer_radians, outer_gain);
	}
	void get_cone(float *inner_radians, float *outer_radians, float *outer_gain) override
	{
		if (snd)
			ma_sound_get_cone(&*snd, inner_radians, outer_radians, outer_gain);
		else
		{
			if (inner_radians)
				*inner_radians = NAN;
			if (outer_radians)
				*outer_radians = NAN;
			if (outer_gain)
				*outer_gain = NAN;
		}
	}
	void set_doppler_factor(float factor) override
	{
		if (snd)
			ma_sound_set_doppler_factor(&*snd, factor);
	}
	float get_doppler_factor() override
	{
		return snd ? ma_sound_get_doppler_factor(&*snd) : NAN;
	}
	void set_directional_attenuation_factor(float factor) override
	{
		if (snd)
			ma_sound_set_directional_attenuation_factor(&*snd, factor);
	}
	float get_directional_attenuation_factor() override
	{
		return snd ? ma_sound_get_directional_attenuation_factor(&*snd) : NAN;
	}
	void set_fade(float start_volume, float end_volume, ma_uint64 length) override
	{
		if (!snd)
			return;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			set_fade_in_frames(start_volume, end_volume, length);
		else
			set_fade_in_milliseconds(start_volume, end_volume, length);
	}
	void set_fade_in_frames(float start_volume, float end_volume, ma_uint64 frames) override
	{
		if (snd)
			ma_sound_set_fade_in_pcm_frames(&*snd, start_volume, end_volume, frames);
	}
	void set_fade_in_milliseconds(float start_volume, float end_volume, ma_uint64 milliseconds) override
	{
		if (snd)
			ma_sound_set_fade_in_milliseconds(&*snd, start_volume, end_volume, milliseconds);
	}
	float get_current_fade_volume() override
	{
		return snd ? ma_sound_get_current_fade_volume(&*snd) : NAN;
	}
	void set_start_time(ma_uint64 absolute_time) override
	{
		if (!snd)
			return;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			set_start_time_in_frames(absolute_time);
		else
			set_start_time_in_milliseconds(absolute_time);
	}
	void set_start_time_in_frames(ma_uint64 absolute_time) override
	{
		if (snd)
			ma_sound_set_start_time_in_pcm_frames(&*snd, absolute_time);
	}
	void set_start_time_in_milliseconds(ma_uint64 absolute_time) override
	{
		if (snd)
			ma_sound_set_start_time_in_milliseconds(&*snd, absolute_time);
	}
	void set_stop_time(ma_uint64 absolute_time) override
	{
		if (!snd)
			return;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			set_stop_time_in_frames(absolute_time);
		else
			set_stop_time_in_milliseconds(absolute_time);
	}
	void set_stop_time_in_frames(ma_uint64 absolute_time) override
	{
		if (snd)
			ma_sound_set_stop_time_in_pcm_frames(&*snd, absolute_time);
	}
	void set_stop_time_in_milliseconds(ma_uint64 absolute_time) override
	{
		if (snd)
			ma_sound_set_stop_time_in_milliseconds(&*snd, absolute_time);
	}
	ma_uint64 get_time() override
	{
		return snd ? ((engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? get_time_in_frames() : get_time_in_milliseconds()) : 0;
	}
	ma_uint64 get_time_in_frames() override
	{
		return snd ? ma_sound_get_time_in_pcm_frames(&*snd) : 0;
	}
	ma_uint64 get_time_in_milliseconds() override
	{
		return snd ? ma_sound_get_time_in_milliseconds(&*snd) : 0ULL;
	}
	bool get_playing() override
	{
		return snd ? ma_sound_is_playing(&*snd) : false;
	}
};
class sound_impl final : public mixer_impl, public virtual sound
{
	std::vector<char> pcm_buffer; // When loading from raw PCM (like TTS) we store the intermediate wav data here so we can take advantage of async loading to return quickly. Makes a substantial difference in the responsiveness of TTS calls.
	// Always called before associating the object with a new sound.
	void reset()
	{
		if (!snd)
			snd = make_unique<ma_sound>();
		else
			ma_sound_uninit(&*snd);
		pcm_buffer.resize(0);
	}

public:
	sound_impl(audio_engine *e) : mixer_impl(static_cast<audio_engine_impl *>(e)), pcm_buffer(), sound()
	{
		snd = nullptr;
	}
	~sound_impl()
	{
		close();
	}
	bool load_special(const std::string &filename, const size_t protocol_slot = 0, directive_t protocol_directive = nullptr, const size_t filter_slot = 0, directive_t filter_directive = nullptr, ma_uint32 ma_flags = MA_SOUND_FLAG_DECODE) override
	{
		reset();
		// The sound service converts our file name into a "tripplet" which includes information about the origin an asset is expected to come from. This guarantees that we don't mistake assets from different origins as the same just because they have the same name.
		std::string triplet = g_sound_service->prepare_triplet(filename, protocol_slot, protocol_directive, filter_slot, filter_directive);
		if (triplet.empty())
		{
			return false;
		}

		g_soundsystem_last_error = ma_sound_init_from_file(engine->get_ma_engine(), triplet.c_str(), ma_flags, nullptr, nullptr, &*snd);

		if (g_soundsystem_last_error != MA_SUCCESS)
			snd.reset();
		return g_soundsystem_last_error == MA_SUCCESS;
	}
	bool load(const string &filename) override
	{
		return load_special(filename, 0, nullptr, 0, nullptr, MA_SOUND_FLAG_DECODE);
	}
	bool stream(const std::string &filename) override
	{
		return load_special(filename, 0, nullptr, 0, nullptr, MA_SOUND_FLAG_STREAM);
	}
	bool seek_in_milliseconds(unsigned long long offset) override { return snd ? (g_soundsystem_last_error = ma_sound_seek_to_pcm_frame(&*snd, offset * ma_engine_get_sample_rate(engine->get_ma_engine()) / 1000)) == MA_SUCCESS : false; }
	bool load_string(const std::string &data) override { return load_memory(data.data(), data.size()); }
	bool load_memory(const void *buffer, unsigned int size) override
	{
		return load_special("::memory", g_memory_protocol_slot, memory_protocol::directive(buffer, size));
	}
	bool load_pcm(void *buffer, unsigned int size, ma_format format, int samplerate, int channels) override
	{
		reset();
		// At least for now, the strat here is just to write the PCM to wav and then load it the normal way.
		// Should optimization become necessary (this does result in a couple of copies), a protocol could be written that simulates its input having a RIFF header on it.
		int frame_size = 0;
		switch (format)
		{
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
		default:
			return false;
		}
		frame_size /= channels;
		pcm_buffer.resize(size + 44);
		Poco::MemoryOutputStream stream(&pcm_buffer[0], pcm_buffer.size());
		ma_encoder_config cfg = ma_encoder_config_init(ma_encoding_format_wav, format, channels, samplerate);
		ma_encoder encoder;
		g_soundsystem_last_error = ma_encoder_init(wav_write_proc, wav_seek_proc, &stream, &cfg, &encoder);
		if (g_soundsystem_last_error != MA_SUCCESS)
		{
			return false;
		}
		// Should be okay to push the content in one go:
		ma_uint64 frames_written;
		g_soundsystem_last_error = ma_encoder_write_pcm_frames(&encoder, buffer, size / frame_size, &frames_written);
		ma_encoder_uninit(&encoder);
		if (g_soundsystem_last_error != MA_SUCCESS)
		{
			return false;
		}
		// At this point we can just use the sound service to load this. We use the low level API though because we need to be clear that no filters apply.
		// Also, our PCM buffer is a permanent class property so we can enjoy the speed of async loading.
		return load_special(":pcm", g_memory_protocol_slot, memory_protocol::directive(&pcm_buffer[0], pcm_buffer.size()), sound_service::null_filter_slot, nullptr, MA_SOUND_FLAG_DECODE | MA_SOUND_FLAG_ASYNC);
	}
	bool close() override
	{
		if (snd)
		{
			ma_sound_uninit(&*snd);
			snd.reset();
			return true;
		}
		return false;
	}
	bool get_active() override
	{
		return snd ? true : false;
	}
	bool get_paused() override
	{
		return snd ? ma_sound_is_playing(&*snd) : false;
	}
	bool pause() override
	{
		if (snd)
		{
			g_soundsystem_last_error = ma_sound_stop(&*snd);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	bool pause_fade(unsigned long long length) override
	{
		return (engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? pause_fade_in_frames(length) : pause_fade_in_milliseconds(length);
	}
	bool pause_fade_in_frames(unsigned long long frames) override
	{
		if (snd)
		{
			g_soundsystem_last_error = ma_sound_stop_with_fade_in_pcm_frames(&*snd, frames);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	bool pause_fade_in_milliseconds(unsigned long long frames) override
	{
		if (snd)
		{
			g_soundsystem_last_error = ma_sound_stop_with_fade_in_milliseconds(&*snd, frames);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	void set_timed_fade(float start_volume, float end_volume, unsigned long long length, unsigned long long absolute_time) override
	{
		return (engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? set_timed_fade_in_frames(start_volume, end_volume, length, absolute_time) : set_timed_fade_in_milliseconds(start_volume, end_volume, length, absolute_time);
	}
	void set_timed_fade_in_frames(float start_volume, float end_volume, unsigned long long frames, unsigned long long absolute_time_in_frames) override
	{
		if (snd)
			ma_sound_set_fade_start_in_pcm_frames(&*snd, start_volume, end_volume, frames, absolute_time_in_frames);
	}
	void set_timed_fade_in_milliseconds(float start_volume, float end_volume, unsigned long long frames, unsigned long long absolute_time_in_frames) override
	{
		if (snd)
			ma_sound_set_fade_start_in_milliseconds(&*snd, start_volume, end_volume, frames, absolute_time_in_frames);
	}
	void set_stop_time_with_fade(unsigned long long absolute_time, unsigned long long fade_length) override
	{
		return (engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? set_stop_time_with_fade_in_frames(absolute_time, fade_length) : set_stop_time_with_fade_in_milliseconds(absolute_time, fade_length);
	}
	void set_stop_time_with_fade_in_frames(unsigned long long absolute_time, unsigned long long fade_length) override
	{
		if (snd)
			ma_sound_set_stop_time_with_fade_in_pcm_frames(&*snd, absolute_time, fade_length);
	}
	void set_stop_time_with_fade_in_milliseconds(unsigned long long absolute_time, unsigned long long fade_length) override
	{
		if (snd)
			ma_sound_set_stop_time_with_fade_in_milliseconds(&*snd, absolute_time, fade_length);
	}
	void set_looping(bool looping) override
	{
		if (snd)
			ma_sound_set_looping(&*snd, looping);
	}
	bool get_looping() override
	{
		return snd ? ma_sound_is_looping(&*snd) : false;
	}
	bool get_at_end() override
	{
		return snd ? ma_sound_at_end(&*snd) : false;
	}
	bool seek(unsigned long long position) override
	{
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			return seek_in_frames(position);
		else
			return seek_in_milliseconds(position);
	}
	bool seek_in_frames(unsigned long long position) override
	{
		if (snd)
		{
			g_soundsystem_last_error = ma_sound_seek_to_pcm_frame(&*snd, position);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	unsigned long long get_position() override
	{
		if (!snd)
			return 0;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			return get_position_in_frames();
		else
			return get_position_in_milliseconds();
	}
	unsigned long long get_position_in_frames() override
	{
		if (snd)
		{
			ma_uint64 pos = 0;
			g_soundsystem_last_error = ma_sound_get_cursor_in_pcm_frames(&*snd, &pos);
			return g_soundsystem_last_error == MA_SUCCESS ? pos : 0;
		}
		return 0;
	}
	unsigned long long get_position_in_milliseconds() override
	{
		if (snd)
		{
			float pos = 0.0f;
			g_soundsystem_last_error = ma_sound_get_cursor_in_seconds(&*snd, &pos);
			return g_soundsystem_last_error == MA_SUCCESS ? pos * 1000.0f : 0;
		}
		return 0;
	}
	unsigned long long get_length() override
	{
		if (!snd)
			return 0;
		if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
			return get_length_in_frames();
		else
			return get_length_in_milliseconds();
	}
	unsigned long long get_length_in_frames() override
	{
		if (snd)
		{
			ma_uint64 len;
			g_soundsystem_last_error = ma_sound_get_length_in_pcm_frames(&*snd, &len);
			return g_soundsystem_last_error == MA_SUCCESS ? len : 0;
		}
		return 0;
	}
	unsigned long long get_length_in_milliseconds() override
	{
		if (snd)
		{
			float len;
			g_soundsystem_last_error = ma_sound_get_length_in_seconds(&*snd, &len);
			return g_soundsystem_last_error == MA_SUCCESS ? len * 1000.0f : 0;
		}
		return 0;
	}
	bool get_data_format(ma_format *format, unsigned int *channels, unsigned int *sample_rate) override
	{
		if (snd)
		{
			g_soundsystem_last_error = ma_sound_get_data_format(&*snd, format, channels, sample_rate, nullptr, 0);
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		return false;
	}
	// A completely pointless API here, but needed for code that relies on legacy BGT includes. Always returns 0.
	double get_pitch_lower_limit() override
	{
		return 0;
	}
};

audio_engine *new_audio_engine(int flags) { return new audio_engine_impl(flags); }
mixer *new_mixer(audio_engine *engine) { return new mixer_impl(engine); }
sound *new_sound(audio_engine *engine) { return new sound_impl(engine); }
mixer *new_global_mixer()
{
	init_sound();
	return new mixer_impl(g_audio_engine);
}
sound *new_global_sound()
{
	init_sound();
	return new sound_impl(g_audio_engine);
}
int get_sound_output_device()
{
	init_sound();
	return g_audio_engine->get_device();
}
void set_sound_output_device(int device)
{
	init_sound();
	g_audio_engine->set_device(device);
}
// Encryption.
void set_default_decryption_key(const std::string &key)
{
	if (!init_sound())
		return;
	g_sound_service->set_filter_directive(g_encryption_filter_slot, std::make_shared<std::string>(key));
	g_sound_service->set_default_filter(key.empty() ? sound_service::null_filter_slot : g_encryption_filter_slot);
}
// Set default pack storage for future sounds. Null means go back to local file system.
// Note: a pack must be marked immutable in order to be used with sound service.
void set_sound_default_storage(new_pack::pack *obj)
{
	if (!init_sound())
	{
		return;
	}
	if (obj == nullptr)
	{
		g_sound_service->set_default_protocol(sound_service::fs_protocol_slot);
		return;
	}
	g_sound_service->set_protocol_directive(g_pack_protocol_slot, obj->to_shared());
	g_sound_service->set_default_protocol(g_pack_protocol_slot);
}
int get_soundsystem_last_error() { return g_soundsystem_last_error; }

template <class T, auto Function, typename ReturnType, typename... Args>
ReturnType virtual_call(T *object, Args... args)
{
	return (object->*Function)(std::forward<Args>(args)...);
}
template <class T>
void RegisterSoundsystemAudioNode(asIScriptEngine *engine, const string &type)
{
	engine->RegisterObjectType(type.c_str(), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_ADDREF, "void f()", asFUNCTION((virtual_call<T, &T::duplicate, void>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_RELEASE, "void f()", asFUNCTION((virtual_call<T, &T::release, void>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_input_bus_count() const property", asFUNCTION((virtual_call<T, &T::get_input_bus_count, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_output_bus_count() const property", asFUNCTION((virtual_call<T, &T::get_output_bus_count, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_input_channels(uint bus) const", asFUNCTION((virtual_call<T, &T::get_input_channels, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_output_channels(uint bus) const", asFUNCTION((virtual_call<T, &T::get_output_channels, unsigned int, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool attach_output_bus(uint output_bus, audio_node@ destination, uint destination_input_bus)", asFUNCTION((virtual_call<T, &T::attach_output_bus, bool, unsigned int, audio_node *, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool detach_output_bus(uint bus)", asFUNCTION((virtual_call<T, &T::detach_output_bus, bool, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool detach_all_output_buses()", asFUNCTION((virtual_call<T, &T::detach_all_output_buses, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_output_bus_volume(uint bus, float volume)", asFUNCTION((virtual_call<T, &T::set_output_bus_volume, bool, unsigned int, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_output_bus_volume(uint bus)", asFUNCTION((virtual_call<T, &T::get_output_bus_volume, float, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_state(audio_node_state state)", asFUNCTION((virtual_call<T, &T::set_state, bool, ma_node_state>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_node_state get_state()", asFUNCTION((virtual_call<T, &T::get_state, ma_node_state>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_state_time(audio_node_state state, uint64 time)", asFUNCTION((virtual_call<T, &T::set_state_time, bool, ma_node_state, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint64 get_state_time(uint64 global_time)", asFUNCTION((virtual_call<T, &T::get_state_time, unsigned long long, ma_node_state>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_node_state get_state_by_time(uint64 global_time)", asFUNCTION((virtual_call<T, &T::get_state_by_time, ma_node_state, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_node_state get_state_by_time_range(uint64 global_time_begin, uint64 global_time_end)", asFUNCTION((virtual_call<T, &T::get_state_by_time_range, ma_node_state, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint64 get_time() const", asFUNCTION((virtual_call<T, &T::get_time, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool set_time(uint64 local_time)", asFUNCTION((virtual_call<T, &T::set_time, bool, ma_node_state>)), asCALL_CDECL_OBJFIRST);
}
template <class T>
void RegisterSoundsystemMixer(asIScriptEngine *engine, const string &type)
{
	RegisterSoundsystemAudioNode<T>(engine, type);
	engine->RegisterObjectMethod(type.c_str(), "bool play()", asFUNCTION((virtual_call<T, &T::play, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool play_looped()", asFUNCTION((virtual_call<T, &T::play_looped, bool>)), asCALL_CDECL_OBJFIRST);

	engine->RegisterObjectMethod(type.c_str(), "bool stop()", asFUNCTION((virtual_call<T, &T::stop, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_volume(float volume) property", asFUNCTION((virtual_call<T, &T::set_volume, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_volume() const property", asFUNCTION((virtual_call<T, &T::get_volume, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_pan(float pan) property", asFUNCTION((virtual_call<T, &T::set_pan, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_pan() const property", asFUNCTION((virtual_call<T, &T::get_pan, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_pan_mode(audio_pan_mode mode) property", asFUNCTION((virtual_call<T, &T::set_pan_mode, void, ma_pan_mode>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_pan_mode get_pan_mode() const property", asFUNCTION((virtual_call<T, &T::get_pan_mode, ma_pan_mode>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_pitch(float pitch) property", asFUNCTION((virtual_call<T, &T::set_pitch, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_pitch() const property", asFUNCTION((virtual_call<T, &T::get_pitch, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_spatialization_enabled(bool enabled) property", asFUNCTION((virtual_call<T, &T::set_spatialization_enabled, void, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_spatialization_enabled() const property", asFUNCTION((virtual_call<T, &T::get_spatialization_enabled, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_pinned_listener(uint index) property", asFUNCTION((virtual_call<T, &T::set_pinned_listener, void, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_pinned_listener() const property", asFUNCTION((virtual_call<T, &T::get_pinned_listener, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "uint get_listener() const property", asFUNCTION((virtual_call<T, &T::get_listener, unsigned int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "vector get_direction_to_listener() const", asFUNCTION((virtual_call<T, &T::get_direction_to_listener, reactphysics3d::Vector3>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_position_3d(float x, float y, float z)", asFUNCTION((virtual_call<T, &T::set_position_3d, void, float, float, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "vector get_position_3d() const", asFUNCTION((virtual_call<T, &T::get_position_3d, reactphysics3d::Vector3>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_direction(float x, float y, float z)", asFUNCTION((virtual_call<T, &T::set_direction, void, float, float, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "vector get_direction() const", asFUNCTION((virtual_call<T, &T::get_direction, reactphysics3d::Vector3>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_velocity(float x, float y, float z)", asFUNCTION((virtual_call<T, &T::set_velocity, void, float, float, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "vector get_velocity() const", asFUNCTION((virtual_call<T, &T::get_velocity, reactphysics3d::Vector3>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_attenuation_model(audio_attenuation_model model) property", asFUNCTION((virtual_call<T, &T::set_attenuation_model, void, ma_attenuation_model>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_attenuation_model get_attenuation_model() const property", asFUNCTION((virtual_call<T, &T::get_attenuation_model, ma_attenuation_model>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_positioning(audio_positioning_mode mode) property", asFUNCTION((virtual_call<T, &T::set_positioning, void, ma_positioning>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "audio_positioning_mode get_positioning() const property", asFUNCTION((virtual_call<T, &T::get_positioning, ma_positioning>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_rolloff(float rolloff) property", asFUNCTION((virtual_call<T, &T::set_rolloff, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_rolloff() const property", asFUNCTION((virtual_call<T, &T::get_rolloff, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_min_gain(float gain) property", asFUNCTION((virtual_call<T, &T::set_min_gain, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_min_gain() const property", asFUNCTION((virtual_call<T, &T::get_min_gain, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_max_gain(float gain) property", asFUNCTION((virtual_call<T, &T::set_max_gain, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_max_gain() const property", asFUNCTION((virtual_call<T, &T::get_max_gain, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_min_distance(float distance) property", asFUNCTION((virtual_call<T, &T::set_min_distance, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_min_distance() const property", asFUNCTION((virtual_call<T, &T::get_min_distance, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_max_distance(float distance) property", asFUNCTION((virtual_call<T, &T::set_max_distance, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_max_distance() const property", asFUNCTION((virtual_call<T, &T::get_max_distance, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_cone(float inner_radians, float outer_radians, float outer_gain)", asFUNCTION((virtual_call<T, &T::set_cone, void, float, float, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void get_cone(float &out inner_radians, float &out outer_radians, float &out outer_gain)", asFUNCTION((virtual_call<T, &T::get_cone, void, float *, float *, float *>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_doppler_factor(float factor) property", asFUNCTION((virtual_call<T, &T::set_doppler_factor, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_doppler_factor() const property", asFUNCTION((virtual_call<T, &T::get_doppler_factor, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_directional_attenuation_factor(float factor) property", asFUNCTION((virtual_call<T, &T::set_directional_attenuation_factor, void, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_directional_attenuation_factor() const property", asFUNCTION((virtual_call<T, &T::get_directional_attenuation_factor, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_fade(float start_volume, float end_volume, uint64 length)", asFUNCTION((virtual_call<T, &T::set_fade, void, float, float, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "float get_current_fade_volume() const property", asFUNCTION((virtual_call<T, &T::get_current_fade_volume, float>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_start_time(uint64 absolute_time) property", asFUNCTION((virtual_call<T, &T::set_start_time, void, ma_uint64>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "void set_stop_time(uint64 absolute_time)", asFUNCTION((virtual_call<T, &T::set_stop_time, void, ma_uint64>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type.c_str(), "bool get_playing() const property", asFUNCTION((virtual_call<T, &T::get_playing, bool>)), asCALL_CDECL_OBJFIRST);
}
void RegisterSoundsystem(asIScriptEngine *engine)
{
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
	RegisterSoundsystemAudioNode<audio_node>(engine, "audio_node");
	RegisterSoundsystemMixer<sound>(engine, "sound");
	engine->RegisterObjectBehaviour("sound", asBEHAVE_FACTORY, "sound@ s()", asFUNCTION(new_global_sound), asCALL_CDECL);
	engine->RegisterObjectMethod("sound", "bool load(const string&in filename)", asFUNCTION((virtual_call<sound, &sound::load, bool, const string &>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool stream(const string&in filename)", asFUNCTION((virtual_call<sound, &sound::stream, bool, const string &>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool load_memory(const string&in data)", asFUNCTION((virtual_call<sound, &sound::load_string, bool, const string &>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool close()", asFUNCTION((virtual_call<sound, &sound::close, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_active() const property", asFUNCTION((virtual_call<sound, &sound::get_active, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_paused() const property", asFUNCTION((virtual_call<sound, &sound::get_paused, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool pause()", asFUNCTION((virtual_call<sound, &sound::pause, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool pause_fade(const uint64 length)", asFUNCTION((virtual_call<sound, &sound::pause_fade, bool, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool pause_fade_in_frames(const uint64 length_in_frames)", asFUNCTION((virtual_call<sound, &sound::pause_fade_in_frames, bool, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool pause_fade_in_milliseconds(const uint64 length_in_milliseconds)", asFUNCTION((virtual_call<sound, &sound::pause_fade_in_milliseconds, bool, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_timed_fade(float start_volume, float end_volume, uint64 length, uint64 absolute_time)", asFUNCTION((virtual_call<sound, &sound::set_timed_fade, void, float, float, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_timed_fade_in_frames(float start_volume, float end_volume, uint64 length, uint64 absolute_time)", asFUNCTION((virtual_call<sound, &sound::set_timed_fade_in_frames, void, float, float, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_timed_fade_in_milliseconds(float start_volume, float end_volume, uint64 length, uint64 absolute_time)", asFUNCTION((virtual_call<sound, &sound::set_timed_fade_in_milliseconds, void, float, float, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_stop_time_with_fade(uint64 absolute_time, uint64 fade_length)", asFUNCTION((virtual_call<sound, &sound::set_stop_time_with_fade, void, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_stop_time_with_fade_in_frames(uint64 absolute_time, uint64 fade_length)", asFUNCTION((virtual_call<sound, &sound::set_stop_time_with_fade_in_frames, void, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_stop_time_with_fade_in_milliseconds(uint64 absolute_time, uint64 fade_length)", asFUNCTION((virtual_call<sound, &sound::set_stop_time_with_fade_in_milliseconds, void, unsigned long long, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "void set_looping(bool looping) property", asFUNCTION((virtual_call<sound, &sound::set_looping, void, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_looping() const property", asFUNCTION((virtual_call<sound, &sound::get_looping, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_at_end() const property", asFUNCTION((virtual_call<sound, &sound::get_looping, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool seek(const uint64 position)", asFUNCTION((virtual_call<sound, &sound::seek, bool, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool seek_in_frames(const uint64 position)", asFUNCTION((virtual_call<sound, &sound::seek_in_frames, bool, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool seek_in_milliseconds(const uint64 position)", asFUNCTION((virtual_call<sound, &sound::seek_in_milliseconds, bool, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_position() property", asFUNCTION((virtual_call<sound, &sound::get_position, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_position_in_frames() const property", asFUNCTION((virtual_call<sound, &sound::get_position_in_frames, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_position_in_milliseconnds() const property", asFUNCTION((virtual_call<sound, &sound::get_position_in_milliseconds, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_length() property", asFUNCTION((virtual_call<sound, &sound::get_length, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_length_in_frames( ) const property", asFUNCTION((virtual_call<sound, &sound::get_length_in_frames, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "uint64 get_length_in_ms() const property", asFUNCTION((virtual_call<sound, &sound::get_length_in_milliseconds, unsigned long long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "bool get_data_format(audio_format&out format, uint32&out channels, uint32&out sample_rate)", asFUNCTION((virtual_call<sound, &sound::get_data_format, bool, ma_format *, unsigned int *, unsigned int *>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("sound", "double get_pitch_lower_limit() const property", asFUNCTION((virtual_call<sound, &sound::get_pitch_lower_limit, bool>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("const string[]@ get_sound_input_devices() property", asFUNCTION(get_sound_input_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction("const string[]@ get_sound_output_devices() property", asFUNCTION(get_sound_output_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_sound_output_device() property", asFUNCTION(get_sound_output_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_output_device(int device) property", asFUNCTION(set_sound_output_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_default_decryption_key(const string& in key) property", asFUNCTION(set_default_decryption_key), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_default_pack(new_pack::pack_file@ storage) property", asFUNCTION(set_sound_default_storage), asCALL_CDECL);

	engine->RegisterGlobalFunction("audio_error_state get_SOUNDSYSTEM_LAST_ERROR() property", asFUNCTION(get_soundsystem_last_error), asCALL_CDECL);
}
