// This file defines the implementations of all single header dependencies used in this project to increase build speed.

#ifdef _WIN32
#include <windows.h>
#else
#include <cstdio>
#include <cstdlib>
#include <cstring>
#endif

#define BL_NUMWORDS_IMPLEMENTATION
#include "bl_number_to_words.h"
#define VERBLIB_IMPLEMENTATION
#include "verblib.h"
#define DBGTOOLS_IMPLEMENTATION
#include "dbgtools.h"
#define RND_IMPLEMENTATION
#include "rnd.h"
#define SPEECH_IMPLEMENTATION
#include "speech.h"
#define THREAD_IMPLEMENTATION
#include "thread.h"
