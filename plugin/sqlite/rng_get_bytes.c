/* LibTomCrypt, modular cryptographic library -- Tom St Denis
 *
 * LibTomCrypt is a library that provides various cryptographic
 * algorithms in a highly modular and flexible manner.
 *
 * The library is free for all purposes without any express
 * guarantee it works.
 */

/**
   @file rng_get_bytes.c
   portable way to get secure random bits to feed a PRNG (Tom St Denis)
*/

#include <assert.h>

#if !defined(_WIN32)
#include <stdio.h>
/* on *NIX read /dev/random */
static unsigned long _rng_nix ( unsigned char* buf, unsigned long len )
{
    FILE* f;
    unsigned long x;

    f = fopen ( "/dev/urandom", "rb" );
    if ( f == NULL )
    {
        f = fopen ( "/dev/random", "rb" );
    }

    if ( f == NULL )
    {
        return 0;
    }

    /* disable buffering */
    if ( setvbuf ( f, NULL, _IONBF, 0 ) != 0 )
    {
        fclose ( f );
        return 0;
    }

    x = ( unsigned long ) fread ( buf, 1, ( size_t ) len, f );
    fclose ( f );
    return x;
}
#endif

/* Try the Microsoft CSP */
#if defined(_WIN32) || defined(_WIN32_WCE)
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
#ifdef _WIN32_WCE
#define UNDER_CE
#define ARM
#endif

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

typedef LONG ( WINAPI* BCryptGenRandomFuncPtr ) ( LPVOID handle, unsigned char* buffer, ULONG bytes, ULONG flags );
typedef unsigned char ( WINAPI* RtlGenRandomFuncPtr ) ( LPVOID buffer, ULONG bytes );

static unsigned long _rng_win32 ( unsigned char* buf, unsigned long len )
{
    unsigned long result = 0;
    HMODULE handle = NULL;

    // In Windows UWP apps, we have to use LoadPackagedLibrary to import a module rather than the traditional LoadLibrary.
#if defined(WINAPI_FAMILY) && (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP || WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
    handle = LoadPackagedLibrary ( L"Bcrypt.dll", 0 );
#else
    handle = LoadLibraryW ( L"Bcrypt.dll" );
#endif
    if ( handle )
    {
        BCryptGenRandomFuncPtr BCryptGenRandomFunc = ( BCryptGenRandomFuncPtr ) GetProcAddress ( handle, "BCryptGenRandom" );
        if ( BCryptGenRandomFunc && BCryptGenRandomFunc ( NULL, buf, ( ULONG ) len, ( ULONG ) 0x00000002 ) >= 0 )
        {
            result = len;
        }
        FreeLibrary ( handle );
        handle = NULL;
    }

    if ( result == 0 )
    {

        // Use RtlGenRandom as a fallback.
        // This function is not guaranteed to be available, but is in practise (at least on Windows desktop according to MSDN).
        // However, we attempt to call it even on UWP just in case.
#if defined(WINAPI_FAMILY) && (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP || WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
        handle = LoadPackagedLibrary ( L"Advapi32.dll", 0 );
#else
        handle = LoadLibraryW ( L"Advapi32.dll" );
#endif
        if ( handle )
        {

            // Note: MinGW64 generates a harmless warning about a potentially incompatible pointer cast on the below line. It can be ignored.
            RtlGenRandomFuncPtr RtlGenRandomFunc = ( RtlGenRandomFuncPtr ) GetProcAddress ( handle, "SystemFunction036" );
            if ( RtlGenRandomFunc && RtlGenRandomFunc ( ( PVOID ) buf, ( ULONG ) len ) == TRUE )
            {
                result = len;
            }
            FreeLibrary ( handle );
            handle = NULL;
        }
    }
    return result;
}

#endif /* WIN32 */

/**
  Read the system RNG
  @param out       Destination
  @param outlen    Length desired (octets)
  @return Number of octets read
*/
unsigned long rng_get_bytes ( unsigned char* out, unsigned long outlen )
{
    unsigned long x;

    assert ( out != NULL );

#if defined(_WIN32) || defined(_WIN32_WCE)
    x = _rng_win32 ( out, outlen );
    if ( x != 0 )
    {
        return x;
    }
#else
    x = _rng_nix ( out, outlen );
    if ( x != 0 )
    {
        return x;
    }
#endif
    return 0;
}
