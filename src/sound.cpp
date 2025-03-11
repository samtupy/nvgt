/* sound.cpp - sound system implementation code
 * Please note that the beginnings of this file were written way back in 2021 before the NVGT project even really started, and there has been a lot of learning that has taken place since then. This could have been written better putting it kindly, but it does provide the expected functionality.
 * Most likely this entire file will be written from complete scratch when it comes time to transition from bass to miniaudio in the coming months.
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

//#define SOUND_DEBUG
#include <string>
#include <algorithm>
#include <unordered_set>
#include <vector>
#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#define NOMINMAX
	#include <windows.h>
#endif
#include <math.h>
#include <unordered_map>
#include <thread.h>
#include <bass.h>
#include <bass_fx.h>
#include <bassmix.h>
#include <obfuscate.h>
#include <Poco/Thread.h>
#include <Poco/UnicodeConverter.h>
#include <phonon.h>
#include "UI.h" // wait
#include "misc_functions.h" // range_convert
#include "nvgt.h" // g_ScriptEngine
#ifndef NVGT_USER_CONFIG // sound_data_char_decrypt
	#include "nvgt_config.h"
#else
	#include "../user/nvgt_config.h"
#endif
#include "pack.h"
#define riffheader_impl
#include "riffheader.h"
#include "srspeech.h"
#include "sound.h"
#include <scriptarray.h>
#include "timestuff.h" //ticks() sound preloading
#include "xplatform.h" // running_on_mobile
#include <system_error>
#include <fast_float.h>
#include <Poco/StringTokenizer.h>
#include <array>
#include <algorithm>

#ifndef _WIN32
	#define strnicmp strncasecmp
#endif

using namespace std;
using namespace fast_float;

static BOOL sound_initialized = FALSE;
static mixer* output;
static mixer* g_default_mixer = NULL;
static bool hrtf = TRUE;
#define hrtf_framesize 512
static IPLContext phonon_context = NULL;
static IPLAudioSettings phonon_audio_settings{44100, hrtf_framesize};
static IPLHRTFSettings phonon_hrtfSettings{};
static IPLHRTF phonon_hrtf = NULL;
static IPLHRTF phonon_hrtf_reflections = NULL;
static thread_mutex_t preload_mutex;
static pack* g_sound_default_pack = nullptr;

hstream_entry* last_channel = NULL;
hstream_entry* register_hstream(unsigned int channel) {
	if (!channel) return NULL;
	hstream_entry* e = (hstream_entry*)malloc(sizeof(hstream_entry));
	e->p = last_channel;
	e->channel = channel;
	e->n = NULL;
	if (last_channel) last_channel->n = e;
	last_channel = e;
	return e;
}
void unregister_hstream(hstream_entry* e) {
	if (!e) return;
	if (last_channel == e) last_channel = e->p;
	if (e->p) e->p->n = e->n;
	if (e->n) e->n->p = e->p;
	free(e);
}

BOOL sound_available() {
	#ifdef _MSC_VER
	__try {
		return init_sound();
	} __except (1) {
		return FALSE;
	}
	#else
	return init_sound();
	#endif
}
BOOL init_sound(unsigned int dev) {
	if (sound_initialized)
		return TRUE;
	BASS_SetConfig(BASS_CONFIG_DEV_DEFAULT, TRUE);
	BASS_SetConfig(BASS_CONFIG_DEV_PERIOD, -128);
	BASS_SetConfig(BASS_CONFIG_CURVE_PAN, TRUE);
	BASS_SetConfig(BASS_CONFIG_CURVE_VOL, TRUE);
	BASS_SetConfig(BASS_CONFIG_FLOAT, TRUE);
	BASS_SetConfig(BASS_CONFIG_FLOATDSP, TRUE);
	BASS_SetConfig(BASS_CONFIG_BUFFER, 1000);
	BASS_SetConfig(BASS_CONFIG_MIXER_BUFFER, 5);
	BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD, 50);
	BASS_SetConfig(BASS_CONFIG_UPDATETHREADS, 8);
	BASS_SetConfig(BASS_CONFIG_UNICODE, TRUE);
	if (BASS_Init(dev, 44100, 0, NULL, NULL))
		sound_initialized = TRUE;
	if (sound_initialized) {
		if (!BASS_PluginLoad("lib\\bassflac", 0))
			BASS_PluginLoad("bassflac", 0);
		if (!BASS_PluginLoad("lib\\bassopus", 0))
			BASS_PluginLoad("bassopus", 0);
		BASS_GetVersion();
		BASS_FX_GetVersion();
		output = new mixer(NULL);
		/* HFX reverb=BASS_ChannelSetFX(output->channel, BASS_FX_BFX_FREEVERB, 0);
		BASS_BFX_FREEVERB freeverb;
		freeverb.fDryMix=1.0;
		freeverb.fWetMix=0.8;
		freeverb.fRoomSize=0.3;
		freeverb.fDamp=0.5;
		freeverb.fWidth=1.0;
		freeverb.lChannel=BASS_BFX_CHANALL;
		BASS_FXSetParameters(reverb, &freeverb);
		*/
		thread_mutex_init(&preload_mutex);
	}
	return sound_initialized;
}
BOOL shutdown_sound() {
	if (!sound_initialized)
		return TRUE;
	while (last_channel) {
		BASS_StreamFree(last_channel->channel);
		unregister_hstream(last_channel);
	}
	BASS_Free();
	BASS_RecordFree();
	sound_initialized = FALSE;
	return !sound_initialized;
}

// A microclass for locking mutexes in scope, could likely do with error handling.
class lock_mutex {
	thread_mutex_t* mtx;
public:
	lock_mutex(thread_mutex_t* mtx) : mtx(mtx) {
		thread_mutex_lock(mtx);
	}
	~lock_mutex() {
		thread_mutex_unlock(mtx);
	}
};

// no hrtf positional dsp
void basic_positioning_dsp(void* buffer, unsigned int length, float x, float y, float z, float pan_step, float volume_step) {
	if (!buffer || length < 2)
		return;
	float volume = 1.0 - (floorf(sqrtf(pow(fabs(x), 2) + pow(fabs(y), 2) + pow(fabs(z), 2)))) / (125.0 / volume_step);
	float pan = x / (125.0 / pan_step);
	if (pan < -1.0) pan = -1.0;
	else if (pan > 1.0) pan = 1.0;
	if (volume < 0.0) volume = 0.0;
	else if (volume > 1.0) volume = 1.0;
	float* f = (float*)buffer;
	for (; length; length -= 8, f += 2) {
		float amp = 0;
		if (volume > 0)
			amp = pow(10.0f, (volume * 100 - 100) / 20.0);
		f[0] *= amp;
		f[1] *= amp;
		if (pan < 0)
			f[1] = f[1] * pow(10.0f, ((1 + pan) * 100 - 100) / 20.0);
		else if (pan > 0)
			f[0] = f[0] * pow(10.0f, ((1 - pan) * 100 - 100) / 20.0);
	}
}

// Uses steam audio to position the sound and add other effects to it such as reverb and occlusion. Sorry if this is a bit messy, this function has seen some evolution to say the least as different things were tested and so as to not break compatibility with existing code, this should probably be cleaned up as time goes on.
void phonon_dsp(void* buffer, unsigned int length, float x, float y, float z, sound_base& s) {
	if (!buffer || length < 2 || !hrtf || !s.hrtf_effect)
		return;
	float blend = (fabs(x * s.pan_step) + fabs(y * s.pan_step) + fabs(z * s.pan_step)) / 3;
	if (blend > 1.0)
		blend = 1.0;
	if (blend < 0.0)
		blend = 0.0;
	// Todo: Maybe we should allocate these differently?
	static thread_local float in_left[hrtf_framesize * 2], in_right[hrtf_framesize * 2], out_left[hrtf_framesize * 2], out_right[hrtf_framesize * 2], tmp_mono[hrtf_framesize * 2], in_mono[hrtf_framesize * 2], reflections1[hrtf_framesize * 2], reflections2[hrtf_framesize * 2], reflections3[hrtf_framesize * 2], reflections4[hrtf_framesize * 2], reflections5[hrtf_framesize * 2], reflections6[hrtf_framesize * 2], reflections7[hrtf_framesize * 2], reflections8[hrtf_framesize * 2], reflections9[hrtf_framesize * 2], reflections_downmix_left[hrtf_framesize * 2], reflections_downmix_right[hrtf_framesize * 2];
	float* in_data[] = {in_left, in_right};
	float* out_data[] = {out_left, out_right};
	float* tmp_mono_data[] = {tmp_mono};
	float* in_mono_data[] = {in_mono};
	float* reflections_data[] = {reflections1, reflections2, reflections3, reflections4, reflections5, reflections6, reflections7, reflections8, reflections9};
	float* reflections_downmix_data[] = {reflections_downmix_left, reflections_downmix_right};
	int samples = length / sizeof(float) / 2;
	IPLAudioBuffer inbuffer {2, samples, in_data };
	IPLAudioBuffer outbuffer {2, samples, out_data };
	IPLAudioBuffer mono_tmp_buffer {1, samples, tmp_mono_data};
	IPLAudioBuffer mono_inbuffer {1, samples, in_mono_data};
	IPLAudioBuffer reflections_outbuffer{ 9, samples, reflections_data };
	IPLAudioBuffer reflections_downmix_buffer {2, samples, reflections_downmix_data};
	if (!s.env) {
		// simple distance rolloff in the case of no set sound_environment
		float volume = 1.0 - (floorf(sqrtf(pow(fabs(x), 2) + pow(fabs(y), 2) + pow(fabs(z), 2)))) / (125.0 / s.volume_step);
		float* f = (float*)buffer;
		for (; length; length -= 8, f += 2) {
			float amp = 0;
			if (volume > 0)
				amp = pow(10.0f, (volume * 100 - 100) / 20.0);
			f[0] *= amp;
			f[1] *= amp;
		}
	}
	IPLSimulationOutputs src_out{};
	if (s.env) iplSourceGetOutputs(s.source, IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS), &src_out);
	iplAudioBufferDeinterleave(phonon_context, (IPLfloat32*)buffer, &inbuffer);
	iplAudioBufferDownmix(phonon_context, &inbuffer, &mono_inbuffer);
	if (s.env) {
		IPLDirectEffectParams dir_params = src_out.direct;
		dir_params.flags = IPLDirectEffectFlags(IPL_DIRECTEFFECTFLAGS_APPLYDISTANCEATTENUATION | IPL_DIRECTEFFECTFLAGS_APPLYAIRABSORPTION | IPL_DIRECTEFFECTFLAGS_APPLYOCCLUSION);
		iplDirectEffectApply(s.direct_effect, &dir_params, &mono_inbuffer, &mono_tmp_buffer);
	}
	if ((x != 0 || y != 0 || z != 0) && s.hrtf_effect) {
		IPLBinauralEffectParams effect_args{};
		effect_args.direction = iplCalculateRelativeDirection(phonon_context, IPLVector3{s.x, s.y, s.z}, s.env ? IPLVector3{s.env->listener_x, s.env->listener_y, s.env->listener_z} : IPLVector3{s.listener_x, s.listener_y, s.listener_z}, s.env ? IPLVector3{sin(s.env->listener_rotation), cos(s.env->listener_rotation), 0} : IPLVector3{sin(s.rotation), cos(s.rotation), 0}, IPLVector3{0, 0, 1});
		effect_args.interpolation = IPL_HRTFINTERPOLATION_BILINEAR;
		effect_args.spatialBlend = blend;
		effect_args.hrtf = phonon_hrtf;
		iplBinauralEffectApply(s.hrtf_effect, &effect_args, s.env ? &mono_tmp_buffer : &inbuffer, &outbuffer);
	} else { // Sound is at the same position as the listener, direct copy to output buffer
		memcpy(out_left, in_left, sizeof(float) * hrtf_framesize * 2);
		memcpy(out_right, in_right, sizeof(float) * hrtf_framesize * 2);
	}
	if (s.env) { // reflections
		IPLReflectionEffectParams reflect_params = src_out.reflections;
		reflect_params.numChannels = 9;
		reflect_params.irSize = 88200;
		iplReflectionEffectApply(s.reflection_effect, &reflect_params, &mono_inbuffer, &reflections_outbuffer, NULL);
		// spacialize reflections
		// IPLCoordinateSpace3{IPLVector3{1, 0, 0}, IPLVector3{0, 0, 1}, IPLVector3{0, 1, 0}, IPLVector3{s.x, s.y, s.z}}
		IPLAmbisonicsDecodeEffectParams dec_params{2, phonon_hrtf_reflections, s.env->sim_inputs.listener, IPL_TRUE};
		iplAmbisonicsDecodeEffectApply(s.reflection_decode_effect, &dec_params, &reflections_outbuffer, &reflections_downmix_buffer);
		iplAudioBufferMix(phonon_context, &reflections_downmix_buffer, &outbuffer);
	}
	iplAudioBufferInterleave(phonon_context, &outbuffer, (IPLfloat32*)buffer);
}

void CALLBACK positioning_dsp(HDSP handle, DWORD channel, void* buffer, DWORD length, void* user) {
	if (!buffer || length < 1 || !user)
		return;
	sound_base* s = (sound_base*)user;
	float x = s->x - s->listener_x;
	float y = s->y - s->listener_y;
	float z = s->z - s->listener_z;
	if (x == 0 && y == 0 && z == 0) {
		if (s->hrtf_effect)
			iplBinauralEffectReset(s->hrtf_effect);
		//if(!s->env) return;
	}
	float rotational_x = x;
	float rotational_y = y;
	if (s->rotation > 0.0) {
		rotational_x = (cosf(s->rotation) * (x)) - (sinf(s->rotation) * (y));
		rotational_y = (sinf(s->rotation) * (x)) + (cosf(s->rotation) * (y));
		x = rotational_x;
		y = rotational_y;
	}
	if (s->hrtf_effect && (!hrtf || !s->use_hrtf)) {
		iplBinauralEffectRelease(&s->hrtf_effect);
		s->hrtf_effect = NULL;
	} else if (!s->hrtf_effect && hrtf && s->use_hrtf) {
		IPLBinauralEffectSettings effect_settings{};
		effect_settings.hrtf = phonon_hrtf;
		iplBinauralEffectCreate(phonon_context, &phonon_audio_settings, &effect_settings, &s->hrtf_effect);
	}
	if (hrtf && s->hrtf_effect && s->use_hrtf)
		phonon_dsp(buffer, length, x, y, z, *s);
	else
		basic_positioning_dsp(buffer, length, x, y, z, s->pan_step, s->volume_step);
}

// Bass fileprocs
// pack
void CALLBACK bass_closeproc_pack(void* user) {
	if (!user)
		return;
	packed_sound snd = (*(packed_sound*)user);
	if (!snd.p)
		return;
	snd.p->stream_close(snd.s);
	free(user);
}
QWORD CALLBACK bass_lenproc_pack(void* user) {
	if (!user)
		return 0xffffffff;
	packed_sound snd = (*(packed_sound*)user);
	if (!snd.p || !snd.p->next_stream_idx)
		return 0xffffffff;
	return snd.p->stream_size(snd.s);
}
DWORD CALLBACK bass_readproc_pack(void* buffer, DWORD length, void* user) {
	if (!user)
		return 0;
	packed_sound* snd = (packed_sound*)user;
	if (!snd->p || !snd->p->next_stream_idx)
		return 0;
	DWORD ret = 0;
	if (snd->snd)
		thread_mutex_lock(&snd->snd->close_mutex);
	if (!snd->snd || (snd->snd->channel || snd->snd->script_loading))
		ret = snd->p->stream_read(snd->s, (BYTE *)buffer, length);
	if (snd->snd)
		thread_mutex_unlock(&snd->snd->close_mutex);
	//if(ret==0) ret=-1;
	return ret;
}
BOOL CALLBACK bass_seekproc_pack(QWORD offset, void* user) {
	if (!user)
		return FALSE;
	packed_sound* snd = (packed_sound*)user;
	if (!snd->p || !snd->p->next_stream_idx)
		return FALSE;
	return snd->p->stream_seek(snd->s, offset, SEEK_SET);
}
// push
void CALLBACK bass_closeproc_push(void* user) {
	return;
}
QWORD CALLBACK bass_lenproc_push(void* user) {
	sound* s = (sound*) user;
	if (s->memstream && s->memstream_size == s->memstream->size())
		return s->memstream_size;
	return 0;
}
DWORD CALLBACK bass_readproc_push(void* buffer, DWORD length, void* user) {
	if (!buffer || !user)
		return 0;
	sound* s = (sound*)user;
	thread_mutex_lock(&s->close_mutex);
	if (s->memstream) {
		if (!s->channel && !s->script_loading) {
			thread_mutex_unlock(&s->close_mutex);
			return -1;
		}
		DWORD l = length;
		DWORD S = s->memstream->size();
		if (s->memstream_pos + l >= s->memstream_size)
			l = s->memstream_size - s->memstream_pos;
		if (l < 1) {
			thread_mutex_unlock(&s->close_mutex);
			return -1;
		}
		if (s->memstream_pos + l >= S)
			l = S - s->memstream_pos;
		if (l < 1) {
			thread_mutex_unlock(&s->close_mutex);
			return 0;
		}
		DWORD bufsize = 128;
		s->AddRef();
		for (DWORD pos = 0; pos < l; pos += bufsize) {
			if (!s->script_loading && !s->output_mixer) {
				thread_mutex_unlock(&s->close_mutex);
				s->Release();
				return -1;
			}
			int size = bufsize;
			if (l - pos < bufsize)
				size = l - pos;
			if (size > l) size = l;
			std::string data;
			try {
				data = s->memstream->substr(s->memstream_pos + pos, size);
				if (s->memstream_legacy_encrypt) {
					for (int i = 0; i < data.size(); i ++) data[i] = sound_data_char_decrypt(data[i], s->memstream_pos + pos + i, s->memstream_size);
				}
				BYTE* ptr = ((BYTE*)buffer) + pos;
				memcpy(ptr, &data[0], size);
			} catch (...) {
				thread_mutex_unlock(&s->close_mutex);
				return -1;
			}
		}
		s->memstream_pos += l;
		thread_mutex_unlock(&s->close_mutex);
		s->Release();
		return l;
	}
	if (s->push_prebuff.size() < length)
		length = s->push_prebuff.size();
	if (length < 1) {
		thread_mutex_unlock(&s->close_mutex);
		return 0;
	}
	copy(s->push_prebuff.begin(), s->push_prebuff.begin() + length, (BYTE*)buffer);
	s->push_prebuff.erase(s->push_prebuff.begin(), s->push_prebuff.begin() + length);
	thread_mutex_unlock(&s->close_mutex);
	return length;
}
BOOL CALLBACK bass_seekproc_push(QWORD offset, void* user) {
	sound* s = (sound*) user;
	if (s->memstream) {
		if (offset >= s->memstream_size)
			return FALSE;
		s->memstream_pos = offset;
		return TRUE;
	}
	return FALSE;
}
// script
void CALLBACK bass_closeproc_script(void* user) {
	if (!user)
		return;
	sound* s = (sound*)user;
	if (!s->close_callback)
		return;
	asIScriptContext* ctx = g_ScriptEngine->RequestContext();
	if (!ctx) return;
	if (ctx->Prepare(s->close_callback) < 0)
		goto finish;
	if (ctx->SetArgObject(0, &s->callback_data) < 0)
		goto finish;
	ctx->Execute();
finish:
	g_ScriptEngine->ReturnContext(ctx);
	asThreadCleanup();
}
QWORD CALLBACK bass_lenproc_script(void* user) {
	if (!user)
		return 0;
	sound* s = (sound*)user;
	unsigned long long ret = 0;
	if (!s->len_callback)
		return 0;
	asIScriptContext* ctx = g_ScriptEngine->RequestContext();
	if (!ctx) return 0;
	if (!ctx || ctx->Prepare(s->len_callback) < 0)
		goto finish;
	if (ctx->SetArgObject(0, &s->callback_data) < 0)
		goto finish;
	if (ctx->Execute() != asEXECUTION_FINISHED)
		goto finish;
	ret = ctx->GetReturnDWord();
finish:
	g_ScriptEngine->ReturnContext(ctx);
	asThreadCleanup();
	return ret;
}
DWORD CALLBACK bass_readproc_script(void* buffer, DWORD length, void* user) {
	if (!user)
		return -1;
	sound* s = (sound*)user;
	int ret = -1;
	std::string data;
	if (!s->read_callback)
		return -1;
	asIScriptContext* ctx = g_ScriptEngine->RequestContext();
	if (!ctx) return -1;
	if (ctx->Prepare(s->read_callback) < 0) goto finish;
	if (ctx->SetArgObject(0, &data) < 0 || ctx->SetArgDWord(1, length) < 0 || ctx->SetArgObject(2, &s->callback_data) < 0)
		goto finish;
	if (ctx->Execute() != asEXECUTION_FINISHED) goto finish;
	ret = ctx->GetReturnDWord();
	if (data.size() > length) data.resize(length);
	if (data.size() > 0)
		memcpy(buffer, &data[0], data.size());
finish:
	g_ScriptEngine->ReturnContext(ctx);
	asThreadCleanup();
	return ret;
}
BOOL CALLBACK bass_seekproc_script(QWORD offset, void* user) {
	if (!user)
		return false;
	sound* s = (sound*)user;
	bool ret = false;
	if (!s->seek_callback)
		return false;
	asIScriptContext* ctx = g_ScriptEngine->RequestContext();
	if (!ctx) return false;
	if (ctx->Prepare(s->seek_callback) < 0)
		goto finish;
	if (ctx->SetArgDWord(0, offset) < 0 || ctx->SetArgObject(1, &s->callback_data) < 0) goto finish;
	if (ctx->Execute() != asEXECUTION_FINISHED) goto finish;
	ret = ctx->GetReturnByte();
finish:
	g_ScriptEngine->ReturnContext(ctx);
	asThreadCleanup();
	return ret;
}

std::unordered_map<std::string, sound_preload*> sound_preloads;
sound_preload* get_sound_preload(const std::string& filename, bool allow_creating = false) {
	lock_mutex scopelock(&preload_mutex);
	auto it = sound_preloads.find(filename);
	if (it == sound_preloads.end()) return NULL;
	if (!allow_creating && it->second->t == -1) return NULL;
	return it->second;
}
typedef struct {
	std::string filename;
	pack* p;
} sound_preload_transport;
void sound_preload_perform(HSTREAM channel, const std::string& filename) {
	if (!channel) return;
	sound_preload* pre = (sound_preload*)malloc(sizeof(sound_preload));
	memset(pre, 0, sizeof(sound_preload));
	pre->t = -1;
	thread_mutex_lock(&preload_mutex);
	sound_preloads[filename] = pre;
	thread_mutex_unlock(&preload_mutex);
	BASS_CHANNELINFO ci;
	BASS_ChannelGetInfo(channel, &ci);
	DWORD len = BASS_ChannelGetLength(channel, BASS_POS_BYTE);
	unsigned char* samples = (unsigned char*)malloc(len + 44);
	len = BASS_ChannelGetData(channel, samples + 44, len | BASS_DATA_FLOAT);
	wav_header h = make_wav_header(len + 44, ci.freq, 32, ci.chans, 3);
	memcpy(samples, &h, 44);
	pre->ref = 1;
	pre->data = samples;
	pre->size = len + 44;
	pre->fn = filename;
	BASS_ChannelSetPosition(channel, 0, BASS_POS_BYTE);
	thread_mutex_lock(&preload_mutex);
	pre->t = ticks();
	thread_mutex_unlock(&preload_mutex);
}
int sound_preload_thread(void* args) {
	sound_preload_transport* t = (sound_preload_transport*)args;
	if (get_sound_preload(t->filename, true)) {
		free(t);
		return 0;
	}
	pack_stream* stream = NULL;
	DWORD channel = 0;
	if (!t->p || !t->p->is_active() || (stream = t->p->stream_open(t->filename, 0)) == NULL)
		channel = BASS_StreamCreateFile(FALSE, t->filename.c_str(), 0, 0, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT);
	else {
		BASS_FILEPROCS prox;
		prox.close = bass_closeproc_pack;
		prox.length = bass_lenproc_pack;
		prox.read = bass_readproc_pack;
		prox.seek = bass_seekproc_pack;
		packed_sound* s = (packed_sound*)malloc(sizeof(packed_sound));
		s->p = t->p;
		s->s = stream;
		s->snd = NULL;
		channel = BASS_StreamCreateFileUser(STREAMFILE_NOBUFFER, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT, &prox, s);
	}
	if (!channel) {
		free(t);
		return 0;
	}
	if (t->p)
		t->p->delay_close = TRUE;
	sound_preload_perform(channel, t->filename);
	if (t->p)
		t->p->delay_close = FALSE;
	free(t);
	BASS_StreamFree(channel);
	return 0;
}
void sound_preload_release(sound_preload* p) {
	if (p->ref > 0)
		p->ref -= 1;
	if (p->ref < 1 && ticks() - p->t > 120000) {
		lock_mutex scopelock(&preload_mutex);
		auto it = sound_preloads.find(p->fn);
		if (it != sound_preloads.end())
			sound_preloads.erase(it);
		p->fn = "";
		free(p->data);
		free(p);
	}
}
static int sound_preloads_clean_counter = 0;
void sound_preloads_clean() {
	if (sound_preloads_clean_counter < 250) {
		sound_preloads_clean_counter += 1;
		return;
	}
	sound_preloads_clean_counter = 0;
	lock_mutex scopelock(&preload_mutex);
	std::unordered_map<std::string, sound_preload*>::iterator i = sound_preloads.begin();
	while (i != sound_preloads.end()) {
		if (i->second->t == -1) {
			i++;
			continue;
		}
		if (i->second->ref > 0 || ticks() - i->second->t < 120000) {
			i++;
			continue;
		}
		free(i->second->data);
		i->second->fn = "";
		free(i->second);
		i = sound_preloads.erase(i);
		i++;
	}
}


int sound_environment_thread(void* args) {
	sound_environment* e = (sound_environment*)args;
	while (e->ref_count > 0)
		e->background_update();
	e->_detach_all();
	return 0;
}
sound_environment::sound_environment() : ref_count(1), sim_inputs({}), scene_needs_commit(false), listener_modified(false) {
	set_global_hrtf(true);
	IPLSimulationSettings simulation_settings{};
	simulation_settings.flags = IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS);
	simulation_settings.sceneType = IPL_SCENETYPE_DEFAULT;
	simulation_settings.reflectionType = IPL_REFLECTIONEFFECTTYPE_CONVOLUTION;
	simulation_settings.maxNumRays = 2048;
	simulation_settings.numDiffuseSamples = 128;
	simulation_settings.maxDuration = 2.0f;
	simulation_settings.maxOrder = 2;
	simulation_settings.maxNumSources = 64;
	simulation_settings.numThreads = 16;
	simulation_settings.samplingRate = phonon_audio_settings.samplingRate;
	simulation_settings.frameSize = phonon_audio_settings.frameSize;
	iplSimulatorCreate(phonon_context, &simulation_settings, &sim);
	IPLSceneSettings scene_settings{};
	scene_settings.type = IPL_SCENETYPE_DEFAULT;
	iplSceneCreate(phonon_context, &scene_settings, &scene);
	sim_inputs.numRays = 2048;
	sim_inputs.numBounces = 32;
	sim_inputs.duration = 2.0f;
	sim_inputs.order = 2;
	sim_inputs.irradianceMinDistance = 1.0f;
	add_material("air", 0, 0, 0, 0, 1, 1, 1);
	add_material("generic", 0.10f, 0.20f, 0.30f, 0.05f, 0.100f, 0.050f, 0.030f);
	add_material("brick", 0.03f, 0.04f, 0.07f, 0.05f, 0.015f, 0.015f, 0.015f);
	add_material("concrete", 0.05f, 0.07f, 0.08f, 0.05f, 0.015f, 0.002f, 0.001f);
	add_material("ceramic", 0.01f, 0.02f, 0.02f, 0.05f, 0.060f, 0.044f, 0.011f);
	add_material("gravel", 0.60f, 0.70f, 0.80f, 0.05f, 0.031f, 0.012f, 0.008f);
	add_material("carpet", 0.24f, 0.69f, 0.73f, 0.05f, 0.020f, 0.005f, 0.003f);
	add_material("glass", 0.06f, 0.03f, 0.02f, 0.05f, 0.060f, 0.044f, 0.011f);
	add_material("plaster", 0.12f, 0.06f, 0.04f, 0.05f, 0.056f, 0.056f, 0.004f);
	add_material("wood", 0.11f, 0.07f, 0.06f, 0.05f, 0.070f, 0.014f, 0.005f);
	add_material("metal", 0.20f, 0.07f, 0.06f, 0.05f, 0.200f, 0.025f, 0.010f);
	add_material("rock", 0.13f, 0.20f, 0.24f, 0.05f, 0.015f, 0.002f, 0.001f);
	iplSimulatorSetScene(sim, scene);
	iplSimulatorCommit(sim);
	env_thread = thread_create(sound_environment_thread, this, THREAD_STACK_SIZE_DEFAULT);
}
sound_environment::~sound_environment() {
	asAtomicDec(ref_count); // ref_count < 0 shuts down thread.
	thread_join(env_thread);
	iplSceneRelease(&scene);
	iplSimulatorRelease(&sim);
}
void sound_environment::add_ref() {
	asAtomicInc(ref_count);
}
void sound_environment::release() {
	if (asAtomicDec(ref_count) < 1)
		delete this;
}
bool sound_environment::add_material(const std::string& name, float absorption_low, float absorption_mid, float absorption_high, float scattering, float transmission_low, float transmission_mid, float transmission_high, bool replace_if_existing) {
	if (!replace_if_existing && materials.find(name) != materials.end()) return false;
	materials[name] = IPLMaterial{{absorption_low, absorption_mid, absorption_high}, scattering, {transmission_low, transmission_mid, transmission_high}};
	return true;
}
bool sound_environment::add_box(const std::string& material, float minx, float maxx, float miny, float maxy, float minz, float maxz) {
	if (materials.find(material) == materials.end()) return false;
	IPLVector3 vertices[8] = {
		{minx, miny, minz},
		{maxx, miny, minz},
		{maxx, maxy, minz},
		{minx, maxy, minz},
		{minx, miny, maxz},
		{maxx, miny, maxz},
		{maxx, maxy, maxz},
		{minx, maxy, maxz}
	};
	IPLTriangle triangles[12] = {
		// floor
		{0, 1, 2},
		{0, 2, 3},
		// back wall
		{0, 1, 5},
		{0, 5, 4},
		// right wall
		{1, 5, 6},
		{1, 6, 2},
		// front wall
		{2, 6, 7},
		{2, 7, 3},
		// left wall
		{3, 7, 0},
		{3, 0, 4},
		// roof
		{4, 5, 6},
		{4, 6, 7},
	};
	IPLint32 material_indexes[12] = {0};
	IPLStaticMeshSettings mesh_settings{8, 12, 1, vertices, triangles, material_indexes, & materials[material]};
	IPLStaticMesh mesh = NULL;
	iplStaticMeshCreate(scene, &mesh_settings, &mesh);
	iplStaticMeshAdd(mesh, scene);
	scene_needs_commit = true;
	return true;
}
bool sound_environment::attach(sound_base* s) {
	if (!s || s->env) return false;
	IPLDirectEffectSettings direct_effect_settings{1};
	iplDirectEffectCreate(phonon_context, &phonon_audio_settings, &direct_effect_settings, &s->direct_effect);
	IPLReflectionEffectSettings reflection_effect_settings{IPL_REFLECTIONEFFECTTYPE_CONVOLUTION, 88200, 9};
	iplReflectionEffectCreate(phonon_context, &phonon_audio_settings, &reflection_effect_settings, &s->reflection_effect);
	IPLAmbisonicsDecodeEffectSettings dec_settings{};
	dec_settings.maxOrder = 2;
	dec_settings.hrtf = phonon_hrtf_reflections;
	dec_settings.speakerLayout = IPLSpeakerLayout{IPL_SPEAKERLAYOUTTYPE_STEREO};
	iplAmbisonicsDecodeEffectCreate(phonon_context, &phonon_audio_settings, &dec_settings, &s->reflection_decode_effect);
	IPLSourceSettings source_settings{IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS)};
	iplSourceCreate(sim, &source_settings, &s->source);
	IPLSimulationInputs inputs{};
	inputs.flags = IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS);
	inputs.directFlags = IPLDirectSimulationFlags(IPL_DIRECTSIMULATIONFLAGS_DISTANCEATTENUATION | IPL_DIRECTSIMULATIONFLAGS_AIRABSORPTION | IPL_DIRECTSIMULATIONFLAGS_OCCLUSION | IPL_DIRECTSIMULATIONFLAGS_TRANSMISSION);
	inputs.distanceAttenuationModel = IPLDistanceAttenuationModel{IPL_DISTANCEATTENUATIONTYPE_DEFAULT};
	inputs.airAbsorptionModel = IPLAirAbsorptionModel{IPL_AIRABSORPTIONTYPE_DEFAULT};
	inputs.source = IPLCoordinateSpace3{IPLVector3{1, 0, 0}, IPLVector3{0, 0, 1}, IPLVector3{0, 1, 0}, IPLVector3{s->x, s->y, s->z}};
	inputs.occlusionType = IPL_OCCLUSIONTYPE_RAYCAST;
	iplSourceSetInputs(s->source, IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS), &inputs);
	iplSourceAdd(s->source, sim);
	iplSimulatorCommit(sim);
	s->env = this;
	this->add_ref();
	attached.push_back(s);
	return true;
}
bool sound_environment::_detach(sound_base* s) {
	iplSourceRemove(s->source, sim);
	iplSimulatorCommit(sim);
	iplAmbisonicsDecodeEffectRelease(&s->reflection_decode_effect);
	iplReflectionEffectRelease(&s->reflection_effect);
	iplDirectEffectRelease(&s->direct_effect);
	iplSourceRelease(&s->source);
	s->source = NULL;
	s->reflection_decode_effect = NULL;
	s->reflection_effect = NULL;
	s->direct_effect = NULL;
	s->env = NULL;
	// Todo: Consider switching to some sort of map for faster removal?
	auto it = std::find(attached.begin(), attached.end(), s);
	if (it != attached.end()) attached.erase(it);
	if (ref_count > 0) s->env_detaching.set();
	return true;
}
void sound_environment::_detach_all() {
	for (sound_base * s : attached) _detach(s);
}
bool sound_environment::detach(sound_base* s) {
	if (!s || s->env != this) return false;
	s->env = NULL;
	detaching.push_back(s);
	s->env_detaching.wait();
	if (ref_count > 0) this->release();
	return true;
}
mixer* sound_environment::new_mixer() {
	mixer* s = new mixer();
	s->use_hrtf = true;
	attach(s);
	if (!s->pos_effect) s->pos_effect = BASS_ChannelSetDSP(s->channel, positioning_dsp, s, 0);
	return s;
}
sound* sound_environment::new_sound() {
	sound* s = new sound();
	attach(s);
	return s;
}
void sound_environment::update() {
	iplSimulatorRunDirect(sim);
}
void sound_environment::background_update() {
	for (sound_base * s : detaching) {
		_detach(s);
		if (ref_count < 1) return;
	}
	detaching.clear();
	if (scene_needs_commit) {
		iplSceneCommit(scene);
		iplSimulatorCommit(sim);
		scene_needs_commit = false;
	}
	if (listener_modified) {
		sim_inputs.listener.right = IPLVector3{1, 0, 0};
		sim_inputs.listener.up = IPLVector3{0, 0, 1};
		sim_inputs.listener.ahead = IPLVector3{sin(listener_rotation), cos(listener_rotation), 0};
		sim_inputs.listener.origin = IPLVector3{listener_x, listener_y, listener_z};
		iplSimulatorSetSharedInputs(sim, IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS), &sim_inputs);
		iplSimulatorCommit(sim);
		listener_modified = false;
		iplSimulatorRunReflections(sim);
	}
	iplSimulatorRunReflections(sim);
}
void sound_environment::set_listener(float x, float y, float z, float rotation) {
	listener_x = x;
	listener_y = y;
	listener_z = z;
	listener_rotation = rotation;
	listener_modified = true;
}


sound::sound() {
	RefCount = 1;
	channel = 0;
	memset(&channel_info, 0, sizeof(BASS_CHANNELINFO));
	pitch = 1.0;
	length = 0.0;
	x = 0.0;
	y = 0.0;
	z = 0.0;
	listener_x = 0.0;
	listener_y = 0.0;
	listener_z = 0.0;
	rotation = 0.0;
	last_x = 1.0;
	last_y = 1.0;
	last_z = 1.0;
	last_rotation = 0.0;
	pan_step = 1;
	volume_step = 1;
	hrtf_effect = NULL;
	pos_effect = 0;
	use_hrtf = TRUE;
	output_mixer = NULL;
	parent_mixer = NULL;
	preload_ref = NULL;
	close_callback = NULL;
	len_callback = NULL;
	read_callback = NULL;
	seek_callback = NULL;
	callback_data = "";
	script_loading = FALSE;
	thread_mutex_init(&close_mutex);
	memstream = NULL;
	memstream_size = 0;
	memstream_pos = 0;
	memstream_legacy_encrypt = false;
}
sound::~sound() {
	if (!sound_initialized)
		return;
	close();
}
void sound_base::AddRef() {
	asAtomicInc(RefCount);
}
void sound_base::Release() {
	if (asAtomicDec(RefCount) < 1) delete this;
}
void sound::Release() {
	if (asAtomicDec(RefCount) < 1) {
		close();
		thread_mutex_term(&close_mutex);
		delete this;
	}
}

BOOL sound::load(const string& filename, pack* containing_pack, BOOL allow_preloads) {
	if (!sound_initialized)
		init_sound();
	if (!sound_initialized)
		return FALSE;
	if (channel)
		close();
	if (strnicmp(filename.c_str(), "http://", 7) == 0 || strnicmp(filename.c_str(), "https:///", 8) == 0 || strnicmp(filename.c_str(), "ftp://", 6) == 0)
		return load_url(filename);
	channel = 0;
	sound_preload* pre = (allow_preloads ? get_sound_preload(filename) : NULL);
	if (pre != NULL) {
		preload_ref = pre;
		pre->ref += 1;
		pre->t = ticks();
		if (pre->data && pre->size)
			channel = BASS_StreamCreateFile(TRUE, pre->data, 0, pre->size, BASS_SAMPLE_FLOAT | BASS_STREAM_DECODE);
	}
	if (!channel) {
		pack_stream* stream = NULL;
		if (!containing_pack || !containing_pack->is_active() || (stream = containing_pack->stream_open(filename, 0)) == NULL) {
			#ifdef WIN32
			// aww I guess bass decided to contribute to the pain of the no UTF8 paths on windows rather than helping developers work around it like everyone else seems to do, so manually convert the UTF8 sound path to UTF16 here. Ugh ugh!
			std::wstring filename_u;
			Poco::UnicodeConverter::convert(filename, filename_u);
			channel = BASS_StreamCreateFile(FALSE, filename_u.c_str(), 0, 0, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT | BASS_UNICODE);
			#else
			channel = BASS_StreamCreateFile(FALSE, filename.c_str(), 0, 0, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT);
			#endif
		} else {
			script_loading = TRUE;
			BASS_FILEPROCS prox;
			prox.close = bass_closeproc_pack;
			prox.length = bass_lenproc_pack;
			prox.read = bass_readproc_pack;
			prox.seek = bass_seekproc_pack;
			packed_sound* s = (packed_sound*)malloc(sizeof(packed_sound));
			s->p = containing_pack;
			s->s = stream;
			s->snd = this;
			channel = BASS_StreamCreateFileUser(STREAMFILE_NOBUFFER, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT, &prox, s);
		}
		if (channel && allow_preloads && !pre) {
			sound_preload_transport* t = (sound_preload_transport*)malloc(sizeof(sound_preload_transport));
			memset(t, 0, sizeof(sound_preload_transport));
			t->filename += filename;
			t->p = containing_pack;
			thread_create(sound_preload_thread, t, THREAD_STACK_SIZE_DEFAULT);
		}
	}
	if (containing_pack) containing_pack->Release();
	return postload(filename);
}

BOOL sound::load_script(asIScriptFunction* close, asIScriptFunction* len, asIScriptFunction* read, asIScriptFunction* seek, const std::string& data, const std::string& preload_filename) {
	if (!sound_initialized)
		init_sound();
	if (!sound_initialized)
		return FALSE;
	if (channel)
		this->close();
	sound_preload* pre = (preload_filename != "" ? get_sound_preload(preload_filename) : NULL);
	if (pre != NULL) {
		preload_ref = pre;
		pre->ref += 1;
		pre->t = ticks();
		if (pre->data && pre->size)
			channel = BASS_StreamCreateFile(TRUE, pre->data, 0, pre->size, BASS_SAMPLE_FLOAT | BASS_STREAM_DECODE);
		if (channel) {
			if (close) close->Release();
			if (len) len->Release();
			if (read) read->Release();
			if (seek) seek->Release();
		}
	}
	if (!channel) {
		if (close_callback) close_callback->Release();
		if (len_callback) len_callback->Release();
		if (read_callback) read_callback->Release();
		if (seek_callback) seek_callback->Release();
		close_callback = close;
		len_callback = len;
		read_callback = read;
		seek_callback = seek;
		BASS_FILEPROCS prox;
		prox.close = bass_closeproc_script;
		prox.length = bass_lenproc_script;
		prox.read = bass_readproc_script;
		prox.seek = bass_seekproc_script;
		script_loading = TRUE;
		channel = BASS_StreamCreateFileUser(STREAMFILE_NOBUFFER, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT, &prox, this);
		if (preload_filename != "" && channel && !pre)
			sound_preload_perform(channel, preload_filename);
	}
	return postload(preload_filename != "" ? preload_filename : "script_stream");
}

BOOL sound::load_memstream(string& data, unsigned int size, const std::string& preload_filename, bool legacy_encrypt) {
	if (!sound_initialized)
		init_sound();
	if (!sound_initialized)
		return FALSE;
	if (channel)
		this->close();
	sound_preload* pre = (preload_filename != "" ? get_sound_preload(preload_filename) : NULL);
	if (pre != NULL) {
		preload_ref = pre;
		pre->ref += 1;
		pre->t = ticks();
		if (pre->data && pre->size)
			channel = BASS_StreamCreateFile(TRUE, pre->data, 0, pre->size, BASS_SAMPLE_FLOAT | BASS_STREAM_DECODE);
	}
	if (!channel) {
		BASS_FILEPROCS prox;
		prox.close = bass_closeproc_push;
		prox.length = bass_lenproc_push;
		prox.read = bass_readproc_push;
		prox.seek = bass_seekproc_push;
		memstream = &data;
		memstream_size = size;
		memstream_pos = 0;
		memstream_legacy_encrypt = legacy_encrypt;
		script_loading = TRUE;
		channel = BASS_StreamCreateFileUser(STREAMFILE_NOBUFFER, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT, &prox, this);
		if (preload_filename != "" && channel && !pre)
			sound_preload_perform(channel, preload_filename);
	}
	return postload(preload_filename != "" ? preload_filename : "script_stream");
}

BOOL sound::load_url(const string& url) {
	if (!sound_initialized)
		init_sound();
	if (!sound_initialized)
		return FALSE;
	if (channel)
		this->close();
	channel = BASS_StreamCreateURL(url.c_str(), 0, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT, NULL, NULL);
	return postload(url);
}

BOOL sound::push_memory(unsigned char* buffer, unsigned int length, BOOL stream_end, int pcm_rate, int pcm_chans) {
	if (!sound_initialized)
		init_sound();
	if (!sound_initialized || !stream_end && length < 1)
		return FALSE;
	if (loaded_filename != "") {
		if (length > 0)
			close();
		else
			return FALSE;
	}
	if (!buffer || !channel && length < 768)
		return FALSE;
	if (!channel) {
		if (!pcm_rate) {
			BASS_FILEPROCS prox;
			prox.close = bass_closeproc_push;
			prox.length = bass_lenproc_push;
			prox.read = bass_readproc_push;
			prox.seek = bass_seekproc_push;
			push_prebuff.insert(push_prebuff.end(), buffer, buffer + length);
			channel = BASS_StreamCreateFileUser(STREAMFILE_BUFFER, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT, &prox, this);
			BASS_ChannelSetAttribute(channel, BASS_ATTRIB_NET_RESUME, 20);
		} else {
			push_prebuff.insert(push_prebuff.end(), buffer, buffer + length);
			channel = BASS_StreamCreate(pcm_rate, pcm_chans, BASS_STREAM_DECODE | BASS_SAMPLE_FLOAT, STREAMPROC_PUSH, NULL);
		}
		if (!postload())
			return FALSE;
		if (push_prebuff.size() > 0 && pcm_rate) {
			BASS_StreamPutData(channel, buffer + (length - push_prebuff.size()), push_prebuff.size());
			push_prebuff.clear();
			if (stream_end)
				BASS_StreamPutData(channel, NULL, BASS_STREAMPROC_END);
		}
		return TRUE;
	}
	bool ret = true;
	if (!pcm_rate)
		push_prebuff.insert(push_prebuff.end(), buffer, buffer + length);
	else {
			ret = BASS_StreamPutData(channel, buffer, length) > 0;
			if (stream_end)
				BASS_StreamPutData(channel, NULL, BASS_STREAMPROC_END);
	}
	return ret;
}
BOOL sound::push_string(const std::string& buffer, BOOL stream_end, int pcm_rate, int pcm_chans) {
	return push_memory((unsigned char*)&buffer[0], buffer.size(), stream_end, pcm_rate, pcm_chans);
}

BOOL sound::postload(const string& filename) {
	if (!channel)
		return FALSE;
	BASS_ChannelGetInfo(channel, &channel_info);
	loaded_filename = filename;
	if (hrtf && !hrtf_effect) {
		IPLBinauralEffectSettings effect_settings{};
		effect_settings.hrtf = phonon_hrtf;
		iplBinauralEffectCreate(phonon_context, &phonon_audio_settings, &effect_settings, &hrtf_effect);
	}
	if (!parent_mixer)
		parent_mixer = g_default_mixer? g_default_mixer : output;
	if (!output_mixer) {
		output_mixer = new mixer(parent_mixer, !env);
		if (listener_x != x || listener_y != y || listener_z != z || env)
			pos_effect = BASS_ChannelSetDSP(output_mixer->channel, positioning_dsp, this, 0);
	} else if (!pos_effect && (listener_x != x || listener_y != y || listener_z != z || env))
		pos_effect = BASS_ChannelSetDSP(output_mixer->channel, positioning_dsp, this, 0);
	store_channel = register_hstream(channel);
	output_mixer->add_sound(*this, TRUE);
	script_loading = FALSE;
	return TRUE;
}

BOOL sound::close() {
	if (channel) {
		stop();
		thread_mutex_lock(&close_mutex);
		if (hrtf_effect) {
			if (output_mixer && pos_effect)
				BASS_ChannelRemoveDSP(output_mixer->channel, pos_effect);
			pos_effect = 0;
			iplBinauralEffectReset(hrtf_effect);
			iplBinauralEffectRelease(&hrtf_effect);
		}
		hrtf_effect = NULL;
		if (env) env->detach(this);
		if (output_mixer) {
			if (parent_mixer)
				parent_mixer->remove_mixer(output_mixer);
			output_mixer->remove_sound(*this, TRUE);
			BASS_StreamFree(output_mixer->channel); // Can't do in mixer destructor, it's being called when I don't want it to and I don't know why.
			output_mixer->channel = 0;
			delete output_mixer;
			output_mixer = NULL;
		}
		BASS_StreamFree(channel);
		unregister_hstream(store_channel);
		channel = 0;
		thread_mutex_unlock(&close_mutex);
		length = 0;
		memset(&channel_info, 0, sizeof(BASS_CHANNELINFO));
		loaded_filename = "";
		push_prebuff.clear();
		memstream = NULL;
		memstream_size = 0;
		memstream_pos = 0;
		memstream_legacy_encrypt = false;
		pitch = 1.0;
		if (preload_ref) {
			sound_preload_release(preload_ref);
			preload_ref = NULL;
		}
		sound_preloads_clean();
		if (close_callback) close_callback->Release();
		if (len_callback) len_callback->Release();
		if (read_callback) read_callback->Release();
		if (seek_callback) seek_callback->Release();
		close_callback = NULL;
		len_callback = NULL;
		read_callback = NULL;
		seek_callback = NULL;
		return TRUE;
	}
	return false;
}

int sound::set_fx(const std::string& fx, int idx) {
	if (!output_mixer)
		output_mixer = new mixer(parent_mixer, TRUE);
	if (!output_mixer)
		return -1;
	return output_mixer->set_fx(fx, idx);
}

BOOL sound::set_mixer(mixer* m) {
	if (!m)
		m = output;
	if (output_mixer) {
		if (parent_mixer)
			parent_mixer->remove_mixer(output_mixer, TRUE);
		if (m && m->add_mixer(output_mixer))
			parent_mixer = m;
		return parent_mixer == m;
	}
	parent_mixer = m;
	return m != NULL;
}

BOOL sound_base::set_position(float listener_x, float listener_y, float listener_z, float sound_x, float sound_y, float sound_z, float rotation, float pan_step, float volume_step) {
	this->listener_x = listener_x;
	this->listener_y = listener_y;
	this->listener_z = listener_z;
	this->x = sound_x;
	this->y = sound_y;
	this->z = sound_z;
	this->rotation = rotation;
	this->pan_step = pan_step;
	this->volume_step = volume_step;
	if (x == listener_x && y == listener_y && z == listener_z && !env) {
		if (pos_effect) {
			BASS_ChannelRemoveDSP(output_mixer ? output_mixer->channel : channel, pos_effect);
			if (hrtf_effect)
				iplBinauralEffectReset(hrtf_effect);
			pos_effect = 0;
		}
	} else if (!pos_effect)
		pos_effect = BASS_ChannelSetDSP(output_mixer ? output_mixer->channel : channel, positioning_dsp, this, 0);
	if (source && env->sim) {
		IPLSimulationInputs inputs{};
		inputs.flags = IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS);
		inputs.directFlags = IPLDirectSimulationFlags(IPL_DIRECTSIMULATIONFLAGS_DISTANCEATTENUATION | IPL_DIRECTSIMULATIONFLAGS_AIRABSORPTION | IPL_DIRECTSIMULATIONFLAGS_OCCLUSION | IPL_DIRECTSIMULATIONFLAGS_TRANSMISSION);
		inputs.distanceAttenuationModel = IPLDistanceAttenuationModel{IPL_DISTANCEATTENUATIONTYPE_DEFAULT};
		inputs.airAbsorptionModel = IPLAirAbsorptionModel{IPL_AIRABSORPTIONTYPE_DEFAULT};
		inputs.source = IPLCoordinateSpace3{IPLVector3{1, 0, 0}, IPLVector3{0, 0, 1}, IPLVector3{0, 1, 0}, IPLVector3{sound_x, sound_y, sound_z}};
		inputs.occlusionType = IPL_OCCLUSIONTYPE_RAYCAST;
		iplSourceSetInputs(source, IPLSimulationFlags(IPL_SIMULATIONFLAGS_DIRECT | IPL_SIMULATIONFLAGS_REFLECTIONS), &inputs);
		iplSimulatorCommit(env->sim);
	}
	return TRUE;
}

BOOL sound::play(bool reset_loop_state) {
	if (!channel)
		return FALSE;
	if (loaded_filename != "" && is_playing())
		return FALSE;
	if (BASS_ChannelIsActive(channel) != BASS_ACTIVE_PLAYING)
		BASS_Mixer_ChannelSetPosition(channel, 0, BASS_POS_BYTE);
	if (reset_loop_state) BASS_ChannelFlags(channel, 0, BASS_SAMPLE_LOOP);
	return !(BASS_Mixer_ChannelFlags(channel, 0, BASS_MIXER_CHAN_PAUSE)&BASS_MIXER_CHAN_PAUSE);
}

BOOL sound::play_wait() {
	if (!play())
		return FALSE;
	QWORD pos = BASS_Mixer_ChannelGetPosition(channel, BASS_POS_BYTE);
	QWORD len = BASS_ChannelGetLength(channel, BASS_POS_BYTE);
	if (len - pos < 0)
		return FALSE;
	double time_to_sleep = BASS_ChannelBytes2Seconds(channel, len - pos) / get_pitch();
	wait(time_to_sleep * 1000);
	return TRUE;
}

BOOL sound::play_looped() {
	if (!play())
		return FALSE;
	BASS_ChannelFlags(channel, BASS_SAMPLE_LOOP, BASS_SAMPLE_LOOP);
	return TRUE;
}

BOOL sound::pause() {
	if (!channel)
		return FALSE;
	if (!is_playing())
		return FALSE;
	BOOL ret = (BASS_Mixer_ChannelFlags(channel, BASS_MIXER_CHAN_PAUSE, BASS_MIXER_CHAN_PAUSE)&BASS_MIXER_CHAN_PAUSE) > 0;
	if (ret && hrtf && hrtf_effect)
		iplBinauralEffectReset(hrtf_effect);
	return ret;
}

BOOL sound::seek(float offset) {
	if (!channel)
		return FALSE;
	QWORD bytes = BASS_ChannelSeconds2Bytes(channel, offset / 1000);
	BOOL ret = BASS_Mixer_ChannelSetPosition(channel, bytes, BASS_POS_BYTE);
	if (ret && hrtf && hrtf_effect)
		iplBinauralEffectReset(hrtf_effect);
	return ret;
}

BOOL sound::stop() {
	if (!channel)
		return FALSE;
	BOOL ret = (BASS_Mixer_ChannelFlags(channel, BASS_MIXER_CHAN_PAUSE, BASS_MIXER_CHAN_PAUSE)&BASS_MIXER_CHAN_PAUSE) > 0;
	BASS_Mixer_ChannelSetPosition(channel, 0, BASS_POS_BYTE);
	if (ret && hrtf && hrtf_effect)
		iplBinauralEffectReset(hrtf_effect);
	return ret;
}

BOOL sound::is_active() {
	return channel > 0 && parent_mixer != NULL;
}

BOOL sound::is_paused() {
	return channel > 0 && parent_mixer && (BASS_Mixer_ChannelFlags(channel, BASS_MIXER_CHAN_PAUSE, 0)&BASS_MIXER_CHAN_PAUSE) > 0;
}

BOOL sound::is_playing() {
	return channel > 0 && parent_mixer && output_mixer && BASS_ChannelIsActive(channel) == BASS_ACTIVE_PLAYING && BASS_Mixer_ChannelGetMixer(channel) == output_mixer->channel && BASS_Mixer_ChannelGetMixer(output_mixer->channel) == parent_mixer->channel && !(BASS_Mixer_ChannelFlags(channel, 0, 0)&BASS_MIXER_CHAN_PAUSE);
}

BOOL sound::is_sliding() {
	return channel > 0 && BASS_ChannelIsSliding(channel, 0) || output_mixer && output_mixer->channel && BASS_ChannelIsSliding(output_mixer->channel, 0);
}

BOOL sound::is_pan_sliding() {
	return channel > 0 && BASS_ChannelIsSliding(channel, BASS_ATTRIB_PAN);
}

BOOL sound::is_pitch_sliding() {
	return channel > 0 && BASS_ChannelIsSliding(channel, BASS_ATTRIB_FREQ);
}

BOOL sound::is_volume_sliding() {
	return channel > 0 && output_mixer && BASS_ChannelIsSliding(output_mixer->channel, BASS_ATTRIB_VOL);
}

float sound::get_length() {
	if (!channel)
		return -1;
	if (length > 0) return length / 1000.0;
	QWORD length;
	if (loaded_filename != "")
		length = BASS_ChannelGetLength(channel, BASS_POS_BYTE);
	else
		length = BASS_ChannelGetData(channel, NULL, BASS_DATA_AVAILABLE);
	if (length > 0)
		return BASS_ChannelBytes2Seconds(channel, length);
	else
		return -1;
}
float sound::get_length_ms() {
	float v = get_length();
	if (v > -1) v *= 1000;
	return v;
}

float sound::get_position() {
	if (!channel)
		return -1;
	QWORD pos = BASS_ChannelGetPosition(channel, BASS_POS_BYTE);
	if (pos > 0)
		return BASS_ChannelBytes2Seconds(channel, pos);
	else
		return -1;
}
float sound::get_position_ms() {
	float v = get_position();
	if (v > -1) v *= 1000;
	return v;
}

float sound::get_pan() {
	if (!channel)
		return 0;
	float pan = 0;
	BASS_ChannelGetAttribute(channel, BASS_ATTRIB_PAN, &pan);
	return pan;
}
float sound::get_pan_alt() {
	return get_pan() * 100;
}

float sound::get_pitch() {
	if (!channel)
		return 0;
	float pitch = 0.0;
	if (!BASS_ChannelGetAttribute(channel, BASS_ATTRIB_FREQ, &pitch))
		return 0.0;
	pitch /= channel_info.freq;
	return pitch;
}
float sound::get_pitch_alt() {
	return get_pitch() * 100;
}

float sound::get_volume() {
	if (!channel)
		return 0;
	float volume = 0;
	if (output_mixer)
		return output_mixer->get_volume();
	BASS_ChannelGetAttribute(channel, BASS_ATTRIB_VOL, &volume);
	return volume;
}
float sound::get_volume_alt() {
	return (get_volume() * 100) - 100;
}

BOOL sound::set_pan(float pan) {
	if (!channel)
		return FALSE;
	if (pan < -1.0 || pan > 1.0)
		return FALSE;
	return BASS_ChannelSetAttribute(channel, BASS_ATTRIB_PAN, pan);
}
BOOL sound::set_pan_alt(float pan) {
	return set_pan(pan / 100);
}

BOOL sound::slide_pan(float pan, unsigned int time) {
	if (!channel)
		return FALSE;
	if (pan < -1.0 || pan > 1.0)
		return FALSE;
	return BASS_ChannelSlideAttribute(channel, BASS_ATTRIB_PAN, pan, time);
}
BOOL sound::slide_pan_alt(float pan, unsigned int time) {
	return slide_pan(pan / 100, time);
}

BOOL sound::set_pitch(float pitch) {
	if (!channel)
		return FALSE;
	if (pitch < 0.05 || pitch > 5.0) return false;
	BASS_ChannelLock(channel, TRUE);
	BOOL r = BASS_ChannelSetAttribute(channel, BASS_ATTRIB_FREQ, channel_info.freq * pitch);
	BASS_ChannelLock(channel, FALSE);
	return r;
}
BOOL sound::set_pitch_alt(float pitch) {
	return set_pitch(pitch / 100);
}

BOOL sound::slide_pitch(float pitch, unsigned int time) {
	if (!channel)
		return FALSE;
	if (pitch < 0.05 || pitch > 5.0) return false;
	return BASS_ChannelSlideAttribute(channel, BASS_ATTRIB_FREQ, channel_info.freq * pitch, time);
}
BOOL sound::slide_pitch_alt(float pitch, unsigned int time) {
	return slide_pitch(pitch / 100, time);
}

BOOL sound::set_volume(float volume) {
	if (!channel)
		return FALSE;
	if (volume < 0) volume = 0.0;
	if (volume > 1) volume = 1.0;
	if (output_mixer)
		return output_mixer->set_volume(volume);
	else
		return BASS_ChannelSetAttribute(channel, BASS_ATTRIB_VOL, volume);
}
BOOL sound::set_volume_alt(float volume) {
	return set_volume((volume + 100) / 100);
}

BOOL sound::slide_volume(float volume, unsigned int time) {
	if (!channel)
		return FALSE;
	if (volume < 0.0 || volume > 1.0)
		return FALSE;
	if (output_mixer)
		return output_mixer->slide_volume(volume, time);
	else
		return BASS_ChannelSlideAttribute(channel, BASS_ATTRIB_VOL, volume, time);
}
BOOL sound::slide_volume_alt(float volume, unsigned int time) {
	return slide_volume((volume + 100) / 100, time);
}
/**
 * A dummy version of sound.pitch_lower_limit that just returns const 0 all the time.
 * Since this is not using legacy DirectSound there's no need for this API except for BGT compat.
 */
const double sound::pitch_lower_limit()
{
	return 0;
}

int mixer::get_effect_index(const std::string& id) {
	if (id.size() < 2) return -1;
	for (DWORD i = 0; i < effects.size(); i++) {
		if (effects[i].id == id) return i;
	}
	return -1;
}

mixer::mixer(mixer* parent, BOOL for_single_sound, BOOL for_decode, BOOL floatingpoint) {
	if (!sound_initialized)
		init_sound();
	RefCount = 1;
	if (!parent)
		parent = output;
	parent_mixer = parent;
	if (!parent) {
		channel = BASS_Mixer_StreamCreate(44100, 2, BASS_MIXER_NONSTOP | (floatingpoint ? BASS_SAMPLE_FLOAT : 0));
		BASS_ChannelSetAttribute(channel, BASS_ATTRIB_BUFFER, 0);
		//BASS_ChannelSetAttribute(channel, BASS_ATTRIB_MIXER_THREADS, 16);
		BASS_ChannelPlay(channel, TRUE);
		store_channel = register_hstream(channel);
	} else {
		if (!for_single_sound)
			channel = BASS_Mixer_StreamCreate(44100, 2, BASS_STREAM_DECODE | BASS_MIXER_NONSTOP | (floatingpoint ? BASS_SAMPLE_FLOAT : 0));
		else
			channel = BASS_Mixer_StreamCreate(44100, 2, BASS_STREAM_DECODE | (floatingpoint ? BASS_SAMPLE_FLOAT : 0));
		if (!for_decode)
			set_mixer(parent);
		else
			parent_mixer = NULL;
	}
	output_mixer = NULL;
	hrtf_effect = NULL;
	pos_effect = 0;
}

mixer::~mixer() {
	if (this != output) {
		for (auto i : mixers)
			i->set_mixer(output);
		for (auto i : sounds)
			i->set_mixer(output);
	}
	mixers.clear();
	sounds.clear();
}

void mixer::AddRef() {
	asAtomicInc(RefCount);
}
void mixer::Release() {
	if (asAtomicDec(RefCount) < 1)
		delete this;
}

int mixer::get_data(const unsigned char* buffer, int bufsize) {
	if (!channel) return 0;
	return BASS_ChannelGetData(channel, (void*)buffer, bufsize);
}

BOOL mixer::add_mixer(mixer* m) {
	if (!sound_initialized)
		init_sound();
	if (find(mixers.begin(), mixers.end(), m) != mixers.end())
		return FALSE;
	if (!channel || !m->channel)
		return FALSE;
	if (BASS_Mixer_ChannelGetMixer(m->channel) == channel)
		return FALSE;
	else if (BASS_Mixer_ChannelGetMixer(m->channel) == output->channel)
		return FALSE;
	else if (BASS_Mixer_ChannelGetMixer(m->channel) > 0)
		return FALSE;
	BOOL ret = BASS_Mixer_StreamAddChannel(channel, m->channel, BASS_MIXER_CHAN_NORAMPIN);
	if (ret) {
		m->parent_mixer = this;
		mixers.insert(m);
	}
	return ret;
}
BOOL mixer::remove_mixer(mixer* m, BOOL internal) {
	auto i = find(mixers.begin(), mixers.end(), m);
	if (i == mixers.end())
		return FALSE;
	mixers.erase(i);
	BASS_Mixer_ChannelRemove(m->channel);
	if (internal)
		return TRUE;
	m->parent_mixer = NULL;
	m->set_mixer(NULL);
	return TRUE;
}
BOOL mixer::add_sound(sound& s, BOOL internal) {
	if (!sound_initialized)
		init_sound();
	if (sounds.find(&s) != sounds.end())
		return FALSE;
	BOOL ret = BASS_Mixer_StreamAddChannel(channel, s.channel, BASS_MIXER_CHAN_NORAMPIN | BASS_MIXER_CHAN_PAUSE);
	if (ret) {
		if (!internal)
			s.parent_mixer = this;
		sounds.insert(&s);
	}
	return ret;
}
BOOL mixer::remove_sound(sound& s, BOOL internal) {
	auto i = find(sounds.begin(), sounds.end(), &s);
	if (i == sounds.end())
		return FALSE;
	sounds.erase(i);
	if (internal)
		return TRUE;
	s.parent_mixer = NULL;
	BASS_Mixer_ChannelRemove(s.channel);
	s.set_mixer(NULL);
	return TRUE;
}

int mixer::set_fx(const std::string& fx, int idx) {
	if(fx.size()<1) {
		if(idx>=0&&idx<effects.size()) {
			for(DWORD i=idx+1; i<effects.size(); i++)
				BASS_FXSetPriority(effects[i].hfx, i);
			BASS_ChannelRemoveFX(channel, effects[idx].hfx);
			effects.erase(effects.begin()+idx);
			return TRUE;
		} else if(idx==-1) {
			for(DWORD i=0; i<effects.size(); i++) {
				BASS_ChannelRemoveFX(channel, effects[i].hfx);
			}
			effects.clear();
			return TRUE;
		} else
			return -1;
	}
	vector<string> args;
	string fxt=fx;
	char* arg=strtok(&fxt.front(), ":");
	while(arg) {
		args.push_back(arg);
		arg=strtok(NULL, ":");
	}
	if(args.size()<1)
		return -1;
	else if(args.size()==1&&args[0].size()>0&&args[0][0]=='$') {
		for(DWORD idx=0; idx<effects.size(); idx++) {
			if(strncmp(effects[idx].id, args[0].c_str(), args[0].size())==0) {
				for(DWORD i=idx+1; i<effects.size(); i++)
					BASS_FXSetPriority(effects[i].hfx, i);
				BASS_ChannelRemoveFX(channel, effects[idx].hfx);
				effects.erase(effects.begin()+idx);
				idx-=1;
			}
		}
		return 1;
	}
	string effect_id;
	if(args[0].size()>0&&args[0][0]=='$') {
		effect_id=args[0];
		args.erase(args.begin());
	}
	mixer_effect e;
	e.type=0;
	e.id[0]=0;
	if(effect_id!="")
		strncpy(e.id, effect_id.c_str(), 32);
	BYTE effect_settings[512];
	// effects
	if(args[0]=="i3DL2reverb"&&args.size()>12) {
		e.type=BASS_FX_DX8_I3DL2REVERB;
		BASS_DX8_I3DL2REVERB settings= {strtol(args[1].c_str(), NULL, 10), strtol(args[2].c_str(), NULL, 10), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), strtof(args[5].c_str(), NULL), strtol(args[6].c_str(), NULL, 10), strtof(args[7].c_str(), NULL), strtol(args[8].c_str(), NULL, 10), strtof(args[9].c_str(), NULL), strtof(args[10].c_str(), NULL), strtof(args[11].c_str(), NULL), strtof(args[12].c_str(), NULL)};
		memcpy(&effect_settings, &settings, sizeof(BASS_DX8_I3DL2REVERB));
	} else if(args[0]=="reverb"&&args.size()>4) {
		e.type=BASS_FX_DX8_REVERB;
		BASS_DX8_REVERB settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL)};
		memcpy(&effect_settings, &settings, sizeof(BASS_DX8_REVERB));
	} else if(args[0]=="rotate"&&args.size()>1) {
		e.type=BASS_FX_BFX_ROTATE;
		BASS_BFX_ROTATE settings= {strtof(args[1].c_str(), NULL), -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_ROTATE));
	} else if(args[0]=="volume"&&args.size()>1) {
		float volume=strtof(args[1].c_str(), NULL);
		float amp=pow(10.0f, (volume*100.0-100)/20.0);
		e.type=BASS_FX_BFX_VOLUME;
		BASS_BFX_VOLUME settings= {-1, amp};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_VOLUME));
	} else if(args[0]=="lvolume"&&args.size()>1) {
		e.type=BASS_FX_BFX_VOLUME;
		BASS_BFX_VOLUME settings= {-1, strtof(args[1].c_str(), NULL)};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_VOLUME));
	} else if(args[0]=="highpass"&&args.size()>3) {
		e.type=BASS_FX_BFX_BQF;
		BASS_BFX_BQF settings= {BASS_BFX_BQF_HIGHPASS, strtof(args[1].c_str(), NULL), 0, strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), 0, -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_BQF));
	} else if(args[0]=="lowpass"&&args.size()>3) {
		e.type=BASS_FX_BFX_BQF;
		BASS_BFX_BQF settings= {BASS_BFX_BQF_LOWPASS, strtof(args[1].c_str(), NULL), 0, strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), 0, -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_BQF));
	} else if(args[0]=="bandpass"&&args.size()>3) {
		e.type=BASS_FX_BFX_BQF;
		BASS_BFX_BQF settings= {BASS_BFX_BQF_BANDPASS, strtof(args[1].c_str(), NULL), 0, strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), 0, -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_BQF));
	} else if(args[0]=="damp"&&args.size()>5) {
		e.type=BASS_FX_BFX_DAMP;
		BASS_BFX_DAMP settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), strtof(args[5].c_str(), NULL), -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_DAMP));
	} else if(args[0]=="autowah"&&args.size()>6) {
		e.type=BASS_FX_BFX_AUTOWAH;
		BASS_BFX_AUTOWAH settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), strtof(args[5].c_str(), NULL), strtof(args[6].c_str(), NULL), -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_AUTOWAH));
	} else if(args[0]=="phaser"&&args.size()>6) {
		e.type=BASS_FX_BFX_PHASER;
		BASS_BFX_PHASER settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), strtof(args[5].c_str(), NULL), strtof(args[6].c_str(), NULL), -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_PHASER));
	} else if(args[0]=="chorus"&&args.size()>6) {
		e.type=BASS_FX_BFX_CHORUS;
		BASS_BFX_CHORUS settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), strtof(args[5].c_str(), NULL), strtof(args[6].c_str(), NULL), -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_CHORUS));
	} else if(args[0]=="distortion"&&args.size()>5) {
		e.type=BASS_FX_BFX_DISTORTION;
		BASS_BFX_DISTORTION settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), strtof(args[5].c_str(), NULL), -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_DISTORTION));
	} else if(args[0]=="compressor2"&&args.size()>5) {
		e.type=BASS_FX_BFX_COMPRESSOR2;
		BASS_BFX_COMPRESSOR2 settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), strtof(args[5].c_str(), NULL), -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_COMPRESSOR2));
	} else if(args[0]=="echo4"&&args.size()>5) {
		e.type=BASS_FX_BFX_ECHO4;
		BASS_BFX_ECHO4 settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), args[5]=="1", -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_ECHO4));
	} else if(args[0]=="pitchshift"&&args.size()>1) {
		e.type=BASS_FX_BFX_PITCHSHIFT;
		BASS_BFX_PITCHSHIFT settings= {strtof(args[1].c_str(), NULL), (args.size()>2? strtof(args[2].c_str(), NULL) : 0.0f), 2048, 16, -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_PITCHSHIFT));
	} else if(args[0]=="freeverb"&&args.size()>5) {
		e.type=BASS_FX_BFX_FREEVERB;
		BASS_BFX_FREEVERB settings= {strtof(args[1].c_str(), NULL), strtof(args[2].c_str(), NULL), strtof(args[3].c_str(), NULL), strtof(args[4].c_str(), NULL), strtof(args[5].c_str(), NULL), (DWORD)(args.size()>6&&args[6]=="1"? BASS_BFX_FREEVERB_MODE_FREEZE : 0), -1};
		memcpy(&effect_settings, &settings, sizeof(BASS_BFX_FREEVERB));
	} else
		return -1;
	int id_idx=get_effect_index(e.id);
	if(id_idx==-1&&idx>=0&&idx<effects.size()) {
		for(DWORD i=idx; i<effects.size(); i++) {
			if(effects[i].hfx)
				BASS_FXSetPriority(effects[i].hfx, i+1);
		}
	}
	if(id_idx<0) {
		e.hfx=BASS_ChannelSetFX(channel, e.type, (idx>=0&&idx<effects.size()? idx+1 : effects.size()+1));
		if(!e.hfx)
			return -1;
	} else {
		if(effects[id_idx].type!=e.type)
			return -1;
		e.hfx=effects[id_idx].hfx;
	}
	BASS_FXSetParameters(e.hfx, effect_settings);
	if(id_idx>-1) return id_idx;
	if(idx>=0&&idx<effects.size()) {
		effects.insert(effects.begin()+idx, e);
		return idx;
	}
	effects.push_back(e);
	return effects.size()-1;
}

BOOL mixer::set_mixer(mixer* m) {
	if (!m)
		m = output;
	if (this == output)
		return FALSE;
	if (parent_mixer)
		parent_mixer->remove_mixer(this, TRUE);
	if (m)
		return m->add_mixer(this);
	return false;
}

BOOL mixer::is_sliding() {
	return channel > 0 && BASS_ChannelIsSliding(channel, 0);
}

BOOL mixer::is_pan_sliding() {
	return channel > 0 && BASS_ChannelIsSliding(channel, BASS_ATTRIB_PAN);
}

BOOL mixer::is_pitch_sliding() {
	return channel > 0 && BASS_ChannelIsSliding(channel, BASS_ATTRIB_FREQ);
}

BOOL mixer::is_volume_sliding() {
	return channel > 0 && BASS_ChannelIsSliding(channel, BASS_ATTRIB_VOL);
}

float mixer::get_pan() {
	if (!channel)
		return 0;
	float pan = 0;
	BASS_ChannelGetAttribute(channel, BASS_ATTRIB_PAN, &pan);
	return pan;
}
float mixer::get_pan_alt() {
	return get_pan() * 100;
}

float mixer::get_pitch() {
	if (!channel)
		return 0;
	float pitch = 0.0;
	if (!BASS_ChannelGetAttribute(channel, BASS_ATTRIB_FREQ, &pitch))
		return 0.0;
	pitch /= 44100;
	return pitch;
}
float mixer::get_pitch_alt() {
	return get_pitch() * 100;
}

float mixer::get_volume() {
	if (!channel)
		return 0;
	float volume = 0;
	BASS_ChannelGetAttribute(channel, BASS_ATTRIB_VOL, &volume);
	return volume;
}
float mixer::get_volume_alt() {
	return (get_volume() * 100) - 100;
}

BOOL mixer::set_pan(float pan) {
	if (!channel)
		return FALSE;
	if (pan < -1.0 || pan > 1.0)
		return FALSE;
	return BASS_ChannelSetAttribute(channel, BASS_ATTRIB_PAN, pan);
}
BOOL mixer::set_pan_alt(float pan) {
	return set_pan(pan / 100);
}

BOOL mixer::slide_pan(float pan, unsigned int time) {
	if (!channel)
		return FALSE;
	if (pan < -1.0 || pan > 1.0)
		return FALSE;
	return BASS_ChannelSlideAttribute(channel, BASS_ATTRIB_PAN, pan, time);
}
BOOL mixer::slide_pan_alt(float pan, unsigned int time) {
	return slide_pan(pan / 100, time);
}

BOOL mixer::set_pitch(float pitch) {
	if (!channel)
		return FALSE;
	if (pitch < 0.05 || pitch > 5.0)
		return FALSE;
	return BASS_ChannelSetAttribute(channel, BASS_ATTRIB_FREQ, 44100 * pitch);
}
BOOL mixer::set_pitch_alt(float pitch) {
	return set_pitch(pitch / 100);
}

BOOL mixer::slide_pitch(float pitch, unsigned int time) {
	if (!channel)
		return FALSE;
	if (pitch < 0.05 || pitch > 5.0)
		return FALSE;
	return BASS_ChannelSlideAttribute(channel, BASS_ATTRIB_FREQ, 44100 * pitch, time);
}
BOOL mixer::slide_pitch_alt(float pitch, unsigned int time) {
	return slide_pitch(pitch / 100, time);
}

BOOL mixer::set_volume(float volume) {
	if (!channel)
		return FALSE;
	if (volume < 0) volume = 0.0;
	if (volume > 1) volume = 1.0;
	return BASS_ChannelSetAttribute(channel, BASS_ATTRIB_VOL, volume);
}
BOOL mixer::set_volume_alt(float volume) {
	return set_volume((volume + 100) / 100);
}

BOOL mixer::slide_volume(float volume, unsigned int time) {
	if (!channel)
		return FALSE;
	if (volume < 0.0 || volume > 1.0)
		return FALSE;
	return BASS_ChannelSlideAttribute(channel, BASS_ATTRIB_VOL, volume, time);
}
BOOL mixer::slide_volume_alt(float volume, unsigned int time) {
	return slide_volume((volume + 100) / 100, time);
}



float get_master_volume() {
	if (!sound_initialized)
		init_sound();
	return BASS_GetConfig(BASS_CONFIG_GVOL_STREAM) / 10000.0;
}
float get_master_volume_r() {
	float v = get_master_volume() - 1.0;
	return v * 100;
}
BOOL set_master_volume(float volume) {
	if (!sound_initialized)
		init_sound();
	return BASS_SetConfig(BASS_CONFIG_GVOL_STREAM, volume * 10000);
}
BOOL set_master_volume_r(float volume) {
	volume /= 100.0;
	return set_master_volume(volume + 1.0);
}
unsigned int get_input_device() {
	if (!sound_initialized)
		init_sound();
	return BASS_RecordGetDevice();
}
unsigned int get_input_device_count() {
	if (!sound_initialized)
		init_sound();
	BASS_DEVICEINFO inf;
	DWORD count = 0;
	for (DWORD i = 0; BASS_RecordGetDeviceInfo(i, &inf); i++) {
		if (!(inf.flags & BASS_DEVICE_LOOPBACK) && inf.flags & BASS_DEVICE_ENABLED)
			count++;
	}
	return count;
}
unsigned int get_input_device_name(unsigned int device, char* buffer, unsigned int bufsize) {
	if (!sound_initialized)
		init_sound();
	BASS_DEVICEINFO i;
	if (!BASS_RecordGetDeviceInfo(device, &i))
		return 0;
	DWORD namelen = strlen(i.name);
	if (bufsize < namelen)
		return namelen;
	strncpy(buffer, i.name, namelen);
	return namelen;
}
CScriptArray* list_input_devices() {
	DWORD count = get_input_device_count();
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
	CScriptArray* array = CScriptArray::Create(arrayType, count);
	for (int i = 0; i < count; i++) {
		char devname[512];
		int r = get_input_device_name(i, devname, 512);
		devname[r] = 0;
		((string*)(array->At(i)))->assign(devname);
	}
	return array;
}
BOOL set_input_device(unsigned int device) {
	if (!sound_initialized)
		init_sound();
	if (!BASS_RecordInit(device))
		return FALSE;
	return BASS_RecordSetDevice(device);
}
unsigned int get_output_device() {
	if (!sound_initialized)
		init_sound();
	return BASS_GetDevice();
}
unsigned int get_output_device_count() {
	if (!sound_initialized)
		init_sound();
	BASS_DEVICEINFO inf;
	DWORD count = 0;
	for (DWORD i = 0; BASS_GetDeviceInfo(i, &inf); i++)
		count++;
	return count;
}
unsigned int get_output_device_name(unsigned int device, char* buffer, unsigned int bufsize) {
	if (!sound_initialized)
		init_sound();
	BASS_DEVICEINFO i;
	if (!BASS_GetDeviceInfo(device, &i))
		return 0;
	DWORD namelen = strlen(i.name);
	if (bufsize < namelen)
		return namelen;
	strncpy(buffer, i.name, namelen);
	return namelen;
}
CScriptArray* list_output_devices() {
	DWORD count = get_output_device_count();
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();
	asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
	CScriptArray* array = CScriptArray::Create(arrayType, count);
	for (int i = 0; i < count; i++) {
		char devname[512];
		int r = get_output_device_name(i, devname, 512);
		devname[r] = 0;
		((string*)(array->At(i)))->assign(devname);
	}
	return array;
}
BOOL set_output_device(unsigned int device) {
	if (!sound_initialized)
		init_sound(device);
	else
		BASS_Init(device, 44100, 0, NULL, NULL);
	BOOL ret = BASS_SetDevice(device);
	if (ret) {
		for (hstream_entry * e = last_channel; e; e = e->p)
			BASS_ChannelSetDevice(e->channel, device);
	}
	return ret;
}

BOOL get_global_hrtf() {
	return hrtf;
}
BOOL set_global_hrtf(BOOL enable) {
	init_sound();
	if (enable && !phonon_context) {
		IPLContextSettings phonon_context_settings{};
		phonon_context_settings.version = STEAMAUDIO_VERSION;
		iplContextCreate(&phonon_context_settings, &phonon_context);
		IPLHRTFSettings phonon_hrtf_settings{};
		phonon_hrtf_settings.type = IPL_HRTFTYPE_DEFAULT;
		phonon_hrtf_settings.volume = 1.0;
		iplHRTFCreate(phonon_context, &phonon_audio_settings, &phonon_hrtf_settings, &phonon_hrtf);
		iplHRTFCreate(phonon_context, &phonon_audio_settings, &phonon_hrtf_settings, &phonon_hrtf_reflections);
		BASS_ChannelSetAttribute(output->channel, BASS_ATTRIB_GRANULE, hrtf_framesize);
	} else if (!enable && phonon_context) {
		iplHRTFRelease(&phonon_hrtf);
		iplContextRelease(&phonon_context);
		phonon_hrtf = NULL;
		phonon_context = NULL;
		BASS_ChannelSetAttribute(output->channel, BASS_ATTRIB_GRANULE, 0);
	}
	hrtf = enable;
	return TRUE;
}

mixer* ScriptMixer_Factory() {
	return new mixer();
}
sound* ScriptSound_Factory() {
	return new sound();
}
sound_environment* ScriptSound_Environment_Factory() {
	return new sound_environment();
}
void RegisterScriptSound(asIScriptEngine* engine) {
	engine->RegisterGlobalProperty("pack@ sound_default_pack", &g_sound_default_pack);
	engine->RegisterFuncdef(_O("void sound_close_callback(string)"));
	engine->RegisterFuncdef(_O("uint sound_length_callback(string)"));
	engine->RegisterFuncdef(_O("int sound_read_callback(string &out, uint, string)"));
	engine->RegisterFuncdef(_O("bool sound_seek_callback(uint, string)"));
	engine->RegisterObjectType("mixer", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("mixer", asBEHAVE_FACTORY, "mixer @m()", asFUNCTION(ScriptMixer_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("mixer", asBEHAVE_ADDREF, "void f()", asMETHOD(mixer, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("mixer", asBEHAVE_RELEASE, "void f()", asMETHOD(mixer, Release), asCALL_THISCALL);
	engine->RegisterObjectType("sound", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("sound", asBEHAVE_FACTORY, "sound @s()", asFUNCTION(ScriptSound_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("sound", asBEHAVE_ADDREF, "void f()", asMETHOD(sound, AddRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("sound", asBEHAVE_RELEASE, "void f()", asMETHOD(sound, Release), asCALL_THISCALL);
	engine->RegisterObjectProperty("sound", "const string loaded_filename", asOFFSET(sound, loaded_filename));
	engine->RegisterObjectMethod("sound", "bool close()", asMETHOD(sound, close), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool load(const string &in filename, pack@ pack_file = sound_default_pack, bool allow_preloads = !system_is_mobile)", asMETHOD(sound, load), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool load(sound_close_callback@, sound_length_callback@, sound_read_callback@, sound_seek_callback@, const string &in, const string&in = \"\")", asMETHOD(sound, load_script), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool load(string& data, uint size, const string&in preload_filename = \"\", bool legacy_encrypt = false)", asMETHOD(sound, load_memstream), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool load_url(const string &in url)", asMETHOD(sound, load_url), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool stream(const string &in filename, pack@ containing_pack = sound_default_pack)", asMETHOD(sound, stream), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool push_memory(const string &in data, bool end_stream = false, int pcm_rate = 0, int pcm_channels = 0)", asMETHOD(sound, push_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool set_position(float listener_x, float listener_y, float listener_z, float sound_x, float sound_y, float sound_z, float rotation = 0.0, float pan_step = 1.0, float volume_step = 1.0)", asMETHOD(sound, set_position), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool set_mixer(mixer@ mixer = null)", asMETHOD(sound, set_mixer), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "void set_hrtf(bool enable = true)", asMETHOD(sound, set_hrtf), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "void set_length(float length = 0.0)", asMETHOD(sound, set_length), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool set_fx(const string &in fx, int index = -1)", asMETHOD(sound, set_fx), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool play(bool reset_loop_state = true)", asMETHOD(sound, play), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool play_wait()", asMETHOD(sound, play_wait), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool play_looped()", asMETHOD(sound, play_looped), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool pause()", asMETHOD(sound, pause), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool stop()", asMETHOD(sound, stop), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool seek(float position)", asMETHOD(sound, seek), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool get_active() const property", asMETHOD(sound, is_active), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool get_playing() const property", asMETHOD(sound, is_playing), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool get_paused() const property", asMETHOD(sound, is_paused), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool get_sliding() const property", asMETHOD(sound, is_sliding), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool get_pan_sliding() const property", asMETHOD(sound, is_pan_sliding), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool get_pitch_sliding() const property", asMETHOD(sound, is_pitch_sliding), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool get_volume_sliding() const property", asMETHOD(sound, is_volume_sliding), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "float get_length() const property", asMETHOD(sound, get_length_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "float get_position() const property", asMETHOD(sound, get_position_ms), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "float get_pitch() const property", asMETHOD(sound, get_pitch_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "void set_pitch(float) property", asMETHOD(sound, set_pitch_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool slide_pitch(float, uint)", asMETHOD(sound, slide_pitch_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "float get_pan() const property", asMETHOD(sound, get_pan_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "void set_pan(float) property", asMETHOD(sound, set_pan_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool slide_pan(float, uint)", asMETHOD(sound, slide_pan_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "float get_volume() const property", asMETHOD(sound, get_volume_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "void set_volume(float) property", asMETHOD(sound, set_volume_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "bool slide_volume(float, uint)", asMETHOD(sound, slide_volume_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound", "double get_pitch_lower_limit() const property", asMETHOD(sound, pitch_lower_limit), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool set_fx(const string &in, int = -1)", asMETHOD(mixer, set_fx), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool set_position(float, float, float, float, float, float, float, float, float)", asMETHOD(mixer, set_position), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool set_mixer(mixer@ = null)", asMETHOD(mixer, set_mixer), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "void set_hrtf(bool = true)", asMETHOD(mixer, set_hrtf), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool get_sliding() const property", asMETHOD(mixer, is_sliding), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool get_pan_sliding() const property", asMETHOD(mixer, is_pan_sliding), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool get_pitch_sliding() const property", asMETHOD(mixer, is_pitch_sliding), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool get_volume_sliding() const property", asMETHOD(mixer, is_volume_sliding), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "float get_pitch() const property", asMETHOD(mixer, get_pitch_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "void set_pitch(float) property", asMETHOD(mixer, set_pitch_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool slide_pitch(float, uint)", asMETHOD(mixer, slide_pitch_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "float get_pan() const property", asMETHOD(mixer, get_pan_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "void set_pan(float) property", asMETHOD(mixer, set_pan_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool slide_pan(float, uint)", asMETHOD(mixer, slide_pan_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "float get_volume() const property", asMETHOD(mixer, get_volume_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "void set_volume(float) property", asMETHOD(mixer, set_volume_alt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mixer", "bool slide_volume(float, uint)", asMETHOD(mixer, slide_volume_alt), asCALL_THISCALL);

	engine->RegisterObjectType("sound_environment", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("sound_environment", asBEHAVE_FACTORY, "sound_environment @s()", asFUNCTION(ScriptSound_Environment_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("sound_environment", asBEHAVE_ADDREF, "void f()", asMETHOD(sound_environment, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("sound_environment", asBEHAVE_RELEASE, "void f()", asMETHOD(sound_environment, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool add_material(const string&in, float, float, float, float, float, float, float, bool = false)", asMETHOD(sound_environment, add_material), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "bool add_box(const string&in, float, float, float, float, float, float)", asMETHOD(sound_environment, add_box), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "mixer@ new_mixer()", asMETHOD(sound_environment, new_mixer), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "sound@ new_sound()", asMETHOD(sound_environment, new_sound), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "void update()", asMETHOD(sound_environment, update), asCALL_THISCALL);
	engine->RegisterObjectMethod("sound_environment", "void set_listener(float, float, float, float)", asMETHOD(sound_environment, set_listener), asCALL_THISCALL);

	engine->RegisterGlobalFunction("bool get_SOUND_AVAILABLE() property", asFUNCTION(sound_available), asCALL_CDECL);
	engine->RegisterGlobalFunction("float get_sound_master_volume() property", asFUNCTION(get_master_volume_r), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_master_volume(float) property", asFUNCTION(set_master_volume_r), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint get_sound_input_device() property", asFUNCTION(get_input_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_input_device(uint) property", asFUNCTION(set_input_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint get_sound_input_device_count() property", asFUNCTION(get_input_device_count), asCALL_CDECL);
	engine->RegisterGlobalFunction("array<string>@ get_sound_input_devices() property", asFUNCTION(list_input_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint get_sound_output_device() property", asFUNCTION(get_output_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_output_device(uint) property", asFUNCTION(set_output_device), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint get_sound_output_device_count() property", asFUNCTION(get_output_device_count), asCALL_CDECL);
	engine->RegisterGlobalFunction("array<string>@ get_sound_output_devices() property", asFUNCTION(list_output_devices), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool get_sound_global_hrtf() property", asFUNCTION(get_global_hrtf), asCALL_CDECL);
	engine->RegisterGlobalFunction("void set_sound_global_hrtf(bool) property", asFUNCTION(set_global_hrtf), asCALL_CDECL);
	engine->RegisterGlobalProperty("mixer@ sound_default_mixer", &g_default_mixer);
}
