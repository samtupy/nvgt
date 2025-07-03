#ifndef el_vb_h
#define el_vb_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>

#include <windows.h>
#include <sapi.h>

/* Based on the minimalistic SAPI handler for VoiceBridge, but more fleshed out. Probably should've done this one first really. */

/* Public API */

typedef struct sbz_sapi sb_sapi;

int sb_sapi_initialise(sb_sapi* sapi);
int sb_sapi_speak(sb_sapi* sapi, char* text, int interrupt);
int sb_sapi_speak_to_memory(sb_sapi* sapi, char* text, void** buffer, int* size);
int sb_sapi_is_speaking(sb_sapi* sapi);
int sb_sapi_stop(sb_sapi* sapi);
int sb_sapi_pause(sb_sapi* sapi);
int sb_sapi_resume(sb_sapi* sapi);
int sb_sapi_set_volume(sb_sapi* sapi, int volume);
int sb_sapi_get_volume(sb_sapi* sapi);
int sb_sapi_set_rate(sb_sapi* sapi, int rate);
int sb_sapi_get_rate(sb_sapi* sapi);
int sb_sapi_set_pitch(sb_sapi* sapi, int pitch);
int sb_sapi_get_pitch(sb_sapi* sapi);
int sb_sapi_refresh_voices(sb_sapi* sapi);
int sb_sapi_count_voices(sb_sapi* sapi);
char* sb_sapi_get_voice_name(sb_sapi* sapi, int id);
int sb_sapi_set_voice(sb_sapi* sapi, int id);
int sb_sapi_get_voice(sb_sapi* sapi);
int sb_sapi_get_channels(sb_sapi* sapi);
int sb_sapi_get_sample_rate(sb_sapi* sapi);
int sb_sapi_get_bit_depth(sb_sapi* sapi);
void sb_sapi_cleanup(sb_sapi* sapi);

/* Internals */

#define sbz_com_begin 0x188CB9C5
#define sbz_com_end 0xDD5902E9

#define sbz_sapi_begin 0xCA143E5A
#define sbz_sapi_end 0xCCBEDE64

typedef struct
{
int begin;
HMODULE ole;
HRESULT(WINAPI* CoInitializeEx)(LPVOID, DWORD);
HRESULT(WINAPI* CoCreateInstance)(REFCLSID, LPUNKNOWN, DWORD, REFIID, LPVOID*);
void(WINAPI* CoTaskMemFree)(void*);
HRESULT(WINAPI* CoUninitialize)(void);
int end;
}
sbz_com;

typedef struct
{
ISpObjectToken* token;
char* name;
}
sbz_sapi_voice;

struct sbz_sapi
{
int begin;
sbz_com com;
ISpVoice* voice;
sbz_sapi_voice* voices;
int voice_count;
int pitch;
int audio_channels;
int audio_bit_depth;
int audio_sample_rate;
int end;
};

int sbz_sapi_is_init(sb_sapi* sapi);
int sbz_sapi_set_init_flag(sb_sapi* sapi);
int sbz_sapi_refresh_voices(sb_sapi* sapi);
int sbz_sapi_get_voice_enum(sb_sapi* sapi, IEnumSpObjectTokens** enum_tokens);
int sbz_sapi_populate_voices_from_tokens(sb_sapi* sapi, IEnumSpObjectTokens** enum_tokens, int count);
int sbz_sapi_speak_to_memory(sb_sapi* sapi, char* text, void** buffer, int* size);
int sbz_sapi_create_memory_stream(sb_sapi* sapi, ISpStream** stream);
int sbz_sapi_capture_stream_output(sb_sapi* sapi, ISpStream* stream, void** buffer, int* size);
int sbz_sapi_cache_audio_attributes(sb_sapi* sapi);
int sbz_sapi_get_waveformatex(sb_sapi* sapi, WAVEFORMATEX** wf);
void sbz_sapi_reset_voice_cache(sb_sapi* sapi);
void sbz_sapi_clean_voice_cache(sb_sapi* sapi);
void sbz_sapi_cleanup(sb_sapi* sapi);
void sbz_sapi_reset(sb_sapi* sapi);

int sbz_com_initialise(sbz_com* com);
int sbz_com_load(sbz_com* com);
int sbz_com_is_init(sbz_com* com);
int sbz_com_set_init_flag(sbz_com* com);
int sbz_com_create_instance(sbz_com* com, CLSID* clsid, IID* iid, void** data);
int sbz_com_free_memory(sbz_com* com, void* data);
void sbz_com_reset(sbz_com* com);
void sbz_com_cleanup(sbz_com* com);

WCHAR* sbz_char_to_wchar(char* text);
char* sbz_wchar_to_char(WCHAR* text);
int sbz_validate_waveformatex(WAVEFORMATEX* wf);

#ifdef __cplusplus
}
#endif

#endif
