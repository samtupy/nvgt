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

#ifndef sound_h
#define sound_h
#pragma once
#include <atomic>
#include <unordered_set>
#include <vector>
#include <angelscript.h>
#include <bass.h>
#include <bass_fx.h>
#include <phonon.h>
#include <thread.h>
#include <verblib.h>
#include "misc_functions.h"
#include "pack.h"

BOOL init_sound(DWORD dev = -1);
BOOL shutdown_sound();

class sound;
class mixer;

typedef struct {
	unsigned char* data;
	DWORD size;
	int ref;
	QWORD t;
	std::string fn;
} sound_preload;

typedef struct {
	pack* p;
	pack_stream* s;
	sound* snd;
} packed_sound;

typedef struct hstream_entry {
	hstream_entry* p;
	DWORD channel;
	hstream_entry* n;
} hstream_entry;

typedef struct {
	HFX hfx;
	DWORD type;
	char id[32];
} mixer_effect;

typedef struct {
	verblib v;
	bool inside;
} sound_reverb;

class sound_base;
class sound_environment {
	IPLScene scene;
	std::vector<sound_base*> attached;
	std::unordered_map<std::string, IPLMaterial> materials;
	bool scene_needs_commit = false;
public:
	int ref_count;
	IPLSimulator sim;
	IPLSimulationSharedInputs sim_inputs;
	float listener_x, listener_y, listener_z, listener_rotation;
	bool listener_modified;
	sound_environment();
	~sound_environment();
	void add_ref();
	void release();
	bool add_material(const std::string& name, float absorption_low, float absorption_mid, float absorption_high, float scattering, float transmission_low, float transmission_mid, float transmission_high, bool replace_if_existing = false);
	bool add_box(const std::string& material, float minx, float maxx, float miny, float maxy, float minz, float maxz);
	mixer* new_mixer();
	sound* new_sound();
	bool attach(sound_base* s);
	bool detach(sound_base* s);
	void update();
	void set_listener(float x, float y, float z, float rotation);
};

class mixer;
class sound_base {
protected:
	int RefCount;
public:
	IPLBinauralEffect hrtf_effect;
	IPLSource source;
	IPLDirectEffect direct_effect;
	IPLReflectionEffect reflection_effect;
	IPLAmbisonicsDecodeEffect reflection_decode_effect;
	HDSP pos_effect;
	mixer* output_mixer;
	mixer* parent_mixer;
	sound_environment* env;
	BOOL use_hrtf;
	float x;
	float y;
	float z;
	float listener_x;
	float listener_y;
	float listener_z;
	float last_x;
	float last_y;
	float last_z;
	float last_rotation;
	float rotation;
	float pan_step;
	float volume_step;
	DWORD channel;
	hstream_entry* store_channel;
	sound_base() : env(NULL), source(NULL), direct_effect(NULL), reflection_effect(NULL), reflection_decode_effect(NULL) {}
	virtual void AddRef();
	virtual void Release();
	void set_hrtf(BOOL enable) {
		use_hrtf = enable;
	}
	BOOL set_position(float listener_x, float listener_y, float listener_z, float sound_x, float sound_y, float sound_z, float rotation, float pan_step, float volume_step);
};

class sound : public sound_base {
	char loaded_filename[MAX_PATH];
	float pitch;
	float length;
public:
	BASS_CHANNELINFO channel_info;
	sound_preload* preload_ref;
	asIScriptFunction* len_callback;
	asIScriptFunction* read_callback;
	asIScriptFunction* seek_callback;
	asIScriptFunction* close_callback;
	std::string callback_data;
	BOOL script_loading;
	thread_mutex_t close_mutex;
	std::vector<BYTE> push_prebuff;
	std::string* memstream;
	DWORD memstream_size;
	DWORD memstream_pos;
	bool memstream_legacy_encrypt;
	sound();
	~sound();
	void Release();
	BOOL load(const std::string& filename, pack* containing_pack = NULL, BOOL allow_preloads = TRUE);
	BOOL load_script(asIScriptFunction* close, asIScriptFunction* len, asIScriptFunction* read, asIScriptFunction* seek, const std::string& data, const std::string& preload_filename = "");
	BOOL load_memstream(std::string& data, DWORD size, const std::string& preload_filename = "", bool legacy_encrypt = false);
	BOOL load_url(const std::string& url);
	BOOL stream(const std::string& filename, pack* containing_pack = NULL) {
		return load(filename, containing_pack, FALSE);
	}
	BOOL push_memory(unsigned char* buffer, DWORD length, BOOL stream_end = FALSE, int pcm_rate = 0, int pcm_chans = 0);
	BOOL push_string(const std::string& buffer, BOOL stream_end = FALSE, int pcm_rate = 0, int pcm_chans = 0);
	BOOL postload(const std::string& filename = std::string(""));
	BOOL close();
	int set_fx(std::string& fx, int idx = -1);
	void set_length(float len) {
		if (len >= 0) length = len;
	}
	BOOL set_mixer(mixer* m);
	BOOL play();
	BOOL play_wait();
	BOOL play_looped();
	BOOL pause();
	BOOL seek(float offset);
	BOOL stop();
	BOOL is_active();
	BOOL is_paused();
	BOOL is_playing();
	BOOL is_sliding();
	BOOL is_pan_sliding();
	BOOL is_pitch_sliding();
	BOOL is_volume_sliding();
	float get_length();
	float get_length_ms();
	float get_position();
	float get_position_ms();
	float get_pan();
	float get_pitch();
	float get_volume();
	float get_pan_alt();
	float get_pitch_alt();
	float get_volume_alt();
	BOOL set_pan(float pan);
	BOOL slide_pan(float pan, DWORD time);
	BOOL set_pitch(float pitch);
	BOOL slide_pitch(float pitch, DWORD time);
	BOOL set_volume(float volume);
	BOOL slide_volume(float volume, DWORD time);
	BOOL set_pan_alt(float pan);
	BOOL slide_pan_alt(float pan, DWORD time);
	BOOL set_pitch_alt(float pitch);
	BOOL slide_pitch_alt(float pitch, DWORD time);
	BOOL set_volume_alt(float volume);
	BOOL slide_volume_alt(float volume, DWORD time);
};

class mixer : public sound_base {
	std::unordered_set<mixer*> mixers;
	std::unordered_set<sound*> sounds;
	std::vector<mixer_effect> effects;
	mixer* parent_mixer;
	int get_effect_index(const char* id);
public:
	mixer(mixer* parent = NULL, BOOL for_single_sound = FALSE, BOOL for_decode = FALSE, BOOL floatingpoint = TRUE);
	~mixer();
	void AddRef();
	void Release();
	int get_data(const unsigned char* buffer, int bufsize);
	BOOL add_mixer(mixer* m);
	BOOL remove_mixer(mixer* m, BOOL internal = FALSE);
	BOOL add_sound(sound& s, BOOL internal = FALSE);
	BOOL remove_sound(sound& s, BOOL internal = FALSE);
	bool set_impulse_response(const std::string& response, float dry, float wet);
	int set_fx(std::string& fx, int idx = -1);
	BOOL set_mixer(mixer* m);
	BOOL is_sliding();
	BOOL is_pan_sliding();
	BOOL is_pitch_sliding();
	BOOL is_volume_sliding();
	float get_pan();
	float get_pitch();
	float get_volume();
	float get_pan_alt();
	float get_pitch_alt();
	float get_volume_alt();
	BOOL set_pan(float pan);
	BOOL slide_pan(float pan, DWORD time);
	BOOL set_pitch(float pitch);
	BOOL slide_pitch(float pitch, DWORD time);
	BOOL set_volume(float volume);
	BOOL slide_volume(float volume, DWORD time);
	BOOL set_pan_alt(float pan);
	BOOL slide_pan_alt(float pan, DWORD time);
	BOOL set_pitch_alt(float pitch);
	BOOL slide_pitch_alt(float pitch, DWORD time);
	BOOL set_volume_alt(float volume);
	BOOL slide_volume_alt(float volume, DWORD time);
};


float get_master_volume();
BOOL set_master_volume(float volume);
DWORD get_input_device();
DWORD get_input_device_count();
DWORD get_input_device_name(DWORD device, char* buffer, DWORD bufsize);
BOOL set_input_device(DWORD device);
DWORD get_output_device();
DWORD get_output_device_count();
DWORD get_output_device_name(DWORD device, char* buffer, DWORD bufsize);
BOOL set_output_device(DWORD device);
BOOL get_global_hrtf();
BOOL set_global_hrtf(BOOL enable);

void RegisterScriptSound(asIScriptEngine* engine);
#endif //sound_h
