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
#include <Poco/DateTimeParser.h>
#include <Poco/LocalDateTime.h>
#include <Poco/Mutex.h>
#include <Poco/Timestamp.h>
#include <Poco/Timezone.h>
#include <SDL3/SDL.h>
#include <scriptarray.h>
#include "nvgt.h"
#include "pocostuff.h" // angelscript_refcounted
#include "scriptstuff.h"

using namespace Poco;

Poco::Clock g_clock;
Poco::Timestamp g_secure_clock;
Poco::Timestamp g_time_cache;
Poco::DateTime g_time_values;
Poco::FastMutex g_time_mutex;

static asIScriptContext *callback_ctx = NULL;
timer_queue_item::timer_queue_item(timer_queue *parent, const std::string &id, asIScriptFunction *callback, const std::string &callback_data, int timeout, bool repeating) : parent(parent), id(id), callback(callback), callback_data(callback_data), timeout(timeout), repeating(repeating), is_scheduled(true) {
}
void timer_queue_item::execute() {
	is_scheduled = false;
	asIScriptContext *ACtx = asGetActiveContext();
	bool new_context = ACtx == NULL || ACtx->PushState() < 0;
	asIScriptContext *ctx = (new_context ? g_ScriptEngine->RequestContext() : ACtx);
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
		if (new_context)
			g_ScriptEngine->ReturnContext(ctx);
		else
			ctx->PopState();
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
	if (repeating && ms < 1)
		ms = timeout;
	if (new_context)
		g_ScriptEngine->ReturnContext(ctx);
	else
		ctx->PopState();
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
		if (it->second->callback)
			it->second->callback->Release();
		if (it->second->is_scheduled)
			it->second->cancel();
		delete it->second;
	}
	timer_objects.clear();
	for (auto i : deleting_timers) {
		if (i->callback)
			i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
}
void timer_queue::set(const std::string &id, asIScriptFunction *callback, const std::string &callback_data, uint64_t timeout, bool repeating) {
	auto it = timer_objects.find(id);
	if (it != timer_objects.end()) {
		if (it->second->callback)
			it->second->callback->Release();
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
uint64_t timer_queue::elapsed(const std::string &id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end())
		return 0;
	return it->second->scheduled_at() - timers.now();
}
uint64_t timer_queue::timeout(const std::string &id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end())
		return 0;
	return it->second->timeout;
}
bool timer_queue::restart(const std::string &id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end())
		return false;
	it->second->is_scheduled = true;
	it->second->cancel();
	timers.schedule(it->second, it->second->timeout);
	return true;
}
bool timer_queue::is_repeating(const std::string &id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end())
		return false;
	return it->second->repeating;
}
bool timer_queue::set_timeout(const std::string &id, uint64_t timeout, bool repeating) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end())
		return false;
	it->second->timeout = timeout;
	it->second->repeating = repeating;
	if (timeout > 0 || repeating) {
		it->second->is_scheduled = true;
		timers.schedule(it->second, timeout);
	}
	return true;
}
bool timer_queue::erase(const std::string &id) {
	auto it = timer_objects.find(id);
	if (it == timer_objects.end())
		return false;
	it->second->cancel();
	deleting_timers.insert(it->second);
	timer_objects.erase(it);
	return true;
}
void timer_queue::flush() {
	for (auto i : deleting_timers) {
		if (i->callback)
			i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
	last_looped = ticks();
}
bool timer_queue::loop(int max_timers, int max_catchup) {
	for (auto i : deleting_timers) {
		if (i->callback)
			i->callback->Release();
		delete i;
	}
	deleting_timers.clear();
	uint64_t t = !open_tick ? ticks() - last_looped : 0;
	if (t > max_catchup)
		t = max_catchup;
	if (!open_tick && t <= 0)
		return true;
	open_tick = !(max_timers > 0 ? timers.advance(t, max_timers) : timers.advance(t));
	if (!open_tick)
		last_looped += t;
	return !open_tick;
}

void update_tm() {
	Timestamp ts;
	if (ts.epochTime() == g_time_cache.epochTime())
		return;
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
	FILE *f = fopen("/proc/uptime", "r");
	char tmp[40];
	if (!fgets(tmp, 40, f))
		return 0;
	char *space = strchr(tmp, ' ');
	if (space)
		*space = '\0';
	return strtof(tmp, NULL) * 1000;
	#endif
}

// timer class
uint64_t timer_default_accuracy = Timespan::MILLISECONDS;
uint64_t TIMESPAN_MICROSECONDS = 1; // This so that all timer accuracies can have a constant named after them, Poco starts these at milliseconds.
timer::timer() : value(microticks()), accuracy(timer_default_accuracy), paused(false), secure(speedhack_protection) {}
timer::timer(bool secure) : value(microticks(secure)), accuracy(timer_default_accuracy), paused(false), secure(secure) {}
timer::timer(int64_t initial_value, bool secure) : value(int64_t(microticks(secure)) - initial_value * timer_default_accuracy), accuracy(timer_default_accuracy), paused(false), secure(secure) {}
timer::timer(int64_t initial_value, uint64_t initial_accuracy, bool secure) : value(int64_t(microticks(secure)) - initial_value * initial_accuracy), accuracy(initial_accuracy), paused(false), secure(secure) {}
int64_t timer::get_elapsed() const { return int64_t(paused ? value : microticks(secure) - value) / int64_t(accuracy); }
bool timer::has_elapsed(int64_t value) const { return get_elapsed() >= value; }
void timer::force(int64_t new_value) { paused ? value = new_value * accuracy : value = microticks(secure) - new_value * accuracy; }
void timer::adjust(int64_t new_value) { paused ? value += new_value * accuracy : value -= new_value * accuracy; }
void timer::restart() {
	value = int64_t(microticks(secure));
	paused = false;
}
bool timer::get_secure() const { return secure; }
bool timer::get_paused() const { return paused; }
bool timer::get_running() const { return !paused; }
bool timer::pause() { return paused ? false : set_paused(true); }
bool timer::resume() { return !paused ? false : set_paused(false); }
void timer::toggle_pause() {
	value = microticks(secure) - value;
	paused = !paused;
}
bool timer::tick(int64_t value) {
	if (!has_elapsed(value))
		return false;
	restart();
	return true;
}
bool timer::set_paused(bool new_paused) {
	if (paused == new_paused)
		return false;
	value = int64_t(microticks(secure)) - value;
	paused = new_paused;
	return true;
}
bool timer::set_secure(bool new_secure) {
	if (secure == new_secure)
		return false;
	bool is_paused = paused;
	if (!is_paused)
		pause();
	secure = new_secure;
	if (!is_paused)
		resume();
	return true;
}

// Angelscript factories.
template <class T, typename... A> void timestuff_construct(void *mem, A... args) { new (mem) T(args...); }
template <class T>
void timestuff_copy_construct(void *mem, const T &obj) { new (mem) T(obj); }
template <class T>
void timestuff_destruct(T *obj) { obj->~T(); }
template <class T, typename... A>
void *timestuff_factory(A... args) { return new T(args...); }
template <class T, typename O>
int timestuff_opCmp(T *self, O other) {
	if (*self < other)
		return -1;
	else if (*self > other)
		return 1;
	else
		return 0;
}
// Assigns one of the datetime types to a new version of itself E. the current date and time.
template <class T>
void timestuff_reset(T *obj) { (*obj) = T(); }
/**
 * Additional calendar methods and properties for BGT compatibility.
 * This portion contributed by Caturria, Mar 10, 2025.
 */
/**
 * Makes sure the values stored within a LocalDateTime or DateTime object are valid, and raises a script exception if not.
 */
template <class t> bool verify_date_time(t &dt) {
	if (!DateTime::isValid(dt.year(), dt.month(), dt.day(), dt.hour(), dt.minute(), dt.second(), dt.millisecond(), dt.microsecond())) {
		asGetActiveContext()->SetException("Invalid date/time.");
		return false;
	}
	return true;
}
std::string get_month_name(LocalDateTime &dt) {
	if (verify_date_time(dt))
		return DateTimeFormat::MONTH_NAMES[dt.month() - 1];
	return "";
}
std::string get_weekday_name(LocalDateTime &dt) {
	if (verify_date_time(dt))
		return DateTimeFormat::WEEKDAY_NAMES[dt.dayOfWeek()];
	return "";
}
/**
 * Either adds or subtracts a timespan from either a LocalDateTime or a DateTime.
 * Always returns boolean true.
 */
template <class t> bool add_timespan(t &dt, Timespan &timespan, bool negative) {
	if (negative)
		dt -= timespan;
	else
		dt += timespan;
	return true;
}

/**
 * Convenience methods for adding days, hours, minutes and seconds to a datetime or calendar.
 */
#define make_add_units(x, a, b, c, d, e) \
	template <class t> \
	bool add_##x(t &dt, asINT32 amount) \
	{ \
		if (amount == 0) \
		{ \
			return false; \
		} \
		Timespan timespan(a, b, c, d, e); \
		return add_timespan(dt, timespan, amount < 0); \
	}
make_add_units(days, abs(amount), 0, 0, 0, 0)
make_add_units(hours, 0, abs(amount), 0, 0, 0)
make_add_units(minutes, 0, 0, abs(amount), 0, 0)
make_add_units(seconds, 0, 0, 0, abs(amount), 0)

template <class t> bool add_years(t &dt, asINT32 amount) {
	if (amount == 0)
		return false;
	dt.assign(dt.year() + amount, dt.month(), dt.day(), dt.hour(), dt.minute(), dt.second(), dt.microsecond());
	return true;
}
template <class t> bool add_months(t &dt, asINT32 amount) {
	if (amount == 0)
		return false;
	asINT32 monthToAssign = dt.month() + amount;
	asINT32 yearsToAdd = 0;
	if (monthToAssign > 12) {
		yearsToAdd = (monthToAssign - 1) / 12;
		monthToAssign -= (yearsToAdd * 12);
	} else if (monthToAssign <= 0) {
		yearsToAdd = (int64_t)ceil(abs(monthToAssign) / 12.0f) * -1;
		monthToAssign = (abs(yearsToAdd) * 12) - abs(monthToAssign);
		if (monthToAssign == 0) {
			monthToAssign = 12;
			yearsToAdd -= 1;
		}
	}
	asINT32 yearToAssign = dt.year() + yearsToAdd;
	dt.assign(dt.year() + yearsToAdd, monthToAssign, min(dt.day(), DateTime::daysOfMonth(yearToAssign, monthToAssign)), dt.hour(), dt.minute(), dt.second(), dt.microsecond());
	return true;
}
/**
 * Computes the difference between two dates either in years, months, days, hours, minutes or seconds.
 * These also match BGT's calendar API.
 */
template <class t> Timespan make_diff_timespan(t &first, t &second) {
	if (!verify_date_time(first) || !verify_date_time(second)) {
		return Timespan(); // Script will crash anyway.
	}
	return Timespan(abs(first.utcTime() - second.utcTime()));
}
template <class t> asQWORD diff_days(t &first, t &second) {
	return make_diff_timespan(first, second).days() / 10; // Poco timestamps give these values to you multiplied by a factor of 10; why not float or double? Weird.
}
template <class t> asQWORD diff_hours(t &first, t &second) {
	return make_diff_timespan(first, second).totalHours() / 10;
}
template <class t> asQWORD diff_minutes(t &first, t &second) {
	return make_diff_timespan(first, second).totalMinutes() / 10;
}
template <class t> asQWORD diff_seconds(t &first, t &second) {
	return make_diff_timespan(first, second).totalSeconds() / 10;
}
/**
 * Computes the total duration of the current year as represented by the given object.
 * Used internally by diff_years.
 */
template <class t> Timespan::TimeDiff get_duration_of_year(t &dt) {
	return t(dt.year() + 1, 1, 1).utcTime() - t(dt.year(), 1, 1).utcTime();
}
/**
 * Computes the amount of time that has elapsed since the start of the year as represented by the given object.
 * Used internally for diff_years.
 */
template <class t> double time_since_year_start(t &dt) {
	return (dt.utcTime() - t(dt.year(), 1, 1).utcTime()) / (double)get_duration_of_year(dt);
}
template <class t> double diff_years(t &first, t &second) {
	t *high, *low;
	if (first.utcTime() > second.utcTime()) {
		high = &first;
		low = &second;
	} else {
		high = &second;
		low = &first;
	}
	asINT64 years = high->year() - low->year();
	double delta = time_since_year_start(*low) - time_since_year_start(*high);
	if (years > 0 && delta > 0)
		years -= 1;
	return years + abs(delta);
}
/**
 * Computes the span of time that has elapsed since midnight on the current day as represented by the given object.
 */
template <class t> Timespan::TimeDiff time_since_midnight(t &dt) {
	return dt.utcTime() - t(dt.year(), dt.month(), dt.day()).utcTime();
}
template <class t> bool is_further_into_month(t &high, t &low) {
	if (high.day() > low.day())
		return false;
	if (high.day() < low.day())
		return true;
	// They're same day, so just check which one is a later time.
	return time_since_midnight(high) < time_since_midnight(low);
}
/**
 * Computes the difference between two dates in months.
 */
template <class t> asQWORD diff_months(t &first, t &second) {
	t *high, *low;
	if (first.utcTime() > second.utcTime()) {
		high = &first;
		low = &second;
	} else {
		high = &second;
		low = &first;
	}
	asQWORD months = 0;
	if (high->year() != low->year())
		months = (asQWORD)diff_years(*high, *low) * 12;
	if (low->month() > high->month() && low->year() < high->year())
		months += (12 - abs(low->month() - high->month()));
	else
		months += abs(high->month() - low->month());
	if (is_further_into_month(*high, *low))
		months--;
	return months;
}
/**
 * Checks if the date held within the object is valid.
 */
template <class t> bool is_valid(t &dt) {
	return DateTime::isValid(dt.year(), dt.month(), dt.day(), dt.hour(), dt.minute(), dt.second(), dt.millisecond(), dt.microsecond());
}
/**
 * Checks if the current year of the object is a leap year.
 */
template <class t> bool is_leap_year(t &dt) {
	return DateTime::isLeapYear(dt.year());
}
/**
 * Registers the above extensions with Angelscript.
 */
#define register_add_units(x) engine->RegisterObjectMethod(classname.c_str(), "bool add_" #x "(int32 amount)", asFUNCTION(add_##x<t>), asCALL_CDECL_OBJFIRST);
#define register_diff_units(r, x) engine->RegisterObjectMethod(classname.c_str(), format(#r " diff_" #x "(%s@ other)", classname).c_str(), asFUNCTION(diff_##x<t>), asCALL_CDECL_OBJFIRST);

template <class t> void register_date_time_extensions(asIScriptEngine *engine, std::string classname) {
	engine->RegisterObjectMethod(classname.c_str(), "string get_month_name() const property", asFUNCTION(get_month_name), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(classname.c_str(), "string get_weekday_name() const property", asFUNCTION(get_weekday_name), asCALL_CDECL_OBJFIRST);
	register_add_units(days);
	register_add_units(hours);
	register_add_units(minutes);
	register_add_units(seconds);
	register_add_units(months);
	register_add_units(years);
	register_diff_units(uint64, days);
	register_diff_units(uint64, hours);
	register_diff_units(uint64, minutes);
	register_diff_units(uint64, seconds);
	register_diff_units(double, years);
	register_diff_units(uint64, months);
	engine->RegisterObjectMethod(classname.c_str(), "bool get_valid() const property", asFUNCTION(is_valid<t>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(classname.c_str(), "bool get_leap_year()", asFUNCTION(is_leap_year<t>), asCALL_CDECL_OBJFIRST);
}
void RegisterScriptTimestuff(asIScriptEngine *engine) {
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
	engine->RegisterGlobalFunction(_O("uint64 ticks(bool secure = false)"), asFUNCTION(ticks), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 secure_ticks()"), asFUNCTION(secure_ticks), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 microticks(bool secure = false)"), asFUNCTION(microticks), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 nanoticks()"), asFUNCTION(SDL_GetTicksNS), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 get_SYSTEM_PERFORMANCE_COUNTER() property"), asFUNCTION(SDL_GetPerformanceCounter), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("uint64 get_SYSTEM_PERFORMANCE_FREQUENCY() property"), asFUNCTION(SDL_GetPerformanceFrequency), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void nanosleep(uint64 ns)"), asFUNCTION(SDL_DelayNS), asCALL_CDECL);
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
	engine->RegisterFuncdef(_O("uint timer_callback(string timer_id, string user_data)"));
	engine->RegisterObjectProperty(_O("timer_queue"), _O("const string failures"), asOFFSET(timer_queue, failures));
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void set(const string&in timer_id, timer_callback@ callback, const string&in callback_data, uint64 milliseconds, bool repeating = false)"), asMETHOD(timer_queue, set), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void set(const string&in timer_id, timer_callback@ callback, uint64 milliseconds, bool repeating = false)"), asMETHOD(timer_queue, set_dataless), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint64 elapsed(const string&in timer_id) const"), asMETHOD(timer_queue, elapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint64 timeout(const string&in timer_id) const"), asMETHOD(timer_queue, timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool exists(const string&in timer_id) const"), asMETHOD(timer_queue, exists), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool restart(const string&in timer_id)"), asMETHOD(timer_queue, restart), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool is_repeating(const string&in timer_id) const"), asMETHOD(timer_queue, is_repeating), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool set_timeout(const string&in timer_id, uint64 milliseconds, bool repeating = false)"), asMETHOD(timer_queue, set_timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool delete(const string&in timer_id)"), asMETHOD(timer_queue, erase), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void flush()"), asMETHOD(timer_queue, flush), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("void reset()"), asMETHOD(timer_queue, reset), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("uint size() const"), asMETHOD(timer_queue, size), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer_queue"), _O("bool loop(int max_timers = 0, int max_catchup_milliseconds = 100)"), asMETHOD(timer_queue, loop), asCALL_THISCALL);
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_DATETIME);
	engine->RegisterObjectType(_O("timer"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_FACTORY, _O("timer@ t()"), asFUNCTION(timestuff_factory<timer>), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_FACTORY, _O("timer@ t(bool speedhack_protection)"), asFUNCTION((timestuff_factory<timer, bool>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_FACTORY, _O("timer@ t(int64 initial_elapsed, bool speedhack_protection = speedhack_protection)"), asFUNCTION((timestuff_factory<timer, int64_t, bool>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_FACTORY, _O("timer@ t(int64 initial_elapsed, uint64 accuracy, bool speedhack_protection = speedhack_protection)"), asFUNCTION((timestuff_factory<timer, int64_t, uint64_t, bool>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(timer, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("timer"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(timer, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("int64 get_elapsed() const property"), asMETHOD(timer, get_elapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void set_elapsed(int64 time_units) property"), asMETHOD(timer, force), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool has_elapsed(int64 time_units) const"), asMETHOD(timer, has_elapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool tick(int64 time_units)"), asMETHOD(timer, tick), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void force(int64 elapsed)"), asMETHOD(timer, force), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void adjust(int64 mod_elapsed)"), asMETHOD(timer, adjust), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void restart()"), asMETHOD(timer, restart), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool get_secure() const property"), asMETHOD(timer, get_secure), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void set_secure(bool secure) property"), asMETHOD(timer, set_secure), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool get_paused() const property"), asMETHOD(timer, get_paused), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool get_running() const property"), asMETHOD(timer, get_running), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("void toggle_pause()"), asMETHOD(timer, toggle_pause), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool pause()"), asMETHOD(timer, pause), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool resume()"), asMETHOD(timer, resume), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("timer"), _O("bool set_paused(bool paused)"), asMETHOD(timer, set_paused), asCALL_THISCALL);
	engine->RegisterObjectProperty(_O("timer"), _O("uint64 accuracy"), asOFFSET(timer, accuracy));
	engine->RegisterGlobalProperty(_O("const int64 MICROSECONDS"), (void *)&TIMESPAN_MICROSECONDS);
	engine->RegisterGlobalProperty(_O("const int64 MILLISECONDS"), (void *)&Timespan::MILLISECONDS);
	engine->RegisterGlobalProperty(_O("const int64 SECONDS"), (void *)&Timespan::SECONDS);
	engine->RegisterGlobalProperty(_O("const int64 MINUTES"), (void *)&Timespan::MINUTES);
	engine->RegisterGlobalProperty(_O("const int64 HOURS"), (void *)&Timespan::HOURS);
	engine->RegisterGlobalProperty(_O("const int64 DAYS"), (void *)&Timespan::DAYS);
	engine->RegisterGlobalProperty(_O("uint64 timer_default_accuracy"), &timer_default_accuracy);
	angelscript_refcounted_register<LocalDateTime>(engine, "calendar");
	angelscript_refcounted_register<DateTime>(engine, "datetime");
	engine->RegisterObjectType("timespan", sizeof(Timespan), asOBJ_VALUE | asGetTypeTraits<Timespan>());
	engine->RegisterObjectType("timestamp", sizeof(Timestamp), asOBJ_VALUE | asGetTypeTraits<Timestamp>());
	engine->RegisterObjectBehaviour("timestamp", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(timestuff_construct<Timestamp>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("timestamp", asBEHAVE_CONSTRUCT, "void f(int64)", asFUNCTION((timestuff_construct<Timestamp, Timestamp::TimeVal>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("timestamp", asBEHAVE_CONSTRUCT, "void f(const timestamp&in)", asFUNCTION(timestuff_copy_construct<Timestamp>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("timestamp", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(timestuff_destruct<Timestamp>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("timestamp", "timestamp& opAssign(const timestamp&in)", asMETHODPR(Timestamp, operator=, (const Timestamp &), Timestamp &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "timestamp& opAssign(int64)", asMETHODPR(Timestamp, operator=, (Int64), Timestamp &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "void update()", asMETHOD(Timestamp, update), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "bool opEquals(const timestamp&in) const", asMETHOD(Timestamp, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "int opCmp(const timestamp&in) const", asFUNCTION((timestuff_opCmp<Timestamp, const Timestamp &>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("timestamp", "timestamp opAdd(int64) const", asMETHODPR(Timestamp, operator+, (Int64) const, Timestamp), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "timestamp opAdd(const timespan&in) const", asMETHODPR(Timestamp, operator+, (const Timespan &) const, Timestamp), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "timestamp opSub(int64) const", asMETHODPR(Timestamp, operator-, (Int64) const, Timestamp), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "timestamp opSub(const timespan&in) const", asMETHODPR(Timestamp, operator-, (const Timespan &) const, Timestamp), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "int64 opSub(const timestamp&in) const", asMETHODPR(Timestamp, operator-, (const Timestamp &) const, Int64), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "timestamp& opAddAssign(int64)", asMETHODPR(Timestamp, operator+=, (Int64), Timestamp &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "timestamp& opAddAssign(const timespan&in)", asMETHODPR(Timestamp, operator+=, (const Timespan &), Timestamp &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "timestamp& opSubAssign(int64)", asMETHODPR(Timestamp, operator-=, (Int64), Timestamp &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "timestamp& opSubAssign(const timespan&in)", asMETHODPR(Timestamp, operator-=, (const Timespan &), Timestamp &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "int64 get_UTC_time() const property", asMETHOD(Timestamp, utcTime), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "int64 get_elapsed() const property", asMETHOD(Timestamp, elapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "bool has_elapsed(int64) const", asMETHOD(Timestamp, isElapsed), asCALL_THISCALL);
	engine->RegisterObjectMethod("timestamp", "int64 opImplConv() const", asMETHOD(Timestamp, raw), asCALL_THISCALL);
	engine->RegisterGlobalFunction("timestamp timestamp_from_UTC_time(int64 UTC)", asFUNCTION(Timestamp::fromUtcTime), asCALL_CDECL);

	engine->RegisterObjectBehaviour("timespan", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(timestuff_construct<Timespan>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("timespan", asBEHAVE_CONSTRUCT, "void f(int64 microseconds)", asFUNCTION((timestuff_construct<Timespan, Int64>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("timespan", asBEHAVE_CONSTRUCT, "void f(int seconds, int microseconds)", asFUNCTION((timestuff_construct<Timespan, long, long>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("timespan", asBEHAVE_CONSTRUCT, "void f(int days, int hours, int minutes, int seconds, int microseconds)", asFUNCTION((timestuff_construct<Timespan, int, int, int, int, int>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("timespan", asBEHAVE_CONSTRUCT, "void f(const timespan&in)", asFUNCTION(timestuff_copy_construct<Timespan>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("timespan", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(timestuff_destruct<Timespan>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("timespan", "timespan& opAssign(const timespan&in)", asMETHODPR(Timespan, operator=, (const Timespan &), Timespan &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "timespan& opAssign(int64 microseconds)", asMETHODPR(Timespan, operator=, (Int64), Timespan &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "bool opEquals(const timespan&in) const", asMETHODPR(Timespan, operator==, (const Timespan &) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "bool opEquals(int64 microseconds) const", asMETHODPR(Timespan, operator==, (Int64) const, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int opCmp(const timespan&in) const", asFUNCTION((timestuff_opCmp<Timespan, const Timespan &>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("timespan", "int opCmp(int64 microseconds) const", asFUNCTION((timestuff_opCmp<Timespan, Int64>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("timespan", "timespan opAdd(int64 microseconds) const", asMETHODPR(Timespan, operator+, (Int64) const, Timespan), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "timespan opAdd(const timespan&in) const", asMETHODPR(Timespan, operator+, (const Timespan &) const, Timespan), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "timespan opSub(int64 microseconds) const", asMETHODPR(Timespan, operator-, (Int64) const, Timespan), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "timespan opSub(const timespan&in) const", asMETHODPR(Timespan, operator-, (const Timespan &) const, Timespan), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "timespan& opAddAssign(int64 milliseconds)", asMETHODPR(Timespan, operator+=, (Int64), Timespan &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "timespan& opAddAssign(const timespan&in)", asMETHODPR(Timespan, operator+=, (const Timespan &), Timespan &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "timespan& opSubAssign(int64 milliseconds)", asMETHODPR(Timespan, operator-=, (Int64), Timespan &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "timespan& opSubAssign(const timespan&in)", asMETHODPR(Timespan, operator-=, (const Timespan &), Timespan &), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_days() const property", asMETHOD(Timespan, days), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_hours() const property", asMETHOD(Timespan, hours), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_total_hours() const property", asMETHOD(Timespan, totalHours), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_minutes() const property", asMETHOD(Timespan, minutes), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_total_minutes() const property", asMETHOD(Timespan, totalMinutes), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_seconds() const property", asMETHOD(Timespan, seconds), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_total_seconds() const property", asMETHOD(Timespan, totalSeconds), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_milliseconds() const property", asMETHOD(Timespan, milliseconds), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_total_milliseconds() const property", asMETHOD(Timespan, totalMilliseconds), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_microseconds() const property", asMETHOD(Timespan, microseconds), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_useconds() const property", asMETHOD(Timespan, useconds), asCALL_THISCALL);
	engine->RegisterObjectMethod("timespan", "int get_total_microseconds() const property", asMETHOD(Timespan, totalMicroseconds), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("datetime", asBEHAVE_FACTORY, "datetime@ f()", asFUNCTION(angelscript_refcounted_factory<DateTime>), asCALL_CDECL);
	engine->RegisterObjectBehaviour("datetime", asBEHAVE_FACTORY, "datetime@ f(const timestamp&in timestamp)", asFUNCTION((angelscript_refcounted_factory<DateTime, const Timestamp&>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour("datetime", asBEHAVE_FACTORY, "datetime@ f(double julian_day)", asFUNCTION((angelscript_refcounted_factory<DateTime, double>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour("datetime", asBEHAVE_FACTORY, "datetime@ f(int year, int month, int day, int hour = 0, int minute = 0, int second = 0, int millisecond = 0, int microsecond = 0)", asFUNCTION((angelscript_refcounted_factory<DateTime, int, int, int, int, int, int, int, int>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour("datetime", asBEHAVE_FACTORY, "datetime@ f(const datetime&in)", asFUNCTION((angelscript_refcounted_factory<DateTime, const DateTime &>)), asCALL_CDECL);

	engine->RegisterObjectMethod("datetime", "datetime& opAssign(const datetime&in)", asMETHODPR(DateTime, operator=, (const DateTime &), DateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "datetime& opAssign(const timestamp&in)", asMETHODPR(DateTime, operator=, (const Timestamp &), DateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "datetime& opAssign(double julian_day)", asMETHODPR(DateTime, operator=, (double), DateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "datetime& set(int year, int month, int day, int hour = 0, int minute = 0, int second = 0, int millisecond = 0, int microsecond = 0)", asMETHOD(DateTime, assign), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_year() const property", asMETHOD(DateTime, year), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_yearday() const property", asMETHOD(DateTime, dayOfYear), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_month() const property", asMETHOD(DateTime, month), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int week(int first_day_of_week = 1) const", asMETHOD(DateTime, week), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_weekday() const property", asMETHOD(DateTime, dayOfWeek), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_day() const property", asMETHOD(DateTime, day), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_hour() const property", asMETHOD(DateTime, hour), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_hour12() const property", asMETHOD(DateTime, hourAMPM), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "bool get_AM() const property", asMETHOD(DateTime, isAM), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "bool get_PM() const property", asMETHOD(DateTime, isPM), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_minute() const property", asMETHOD(DateTime, minute), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_second() const property", asMETHOD(DateTime, second), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_millisecond() const property", asMETHOD(DateTime, millisecond), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int get_microsecond() const property", asMETHOD(DateTime, microsecond), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "double get_julian_day() const property", asMETHOD(DateTime, julianDay), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "timestamp get_timestamp() const property", asMETHOD(DateTime, timestamp), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int64 get_UTC_time() const property", asMETHOD(DateTime, utcTime), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "bool opEquals(const datetime&in) const", asMETHOD(DateTime, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "int opCmp(const datetime&in) const", asFUNCTION((timestuff_opCmp<DateTime, const DateTime &>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("datetime", "datetime@ opAdd(const timespan&in) const", asMETHODPR(DateTime, operator+, (const Timespan &) const, DateTime), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "datetime@ opSub(const timespan&in) const", asMETHODPR(DateTime, operator-, (const Timespan &) const, DateTime), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "timespan opSub(const datetime&in) const", asMETHODPR(DateTime, operator-, (const DateTime &) const, Timespan), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "datetime& opAddAssign(const timespan&in)", asMETHODPR(DateTime, operator+=, (const Timespan &), DateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "datetime& opSubAssign(const timespan&in)", asMETHODPR(DateTime, operator-=, (const Timespan &), DateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "void make_UTC(int timezone_offset)", asMETHOD(DateTime, makeUTC), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "void make_local(int timezone_offset)", asMETHOD(DateTime, makeLocal), asCALL_THISCALL);
	engine->RegisterObjectMethod("datetime", "void reset()", asFUNCTION(timestuff_reset<DateTime>), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("bool datetime_is_leap_year(int year)", asFUNCTION(DateTime::isLeapYear), asCALL_CDECL);
	engine->RegisterGlobalFunction("int datetime_days_of_month(int year, int month)", asFUNCTION(DateTime::daysOfMonth), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool datetime_is_valid(int year, int month, int day, int hour = 0, int minute = 0, int second = 0, int millisecond = 0, int microsecond = 0)", asFUNCTION(DateTime::isValid), asCALL_CDECL);

	engine->RegisterObjectBehaviour("calendar", asBEHAVE_FACTORY, "calendar@ f()", asFUNCTION(angelscript_refcounted_factory<LocalDateTime>), asCALL_CDECL);
	engine->RegisterObjectBehaviour("calendar", asBEHAVE_FACTORY, "calendar@ f(double julian_day)", asFUNCTION((angelscript_refcounted_factory<LocalDateTime, double>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour("calendar", asBEHAVE_FACTORY, "calendar@ f(int year, int month, int day, int hour = 0, int minute = 0, int second = 0, int millisecond = 0, int microsecond = 0)", asFUNCTION((angelscript_refcounted_factory<LocalDateTime, int, int, int, int, int, int, int, int>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour("calendar", asBEHAVE_FACTORY, "calendar@ f(const datetime&in)", asFUNCTION((angelscript_refcounted_factory<LocalDateTime, const DateTime &>)), asCALL_CDECL);
	engine->RegisterObjectBehaviour("calendar", asBEHAVE_FACTORY, "calendar@ f(const calendar&in)", asFUNCTION((angelscript_refcounted_factory<LocalDateTime, const LocalDateTime &>)), asCALL_CDECL);
	engine->RegisterObjectMethod("calendar", "calendar& opAssign(const calendar&in)", asMETHODPR(LocalDateTime, operator=, (const LocalDateTime &), LocalDateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "calendar& opAssign(const timestamp&in)", asMETHODPR(LocalDateTime, operator=, (const Timestamp &), LocalDateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "calendar& opAssign(double julian_day)", asMETHODPR(LocalDateTime, operator=, (double), LocalDateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "calendar& set(int year, int month, int day, int hour = 0, int minute = 0, int second = 0, int millisecond = 0, int microsecond = 0)", asMETHODPR(LocalDateTime, assign, (int, int, int, int, int, int, int, int), LocalDateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_year() const property", asMETHOD(LocalDateTime, year), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_yearday() const property", asMETHOD(LocalDateTime, dayOfYear), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_month() const property", asMETHOD(LocalDateTime, month), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int week(int first_day_of_week = 1) const", asMETHOD(LocalDateTime, week), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_weekday() const property", asMETHOD(LocalDateTime, dayOfWeek), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_day() const property", asMETHOD(LocalDateTime, day), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_hour() const property", asMETHOD(LocalDateTime, hour), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_hour12() const property", asMETHOD(LocalDateTime, hourAMPM), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "bool get_AM() const property", asMETHOD(LocalDateTime, isAM), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "bool get_PM() const property", asMETHOD(LocalDateTime, isPM), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_minute() const property", asMETHOD(LocalDateTime, minute), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_second() const property", asMETHOD(LocalDateTime, second), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_millisecond() const property", asMETHOD(LocalDateTime, millisecond), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_microsecond() const property", asMETHOD(LocalDateTime, microsecond), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "double get_julian_day() const property", asMETHOD(LocalDateTime, julianDay), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int get_tzd() const property", asMETHOD(LocalDateTime, tzd), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "datetime@ get_UTC() const property", asMETHOD(LocalDateTime, utc), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "timestamp get_timestamp() const property", asMETHOD(LocalDateTime, timestamp), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int64 get_UTC_time() const property", asMETHOD(LocalDateTime, utcTime), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "bool opEquals(const calendar&in) const", asMETHOD(LocalDateTime, operator==), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "int opCmp(const calendar&in) const", asFUNCTION((timestuff_opCmp<LocalDateTime, const LocalDateTime &>)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("calendar", "calendar@ opAdd(const timespan&in) const", asFUNCTION((angelscript_refcounted_duplicating_method < LocalDateTime, &LocalDateTime::operator+, const Timespan & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("calendar", "calendar@ opSub(const timespan&in) const", asFUNCTION((angelscript_refcounted_duplicating_method < LocalDateTime, static_cast<LocalDateTime(LocalDateTime::*)(const Timespan &) const>(&LocalDateTime::operator-), const Timespan & >)), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("calendar", "timespan opSub(const calendar&in) const", asMETHODPR(LocalDateTime, operator-, (const LocalDateTime &) const, Timespan), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "calendar& opAddAssign(const timespan&in)", asMETHODPR(LocalDateTime, operator+=, (const Timespan &), LocalDateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "calendar& opSubAssign(const timespan&in)", asMETHODPR(LocalDateTime, operator-=, (const Timespan &), LocalDateTime &), asCALL_THISCALL);
	engine->RegisterObjectMethod("calendar", "void reset()", asFUNCTION(timestuff_reset<LocalDateTime>), asCALL_CDECL_OBJFIRST);
	register_date_time_extensions<LocalDateTime>(engine, "calendar");
	register_date_time_extensions<DateTime>(engine, "datetime");
	engine->RegisterObjectMethod("timestamp", "string format(const string&in fmt, int tzd = 0xffff)", asFUNCTIONPR(DateTimeFormatter::format, (const Timestamp &, const std::string &, int), std::string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("datetime", "string format(const string&in fmt, int tzd = 0xffff)", asFUNCTIONPR(DateTimeFormatter::format, (const DateTime &, const std::string &, int), std::string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("calendar", "string format(const string&in fmt)", asFUNCTIONPR(DateTimeFormatter::format, (const LocalDateTime &, const std::string &), std::string), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("timespan", "string format(const string&in fmt = \"%dd %H:%M:%S.%i\")", asFUNCTIONPR(DateTimeFormatter::format, (const Timespan &, const std::string &), std::string), asCALL_CDECL_OBJFIRST);
	engine->RegisterGlobalFunction("datetime@ parse_datetime(const string&in fmt, const string&in str, int& tzd)", asFUNCTIONPR(DateTimeParser::parse, (const std::string &, const std::string &, int &), DateTime), asCALL_CDECL);
	engine->RegisterGlobalFunction("datetime@ parse_datetime(const string&in str, int& tzd)", asFUNCTIONPR(DateTimeParser::parse, (const std::string &, int &), DateTime), asCALL_CDECL);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_ISO8601", (void *)&DateTimeFormat::ISO8601_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_ISO8601_FRAC", (void *)&DateTimeFormat::ISO8601_FRAC_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_REGEX_ISO8601", (void *)&DateTimeFormat::ISO8601_REGEX);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_RFC822", (void *)&DateTimeFormat::RFC822_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_REGEX_RFC822", (void *)&DateTimeFormat::RFC822_REGEX);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_RFC1123", (void *)&DateTimeFormat::RFC1123_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_REGEX_RFC1123", (void *)&DateTimeFormat::RFC1123_REGEX);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_RFC850", (void *)&DateTimeFormat::RFC850_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_REGEX_RFC850", (void *)&DateTimeFormat::RFC850_REGEX);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_RFC1036", (void *)&DateTimeFormat::RFC1036_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_REGEX_RFC1036", (void *)&DateTimeFormat::RFC1036_REGEX);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_HTTP", (void *)&DateTimeFormat::HTTP_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_REGEX_HTTP", (void *)&DateTimeFormat::HTTP_REGEX);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_ASCTIME", (void *)&DateTimeFormat::ASCTIME_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_REGEX_ASCTIME", (void *)&DateTimeFormat::ASCTIME_REGEX);
	engine->RegisterGlobalProperty("const string DATE_TIME_FORMAT_SORTABLE", (void *)&DateTimeFormat::SORTABLE_FORMAT);
	engine->RegisterGlobalProperty("const string DATE_TIME_REGEX_SORTABLE", (void *)&DateTimeFormat::SORTABLE_REGEX);
	engine->RegisterGlobalFunction("bool datetime_is_valid_format_string(const string&in fmt)", asFUNCTION(DateTimeFormat::hasFormat), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool datetime_is_valid_format(const string&in datetime)", asFUNCTION(DateTimeFormat::isValid), asCALL_CDECL);
}
