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

#ifdef __cplusplus
extern "C" {
#endif

#include "blastspeak.h"
#include <wchar.h>
#include <windows.h>
#include <oaidl.h>
#include <objbase.h>
#include <stdlib.h>
#include <stdio.h>

    const IID BS_IID_null = {0x00000000, 0x0000, 0x0000, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}};
    const IID BS_IID_IDispatch = {0x00020400, 0x0000, 0x0000, {0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46}};
    const IID BS_IID_SpVoice = {0x96749377, 0x3391, 0x11D2, {0x9E, 0xE3, 0x00, 0xC0, 0x4F, 0x79, 0x73, 0x96}};
    const IID BS_IID_SpMemoryStream = {0x5FB7EF7D, 0xDFF4, 0x468a, {0xB6, 0xB7, 0x2F, 0xCB, 0xD1, 0x88, 0xF9, 0x94}};

#if 0
    static void print_error ( HRESULT hr, UINT puArgErr )
    {
        switch ( hr )
        {
            case DISP_E_BADPARAMCOUNT:
                printf ( "The number of elements provided to DISPPARAMS is different from the number of arguments accepted by the method or property." );
                break;
            case DISP_E_BADVARTYPE:
                printf ( "One of the arguments in DISPPARAMS is not a valid variant type." );
                break;
            case DISP_E_EXCEPTION:
                printf ( "The application needs to raise an exception." );
                break;
            case DISP_E_MEMBERNOTFOUND:
                printf ( "The requested member does not exist." );
                break;
            case DISP_E_NONAMEDARGS:
                printf ( "This implementation of IDispatch does not support named arguments." );
                break;
            case DISP_E_OVERFLOW:
                printf ( "One of the arguments in DISPPARAMS could not be coerced to the specified type." );
                break;
            case DISP_E_PARAMNOTFOUND:
                printf ( "One of the parameter IDs does not correspond to a parameter on the method." );
                break;
            case DISP_E_TYPEMISMATCH:
                printf ( "One or more of the arguments could not be coerced." );
                break;
            case DISP_E_UNKNOWNINTERFACE:
                printf ( "The interface identifier passed in riid is not IID_NULL." );
                break;
            case DISP_E_UNKNOWNLCID:
                printf ( "The member being invoked interprets string arguments according to the LCID, and the LCID is not recognized." );
                break;
            case DISP_E_PARAMNOTOPTIONAL:
                printf ( "A required parameter was omitted." );
                break;
            default:
                printf ( "Unknown error" );
        }
        printf ( "\nArgument error: %u\n", puArgErr );
    }
#endif

    HRESULT InitVariantFromString ( __in PCWSTR psz, __out VARIANT* pvar )
    {
        pvar->vt = VT_BSTR;
        pvar->bstrVal = SysAllocString ( psz );
        HRESULT hr =  pvar->bstrVal ? S_OK : ( psz ? E_OUTOFMEMORY : E_INVALIDARG );
        if ( FAILED ( hr ) )
        {
            VariantInit ( pvar );
        }
        return hr;
    }

    HRESULT InitVariantFromUInt32 ( __in ULONG ulVal, __out VARIANT* pvar )
    {
        pvar->vt = VT_UI4;
        pvar->ulVal = ulVal;
        return S_OK;
    }

    static char* blastspeak_get_temporary_memory ( blastspeak* instance, unsigned int bytes )
    {
        if ( bytes <= blastspeak_static_memory_length )
        {
            return instance->static_memory;
        }
        if ( instance->allocated_memory && bytes <= instance->allocated_memory_length )
        {
            return instance->allocated_memory;
        }
        instance->allocated_memory = ( char* ) realloc ( instance->allocated_memory, ( size_t ) bytes );
        if ( instance->allocated_memory == NULL )
        {
            instance->allocated_memory_length = 0;
            return NULL;
        }
        instance->allocated_memory_length = bytes;
        return instance->allocated_memory;
    }

    /* If length_in_bytes is nonzero, it must be the length of the string excluding the NULL terminator. */
    /* If length_in_bytes is 0, the function looks for the NULL terminator to figure out the length. */
    /* The input string must always be NULL terminated. */
    /* The returned string is always NULL terminated. The function returns a NULL pointer on failure. */
    static WCHAR* blastspeak_get_wchar_from_utf8 ( blastspeak* instance, const char* the_string, unsigned int length_in_bytes )
    {
        WCHAR* result;
        int needed_size;

        if ( length_in_bytes == 0 )
        {
            length_in_bytes = strlen ( the_string );
        }
        if ( length_in_bytes == 0 )
        {
            return NULL;
        }
        ++length_in_bytes;
        needed_size = MultiByteToWideChar ( CP_UTF8, 0, the_string, length_in_bytes, NULL, 0 );
        if ( needed_size == 0 )
        {
            return NULL;
        }
        result = ( WCHAR* ) blastspeak_get_temporary_memory ( instance, needed_size * sizeof ( WCHAR ) );
        if ( result == NULL )
        {
            return NULL;
        }
        if ( MultiByteToWideChar ( CP_UTF8, 0, the_string, length_in_bytes, result, needed_size ) != needed_size )
        {
            return NULL;
        }
        return result;
    }

    /* The returned string is always NULL terminated. The function returns a NULL pointer on failure. */
    /* The input BSTR is not freed. */
    static char* blastspeak_get_UTF8_from_BSTR ( blastspeak* instance, BSTR the_string )
    {
        char* result;
        int needed_size;
        unsigned int length_in_chars = SysStringLen ( the_string );
        if ( length_in_chars == 0 )
        {
            return NULL;
        }

        ++length_in_chars;
        needed_size = WideCharToMultiByte ( CP_UTF8, 0, the_string, length_in_chars, NULL, 0, NULL, NULL );
        if ( needed_size == 0 )
        {
            return NULL;
        }
        result = blastspeak_get_temporary_memory ( instance, needed_size );
        if ( result == NULL )
        {
            return NULL;
        }
        if ( WideCharToMultiByte ( CP_UTF8, 0, the_string, length_in_chars, result, needed_size, NULL, NULL ) != needed_size )
        {
            return NULL;
        }
        return result;
    }

    static int blastspeak_get_stream_format ( blastspeak* instance, int retrieve_dispids, unsigned long* sample_rate, unsigned char* bits_per_sample, unsigned char* channels );

    int blastspeak_initialize ( blastspeak* instance )
    {
        OLECHAR* voice_names[] = {L"AllowAudioOutputFormatChangesOnNextSet", L"AudioOutputStream", L"GetVoices", L"Rate", L"Speak", L"Status", L"Voice", L"Volume"};
        OLECHAR* voice_token_names[] = {L"GetAttribute", L"GetDescription"};
        OLECHAR* voice_collection_names[] = {L"Count", L"Item"};
        OLECHAR* memory_stream_names[] = {L"GetData", L"Format", L"SetData"};
        IDispatch* stream;
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT return_value;
        UINT puArgErr;
        DISPID voice_collection_dispids[2];
        LONG voice_count = 0;

        instance->allocated_memory = NULL;
        instance->allocated_memory_length = 0;
        instance->static_memory[0] = 0;
        instance->must_reset_output = 0;

        CoInitializeEx ( NULL, COINIT_MULTITHREADED );

        hr = CoCreateInstance ( &BS_IID_SpVoice, NULL, CLSCTX_INPROC_SERVER, &BS_IID_IDispatch, ( void** ) &instance->voice );
        if ( FAILED ( hr ) )
        {
            CoUninitialize();
            return 0;
        }

        hr = CoCreateInstance ( &BS_IID_SpMemoryStream, NULL, CLSCTX_INPROC_SERVER, &BS_IID_IDispatch, ( void** ) &stream );
        if ( FAILED ( hr ) )
        {
            instance->voice->lpVtbl->Release ( instance->voice );
            CoUninitialize();
            return 0;
        }

        for ( puArgErr = 0; puArgErr < 8; ++puArgErr )
        {
            hr = instance->voice->lpVtbl->GetIDsOfNames ( instance->voice, &BS_IID_null, &voice_names[puArgErr], 1, LOCALE_SYSTEM_DEFAULT, &instance->voice_dispids[puArgErr] );
            if ( FAILED ( hr ) )
            {
                stream->lpVtbl->Release ( stream );
                instance->voice->lpVtbl->Release ( instance->voice );
                CoUninitialize();
                return 0;
            }
        }

        for ( puArgErr = 0; puArgErr < 3; ++puArgErr )
        {
            hr = stream->lpVtbl->GetIDsOfNames ( stream, &BS_IID_null, &memory_stream_names[puArgErr], 1, LOCALE_SYSTEM_DEFAULT, &instance->memory_stream_dispids[puArgErr] );
            if ( FAILED ( hr ) )
            {
                stream->lpVtbl->Release ( stream );
                instance->voice->lpVtbl->Release ( instance->voice );
                CoUninitialize();
                return 0;
            }
        }

        stream->lpVtbl->Release ( stream );

        parameters.rgvarg = NULL;
        parameters.cArgs = 0;
        parameters.rgdispidNamedArgs = NULL;
        parameters.cNamedArgs = 0;

        hr = instance->voice->lpVtbl->Invoke ( instance->voice, instance->voice_dispids[6], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYGET, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            instance->voice->lpVtbl->Release ( instance->voice );
            CoUninitialize();
            return 0;
        }

        if ( return_value.vt != VT_DISPATCH )
        {
            VariantClear ( &return_value );
            instance->voice->lpVtbl->Release ( instance->voice );
            CoUninitialize();
            return 0;
        }

        instance->default_voice_token = return_value.pdispVal;
        for ( puArgErr = 0; puArgErr < 2; ++puArgErr )
        {
            hr = instance->default_voice_token->lpVtbl->GetIDsOfNames ( instance->default_voice_token, &BS_IID_null, &voice_token_names[puArgErr], 1, LOCALE_SYSTEM_DEFAULT, &instance->voice_token_dispids[puArgErr] );
            if ( FAILED ( hr ) )
            {
                instance->default_voice_token->lpVtbl->Release ( instance->default_voice_token );
                instance->voice->lpVtbl->Release ( instance->voice );
                CoUninitialize();
                return 0;
            }
        }

        hr = instance->voice->lpVtbl->Invoke ( instance->voice, instance->voice_dispids[2], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            instance->default_voice_token->lpVtbl->Release ( instance->default_voice_token );
            instance->voice->lpVtbl->Release ( instance->voice );
            CoUninitialize();
            return 0;
        }

        if ( return_value.vt != VT_DISPATCH )
        {
            VariantClear ( &return_value );
            instance->default_voice_token->lpVtbl->Release ( instance->default_voice_token );
            instance->voice->lpVtbl->Release ( instance->voice );
            CoUninitialize();
            return 0;
        }

        instance->voices = return_value.pdispVal;

        for ( puArgErr = 0; puArgErr < 2; ++puArgErr )
        {
            hr = instance->voices->lpVtbl->GetIDsOfNames ( instance->voices, &BS_IID_null, &voice_collection_names[puArgErr], 1, LOCALE_SYSTEM_DEFAULT, &voice_collection_dispids[puArgErr] );
            if ( FAILED ( hr ) )
            {
                instance->voices->lpVtbl->Release ( instance->voices );
                instance->default_voice_token->lpVtbl->Release ( instance->default_voice_token );
                instance->voice->lpVtbl->Release ( instance->voice );
                CoUninitialize();
                return 0;
            }
        }

        hr = instance->voices->lpVtbl->Invoke ( instance->voices, voice_collection_dispids[0], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYGET, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            instance->voices->lpVtbl->Release ( instance->voices );
            instance->default_voice_token->lpVtbl->Release ( instance->default_voice_token );
            instance->voice->lpVtbl->Release ( instance->voice );
            CoUninitialize();
            return 0;
        }
        if ( return_value.vt == VT_I4 )
        {
            voice_count = return_value.lVal;
        }
        else
        {
            VariantClear ( &return_value );
        }
        if ( voice_count <= 0 )
        {
            instance->voices->lpVtbl->Release ( instance->voices );
            instance->default_voice_token->lpVtbl->Release ( instance->default_voice_token );
            instance->voice->lpVtbl->Release ( instance->voice );
            CoUninitialize();
            return 0;
        }
        instance->voice_count = ( unsigned int ) voice_count;
        instance->voice_collection_item_dispid = voice_collection_dispids[1];
        instance->format = NULL;
        instance->current_voice_token = NULL;

        if ( blastspeak_get_stream_format ( instance, 1, &instance->sample_rate, &instance->bits_per_sample, &instance->channels ) == 0 )
        {
            instance->voices->lpVtbl->Release ( instance->voices );
            instance->default_voice_token->lpVtbl->Release ( instance->default_voice_token );
            instance->voice->lpVtbl->Release ( instance->voice );
            CoUninitialize();
            return 0;
        }

        return 1;
    }

    void blastspeak_destroy ( blastspeak* instance )
    {
        if ( instance->allocated_memory )
        {
            free ( instance->allocated_memory );
        }
        instance->voice->lpVtbl->Release ( instance->voice );
        instance->voices->lpVtbl->Release ( instance->voices );
        instance->default_voice_token->lpVtbl->Release ( instance->default_voice_token );
        instance->format->lpVtbl->Release ( instance->format );
        if ( instance->current_voice_token )
        {
            instance->current_voice_token->lpVtbl->Release ( instance->current_voice_token );
        }
        CoUninitialize();
    }

    static int blastspeak_speak_internal ( blastspeak* instance, const char* text )
    {
        HRESULT hr;
        VARIANT return_value;
        VARIANT arguments[2];
        DISPPARAMS parameters;
        UINT puArgErr;
        WCHAR* utf16_string = blastspeak_get_wchar_from_utf8 ( instance, text, 0 );

        if ( utf16_string == NULL )
        {
            return 0;
        }

        hr = InitVariantFromString ( utf16_string, &arguments[1] );
        if ( FAILED ( hr ) )
        {
            return 0;
        }

        InitVariantFromUInt32 ( 0, &arguments[0] );

        parameters.rgvarg = arguments;
        parameters.rgdispidNamedArgs = NULL;
        parameters.cArgs = 2;
        parameters.cNamedArgs = 0;

        hr = instance->voice->lpVtbl->Invoke ( instance->voice, instance->voice_dispids[4], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        VariantClear ( &arguments[1] );
        VariantClear ( &return_value );
        if ( FAILED ( hr ) )
        {
            return 0;
        }
        return 1;
    }
    static int blastspeak_reset_output(blastspeak *instance)
    {
            HRESULT hr;
            VARIANT return_value;
            VARIANT argument;
            DISPPARAMS parameters;
            UINT puArgErr;
            DISPID dispid_named = DISPID_PROPERTYPUT;
            parameters.rgvarg = &argument;
            parameters.cArgs = 1;
            parameters.rgdispidNamedArgs = &dispid_named;
            parameters.cNamedArgs = 1;
            argument.vt = VT_EMPTY;

            hr = instance->voice->lpVtbl->Invoke ( instance->voice, instance->voice_dispids[1], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYPUTREF, &parameters, &return_value, NULL, &puArgErr );
            if ( FAILED ( hr ) )
            {
                return 0;
            }
            VariantClear ( &return_value );
            instance->must_reset_output = 0;
            return 1;
    }

    int blastspeak_speak ( blastspeak* instance, const char* text )
    {
        if ( instance->must_reset_output )
        {
            if(!blastspeak_reset_output(instance))
            {
                return 0;
            }
        }

        return blastspeak_speak_internal ( instance, text );
    }

    static IDispatch* blastspeak_get_voice ( blastspeak* instance, unsigned int voice_index )
    {
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT argument;
        VARIANT return_value;
        UINT puArgErr;

        if ( voice_index >= instance->voice_count )
        {
            return NULL;
        }

        parameters.rgvarg = &argument;
        parameters.cArgs = 1;
        parameters.rgdispidNamedArgs = NULL;
        parameters.cNamedArgs = 0;

        InitVariantFromUInt32 ( voice_index, &argument );

        hr = instance->voices->lpVtbl->Invoke ( instance->voices, instance->voice_collection_item_dispid, &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            return NULL;
        }

        if ( return_value.vt != VT_DISPATCH )
        {
            VariantClear ( &return_value );
            return 0;
        }

        return return_value.pdispVal;
    }

    int blastspeak_set_voice ( blastspeak* instance, unsigned int voice_index )
    {
        if ( instance->must_reset_output )
        {
            if(!blastspeak_reset_output(instance))
            {
                return 0;
            }
        }
        IDispatch* voice_token = blastspeak_get_voice ( instance, voice_index );
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT argument;
        VARIANT return_value;
        UINT puArgErr;
        DISPID dispid_named = DISPID_PROPERTYPUT;

        if ( voice_token == NULL )
        {
            return 0;
        }

        parameters.rgvarg = &argument;
        parameters.cArgs = 1;
        parameters.rgdispidNamedArgs = &dispid_named;
        parameters.cNamedArgs = 1;

        argument.vt = VT_DISPATCH;
        argument.pdispVal = voice_token;

        hr = instance->voice->lpVtbl->Invoke ( instance->voice, instance->voice_dispids[6], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYPUTREF, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            voice_token->lpVtbl->Release ( voice_token );
            return 0;
        }
        VariantClear ( &return_value );
        if ( instance->current_voice_token )
        {
            instance->current_voice_token->lpVtbl->Release ( instance->current_voice_token );
        }
        instance->current_voice_token = voice_token;
        argument.vt = VT_EMPTY;
        hr = instance->voice->lpVtbl->Invoke ( instance->voice, instance->voice_dispids[1], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYPUTREF, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            return 0;
        }
        VariantClear ( &return_value );
        if ( blastspeak_get_stream_format ( instance, 0, &instance->sample_rate, &instance->bits_per_sample, &instance->channels ) == 0 )
        {
            return 0;
        }
        return 1;
    }

    const char* blastspeak_get_voice_description ( blastspeak* instance, unsigned int voice_index )
    {
        char* result;
        IDispatch* voice_token = blastspeak_get_voice ( instance, voice_index );
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT return_value;
        UINT puArgErr;

        if ( voice_token == NULL )
        {
            return NULL;
        }

        parameters.rgvarg = NULL;
        parameters.cArgs = 0;
        parameters.rgdispidNamedArgs = NULL;
        parameters.cNamedArgs = 0;

        hr = voice_token->lpVtbl->Invoke ( voice_token, instance->voice_token_dispids[1], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        voice_token->lpVtbl->Release ( voice_token );
        if ( FAILED ( hr ) )
        {
            return NULL;
        }

        if ( return_value.vt != VT_BSTR )
        {
            VariantClear ( &return_value );
            return NULL;
        }

        result = blastspeak_get_UTF8_from_BSTR ( instance, return_value.bstrVal );
        VariantClear ( &return_value );
        return result;
    }

    const char* blastspeak_get_voice_attribute ( blastspeak* instance, unsigned int voice_index, const char* attribute )
    {
        char* result;
        IDispatch* voice_token = blastspeak_get_voice ( instance, voice_index );
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT argument;
        VARIANT return_value;
        UINT puArgErr;
        WCHAR* utf16_string;

        if ( voice_token == NULL )
        {
            return NULL;
        }

        utf16_string = blastspeak_get_wchar_from_utf8 ( instance, attribute, 0 );
        if ( utf16_string == NULL )
        {
            voice_token->lpVtbl->Release ( voice_token );
            return NULL;
        }

        parameters.rgvarg = &argument;
        parameters.cArgs = 1;
        parameters.rgdispidNamedArgs = NULL;
        parameters.cNamedArgs = 0;

        hr = InitVariantFromString ( utf16_string, &argument );
        if ( FAILED ( hr ) )
        {
            voice_token->lpVtbl->Release ( voice_token );
            return NULL;
        }

        hr = voice_token->lpVtbl->Invoke ( voice_token, instance->voice_token_dispids[0], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        VariantClear ( &argument );
        voice_token->lpVtbl->Release ( voice_token );
        if ( FAILED ( hr ) )
        {
            return NULL;
        }

        if ( return_value.vt != VT_BSTR )
        {
            VariantClear ( &return_value );
            return NULL;
        }

        result = blastspeak_get_UTF8_from_BSTR ( instance, return_value.bstrVal );
        VariantClear ( &return_value );
        return result;
    }

    const char* blastspeak_get_voice_languages ( blastspeak* instance, unsigned int voice_index )
    {
        char* the_string = ( char* ) blastspeak_get_voice_attribute ( instance, voice_index, "language" );
        long codes[blastspeak_max_languages_per_voice];
        int languages = 0;
        int i;
        char current_name[9];

        if ( the_string == NULL )
        {
            return NULL;
        }

        for ( ;; )
        {
            int should_continue = 0;
            codes[languages] = strtol ( the_string, &the_string, 16 );
            if ( codes[languages] == 0L )
            {
                return NULL;
            }
            else if ( codes[languages] < -32768L || codes[languages] > 32767L )
            {
                return NULL;
            }
            for ( i = 0; i < languages; ++i )
            {
                if ( codes[i] == codes[languages] )
                {
                    should_continue = 1;
                    break;
                }
            }
            if ( should_continue )
            {
                continue;
            }
            ++languages;
            if ( languages > blastspeak_max_languages_per_voice )
            {
                return NULL;
            }
            for ( ; *the_string; ++the_string )
            {
                if ( *the_string == ' ' || *the_string == ';' )
                {
                    continue;
                }
                break;
            }
            if ( *the_string == 0 )
            {
                break;
            }
        }

        if ( languages == 0 )
        {
            return NULL;
        }

        the_string = blastspeak_get_temporary_memory ( instance, ( languages * 20 ) + 1 );
        if ( the_string == NULL )
        {
            return NULL;
        }
        the_string[0] = 0;

        for ( i = 0; i < languages; ++i )
        {
            if ( i )
            {
                strcat ( the_string, " " );
            }
            current_name[0] = 0;
            if ( GetLocaleInfoA ( codes[i], LOCALE_SISO639LANGNAME, current_name, 9 ) == 0 )
            {
                return NULL;
            }
            strcat ( the_string, current_name );

            if ( SUBLANGID ( ( short ) codes[i] ) == 0 ) /* Neutral. */
            {
                continue;
            }

            current_name[0] = 0;
            if ( GetLocaleInfoA ( codes[i], LOCALE_SISO3166CTRYNAME, current_name, 9 ) == 0 )
            {
                continue;
            }
            strcat ( the_string, "-" );
            strcat ( the_string, current_name );
        }

        return the_string;
    }

    static int blastspeak_set_long_property ( blastspeak* instance, DISPID dispid, long value )
    {
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT argument;
        VARIANT return_value;
        UINT puArgErr;
        DISPID dispid_named = DISPID_PROPERTYPUT;

        parameters.rgvarg = &argument;
        parameters.cArgs = 1;
        parameters.rgdispidNamedArgs = &dispid_named;
        parameters.cNamedArgs = 1;
        argument.vt = VT_I4;
        argument.lVal = value;

        hr = instance->voice->lpVtbl->Invoke ( instance->voice, dispid, &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYPUT, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            return 0;
        }
        VariantClear ( &return_value );

        return 1;
    }

    static int blastspeak_get_long_property ( blastspeak* instance, DISPID dispid, long* value, IDispatch* object )
    {
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT return_value;
        UINT puArgErr;

        if ( object == NULL )
        {
            object = instance->voice;
        }

        parameters.rgvarg = NULL;
        parameters.cArgs = 0;
        parameters.rgdispidNamedArgs = NULL;
        parameters.cNamedArgs = 0;

        hr = object->lpVtbl->Invoke ( object, dispid, &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYGET, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            return 0;
        }
        if ( return_value.vt != VT_I4 && return_value.vt != VT_I2 )
        {
            VariantClear ( &return_value );
            return 0;
        }

        if ( return_value.vt == VT_I4 )
        {
            *value = return_value.lVal;
        }
        else
        {
            *value = return_value.iVal;
        }

        return 1;
    }

    static int blastspeak_get_stream_format ( blastspeak* instance, int retrieve_dispids, unsigned long* sample_rate, unsigned char* bits_per_sample, unsigned char* channels )
    {
        OLECHAR* audio_format_getwaveformatex_name = L"GetWaveFormatEx";
                OLECHAR* audio_format_setwaveformatex_name = L"SetWaveFormatEx";
        OLECHAR* waveformatex_names[] = {L"BitsPerSample", L"Channels", L"FormatTag", L"SamplesPerSec"};
        IDispatch* audio_device_stream;
        IDispatch* formatex = NULL;
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT return_value;
        UINT puArgErr;
        long temp;

        parameters.rgvarg = NULL;
        parameters.cArgs = 0;
        parameters.rgdispidNamedArgs = NULL;
        parameters.cNamedArgs = 0;

        if ( instance->format )
        {
            instance->format->lpVtbl->Release ( instance->format );
            instance->format = NULL;
        }

        hr = instance->voice->lpVtbl->Invoke ( instance->voice, instance->voice_dispids[1], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYGET, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            return 0;
        }
        if ( return_value.vt != VT_DISPATCH )
        {
            VariantClear ( &return_value );
            return 0;
        }
        audio_device_stream = return_value.pdispVal;

        hr = audio_device_stream->lpVtbl->Invoke ( audio_device_stream, instance->memory_stream_dispids[1], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYGET, &parameters, &return_value, NULL, &puArgErr );
        audio_device_stream->lpVtbl->Release ( audio_device_stream );
        if ( FAILED ( hr ) )
        {
            return 0;
        }
        if ( return_value.vt != VT_DISPATCH )
        {
            VariantClear ( &return_value );
            return 0;
        }
        instance->format = return_value.pdispVal;

        if ( retrieve_dispids )
        {
            hr = instance->format->lpVtbl->GetIDsOfNames ( instance->format, &BS_IID_null, &audio_format_getwaveformatex_name, 1, LOCALE_SYSTEM_DEFAULT, &instance->audio_format_getwaveformatex_dispid );
            if ( FAILED ( hr ) )
            {
                goto error;
            }
                        hr = instance->format->lpVtbl->GetIDsOfNames ( instance->format, &BS_IID_null, &audio_format_setwaveformatex_name, 1, LOCALE_SYSTEM_DEFAULT, &instance->audio_format_setwaveformatex_dispid );
            if ( FAILED ( hr ) )
            {
                goto error;
            }

        }

        hr = instance->format->lpVtbl->Invoke ( instance->format, instance->audio_format_getwaveformatex_dispid, &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            goto error;
        }
        if ( return_value.vt != VT_DISPATCH )
        {
            VariantClear ( &return_value );
            goto error;
        }
        formatex = return_value.pdispVal;

        if ( retrieve_dispids )
        {
            for ( puArgErr = 0; puArgErr < 4; ++puArgErr )
            {
                hr = formatex->lpVtbl->GetIDsOfNames ( formatex, &BS_IID_null, &waveformatex_names[puArgErr], 1, LOCALE_SYSTEM_DEFAULT, &instance->waveformatex_dispids[puArgErr] );
                if ( FAILED ( hr ) )
                {
                    goto error;
                }
            }

        }

        if ( blastspeak_get_long_property ( instance, instance->waveformatex_dispids[2], &temp, formatex ) == 0 )
        {
            goto error;
        }
        if ( temp != 1 )
        {
            goto error;
        }

        if ( blastspeak_get_long_property ( instance, instance->waveformatex_dispids[0], &temp, formatex ) == 0 )
        {
            goto error;
        }
        if ( temp != 8 && temp != 16 )
        {
            goto error;
        }
        *bits_per_sample = ( unsigned char ) temp;

        if ( blastspeak_get_long_property ( instance, instance->waveformatex_dispids[1], &temp, formatex ) == 0 )
        {
            goto error;
        }
        if ( temp != 1 && temp != 2 )
        {
            goto error;
        }
        *channels = ( unsigned char ) temp;

        if ( blastspeak_get_long_property ( instance, instance->waveformatex_dispids[3], &temp, formatex ) == 0 )
        {
            goto error;
        }
        if ( temp >= 8000 && temp <= 192000 )
        {
            *sample_rate = ( unsigned long ) temp;
        }
        else
        {
            goto error;
        }

        if ( formatex )
        {
            formatex->lpVtbl->Release ( formatex );
        }
        return 1;

error:
        if ( formatex )
        {
            formatex->lpVtbl->Release ( formatex );
        }
        return 0;
    }

    int blastspeak_get_voice_rate ( blastspeak* instance, long* result )
    {
        if ( result == NULL )
        {
            return 0;
        }
        return blastspeak_get_long_property ( instance, instance->voice_dispids[3], result, NULL );
    }

    int blastspeak_set_voice_rate ( blastspeak* instance, long value )
    {
        if ( value < -10 )
        {
            return 0;
        }
        if ( value > 10 )
        {
            return 0;
        }
        return blastspeak_set_long_property ( instance, instance->voice_dispids[3], value );
    }

    int blastspeak_get_voice_volume ( blastspeak* instance, long* result )
    {
        if ( result == NULL )
        {
            return 0;
        }
        return blastspeak_get_long_property ( instance, instance->voice_dispids[7], result, NULL );
    }

    int blastspeak_set_voice_volume ( blastspeak* instance, long value )
    {
        if ( value < -100 )
        {
            return 0;
        }
        if ( value > 100 )
        {
            return 0;
        }
        return blastspeak_set_long_property ( instance, instance->voice_dispids[7], value );
    }

    char* blastspeak_speak_to_memory ( blastspeak* instance, unsigned long* bytes, const char* text )
    {
        int temp;
        HRESULT hr;
        DISPPARAMS parameters;
        VARIANT argument;
        VARIANT return_value;
        UINT puArgErr;
        char* ptr;
        LONGLONG elements;
        char* data = NULL;
        IDispatch* stream = NULL;
        IDispatch *stream_format = NULL;
        IDispatch *formatex = NULL;
        DISPID dispid_named = DISPID_PROPERTYPUT;
        DISPID dispid_method = DISPID_UNKNOWN;
        int num_refs;
        if ( instance->format == NULL )
        {
            return NULL;
        }

        hr = CoCreateInstance ( &BS_IID_SpMemoryStream, NULL, CLSCTX_INPROC_SERVER, &BS_IID_IDispatch, ( void** ) &stream );
        if ( FAILED ( hr ) )
        {
            return NULL;
        }
        //Bug: if we call SetFormat on the SpMemoryStream it will make a copy and leak it.
        //Workaround: retrieve the existing SpAudioFormat held by the stream, retrieve the WaveFormatEx held by the current voice's SpAudioFormat, and call SetWaveFormatEx on the SpMemoryStream's existing SpAudioFormat.
        parameters.cArgs = 0;
        parameters.cNamedArgs = 0;
        parameters.rgdispidNamedArgs = NULL;
        parameters.rgvarg = NULL;
        hr = stream->lpVtbl->Invoke ( stream, instance->memory_stream_dispids[1], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYGET, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            goto done;
        }
        stream_format = return_value.pdispVal;

        hr = instance->format->lpVtbl->Invoke ( instance->format, instance->audio_format_getwaveformatex_dispid, &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) || return_value.vt != VT_DISPATCH )
        {
goto done;
      }
        formatex = return_value.pdispVal;
        parameters.rgvarg = &argument;
        parameters.cArgs = 1;
        argument.vt = VT_DISPATCH;
        argument.pdispVal = formatex;
        hr = stream_format->lpVtbl->Invoke ( stream_format, instance->audio_format_setwaveformatex_dispid, &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        if(FAILED(hr))
        {
            goto done;
        }
        VariantClear(&return_value);

        parameters.rgdispidNamedArgs = &dispid_named;
        parameters.cNamedArgs = 1;

        argument.vt = VT_DISPATCH;
        argument.pdispVal = stream;

        hr = instance->voice->lpVtbl->Invoke ( instance->voice, instance->voice_dispids[1], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_PROPERTYPUTREF, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
            goto done;
        }
        VariantClear ( &return_value );
        
        instance->must_reset_output = 1;

        temp = blastspeak_speak_internal ( instance, text );
        if ( temp == 0 )
        {
            goto done;
        }

        parameters.rgvarg = NULL;
        parameters.cArgs = 0;
        parameters.rgdispidNamedArgs = NULL;
        parameters.cNamedArgs = 0;

        hr = stream->lpVtbl->Invoke ( stream, instance->memory_stream_dispids[0], &BS_IID_null, LOCALE_SYSTEM_DEFAULT, DISPATCH_METHOD, &parameters, &return_value, NULL, &puArgErr );
        if ( FAILED ( hr ) )
        {
goto done;
       }
        if ( return_value.vt != 8209 )
        {
            VariantClear ( &return_value );
goto done;
        }

        ptr = ( char* ) return_value.parray->pvData;
        elements = return_value.parray->rgsabound[0].cElements;

        ptr += return_value.parray->rgsabound[0].lLbound;
        data = blastspeak_get_temporary_memory ( instance, ( unsigned int ) elements );
        if ( data )
        {
            memcpy ( data, ptr, ( size_t ) elements );
            *bytes = ( unsigned long ) elements;
        }
        else
        {
            *bytes = 0;
        }
        VariantClear ( &return_value );
done:
if(instance->must_reset_output)
{
    blastspeak_reset_output(instance);
}
//Several operations performed here involving the stream have called AddRef on it, and they never get cleaned up. So we'll have to find out how many references the stream has and clear all of them so that it doesn't just leak.
for(num_refs = stream->lpVtbl->AddRef(stream) ; num_refs > 0; num_refs--)
{
    stream->lpVtbl->Release(stream);
}
if(formatex != NULL)
{
    formatex->lpVtbl->Release(formatex);

}
if(stream_format != NULL)
{
    stream_format->lpVtbl->Release(stream_format);
}

        return data;
    }

#ifdef __cplusplus
}
#endif
