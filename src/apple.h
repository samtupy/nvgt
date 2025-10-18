/* apple.h - header included on all apple platforms
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
#include <string>
#include "tts.h"
class asIScriptEngine;
class CScriptArray;

bool voice_over_is_running();
bool voice_over_speak(const std::string& message, bool interrupt = true);
void voice_over_window_created();
void voice_over_speech_shutdown();
std::string apple_input_box(const std::string& title, const std::string& message, const std::string& default_value = "", bool secure = false, bool readonly = false);

// Definition for AVTTSVoice class created by Gruia Chiscop on 6/6/24.
class AVTTSVoice : public tts_engine_impl {
public:
	AVTTSVoice();
	~AVTTSVoice();
	virtual bool is_available() override;
	virtual tts_pcm_generation_state get_pcm_generation_state() override;
	virtual bool speak(const std::string& text, bool interrupt = false, bool blocking = false) override;
	virtual tts_audio_data* speak_to_pcm(const std::string &text) override;
	virtual void free_pcm(tts_audio_data* data) override;
	virtual bool is_speaking() override;
	virtual bool stop() override;
	virtual float get_rate() override;
	virtual float get_pitch() override;
	virtual float get_volume() override;
	virtual void set_rate(float rate) override;
	virtual void set_pitch(float pitch) override;
	virtual void set_volume(float volume) override;
	virtual bool get_rate_range(float& minimum, float& midpoint, float& maximum) override;
	virtual bool get_pitch_range(float& minimum, float& midpoint, float& maximum) override;
	virtual bool get_volume_range(float& minimum, float& midpoint, float& maximum) override;
	virtual int get_voice_count() override;
	virtual std::string get_voice_name(int index) override;
	virtual std::string get_voice_language(int index) override;
	virtual bool set_voice(int voice) override;
	virtual int get_current_voice() override;
	bool speakWait(const std::string& text, bool interrupt);
	bool stopSpeech();
	bool pauseSpeech();
	CScriptArray* getAllVoices() const;
	CScriptArray* getVoicesByLanguage(const std::string& language) const;
	std::string getCurrentVoice() const;
	bool isPaused() const;
	void setVoiceByName(const std::string& name);
	void setVoiceByLanguage(const std::string& language);
	std::string getCurrentLanguage() const;
	uint64_t getVoicesCount() const;
	int getVoiceIndex(const std::string& name) const;
	bool setVoiceByIndex(uint64_t index);
	std::string getVoiceName(uint64_t index);
private:
	class Impl;
	Impl* impl;
	int RefCount;
};
