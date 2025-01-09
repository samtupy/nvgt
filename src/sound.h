/* sound.h - sound system implementation header
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

#pragma once

#include <miniaudio.h>
#include <reactphysics3d/mathematics/Vector3.h>

class CScriptArray;
class asIScriptEngine;
class audio_engine;
class mixer;
class sound;

//extern audio_engine* g_audio_engine;
bool init_sound();
bool refresh_audio_devices();

class audio_node {
	public:
		virtual void duplicate() = 0; // reference counting
		virtual void release() = 0;
		virtual audio_engine* get_engine() const = 0;
		virtual unsigned int get_input_bus_count() = 0;
		virtual unsigned int get_output_bus_count() = 0;
		virtual unsigned int get_input_channels(unsigned int bus) = 0;
		virtual unsigned int get_output_channels(unsigned int bus) = 0;
		virtual bool attach_output_bus(unsigned int output_bus, audio_node* destination, unsigned int destination_input_bus) = 0;
		virtual bool detach_output_bus(unsigned int bus) = 0;
		virtual bool detach_all_output_busses() = 0;
		virtual bool set_output_bus_volume(unsigned int bus, float volume) = 0;
		virtual float get_output_bus_volume(unsigned int bus) = 0;
		virtual bool set_state(ma_node_state state) = 0;
		virtual ma_node_state get_state() = 0;
		virtual bool set_state_time(ma_node_state state, unsigned long long time) = 0;
		virtual unsigned long long get_state_time(ma_node_state state) = 0;
		virtual ma_node_state get_state_by_time(unsigned long long global_time) = 0;
		virtual ma_node_state get_state_by_time_range(unsigned long long global_time_begin, unsigned long long global_time_end) = 0;
		virtual unsigned long long get_time() = 0;
		virtual bool set_time(unsigned long long local_time) = 0;
};
class audio_engine {
	public:
		enum engine_flags {
			DURATIONS_IN_FRAMES = 1, // If set, all durations possible will expect a value in PCM frames rather than milliseconds.
			NO_AUTO_START = 2, // if set, audio_engine::start must be called after initialization.
			NO_DEVICE = 4 // If set, audio_engine::read() must be used to receive raw audio samples from the engine instead.
		};
		virtual void duplicate() = 0; // reference counting
		virtual void release() = 0;
		virtual audio_node* get_endpoint() = 0;
		virtual ma_engine* get_ma_engine() = 0;
		virtual bool read(void* buffer, unsigned long long frame_count, unsigned long long* frames_read) = 0;
		virtual CScriptArray* read(unsigned long long frame_count) = 0;
		virtual unsigned long long get_time() = 0;
		virtual bool set_time(unsigned long long time) = 0; // depends on DURATIONS_IN_FRAMES flag.
		virtual unsigned long long get_time_in_frames() = 0;
		virtual bool set_time_in_frames(unsigned long long time) = 0;
		virtual unsigned long long get_time_in_milliseconds() = 0;
		virtual bool set_time_in_milliseconds(unsigned long long time) = 0;
		virtual int get_channels() = 0;
		virtual int get_sample_rate() = 0;
		virtual bool start() = 0; // Begins audio playback <ma_engine_start>, only needs to be called if NO_AUTO_START flag is set in engine construction or after stop is called.
		virtual bool stop() = 0; // Stops audio playback.
		virtual bool set_volume(float volume) = 0; // 0.0 to 1.0.
		virtual float get_volume() = 0;
		virtual bool set_gain(float db) = 0;
		virtual float get_gain() = 0;
		virtual unsigned int get_listener_count() = 0;
		virtual unsigned int find_closest_listener(float x, float y, float z) = 0;
		virtual void set_listener_position(unsigned int index, float x, float y, float z) = 0;
		virtual reactphysics3d::Vector3 get_listener_position(unsigned int index) = 0;
		virtual void set_listener_direction(unsigned int index, float x, float y, float z) = 0;
		virtual reactphysics3d::Vector3 get_listener_direction(unsigned int index) = 0;
		virtual void set_listener_velocity(unsigned int index, float x, float y, float z) = 0;
		virtual reactphysics3d::Vector3 get_listener_velocity(unsigned int index) = 0;
		virtual void set_listener_cone(unsigned int index, float inner_radians, float outer_radians, float outer_gain) = 0;
		virtual void get_listener_cone(unsigned int index, float* inner_radians, float* outer_radians, float* outer_gain) = 0;
		virtual void set_listener_world_up(unsigned int index, float x, float y, float z) = 0;
		virtual reactphysics3d::Vector3 get_listener_world_up(unsigned int index) = 0;
		virtual void set_listener_enabled(unsigned int index, bool enabled) = 0;
		virtual bool get_listener_enabled(unsigned int index) = 0;
		virtual bool play(const std::string& path, audio_node* node, unsigned int input_bus_index) = 0;
		virtual bool play(const std::string& path, mixer* mixer = nullptr) = 0;
		virtual mixer* new_mixer() = 0;
		virtual sound* new_sound() = 0;
};
class mixer {
	public:
		virtual void duplicate() = 0; // reference counting
		virtual void release() = 0;
		virtual audio_engine* get_engine() = 0;
		virtual bool play() = 0;
		virtual bool stop() = 0;
		virtual void set_volume(float volume) = 0;
		virtual float get_volume() = 0;
		virtual void set_pan(float pan) = 0;
		virtual float get_pan() = 0;
		virtual void set_pan_mode(ma_pan_mode mode) = 0;
		virtual ma_pan_mode get_pan_mode() = 0;
		virtual void set_pitch(float pitch) = 0;
		virtual float get_pitch() = 0;
		virtual void set_spatialization_enabled(bool enabled) = 0;
		virtual void get_spatialization_enabled() = 0;
		virtual void set_pinned_listener(unsigned int index) = 0;
		virtual unsigned int get_pinned_listener() = 0;
		virtual unsigned int get_listener() = 0;
		virtual reactphysics3d::Vector3 get_direction_to_listener() = 0;
		virtual void set_position_3d(float x, float y, float z) = 0;
		virtual reactphysics3d::Vector3 get_position_3d() = 0;
		virtual void set_direction(float x, float y, float z) = 0;
		virtual reactphysics3d::Vector3 get_direction() = 0;
		virtual void set_velocity(float x, float y, float z) = 0;
		virtual reactphysics3d::Vector3 get_velocity() = 0;
		virtual void set_attenuation_model(ma_attenuation_model model) = 0;
		virtual ma_attenuation_model get_attenuation_model() = 0;
		virtual void set_positioning(ma_positioning positioning) = 0;
		virtual ma_positioning get_positioning() = 0;
		virtual void set_rolloff(float rolloff) = 0;
		virtual float get_rolloff() = 0;
		virtual void set_min_gain(float gain) = 0;
		virtual float get_min_gain() = 0;
		virtual void set_max_gain(float gain) = 0;
		virtual float get_max_gain() = 0;
		virtual void set_min_distance(float distance) = 0;
		virtual float get_min_distance() = 0;
		virtual void set_max_distance(float distance) = 0;
		virtual float get_max_distance() = 0;
		virtual void set_cone(float inner_radians, float outer_radians, float outer_gain) = 0;
		virtual void get_cone(float* inner_radians, float* outer_radians, float* outer_gain) = 0;
		virtual void set_doppler_factor(float factor) = 0;
		virtual float get_doppler_factor() = 0;
		virtual void set_directional_attenuation_factor(float factor) = 0;
		virtual float get_directional_attenuation_factor() = 0;
		virtual void set_fade(float start_volume, float end_volume, unsigned long long length) = 0; // depends on DURATIONS_IN_FRAMES flag in parent engine
		virtual void set_fade_in_frames(float start_volume, float end_volume, unsigned long long frames) = 0;
		virtual void set_fade_in_milliseconds(float start_volume, float end_volume, unsigned long long milliseconds) = 0;
		virtual float get_current_fade_volume() = 0;
		virtual void set_start_time(unsigned long long absolute_time) = 0; // DURATIONS_IN_FRAMES
		virtual void set_start_time_in_frames(unsigned long long absolute_time) = 0;
		virtual void set_start_time_in_milliseconds(unsigned long long absolute_time) = 0;
		virtual void set_stop_time(unsigned long long absolute_time) = 0; // DURATIONS_IN_FRAMES
		virtual void set_stop_time_in_frames(unsigned long long absolute_time) = 0;
		virtual void set_stop_time_in_milliseconds(unsigned long long absolute_time) = 0;
		virtual unsigned long long get_time() = 0; // DURATIONS_IN_FRAMES
		virtual unsigned long long get_time_in_frames() = 0;
		virtual unsigned long long get_time_in_milliseconds() = 0;
		virtual bool get_playing() = 0;
};
class sound : public mixer {
	public:
		virtual bool load(const std::string& filename) = 0;
		virtual bool load_memory(const std::string& data) = 0;
		virtual bool load_memory(void* buffer, unsigned int size) = 0;
		virtual bool load_pcm(void* buffer, unsigned int size, ma_format format, int samplerate, int channels) = 0;
		virtual bool close() = 0;
		virtual bool get_active() = 0;
		virtual bool get_paused() = 0;
		virtual bool pause() = 0;
		virtual bool pause_fade(unsigned long long length) = 0; // depends on the DURATIONS_IN_FRAMES engine flag.
		virtual bool pause_fade_in_frames(unsigned long long frames) = 0;
		virtual bool pause_fade_in_milliseconds(unsigned long long milliseconds) = 0;
		virtual void set_timed_fade(float start_volume, float end_volume, unsigned long long length, unsigned long long absolute_time) = 0; // depends on DURATIONS_IN_FRAMES flag in parent engine
		virtual void set_timed_fade_in_frames(float start_volume, float end_volume, unsigned long long frames, unsigned long long absolute_time_in_frames) = 0;
		virtual void set_timed_fade_in_milliseconds(float start_volume, float end_volume, unsigned long long milliseconds, unsigned long long absolute_time_in_milliseconds) = 0;
		virtual void set_stop_time_with_fade(unsigned long long absolute_time, unsigned long long fade_length) = 0; // DURATIONS_IN_FRAMES
		virtual void set_stop_time_with_fade_in_frames(unsigned long long absolute_time, unsigned long long fade_length) = 0;
		virtual void set_stop_time_with_fade_in_milliseconds(unsigned long long absolute_time, unsigned long long fade_length) = 0;
		virtual void set_looping(bool looping) = 0;
		virtual bool get_looping() = 0;
		virtual bool get_at_end() = 0;
		virtual bool seek(unsigned long long position) = 0; // DURATION_IN_FRAMES
		virtual bool seek_in_frames(unsigned long long position) = 0;
		virtual bool seek_in_milliseconds(unsigned long long position) = 0;
		virtual unsigned long long get_position() = 0; // DURATION_IN_FRAMES
		virtual unsigned long long get_position_in_frames() = 0;
		virtual unsigned long long get_position_in_milliseconds() = 0;
		virtual unsigned long long get_length() = 0; // DURATION_IN_FRAMES
		virtual unsigned long long get_length_in_frames() = 0;
		virtual unsigned long long get_length_in_milliseconds() = 0;
		virtual bool get_data_format(ma_format* format, unsigned int* channels, unsigned int* sample_rate) = 0;
};

// audio_engine* new_audio_engine();

void RegisterSoundsystem(asIScriptEngine* engine);
