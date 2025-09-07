/* sound_nodes.h - audio nodes header
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

#include <exception>
#include <angelscript.h> // asAtomic
#include <miniaudio_phonon.h>
#include <phonon.h>
#include <unordered_map>
#include "sound.h"

class audio_node_impl : public virtual audio_node {
protected:
	ma_node_base* node; // Must be set by subclasses
	audio_engine *engine;
	int refcount;
public:
	audio_node_impl(ma_node_base *node, audio_engine *engine) : audio_node(), node(node), engine(engine), refcount(1) {
		if (!init_sound()) throw std::runtime_error("sound system was not initialized");
	}
	void duplicate() { asAtomicInc(refcount); }
	void release() {
		if (asAtomicDec(refcount) < 1)
			delete this;
	}
	audio_engine *get_engine() const { return engine; }
	ma_node_base *get_ma_node() { return node; }
	unsigned int get_input_bus_count() { return node ? ma_node_get_input_bus_count(node) : 0; }
	unsigned int get_output_bus_count() { return node ? ma_node_get_output_bus_count(node) : 0; }
	unsigned int get_input_channels(unsigned int bus) { return node ? ma_node_get_input_channels(node, bus) : 0; }
	unsigned int get_output_channels(unsigned int bus) { return node ? ma_node_get_output_channels(node, bus) : 0; }
	bool attach_output_bus(unsigned int output_bus, audio_node *destination, unsigned int destination_input_bus) { return node ? (g_soundsystem_last_error = ma_node_attach_output_bus(node, output_bus, destination->get_ma_node(), destination_input_bus)) == MA_SUCCESS : false; }
	bool detach_output_bus(unsigned int bus) { return node ? (g_soundsystem_last_error = ma_node_detach_output_bus(node, bus)) == MA_SUCCESS : false; }
	bool detach_all_output_buses() { return node ? (g_soundsystem_last_error = ma_node_detach_all_output_buses(node)) == MA_SUCCESS : false; }
	bool set_output_bus_volume(unsigned int bus, float volume) { return node ? (g_soundsystem_last_error = ma_node_set_output_bus_volume(node, bus, volume)) == MA_SUCCESS : false; }
	float get_output_bus_volume(unsigned int bus) { return node ? ma_node_get_output_bus_volume(node, bus) : 0; }
	bool set_state(ma_node_state state) { return node ? (g_soundsystem_last_error = ma_node_set_state(node, state)) == MA_SUCCESS : false; }
	ma_node_state get_state() { return node ? ma_node_get_state(node) : ma_node_state_stopped; }
	bool set_state_time(ma_node_state state, unsigned long long time) { return node ? (g_soundsystem_last_error = ma_node_set_state_time(node, state, time)) == MA_SUCCESS : false; }
	unsigned long long get_state_time(ma_node_state state) { return node ? ma_node_get_state_time(node, state) : static_cast<unsigned long long>(ma_node_state_stopped); }
	ma_node_state get_state_by_time(unsigned long long global_time) { return node ? ma_node_get_state_by_time(node, global_time) : ma_node_state_stopped; }
	ma_node_state get_state_by_time_range(unsigned long long global_time_begin, unsigned long long global_time_end) { return node ? ma_node_get_state_by_time_range(node, global_time_begin, global_time_end) : ma_node_state_stopped; }
	unsigned long long get_time() { return node ? ma_node_get_time(node) : 0; }
	bool set_time(unsigned long long local_time) { return node ? (g_soundsystem_last_error = ma_node_set_time(node, local_time)) == MA_SUCCESS : false; }
};

class effect_node : public virtual audio_node {
	public:
	virtual void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) = 0;
	virtual unsigned int required_input_frame_count(unsigned int output_frame_count) const = 0;
};

class passthrough_node : public virtual audio_node {
	public:
	static passthrough_node* create(audio_engine* engine);
};

// When nodes are added or removed from a node_chain, they are automatically reattached as needed.
class audio_node_chain : public virtual passthrough_node {
public:
	virtual bool attach_output_bus(unsigned int bus_index, audio_node* node, unsigned int input_bus_index) override = 0;
	virtual bool detach_output_bus(unsigned int bus_index) override = 0;
	virtual bool detach_all_output_buses() override = 0;
	virtual bool add_node(audio_node* node, audio_node* after = nullptr, unsigned int input_bus_index = 0) = 0;
	virtual bool add_node_at(audio_node* node, int after = -1, unsigned int input_bus_index = 0) = 0;
	virtual bool remove_node(audio_node* node) = 0;
	virtual bool remove_node_at(unsigned int index) = 0;
	virtual bool clear(bool detach_nodes = true) = 0;
	virtual void set_endpoint(audio_node* endpoint, unsigned int input_bus_index = 0) = 0;
	virtual audio_node* get_endpoint() const = 0;
	virtual audio_node* first() const = 0;
	virtual audio_node* last() const = 0;
	virtual audio_node* operator[](unsigned int index) const = 0;
	virtual int index_of(audio_node* node) const = 0;
	virtual unsigned int get_node_count() const = 0;
	static audio_node_chain* create(audio_node* source = nullptr, audio_node* endpoint = nullptr, audio_engine* engine = nullptr);
};

bool set_global_hrtf(bool enabled);
bool get_global_hrtf();

class phonon_binaural_node : public virtual audio_node {
	public:
	static phonon_binaural_node* create(audio_engine* engine, int channels, int sample_rate, int frame_size = 0);
	virtual void set_direction(float x, float y, float z, float distance) = 0;
	virtual void set_direction_vector(const reactphysics3d::Vector3& direction, float distance) = 0;
	virtual void set_spatial_blend_max_distance(float max_distance) = 0;
};
class splitter_node : public virtual audio_node {
	public:
	static splitter_node* create(audio_engine* engine, int channels);
};
class low_pass_filter_node : public virtual audio_node {
public:
	virtual void set_cutoff_frequency(double freq) = 0;
	virtual double get_cutoff_frequency() const = 0;
	virtual void set_order(unsigned int order) = 0;
	virtual unsigned int get_order() const = 0;
	static low_pass_filter_node* create(double cutoff_frequency, unsigned int order, audio_engine* engine);
};
class high_pass_filter_node : public virtual audio_node {
public:
	virtual void set_cutoff_frequency(double freq) = 0;
	virtual double get_cutoff_frequency() const = 0;
	virtual void set_order(unsigned int order) = 0;
	virtual unsigned int get_order() const = 0;
	static high_pass_filter_node* create(double cutoff_frequency, unsigned int order, audio_engine* engine);
};
class band_pass_filter_node : public virtual audio_node {
public:
	virtual void set_cutoff_frequency(double freq) = 0;
	virtual double get_cutoff_frequency() const = 0;
	virtual void set_order(unsigned int order) = 0;
	virtual unsigned int get_order() const = 0;
	static band_pass_filter_node* create(double cutoff_frequency, unsigned int order, audio_engine* engine);
};
class notch_filter_node : public virtual audio_node {
public:
	virtual void set_q(double q) = 0;
	virtual double get_q() const = 0;
	virtual void set_frequency(double freq) = 0;
	virtual double get_frequency() const = 0;
	static notch_filter_node* create(double q, double frequency, audio_engine* engine);
};
class peak_filter_node : public virtual audio_node {
public:
	virtual void set_gain(double gain) = 0;
	virtual double get_gain() const = 0;
	virtual void set_q(double q) = 0;
	virtual double get_q() const = 0;
	virtual void set_frequency(double freq) = 0;
	virtual double get_frequency() const = 0;
	static peak_filter_node* create(double gain_db, double q, double frequency, audio_engine* engine);
};
class low_shelf_filter_node : public virtual audio_node {
public:
	virtual void set_gain(double gain) = 0;
	virtual double get_gain() const = 0;
	virtual void set_q(double q) = 0;
	virtual double get_q() const = 0;
	virtual void set_frequency(double freq) = 0;
	virtual double get_frequency() const = 0;
	static low_shelf_filter_node* create(double gain_db, double q, double frequency, audio_engine* engine);
};
class high_shelf_filter_node : public virtual audio_node {
public:
	virtual void set_gain(double gain) = 0;
	virtual double get_gain() const = 0;
	virtual void set_q(double q) = 0;
	virtual double get_q() const = 0;
	virtual void set_frequency(double freq) = 0;
	virtual double get_frequency() const = 0;
	static high_shelf_filter_node* create(double gain_db, double q, double frequency, audio_engine* engine);
};
class delay_node : public virtual audio_node {
public:
	virtual void set_wet(float wet) = 0;
	virtual float get_wet() const = 0;
	virtual void set_dry(float dry) = 0;
	virtual float get_dry() const = 0;
	virtual void set_decay(float decay) = 0;
	virtual float get_decay() const = 0;
	static delay_node* create(unsigned int delay_in_frames, float decay, audio_engine* engine);
};
class freeverb_node : public virtual audio_node {
	public:
	virtual void set_room_size(float size) = 0;
	virtual float get_room_size() const = 0;
	virtual void set_damping(float damping) = 0;
	virtual float get_damping() const = 0;
	virtual void set_width(float width) = 0;
	virtual float get_width() const = 0;
	virtual void set_wet(float wet) = 0;
	virtual float get_wet() const = 0;
	virtual void set_dry(float dry) = 0;
	virtual float get_dry() const = 0;
	virtual void set_input_width(float width) = 0;
	virtual float get_input_width() const = 0;
	virtual void set_frozen(bool frozen) = 0;
	virtual bool get_frozen() const = 0;
	static freeverb_node* create(audio_engine* engine, int channels);
};
class reverb3d : public virtual passthrough_node {
public:
	virtual void set_reverb(audio_node* verb) = 0;
	virtual audio_node* get_reverb() const = 0;
	virtual void set_mixer(mixer* mix) = 0;
	virtual mixer* get_mixer() const = 0;
	virtual void set_min_volume(float min_volume) = 0;
	virtual float get_min_volume() const = 0;
	virtual void set_max_volume(float max_volume) = 0;
	virtual float get_max_volume() const = 0;
	virtual void set_max_volume_distance(float distance) = 0;
	virtual float get_max_volume_distance() const = 0;
	virtual void set_max_audible_distance(float distance) = 0;
	virtual float get_max_audible_distance() const = 0;
	virtual void set_volume_curve(float volume_curve) = 0;
	virtual float get_volume_curve() const = 0;
	virtual float get_volume_at(float distance) const = 0;
	virtual splitter_node* create_attachment(audio_node* dry_input = nullptr, audio_node* dry_output = nullptr) = 0;
	static reverb3d* create(audio_node* reverb, mixer* destination = nullptr, audio_engine* e = g_audio_engine);
};
class plugin_node : public virtual audio_node {
public:
	virtual audio_plugin_node_interface* get_plugin_interface() const = 0;
	virtual void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) = 0;
	static plugin_node* create(audio_plugin_node_interface* impl, unsigned char input_bus_count, unsigned char output_bus_count, unsigned int flags, audio_engine* engine);
};

enum audio_spatializer_distance_model {
	linear,
	inverse,
	exponential
};
struct audio_spatialization_parameters {
	float listener_x;
	float listener_y;
	float listener_z;
	float listener_direction_x;
	float listener_direction_y;
	float listener_direction_z;
	float listener_distance;
	float sound_x;
	float sound_y;
	float sound_z;
	float min_distance;
	float max_distance;
	float min_volume;
	float max_volume;
	float rolloff;
	float directional_attenuation_factor;
	audio_spatializer_distance_model distance_model;
};
enum audio_spatializer_reverb3d_placement {
	prepan,
	postpan,
	postattenuate
};

class spatializer_component_node;

class audio_spatializer : public virtual audio_node_chain {
public:
	virtual void set_panner(spatializer_component_node* new_panner) = 0;
	virtual spatializer_component_node* get_panner() const = 0;
	virtual void set_attenuator(spatializer_component_node* new_attenuator) = 0;
	virtual spatializer_component_node* get_attenuator() const = 0;
	virtual void set_panner_by_id(int panner_id) = 0;
	virtual void set_attenuator_by_id(int attenuator_id) = 0;
	virtual int get_current_panner_id() const = 0;
	virtual int get_current_attenuator_id() const = 0;
	virtual int get_preferred_panner_id() const = 0;
	virtual int get_preferred_attenuator_id() const = 0;
	virtual void set_rolloff(float rolloff) = 0;
	virtual float get_rolloff() const = 0;
	virtual void set_directional_attenuation_factor(float factor) = 0;
	virtual float get_directional_attenuation_factor() const = 0;
	virtual void set_reverb3d(reverb3d* new_reverb, audio_spatializer_reverb3d_placement placement = postpan) = 0;
	virtual reverb3d* get_reverb3d() const = 0;
	virtual splitter_node* get_reverb3d_attachment() const = 0;
	virtual audio_spatializer_reverb3d_placement get_reverb3d_placement() const = 0;
	virtual mixer* get_mixer() const = 0;
	virtual bool get_parameters(audio_spatialization_parameters& params) = 0;
	virtual void on_panner_enabled_changed(int panner_id, bool enabled) = 0;
	virtual void on_attenuator_enabled_changed(int attenuator_id, bool enabled) = 0;
	static audio_spatializer* create(mixer* mixer, audio_engine* engine = nullptr);
};

class spatializer_component_node : public virtual audio_node {
public:
	virtual audio_spatializer* get_spatializer() const = 0;
	virtual void process(const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) = 0;
};

class basic_panner : public virtual spatializer_component_node {
public:
	static spatializer_component_node* create(audio_spatializer* spatializer, audio_engine* engine);
};

class phonon_hrtf_panner : public virtual spatializer_component_node {
public:
	static spatializer_component_node* create(audio_spatializer* spatializer, audio_engine* engine);
};

class basic_attenuator : public virtual spatializer_component_node {
public:
	static spatializer_component_node* create(audio_spatializer* spatializer, audio_engine* engine);
};

class phonon_attenuator : public virtual spatializer_component_node {
public:
	static spatializer_component_node* create(audio_spatializer* spatializer, audio_engine* engine);
};

typedef spatializer_component_node* (*spatializer_component_node_factory)(audio_spatializer*, audio_engine*);

struct spatializer_component {
	spatializer_component_node_factory factory;
	bool enabled;
};

int register_audio_panner(spatializer_component_node_factory factory, bool default_enabled = true);
int register_audio_attenuator(spatializer_component_node_factory factory, bool default_enabled = true);
spatializer_component_node* create_audio_panner(int id, audio_spatializer* spatializer, audio_engine* engine);
spatializer_component_node* create_audio_attenuator(int id, audio_spatializer* spatializer, audio_engine* engine);
void sound_set_default_3d_panner(int panner_id);
int sound_get_default_3d_panner();
void sound_set_default_3d_attenuator(int attenuator_id);
int sound_get_default_3d_attenuator();
void set_audio_panner_enabled(int id, bool enabled);
void set_audio_attenuator_enabled(int id, bool enabled);
bool get_audio_panner_enabled(int id);
bool get_audio_attenuator_enabled(int id);
bool sound_set_spatialization(int panner, int attenuator, bool disable_previous = false, bool set_default = true);


extern int g_audio_basic_panner;
extern int g_audio_phonon_hrtf_panner;
extern int g_audio_basic_attenuator;
extern int g_audio_phonon_attenuator;
