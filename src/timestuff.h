/* timestuff.h - header for datetime routines
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

#pragma once

#include <angelscript.h>
#include <algorithm>
#include <Poco/RefCountedObject.h>
#include <timer-wheel.h>
#include <unordered_map>
#include <unordered_set>
#include <string>

uint64_t ticks(bool secure = true);
uint64_t microticks(bool secure = true);

class timer_queue;
class timer_queue_item : public TimerEventInterface {
public:
	std::string id;
	asIScriptFunction* callback;
	std::string callback_data;
	int timeout;
	bool repeating;
	bool is_scheduled;
	timer_queue* parent;
	timer_queue_item(timer_queue* parent, const std::string& id, asIScriptFunction* callback, const std::string& callback_data, int timeout, bool repeating);
	void execute();
};
class timer_queue {
	TimerWheel timers;
	std::unordered_map<std::string, timer_queue_item*> timer_objects;
	std::unordered_set<timer_queue_item*> deleting_timers;
	uint64_t last_looped;
	bool open_tick;
	int RefCount;
public:
	std::string failures;
	timer_queue();
	void add_ref();
	void release();
	void set(const std::string& id, asIScriptFunction* callback, const std::string& user_data, uint64_t timeout, bool repeating = false);
	void set_dataless(const std::string& id, asIScriptFunction* callback, uint64_t timeout, bool repeating = false) {
		set(id, callback, "", timeout, repeating);
	}
	uint64_t elapsed(const std::string& id);
	uint64_t timeout(const std::string& id);
	bool is_repeating(const std::string& id);
	bool exists(const std::string& id) {
		return timer_objects.find(id) != timer_objects.end();
	}
	bool restart(const std::string& id);
	bool set_timeout(const std::string& id, uint64_t timeout, bool repeating);
	bool erase(const std::string& id);
	void flush();
	void reset();
	void schedule(timer_queue_item* t, Tick delta) {
		return timers.schedule(t, delta);
	}
	int size() {
		return timer_objects.size();
	}
	bool loop(int max_timers = 0, int max_catchup = 100);
};

class timer : public Poco::RefCountedObject {
	uint64_t value;
	bool paused;
	bool secure;
public:
	uint64_t accuracy;
	timer();
	timer(bool secure);
	timer(int64_t initial_value, bool secure);
	timer(int64_t initial_value, uint64_t initial_accuracy, bool secure);
	int64_t get_elapsed() const;
	bool has_elapsed(int64_t value) const;
	bool tick(int64_t value);
	void force(int64_t value);
	void adjust(int64_t value);
	void restart();
	bool get_secure() const;
	bool set_secure(bool value);
	bool get_paused() const;
	bool get_running() const;
	void toggle_pause();
	bool set_paused(bool paused);
	bool pause();
	bool resume();
};

void RegisterScriptTimestuff(asIScriptEngine* engine);
