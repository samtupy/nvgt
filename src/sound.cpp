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

class audio_engine_tmp; // remove this temporary forward decl later.
audio_engine_tmp* new_audio_engine();

// Globals, currently NVGT does not support instanciating multiple miniaudio contexts and NVGT provides a global sound engine.
static ma_context g_sound_context;
audio_engine_tmp* g_audio_engine = nullptr;
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

// I learned the hard way that you can't instantiate a virtual class until none of it's members are abstract. Hack around that. When wrapper is complete, remove the following placeholder classes:
class audio_engine_tmp {
public:
	virtual ma_engine* get_ma_engine() = 0;
	virtual int get_device() = 0;
	virtual bool set_device(int device) = 0;
};
class mixer_tmp {
public:
	virtual void duplicate() = 0;
	virtual void release() = 0;
	virtual bool play() = 0;
};
class sound_tmp : public virtual mixer_tmp {
public:
	virtual bool load(const string& filename) = 0;
	virtual bool seek(unsigned long long offset) = 0;
};

// Miniaudio objects must be allocated on the heap as nvgt's API introduces the concept of an uninitialized sound, which a stack based system would make more difficult to implement.
class audio_engine_impl : public audio_engine_tmp {
		unique_ptr<ma_engine> engine;
		audio_node* engine_endpoint; // Upon engine creation we'll call ma_engine_get_endpoint once so as to avoid creating more than one of our wrapper objects when our engine->get_endpoint() function is called.
	public:
		audio_engine_impl() {
			// default constructor initializes a miniaudio engine ourselves.
			ma_engine_config cfg = ma_engine_config_init();
			engine = make_unique<ma_engine>();
			if ((g_soundsystem_last_error = ma_engine_init(&cfg, &*engine)) != MA_SUCCESS) {
				engine.reset();
				return;
			}
		}
		ma_engine* get_ma_engine() { return engine.get(); }
		int get_device() {
			ma_device* dev = ma_engine_get_device(&*engine);
			ma_device_info info;
			if (!dev || ma_device_get_info(dev, ma_device_type_playback, &info) != MA_SUCCESS) return -1;
			for (int i = 0; i < g_sound_output_devices.size(); i++) {
				if (memcmp(&g_sound_output_devices[i].id, &info.id, sizeof(ma_device_id)) == 0) return i;
			}
			return -1; // couldn't determine device?
		}
		bool set_device(int device) {
			if (device < 0 || device >= g_sound_output_devices.size()) return false;
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
};
class mixer_impl : public virtual mixer_tmp {
	// In miniaudio, a sound_group is really just a sound. A typical ma_sound_group_x function looks like float ma_sound_group_get_pan(const ma_sound_group* pGroup) { return ma_sound_get_pan(pGroup); }.
	// Furthermore ma_sound_group is just a typedef for ma_sound. As such, for the sake of less code and better inheritance, we will directly call the ma_sound APIs in this class even though it deals with sound groups and not sounds.
	protected:
		ma_engine* engine;
		unique_ptr<ma_sound> snd;
		int refcount;
	public:
	mixer_impl() : snd(nullptr), refcount(1) {
		init_sound();
		engine = g_audio_engine->get_ma_engine();
	}
	mixer_impl(ma_engine* engine) : engine(engine), snd(nullptr), refcount(1) {}
	void duplicate() { asAtomicInc(refcount); }
	void release() {
		if (asAtomicDec(refcount) < 1) delete this;
	}
	bool play() { return snd? ma_sound_start(&*snd) : false; }
};
class sound_impl : public mixer_impl, public sound_tmp {
	public:
		sound_impl(ma_engine* e) {
			engine = e;
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
			g_soundsystem_last_error = ma_sound_init_from_file(engine, filename.c_str(), 0, nullptr, nullptr, snd.get());
			if (g_soundsystem_last_error != MA_SUCCESS) snd.reset();
			return g_soundsystem_last_error == MA_SUCCESS;
		}
		bool seek(unsigned long long offset) { return snd? (g_soundsystem_last_error = ma_sound_seek_to_pcm_frame(&*snd, offset * ma_engine_get_sample_rate(engine) / 1000)) == MA_SUCCESS : false; }
};

audio_engine_tmp* new_audio_engine() { return new audio_engine_impl(); }
sound_tmp* new_global_sound() { init_sound(); return new sound_impl(g_audio_engine->get_ma_engine()); }
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
