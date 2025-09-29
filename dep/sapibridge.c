#include "sapibridge.h"

int sb_sapi_initialise(sb_sapi* sapi)
{
if(!sapi) return 0;
if(sbz_sapi_is_init(sapi)) return 0;
sbz_sapi_reset(sapi);

/* Unfortunately, because we're runtime linking, we have to specify the COM ID sapi manually. */
CLSID CLSID_SpVoice={0x96749377, 0x3391, 0x11D2, {0x9E, 0xE3, 0x00, 0xC0, 0x4F, 0x79, 0x73, 0x96}};
IID IID_ISpVoice={0x6C44DF74, 0x72B9, 0x4992, {0xA1, 0xEC, 0xEF, 0x99, 0x6E, 0x04, 0x22, 0xD4}};
if(!sbz_com_initialise(&sapi->com)) return 0;
if(!sbz_com_create_instance(&sapi->com, &CLSID_SpVoice, &IID_ISpVoice, (void**) &sapi->voice))
{
sbz_sapi_cleanup(sapi);
return 0;
}
if(!sbz_sapi_refresh_voices(sapi))
{
sbz_sapi_cleanup(sapi);
return 0;
}
if(!sbz_sapi_cache_audio_attributes(sapi))
{
sbz_sapi_cleanup(sapi);
return 0;
}
return sbz_sapi_set_init_flag(sapi);
}
int sb_sapi_speak(sb_sapi* sapi, char* text, int interrupt)
{
if(!sbz_sapi_is_init(sapi)) return 0;
if((!text)||(!*text)) return 0;
WCHAR* text_compat=sbz_char_to_wchar(text);
if(!text_compat) return 0;
if(interrupt) sb_sapi_stop(sapi);
HRESULT hr=sapi->voice->lpVtbl->Speak(sapi->voice, text_compat, SPF_DEFAULT|SPF_ASYNC, NULL);
free(text_compat);
if(FAILED(hr)) return 0;
return 1;
}
int sb_sapi_speak_to_memory(sb_sapi* sapi, char* text, void** buffer, int* size)
{
if(!sbz_sapi_is_init(sapi)) return 0;
if((!text)||(!*text)) return 0;
if(!buffer) return 0;
if(!size) return 0;
sb_sapi_stop(sapi);
return sbz_sapi_speak_to_memory(sapi, text, buffer, size);
}
int sb_sapi_is_speaking(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
SPVOICESTATUS status;
HRESULT hr=sapi->voice->lpVtbl->GetStatus(sapi->voice, &status, NULL);
if(FAILED(hr)) return 0;
if(status.dwRunningState!=SPRS_DONE) return 1;
return 0;
}
int sb_sapi_stop(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
sapi->voice->lpVtbl->Speak(sapi->voice, NULL, SPF_PURGEBEFORESPEAK, NULL);
return 1;
}
int sb_sapi_pause(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
HRESULT hr=sapi->voice->lpVtbl->Pause(sapi->voice);
if(FAILED(hr)) return 0;
return 1;
}
int sb_sapi_resume(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
HRESULT hr=sapi->voice->lpVtbl->Resume(sapi->voice);
if(FAILED(hr)) return 0;
return 1;
}
int sb_sapi_set_volume(sb_sapi* sapi, int volume)
{
if(!sbz_sapi_is_init(sapi)) return 0;
if((volume<0)||(volume>100)) return 0;
HRESULT hr=sapi->voice->lpVtbl->SetVolume(sapi->voice, volume);
if(FAILED(hr)) return 0;
return 1;
}
int sb_sapi_get_volume(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
USHORT volume=0;
HRESULT hr=sapi->voice->lpVtbl->GetVolume(sapi->voice, &volume);
if(FAILED(hr)) return 0;
return volume;
}
int sb_sapi_set_rate(sb_sapi* sapi, int rate)
{
if(!sbz_sapi_is_init(sapi)) return 0;
if((rate<-10)||(rate>10)) return 0;
HRESULT hr=sapi->voice->lpVtbl->SetRate(sapi->voice, rate);
if(FAILED(hr)) return 0;
return 1;
}
int sb_sapi_get_rate(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
long rate=0;
HRESULT hr=sapi->voice->lpVtbl->GetRate(sapi->voice, &rate);
if(FAILED(hr)) return 0;
return rate;
}
int sb_sapi_set_pitch(sb_sapi* sapi, int pitch)
{
if(!sbz_sapi_is_init(sapi)) return 0;
if((pitch<-10)||(pitch>10)) return 0;
WCHAR buffer[100];
swprintf(buffer, 100, L"<pitch absmiddle=\"%d\"/>", pitch);
HRESULT hr=sapi->voice->lpVtbl->Speak(sapi->voice, buffer, SPF_IS_XML|SPF_ASYNC, NULL);
if(FAILED(hr)) return 0;
sapi->pitch=pitch;
return 1;
}
int sb_sapi_get_pitch(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
return sapi->pitch;
}
int sb_sapi_refresh_voices(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
return sbz_sapi_refresh_voices(sapi);
}
int sb_sapi_count_voices(sb_sapi* sapi)
{
if(!sb_sapi_refresh_voices(sapi)) return 0;
return sapi->voice_count;
}
char* sb_sapi_get_voice_name(sb_sapi* sapi, int id)
{
if(!sb_sapi_refresh_voices(sapi)) return NULL;
if((id<0)||(id>=sapi->voice_count)) return NULL;
return sapi->voices[id].name;
}
int sb_sapi_set_voice(sb_sapi* sapi, int id)
{
if(!sb_sapi_refresh_voices(sapi)) return 0;
if((id<0)||(id>=sapi->voice_count)) return 0;
HRESULT hr= sapi->voice->lpVtbl->SetVoice(sapi->voice, sapi->voices[id].token);
if(FAILED(hr)) return 0;
 
/* Todo: What should we do if this fails? */
/* Don't want to just return 0 because technically the voice has changed. */
/* But neither do I want to return 1 if there could be a problem with the audio attribute system that might complicate speaking the new voice to memory. */
sbz_sapi_cache_audio_attributes(sapi);
return 1;
}
int sb_sapi_get_voice(sb_sapi* sapi)
{
if(!sb_sapi_refresh_voices(sapi)) return 0;
ISpObjectToken* current=NULL;
if(FAILED(sapi->voice->lpVtbl->GetVoice(sapi->voice, &current))) return -1;
for(int x=0; x<sapi->voice_count; x++)
{
if(sapi->voices[x].token!=current) continue;
current->lpVtbl->Release(current);
return x;
}
current->lpVtbl->Release(current);
return -1;
}
int sb_sapi_get_channels(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
return sapi->audio_channels;
}
int sb_sapi_get_sample_rate(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
return sapi->audio_sample_rate;
}
int sb_sapi_get_bit_depth(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return 0;
return sapi->audio_bit_depth;
}
void sb_sapi_cleanup(sb_sapi* sapi)
{
if(!sbz_sapi_is_init(sapi)) return;
sb_sapi_stop(sapi);
sbz_sapi_cleanup(sapi);
}
int sbz_sapi_is_init(sb_sapi* sapi)
{
if(!sapi) return 0;
if(sapi->begin!=sbz_sapi_begin) return 0;
if(sapi->end!=sbz_sapi_end) return 0;
return 1;
}
int sbz_sapi_set_init_flag(sb_sapi* sapi)
{
if(!sapi) return 0;
sapi->begin=sbz_sapi_begin;
sapi->end=sbz_sapi_end;
return 1;
}
int sbz_sapi_refresh_voices(sb_sapi* sapi)
{
if(!sapi) return 0;
sbz_sapi_clean_voice_cache(sapi);
IEnumSpObjectTokens* enum_tokens=NULL;
if(!sbz_sapi_get_voice_enum(sapi, &enum_tokens)) return 0;
ULONG count=0;
HRESULT hr=enum_tokens->lpVtbl->GetCount(enum_tokens, &count);
if((FAILED(hr))||(count<=0))
{
enum_tokens->lpVtbl->Release(enum_tokens);
return 0;
}
if(!sbz_sapi_populate_voices_from_tokens(sapi, &enum_tokens, count))
{
enum_tokens->lpVtbl->Release(enum_tokens);
return 0;
}
enum_tokens->lpVtbl->Release(enum_tokens);
return 1;
}
int sbz_sapi_get_voice_enum(sb_sapi* sapi, IEnumSpObjectTokens** enum_tokens)
{
if(!sapi) return 0;

/* Like other GUIDs, we're having to declare these manually. */
CLSID CLSID_SpObjectTokenCategory={0xA910187F, 0x0C7A, 0x45AC, {0x92, 0xCC, 0x59, 0xED, 0xAF, 0xB7, 0x7B, 0x53}};
IID IID_ISpObjectTokenCategory={0x2D3D3845, 0x39AF, 0x4850, {0xBB, 0xF9, 0x40, 0xB4, 0x97, 0x80, 0x01, 0x1D}};
ISpObjectTokenCategory* category=NULL;
if(!sbz_com_create_instance(&sapi->com, &CLSID_SpObjectTokenCategory, &IID_ISpObjectTokenCategory, (void**)&category)) return 0;
HRESULT hr=category->lpVtbl->SetId(category, SPCAT_VOICES, FALSE);
if(FAILED(hr))
{
category->lpVtbl->Release(category);
return 0;
}
hr=category->lpVtbl->EnumTokens(category, NULL, NULL, enum_tokens);
category->lpVtbl->Release(category);
if(FAILED(hr)) return 0;
return 1;
}
int sbz_sapi_populate_voices_from_tokens(sb_sapi* sapi, IEnumSpObjectTokens** enum_tokens, int count)
{
if(!sapi) return 0;
sbz_sapi_voice* voice=malloc(sizeof(sbz_sapi_voice)*count);
if(!voice) return 0;
for(int x=0; x<count; x++)
{
ISpObjectToken* token = NULL;
WCHAR* name = NULL;
if((*enum_tokens)->lpVtbl->Next(*enum_tokens, 1, &token, NULL)!=S_OK) break;
if(FAILED(token->lpVtbl->GetStringValue(token, NULL, &name)))
{
token->lpVtbl->Release(token);
continue;
}
char* utf8=sbz_wchar_to_char(name);
sbz_com_free_memory(&sapi->com, name);
if(!utf8)
{
token->lpVtbl->Release(token);
continue;
}
voice[x].token=token;
voice[x].name=utf8;
}
sapi->voices=voice;
sapi->voice_count=count;
return 1;
}
int sbz_sapi_speak_to_memory(sb_sapi* sapi, char* text, void** buffer, int* size)
{
*buffer=NULL;
*size=0;
if(!sapi) return 0;
WCHAR* wtext=sbz_char_to_wchar(text);
if(!wtext) return 0;
ISpStream* stream=NULL;
if(!sbz_sapi_create_memory_stream(sapi, &stream))
{
free(wtext);
return 0;
}
HRESULT hr=sapi->voice->lpVtbl->Speak(sapi->voice, wtext, SPF_DEFAULT, NULL);
free(wtext);
if(FAILED(hr))
{
sapi->voice->lpVtbl->SetOutput(sapi->voice, NULL, TRUE);
stream->lpVtbl->Release(stream);
return 0;
    }
sbz_sapi_cache_audio_attributes(sapi);
int ok=sbz_sapi_capture_stream_output(sapi, stream, buffer, size);
sapi->voice->lpVtbl->SetOutput(sapi->voice, NULL, TRUE);
stream->lpVtbl->Close(stream);
stream->lpVtbl->Release(stream);
return ok;
}
int sbz_sapi_create_memory_stream(sb_sapi* sapi, ISpStream** stream)
{
if(!sbz_sapi_is_init(sapi)) return 0;
if(!stream) return 0;

/* Manual GUID declarations */
CLSID CLSID_SpMemoryStream={0x5FB7EF7D, 0xDFF4, 0x468a, {0xB6, 0xB7, 0x2F, 0xCB, 0xD1, 0x88, 0xF9, 0x94}};
IID IID_ISpStream={0x12E3CCA9, 0x7518, 0x44C5, {0xA5, 0xE7, 0xBA, 0x5A, 0x79, 0xCB, 0x92, 0x9E}};

*stream=NULL;
if(!sbz_com_create_instance(&sapi->com, &CLSID_SpMemoryStream, &IID_ISpStream, (void**) stream)) return 0;
HRESULT hr=sapi->voice->lpVtbl->SetOutput(sapi->voice, (IUnknown*) (*stream), TRUE);
if(FAILED(hr)) return 0;
return 1;
}
int sbz_sapi_capture_stream_output(sb_sapi* sapi, ISpStream* stream, void** buffer, int* size)
{
if(!sbz_sapi_is_init(sapi)) return 0;
if((!stream)||(!buffer)||(!size)) return 0;
*buffer=NULL;
*size = 0;
LARGE_INTEGER zero={0};
ULARGE_INTEGER end_pos;
if(FAILED(stream->lpVtbl->Seek(stream, zero, STREAM_SEEK_END, &end_pos))) return 0;
ULONG total_size=(ULONG) end_pos.QuadPart;
if(total_size<=0) return 0;
if(FAILED(stream->lpVtbl->Seek(stream, zero, STREAM_SEEK_SET, NULL))) return 0;
void* wav=malloc(total_size);
if(!wav) return 0;
ULONG bytes_read=0;
HRESULT hr=stream->lpVtbl->Read(stream, wav, total_size, &bytes_read);
if((FAILED(hr))||(bytes_read!=total_size))
{
free(wav);
return 0;
}
*buffer=wav;
*size=total_size;
return 1;
}
int sbz_sapi_cache_audio_attributes(sb_sapi* sapi)
{
if(!sapi) return 0;
WAVEFORMATEX* wf=NULL;
if(!sbz_sapi_get_waveformatex(sapi, &wf)) return 0;
if(!sbz_validate_waveformatex(wf))
{
sbz_com_free_memory(&sapi->com, wf);
return 0;
}
sapi->audio_channels=wf->nChannels;
sapi->audio_sample_rate=wf->nSamplesPerSec;
sapi->audio_bit_depth=wf->wBitsPerSample;
sbz_com_free_memory(&sapi->com, wf);
return 1;
}
int sbz_sapi_get_waveformatex(sb_sapi* sapi, WAVEFORMATEX** wf)
{
if((!sapi)||(!wf)) return 0;
*wf=NULL;
ISpAudio* audio=NULL;
ISpStreamFormat* format=NULL;
WAVEFORMATEX* pwfx=NULL;
GUID id;
HRESULT hr=sapi->voice->lpVtbl->GetOutputStream(sapi->voice, &format);
if((FAILED(hr))||(!format)) return 0;
hr=format->lpVtbl->GetFormat(format, &id, &pwfx);
if((FAILED(hr))||(!pwfx)) goto fail;
*wf=pwfx;
format->lpVtbl->Release(format);
return 1;

fail:
if(pwfx) sbz_com_free_memory(&sapi->com, pwfx);
if(format) format->lpVtbl->Release(format);
return 0;
}
void sbz_sapi_reset_voice_cache(sb_sapi* sapi)
{
if(!sapi) return;
sapi->voices=NULL;
sapi->voice_count=0;
}
void sbz_sapi_clean_voice_cache(sb_sapi* sapi)
{
if(!sapi) return;
for(int x=0; x<sapi->voice_count; x++)
{
sapi->voices[x].token->lpVtbl->Release(sapi->voices[x].token);
free(sapi->voices[x].name);
}
if(sapi->voices) free(sapi->voices);
sbz_sapi_reset_voice_cache(sapi);
}
void sbz_sapi_cleanup(sb_sapi* sapi)
{
if(!sapi) return;
if(sapi->voice) sapi->voice->lpVtbl->Release(sapi->voice);
sbz_sapi_clean_voice_cache(sapi);
sbz_com_cleanup(&sapi->com);
sbz_sapi_reset(sapi);
}
void sbz_sapi_reset(sb_sapi* sapi)
{
if(!sapi) return;
sbz_com_reset(&sapi->com);
sbz_sapi_reset_voice_cache(sapi);
sapi->voice = NULL;
sapi->pitch=0;
sapi->audio_channels=0;
sapi->audio_bit_depth=0;
sapi->audio_sample_rate=0;
sapi->begin=0;
sapi->end=0;
}
int sbz_com_initialise(sbz_com* com)
{
if(!com) return 0;
if(sbz_com_is_init(com)) return 0;
sbz_com_reset(com);
if(!sbz_com_load(com)) return 0;
HRESULT hr=com->CoInitializeEx(NULL, COINIT_MULTITHREADED);
if(FAILED(hr))
{
FreeLibrary(com->ole);
sbz_com_reset(com);
return 0;
}
return sbz_com_set_init_flag(com);
}
int sbz_com_load(sbz_com* com)
{
if(!com) return 0;
com->ole=LoadLibraryW(L"Ole32.dll");
if(!com->ole) return 0;
com->CoInitializeEx=(HRESULT(WINAPI*)(LPVOID, DWORD)) GetProcAddress(com->ole, "CoInitializeEx");
if(!com->CoInitializeEx)
{
FreeLibrary(com->ole);
sbz_com_reset(com);
return 0;
}
com->CoCreateInstance=(HRESULT(WINAPI*)(REFCLSID, LPUNKNOWN, DWORD, REFIID, LPVOID*)) GetProcAddress(com->ole, "CoCreateInstance");
if(!com->CoCreateInstance)
{
FreeLibrary(com->ole);
sbz_com_reset(com);
return 0;
}
com->CoTaskMemFree=(void(WINAPI*)(void*)) GetProcAddress(com->ole, "CoTaskMemFree");
if(!com->CoTaskMemFree)
{
FreeLibrary(com->ole);
sbz_com_reset(com);
return 0;
}
com->CoUninitialize=(HRESULT(WINAPI*)(void)) GetProcAddress(com->ole, "CoUninitialize");
if(!com->CoUninitialize)
{
FreeLibrary(com->ole);
sbz_com_reset(com);
return 0;
}
return 1;
}
int sbz_com_is_init(sbz_com* com)
{
if(!com) return 0;
if(com->begin!=sbz_com_begin) return 0;
if(com->end!=sbz_com_end) return 0;
return 1;
}
int sbz_com_set_init_flag(sbz_com* com)
{
if(!com) return 0;
com->begin=sbz_com_begin;
com->end=sbz_com_end;
return 1;
}
int sbz_com_create_instance(sbz_com* com, CLSID* clsid, IID* iid, void** data)
{
if(!sbz_com_is_init(com)) return 0;
HRESULT hr=com->CoCreateInstance(clsid, NULL, CLSCTX_ALL, iid, data);
if(FAILED(hr)) return 0;
return 1;
}
int sbz_com_free_memory(sbz_com* com, void* data)
{
if(!sbz_com_is_init(com)) return 0;
com->CoTaskMemFree(data);
return 1;
}
void sbz_com_reset(sbz_com* com)
{
if(!com) return;
com->ole=NULL;
com->CoInitializeEx=NULL;
com->CoCreateInstance=NULL;
com->CoTaskMemFree=NULL;
com->CoUninitialize=NULL;
com->begin=0;
com->end=0;
}
void sbz_com_cleanup(sbz_com* com)
{
if(!sbz_com_is_init(com)) return;
com->CoUninitialize();
FreeLibrary(com->ole);
sbz_com_reset(com);
}
WCHAR* sbz_char_to_wchar(char* text)
{
if((!text)||(!*text)) return NULL;
int source_length=strlen(text);
int destination_length=MultiByteToWideChar(CP_ACP, 0, text, source_length, NULL, 0);
WCHAR* wtext=malloc((destination_length+1)*sizeof(WCHAR));
if(!wtext) return NULL;
MultiByteToWideChar(CP_ACP, 0, text, source_length, wtext, destination_length);
wtext[destination_length]=0;
return wtext;
}
char* sbz_wchar_to_char(WCHAR* wtext)
{
if((!wtext)||(!*wtext)) return NULL;
int len=WideCharToMultiByte(CP_UTF8, 0, wtext, -1, NULL, 0, NULL, NULL);
if(len<=0) return NULL;
char* result=malloc(len);
if(!result) return NULL;
WideCharToMultiByte(CP_UTF8, 0, wtext, -1, result, len, NULL, NULL);
    return result;
}
int sbz_validate_waveformatex(WAVEFORMATEX* wf)
{
if(!wf) return 0;
if(wf->wFormatTag!=1) return 0;
if((wf->nChannels!=1)&&(wf->nChannels!=2)) return 0;
if((wf->wBitsPerSample!=8)&&(wf->wBitsPerSample!=16)) return 0;
if((wf->nSamplesPerSec<8000)||(wf->nSamplesPerSec>192000)) return 0;
return 1;
}
