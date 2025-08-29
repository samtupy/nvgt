/* test_plugin.cpp - small plugin example
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

#include <windows.h>
#include "../../src/nvgt_plugin.h"

void do_test() {
	MessageBoxA(0, "It works, this function is being called from within the context of an NVGT plugin!", "success", 0);
}
void do_exception() {
	asGetActiveContext()->SetException("It's rare when an exception being thrown is a good thing...");
}

plugin_main(nvgt_plugin_shared* shared) {
	prepare_plugin(shared);
	shared->script_engine->RegisterGlobalFunction("void do_test()", asFUNCTION(do_test), asCALL_CDECL);
	shared->script_engine->RegisterGlobalFunction("void do_exception()", asFUNCTION(do_exception), asCALL_CDECL);
	return true;
}
