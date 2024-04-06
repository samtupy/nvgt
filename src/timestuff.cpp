/* timestuff.cpp - code for date/time related routines from checking the system clock to timers.
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

#include "timestuff.h"
#ifdef _WIN32
#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#define VC_EXTRALEAN
#include <windows.h>
#endif
#include <cstring>
#include <ctime>
#include <string>
#include <chrono>
#include <obfuscate.h>
#include <fstream>
#include <iostream>
#include <Poco/Timezone.h>
#include "nvgt.h"
#include "scriptstuff.h"

std::chrono::high_resolution_clock::time_point g_clock=std::chrono::high_resolution_clock::now();
#ifdef _WIN32
ULARGE_INTEGER g_ftclock;
#endif
void timestuff_startup() {
	#ifdef _WIN32
	FILETIME ft_now;
	GetSystemTimeAsFileTime(&ft_now);
	g_ftclock.LowPart  = ft_now.dwLowDateTime;
	g_ftclock.HighPart = ft_now.dwHighDateTime;
	#endif
}

static asIScriptContext* callback_ctx=NULL;
timer_queue_item::timer_queue_item(timer_queue* parent, const std::string& id, asIScriptFunction* callback, const std::string& callback_data, int timeout, bool repeating) : parent(parent), id(id), callback(callback), callback_data(callback_data), timeout(timeout), repeating(repeating), is_scheduled(true) {
}
void timer_queue_item::execute() {
	is_scheduled=false;
	asIScriptContext* ACtx=asGetActiveContext();
	bool new_context=ACtx==NULL||ACtx->PushState()<0;
	asIScriptContext* ctx=(new_context? g_ScriptEngine->RequestContext() : ACtx);
	if(!ctx) {
		parent->failures+=id;
		parent->failures+="; can't get context.\r\n";
		parent->failures+=get_call_stack();
		parent->erase(id);
		return;
	}
	int rp=0;
	if((rp=ctx->Prepare(callback))<0) {
		char tmp[200];
		snprintf(tmp, 200, "%s; can't prepare; %d\r\n", id.c_str(), rp);
		parent->failures+=tmp;
		parent->failures+=get_call_stack();
		parent->erase(id);
		if(new_context) g_ScriptEngine->ReturnContext(ctx);
		else ctx->PopState();
		return;
	}
	ctx->SetArgObject(0, &id);
	ctx->SetArgObject(1, &callback_data);
	int xr=ctx->Execute();
	int ms=0;
	if(xr==asEXECUTION_FINISHED)
		ms=ctx->GetReturnDWord();
	else if(!is_scheduled||xr==asEXECUTION_EXCEPTION)
		repeating=false;
	if(repeating&&ms<1) ms=timeout;
	if(new_context) g_ScriptEngine->ReturnContext(ctx);
	else ctx->PopState();
	if(!is_scheduled) {
		if(ms>0) {
			parent->schedule(this, ms);
			is_scheduled=true;
		} else
			parent->erase(id);
	}
}
timer_queue::timer_queue() : RefCount(1), last_looped(ticks()), open_tick(false) {
}
void timer_queue::add_ref() {
	asAtomicInc(RefCount);
}
void timer_queue::release() {
	if(asAtomicDec(RefCount)<1) {
		reset();
		delete this;
	}
}
void timer_queue::reset() {
	for(auto it=timer_objects.begin(); it!=timer_objects.end(); it++) {
		if(it->second->callback) it->second->callback->Release();
		if(it->second->is_scheduled)
			it->second->cancel();
		delete it->second;
	}
	timer_objects.clear();
	for(auto i : deleting_timers) {
		if(i->callback) i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
}
void timer_queue::set(const std::string& id, asIScriptFunction* callback, const std::string& callback_data, uint64_t timeout, bool repeating) {
	auto it=timer_objects.find(id);
	if(it!=timer_objects.end()) {
		if(it->second->callback) it->second->callback->Release();
		it->second->callback=callback;
		it->second->callback_data=callback_data;
		it->second->timeout=timeout;
		it->second->repeating=repeating;
		it->second->is_scheduled=true;
		it->second->cancel();
		timers.schedule(it->second, timeout);
		return;
	}
	timer_objects[id]=new timer_queue_item(this, id, callback, callback_data, timeout, repeating);
	timers.schedule(timer_objects[id], timeout);
}
uint64_t timer_queue::elapsed(const std::string& id) {
	auto it=timer_objects.find(id);
	if(it==timer_objects.end()) return 0;
	return it->second->scheduled_at()-timers.now();
}
uint64_t timer_queue::timeout(const std::string& id) {
	auto it=timer_objects.find(id);
	if(it==timer_objects.end()) return 0;
	return it->second->timeout;
}
bool timer_queue::restart(const std::string& id) {
	auto it=timer_objects.find(id);
	if(it==timer_objects.end()) return false;
	it->second->is_scheduled=true;
	it->second->cancel();
	timers.schedule(it->second, it->second->timeout);
	return true;
}
bool timer_queue::is_repeating(const std::string& id) {
	auto it=timer_objects.find(id);
	if(it==timer_objects.end()) return false;
	return it->second->repeating;
}
bool timer_queue::set_timeout(const std::string& id, uint64_t timeout, bool repeating) {
	auto it=timer_objects.find(id);
	if(it==timer_objects.end()) return false;
	it->second->timeout=timeout;
	it->second->repeating=repeating;
	if(timeout>0||repeating) {
		it->second->is_scheduled=true;
		timers.schedule(it->second, timeout);
	}
	return true;
}
bool timer_queue::erase(const std::string& id) {
	auto it=timer_objects.find(id);
	if(it==timer_objects.end()) return false;
	it->second->cancel();
	deleting_timers.insert(it->second);
	timer_objects.erase(it);
	return true;
}
void timer_queue::flush() {
	for(auto i : deleting_timers) {
		if(i->callback) i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
	last_looped=ticks();
}
bool timer_queue::loop(int max_timers, int max_catchup) {
	for(auto i : deleting_timers) {
		if(i->callback) i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
	uint64_t t=!open_tick? ticks()-last_looped : 0;
	if(t>max_catchup) t=max_catchup;
	if(!open_tick&&t<=0) return true;
	open_tick=!(max_timers>0? timers.advance(t, max_timers) : timers.advance(t));
	if(!open_tick) last_looped+=t;
	return !open_tick;
}
timer_queue* new_timer_queue() {
	return new timer_queue();
}

static tm tm_cache;
time_t time_cache;
const char* daynames[]= {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", NULL};
const char* monthnames[]= {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", NULL};

void update_tm() {
	time_t t=time(0);
	if(t==time_cache)
		return;
	time_cache=t;
	tm* new_tm=localtime(&t);
	if(!new_tm)
		return;
	memcpy(&tm_cache, new_tm, sizeof(tm));
}

int get_date_year() {
	update_tm();
	return tm_cache.tm_year+1900;
}
int get_date_month() {
	update_tm();
	return tm_cache.tm_mon+1;
}
std::string get_date_month_name() {
	update_tm();
	return monthnames[tm_cache.tm_mon];
}
int get_date_day() {
	update_tm();
	return tm_cache.tm_mday;
}
int get_date_weekday() {
	update_tm();
	return tm_cache.tm_wday+1;
}
std::string get_date_weekday_name() {
	update_tm();
	return daynames[tm_cache.tm_wday];
}
int get_time_hour() {
	update_tm();
	return tm_cache.tm_hour;
}
int get_time_minute() {
	update_tm();
	return tm_cache.tm_min;
}
int get_time_second() {
	update_tm();
	return tm_cache.tm_sec;
}

bool speedhack_protection=true;
asINT64 secure_ticks() {
	#ifdef _WIN32
	FILETIME ft_now;
	GetSystemTimeAsFileTime(&ft_now);
	ULARGE_INTEGER ft_calc;
	ft_calc.LowPart=ft_now.dwLowDateTime;
	ft_calc.HighPart=ft_now.dwHighDateTime;
	ft_calc.QuadPart-=g_ftclock.QuadPart;
	ft_calc.QuadPart/=10000;
	return ft_calc.QuadPart;
	#else
	return ticks(true);
	#endif
}
asINT64 ticks(bool unsecure) {
	if(!speedhack_protection||unsecure) {
		auto t=std::chrono::high_resolution_clock::now();
		return std::chrono::duration_cast<std::chrono::milliseconds>(t-g_clock).count();
	} else {
		return secure_ticks();
	}
}
asINT64 system_running_milliseconds() {
	#ifdef _WIN32
	return GetTickCount64();
	#else
	FILE* f=fopen("/proc/uptime", "r");
	char tmp[40];
	if(!fgets(tmp, 40, f))
		return 0;
	char* space=strchr(tmp, ' ');
	if(space) *space='\0';
	return strtof(tmp, NULL)*1000;
	#endif
}

int get_timezone_offset() {
	#ifdef _WIN32
	TIME_ZONE_INFORMATION tzi;
	GetTimeZoneInformation(&tzi);
	return tzi.Bias;
	#else
	std::time_t current_time;
	std::time(&current_time);
	struct std::tm *timeinfo = std::localtime(&current_time);
	return timeinfo->tm_gmtoff;
	#endif
}

void RegisterScriptTimestuff(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATETIME);
	engine->RegisterGlobalFunction("int get_DATE_YEAR() property", asFUNCTION(get_date_year), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_DATE_MONTH() property", asFUNCTION(get_date_month), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_DATE_MONTH_NAME() property", asFUNCTION(get_date_month_name), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_DATE_DAY() property", asFUNCTION(get_date_day), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_DATE_WEEKDAY() property", asFUNCTION(get_date_weekday), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_DATE_WEEKDAY_NAME() property", asFUNCTION(get_date_weekday_name), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_TIME_HOUR() property", asFUNCTION(get_time_hour), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_TIME_MINUTE() property", asFUNCTION(get_time_minute), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_TIME_SECOND() property", asFUNCTION(get_time_second), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 ticks(bool = false)"), asFUNCTION(ticks), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 secure_ticks()"), asFUNCTION(secure_ticks), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_OS);
	engine->RegisterGlobalFunction(_O("uint64 get_TIME_SYSTEM_RUNNING_MILLISECONDS() property"), asFUNCTION(system_running_milliseconds), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_TIMEZONE_BASE_OFFSET() property", asFUNCTION(Poco::Timezone::utcOffset), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_TIMEZONE_DST_OFFSET() property", asFUNCTIONPR(Poco::Timezone::dst, (), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int get_TIMEZONE_OFFSET() property", asFUNCTION(Poco::Timezone::tzd), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_TIMEZONE_NAME() property", asFUNCTION(Poco::Timezone::name), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_TIMEZONE_STANDARD_NAME() property", asFUNCTION(Poco::Timezone::standardName), asCALL_CDECL);
	engine->RegisterGlobalFunction("string get_TIMEZONE_DST_NAME() property", asFUNCTION(Poco::Timezone::dstName), asCALL_CDECL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_UNCLASSIFIED);
	engine->RegisterGlobalProperty(_O("bool speedhack_protection"), &speedhack_protection);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_TMRQ);
	engine->RegisterObjectType(_O("timer_queue"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("timer_queue"), asBEHAVE_FACTORY, _O("timer_queue @q()"), asFUNCTION(new_timer_queue), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer_queue"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(timer_queue, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("timer_queue"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(timer_queue, release), asCALL_THISCALL);
	engine->RegisterFuncdef(_O("uint timer_callback(string, string)"));
	engine->RegisterObjectProperty(_O("timer_queue"), _O("const string failures"), asOFFSET(timer_queue, failures));
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void set(const string&in, timer_callback@, const string&in, uint64, bool = false)"), asMETHOD(timer_queue, set), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void set(const string&in, timer_callback@, uint64, bool = false)"), asMETHOD(timer_queue, set_dataless), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint64 elapsed(const string&in)"), asMETHOD(timer_queue, elapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint64 timeout(const string&in)"), asMETHOD(timer_queue, timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool exists(const string&in)"), asMETHOD(timer_queue, exists), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool restart(const string&in)"), asMETHOD(timer_queue, restart), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool is_repeating(const string&in)"), asMETHOD(timer_queue, is_repeating), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool set_timeout(const string&in, uint64, bool = false)"), asMETHOD(timer_queue, set_timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool delete(const string&in)"), asMETHOD(timer_queue, erase), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void flush()"), asMETHOD(timer_queue, flush), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void reset()"), asMETHOD(timer_queue, reset), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint size() const"), asMETHOD(timer_queue, size), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool loop(int = 0, int = 100)"), asMETHOD(timer_queue, loop), asCALL_THISCALL);
}
