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
#include <Poco/Format.h>
#include <Poco/Mutex.h>
#include <Poco/NamedMutex.h>
#include <Poco/RWLock.h>
#include <Poco/ScopedLock.h>
#include <Poco/Thread.h>
#include <angelscript.h>
#include <scriptdictionary.h>
#include <obfuscate.h>
#include "nvgt.h"
#include "pocostuff.h"
#include "threading.h"
using namespace Poco;

typedef struct {
	asIScriptFunction* func;
	CScriptDictionary* args;
	Thread* thread;
} script_thread_extra;
void script_thread(void* extra) {
	script_thread_extra* e=(script_thread_extra*)extra;
	Thread* thread = e->thread;
	asIScriptFunction* func=e->func;
	CScriptDictionary* args=e->args;
	free(e);
	if(!func) {
		angelscript_refcounted_release<Thread>(thread);
		return;
	}
	asIScriptContext* ctx=g_ScriptEngine->CreateContext();
	if(!ctx) {
		angelscript_refcounted_release<Thread>(thread);
		return;
	}
	if(ctx->Prepare(func)<0) {
		ctx->Release();
		angelscript_refcounted_release<Thread>(thread);
		return;
	}
	if(ctx->SetArgObject(0, args)<0) {
		ctx->Release();
		angelscript_refcounted_release<Thread>(thread);
		return;
	}
	if(ctx->Execute()!=asEXECUTION_FINISHED) {
		ctx->Release();
		angelscript_refcounted_release<Thread>(thread);
		return;
	}
	ctx->Release();
	asThreadCleanup();
	angelscript_refcounted_release<Thread>(thread);
	return;
}

void thread_begin(Thread* thread, asIScriptFunction* func, CScriptDictionary* args) {
	if(!func) return;
	script_thread_extra* e=(script_thread_extra*)malloc(sizeof(script_thread_extra));
	e->func=func;
	e->thread = thread;
	e->args=args;
	angelscript_refcounted_duplicate<Thread>(thread);
	thread->start(script_thread, e);
}

Thread* thread_factory() {
	return new(angelscript_refcounted_create<Thread>()) Thread();
}
Thread* thread_named_factory(const std::string& name) {
	return new(angelscript_refcounted_create<Thread>()) Thread(name);
}
void* mutex_factory() { 
	return new(angelscript_refcounted_create<Mutex>()) Mutex();
}
void* fast_mutex_factory() { 
	return new(angelscript_refcounted_create<FastMutex>()) FastMutex();
}
void* spinlock_mutex_factory() { 
	return new(angelscript_refcounted_create<SpinlockMutex>()) SpinlockMutex();
}
void* named_mutex_factory(const std::string& name) { 
	return new(angelscript_refcounted_create<NamedMutex>()) NamedMutex(name);
}
void* rw_lock_factory() { 
	return new(angelscript_refcounted_create<RWLock>()) RWLock();
}
template <class T> void scoped_lock_construct(void* mem, T* mutex) {
	new(mem) ScopedLockWithUnlock<T>(*mutex);
}
template <class T> void scoped_lock_construct_ms(void* mem, T* mutex, long ms) {
	new(mem) ScopedLockWithUnlock<T>(*mutex, ms);
}
void scoped_rw_lock_construct(void* mem, RWLock* lock, bool write) {
	new(mem) ScopedRWLock(*lock, write);
}
void scoped_read_rw_lock_construct(void* mem, RWLock* lock) {
	new(mem) ScopedReadRWLock(*lock);
}
void scoped_write_rw_lock_construct(void* mem, RWLock* lock) {
	new(mem) ScopedWriteRWLock(*lock);
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
template <class T> void RegisterMutexType(asIScriptEngine* engine, const std::string& type, void* factory) {
	angelscript_refcounted_register<T>(engine, type.c_str());
	if constexpr(std::is_same<T, NamedMutex>::value) engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ m(const string&in)", type).c_str(), asFUNCTION(factory), asCALL_CDECL);
	else {
		engine->RegisterObjectBehaviour(type.c_str(), asBEHAVE_FACTORY, format("%s@ m()", type).c_str(), asFUNCTION(factory), asCALL_CDECL);
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
	engine->RegisterObjectBehaviour(_O("thread"), asBEHAVE_FACTORY, _O("thread@ t()"), asFUNCTION(thread_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("thread"), asBEHAVE_FACTORY, _O("thread@ t(const string&in)"), asFUNCTION(thread_named_factory), asCALL_CDECL);
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
	RegisterMutexType<Mutex>(engine, "mutex", (void*)mutex_factory);
	RegisterMutexType<FastMutex>(engine, "fast_mutex", (void*)fast_mutex_factory);
	RegisterMutexType<NamedMutex>(engine, "named_mutex", (void*)named_mutex_factory);
	RegisterMutexType<NamedMutex>(engine, "spinlock_mutex", (void*)spinlock_mutex_factory);
	angelscript_refcounted_register<RWLock>(engine, "rw_lock");
	engine->RegisterObjectBehaviour(_O("rw_lock"), asBEHAVE_FACTORY, _O("rw_lock@ l()"), asFUNCTION(rw_lock_factory), asCALL_CDECL);
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
}
