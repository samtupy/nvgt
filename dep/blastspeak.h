/*
Blastspeak text to speech library
Copyright (c) 2019-2020 Philip Bennefall

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
*/

#ifndef BLASTSPEAK_H
#define BLASTSPEAK_H

#ifdef __cplusplus
extern "C" {
#endif

#include <oaidl.h>
#include <objbase.h>

#ifndef blastspeak_static_memory_length
#define blastspeak_static_memory_length 64 /* In bytes. */
#endif

#ifndef blastspeak_max_languages_per_voice
#define blastspeak_max_languages_per_voice 4
#endif

    typedef struct blastspeak
    {
        char static_memory[blastspeak_static_memory_length];
        char* allocated_memory;
        IDispatch* voice;
        IDispatch* format;
        IDispatch* voices;
        IDispatch* default_voice_token;
        IDispatch* current_voice_token;
        unsigned int voice_count;
        unsigned int allocated_memory_length;
        DISPID voice_dispids[8];
        DISPID voice_collection_item_dispid;
        DISPID voice_token_dispids[2];
        DISPID memory_stream_dispids[3];
        DISPID audio_format_getwaveformatex_dispid;
        DISPID audio_format_setwaveformatex_dispid;
        DISPID waveformatex_dispids[4];
        unsigned long sample_rate;
        unsigned char bits_per_sample;
        unsigned char channels;
unsigned char must_reset_output;
    } blastspeak;

    int blastspeak_initialize ( blastspeak* instance );

    void blastspeak_destroy ( blastspeak* instance );

    int blastspeak_speak ( blastspeak* instance, const char* text );

    int blastspeak_set_voice ( blastspeak* instance, unsigned int voice_index );

    const char* blastspeak_get_voice_description ( blastspeak* instance, unsigned int voice_index );

    const char* blastspeak_get_voice_attribute ( blastspeak* instance, unsigned int voice_index, const char* attribute );

    const char* blastspeak_get_voice_languages ( blastspeak* instance, unsigned int voice_index );

    int blastspeak_get_voice_rate ( blastspeak* instance, long* result );

    int blastspeak_set_voice_rate ( blastspeak* instance, long value );

    int blastspeak_get_voice_volume ( blastspeak* instance, long* result );

    int blastspeak_set_voice_volume ( blastspeak* instance, long value );

    char* blastspeak_speak_to_memory ( blastspeak* instance, unsigned long* bytes, const char* text );

#ifdef __cplusplus
}
#endif

#endif
