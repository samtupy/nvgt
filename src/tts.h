/* tts.h - header for OS based text to speech system
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
#include <speech.h>
#include <string>
#include <angelscript.h>
#include <scriptarray.h>
#include "sound.h"
#ifdef _WIN32
struct blastspeak;
#elif defined(__APPLE__)
class AVTTSVoice;
#elif defined (__ANDROID__)
#include <jni.h>
#endif

class tts_voice {
	int RefCount;
	#ifdef _WIN32
	blastspeak* inst;
	#elif defined(__APPLE__)
	AVTTSVoice* inst;
	#elifdef __ANDROID__
	jclass TTSClass;
	jmethodID constructor, midIsActive, midIsSpeaking, midSpeak, midSilence, midGetVoice, midSetRate, midSetPitch, midSetPan, midSetVolume, midGetVoices, midSetVoice, midGetMaxSpeechInputLength, midGetPitch, midGetPan, midGetRate, midGetVolume;
	JNIEnv* env;
	jobject TTSObj;
	#endif
	bool destroyed;
	HSTREAM audioout;
	long samprate;
	short bitrate;
	short channels;
	// Variables for public domain RSynth derivative builtin synthesizer, mostly so that we can get nvgt to run on new platforms in a limited way without needing to figure out native speech layers for those platforms before giving at least something to beta testers. It is still included on windows though. At the time of writing this comment I have no idea how this sounds, but I do know that my knowledge of tiny public domain speech synthesizers extends to this one.
	int builtin_rate, builtin_volume, builtin_index;
	std::string builtin_voice_name;
public:
	int voice_index;
	tts_voice(const std::string& builtin_voice_name = "builtin fallback voice");
	~tts_voice();
	void setup();
	void destroy();
	void AddRef();
	void Release();
	bool speak(const std::string& text, bool interrupt = false);
	bool speak_to_file(const std::string& filename, const std::string& text);
	std::string speak_to_memory(const std::string& text);
	bool speak_wait(const std::string& text, bool interrupt = false);
	bool speak_interrupt(const std::string& text) {
		return speak(text, true);
	}
	bool speak_interrupt_wait(const std::string& text) {
		return speak_wait(text, true);
	}
	int get_rate();
	int get_pitch();
	int get_volume();
	int get_voice_count();
	std::string get_voice_name(int index);
	void set_rate(int rate);
	void set_pitch(int pitch);
	void set_volume(int volume);
	CScriptArray* list_voices();
	bool set_voice(int voice);
	bool get_speaking();
	bool refresh();
	bool stop();
};

void RegisterTTSVoice(asIScriptEngine* engine);
