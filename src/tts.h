/* tts.h - header for engine-based text to speech system
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
#include <speech.h>
#include <string>
#include <vector>
#include <memory>
#include <functional>
#include <queue>
#include <mutex>
#include <atomic>
#include <sstream>
#include <cstdlib>
#include <angelscript.h>
#include <scriptarray.h>
#include "sound.h"

class sound;
class tts_engine_impl;
class tts_engine;

enum tts_pcm_generation_state { PCM_UNSUPPORTED, PCM_SUPPORTED, PCM_PREFERRED };
struct tts_audio_data {
	void* data;
	unsigned int size_in_bytes;
	unsigned int sample_rate;
	unsigned int channels;
	unsigned int bitsize;
	void* context;
	tts_engine* engine;
	tts_audio_data(tts_engine* eng, void* dat, unsigned int size, unsigned int rate, unsigned int chans, unsigned int bits, void* ctx = nullptr);
	void free();
};

class tts_engine {
public:
	virtual ~tts_engine() = default;
	virtual bool is_available() = 0;
	virtual tts_pcm_generation_state get_pcm_generation_state() = 0;
	virtual bool speak(const std::string &text, bool interrupt = false, bool blocking = false) = 0;
	virtual tts_audio_data* speak_to_pcm(const std::string &text) = 0;
	virtual void free_pcm(tts_audio_data* data) = 0;
	virtual bool is_speaking() = 0;
	virtual bool stop() = 0;
	virtual float get_rate() = 0;
	virtual float get_pitch() = 0;
	virtual float get_volume() = 0;
	virtual void set_rate(float rate) = 0;
	virtual void set_pitch(float pitch) = 0;
	virtual void set_volume(float volume) = 0;
	virtual bool get_rate_range(float& minimum, float& midpoint, float& maximum) = 0;
	virtual bool get_pitch_range(float& minimum, float& midpoint, float& maximum) = 0;
	virtual bool get_volume_range(float& minimum, float& midpoint, float& maximum) = 0;
	virtual int get_voice_count() = 0;
	virtual std::string get_voice_name(int index) = 0;
	virtual std::string get_voice_language(int index) = 0;
	virtual bool set_voice(int voice) = 0;
	virtual int get_current_voice() = 0;
	virtual std::string get_engine_name() = 0;
};

class tts_engine_impl : public tts_engine {
protected:
	std::string engine_name;
public:
	tts_engine_impl(const std::string &name) : engine_name(name) {}
	virtual ~tts_engine_impl() = default;
	virtual bool is_available() override { return true; }
	virtual tts_pcm_generation_state get_pcm_generation_state() override { return PCM_UNSUPPORTED; }
	virtual bool speak(const std::string &text, bool interrupt = false, bool blocking = false) override { return false; }
	virtual tts_audio_data* speak_to_pcm(const std::string &text) override { return nullptr; }
	virtual void free_pcm(tts_audio_data* data) override { if (data->data) free(data->data); delete data; }
	virtual bool is_speaking() override { return false; }
	virtual bool stop() override { return true; }
	virtual float get_rate() override { return 0; }
	virtual float get_pitch() override { return 0; }
	virtual float get_volume() override { return 0; }
	virtual void set_rate(float rate) override { }
	virtual void set_pitch(float pitch) override { }
	virtual void set_volume(float volume) override { }
	virtual bool get_rate_range(float& minimum, float& midpoint, float& maximum) override { return false; }
	virtual bool get_pitch_range(float& minimum, float& midpoint, float& maximum) override { return false; }
	virtual bool get_volume_range(float& minimum, float& midpoint, float& maximum) override { return false; }
	virtual int get_voice_count() override { return 1; }
	virtual std::string get_voice_name(int index) override { return index == 0? get_engine_name() : ""; }
	virtual std::string get_voice_language(int index) override { return "en-us"; }
	virtual bool set_voice(int voice) override { return voice == 0; }
	virtual int get_current_voice() override { return 0; }
	virtual std::string get_engine_name() override { return engine_name; }
};

// Engine factory system
typedef std::function<std::shared_ptr<tts_engine>()> tts_engine_factory;
bool tts_engine_register(const std::string &name, tts_engine_factory factory);
std::vector<std::string> tts_get_engine_names();
std::shared_ptr<tts_engine> tts_create_engine(const std::string &name);

struct voice_info {
	tts_engine *engine;
	int engine_voice_index;
	std::string name;
	std::string language;
};

class tts_voice {
	int RefCount;
	std::vector<std::shared_ptr<tts_engine>> engines;
	std::vector<voice_info> voices;
	int current_voice_index;
	std::string current_language;
	typedef std::shared_ptr<sound> soundptr;
	typedef std::queue<soundptr> sound_queue;
	sound_queue queue;
	std::mutex queue_mtx;
	sound_queue fade_queue;
	std::atomic_flag speaking;
	voice_info *get_voice_info(int voice_index);
	void *speak_to_pcm(const std::string &text, tts_audio_data** datablock); // Returns pointer to trimmed sample.
	bool schedule(soundptr &s, bool interrupt);
	void clear();
	bool fade(soundptr &item);
	void cleanup_completed_fades();
	static void at_end(void *pUserData, ma_sound *pSound);
	static ma_result job_proc(ma_job *pJob);
public:
	tts_voice(const std::string &engine_list = "");
	void AddRef();
	void Release();
	bool speak(const std::string &text, bool interrupt = false);
	bool speak_to_file(const std::string &filename, const std::string &text);
	std::string speak_to_memory(const std::string &text);
	bool speak_wait(const std::string &text, bool interrupt = false);
	sound *speak_to_sound(const std::string &text);
	bool speak_interrupt(const std::string &text) { return speak(text, true); }
	bool speak_interrupt_wait(const std::string &text) { return speak_wait(text, true); }
	float get_rate();
	float get_pitch();
	float get_volume();
	int get_voice_count();
	std::string get_voice_name(int index);
	std::string get_voice_language(int index);
	void set_rate(float rate);
	void set_pitch(float pitch);
	void set_volume(float volume);
	CScriptArray *list_voices();
	bool set_voice(int voice);
	int get_current_voice();
	bool get_speaking();
	bool refresh();
	bool stop();
	std::string get_engine_name();
	int get_engine_count();
	std::string get_engine_name(int index);
	bool set_language(const std::string& language);
	std::string get_language();
};

// Global functions
CScriptArray *tts_get_engines();
bool screen_reader_load();
void screen_reader_unload();
std::string screen_reader_detect();
bool screen_reader_has_speech();
bool screen_reader_has_braille();
bool screen_reader_is_speaking();
bool screen_reader_output(const std::string& text, bool interrupt);
bool screen_reader_speak(const std::string& text, bool interrupt);
bool screen_reader_braille(const std::string& text);
bool screen_reader_silence();

void RegisterTTSVoice(asIScriptEngine *engine);
