/* tts.cpp - code for OS based text to speech system
 * On windows this is SAPI, on macOS it is NSSpeech/AVSpeechSynthesizer, on linux speech dispatcher etc.
 * If no OS based speech system can be found for a given platform, a derivative of RSynth that is built into NVGT will be used instead.
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

#ifdef _WIN32
	#include <blastspeak.h>
#endif
#include <obfuscate.h>
#ifdef __APPLE__
	#include "apple.h"
#endif
#include "riffheader.h"
#include "tts.h"
#include "UI.h"
#ifdef __ANDROID__
	#include <jni.h>
	#include <Poco/Exception.h>
	#include <Poco/Format.h>
	#include <SDL3/SDL.h>
#endif

static char* minitrim(char* data, unsigned long* size, int bitrate, int channels, int begin_threshold = 512, int end_threshold = 128) {
	int samplesPerFrame = channels * (bitrate / 8);
	int numSamples = *size / samplesPerFrame;
	int startIndex = 0;
	int endIndex = numSamples - 1;
	for (int i = 0; i < numSamples; i++) {
		int maxAbsValue = 0;
		for (int j = 0; j < channels; j++) {
			int absValue = abs(bitrate == 16? reinterpret_cast<short*>(data)[i * channels + j] : data[i * channels + j]);
			if (absValue > maxAbsValue) maxAbsValue = absValue;
		}
		if (maxAbsValue >= begin_threshold) {
			startIndex = i;
			break;
		}
	}
	for (int i = numSamples - 1; i >= 0; i--) {
		int maxAbsValue = 0;
		for (int j = 0; j < channels; j++) {
			int absValue = abs(bitrate == 16? reinterpret_cast<short*>(data)[i * channels + j] : data[i * channels + j]);
			if (absValue > maxAbsValue) maxAbsValue = absValue;
		}
		if (maxAbsValue >= end_threshold) {
			endIndex = i;
			break;
		}
	}
	*size = (endIndex - startIndex + 1) * samplesPerFrame;
	return data + startIndex * samplesPerFrame;
}

tts_voice::tts_voice(const std::string& builtin_voice_name) {
	init_sound();
	RefCount = 1;
	samprate = 0;
	bitrate = 0;
	channels = 0;
	destroyed = false;
	builtin_rate = 0;
	builtin_volume = 0;
	builtin_index = builtin_voice_name.size() > 0 ? 0 : -1;
	this->builtin_voice_name = builtin_voice_name;
	setup();
	audioout = 0;
}
tts_voice::~tts_voice() {
	//destroy();
}
void tts_voice::setup() {
	#ifdef _WIN32
	voice_index = -1;
	inst = (blastspeak*)malloc(sizeof(blastspeak));
	memset(inst, 0, sizeof(blastspeak));
	if (!blastspeak_initialize(inst)) {
		free(inst);
		inst = NULL;
		voice_index = builtin_index;
	}
	#elif defined(__APPLE__)
	inst = new AVTTSVoice();
	voice_index = inst->getVoiceIndex(inst->getCurrentVoice());
	#elif defined (__ANDROID__)
	env = (JNIEnv*)SDL_GetAndroidJNIEnv();
	if (!env) throw Poco::Exception("cannot retrieve JNI environment");
	TTSClass = env->FindClass("com/samtupy/nvgt/TTS");
	if (!TTSClass) throw Poco::Exception("Cannot find NVGT TTS class!");
	constructor = env->GetMethodID(TTSClass, "<init>", "()V");
	if (!constructor) throw Poco::Exception("Cannot find NVGT TTS constructor!");
	TTSObj = env->NewObject(TTSClass, constructor);
	if (!TTSObj) throw Poco::Exception("Can't instantiate TTS object!");
	midIsActive = env->GetMethodID(TTSClass, "isActive", "()Z");
	midIsSpeaking = env->GetMethodID(TTSClass, "isSpeaking", "()Z");
	midSpeak = env->GetMethodID(TTSClass, "speak", "(Ljava/lang/String;Z)Z");
	midSilence = env->GetMethodID(TTSClass, "silence", "()Z");
	midGetVoice = env->GetMethodID(TTSClass, "getVoice", "()Ljava/lang/String;");
	midSetRate = env->GetMethodID(TTSClass, "setRate", "(F)Z");
	midSetPitch = env->GetMethodID(TTSClass, "setPitch", "(F)Z");
	midSetPan = env->GetMethodID(TTSClass, "setPan", "(F)V");
	midSetVolume = env->GetMethodID(TTSClass, "setVolume", "(F)V");
	midGetVoices = env->GetMethodID(TTSClass, "getVoices", "()Ljava/util/List;");
	midSetVoice = env->GetMethodID(TTSClass, "setVoice", "(Ljava/lang/String;)Z");
	midGetMaxSpeechInputLength = env->GetMethodID(TTSClass, "getMaxSpeechInputLength", "()I");
	midGetRate = env->GetMethodID(TTSClass, "getRate", "()F");
	midGetPitch = env->GetMethodID(TTSClass, "getPitch", "()F");
	midGetPan = env->GetMethodID(TTSClass, "getPan", "()F");
	midGetVolume = env->GetMethodID(TTSClass, "getVolume", "()F");
	if (!midIsActive || !midIsSpeaking || !midSpeak || !midSilence || !midGetVoice || !midSetRate || !midSetPitch || !midSetPan || !midSetVolume || !midGetVoices || !midSetVoice || !midGetMaxSpeechInputLength || !midGetPitch || !midGetPan || !midGetRate || !midGetVolume) throw Poco::Exception("One or more methods on the TTS class could not be retrieved from JNI!");
	if (!env->CallBooleanMethod(TTSObj, midIsActive)) throw Poco::Exception("TTS engine could not be initialized!");
	voice_index = 1;
	#else
	voice_index = builtin_index;
	#endif
}
void tts_voice::destroy() {
	if (audioout) {
		BASS_StreamFree(audioout);
		audioout = 0;
	}
	#ifdef _WIN32
	if (destroyed || !inst) return;
	blastspeak_destroy(inst);
	if (inst) free(inst);
	inst = NULL;
	#elif defined(__APPLE__)
	if (!inst) return;
	delete inst;
	inst = nullptr;
	#elif defined(__ANDROID__)
	env->DeleteLocalRef(TTSObj);
	TTSObj = nullptr;
	#endif
	destroyed = true;
	voice_index = -1;
}
void tts_voice::AddRef() {
	asAtomicInc(RefCount);
}
void tts_voice::Release() {
	if (asAtomicDec(RefCount) < 1) {
		if (!destroyed)
			destroy();
		delete this;
	}
}
bool tts_voice::speak(const std::string& text, bool interrupt) {
	if (text.empty()) {
		if (audioout) BASS_ChannelStop(audioout);
		return true;
	}
	unsigned long bufsize;
	char* data = NULL;
	if (voice_index == builtin_index) {
		if (samprate != 48000 || bitrate != 16 || channels != 2) {
			samprate = 48000;
			bitrate = 16;
			channels = 2;
			if (audioout)
				BASS_StreamFree(audioout);
			audioout = 0;
		}
	}
	#ifdef _WIN32
	else {
		if (!inst && !refresh()) return FALSE;
		data = blastspeak_speak_to_memory(inst, &bufsize, text.c_str());
		if (!data) return false;
		if (!audioout || (inst->sample_rate != samprate || inst->bits_per_sample != bitrate || inst->channels != channels)) {
			samprate = inst->sample_rate;
			bitrate = inst->bits_per_sample;
			channels = inst->channels;
			if (audioout)
				BASS_StreamFree(audioout);
			audioout = 0;
		}
	}
	#elif defined(__APPLE__)
	else
		return inst->speak(text, interrupt);
	#elif defined (__ANDROID__)
	else {
		jstring jtext = env->NewStringUTF(text.c_str());
		bool r = env->CallBooleanMethod(TTSObj, midSpeak, jtext, interrupt ? JNI_TRUE : JNI_FALSE);
		env->DeleteLocalRef(jtext);
		return r;
	}
	#endif
	if (voice_index == builtin_index && !text.empty()) {
		int samples;
		data = (char*) speech_gen(&samples, text.c_str(), NULL);
		bufsize = samples * 4;
	}
	if (interrupt) {
		if (audioout) BASS_ChannelPlay(audioout, true);
		if (text.empty()) return true;
	}
	if (!data) return interrupt;
	if (!audioout && !text.empty())
		audioout = BASS_StreamCreate(samprate, channels, 0, STREAMPROC_PUSH, NULL);
	char* ptr = minitrim(data, &bufsize, bitrate, channels);
	int ret = BASS_StreamPutData(audioout, ptr, bufsize);
	if (voice_index == builtin_index) free(data);
	if (ret < 0)
		return false;
	BASS_ChannelPlay(audioout, FALSE);
	return true;
}
bool tts_voice::speak_to_file(const std::string& filename, const std::string& text) {
	if (text == "" || filename == "") return false;
	char* data;
	unsigned long bufsize;
	if (voice_index == builtin_index) {
		if (samprate != 48000 || bitrate != 16 || channels != 2) {
			samprate = 48000;
			bitrate = 16;
			channels = 2;
			if (audioout)
				BASS_StreamFree(audioout);
			audioout = 0;
		}
		int samples;
		data = (char*)speech_gen(&samples, text.c_str(), NULL);
		bufsize = samples * 4;
	}
	#ifdef _WIN32
	else {
		if (!inst && !refresh()) return FALSE;
		data = blastspeak_speak_to_memory(inst, &bufsize, text.c_str());
		if (!audioout || (inst->sample_rate != samprate || inst->bits_per_sample != bitrate || inst->channels != channels)) {
			samprate = inst->sample_rate;
			bitrate = inst->bits_per_sample;
			channels = inst->channels;
			if (audioout)
				BASS_StreamFree(audioout);
			audioout = 0;
		}
	}
	#elif defined(__APPLE__)
	else {
		return false; // not implemented yet.
	}
	#elif defined(__ANDROID__)
	else
		return false;
	#endif
	char* ptr = minitrim(data, &bufsize, bitrate, channels);
	FILE* f = fopen(filename.c_str(), "wb");
	if (!f) return false;
	wav_header h = make_wav_header(44 + bufsize, samprate, bitrate, channels);
	fwrite(&h, 1, sizeof(wav_header), f);
	fwrite(ptr, bufsize, 1, f);
	fclose(f);
	if (voice_index == builtin_index) free(data);
	return true;
}
std::string tts_voice::speak_to_memory(const std::string& text) {
	if (text.empty()) return "";
	unsigned long bufsize;
	char* data;
	if (voice_index == builtin_index) {
		if (samprate != 48000 || bitrate != 16 || channels != 2) {
			samprate = 48000;
			bitrate = 16;
			channels = 2;
			if (audioout)
				BASS_StreamFree(audioout);
			audioout = 0;
		}
		int samples;
		data = (char*)speech_gen(&samples, text.c_str(), NULL);
		bufsize = samples * 4;
	}
	#ifdef _WIN32
	else {
		if (!inst && !refresh()) return "";
		data = blastspeak_speak_to_memory(inst, &bufsize, text.c_str());
		if (!audioout || (inst->sample_rate != samprate || inst->bits_per_sample != bitrate || inst->channels != channels)) {
			samprate = inst->sample_rate;
			bitrate = inst->bits_per_sample;
			channels = inst->channels;
			if (audioout)
				BASS_StreamFree(audioout);
			audioout = 0;
		}
	}
	#elif defined(__APPLE__) || defined(__ANDROID__)
	else {
		return ""; // Not implemented yet.
	}
	#endif
	if (!data) return "";
	char* ptr = minitrim(data, &bufsize, bitrate, channels);
	wav_header h = make_wav_header(44 + bufsize, samprate, bitrate, channels);
	std::string output((char*)&h, sizeof(wav_header));
	output.append(ptr, bufsize);
	if (voice_index == builtin_index) free(data);
	return output;
}
bool tts_voice::speak_wait(const std::string& text, bool interrupt) {
	if (!speak(text, interrupt)) return false;
	#ifdef __APPLE__
	while (voice_index == builtin_index && BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING || inst->isSpeaking())
	#elif defined(__ANDROID__)
	while (voice_index == builtin_index && BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING || get_speaking())
	#else
	while (BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING)
	#endif
		wait(5);
	return true;
}
bool tts_voice::stop() {
	#ifndef __ANDROID__
	return speak("", true);
	#else
	return env->CallBooleanMethod(TTSObj, midSilence);
	#endif
}
int tts_voice::get_rate() {
	if (voice_index == builtin_index) return builtin_rate;
	#ifdef _WIN32
	if (!inst && !refresh()) return 0;
	long result;
	if (!blastspeak_get_voice_rate(inst, &result))
		return 0;
	return result;
	#elif defined(__APPLE__)
	return inst->getRate() * 7;
	#elif defined (__ANDROID__)
	return static_cast<int>((env->CallFloatMethod(TTSObj, midGetRate) - 1) * 10.0);
	#endif
	return 0;
}
int tts_voice::get_pitch() {
	//if(voice_index == builtin_index) return builtin_pitch;
	#ifdef _WIN32
	// not implemented yet
	#elif defined(__APPLE__)
	return inst->getPitch();
	#elif defined (__ANDROID__)
	return static_cast<int>((env->CallFloatMethod(TTSObj, midGetPitch) - 1) * 10.0);
	#endif
	return 0;
}
int tts_voice::get_volume() {
	if (voice_index == builtin_index) return builtin_volume;
	#ifdef _WIN32
	if (!inst && !refresh()) return 100;
	long result;
	if (!blastspeak_get_voice_volume(inst, &result))
		return 0;
	return result;
	#elif defined(__APPLE__)
	return inst->getRate();
	#elif defined(__ANDROID__)
	return static_cast<int>(env->CallFloatMethod(TTSObj, midGetVolume) - 100.0);
	#endif
	return 0;
}
void tts_voice::set_rate(int rate) {
	if (voice_index == builtin_index) builtin_rate = rate;
	#ifdef _WIN32
	if (!inst && !refresh()) return;
	blastspeak_set_voice_rate(inst, rate);
	#elif defined(__APPLE__)
	inst->setRate(rate / 7.0);
	#elif defined(__ANDROID__)
	env->CallBooleanMethod(TTSObj, midSetRate, (static_cast<float>(rate) / 10.0) + 1.0);
	#endif
}
void tts_voice::set_pitch(int pitch) {
	// if(voice_index == builtin_index) builtin_pitch = pitch;
	#ifdef _WIN32
	// not implemented
	#elif defined(__APPLE__)
	inst->setPitch(pitch);
	#elif defined(__ANDROID__)
	env->CallBooleanMethod(TTSObj, midSetPitch, (static_cast<float>(pitch) / 10.0) + 1.0);
	#endif
	return;
}
void tts_voice::set_volume(int volume) {
	if (voice_index == builtin_index) builtin_volume = volume;
	#ifdef _WIN32
	if (!inst && !refresh()) return;
	blastspeak_set_voice_volume(inst, volume);
	#elif defined(__APPLE__)
	inst->setVolume(volume);
	#elif defined(__ANDROID__)
	env->CallBooleanMethod(TTSObj, midSetVolume, static_cast<float>(volume) + 100.0);
	#endif
}
bool tts_voice::set_voice(int voice) {
	if (voice == builtin_index) {
		voice_index = voice;
		return true;
	}
	#ifdef _WIN32
	if (!inst && !refresh()) return FALSE;
	if (blastspeak_set_voice(inst, voice - (builtin_index + 1))) {
		voice_index = voice;
		return true;
	}
	#elif defined(__APPLE__)
	bool r = inst->setVoiceByIndex(voice - (builtin_index + 1));
	if (!r) return false;
	voice_index = voice;
	return true;
	#endif
	return false;
}
bool tts_voice::get_speaking() {
	#ifdef __APPLE__
	if (voice_index == builtin_index && BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING) return true;
	return inst->isSpeaking();
	#elif defined(__ANDROID__)
	if (voice_index == builtin_index && BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING) return true;
	return env->CallBooleanMethod(TTSObj, midIsSpeaking) == JNI_TRUE;
	#else
	if (!audioout) return false;
	return BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING;
	#endif
}
CScriptArray* tts_voice::list_voices() {
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
	CScriptArray* array = CScriptArray::Create(arrayType, builtin_index + 1);
	if (builtin_index == 0)((std::string*)(array->At(0)))->assign(builtin_voice_name);
	#ifdef _WIN32
	if (!inst && !refresh())
		return array;
	array->Resize(array->GetSize() + inst->voice_count);
	for (int i = 0; i < inst->voice_count; i++) {
		const char* result = blastspeak_get_voice_description(inst, i);
		int array_idx = i + (builtin_index + 1);
		if (result)
			((std::string*)(array->At(array_idx)))->assign(result);
		else
			((std::string*)(array->At(array_idx)))->assign("");
	}
	#elif defined(__APPLE__)
	array->InsertLast(*inst->getAllVoices());
	#endif
	return array;
}
int tts_voice::get_voice_count() {
	#ifdef _WIN32
	if (!inst && !refresh()) return builtin_index + 1;
	return inst ? inst->voice_count + (builtin_index + 1) : builtin_index + 1;
	#elif defined(__APPLE__)
	return inst->getVoicesCount() + (builtin_index + 1);
	#elif defined(__ANDROID__)
	return 1;
	#endif
	return builtin_index + 1;
}
std::string tts_voice::get_voice_name(int index) {
	if (index == builtin_index) return builtin_voice_name;
	index -= (builtin_index + 1);
	#ifdef _WIN32
	int c = get_voice_count();
	if (!inst && !refresh()) return "";
	if (c < 1 || index < 0 || index >= c) return "";
	const char* result = blastspeak_get_voice_description(inst, index);
	if (result)
		return std::string(result);
	#elif defined(__APPLE__)
	return inst->getVoiceName(index);
	#elif defined(__ANDROID__)
	jboolean isCopy;
	return env->GetStringUTFChars((jstring)env->CallObjectMethod(TTSObj, midGetVoice), &isCopy);
	#endif
	return "";
}
bool tts_voice::refresh() {
	int voice = voice_index;
	destroy();
	setup();
	set_voice(voice);
	return true;
}

tts_voice* Script_tts_voice_Factory(const std::string& builtin_voice_name) {
	return new tts_voice(builtin_voice_name);
}
void RegisterTTSVoice(asIScriptEngine* engine) {
	engine->RegisterObjectType("tts_voice", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_FACTORY, _O("tts_voice @t(const string&in fallback_voice_name = \"builtin fallback voice\")"), asFUNCTION(Script_tts_voice_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_ADDREF, "void f()", asMETHOD(tts_voice, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_RELEASE, "void f()", asMETHOD(tts_voice, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak(const string &in text, bool interrupt = false)", asMETHOD(tts_voice, speak), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_interrupt(const string &in text)", asMETHOD(tts_voice, speak_interrupt), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_to_file(const string& in filename, const string &in text)", asMETHOD(tts_voice, speak_to_file), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_wait(const string &in text, bool interrupt = false)", asMETHOD(tts_voice, speak_wait), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "string speak_to_memory(const string &in text)", asMETHOD(tts_voice, speak_to_memory), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_interrupt_wait(const string &in text)", asMETHOD(tts_voice, speak_interrupt_wait), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool refresh()", asMETHOD(tts_voice, refresh), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool stop()", asMETHOD(tts_voice, stop), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "array<string>@ list_voices() const", asMETHOD(tts_voice, list_voices), asCALL_THISCALL);
	//Alias the above as get_voice_names() for legacy BGT code.
	engine->RegisterObjectMethod("tts_voice", "array<string>@ get_voice_names() const", asMETHOD(tts_voice, list_voices), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool set_voice(int index)", asMETHOD(tts_voice, set_voice), asCALL_THISCALL);
	//Alias the above as set_current_voice() for legacy BGT code.
	engine->RegisterObjectMethod("tts_voice", "bool set_current_voice(int index)", asMETHOD(tts_voice, set_voice), asCALL_THISCALL);

	engine->RegisterObjectMethod("tts_voice", "int get_rate() const property", asMETHOD(tts_voice, get_rate), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_rate(int rate) property", asMETHOD(tts_voice, set_rate), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_pitch() const property", asMETHOD(tts_voice, get_pitch), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_pitch(int pitch) property", asMETHOD(tts_voice, set_pitch), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_volume() const property", asMETHOD(tts_voice, get_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_volume(int volume) property", asMETHOD(tts_voice, set_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_voice_count() const property", asMETHOD(tts_voice, get_voice_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "string get_voice_name(int index) const", asMETHOD(tts_voice, get_voice_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool get_speaking() const property", asMETHOD(tts_voice, get_speaking), asCALL_THISCALL);
	engine->RegisterObjectProperty("tts_voice", "const int voice", asOFFSET(tts_voice, voice_index));
}
