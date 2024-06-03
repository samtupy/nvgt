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
#include <cstring>
#include <ctime>
#include <string>
#include <chrono>
#include <obfuscate.h>
#include <fstream>
#include <iostream>
#include <Poco/Clock.h>
#include <Poco/DateTime.h>
#include <Poco/DateTimeFormat.h>
#include <Poco/DateTimeFormatter.h>
#include <Poco/LocalDateTime.h>
#include <Poco/Mutex.h>
#include <Poco/Timestamp.h>
#include <Poco/Timezone.h>
#include "nvgt.h"
#include "scriptstuff.h"

using namespace Poco;

Poco::Clock g_clock;
Poco::Timestamp g_secure_clock;
Poco::Timestamp g_time_cache;
Poco::DateTime g_time_values;
Poco::FastMutex g_time_mutex;

static asIScriptContext* callback_ctx = NULL;
timer_queue_item::timer_queue_item(timer_queue* parent, const std::string& id, asIScriptFunction* callback, const std::string& callback_data, int timeout, bool repeating) : parent(parent), id(id), callback(callback), callback_data(callback_data), timeout(timeout), repeating(repeating), is_scheduled(true) {
}
void timer_queue_item::execute() {
	is_scheduled = false;
	asIScriptContext* ACtx = asGetActiveContext();
	bool new_context = ACtx == NULL || ACtx->PushState() < 0;
	asIScriptContext* ctx = (new_context ? g_ScriptEngine->RequestContext() : ACtx);
	if (!ctx) {
		parent->failures += id;
		parent->failures += "; can't get context.\r\n";
		parent->failures += get_call_stack();
		parent->erase(id);
		return;
	}
	int rp = 0;
	if ((rp = ctx->Prepare(callback)) < 0) {
		char tmp[200];
		snprintf(tmp, 200, "%s; can't prepare; %d\r\n", id.c_str(), rp);
		parent->failures += tmp;
		parent->failures += get_call_stack();
		parent->erase(id);
		if (new_context) g_ScriptEngine->ReturnContext(ctx);
		else ctx->PopState();
		return;
	}
	ctx->SetArgObject(0, &id);
	ctx->SetArgObject(1, &callback_data);
	int xr = ctx->Execute();
	int ms = 0;
	if (xr == asEXECUTION_FINISHED)
		ms = ctx->GetReturnDWord();
	else if (!is_scheduled || xr == asEXECUTION_EXCEPTION)
		repeating = false;
	if (repeating && ms < 1) ms = timeout;
	if (new_context) g_ScriptEngine->ReturnContext(ctx);
	else ctx->PopState();
	if (!is_scheduled) {
		if (ms > 0) {
			parent->schedule(this, ms);
			is_scheduled = true;
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
	if (asAtomicDec(RefCount) < 1) {
		reset();
		delete this;
	}
}
void timer_queue::reset() {
	for (auto it = timer_objects.begin(); it != timer_objects.end(); it++) {
		if (it->second->callback) it->second->callback->Release();
		if (it->second->is_scheduled)
			it->second->cancel();
		delete it->second;
	}
	timer_objects.clear();
	for (auto i : deleting_timers) {
		if (i->callback) i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
}
void timer_queue::set(const std::string& id, asIScriptFunction* callback, const std::string& callback_data, uint64_t timeout, bool repeating) {
	auto it = timer_objects.find(id);
	if (it != timer_objects.end()) {
		if (it->second->callback) it->second->callback->Release();
		it->second->callback = callback;
		it->second->callback_data = callback_data;
		it->second->timeout = timeout;
		it->second->repeating = repeating;
		it->second->is_scheduled = true;
		it->second->cancel();
		timers.schedule(it->second, timeout);
		return;
	}
	timer_objects[id] = new timer_queue_item(this, id, callback, callback_data, timeout, repeating);
	timers.schedule(timer_objects[id], timeout);
}
uint64_t timer_queue::elapsed(const std::string& id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end()) return 0;
	return it->second->scheduled_at() - timers.now();
}
uint64_t timer_queue::timeout(const std::string& id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end()) return 0;
	return it->second->timeout;
}
bool timer_queue::restart(const std::string& id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end()) return false;
	it->second->is_scheduled = true;
	it->second->cancel();
	timers.schedule(it->second, it->second->timeout);
	return true;
}
bool timer_queue::is_repeating(const std::string& id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end()) return false;
	return it->second->repeating;
}
bool timer_queue::set_timeout(const std::string& id, uint64_t timeout, bool repeating) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end()) return false;
	it->second->timeout = timeout;
	it->second->repeating = repeating;
	if (timeout > 0 || repeating) {
		it->second->is_scheduled = true;
		timers.schedule(it->second, timeout);
	}
	return true;
}
bool timer_queue::erase(const std::string& id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end()) return false;
	it->second->cancel();
	deleting_timers.insert(it->second);
	timer_objects.erase(it);
	return true;
}
void timer_queue::flush() {
	for (auto i : deleting_timers) {
		if (i->callback) i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
	last_looped = ticks();
}
bool timer_queue::loop(int max_timers, int max_catchup) {
	for (auto i : deleting_timers) {
		if (i->callback) i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
	uint64_t t = !open_tick ? ticks() - last_looped : 0;
	if (t > max_catchup) t = max_catchup;
	if (!open_tick && t <= 0) return true;
	open_tick = !(max_timers > 0 ? timers.advance(t, max_timers) : timers.advance(t));
	if (!open_tick) last_looped += t;
	return !open_tick;
}

void update_tm() {
	Timestamp ts;
	if (ts.epochTime() == g_time_cache.epochTime()) return;
	FastMutex::ScopedLock l(g_time_mutex);
	g_time_cache = ts;
	g_time_values = ts;
	g_time_values.makeLocal(Poco::Timezone::tzd());
}

int get_date_year() {
	update_tm();
	return g_time_values.year();
}
int get_date_month() {
	update_tm();
	return g_time_values.month();
}
std::string get_date_month_name() {
	update_tm();
	return DateTimeFormat::MONTH_NAMES[g_time_values.month() - 1];
}
int get_date_day() {
	update_tm();
	return g_time_values.day();
}
int get_date_weekday() {
	update_tm();
	return g_time_values.dayOfWeek() + 1;
}
std::string get_date_weekday_name() {
	update_tm();
	return DateTimeFormat::WEEKDAY_NAMES[g_time_values.dayOfWeek()];
}
int get_time_hour() {
	update_tm();
	return g_time_values.hour();
}
int get_time_minute() {
	update_tm();
	return g_time_values.minute();
}
int get_time_second() {
	update_tm();
	return g_time_values.second();
}

bool speedhack_protection = true;
uint64_t secure_ticks() {
	return g_secure_clock.elapsed() / Timespan::MILLISECONDS;
}
uint64_t ticks(bool secure) {
	return (!secure ? g_clock.elapsed() : g_secure_clock.elapsed()) / Timespan::MILLISECONDS;
}
uint64_t microticks(bool secure) {
	return !secure ? g_clock.elapsed() : g_secure_clock.elapsed();
}

// Replace the following function with something from an external library or something as soon as we find it.
#ifdef _WIN32
	#include <windows.h>
#endif
asINT64 system_running_milliseconds() {
	#ifdef _WIN32
	return GetTickCount64();
	#else
	FILE* f = fopen("/proc/uptime", "r");
	char tmp[40];
	if (!fgets(tmp, 40, f))
		return 0;
	char* space = strchr(tmp, ' ');
	if (space) *space = '\0';
	return strtof(tmp, NULL) * 1000;
	#endif
}

// timer class
uint64_t timer_default_accuracy = Timespan::MILLISECONDS;
timer::timer() : value(microticks()), accuracy(timer_default_accuracy), paused(false), secure(speedhack_protection) {}
timer::timer(bool secure) : value(microticks(secure)), accuracy(timer_default_accuracy), paused(false), secure(secure) {}
timer::timer(int64_t initial_value, bool secure) : value(microticks(secure) + initial_value * timer_default_accuracy), accuracy(timer_default_accuracy), paused(false), secure(secure) {}
timer::timer(int64_t initial_value, uint64_t initial_accuracy, bool secure) : value(microticks(secure) + initial_value * initial_accuracy), accuracy(initial_accuracy), paused(false), secure(secure) {}
int64_t timer::get_elapsed() const { return (paused ? value : microticks(secure) - value) / accuracy; }
bool timer::has_elapsed(int64_t value) const { return get_elapsed() >= value; }
void timer::force(int64_t new_value) { paused ? value = new_value * accuracy : value = microticks(secure) - new_value * accuracy; }
void timer::adjust(int64_t new_value) { paused ? value += new_value * accuracy : value -= new_value * accuracy; }
void timer::restart() { value = microticks(secure); paused = false; }
bool timer::get_secure() const { return secure; }
bool timer::get_paused() const { return paused; }
bool timer::get_running() const { return !paused; }
bool timer::pause() { return paused ? false : set_paused(true); }
bool timer::resume() { return !paused ? false : set_paused(false); }
void timer::toggle_pause() { value = microticks(secure) - value; paused = !paused; }
bool timer::set_paused(bool new_paused) {
	if (paused == new_paused) return false;
	value = microticks(secure) - value;
	paused = new_paused;
	return true;
}
bool timer::set_secure(bool new_secure) {
	if (secure == new_secure) return false;
	bool is_paused = paused;
	if (!is_paused) pause();
	secure = new_secure;
	if (!is_paused) resume();
	return true;
}

// Angelscript factories.
template <class T, typename... A> void timestuff_construct(void* mem, A... args) { new (mem) T(args...); }
template <class T> void timestuff_destruct(T* obj) { obj->~T(); }
template <class T, typename... A> void* timestuff_factory(A... args) { return new T(args...); }

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
	engine->RegisterGlobalFunction(_O("uint64 microticks(bool = false)"), asFUNCTION(microticks), asCALL_CDECL);
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
	engine->RegisterObjectBehaviour(_O("timer_queue"), asBEHAVE_FACTORY, _O("timer_queue @q()"), asFUNCTION(timestuff_factory<timer_queue>), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer_queue"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(timer_queue, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("timer_queue"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(timer_queue, release), asCALL_THISCALL);
	engine->RegisterFuncdef(_O("uint timer_callback(string, string)"));
	engine->RegisterObjectProperty(_O("timer_queue"), _O("const string failures"), asOFFSET(timer_queue, failures));
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void set(const string&in, timer_callback@, const string&in, uint64, bool = false)"), asMETHOD(timer_queue, set), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void set(const string&in, timer_callback@, uint64, bool = false)"), asMETHOD(timer_queue, set_dataless), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint64 elapsed(const string&in) const"), asMETHOD(timer_queue, elapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint64 timeout(const string&in) const"), asMETHOD(timer_queue, timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool exists(const string&in) const"), asMETHOD(timer_queue, exists), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool restart(const string&in)"), asMETHOD(timer_queue, restart), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool is_repeating(const string&in) const"), asMETHOD(timer_queue, is_repeating), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool set_timeout(const string&in, uint64, bool = false)"), asMETHOD(timer_queue, set_timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool delete(const string&in)"), asMETHOD(timer_queue, erase), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void flush()"), asMETHOD(timer_queue, flush), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void reset()"), asMETHOD(timer_queue, reset), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint size() const"), asMETHOD(timer_queue, size), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool loop(int = 0, int = 100)"), asMETHOD(timer_queue, loop), asCALL_THISCALL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATETIME);
	engine->RegisterObjectType(_O("timer"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_FACTORY, _O("timer@ t()"), asFUNCTION(timestuff_factory<timer>), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_FACTORY, _O("timer@ t(bool)"), asFUNCTION((timestuff_factory<timer, bool>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_FACTORY, _O("timer@ t(int64, bool = speedhack_protection)"), asFUNCTION((timestuff_factory<timer, int64_t, bool>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_FACTORY, _O("timer@ t(int64, uint64, bool = speedhack_protection)"), asFUNCTION((timestuff_factory<timer, int64_t, uint64_t, bool>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(timer, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(timer, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("int64 get_elapsed() const property"), asMETHOD(timer, get_elapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void set_elapsed(int64) property"), asMETHOD(timer, force), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool has_elapsed(int64) const"), asMETHOD(timer, has_elapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void force(int64)"), asMETHOD(timer, force), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void adjust(int64)"), asMETHOD(timer, adjust), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void restart()"), asMETHOD(timer, restart), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool get_secure() const property"), asMETHOD(timer, get_secure), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void set_secure(bool) property"), asMETHOD(timer, set_secure), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool get_paused() const property"), asMETHOD(timer, get_paused), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool get_running() const property"), asMETHOD(timer, get_running), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void toggle_pause()"), asMETHOD(timer, toggle_pause), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool pause()"), asMETHOD(timer, pause), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool resume()"), asMETHOD(timer, resume), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool set_paused(bool)"), asMETHOD(timer, set_paused), asCALL_THISCALL);
	engine->RegisterObjectProperty(_O("timer"), _O("uint64 accuracy"), asOFFSET(timer, accuracy));
	engine->RegisterGlobalProperty(_O("const int64 MILLISECONDS"), (void*)&Timespan::MILLISECONDS);
	engine->RegisterGlobalProperty(_O("const int64 SECONDS"), (void*)&Timespan::SECONDS);
	engine->RegisterGlobalProperty(_O("const int64 MINUTES"), (void*)&Timespan::MINUTES);
	engine->RegisterGlobalProperty(_O("const int64 HOURS"), (void*)&Timespan::HOURS);
	engine->RegisterGlobalProperty(_O("const int64 DAYS"), (void*)&Timespan::DAYS);
	engine->RegisterGlobalProperty(_O("uint64 timer_default_accuracy"), &timer_default_accuracy);
}
