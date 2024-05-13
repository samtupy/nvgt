/* threading.cpp - code for wrapping threads and multithreading primatives (usually from Poco)
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

#include <string>
#include <type_traits>
#include <Poco/Event.h>
#include <Poco/Format.h>
#include <Poco/Mutex.h>
#include <Poco/NamedMutex.h>
#include <Poco/Runnable.h>
#include <Poco/RWLock.h>
#include <Poco/ScopedLock.h>
#include <Poco/Thread.h>
#include <Poco/ThreadPool.h>
#include <angelscript.h>
#include <scriptdictionary.h>
#include <obfuscate.h>
#include "nvgt.h"
#include "pocostuff.h"
#include "threading.h"
using namespace Poco;

// Poco does support starting a thread by directly passing a function pointer and user data, but things like Poco's ThreadPool do not support this and so instead we opt to inherit from their Runnable class which is more unified and which works with all of Poco's multithreading mechanisms.
class script_runnable : public Runnable {
	asIScriptFunction* func;
	CScriptDictionary* args;
	Thread* thread; // May be null if started from a ThreadPool.
public:
	script_runnable(asIScriptFunction* func, CScriptDictionary* args, Thread* thread = nullptr) : func(func), args(args), thread(thread) {}
	void run() {
		int execution_result = asEXECUTION_FINISHED;
		asIScriptContext* ctx = nullptr;
		if (!func) goto finish;
		ctx = g_ScriptEngine->RequestContext();
		if (!ctx) goto finish;
		if (ctx->Prepare(func) < 0) goto finish;
		if (ctx->SetArgObject(0, args) < 0) goto finish;
		execution_result = ctx->Execute(); // Todo: Work out what we want to do with exceptions or errors that take place in threads.
		finish:
			if (ctx && !g_shutting_down) g_ScriptEngine->ReturnContext(ctx); // We only do this when the engine is not shutting down because the angelscript could get partially destroyed on the main thread before this point in the shutdown case.
			if (thread) angelscript_refcounted_release<Thread>(thread);
			asThreadCleanup();
			delete this; // Poco wants us to keep these Runnable objects alive as long as the thread is running, meaning we must delete ourself from within the thread to avoid some other sort of cleanup machinery.
			return;
	}
};

void thread_begin(Thread* thread, asIScriptFunction* func, CScriptDictionary* args) {
	if (!func) return;
	angelscript_refcounted_duplicate<Thread>(thread);
	thread->start(*new script_runnable(func, args, thread));
}
void pooled_thread_begin(ThreadPool* pool, asIScriptFunction* func, CScriptDictionary* args) {
	if (func) pool->start(*new script_runnable(func, args));
}
void pooled_thread_begin(ThreadPool* pool, asIScriptFunction* func, CScriptDictionary* args, const std::string& name) {
	if (func) pool->start(*new script_runnable(func, args), name);
}
void pooled_thread_begin(ThreadPool* pool, asIScriptFunction* func, CScriptDictionary* args, Thread::Priority priority) {
	if (func) pool->startWithPriority(priority, *new script_runnable(func, args));
}
void pooled_thread_begin(ThreadPool* pool, asIScriptFunction* func, CScriptDictionary* args, const std::string& name, Thread::Priority priority) {
	if (func) pool->startWithPriority(priority, *new script_runnable(func, args), name);
}

template <class T> void scoped_lock_construct(void* mem, T* mutex) {
	new (mem) ScopedLockWithUnlock<T>(*mutex);
}
template <class T> void scoped_lock_construct_ms(void* mem, T* mutex, long ms) {
	new (mem) ScopedLockWithUnlock<T>(*mutex, ms);
}
void scoped_rw_lock_construct(void* mem, RWLock* lock, bool write) {
	new (mem) ScopedRWLock(*lock, write);
}
void scoped_read_rw_lock_construct(void* mem, RWLock* lock) {
	new (mem) ScopedReadRWLock(*lock);
}
void scoped_write_rw_lock_construct(void* mem, RWLock* lock) {
	new (mem) ScopedWriteRWLock(*lock);
}
template <class T> void scoped_lock_destruct(ScopedLockWithUnlock<T>* mem) {
	mem->~ScopedLockWithUnlock<T>();
}
void scoped_rw_lock_destruct(ScopedRWLock* mem) {
	mem->~ScopedRWLock();
}
void scoped_read_rw_lock_destruct(ScopedReadRWLock* mem) {
	mem->~ScopedReadRWLock();
}
void scoped_write_rw_lock_destruct(ScopedWriteRWLock* mem) {
	mem->~ScopedWriteRWLock();
}


template <class T> void RegisterMutexType(asIScriptEngine* engine, const std::string& type) {
	angelscript_refcounted_register<T>(engine, type.c_str());
	if constexpr(std::is_same<T, NamedMutex>::value) engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ m(const string&in)", type).c_str(), asFUNCTION((angelscript_refcounted_factory<T, const std::string&>)), asCALL_CDECL);
	else {
		engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ m()", type).c_str(), asFUNCTION(angelscript_refcounted_factory<T>), asCALL_CDECL);
		engine->RegisterObjectMethod(type.c_str(), _O("void lock(uint)"), asMETHODPR(T, lock, (long), void), asCALL_THISCALL);
		engine->RegisterObjectMethod(type.c_str(), _O("bool try_lock(uint)"), asMETHODPR(T, tryLock, (long), bool), asCALL_THISCALL);
	}
	engine->RegisterObjectMethod(type.c_str(), _O("void lock()"), asMETHODPR(T, lock, (), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), _O("bool try_lock()"), asMETHODPR(T, tryLock, (), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(type.c_str(), _O("void unlock()"), asMETHOD(T, unlock), asCALL_THISCALL);
	engine->RegisterObjectType(format("%s_lock", type).c_str(), sizeof(ScopedLock<T>), asOBJ_VALUE | asGetTypeTraits<ScopedLock<T>>());
	engine->RegisterObjectBehaviour(format("%s_lock", type).c_str(), asBEHAVE_CONSTRUCT, format("void f(%s@)", type).c_str(), asFUNCTION(scoped_lock_construct<T>), asCALL_CDECL_OBJFIRST);
	if constexpr(!std::is_same<T, NamedMutex>::value) engine->RegisterObjectBehaviour(format("%s_lock", type).c_str(), asBEHAVE_CONSTRUCT, format("void f(%s@, uint)", type).c_str(), asFUNCTION(scoped_lock_construct_ms<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(format("%s_lock", type).c_str(), asBEHAVE_DESTRUCT, "void f()", asFUNCTION(scoped_lock_destruct<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(format("%s_lock", type).c_str(), _O("void unlock()"), asMETHOD(ScopedLockWithUnlock<T>, unlock), asCALL_THISCALL);
}

void RegisterThreading(asIScriptEngine* engine) {
	engine->RegisterEnum("thread_priority");
	engine->RegisterEnumValue("thread_priority", "THREAD_PRIORITY_LOWEST", Thread::Priority::PRIO_LOWEST);
	engine->RegisterEnumValue("thread_priority", "THREAD_PRIORITY_LOW", Thread::Priority::PRIO_LOW);
	engine->RegisterEnumValue("thread_priority", "THREAD_PRIORITY_NORMAL", Thread::Priority::PRIO_NORMAL);
	engine->RegisterEnumValue("thread_priority", "THREAD_PRIORITY_HIGH", Thread::Priority::PRIO_HIGH);
	engine->RegisterEnumValue("thread_priority", "THREAD_PRIORITY_HIGHEST", Thread::Priority::PRIO_HIGHEST);
	angelscript_refcounted_register<Thread>(engine, "thread");
	engine->RegisterGlobalFunction(_O("uint thread_current_id()"), asFUNCTION(Thread::currentOsTid), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("void thread_yield()"), asFUNCTION(Thread::yield), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("bool thread_sleep(uint)"), asFUNCTION(Thread::trySleep), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("thread@+ get_thread_current() property"), asFUNCTION(Thread::current), asCALL_CDECL);
	engine->RegisterFuncdef(_O("void thread_callback(dictionary@)"));
	engine->RegisterObjectBehaviour(_O("thread"), asBEHAVE_FACTORY, _O("thread@ t()"), asFUNCTION(angelscript_refcounted_factory<Thread>), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("thread"), asBEHAVE_FACTORY, _O("thread@ t(const string&in)"), asFUNCTION((angelscript_refcounted_factory<Thread, const std::string&>)), asCALL_CDECL);
	engine->RegisterObjectMethod(_O("thread"), _O("int get_id() const property"), asMETHOD(Thread, id), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("void set_priority(thread_priority) property"), asMETHOD(Thread, setPriority), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("thread_priority get_priority() const property"), asMETHOD(Thread, getPriority), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("void set_name(const string&in) property"), asMETHOD(Thread, setName), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("string get_name() const property"), asMETHOD(Thread, getName), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("void join()"), asMETHODPR(Thread, join, (), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("bool join(uint)"), asMETHOD(Thread, tryJoin), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("bool get_running() const property"), asMETHOD(Thread, isRunning), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("void start(thread_callback@, dictionary@ = null)"), asFUNCTION(thread_begin), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("thread"), _O("void wake_up()"), asMETHOD(Thread, wakeUp), asCALL_THISCALL);
	RegisterMutexType<Mutex>(engine, "mutex");
	RegisterMutexType<FastMutex>(engine, "fast_mutex");
	RegisterMutexType<NamedMutex>(engine, "named_mutex");
	RegisterMutexType<NamedMutex>(engine, "spinlock_mutex");
	angelscript_refcounted_register<RWLock>(engine, "rw_lock");
	engine->RegisterObjectBehaviour(_O("rw_lock"), asBEHAVE_FACTORY, _O("rw_lock@ l()"), asFUNCTION(angelscript_refcounted_factory<RWLock>), asCALL_CDECL);
	engine->RegisterObjectMethod(_O("rw_lock"), _O("void read_lock()"), asMETHOD(RWLock, readLock), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("rw_lock"), _O("bool try_read_lock()"), asMETHOD(RWLock, tryReadLock), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("rw_lock"), _O("void write_lock()"), asMETHOD(RWLock, writeLock), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("rw_lock"), _O("bool try_write_lock()"), asMETHOD(RWLock, tryWriteLock), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("rw_lock"), _O("void unlock()"), asMETHOD(RWLock, unlock), asCALL_THISCALL);
	engine->RegisterObjectType("rw_scoped_lock", sizeof(ScopedRWLock), asOBJ_VALUE | asGetTypeTraits<ScopedRWLock>());
	engine->RegisterObjectBehaviour("rw_scoped_lock", asBEHAVE_CONSTRUCT, "void f(rw_lock@, bool)", asFUNCTION(scoped_rw_lock_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("rw_scoped_lock", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(scoped_rw_lock_destruct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectType("rw_read_lock", sizeof(ScopedReadRWLock), asOBJ_VALUE | asGetTypeTraits<ScopedReadRWLock>());
	engine->RegisterObjectBehaviour("rw_read_lock", asBEHAVE_CONSTRUCT, "void f(rw_lock@)", asFUNCTION(scoped_read_rw_lock_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("rw_read_lock", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(scoped_read_rw_lock_destruct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectType("rw_write_lock", sizeof(ScopedWriteRWLock), asOBJ_VALUE | asGetTypeTraits<ScopedWriteRWLock>());
	engine->RegisterObjectBehaviour("rw_write_lock", asBEHAVE_CONSTRUCT, "void f(rw_lock@)", asFUNCTION(scoped_write_rw_lock_construct), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("rw_write_lock", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(scoped_write_rw_lock_destruct), asCALL_CDECL_OBJFIRST);
	engine->RegisterEnum("thread_event_type");
	engine->RegisterEnumValue("thread_event_type", "THREAD_EVENT_MANUAL_RESET", Event::EVENT_MANUALRESET);
	engine->RegisterEnumValue("thread_event_type", "THREAD_EVENT_AUTO_RESET", Event::EVENT_AUTORESET);
	angelscript_refcounted_register<Event>(engine, "thread_event");
	engine->RegisterObjectBehaviour("thread_event", asBEHAVE_FACTORY, "thread_event@ e(thread_event_type = THREAD_EVENT_AUTO_RESET)", asFUNCTION((angelscript_refcounted_factory<Event, Event::EventType>)), asCALL_CDECL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("void set()"), asMETHOD(Event, set), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("void wait()"), asMETHODPR(Event, wait, (), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("void wait(uint)"), asMETHODPR(Event, wait, (long), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("bool try_wait(uint)"), asMETHOD(Event, tryWait), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("void reset()"), asMETHOD(Event, reset), asCALL_THISCALL);
	angelscript_refcounted_register<ThreadPool>(engine, "thread_pool");
	engine->RegisterObjectBehaviour("thread_pool", asBEHAVE_FACTORY, format("thread_pool@ p(int = 2, int = 16, int = 60, int = %d)", POCO_THREAD_STACK_SIZE).c_str(), asFUNCTION((angelscript_refcounted_factory<ThreadPool, int, int, int, int>)), asCALL_CDECL);
	engine->RegisterObjectMethod("thread_pool", "void add_capacity(int)", asMETHOD(ThreadPool, addCapacity), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_capacity() const property", asMETHOD(ThreadPool, capacity), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "void set_stack_size(int) property", asMETHOD(ThreadPool, setStackSize), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_stack_size() const property", asMETHOD(ThreadPool, getStackSize), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_used() const property", asMETHOD(ThreadPool, used), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_allocated() const property", asMETHOD(ThreadPool, allocated), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_available() const property", asMETHOD(ThreadPool, available), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_pool"), _O("void start(thread_callback@, dictionary@ = null)"), asFUNCTIONPR(pooled_thread_begin, (ThreadPool*, asIScriptFunction*, CScriptDictionary*), void), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("thread_pool"), _O("void start(thread_callback@, dictionary@, thread_priority)"), asFUNCTIONPR(pooled_thread_begin, (ThreadPool*, asIScriptFunction*, CScriptDictionary*, Thread::Priority), void), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("thread_pool"), _O("void start(thread_callback@, dictionary@, const string&in)"), asFUNCTIONPR(pooled_thread_begin, (ThreadPool*, asIScriptFunction*, CScriptDictionary*, const std::string&), void), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("thread_pool"), _O("void start(thread_callback@, dictionary@, const string&in, thread_priority)"), asFUNCTIONPR(pooled_thread_begin, (ThreadPool*, asIScriptFunction*, CScriptDictionary*, const std::string&, Thread::Priority), void), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("thread_pool", "void stop_all()", asMETHOD(ThreadPool, stopAll), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "void join_all()", asMETHOD(ThreadPool, joinAll), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "void collect()", asMETHOD(ThreadPool, collect), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "const string& get_name() const property", asMETHOD(ThreadPool, name), asCALL_THISCALL);
	engine->RegisterGlobalFunction(_O("thread_pool& get_thread_pool_default() property"), asFUNCTION(ThreadPool::defaultPool), asCALL_CDECL);
}
