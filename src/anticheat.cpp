/* anticheat.cpp - implementation of basic anti-cheat measures
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

#include "anticheat.h"
#ifdef _WIN32
#include <windows.h>
#include <psapi.h>
#include <tlhelp32.h>
#endif
#include <string_view>
#include <atomic>
#include <angelscript.h>

#ifdef _WIN32
static LPVOID mem_addr = nullptr;
static PSAPI_WORKING_SET_EX_INFORMATION working_set_information;
#endif
std::atomic_flag memory_scan_detected;
std::atomic_flag speed_hack_detected;

// This function is executed every  game iteration.
void anticheat_check() {
	memory_scan_detected.clear();
	speed_hack_detected.clear();
#ifdef _WIN32
	std::memset(&working_set_information, 0, sizeof(working_set_information));
	working_set_information.VirtualAddress = mem_addr;
	const auto res = K32QueryWorkingSetEx((HANDLE)-1, &working_set_information, sizeof(working_set_information));
	if (res && (working_set_information.VirtualAttributes.Flags & 1) != 0) {
		memory_scan_detected.test_and_set();
	}
	const auto hdl = CreateToolhelp32Snapshot(TH32CS_SNAPHEAPLIST | TH32CS_SNAPMODULE | TH32CS_SNAPMODULE32 | TH32CS_SNAPTHREAD, GetCurrentProcessId());
	if (hdl != INVALID_HANDLE_VALUE) {
		MODULEENTRY32 entry;
		entry.dwSize = sizeof(MODULEENTRY32);
		if (Module32First(hdl, &entry)) {
			do {
				const auto modname = std::wstring_view(entry.szModule);
				if (modname == L"speedhack-i386.dll" || modname == L"speedhack-x86_64.dll" || GetProcAddress(entry.hModule, "InitializeSpeedhack") || GetProcAddress(entry.hModule, "realGetTickCount") || GetProcAddress(entry.hModule, "realGetTickCount64") || GetProcAddress(entry.hModule, "realQueryPerformanceCounter") || GetProcAddress(entry.hModule, "speedhackversion_GetTickCount") || GetProcAddress(entry.hModule, "speedhackversion_GetTickCount64") || GetProcAddress(entry.hModule, "speedhackversion_QueryPerformanceCounter")) {
					speed_hack_detected.test_and_set();
				}
			} while (Module32Next(hdl, &entry));
		}
		CloseHandle(hdl);
	}
#endif
}

void anticheat_deinit() {
	// To do: do what we need to do to handle POSIX/MacOS...
}

void register_anticheat(asIScriptEngine* engine) {
#ifdef _WIN32
	mem_addr = VirtualAlloc(nullptr, 0x1000, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
#endif
	engine->RegisterGlobalProperty("const atomic_flag speed_hack_detected", (void*)&speed_hack_detected);
	engine->RegisterGlobalProperty("const atomic_flag memory_scan_detected", (void*)&memory_scan_detected);
}
