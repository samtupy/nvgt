/* sound.h - sound system implementation header
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

#include <miniaudio.h>
#include <reactphysics3d/mathematics/Vector3.h>
#include "sound_service.h"

#define SOUNDSYSTEM_FRAMESIZE 256 // We can make this be configureable if enough people want it.

class CScriptArray;
class CScriptHandle;
class asIScriptEngine;
class script_memory_buffer;
class datastream;
class pack_interface;
class audio_engine;
class mixer;
class sound;
class audio_node_chain;
class splitter_node;
class reverb3d;
struct audio_spatialization_parameters;
enum audio_spatializer_reverb3d_placement {
	prepan,
	postpan,
	postattenuate
};

extern audio_engine *g_audio_engine;
extern std::atomic<ma_result> g_soundsystem_last_error;
// Add support for a new audio format by plugging in a ma_decoding_backend_vtable.
bool add_decoder(ma_decoding_backend_vtable *vtable);
bool init_sound();
void uninit_sound();
bool refresh_audio_devices();
void garbage_collect_inline_sounds();
float pan_db_to_linear(float db);

class audio_node {
public:
	virtual void duplicate() = 0; // reference counting
	virtual void release() = 0;
	virtual ~audio_node() = default;
	virtual ma_node_base *get_ma_node() = 0;
	virtual audio_engine *get_engine() const = 0;
	virtual unsigned int get_input_bus_count() = 0;
	virtual unsigned int get_output_bus_count() = 0;
	virtual unsigned int get_input_channels(unsigned int bus) = 0;
	virtual unsigned int get_output_channels(unsigned int bus) = 0;
	virtual bool attach_output_bus(unsigned int output_bus, audio_node *destination, unsigned int destination_input_bus) = 0;
	virtual bool detach_output_bus(unsigned int bus) = 0;
	virtual bool detach_all_output_buses() = 0;
	virtual bool set_output_bus_volume(unsigned int bus, float volume) = 0;
	virtual float get_output_bus_volume(unsigned int bus) = 0;
	virtual bool set_state(ma_node_state state) = 0;
	virtual ma_node_state get_state() = 0;
	virtual bool set_state_time(ma_node_state state, unsigned long long time) = 0;
	virtual unsigned long long get_state_time(ma_node_state state) = 0;
	virtual ma_node_state get_state_by_time(unsigned long long global_time) = 0;
	virtual ma_node_state get_state_by_time_range(unsigned long long global_time_begin, unsigned long long global_time_end) = 0;
	virtual unsigned long long get_time() const = 0;
	virtual bool set_time(unsigned long long local_time) = 0;
};
class effect_node : public virtual audio_node {
	public:
	virtual void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) = 0;
	virtual unsigned int required_input_frame_count(unsigned int output_frame_count) const = 0;
};
class audio_engine : public virtual audio_node {
public:
	enum engine_flags {
		DURATIONS_IN_FRAMES = 1,  // If set, all durations possible will expect a value in PCM frames rather than milliseconds unless explicitly specified.
		NO_AUTO_START = 2,        // if set, audio_engine::start must be called after initialization.
		NO_DEVICE = 4,            // If set, audio_engine::read() must be used to receive raw audio samples from the engine instead.
		NO_CLIP = 8, // If set, disables miniaudio's sample clipping.
		PERCENTAGE_ATTRIBUTES = 16 // If this is set, attributes for sounds will be in percentages such as 100 instead of decimals such as 1.0, ecentially a multiplication by 100 for backwards compatibility or preference. This also causes sound.volume to work in db.
	};
	virtual ~audio_engine() = default;
	virtual int get_flags() const = 0;
	virtual int get_device() const = 0;
	virtual bool set_device(int device) = 0;
	virtual audio_node *get_endpoint() const = 0;
	virtual ma_engine *get_ma_engine() const = 0;
	virtual bool read(void *buffer, unsigned long long frame_count, unsigned long long *frames_read) = 0;
	virtual CScriptArray *read_script(unsigned long long frame_count) = 0;
	virtual void set_processing_callback(asIScriptFunction* cb) = 0;
	virtual asIScriptFunction* get_processing_callback() const = 0;
	virtual unsigned long long get_time() const override = 0;
	virtual bool set_time(unsigned long long time) override = 0; // depends on DURATIONS_IN_FRAMES flag.
	virtual unsigned long long get_time_in_frames() const = 0;
	virtual bool set_time_in_frames(unsigned long long time) = 0;
	virtual unsigned long long get_time_in_milliseconds() const = 0;
	virtual bool set_time_in_milliseconds(unsigned long long time) = 0;
	virtual int get_channels() const = 0;
	virtual int get_sample_rate() const = 0;
	virtual bool start() = 0;                  // Begins audio playback <ma_engine_start>, only needs to be called if NO_AUTO_START flag is set in engine construction or after stop is called.
	virtual bool stop() = 0;                   // Stops audio playback.
	virtual bool set_volume(float volume) = 0; // 0.0 to 1.0.
	virtual float get_volume() const = 0;
	virtual bool set_gain(float db) = 0;
	virtual float get_gain() const = 0;
	virtual unsigned int get_listener_count() const = 0;
	virtual int find_closest_listener(float x, float y, float z) const = 0;
	virtual int find_closest_listener_vector(const reactphysics3d::Vector3 &position) const = 0;
	virtual void set_listener_position(unsigned int index, float x, float y, float z) = 0;
	virtual void set_listener_position_vector(unsigned int index, const reactphysics3d::Vector3 &position) = 0;
	virtual reactphysics3d::Vector3 get_listener_position(unsigned int index) const = 0;
	virtual void set_listener_direction(unsigned int index, float x, float y, float z) = 0;
	virtual void set_listener_direction_vector(unsigned int index, const reactphysics3d::Vector3 &direction) = 0;
	virtual reactphysics3d::Vector3 get_listener_direction(unsigned int index) const = 0;
	virtual void set_listener_velocity(unsigned int index, float x, float y, float z) = 0;
	virtual void set_listener_velocity_vector(unsigned int index, const reactphysics3d::Vector3 &velocity) = 0;
	virtual reactphysics3d::Vector3 get_listener_velocity(unsigned int index) const = 0;
	virtual void set_listener_cone(unsigned int index, float inner_radians, float outer_radians, float outer_gain) = 0;
	virtual void get_listener_cone(unsigned int index, float *inner_radians, float *outer_radians, float *outer_gain) const = 0;
	virtual void set_listener_world_up(unsigned int index, float x, float y, float z) = 0;
	virtual void set_listener_world_up_vector(unsigned int index, const reactphysics3d::Vector3 &world_up) = 0;
	virtual reactphysics3d::Vector3 get_listener_world_up(unsigned int index) const = 0;
	virtual void set_listener_enabled(unsigned int index, bool enabled) = 0;
	virtual bool get_listener_enabled(unsigned int index) const = 0;
	virtual sound* play(const std::string& path, const reactphysics3d::Vector3& position, float volume, float pan, float pitch, mixer* mix, const pack_interface* pack_file, bool autoplay) = 0;
	virtual mixer *new_mixer() = 0;
	virtual sound *new_sound() = 0;
};
class audio_data_source : public virtual audio_node {
public:
	virtual ma_data_source* get_ma_data_source() const = 0;
	virtual unsigned int get_advised_read_frame_count() const = 0;
	virtual unsigned long long read(void* buffer, unsigned long long frame_count) = 0;
	virtual CScriptArray* read_script(unsigned long long frame_count) = 0;
	virtual unsigned long long skip_frames(unsigned long long frame_count) = 0;
	virtual float skip_milliseconds(float ms) = 0;
	virtual bool seek_frames(unsigned long long frame_index) = 0;
	virtual bool seek_milliseconds(float ms) = 0;
	virtual unsigned long long get_cursor_frames() const = 0;
	virtual float get_cursor_milliseconds() const = 0;
	virtual unsigned long long get_length_frames() const = 0;
	virtual float get_length_milliseconds() const = 0;
	virtual bool set_looping(bool looping) = 0;
	virtual bool get_looping() const = 0;
	virtual bool set_range(unsigned long long start_frame, unsigned long long end_frame) = 0;
	virtual void get_range(unsigned long long* start_frame, unsigned long long* end_frame) const = 0;
	virtual bool set_loop_point(unsigned long long start_frame, unsigned long long end_frame) = 0;
	virtual void get_loop_point(unsigned long long* start_frame, unsigned long long* end_frame) const = 0;
	virtual bool set_current(audio_data_source* new_current) = 0;
	virtual audio_data_source* get_current() const = 0;
	virtual bool set_next(audio_data_source* new_next) = 0;
	virtual audio_data_source* get_next() const = 0;
	virtual bool get_active() const = 0;
	virtual bool get_data_format(ma_format *format, unsigned int *channels, unsigned int *sample_rate) const = 0;
	virtual unsigned int get_channels() const = 0;
	virtual unsigned int get_sample_rate() const = 0;
};
class audio_ring_buffer : public virtual audio_data_source {
public:
	virtual void reset() = 0;
	virtual unsigned int get_advised_read_frame_count() const override = 0;
	virtual unsigned int write(const float* frames_in, unsigned int frame_count) = 0;
	virtual unsigned int write_script_array(CScriptArray* frames) = 0;
	virtual unsigned int write_script_memory_buffer(script_memory_buffer* frames) = 0;
	virtual unsigned int get_available_read() const = 0;
	virtual unsigned int get_available_write() const = 0;
	virtual unsigned int get_channels() const override = 0;
	virtual unsigned int get_sample_rate() const override = 0;
	static audio_ring_buffer* create(unsigned int channels, unsigned int size, audio_engine* e);
};
class audio_decoder : public virtual audio_data_source {
public:
	virtual bool open(const std::string& filename, const pack_interface* pack_file = nullptr, unsigned int sample_rate = 0, unsigned int channels = 0) = 0;
	virtual bool open_stream(datastream* ds, unsigned int sample_rate = 0, unsigned int channels = 0) = 0;
	virtual bool close() = 0;
	virtual unsigned int get_sample_rate() const = 0;
	virtual unsigned int get_channels() const = 0;
	static audio_decoder* create(audio_engine* e);
};
class audio_encoder : public virtual effect_node {
public:
	enum encoder_flags { ENCODER_OVERWRITE = 1 << 0, ENCODER_DEFAULTS = 1 << 31 };
	virtual unsigned int get_default_open_flags() const = 0;
	virtual bool open_file(const std::string& filename, unsigned int sample_rate, unsigned int channels, unsigned int flags = ENCODER_DEFAULTS) = 0;
	virtual bool open_stream(datastream* ds, unsigned int sample_rate, unsigned int channels, unsigned int flags = ENCODER_DEFAULTS) =0;
	virtual bool open_pull(unsigned int sample_rate, unsigned int channels, unsigned int flags = ENCODER_DEFAULTS) = 0;
	virtual bool close() = 0;
	virtual bool get_active() const = 0;
	virtual unsigned long long get_frames_written() const = 0;
	virtual unsigned int write(const float* frames_in, unsigned int frame_count) = 0;
	virtual unsigned int write_script_array(CScriptArray* frames) = 0;
	virtual unsigned int write_script_memory_buffer(script_memory_buffer* frames) = 0;
	virtual std::string read() = 0; // Only works in pull mode.
	virtual std::string get_format() const = 0;
	virtual unsigned int get_sample_rate() const = 0;
	virtual unsigned int get_channels() const = 0;
};
class audio_wav_encoder : public virtual audio_encoder {
public:
	enum wav_encoder_flags { WAV_U8 = 1 << 1, WAV_S16 = 1 << 2, WAV_S24 = 1 << 3, WAV_S32 = 1 << 4, WAV_F32 = 1 << 5 };
	virtual ma_format get_wav_format() const = 0;
	static audio_wav_encoder* create(audio_engine* e);
};
class audio_opus_encoder : public virtual audio_encoder {
public:
	virtual int get_bitrate() const = 0;
	virtual bool set_bitrate(int bitrate) = 0;
	virtual int get_complexity() const = 0;
	virtual bool set_complexity(int complexity) = 0;
	virtual int get_signal_type() const = 0;
	virtual bool set_signal_type(int signal_type) = 0;
	virtual int get_application() const = 0;
	virtual bool set_application(int application) = 0;
	virtual int get_packet_loss_percent() const = 0;
	virtual bool set_packet_loss_percent(int percent) = 0;
	virtual bool get_vbr() const = 0;
	virtual bool set_vbr(bool enabled) = 0;
	virtual bool get_cvbr() const = 0;
	virtual bool set_cvbr(bool enabled) = 0;
	virtual bool get_dtx() const = 0;
	virtual bool set_dtx(bool enabled) = 0;
	static audio_opus_encoder* create(audio_engine* e);
};
class sound_shape {
	// This facility allows sounds to be attached to any arbitrary shape for positioning.
	// When a shape is attached to a sound or mixer, set_position_3d exhibits different functionality. if sound_shape::contains returns true based on whether listener_position is within the shape, spatialization is disabled on the sound. Otherwise, the sound's position is set to the sound_position vector passed to the contains callback, the callback can alter it to point at the nearest edge of the shape if needed and should be overridden by subclasses. Do not override is_in_shape as it's a base function which calls contains.
	// We keep track of the original sound position before it was mutated so that sound::get_position_3d works as expected, as well as the original ref handle the scripter passed to sound::set_shape so that sound::get_shape returns something valid.
	mutable int refcount;
	CScriptHandle* shape;
	reactphysics3d::Vector3 position;
public:
	mixer* connected_sound; // If set, this object is not threadsafe.
	sound_shape(CScriptHandle* script_shape = nullptr) : refcount(1), shape(script_shape), connected_sound(nullptr) {}
	void duplicate() const { asAtomicInc(refcount); }
	void release() const { if (asAtomicDec(refcount) < 1) delete this; }
	void set_shape(CScriptHandle* script_shape) { shape = script_shape; }
	CScriptHandle* get_shape() const { return shape; }
	void set_position(const reactphysics3d::Vector3& new_position) { position = new_position; }
	reactphysics3d::Vector3 get_position() const { return position; }
	bool is_in_shape(const reactphysics3d::Vector3& listener_position, reactphysics3d::Vector3& sound_position) { position = sound_position; return contains(listener_position, sound_position); }
	virtual bool contains(const reactphysics3d::Vector3&  listener_position, reactphysics3d::Vector3& sound_position) { return sound_position == listener_position; }
};
class mixer : public virtual audio_node {
public:
	virtual void duplicate() = 0; // reference counting
	virtual void release() = 0;
	virtual audio_engine *get_engine() const = 0;
	virtual ma_sound *get_ma_sound() const = 0;
	virtual bool set_mixer(mixer *mix) = 0;
	virtual mixer *get_mixer() const = 0;
	virtual void set_3d_panner(int panner_id) = 0;
	virtual int get_3d_panner() const = 0;
	virtual void set_3d_attenuator(int attenuator_id) = 0;
	virtual int get_3d_attenuator() const = 0;
	virtual int get_preferred_3d_panner() const = 0;
	virtual int get_preferred_3d_attenuator() const = 0;
	virtual void set_hrtf(bool enabled) = 0;
	virtual bool get_hrtf() const = 0;
	virtual bool set_shape(CScriptHandle* shape) = 0;
	virtual CScriptHandle* get_shape() const = 0;
	virtual sound_shape* get_shape_object() const = 0;
	virtual void set_reverb3d(reverb3d* verb) = 0;
	virtual void set_reverb3d_at(reverb3d* verb, audio_spatializer_reverb3d_placement placement) = 0;
	virtual reverb3d* get_reverb3d() const = 0;
	virtual splitter_node* get_reverb3d_attachment() const = 0;
	virtual audio_spatializer_reverb3d_placement get_reverb3d_placement() const = 0;
	virtual audio_node_chain* get_effects_chain() = 0;
	virtual audio_node_chain* get_internal_node_chain() = 0;
	virtual bool get_spatialization_parameters(audio_spatialization_parameters& params) = 0;
	virtual bool play(bool reset_loop_state = true) = 0;
	virtual bool play_looped() = 0;
	virtual bool stop() = 0;
	virtual void set_volume(float volume) = 0;
	virtual float get_volume() const = 0;
	virtual void set_pan(float pan) = 0;
	virtual float get_pan() const = 0;
	virtual void set_pan_mode(ma_pan_mode mode) = 0;
	virtual ma_pan_mode get_pan_mode() const = 0;
	virtual void set_pitch(float pitch) = 0;
	virtual float get_pitch() const = 0;
	virtual void set_spatialization_enabled(bool enabled) = 0;
	virtual bool get_spatialization_enabled() const = 0;
	virtual void set_pinned_listener(unsigned int index) = 0;
	virtual unsigned int get_pinned_listener() const = 0;
	virtual unsigned int get_listener() const = 0;
	virtual reactphysics3d::Vector3 get_direction_to_listener() const = 0;
	virtual float get_distance_to_listener() const = 0;
	virtual void set_position_3d(float x, float y, float z) = 0;
	virtual void set_position_3d_vector(const reactphysics3d::Vector3& position) = 0;
	virtual reactphysics3d::Vector3 get_position_3d() const = 0;
	virtual void set_direction(float x, float y, float z) = 0;
	virtual void set_direction_vector(const reactphysics3d::Vector3& direction) = 0;
	virtual reactphysics3d::Vector3 get_direction() const = 0;
	virtual void set_velocity(float x, float y, float z) = 0;
	virtual void set_velocity_vector(const reactphysics3d::Vector3& velocity) = 0;
	virtual reactphysics3d::Vector3 get_velocity() const = 0;
	virtual void set_positioning(ma_positioning positioning) = 0;
	virtual ma_positioning get_positioning() const = 0;
	virtual void set_rolloff(float rolloff) = 0;
	virtual float get_rolloff() const = 0;
	virtual void set_min_gain(float gain) = 0;
	virtual float get_min_gain() const = 0;
	virtual void set_max_gain(float gain) = 0;
	virtual float get_max_gain() const = 0;
	virtual void set_min_distance(float distance) = 0;
	virtual float get_min_distance() const = 0;
	virtual void set_max_distance(float distance) = 0;
	virtual float get_max_distance() const = 0;
	virtual void set_cone(float inner_radians, float outer_radians, float outer_gain) = 0;
	virtual void get_cone(float *inner_radians, float *outer_radians, float *outer_gain) const = 0;
	virtual void set_doppler_factor(float factor) = 0;
	virtual float get_doppler_factor() const = 0;
	virtual void set_directional_attenuation_factor(float factor) = 0;
	virtual float get_directional_attenuation_factor() const = 0;
	virtual void set_fade(float start_volume, float end_volume, ma_uint64 length) = 0; // depends on DURATIONS_IN_FRAMES flag in parent engine
	virtual void set_fade_in_frames(float start_volume, float end_volume, ma_uint64 frames) = 0;
	virtual void set_fade_in_milliseconds(float start_volume, float end_volume, ma_uint64 milliseconds) = 0;
	virtual float get_current_fade_volume() const = 0;
	virtual void set_start_time(ma_uint64 absolute_time) = 0; // DURATIONS_IN_FRAMES
	virtual void set_start_time_in_frames(ma_uint64 absolute_time) = 0;
	virtual void set_start_time_in_milliseconds(ma_uint64 absolute_time) = 0;
	virtual void set_stop_time(ma_uint64 absolute_time) = 0; // DURATIONS_IN_FRAMES
	virtual void set_stop_time_in_frames(ma_uint64 absolute_time) = 0;
	virtual void set_stop_time_in_milliseconds(ma_uint64 absolute_time) = 0;
	virtual ma_uint64 get_time() const = 0; // DURATIONS_IN_FRAMES
	virtual ma_uint64 get_time_in_frames() const = 0;
	virtual ma_uint64 get_time_in_milliseconds() const = 0;
	virtual bool get_playing() const = 0;
};
class sound : public virtual mixer {
public:
	/**
	 * The lowest level method to load from the sound service; everything uses this.
	 * Arguments:
	 * const std::string &filename: the name of an asset on disk, in your archive, etc.
	 * const size_t protocol_slot = 0: A slot number previously returned from sound_service::register_protocol.
	 * directive_t protocol_directive = nullptr: an arbitrary piece of data for your protocol to use while fetching the asset (such as which packed archive to fetch from).
	 * size_t filter_slot = 0: a slot number previously returned from sound_service::register_filter.
	 * directive_t filter_directive = nullptr: an arbitrary piece of data for your filter to use (such as a decryption key).
	 * ma_uint32 flags = 0: MiniAudio specific flags that govern how MiniAudio will load the data.
	 * Remarks:
	 * Directive_t is simply short for std::shared_ptr <void>
	 * The sound service does not retain your directives after this method returns, so it's okay to allocate them on the stack.
	 * A warning to protocol and filter developers: never store directive_t handles.
	 * Also to those implementing custom sound methods: review the MiniAudio documentation to be sure you understand what the flags passed to ma_sound_init_from_file do. Some data sources, by their nature, only make sense in combination with certain flags. For example, MA_SOUND_FLAG_STREAM would be inappropriate for a string source unless you can guarantee it won't go away or be modified by script during playback.
	 */
	virtual bool load_special(const std::string &filename, const size_t protocol_slot = 0, directive_t protocol_directive = nullptr, const size_t filter_slot = 0, directive_t filter_directive = nullptr, ma_uint32 ma_flags = MA_SOUND_FLAG_DECODE) = 0;
	virtual bool load(const std::string &filename, const pack_interface *pack_file = nullptr) = 0;
	virtual bool stream(const std::string &filename, const pack_interface *pack_file = nullptr) = 0;
	virtual bool stream_url(const std::string &url) = 0;
	virtual bool load_string(const std::string &data) = 0;
	virtual bool load_string_async(const std::string &data) = 0; // Makes an extra copy. Good for short sounds that need to start immediately. Used by speak_to_sound.
	virtual bool load_memory(const void *buffer, unsigned int size) = 0;
	virtual bool is_load_completed() const = 0;
	/**
	 * Create a wav file in memory from a raw PCM buffer.
	 * Used internally by TTS.
	 * Format is the format of the input data; it will not be converted.
	 * Output must be preallocated and must be at least 44 bytes larger than the input buffer.
	 */
	static bool pcm_to_wav(const void *buffer, unsigned int size, ma_format format, int samplerate, int channels, void *output);
	virtual bool load_pcm(void *buffer, unsigned int size_in_bytes, ma_format format, int samplerate, int channels) = 0;
	virtual bool load_pcm_script_array(CScriptArray *buffer, int samplerate, int channels) = 0;
	virtual bool load_pcm_script_memory_buffer(script_memory_buffer*buffer, int samplerate, int channels) = 0;
	virtual bool stream_pcm(const void* data, unsigned int size_in_frames, ma_format format = ma_format_unknown, unsigned int sample_rate = 0, unsigned int channels = 0, unsigned int buffer_size = 0) = 0;
	virtual bool stream_pcm_script_array(CScriptArray *buffer, unsigned int samplerate, unsigned int channels, unsigned int buffer_size = 0) = 0;
	virtual bool stream_pcm_script_memory_buffer(script_memory_buffer*buffer, unsigned int samplerate, unsigned int channels, unsigned int buffer_size = 0) = 0;
	virtual bool open(audio_data_source* datasource) = 0;
	virtual bool close() = 0;
	virtual void set_autoclose(bool enabled = true) = 0;
	virtual bool get_autoclose() const = 0;
	virtual const std::string &get_loaded_filename() const = 0;
	virtual audio_data_source* get_datasource() const = 0;
	virtual bool get_active() = 0;
	virtual bool get_paused() = 0;
	virtual bool play_wait() = 0;
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
	virtual bool seek(unsigned long long position) = 0; // DURATIONS_IN_FRAMES
	virtual bool seek_in_frames(unsigned long long position) = 0;
	virtual bool seek_in_milliseconds(unsigned long long position) = 0;
	virtual unsigned long long get_position() = 0; // DURATIONS_IN_FRAMES
	virtual unsigned long long get_position_in_frames() = 0;
	virtual unsigned long long get_position_in_milliseconds() = 0;
	virtual unsigned long long get_length() = 0; // DURATIONS_IN_FRAMES
	virtual unsigned long long get_length_in_frames() = 0;
	virtual unsigned long long get_length_in_milliseconds() = 0;
	virtual bool get_data_format(ma_format *format, unsigned int *channels, unsigned int *sample_rate) = 0;
	// A completely pointless API here, but needed for code that relies on legacy BGT includes. Always returns 0.
	virtual double get_pitch_lower_limit() = 0;
};
class microphone : public virtual audio_ring_buffer {
public:
	virtual bool set_state(ma_node_state state) override = 0;
	virtual bool set_device(int device) = 0;
	virtual int get_device() const = 0;
	virtual void set_volume(float volume) = 0;
	virtual float get_volume() const = 0;
	static microphone* create(int device, audio_engine* engine);
};

audio_engine *new_audio_engine(int flags, int sample_rate = 0, int channels = 0);
mixer *new_mixer(audio_engine *engine);
sound *new_sound(audio_engine *engine);
sound* new_global_sound();
void RegisterSoundsystem(asIScriptEngine *engine);
