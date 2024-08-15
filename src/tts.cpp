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
#ifdef SDL_PLATFORM_APPLE
#include "apple.h"
#endif
#include "riffheader.h"
#include "tts.h"
#include "UI.h"

char* minitrim(char* data, unsigned long* bufsize, int bitrate, int channels) {
	char* ptr = data;
	if (!ptr || !bufsize || *bufsize % 2 != 0 || *bufsize < 1) return ptr;
	short a = 3072;
	while (bitrate == 16 && (ptr - data) < *bufsize) {
		if (channels == 2) {
			short l = (((short) * ptr) << 8) | *(ptr + 1);
			short r = (((short) * (ptr + 2)) << 8) | *(ptr + 3);
			if (l > -a && l < a && r > -a && r < a)
				ptr += 4;
			else break;
		} else if (channels == 1) {
			short s = (((short) * ptr) << 8) | *(ptr + 1);
			if (s > -a && s < a)
				ptr += 2;
			else break;
		}
	}
	*bufsize -= (ptr - data);
	return ptr;
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
	#elif defined(SDL_PLATFORM_APPLE)
	inst = new AVTTSVoice();
	voice_index = inst->getVoiceIndex(inst->getCurrentVoice());
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
	#elif defined(SDL_PLATFORM_APPLE)
	if (!inst) return;
	delete inst;
	inst = nullptr;
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
	#elif defined(SDL_PLATFORM_APPLE)
	else {
		return inst->speak(text, interrupt);
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
		DWORD bufsize;
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
	#elif defined(SDL_PLATFORM_APPLE)
	else {
		return false; // not implemented yet.
	}
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
	#elif defined(SDL_PLATFORM_APPLE)
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
	if (!speak(text, interrupt))
		return false;
	#ifdef SDL_PLATFORM_APPLE
	while (voice_index == builtin_index && BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING || inst->isSpeaking())
	#else
	while (BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING)
	#endif
		wait(5);
	return true;
}
bool tts_voice::stop() {
	return speak("", true);
}
int tts_voice::get_rate() {
	if (voice_index == builtin_index) return builtin_rate;
	#ifdef _WIN32
	if (!inst && !refresh()) return 0;
	long result;
	if (!blastspeak_get_voice_rate(inst, &result))
		return 0;
	return result;
	#elif defined(SDL_PLATFORM_APPLE)
	return inst->getRate() * 7;
	#endif
	return 0;
}
int tts_voice::get_pitch() {
	//if(voice_index == builtin_index) return builtin_pitch;
	#ifdef _WIN32
	// not implemented yet
	#elif defined(SDL_PLATFORM_APPLE)
	return inst->getPitch();
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
	#elif defined(SDL_PLATFORM_APPLE)
	return inst->getRate();
	#endif
	return 0;
}
void tts_voice::set_rate(int rate) {
	if (voice_index == builtin_index) builtin_rate = rate;
	#ifdef _WIN32
	if (!inst && !refresh()) return;
	blastspeak_set_voice_rate(inst, rate);
	#elif defined(SDL_PLATFORM_APPLE)
	inst->setRate(rate / 7.0);
	#endif
}
void tts_voice::set_pitch(int pitch) {
	// if(voice_index == builtin_index) builtin_pitch = pitch;
	#ifdef _WIN32
	// not implemented
	#elif defined(SDL_PLATFORM_APPLE)
	inst->setPitch(pitch);
	#endif
	return;
}
void tts_voice::set_volume(int volume) {
	if (voice_index == builtin_index) builtin_volume = volume;
	#ifdef _WIN32
	if (!inst && !refresh()) return;
	blastspeak_set_voice_volume(inst, volume);
	#elif defined(SDL_PLATFORM_APPLE)
	inst->setVolume(volume);
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
	#elif defined(SDL_PLATFORM_APPLE)
	bool r = inst->setVoiceByIndex(voice - (builtin_index + 1));
	if (!r) return false;
	voice_index = voice;
	return true;
	#endif
	return false;
}
bool tts_voice::get_speaking() {
	#ifdef SDL_PLATFORM_APPLE
	if (voice_index == builtin_index && BASS_ChannelIsActive(audioout) == BASS_ACTIVE_PLAYING) return true;
	return inst->isSpeaking();
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
	#elif defined(SDL_PLATFORM_APPLE)
	array->InsertLast(*inst->getAllVoices());
	#endif
	return array;
}
int tts_voice::get_voice_count() {
	#ifdef _WIN32
	if (!inst && !refresh()) return builtin_index + 1;
	return inst ? inst->voice_count + (builtin_index + 1) : builtin_index + 1;
	#elif defined(SDL_PLATFORM_APPLE)
	return inst->getVoicesCount() + (builtin_index + 1);
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
	#elif defined(SDL_PLATFORM_APPLE)
	return inst->getVoiceName(index);
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
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_FACTORY, _O("tts_voice @t(const string&in = \"builtin fallback voice\")"), asFUNCTION(Script_tts_voice_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_ADDREF, "void f()", asMETHOD(tts_voice, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("tts_voice", asBEHAVE_RELEASE, "void f()", asMETHOD(tts_voice, Release), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak(const string &in, bool = false)", asMETHOD(tts_voice, speak), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_interrupt(const string &in)", asMETHOD(tts_voice, speak_interrupt), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_to_file(const string& in, const string &in)", asMETHOD(tts_voice, speak_to_file), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_wait(const string &in, bool = false)", asMETHOD(tts_voice, speak_wait), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "string speak_to_memory(const string &in)", asMETHOD(tts_voice, speak_to_memory), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool speak_interrupt_wait(const string &in)", asMETHOD(tts_voice, speak_interrupt_wait), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool refresh()", asMETHOD(tts_voice, refresh), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool stop()", asMETHOD(tts_voice, stop), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "array<string>@ list_voices() const", asMETHOD(tts_voice, list_voices), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool set_voice(int)", asMETHOD(tts_voice, set_voice), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_rate() const property", asMETHOD(tts_voice, get_rate), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_rate(int) property", asMETHOD(tts_voice, set_rate), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_pitch() const property", asMETHOD(tts_voice, get_pitch), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_pitch(int) property", asMETHOD(tts_voice, set_pitch), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_volume() const property", asMETHOD(tts_voice, get_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "void set_volume(int) property", asMETHOD(tts_voice, set_volume), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "int get_voice_count() const property", asMETHOD(tts_voice, get_voice_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "string get_voice_name(int) const", asMETHOD(tts_voice, get_voice_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("tts_voice", "bool get_speaking() const property", asMETHOD(tts_voice, get_speaking), asCALL_THISCALL);
	engine->RegisterObjectProperty("tts_voice", "const int voice", asOFFSET(tts_voice, voice_index));
}
