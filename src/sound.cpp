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
#include <Poco/Format.h>
#include <angelscript.h>
#include <aswrappedcall.h>
#include <scriptarray.h>
#include "nvgt_angelscript.h" // get_array_type
#include "sound.h"

using namespace std;

class sound_tmp;
audio_engine* new_audio_engine();
mixer* new_mixer(audio_engine* engine);
sound_tmp* new_sound(audio_engine* engine);

// Globals, currently NVGT does not support instanciating multiple miniaudio contexts and NVGT provides a global sound engine.
static ma_context g_sound_context;
audio_engine* g_audio_engine = nullptr;
static bool g_soundsystem_initialized = false;
static ma_result g_soundsystem_last_error = MA_SUCCESS;

bool init_sound() {
	if (g_soundsystem_initialized) return true;
	if ((g_soundsystem_last_error = ma_context_init(nullptr, 0, nullptr, &g_sound_context)) != MA_SUCCESS) return false;
	g_soundsystem_initialized = true;
	refresh_audio_devices();
	g_audio_engine = new_audio_engine();
	return true;
}

// audio device enumeration, we'll just maintain a global list of available devices, vectors of ma_device_info structures for the c++ side and CScriptArrays of device names on the Angelscript side. It is important that the data in these arrays is index aligned.
vector<ma_device_info> g_sound_input_devices, g_sound_output_devices;
static CScriptArray* g_sound_script_input_devices = nullptr, * g_sound_script_output_devices = nullptr;
ma_bool32 ma_device_enum_callback(ma_context* ctx, ma_device_type type, const ma_device_info* info, void* /*user*/) {
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
	if (!g_soundsystem_initialized && !init_sound()) return false;
	g_sound_output_devices.clear();
	g_sound_input_devices.clear();
	if (!g_sound_script_output_devices) g_sound_script_output_devices = CScriptArray::Create(get_array_type("array<string>"));
	else g_sound_script_output_devices->Resize(0);
	if (!g_sound_script_input_devices) g_sound_script_input_devices = CScriptArray::Create(get_array_type("array<string>"));
	else g_sound_script_input_devices->Resize(0);
	return (g_soundsystem_last_error = ma_context_enumerate_devices(&g_sound_context, ma_device_enum_callback, nullptr)) == MA_SUCCESS;
}
CScriptArray* get_sound_input_devices() {
	if (!init_sound()) return CScriptArray::Create(get_array_type("array<string>")); // Better to return an emptry array instead of null for now.
	return g_sound_script_input_devices;
}
CScriptArray* get_sound_output_devices() {
	if (!init_sound()) return CScriptArray::Create(get_array_type("array<string>"));
	return g_sound_script_output_devices;
}

reactphysics3d::Vector3 ma_vec3_to_rp_vec3(const ma_vec3f& v) { return reactphysics3d::Vector3(v.x, v.y, v.z); }

// I learned the hard way that you can't instantiate a virtual class until none of it's members are abstract. Hack around that. When wrapper is complete, remove the following placeholder classes:
class sound_tmp : public virtual mixer {
public:
	virtual bool load(const string& filename) = 0;
	virtual bool seek(unsigned long long offset) = 0;
};

// Miniaudio objects must be allocated on the heap as nvgt's API introduces the concept of an uninitialized sound, which a stack based system would make more difficult to implement.
class audio_engine_impl : public audio_engine {
		unique_ptr<ma_engine> engine;
		audio_node* engine_endpoint; // Upon engine creation we'll call ma_engine_get_endpoint once so as to avoid creating more than one of our wrapper objects when our engine->get_endpoint() function is called.
		int refcount;
	public:
		engine_flags flags;
		audio_engine_impl() : refcount(1) {
			// default constructor initializes a miniaudio engine ourselves.
			ma_engine_config cfg = ma_engine_config_init();
			engine = make_unique<ma_engine>();
			if ((g_soundsystem_last_error = ma_engine_init(&cfg, &*engine)) != MA_SUCCESS) {
				engine.reset();
				return;
			}
		}
		void duplicate() { asAtomicInc(refcount); }
		void release() {
			if (asAtomicDec(refcount) < 1) delete this;
		}
		ma_engine* get_ma_engine() { return engine.get(); }
		audio_node* get_endpoint() { return nullptr; } // Implement after audio_node
		int get_device() {
			if (!engine) return -1;
			ma_device* dev = ma_engine_get_device(&*engine);
			ma_device_info info;
			if (!dev || ma_device_get_info(dev, ma_device_type_playback, &info) != MA_SUCCESS) return -1;
			for (int i = 0; i < g_sound_output_devices.size(); i++) {
				if (memcmp(&g_sound_output_devices[i].id, &info.id, sizeof(ma_device_id)) == 0) return i;
			}
			return -1; // couldn't determine device?
		}
		bool set_device(int device) {
			if (!engine || device < 0 || device >= g_sound_output_devices.size()) return false;
			ma_device* old_dev = ma_engine_get_device(&*engine);
			if (!old_dev || memcmp(&old_dev->playback.id, &g_sound_output_devices[device].id, sizeof(ma_device_id)) == 0) return false;
			ma_engine_stop(&*engine);
			ma_device_data_proc proc = old_dev->onData;
			ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
			cfg.playback.pDeviceID = &g_sound_output_devices[device].id;
			cfg.playback.channels = old_dev->playback.channels;
			cfg.sampleRate = old_dev->sampleRate;
			cfg.noPreSilencedOutputBuffer = old_dev->noPreSilencedOutputBuffer;
			cfg.noClip = old_dev->noClip;
			cfg.noDisableDenormals = old_dev->noDisableDenormals;
			cfg.noFixedSizedCallback = old_dev->noFixedSizedCallback;
			cfg.dataCallback = old_dev->onData;
			cfg.pUserData = &*engine;
			ma_device_uninit(old_dev);
			ma_device_init(&g_sound_context, &cfg, old_dev);
			return (g_soundsystem_last_error = ma_engine_start(&*engine)) == MA_SUCCESS;
		}
		bool read(void* buffer, unsigned long long frame_count, unsigned long long* frames_read) { return engine? (g_soundsystem_last_error = ma_engine_read_pcm_frames(&*engine, buffer, frame_count, frames_read)) == MA_SUCCESS : false; }
		CScriptArray* read(unsigned long long frame_count) {
			if (!engine) return nullptr;
			CScriptArray* result = CScriptArray::Create(get_array_type("array<float>"), frame_count * ma_engine_get_channels(&*engine));
			unsigned long long frames_read;
			if (!read(result->GetBuffer(), frame_count, &frames_read)) {
				result->Resize(0);
				return result;
			}
			result->Resize(frames_read * ma_engine_get_channels(&*engine));
			return result;
		}
		unsigned long long get_time() { return engine? (flags & DURATIONS_IN_FRAMES? ma_engine_get_time_in_pcm_frames(&*engine) : ma_engine_get_time_in_milliseconds(&*engine)) : 0; }
		bool set_time(unsigned long long time) { return engine? (g_soundsystem_last_error = (flags & DURATIONS_IN_FRAMES? ma_engine_set_time_in_pcm_frames(&*engine, time) : ma_engine_set_time_in_milliseconds(&*engine, time))) == MA_SUCCESS : false; }
		unsigned long long get_time_in_frames() { return engine? ma_engine_get_time_in_pcm_frames(&*engine) : 0; }
		bool set_time_in_frames(unsigned long long time) { return engine ? (g_soundsystem_last_error = ma_engine_set_time_in_pcm_frames(&*engine, time)) == MA_SUCCESS : false; }
		unsigned long long get_time_in_milliseconds() { return engine? ma_engine_get_time_in_milliseconds(&*engine) : 0; }
		bool set_time_in_milliseconds(unsigned long long time) { return engine ? (g_soundsystem_last_error = ma_engine_set_time_in_milliseconds(&*engine, time)) == MA_SUCCESS : false; }
		int get_channels() { return engine? ma_engine_get_channels(&*engine) : 0; }
		int get_sample_rate() { return engine? ma_engine_get_sample_rate(&*engine) : 0; }
		bool start() { return engine? (ma_engine_start(&*engine)) == MA_SUCCESS : false; }
		bool stop() { return engine? (ma_engine_stop(&*engine)) == MA_SUCCESS : false; }
		bool set_volume(float volume) { return engine? (g_soundsystem_last_error = ma_engine_set_volume(&*engine, volume)) == MA_SUCCESS : false; }
		float get_volume() { return engine? ma_engine_get_volume(&*engine) : 0; }
		bool set_gain(float db) { return engine? (g_soundsystem_last_error = ma_engine_set_gain_db(&*engine, db)) == MA_SUCCESS : false; }
		float get_gain() { return engine? ma_engine_get_gain_db(&*engine) : 0; }
		unsigned int get_listener_count() { return engine? ma_engine_get_listener_count(&*engine) : 0; }
		int find_closest_listener(float x, float y, float z) { return engine? ma_engine_find_closest_listener(&*engine, x, y, z) : -1; }
		int find_closest_listener(const reactphysics3d::Vector3& position) override { return engine? ma_engine_find_closest_listener(&*engine, position.x, position.y, position.z) : -1; }
		void set_listener_position(unsigned int index, float x, float y, float z) { if(engine) ma_engine_listener_set_position(&*engine, index, x, y, z); }
		void set_listener_position(unsigned int index, const reactphysics3d::Vector3& position) { if(engine) ma_engine_listener_set_position(&*engine, index, position.x, position.y, position.z); }
		reactphysics3d::Vector3 get_listener_position(unsigned int index) { return engine? ma_vec3_to_rp_vec3(ma_engine_listener_get_position(&*engine, index)) : reactphysics3d::Vector3(); }
		void set_listener_direction(unsigned int index, float x, float y, float z) { if(engine) ma_engine_listener_set_direction(&*engine, index, x, y, z); }
		void set_listener_direction(unsigned int index, const reactphysics3d::Vector3& direction) { if(engine) ma_engine_listener_set_direction(&*engine, index, direction.x, direction.y, direction.z); }
		reactphysics3d::Vector3 get_listener_direction(unsigned int index) { return engine? ma_vec3_to_rp_vec3(ma_engine_listener_get_direction(&*engine, index)) : reactphysics3d::Vector3(); }
		void set_listener_velocity(unsigned int index, float x, float y, float z) { if(engine) ma_engine_listener_set_velocity(&*engine, index, x, y, z); }
		void set_listener_velocity(unsigned int index, const reactphysics3d::Vector3& velocity) { if(engine) ma_engine_listener_set_velocity(&*engine, index, velocity.x, velocity.y, velocity.z); }
		reactphysics3d::Vector3 get_listener_velocity(unsigned int index) { return engine? ma_vec3_to_rp_vec3(ma_engine_listener_get_velocity(&*engine, index)) : reactphysics3d::Vector3(); }
		void set_listener_cone(unsigned int index, float inner_radians, float outer_radians, float outer_gain) { if(engine) ma_engine_listener_set_cone(&*engine, index, inner_radians, outer_radians, outer_gain); }
		void get_listener_cone(unsigned int index, float* inner_radians, float* outer_radians, float* outer_gain) { if(engine) ma_engine_listener_get_cone(&*engine, index, inner_radians, outer_radians, outer_gain); }
		void set_listener_world_up(unsigned int index, float x, float y, float z) { if(engine) ma_engine_listener_set_world_up(&*engine, index, x, y, z); }
		void set_listener_world_up(unsigned int index, const reactphysics3d::Vector3& world_up) { if(engine) ma_engine_listener_set_world_up(&*engine, index, world_up.x, world_up.y, world_up.z); }
		reactphysics3d::Vector3 get_listener_world_up(unsigned int index) { return engine? ma_vec3_to_rp_vec3(ma_engine_listener_get_world_up(&*engine, index)) : reactphysics3d::Vector3(); }
		void set_listener_enabled(unsigned int index, bool enabled) { if(engine) ma_engine_listener_set_enabled(&*engine, index, enabled); }
		bool get_listener_enabled(unsigned int index) { return ma_engine_listener_is_enabled(&*engine, index); }
		bool play(const string& filename, audio_node* node, unsigned int bus_index) { return false; } // Implement after audio_node
		bool play(const string& filename, mixer* mixer) { return engine? (ma_engine_play_sound(&*engine, filename.c_str(), mixer? mixer->get_ma_sound() : nullptr)) == MA_SUCCESS : false; }
		mixer* new_mixer() { return ::new_mixer(this); }
		//sound* new_sound() { return ::new_sound(this); }
};
class mixer_impl : public virtual mixer {
	// In miniaudio, a sound_group is really just a sound. A typical ma_sound_group_x function looks like float ma_sound_group_get_pan(const ma_sound_group* pGroup) { return ma_sound_get_pan(pGroup); }.
	// Furthermore ma_sound_group is just a typedef for ma_sound. As such, for the sake of less code and better inheritance, we will directly call the ma_sound APIs in this class even though it deals with sound groups and not sounds.
	protected:
		audio_engine_impl* engine;
		unique_ptr<ma_sound> snd;
		int refcount;
	public:
	mixer_impl() : snd(nullptr), refcount(1) {
		init_sound();
		engine = static_cast<audio_engine_impl*>(g_audio_engine);
	}
	mixer_impl(audio_engine* engine) : engine(static_cast<audio_engine_impl*>(engine)), snd(nullptr), refcount(1) {}
	void duplicate() override { asAtomicInc(refcount); }
	void release() override {
		if (asAtomicDec(refcount) < 1) delete this;
	}
	bool play() override { return snd? ma_sound_start(&*snd) : false; }
	ma_sound* get_ma_sound() { return &*snd; }
	audio_engine* get_engine() override {
		return engine;
	}
	bool stop() override { return snd ? ma_sound_stop(&*snd) : false; }
	void set_volume(float volume) override {
		if (snd) ma_sound_set_volume(&*snd, volume);
	}
	float get_volume() override { return snd ? ma_sound_get_volume(&*snd) : NAN; }
	void set_pan(float pan) override {
		if (snd) {
			ma_sound_set_pan(&*snd, pan);
		}
	}
	float get_pan() override {
		return snd ? ma_sound_get_pan(&*snd) : NAN;
	}
	void set_pan_mode(ma_pan_mode mode) override {
		if (snd) {
			ma_sound_set_pan_mode(&*snd, mode);
		}
	}
	ma_pan_mode get_pan_mode() override {
		return snd ? ma_sound_get_pan_mode(&*snd) : ma_pan_mode_balance;
	}
	void set_pitch(float pitch) override {
		if (snd) {
			ma_sound_set_pitch(&*snd, pitch);
		}
	}
	float get_pitch() override {
		return snd ? ma_sound_get_pitch(&*snd) : NAN;
	}
	void set_spatialization_enabled(bool enabled) override {
		if (snd) {
			ma_sound_set_spatialization_enabled(&*snd, enabled);
		}
	}
	bool get_spatialization_enabled() override {
		return snd ? ma_sound_is_spatialization_enabled(&*snd) : false;
	}
	void set_pinned_listener(unsigned int index) override {
		if (snd) {
			ma_sound_set_pinned_listener_index(&*snd, index);
		}
	}
	unsigned int get_pinned_listener() override {
		return snd ? ma_sound_get_pinned_listener_index(&*snd) : 0;
	}
	unsigned int get_listener() override {
		return snd ? ma_sound_get_listener_index(&*snd) : 0;
	}
	reactphysics3d::Vector3 get_direction_to_listener() override {
		if (!snd) return reactphysics3d::Vector3();
		const auto dir = ma_sound_get_direction_to_listener(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(dir.x, dir.y, dir.z);
		return res;
	}
	void set_position_3d(float x, float y, float z) override {
		if (!snd) return;
		return ma_sound_set_position(&*snd, x, y, z);
	}
	reactphysics3d::Vector3 get_position_3d() override {
		if (!snd) return reactphysics3d::Vector3();
		const auto pos = ma_sound_get_position(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(pos.x, pos.y, pos.z);
		return res;
	}
	void set_direction(float x, float y, float z) override {
		if (!snd) return;
		return ma_sound_set_direction(&*snd, x, y, z);
	}
	reactphysics3d::Vector3 get_direction() override {
		if (!snd) return reactphysics3d::Vector3();
		const auto dir = ma_sound_get_direction(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(dir.x, dir.y, dir.z);
		return res;
	}
	void set_velocity(float x, float y, float z) override {
		if (!snd) return;
		return ma_sound_set_velocity(&*snd, x, y, z);
	}
	reactphysics3d::Vector3 get_velocity() override {
		if (!snd) return reactphysics3d::Vector3();
		const auto vel = ma_sound_get_velocity(&*snd);
		reactphysics3d::Vector3 res;
		res.setAllValues(vel.x, vel.y, vel.z);
		return res;
	}
	void set_attenuation_model(ma_attenuation_model model) override {
		if (snd) {
			ma_sound_set_attenuation_model(&*snd, model);
		}
	}
	ma_attenuation_model get_attenuation_model() override {
		return snd ? ma_sound_get_attenuation_model(&*snd) : ma_attenuation_model_none;
	}
	void set_positioning(ma_positioning positioning) override {
		if (snd) {
			ma_sound_set_positioning(&*snd, positioning);
		}
	}
	ma_positioning get_positioning() override {
		return snd ? ma_sound_get_positioning(&*snd) : ma_positioning_absolute;
	}
	void set_rolloff(float rolloff) override {
		if (snd) {
			ma_sound_set_rolloff(&*snd, rolloff);
		}
	}
	float get_rolloff() override {
		return snd ? ma_sound_get_rolloff(&*snd) : NAN;
	}
	void set_min_gain(float gain) override {
		if (snd) {
			ma_sound_set_min_gain(&*snd, gain);
		}
	}
	float get_min_gain() override {
		return snd ? ma_sound_get_min_gain(&*snd) : NAN;
	}
	void set_max_gain(float gain) override {
		if (snd) {
			ma_sound_set_max_gain(&*snd, gain);
		}
	}
	float get_max_gain() override {
		return snd ? ma_sound_get_max_gain(&*snd) : NAN;
	}
	void set_min_distance(float distance) override {
		if (snd) {
			ma_sound_set_min_distance(&*snd, distance);
		}
	}
	float get_min_distance() override {
		return snd ? ma_sound_get_min_distance(&*snd) : NAN;
	}
	void set_max_distance(float distance) override {
		if (snd) {
			ma_sound_set_max_distance(&*snd, distance);
		}
	}
	float get_max_distance() override {
		return snd ? ma_sound_get_max_distance(&*snd) : NAN;
	}
	void set_cone(float inner_radians, float outer_radians, float outer_gain) override {
		if (snd) {
			ma_sound_set_cone(&*snd, inner_radians, outer_radians, outer_gain);
		}
	}
	void get_cone(float* inner_radians, float* outer_radians, float* outer_gain) override {
		if (snd) {
			ma_sound_get_cone(&*snd, inner_radians, outer_radians, outer_gain);
		} else {
			if (inner_radians) *inner_radians = NAN;
			if (outer_radians) *outer_radians = NAN;
			if (outer_gain)	*outer_gain	= NAN;
		}
	}
	void set_doppler_factor(float factor) override {
		if (snd) {
			ma_sound_set_doppler_factor(&*snd, factor);
		}
	}
	float get_doppler_factor() override {
		return snd ? ma_sound_get_doppler_factor(&*snd) : NAN;
	}
	void set_directional_attenuation_factor(float factor) override {
		if (snd) {
			ma_sound_set_directional_attenuation_factor(&*snd, factor);
		}
	}
	float get_directional_attenuation_factor() override {
		return snd ? ma_sound_get_directional_attenuation_factor(&*snd) : NAN;
	}
	void set_fade(float start_volume, float end_volume, unsigned long long length) override {
		if (snd) {
			if (engine->flags & audio_engine::DURATIONS_IN_FRAMES) {
				ma_sound_set_fade_in_pcm_frames(&*snd, start_volume, end_volume, length);
			} else {
				ma_sound_set_fade_in_milliseconds(&*snd, start_volume, end_volume, length);
			}
		}
	}
	void set_fade_in_frames(float start_volume, float end_volume, unsigned long long frames) override {
		if (snd) {
			ma_sound_set_fade_in_pcm_frames(&*snd, start_volume, end_volume, frames);
		}
	}
	void set_fade_in_milliseconds(float start_volume, float end_volume, unsigned long long milliseconds) override {
		if (snd) {
			ma_sound_set_fade_in_milliseconds(&*snd, start_volume, end_volume, milliseconds);
		}
	}
	float get_current_fade_volume() override {
		return snd ? ma_sound_get_current_fade_volume(&*snd) : NAN;
	}
	void set_start_time(unsigned long long absolute_time) override {
		if (snd) {
			if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
				ma_sound_set_start_time_in_pcm_frames(&*snd, absolute_time);
			else
				ma_sound_set_start_time_in_milliseconds(&*snd, absolute_time);
		}
	}
	void set_start_time_in_frames(unsigned long long absolute_time) override {
		if (snd) {
			ma_sound_set_start_time_in_pcm_frames(&*snd, absolute_time);
		}
	}
	void set_start_time_in_milliseconds(unsigned long long absolute_time) override {
		if (snd) {
			ma_sound_set_start_time_in_milliseconds(&*snd, absolute_time);
		}
	}
	void set_stop_time(unsigned long long absolute_time) override {
		if (snd) {
			if (engine->flags & audio_engine::DURATIONS_IN_FRAMES)
				ma_sound_set_stop_time_in_pcm_frames(&*snd, absolute_time);
			else
				ma_sound_set_stop_time_in_milliseconds(&*snd, absolute_time);
		}
	}
	void set_stop_time_in_frames(unsigned long long absolute_time) override {
		if (snd) {
			ma_sound_set_stop_time_in_pcm_frames(&*snd, absolute_time);
		}
	}
	void set_stop_time_in_milliseconds(unsigned long long absolute_time) override {
		if (snd) {
			ma_sound_set_stop_time_in_milliseconds(&*snd, absolute_time);
		}
	}
	unsigned long long get_time() override {
	return snd ? ((engine->flags & audio_engine::DURATIONS_IN_FRAMES) ? ma_sound_get_time_in_pcm_frames(&*snd) : ma_sound_get_time_in_milliseconds(&*snd)) : 0;
	}
	unsigned long long get_time_in_frames() override {
		return snd ? ma_sound_get_time_in_pcm_frames(&*snd) : 0;
	}
	unsigned long long get_time_in_milliseconds() override {
		return snd ? ma_sound_get_time_in_milliseconds(&*snd) : 0ULL;
	}
	bool get_playing() override {
		return snd ? ma_sound_is_playing(&*snd) : false;
	}
};
class sound_impl : public mixer_impl, public sound_tmp {
	public:
		sound_impl(audio_engine* e) {
			engine = static_cast<audio_engine_impl*>(e);
			snd = nullptr;
		}
		~sound_impl() {
			if (snd) ma_sound_uninit(&*snd);
			snd.reset();
		}
	void release() {
		if (asAtomicDec(refcount) < 1) delete this;
	}
		bool load(const string& filename) {
			if (!snd) snd = make_unique<ma_sound>();
			g_soundsystem_last_error = ma_sound_init_from_file(engine->get_ma_engine(), filename.c_str(), 0, nullptr, nullptr, snd.get());
			if (g_soundsystem_last_error != MA_SUCCESS) snd.reset();
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		bool seek(unsigned long long offset) { return snd? (g_soundsystem_last_error = ma_sound_seek_to_pcm_frame(&*snd, offset * ma_engine_get_sample_rate(engine->get_ma_engine()) / 1000)) == MA_SUCCESS : false; }
};

audio_engine* new_audio_engine() { return new audio_engine_impl(); }
mixer* new_mixer(audio_engine* engine) { return new mixer_impl(engine); }
sound_tmp* new_sound(audio_engine* engine) { return new sound_impl(engine); }
sound_tmp* new_global_sound() { init_sound(); return new sound_impl(g_audio_engine); }
int get_sound_output_device() { init_sound(); return g_audio_engine->get_device(); }
bool set_sound_output_device(int device) { init_sound(); return g_audio_engine->set_device(device); }

void RegisterSoundsystem(asIScriptEngine* engine) {
	engine->RegisterObjectType("sound", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("sound", asBEHAVE_FACTORY, "sound@ s()", asFUNCTION(new_global_sound), asCALL_CDECL);
	engine->RegisterObjectBehaviour("sound", asBEHAVE_ADDREF, "void f()", WRAP_MFN_PR(sound_tmp, duplicate, (), void), asCALL_GENERIC);
	engine->RegisterObjectBehaviour("sound", asBEHAVE_RELEASE, "void f()", WRAP_MFN_PR(sound_tmp, release, (), void), asCALL_GENERIC);
	engine->RegisterObjectMethod("sound", "bool load(const string&in filename)", WRAP_MFN(sound_tmp, load), asCALL_GENERIC);
	engine->RegisterObjectMethod("sound", "bool play()", WRAP_MFN_PR(sound_tmp, play, (), bool), asCALL_GENERIC);
	engine->RegisterObjectMethod("sound", "bool seek(uint64 offset)", WRAP_MFN_PR(sound_tmp, seek, (unsigned long long), bool), asCALL_GENERIC);
	engine->RegisterGlobalFunction("const string[]@ get_sound_input_devices() property", asFUNCTION(get_sound_input_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction("const string[]@ get_sound_output_devices() property", asFUNCTION(get_sound_output_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_sound_output_device() property", asFUNCTION(get_sound_output_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_output_device(int device) property", asFUNCTION(set_sound_output_device), asCALL_CDECL);
}
