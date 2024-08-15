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

#include <miniaudio.h>
#include "bullet3.h" // Vector3

class asIScriptEngine;
class audio_engine;
class mixer;
class sound;

bool init_sound();
bool refresh_audio_devices();

class audio_node {
	public:
		virtual void duplicate(); // reference counting
		virtual void release();
		virtual audio_engine* get_engine() const;
		virtual unsigned int get_input_bus_count();
		virtual unsigned int get_output_bus_count();
		virtual unsigned int get_input_channels(unsigned int bus);
		virtual unsigned int get_output_channels(unsigned int bus);
		virtual bool attach_output_bus(unsigned int output_bus, audio_node* destination, unsigned int destination_input_bus);
		virtual bool detach_output_bus(unsigned int bus);
		virtual bool detach_all_output_busses();
		virtual bool set_output_bus_volume(unsigned int bus, float volume);
		virtual float get_output_bus_volume(unsigned int bus);
		virtual bool set_state(ma_node_state state);
		virtual ma_node_state get_state();
		virtual bool set_state_time(ma_node_state state, unsigned long long time);
		virtual unsigned long long get_state_time(ma_node_state state);
		virtual ma_node_state get_state_by_time(unsigned long long global_time);
		virtual ma_node_state get_state_by_time_range(unsigned long long global_time_begin, unsigned long long global_time_end);
		virtual unsigned long long get_time();
		virtual bool set_time(unsigned long long local_time);
};
class audio_engine {
	public:
		enum engine_flags {
			DURATIONS_IN_FRAMES = 1, // If set, all durations possible will expect a value in PCM frames rather than milliseconds.
			NO_AUTO_START = 2, // if set, audio_engine::start must be called after initialization.
			NO_DEVICE = 4 // If set, audio_engine::read() must be used to receive raw audio samples from the engine instead.
		};
		virtual void duplicate(); // reference counting
		virtual void release();
		virtual audio_node* get_endpoint();
		virtual bool read(void* buffer, unsigned long long frame_count, unsigned long long* frames_read);
		virtual CScriptArray* read(unsigned long long64 frame_count);
		virtual unsigned long long get_time();
		virtual bool set_time(unsigned long long time); // depends on DURATIONS_IN_FRAMES flag.
		virtual unsigned long long get_time_in_frames();
		virtual bool set_time_in_frames(unsigned long long time);
		virtual unsigned long long get_time_in_milliseconds();
		virtual bool set_time_in_milliseconds(unsigned long long time);
		virtual int get_channels();
		virtual int get_sample_rate();
		virtual bool start(); // Begins audio playback <ma_engine_start>, only needs to be called if NO_AUTO_START flag is set in engine construction or after stop is called.
		virtual bool stop(); // Stops audio playback.
		virtual bool set_volume(float volume); // 0.0 to 1.0.
		virtual float get_volume();
		virtual bool set_gain(float db);
		virtual float get_gain();
		virtual unsigned int get_listener_count();
		virtual unsigned int find_closest_listener(float x, float y, float z);
		virtual void set_listener_position(unsigned int index, float x, float y, float z);
		virtual Vector3 get_listener_position(unsigned int index);
		virtual void set_listener_direction(unsigned int index, float x, float y, float z);
		virtual Vector3 get_listener_direction(unsigned int index);
		virtual void set_listener_velocity(unsigned int index, float x, float y, float z);
		virtual Vector3 get_listener_velocity(unsigned int index);
		virtual void set_listener_cone(unsigned int index, float inner_radians, float outer_radians, float outer_gain);
		virtual void get_listener_cone(unsigned int index, float* inner_radians, float* outer_radians, float* outer_gain);
		virtual void set_listener_world_up(unsigned int index, float x, float y, float z);
		virtual Vector3 get_listener_world_up(unsigned int index);
		virtual void set_listener_enabled(unsigned int index, bool enabled);
		virtual bool get_listener_enabled(unsigned int index);
		virtual bool play(const std::string& path, audio_node* node, unsigned int input_bus_index);
		virtual bool play(const std::string& path, mixer* mixer = nullptr);
		virtual mixer* new_mixer();
		virtual sound* new_sound();
};
class mixer {
	public:
		virtual void duplicate(); // reference counting
		virtual void release();
		virtual audio_engine* get_engine();
		virtual bool play();
		virtual bool stop();
		virtual void set_volume(float volume);
		virtual float get_volume();
		virtual void set_pan(float pan);
		virtual float get_pan();
		virtual void set_pan_mode(ma_pan_mode mode);
		virtual ma_pan_mode get_pan_mode();
		virtual void set_pitch(float pitch);
		virtual float get_pitch();
		virtual void set_spatialization_enabled(bool enabled);
		virtual void get_spatialization_enabled();
		virtual void set_pinned_listener(unsigned int index);
		virtual unsigned int get_pinned_listener();
		virtual unsigned int get_listener();
		virtual Vector3 get_direction_to_listener();
		virtual void set_position(float x, float y, float z);
		virtual Vector3 get_position();
		virtual void set_direction(float x, float y, float z);
		virtual Vector3 get_direction();
		virtual void set_velocity(float x, float y, float z);
		virtual Vector3 get_velocity();
		virtual void set_attenuation_model(ma_attenuation_model model);
		virtual ma_attenuation_model get_attenuation_model();
		virtual void set_positioning(ma_positioning positioning);
		virtual ma_positioning get_positioning();
		virtual void set_rolloff(float rolloff);
		virtual float get_rolloff();
		virtual void set_min_gain(float gain);
		virtual float get_min_gain();
		virtual void set_max_gain(float gain);
		virtual float get_max_gain();
		virtual void set_min_distance(float distance);
		virtual float get_min_distance();
		virtual void set_max_distance(float distance);
		virtual float get_max_distance();
		virtual void set_cone(float inner_radians, float outer_radians, float outer_gain);
		virtual void get_cone(float* inner_radians, float* outer_radians, float* outer_gain);
		virtual void set_doppler_factor(float factor);
		virtual float get_doppler_factor();
		virtual void set_directional_attenuation_factor(float factor);
		virtual float get_directional_attenuation_factor();
		virtual void set_fade(float start_volume, float end_volume, unsigned long long length); // depends on DURATIONS_IN_FRAMES flag in parent engine
		virtual void set_fade_in_frames(float start_volume, float end_volume, unsigned long long frames);
		virtual void set_fade_in_milliseconds(float start_volume, float end_volume, unsigned long long milliseconds);
		virtual float get_current_fade_volume();
		virtual void set_start_time(unsigned long long absolute_time); // DURATIONS_IN_FRAMES
		virtual void set_start_time_in_frames(unsigned long long absolute_time);
		virtual void set_start_time_in_milliseconds(unsigned long long absolute_time);
		virtual void set_stop_time(unsigned long long absolute_time); // DURATIONS_IN_FRAMES
		virtual void set_stop_time_in_frames(unsigned long long absolute_time);
		virtual void set_stop_time_in_milliseconds(unsigned long long absolute_time);
		virtual unsigned long long get_time(); // DURATIONS_IN_FRAMES
		virtual unsigned long long get_time_in_frames();
		virtual unsigned long long get_time_in_milliseconds();
		virtual bool get_playing();
};
class sound : public mixer {
	public:
		virtual bool pause();
		virtual bool pause_fade(unsigned long long length); // depends on the DURATIONS_IN_FRAMES engine flag.
		virtual bool pause_fade_in_frames(unsigned long long frames);
		virtual bool pause_fade_in_milliseconds(unsigned long long milliseconds);
		virtual void set_timed_fade(float start_volume, float end_volume, unsigned long long length, unsigned long long absolute_time); // depends on DURATIONS_IN_FRAMES flag in parent engine
		virtual void set_timed_fade_in_frames(float start_volume, float end_volume, unsigned long long frames, unsigned long long absolute_time_in_frames);
		virtual void set_timed_fade_in_milliseconds(float start_volume, float end_volume, unsigned long long milliseconds, unsigned long long absolute_time_in_milliseconds);
		virtual void set_stop_time_with_fade(unsigned long long absolute_time, unsigned long long fade_length); // DURATIONS_IN_FRAMES
		virtual void set_stop_time_with_fade_in_frames(unsigned long long absolute_time, unsigned long long fade_length);
		virtual void set_stop_time_with_fade_in_milliseconds(unsigned long long absolute_time, unsigned long long fade_length);
		virtual void set_looping(bool looping);
		virtual bool get_looping();
		virtual bool get_at_end();
		virtual bool seek(unsigned long long position); // DURATION_IN_FRAMES
		virtual bool seek_in_frames(unsigned long long position);
		virtual bool seek_in_milliseconds(unsigned long long position);
		virtual unsigned long long get_position(); // DURATION_IN_FRAMES
		virtual unsigned long long get_position_in_frames();
		virtual unsigned long long get_position_in_milliseconds();
		virtual unsigned long long get_length(); // DURATION_IN_FRAMES
		virtual unsigned long long get_length_in_frames();
		virtual unsigned long long get_length_in_milliseconds();
		virtual bool get_data_format(ma_format* format, unsigned int* channels, unsigned int* sample_rate);
};

void RegisterSoundsystem(asIScriptEngine* engine);
