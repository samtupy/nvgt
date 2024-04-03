/* Convert Numbers to Words
* Version 1.0 - 2019-02-03
*
* Philip Bennefall - philip@blastbay.com
*
* See the end of this file for licensing terms.
*
* USAGE
*
* This is a single-file library. To use it, do something like the following in one .c file.
* #define BL_NUMWORDS_IMPLEMENTATION
* #include "BL_NUMBER_TO-WORDS.h"
*
* You can then #include this file in other parts of the program as you would with any other header file.
*/

#ifndef BL_NUMWORDS_H
#define BL_NUMWORDS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h> /* For size_t. */

#if defined(_MSC_VER) && _MSC_VER < 1600
typedef unsigned __int64 bl_uint64;
#else
#include <stdint.h>
typedef uint64_t bl_uint64;
#endif

    /* PUBLIC API */

    /* Convert an unsigned 64 bit integer to words.
    *
* The function uses the convention that "one thousand million" is one billion.
*
* number is the number to convert. The entire unsigned 64 bit range is supported.
* output is the buffer into which the output string should be written. It may be NULL.
* output_size is the total number of bytes that the output buffer can hold.
* If output is NULL, output_size is ignored.
* If output is non-NULL and the string is longer than output_size, the output will be truncated but will still be NULL terminated.
* If output is non-NULL and output_size is 0, output remains untouched.
* The function returns the total number of bytes required to hold the complete output string (including the NULL terminator).
* If the return value is greater than output_size, this indicates that the buffer was too small and had to be truncated.
* You may then resize your buffer so that it can hold the number of bytes returned by this function and invoke it again.
    */
size_t bl_number_to_words ( bl_uint64 number, char* output, size_t output_size, bool include_and );

#ifdef __cplusplus
}
#endif
#endif  /* BL_NUMWORDS_H */

/* IMPLEMENTATION */

#ifdef BL_NUMWORDS_IMPLEMENTATION

#include <assert.h>

static char* bl_append_string_with_space ( char* destination, char* destination_end, size_t* written_bytes, const char* source )
{
if(destination==NULL || (destination && destination==destination_end))
{
    for ( ; *source; ++source )
    {
        assert ( *source );
        ++*written_bytes;
    }
    ++*written_bytes;
}
else
{
    for ( ; *source; ++source )
    {
        assert ( *source );
        if ( destination != destination_end )
        {
            *destination = *source;
            ++destination;
        }
        ++*written_bytes;
    }
    if ( destination != destination_end )
    {
        *destination = ' ';
        ++destination;
    }
    ++*written_bytes;
}

    return destination;
}

size_t bl_number_to_words ( bl_uint64 number, char* output, size_t output_size, bool include_and )
{
    static const char* first[] = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};
    static const char* second[] = {"ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"};
    static const char* third[] = {"twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"};
    static const char* fourth[] = {"hundred", "thousand", "million", "billion", "trillion", "quadrillion", "quintillion"};
    uint8_t three_position = 0;
    uint8_t digit_string[20];
    uint8_t* ptr = digit_string + 20;
    uint8_t digits = 0;
    uint8_t i;
    uint8_t empty_group = 1;
    size_t written_bytes = 0;
    char* output_end = NULL;

    if ( output && output_size )
    {
        output_end = output + ( output_size - 1 );
    }
    else if ( output )
    {
        output = NULL;
    }

    do
    {
        * ( --ptr ) = ( uint8_t ) ( number % 10 );
        assert ( ptr >= digit_string );
        ++digits;
        assert ( digits <= 20 );
        number /= 10;
    }
    while ( number > 0 );

    if ( digits > 3 )
    {
        three_position = digits - 4;
        three_position = three_position - ( three_position % 3 );
        three_position /= 3;
        ++three_position;
    }

    for ( i = 0; i < digits; ++i )
    {
        uint8_t place = ( digits - i ) % 3;
        if ( ptr[i] != 0 )
        {
            empty_group = 0;
        }
        switch ( place )
        {
            case 0: /* Hundreds. */
                if ( ptr[i] != 0 )
                {
                    output = bl_append_string_with_space ( output, output_end, &written_bytes, first[ptr[i]] );
                    output = bl_append_string_with_space ( output, output_end, &written_bytes, fourth[0] );
                }
                assert ( ( i + 2 ) < digits );
                if ( include_and && ( ptr[i + 1] != 0 || ptr[i + 2] != 0 ) )
                {
                    output = bl_append_string_with_space ( output, output_end, &written_bytes, "and" );
                }
                break;
            case 2: /* Tens. */
                if ( ptr[i] != 0 )
                {
                    if ( ptr[i] == 1 ) /* Teens. */
                    {
                        output = bl_append_string_with_space ( output, output_end, &written_bytes, second[ptr[i + 1]] );
                        ptr[i + 1] = 0;
                    }
                    else /* Tens. */
                    {
                        output = bl_append_string_with_space ( output, output_end, &written_bytes, third[ptr[i] - 2] );
                    }
                }
                break;
            case 1: /* Ones. */
                if ( ptr[i] != 0 || digits == 1 )
                {
                    output = bl_append_string_with_space ( output, output_end, &written_bytes, first[ptr[i]] );
                }
                if ( three_position )
                {
                    if ( !empty_group )
                    {
                        output = bl_append_string_with_space ( output, output_end, &written_bytes, fourth[three_position] );
                    }
                    --three_position;
                }
                empty_group = 1;
                break;
        };
    }

    if ( output )
    {
        *output = 0;
        if ( output_size > 1 && output[-1] == ' ' )
        {
            output[-1] = 0;
        }
    }

    return written_bytes;
}

#endif /* BL_NUMWORDS_IMPLEMENTATION */

/* REVISION HISTORY
*
* Version 1.0 - 2019-02-03
* Initial release.
*/

/* LICENSE

This software is available under 2 licenses -- choose whichever you prefer.
------------------------------------------------------------------------------
ALTERNATIVE A - MIT No Attribution License
Copyright (c) 2019 Philip Bennefall

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
ALTERNATIVE B - Public Domain (www.unlicense.org)
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
------------------------------------------------------------------------------
*/
