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
#include <winternl.h>
#endif
#include <string_view>
#include <atomic>
#include <angelscript.h>
#include <cassert>
#include <array>

#ifdef _WIN32
static LPVOID mem_addr = nullptr;
static PSAPI_WORKING_SET_EX_INFORMATION working_set_information;
static PVOID ldr_dll_cookie = nullptr;
#ifdef __cplusplus
extern "C" {
#endif
static constexpr ULONG LDR_DLL_NOTIFICATION_REASON_LOADED = 1;
static constexpr ULONG LDR_DLL_NOTIFICATION_REASON_UNLOADED = 2;

typedef struct _LDR_DLL_LOADED_NOTIFICATION_DATA {
	ULONG Flags;					//Reserved.
	PCUNICODE_STRING FullDllName;   //The full path name of the DLL module.
	PCUNICODE_STRING BaseDllName;   //The base file name of the DLL module.
	PVOID DllBase;				  //A pointer to the base address for the DLL in memory.
	ULONG SizeOfImage;			  //The size of the DLL image, in bytes.
} LDR_DLL_LOADED_NOTIFICATION_DATA, *PLDR_DLL_LOADED_NOTIFICATION_DATA;

typedef struct _LDR_DLL_UNLOADED_NOTIFICATION_DATA {
	ULONG Flags;					//Reserved.
	PCUNICODE_STRING FullDllName;   //The full path name of the DLL module.
	PCUNICODE_STRING BaseDllName;   //The base file name of the DLL module.
	PVOID DllBase;				  //A pointer to the base address for the DLL in memory.
	ULONG SizeOfImage;			  //The size of the DLL image, in bytes.
} LDR_DLL_UNLOADED_NOTIFICATION_DATA, *PLDR_DLL_UNLOADED_NOTIFICATION_DATA;

typedef union _LDR_DLL_NOTIFICATION_DATA {
	LDR_DLL_LOADED_NOTIFICATION_DATA Loaded;
	LDR_DLL_UNLOADED_NOTIFICATION_DATA Unloaded;
} LDR_DLL_NOTIFICATION_DATA, *PLDR_DLL_NOTIFICATION_DATA;

typedef VOID (NTAPI *PLDR_DLL_NOTIFICATION_FUNCTION)(ULONG, const PLDR_DLL_NOTIFICATION_DATA, PVOID);
#ifdef __cplusplus
}
#endif
using PFN_LdrRegisterDllNotification = NTSTATUS (NTAPI*)(ULONG, PLDR_DLL_NOTIFICATION_FUNCTION, PVOID, PVOID*);
using PFN_LdrUnregisterDllNotification = NTSTATUS (NTAPI*)(PVOID);
static PFN_LdrRegisterDllNotification pfn_ldr_register   = nullptr;
static PFN_LdrUnregisterDllNotification pfn_ldr_unregister = nullptr;
#endif
std::atomic_flag memory_scan_detected;
std::atomic_flag speed_hack_detected;

#ifdef _WIN32
#if defined(__x86_64__) || defined(_M_X64) || defined(__amd64__)
uint8_t safe_read(const uint8_t* addr) {
	__try {
		return *reinterpret_cast<volatile const uint8_t*>(addr);
	} __except (EXCEPTION_EXECUTE_HANDLER) {
		return 0xFF;
	}
}
#elif defined(__aarch64__) || defined(_M_ARM64) || defined(__arm64__)
bool safe_read32(const uint32_t* addr, uint32_t& out) {
	__try {
		out = *reinterpret_cast<volatile const uint32_t*>(addr);
		return true;
	} __except (EXCEPTION_EXECUTE_HANDLER) {
		return false;
	}
}
#endif

bool is_executable(void* address) {
	MEMORY_BASIC_INFORMATION mbi;
	if (!VirtualQuery(address, &mbi, sizeof(mbi))) return false;
	return (mbi.Protect & PAGE_EXECUTE_READ) || (mbi.Protect & PAGE_EXECUTE_READWRITE) || (mbi.Protect & PAGE_EXECUTE);
}

#if defined(__x86_64__) || defined(_M_X64) || defined(__amd64__)
bool is_modrm_jump(uint8_t opcode, uint8_t modrm) {
	const uint8_t op = opcode;
	const uint8_t mod = (modrm & 0b11000000) >> 6;
	const uint8_t reg = (modrm & 0b00111000) >> 3;
	// FF /4 is near jump, FF /5 is far jump
	return (op == 0xFF && (reg == 4 || reg == 5));
}

bool is_fnop(const uint8_t* bytes) {
	return bytes[0] == 0xD9 && bytes[1] == 0xD0;
}

bool is_nop(const uint8_t* bytes) {
	if (bytes[0] == 0x90) return true;				  // 1-byte NOP
	if (bytes[0] == 0x66 && bytes[1] == 0x90) return true; // 2-byte NOP
	if (bytes[0] == 0x0F && bytes[1] == 0x1F) return true; // multi-byte NOP
	if (bytes[0] >= 0x40 && bytes[0] <= 0x4F && bytes[1] == 0x90) return true; // REX-prefixed NOP
	return false;
}
#endif

bool is_function_hooked(void* func_ptr) {
	if (!is_executable(func_ptr)) {
		return true;
	}

#if defined(__x86_64__) || defined(_M_X64) || defined(__amd64__)
	const uint8_t* p = reinterpret_cast<const uint8_t*>(func_ptr);
	size_t offset = 0, n_nops = 0;

	// Skip leading NOPs (up to 16 bytes)
	while (offset < 16 && is_nop(p + offset)) {
		offset++;
		n_nops++;
	}

	// JMP rel8
	if (p[offset] == 0xEB) {
		return true;
	}

	// JMP rel16 or rel32
	if (p[offset] == 0xE9) {
		return true;
	}

	// FAR JMP absolute
	if (p[offset] == 0xEA) {
		return true;
	}

	// JMP r/mX (FF /4 or FF /5)
	if (p[offset] == 0xFF && is_modrm_jump(p[offset], p[offset + 1])) {
		return true;
	}

	// MOV RAX, imm64; JMP RAX (far jmp)
	if (p[offset] == 0x48 && p[offset + 1] == 0xB8 && p[offset + 10] == 0xFF && p[offset + 11] == 0xE0) {
		return true;
	}

	// INT3
	if (p[offset] == 0xCC) {
		return true;
	}

	// RET
	if (p[offset] == 0xC3) {
		return true;
	}

	// FNOP (floating-point NOP)
	if (is_fnop(p + offset)) {
		return true;
	}

	// Suspiciously many NOPs at start
	// This is more of a heuristic guess
	if (n_nops >= 5) {
		return true;
	}
#elif defined(__aarch64__) || defined(_M_ARM64) || defined(__arm64__)
	constexpr uint32_t ARM64_NOP	 = 0x1F2003D5;
	constexpr uint32_t ARM64_RET	 = 0xD65F03C0;
	constexpr uint32_t ARM64_BRK	 = 0xD4200000; // BRK #0
	uint32_t instr[4] = {};
	for (int i = 0; i < 4; ++i) {
		if (!safe_read32(((uint32_t*)func_ptr) + i, instr[i])) {
			return true;
		}
	}

	// Early RET
	if (instr[0] == ARM64_RET) {
		return true;
	}

	// BRK
	if ((instr[0] & 0xFFFFF000) == ARM64_BRK) {
		return true;
	}

	// LDR Xt, #imm + BR Xt (common hook: load addr + jump)
	if ((instr[0] & 0xFFC00000) == 0x58000000 && (instr[1] & 0xFFFFFC1F) == 0xD61F0000) {
		return true;
	}

	// Absolute branch (B, BL)
	if ((instr[0] & 0x7C000000) == 0x14000000) {
		return true;
	}

	// MOVZ/MOVK sequence to synthesize addr + BR
	if ((instr[0] & 0xFFC00000) == 0xD2800000 && (instr[1] & 0xFFC00000) == 0xF2800000 && (instr[2] & 0xFFFFFC1F) == 0xD61F0000) {
		return true;
	}

	// NOP sleds
	int nops = 0;
	for (int i = 0; i < 8; ++i) {
		uint32_t word;
		if (!safe_read32(((uint32_t*)func_ptr) + i, word)) break;
		if (word == ARM64_NOP)
			nops++;
		else
			break;
	}

	if (nops >= 4) {
		return true;
	}
#endif

	return false;
}
#endif

// This function is executed every  game iteration.
void anticheat_check() {
	memory_scan_detected.clear();
#ifdef _WIN32
	std::memset(&working_set_information, 0, sizeof(working_set_information));
	working_set_information.VirtualAddress = mem_addr;
	const auto res = K32QueryWorkingSetEx((HANDLE)-1, &working_set_information, sizeof(working_set_information));
	if (res && (working_set_information.VirtualAttributes.Flags & 1) != 0) {
		memory_scan_detected.test_and_set();
		if (VirtualFree(mem_addr, 0, MEM_RELEASE) == 0) FatalAppExit(0, L"Failed to release an internal memory block"); // Should we do this, or set a flag?
		mem_addr = VirtualAlloc(nullptr, 0x1000, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
	}
	std::array<void*, 4> funcs {{&QueryPerformanceCounter, &timeGetTime, &GetTickCount, &GetTickCount64}};
	for (void* func: funcs)
		if (is_function_hooked(func))
			speed_hack_detected.test_and_set();
#endif
}

void anticheat_deinit() {
	#ifdef _WIN32
	if (pfn_ldr_unregister && ldr_dll_cookie) pfn_ldr_unregister(ldr_dll_cookie);
	#endif
}

#ifdef _WIN32
void handle_dll_loader_notification(ULONG reason, const PLDR_DLL_NOTIFICATION_DATA data, PVOID ctx) {
	switch (reason) {
		case LDR_DLL_NOTIFICATION_REASON_LOADED: {
			const auto name = std::wstring_view(data->Loaded.BaseDllName->Buffer);
			if (name == L"speedhack-i386.dll" || name == L"speedhack-x86_64.dll") {
				speed_hack_detected.test_and_set();
			}
			HMODULE module_handle = nullptr;
			if (GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, reinterpret_cast<LPCWSTR>(data->Loaded.DllBase), &module_handle)) {
				if (GetProcAddress(module_handle, "InitializeSpeedhack") || GetProcAddress(module_handle, "realGetTickCount") || GetProcAddress(module_handle, "realGetTickCount64") || GetProcAddress(module_handle, "realQueryPerformanceCounter") || GetProcAddress(module_handle, "speedhackversion_GetTickCount") || GetProcAddress(module_handle, "speedhackversion_GetTickCount64") || GetProcAddress(module_handle, "speedhackversion_QueryPerformanceCounter")) {
					speed_hack_detected.test_and_set();
				}
				FreeLibrary(module_handle);
			}
		} break;
		case LDR_DLL_NOTIFICATION_REASON_UNLOADED: {
			const auto name = std::wstring_view(data->Unloaded.BaseDllName->Buffer);
			if (name == L"speedhack-i386.dll" || name == L"speedhack-x86_64.dll") {
				speed_hack_detected.clear();
			}
			HMODULE module_handle = nullptr;
			if (GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, reinterpret_cast<LPCWSTR>(data->Unloaded.DllBase), &module_handle)) {
				if (GetProcAddress(module_handle, "InitializeSpeedhack") || GetProcAddress(module_handle, "realGetTickCount") || GetProcAddress(module_handle, "realGetTickCount64") || GetProcAddress(module_handle, "realQueryPerformanceCounter") || GetProcAddress(module_handle, "speedhackversion_GetTickCount") || GetProcAddress(module_handle, "speedhackversion_GetTickCount64") || GetProcAddress(module_handle, "speedhackversion_QueryPerformanceCounter")) {
					speed_hack_detected.clear();
				}
				FreeLibrary(module_handle);
			}
		} break;
	}
}
#endif

void register_anticheat(asIScriptEngine* engine) {
#ifdef _WIN32
	mem_addr = VirtualAlloc(nullptr, 0x1000, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
	HMODULE ntdll_handle = GetModuleHandle(L"ntdll.dll");
	assert(ntdll_handle != INVALID_HANDLE_VALUE || ntdll_handle != NULL);
	// If this fails, consider it a fatal exit condition, because ntdll.dll should (always) be loaded
	if (ntdll_handle == INVALID_HANDLE_VALUE || ntdll_handle == NULL) FatalAppExit(0, L"NtDll.dll was not found in the module list!");
	pfn_ldr_register = reinterpret_cast<PFN_LdrRegisterDllNotification>(GetProcAddress(ntdll_handle, "LdrRegisterDllNotification"));
	pfn_ldr_unregister = reinterpret_cast<PFN_LdrUnregisterDllNotification>(GetProcAddress(ntdll_handle, "LdrUnregisterDllNotification"));
	assert(pfn_ldr_register != NULL);
	assert(pfn_ldr_unregister != NULL);
	if (pfn_ldr_register) pfn_ldr_register(0, &handle_dll_loader_notification, nullptr, &ldr_dll_cookie);
#endif
	engine->RegisterGlobalProperty("const atomic_flag speed_hack_detected", (void*)&speed_hack_detected);
	engine->RegisterGlobalProperty("const atomic_flag memory_scan_detected", (void*)&memory_scan_detected);
}
