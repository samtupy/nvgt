/* winhooks.cpp - Implementation of winhooks.h
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

#include "winhooks.h"
#ifdef _WIN32
#include <windows.h>
#include <accctrl.h>
#include <aclapi.h>
#include <sddl.h>
#include <format>
#include <stdexcept>
#include <vector>
#endif

void apply_winapi_hooks() {
#ifdef _WIN32
#ifdef NDEBUG
HANDLE hProcess = GetCurrentProcess();
PSECURITY_DESCRIPTOR pSD = NULL;
PACL pOldDACL = NULL;
auto res = GetSecurityInfo(hProcess, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION, NULL, NULL, &pOldDACL, NULL, &pSD);
if (res != ERROR_SUCCESS) {
throw std::runtime_error(std::format("Can't get process security info, error {}", res));
}
PSID pEveryoneSID = NULL;
SID_IDENTIFIER_AUTHORITY SIDAuthWorld = SECURITY_WORLD_SID_AUTHORITY;
if (res = AllocateAndInitializeSid(&SIDAuthWorld, 1, SECURITY_WORLD_RID, 0, 0, 0, 0, 0, 0, 0, &pEveryoneSID); !res) {
LocalFree(pSD);
throw std::runtime_error(std::format("Cannot initialize SID, error code {}", res)); 
}
PACL pNewDACL = NULL;
std::vector<EXPLICIT_ACCESS> eas;
const std::vector<DWORD> denied_perms = {{PROCESS_ALL_ACCESS, PROCESS_CREATE_PROCESS, PROCESS_CREATE_THREAD, PROCESS_DUP_HANDLE, PROCESS_QUERY_INFORMATION, PROCESS_QUERY_LIMITED_INFORMATION, PROCESS_SET_INFORMATION, PROCESS_SET_QUOTA, PROCESS_SUSPEND_RESUME, PROCESS_TERMINATE, PROCESS_VM_OPERATION, PROCESS_VM_READ, PROCESS_VM_WRITE, SYNCHRONIZE}};
for (const auto& perm : denied_perms) {
EXPLICIT_ACCESS ea;
ZeroMemory(&ea, sizeof(ea));
ea.grfAccessPermissions = perm;
ea.grfAccessMode = DENY_ACCESS;
ea.grfInheritance = NO_INHERITANCE;
ea.Trustee.TrusteeForm = TRUSTEE_IS_SID;
ea.Trustee.TrusteeType = TRUSTEE_IS_WELL_KNOWN_GROUP;
ea.Trustee.ptstrName = (LPWSTR)pEveryoneSID;
eas.emplace_back(ea);
}
res = SetEntriesInAcl(eas.size(), eas.data(), pOldDACL, &pNewDACL);
if (res != ERROR_SUCCESS) {
FreeSid(pEveryoneSID);
LocalFree(pSD);
throw std::runtime_error(std::format("Cannot set process entries in ACE, error code {}", res));
}
res = SetSecurityInfo(hProcess, SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION, NULL, NULL, pNewDACL, NULL);
if (res != ERROR_SUCCESS) {
FreeSid(pEveryoneSID);
LocalFree(pSD);
throw std::runtime_error(std::format("Cannot set process ACL information, error code {}", res));
}
FreeSid(pEveryoneSID);
LocalFree(pSD);
LocalFree(pNewDACL);
#endif
#endif
}
