/* android_fopen.h
 * SDL allows us to read from content:/ URIs on android. This function undoes SDL's stream abstraction so that the file descriptor can be passed to things like Poco FileStreams or Angelscript's script builder.
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include <SDL3/SDL.h>

#ifdef __cplusplus
extern "C" {
#endif
int android_fopen(const char* filename, const char* mode);
#ifdef __cplusplus
}
#endif

#ifdef ANDROID_FOPEN_IMPLEMENTATION
#include <unistd.h>
int android_fopen(const char* filename, const char* mode) {
	SDL_IOStream* stream = SDL_IOFromFile(filename, mode);
	if (!stream) return -1;
	SDL_PropertiesID props = SDL_GetIOProperties(stream);
	FILE* fptr = (FILE*)SDL_GetPointerProperty(props, SDL_PROP_IOSTREAM_STDIO_FILE_POINTER, nullptr);
	if (!fptr) {
		SDL_CloseIO(stream);
		return -1; // Might be an android asset which is not the point of this function.
	}
	int new_fd = dup(fileno(fptr));
	SDL_CloseIO(stream);
	return new_fd;
}
#endif
