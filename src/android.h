/* android.h - header containing functions only applicable to the Android platform
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
#include <vector>
#include "tts.h"
#include <jni.h>
#include <stdexcept>

bool android_is_screen_reader_active();
std::string android_screen_reader_detect();
bool android_screen_reader_speak(const std::string& text, bool interrupt);
bool android_screen_reader_silence();
std::vector<std::string> android_get_tts_engine_packages();

// New functions moved from UI.cpp
std::string android_input_box(const std::string& title, const std::string& text, const std::string& default_value);
bool android_info_box(const std::string& title, const std::string& text, const std::string& value);
bool android_is_window_active();

// JNI Helpers
class JNIException : public std::runtime_error {
public:
	explicit JNIException(const std::string& msg): std::runtime_error(msg) {}
};

template<typename T>
class LocalRef {
	JNIEnv* env;
	T ref;
public:
	LocalRef(JNIEnv* e, T r) : env(e), ref(r) {}
	~LocalRef() {
		if (ref) env->DeleteLocalRef(ref);
	}
	T get() const { return ref; }
	operator T() const { return ref; }
};

class android_tts_engine : public tts_engine_impl {
	jclass TTSClass;
	jmethodID constructor, midIsActive, midIsSpeaking, midSpeak, midSilence, midGetVoice, midSetRate, midSetPitch, midSetPan, midSetVolume, midGetVoices, midSetVoice, midGetMaxSpeechInputLength, midGetPitch, midGetPan, midGetRate, midGetVolume;
	jmethodID midSpeakPcm, midGetPcmSampleRate, midGetPcmAudioFormat, midGetPcmChannelCount;
	jmethodID midGetVoiceCount, midGetVoiceName, midGetVoiceLanguage, midSetVoiceByIndex, midGetCurrentVoiceIndex;
	JNIEnv *env;
	jobject TTSObj;
	std::string engine_package;
public:
	android_tts_engine(const std::string& enginePkg = "");
	virtual ~android_tts_engine();
	virtual bool is_available() override;
	virtual tts_pcm_generation_state get_pcm_generation_state() override;
	virtual bool speak(const std::string &text, bool interrupt = false, bool blocking = false) override;
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
};