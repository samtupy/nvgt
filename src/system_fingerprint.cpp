/* system_fingerprint.cpp - code for generating unique system IDs
 * original repo: https://github.com/Tarik02/machineid
 * Note that before version 1.0 it is very likely that this function will be rewritten from scratch using various functions from Poco and SDL, as well as having callbacks into nvgt_config.h  for extra security.
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


#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#define VC_EXTRALEAN
	#include <windows.h>
	#include <intrin.h>
	#include <iphlpapi.h>
#endif
#include <SDL3/SDL.h>
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) && !defined(__CYGWIN__)
unsigned short hashMacAddress(PIP_ADAPTER_INFO info) {
	unsigned short hash = 0;
	for (unsigned int i = 0; i < info->AddressLength; i++)
		hash += (info->Address[i] << ((i & 1) * 8));
	return hash;
}

void getMacHash(unsigned short& mac1, unsigned short& mac2) {
	IP_ADAPTER_INFO AdapterInfo[32];
	DWORD dwBufLen = sizeof(AdapterInfo);

	DWORD dwStatus = GetAdaptersInfo(AdapterInfo, &dwBufLen);
	if (dwStatus != ERROR_SUCCESS)
		return; // no adapters.

	PIP_ADAPTER_INFO pAdapterInfo = AdapterInfo;
	mac1 = hashMacAddress(pAdapterInfo);
	if (pAdapterInfo->Next)
		mac2 = hashMacAddress(pAdapterInfo->Next);
	if (mac1 > mac2) {
		unsigned short tmp = mac2;
		mac2 = mac1;
		mac1 = tmp;
	}
}

unsigned short getVolumeHash() {
	DWORD serialNum = 0;
	GetVolumeInformation(L"c:\\", NULL, 0, &serialNum, NULL, NULL, NULL, 0);
	unsigned short hash = (unsigned short)((serialNum + (serialNum >> 16)) & 0xFFFF);
	return hash;
}

unsigned short getCpuHash() {
	int cpuinfo[4] =
	{0, 0, 0, 0};
	__cpuid(cpuinfo, 0);
	unsigned short hash = 0;
	unsigned short* ptr = (unsigned short*)(&cpuinfo[0]);
	for (unsigned int i = 0; i < 8; i++)
		hash += ptr[i];
	return hash;
}

const char* getMachineName() {
	static char computerName[1024];
	DWORD size = 1024;
	GetComputerNameA(computerName, &size);
	return &(computerName[0]);
}
#else
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/resource.h>
#include <sys/utsname.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>

#ifdef __APPLE__
	#include <net/if_dl.h>
	#include <ifaddrs.h>
	#include <net/if_types.h>
	#include <IOKit/IOKitLib.h>
#else //!__APPLE__
	#include <linux/if.h>
	#include <linux/sockios.h>
#endif //!__APPLE__

const char* getMachineName() {
	static struct utsname u;

	if (uname(&u) < 0)
		return "unknown";

	return u.nodename;
}

unsigned short hashMacAddress(unsigned char* mac) {
	unsigned short hash = 0;

	for (unsigned int i = 0; i < 6; i++)
		hash += (mac[i] << ((i & 1) * 8));
	return hash;
}

void getMacHash(unsigned short& mac1, unsigned short& mac2) {
	mac1 = 0;
	mac2 = 0;

	#ifdef __APPLE__
	struct ifaddrs* ifaphead;
	if (getifaddrs(&ifaphead) != 0)
		return;
	bool foundMac1 = false;
	struct ifaddrs* ifap;
	for (ifap = ifaphead; ifap; ifap = ifap->ifa_next) {
		struct sockaddr_dl* sdl = (struct sockaddr_dl*)ifap->ifa_addr;
		if (sdl && (sdl->sdl_family == AF_LINK) && (sdl->sdl_type == IFT_ETHER)) {
			if (!foundMac1) {
				foundMac1 = true;
				mac1 = hashMacAddress((unsigned char*)(LLADDR(sdl))); //sdl->sdl_data) + sdl->sdl_nlen) );
			} else {
				mac2 = hashMacAddress((unsigned char*)(LLADDR(sdl))); //sdl->sdl_data) + sdl->sdl_nlen) );
				break;
			}
		}
	}
	freeifaddrs(ifaphead);
	#else // !__APPLE__
	int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (sock < 0)
		return;
	struct ifconf conf;
	char ifconfbuf[128 * sizeof(struct ifreq)];
	memset(ifconfbuf, 0, sizeof(ifconfbuf));
	conf.ifc_buf = ifconfbuf;
	conf.ifc_len = sizeof(ifconfbuf);
	if (ioctl(sock, SIOCGIFCONF, &conf))
		return;
	bool foundMac1 = false;
	struct ifreq* ifr;
	for (ifr = conf.ifc_req; (char*)ifr < (char*)conf.ifc_req + conf.ifc_len; ifr++) {
		if (ifr->ifr_addr.sa_data == (ifr + 1)->ifr_addr.sa_data)
			continue; // duplicate, skip it
		if (ioctl(sock, SIOCGIFFLAGS, ifr))
			continue; // failed to get flags, skip it
		if (ioctl(sock, SIOCGIFHWADDR, ifr) == 0) {
			if (!foundMac1) {
				foundMac1 = true;
				mac1 = hashMacAddress((unsigned char*) & (ifr->ifr_addr.sa_data));
			} else {
				mac2 = hashMacAddress((unsigned char*) & (ifr->ifr_addr.sa_data));
				break;
			}
		}
	}
	close(sock);
	#endif // !__APPLE__
	if (mac1 > mac2) {
		unsigned short tmp = mac2;
		mac2 = mac1;
		mac1 = tmp;
	}
}

#ifdef __APPLE__
unsigned long long getSystemSerialNumberHash() {
	unsigned long long hash = 0;
	unsigned char* phash = (unsigned char*)&hash;
	io_service_t platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
	if (!platformExpert) return 0;
	CFTypeRef t = IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault, 0);
	CFStringRef serialNumber = (CFStringRef)t;
	if (serialNumber) {
		const char* cs = (const char*) CFStringGetCStringPtr(serialNumber, kCFStringEncodingMacRoman);
		unsigned int i = 0;
		while (*cs)
			phash[i++ % sizeof(unsigned long long)] ^= *cs++;
	}
	CFRelease(serialNumber);
	IOObjectRelease(platformExpert);
	return hash;
}
#endif

unsigned short getVolumeHash() {
	#ifdef __APPLE__
	return (unsigned short)getSystemSerialNumberHash();
	#else
	unsigned char* sysname = (unsigned char*)getMachineName();
	unsigned short hash = 0;
	for (unsigned int i = 0; sysname[i]; i++)
		hash += (sysname[i] << ((i & 1) * 8));
	return hash;
	#endif
}

#ifdef __APPLE__
#include <mach-o/arch.h>
unsigned short getCpuHash() {
	unsigned short val = SDL_GetNumLogicalCPUCores() + SDL_GetCPUCacheLineSize();
	return val;
}

#else // !__APPLE__

static void getCpuid(unsigned int* eax, unsigned int* ebx, unsigned int* ecx, unsigned int* edx) {
	#ifdef __ANDROID__
		return;
	#else
	#ifdef __arm__
	*eax = 0xFD;
	*ebx = 0xC1;
	*ecx = 0x72;
	*edx = 0x1D;
	return;
	#else
	asm volatile("cpuid" :
	             "=a"(*eax),
	             "=b"(*ebx),
	             "=c"(*ecx),
	             "=d"(*edx) : "0"(*eax), "2"(*ecx));
	#endif
	#endif
}

unsigned short getCpuHash() {
	unsigned int cpuinfo[4] =
	{0, 0, 0, 0};
	getCpuid(&cpuinfo[0], &cpuinfo[1], &cpuinfo[2], &cpuinfo[3]);
	unsigned short hash = 0;
	unsigned int* ptr = (&cpuinfo[0]);
	for (unsigned int i = 0; i < 4; i++)
		hash += (ptr[i] & 0xFFFF) + (ptr[i] >> 16);
	return hash;
}
#endif // !__APPLE__
#endif


#include <obfuscate.h>
#include <Poco/Path.h>
#include "system_fingerprint.h"
#include "hash.h"
#include "misc_functions.h"
#include <sstream>

std::string generateHash(const std::string& bytes) {
	static char chars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	std::stringstream stream;
	auto size = bytes.size();
	for (unsigned long i = 0; i < size; ++i) {
		unsigned char ch = ~((unsigned char)((unsigned short)bytes[i] + (unsigned short)bytes[(i + 1) % size] + (unsigned short)bytes[(i + 2) % size] + (unsigned short)bytes[(i + 3) % size])) * (i + 1);
		unsigned char ch2 = chars[(ch >> 4) & 62];
		if (ch2 == 0) ch2 = 5;
		stream << ch2 << chars[ch & 62];
	}
	return stream.str();
}


static std::string* cachedHash = nullptr;
static std::string cachedIdentifier = "";
std::string generate_system_fingerprint_legacy1(const std::string& identifier) {
	if (cachedHash != nullptr && cachedIdentifier == identifier)
		return *cachedHash;
	std::stringstream stream;
	unsigned short mac1;
	unsigned short mac2;
	getMacHash(mac1, mac2);
	stream << mac1;
	stream << mac2;
	stream << getCpuHash();
	stream << getVolumeHash();
	stream << identifier;
	return generateHash(sha256(stream.str(), true));
}
std::string generate_system_fingerprint(const std::string& identifier = "") {
	std::stringstream stream;
	stream << SDL_GetSystemRAM();
	stream << Poco::Path::expand(std::string(_O("%NUMBER_OF_PROCESSORS% %PROCESSOR_ARCHITECTURE% %PROCESSOR_IDENTIFIER% %PROCESSOR_LEVEL% %PROCESSOR_REVISION%")));
	stream << getCpuHash();
	stream << getVolumeHash();
	stream << identifier;
	return generateHash(sha256(stream.str(), true));
}

void RegisterSystemFingerprintFunction(asIScriptEngine* engine) {
	engine->RegisterGlobalFunction(_O("string generate_system_fingerprint(const string&in application_id = "")"), asFUNCTION(generate_system_fingerprint), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("string generate_system_fingerprint_legacy1(const string&in application_id = "")"), asFUNCTION(generate_system_fingerprint_legacy1), asCALL_CDECL);
}
