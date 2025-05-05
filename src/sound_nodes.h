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
#include "sound.h"

class audio_node_impl : public virtual audio_node {
protected:
	ma_node_base* node; // Must be set by subclasses
	audio_engine *engine;
	int refcount;
public:
	audio_node_impl() : audio_node(), node(nullptr), refcount(1) {
		if (!init_sound()) throw std::runtime_error("sound system was not initialized");
	}
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

bool set_global_hrtf(bool enabled);
bool get_global_hrtf();
void set_sound_position_changed(); // Indicates to all hrtf nodes that they should update their positions, should be set if a listener moves.

class phonon_binaural_node : public virtual audio_node {
	public:
	static phonon_binaural_node* create(audio_engine* engine, int channels, int sample_rate, int frame_size = 0);
	virtual void set_direction(float x, float y, float z, float distance) = 0;
	virtual void set_direction_vector(const reactphysics3d::Vector3& direction, float distance) = 0;
	virtual void set_spatial_blend_max_distance(float max_distance) = 0;
};
class mixer_monitor_node : public virtual audio_node {
	public:
	static mixer_monitor_node* create(mixer* m);
	virtual void set_position_changed() = 0;
};
class splitter_node : public virtual audio_node {
	public:
	static splitter_node* create(audio_engine* engine, int channels);
};
