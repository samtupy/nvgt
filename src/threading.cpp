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

#include <atomic>
#include <string>
#include <type_traits>
#include <Poco/Event.h>
#include <Poco/Format.h>
#include <Poco/Mutex.h>
#include <Poco/NamedMutex.h>
#include <Poco/RefCountedObject.h>
#include <Poco/Runnable.h>
#include <Poco/RWLock.h>
#include <Poco/ScopedLock.h>
#include <Poco/Thread.h>
#include <Poco/ThreadPool.h>
#include <angelscript.h>
#include <scriptdictionary.h>
#include <scripthelper.h>
#include <obfuscate.h>
#include "nvgt.h"
#include "pocostuff.h"
#include "threading.h"
using namespace Poco;

// We'll put the code for the highest level of nvgt's multithreading support on the top this time. This allows an nvgt user to write a line of code such as async<string> result(url_get, "https://nvgt.gg"); and after result.try_wait(ms) returns true, user can fetch result with result.value or opImplCast.
class async_result : public RefCountedObject, public Runnable {
	void* value;
	asITypeInfo* subtype;
	int subtypeid;
	Thread* task; // A pointer instead of a direct object because if an async_result object is created from a thread pool or has not yet been set up, a specific thread will not exist for it.
	asIScriptContext* ctx; // The angelscript context used to call the function asynchronously, stored as a property because we need to pass it between functions in this class without arguments.
	std::unordered_map<void*, asITypeInfo*> value_args; // Value typed arguments must be copied before being passed to the destination function on another thread, this is because such arguments reside on the stack and so they would otherwise get destroyed when the async_result::call method unwinds but well before the destination function returns. Store pointers to such copied arguments here so they can be released later.
	std::string exception; // Set to an exception string if an exception is thrown from within the async function call.
public:
	Event progress; // Public so that some functions in this object can be called directly from Angelscript such as wait and tryWait.
	async_result(asITypeInfo* t) : value(nullptr), subtype(t), subtypeid(subtype->GetSubTypeId()), progress(Event::EVENT_MANUALRESET), task(nullptr), ctx(nullptr) {}
	~async_result() {
		if (task) angelscript_refcounted_release<Thread>(task);
		release_value_args();
		if (value) {
			if (subtypeid & asTYPEID_MASK_OBJECT) subtype->GetEngine()->ReleaseScriptObject(*(void**)value, subtype->GetSubType());
			free(value);
		}
	}
	void* get_value() {
		if (!ctx) throw NullValueException("Object not initialized");
		progress.wait();
		if (exception != "") throw Exception(exception);
		if ((subtypeid & asTYPEID_MASK_OBJECT) && !(subtypeid & asTYPEID_OBJHANDLE))
			return *(void**)value;
		else return value;
	}
	std::string get_exception() { return progress.tryWait(0) ? exception : ""; }
	bool call(asIScriptGeneric* gen, ThreadPool* pool = nullptr) {
		asIScriptContext* aCtx = asGetActiveContext();
		asIScriptEngine* engine = aCtx->GetEngine();
		asIScriptFunction* func;
		int func_typeid = gen->GetArgTypeId(1);
		asITypeInfo* func_type = engine->GetTypeInfoById(func_typeid);
		if (!func_type || !(func_type->GetFlags() & asOBJ_FUNCDEF)) {
			aCtx->SetException("First argument to async must be a callable function");
			return false;
		}
		if (func_typeid & asTYPEID_OBJHANDLE) func = *(asIScriptFunction**)gen->GetArgAddress(1);
		else func = (asIScriptFunction*)gen->GetArgAddress(1);
		if (func->GetReturnTypeId() != subtypeid) {
			aCtx->SetException(format("return type of %s is incompatible with async result type %s", std::string(func->GetDeclaration()), std::string(engine->GetTypeDeclaration(subtypeid))).c_str());
			return false;
		}
		ctx = engine->RequestContext();
		if (!ctx || ctx->Prepare(func) < 0) {
			aCtx->SetException("Async can't prepare calling context");
			engine->ReturnContext(ctx);
			return false;
		}
		asIScriptContext* defCtx = nullptr; // We may need an extra context if we are required to evaluate expressions for default arguments.
		for (unsigned int i = 0; i < func->GetParamCount(); i++) {
			// In this context, param will be the argument as being received by the calling function and arg will be the argument as being passed to this async::call function.
			int param_typeid, arg_typeid;
			asITypeInfo* param_type, * arg_type;
			asDWORD param_flags, arg_flags;
			const char* param_default;
			int success = func->GetParam(i, &param_typeid, &param_flags, nullptr, &param_default);
			if (success < 0) {
				aCtx->SetException(format("Angelscript error %d while setting art %u of async call to %s", success, i, std::string(func->GetDeclaration())).c_str());
				engine->ReturnContext(ctx);
				return false;
			}
			if (gen->GetArgCount() - 2 <= i || param_default) {
				if (!param_default) {
					aCtx->SetException("Not enough arguments");
					engine->ReturnContext(ctx);
					return false;
				}
				// We must initialize the default arguments ourselves.
				if (!defCtx) defCtx = engine->RequestContext();
				if (!defCtx) {
					aCtx->SetException("Cannot attain context to evaluate default async call argument expressions");
					engine->ReturnContext(ctx);
					return false;
				}
				param_type = engine->GetTypeInfoById(param_typeid);
				if (param_typeid & asTYPEID_MASK_OBJECT && !(param_typeid & asTYPEID_OBJHANDLE)) {
					// Create a copy of the object.
					void* obj = engine->CreateScriptObject(param_type);
					if (!obj) {
						aCtx->SetException(format("Cannot create empty object for default assign of argument %u of async function call", i + 1).c_str());
						engine->ReturnContext(ctx);
						return false;
					}
					value_args[*(void**)obj] = param_type;
					*(void**)ctx->GetAddressOfArg(i) = obj;
				}
				if (std::string_view(param_default) == "void") success = ctx->SetArgObject(i, nullptr);
				else success = ExecuteString(engine, format("return %s;", std::string(param_default)).c_str(), *(void**)ctx->GetAddressOfArg(i), param_typeid, nullptr, defCtx);
				if (success < 0) {
					aCtx->SetException(format("Angelscript error %d while setting default argument %u in async call to %s", success, i + 1, std::string(func->GetDeclaration())).c_str());
					engine->ReturnContext(ctx);
					return false;
				}
				continue;
			}
			arg_typeid = gen->GetArgTypeId(i + 2);
			arg_type = engine->GetTypeInfoById(arg_typeid);
			success = asINVALID_ARG;
			if (arg_typeid == asTYPEID_VOID) success = ctx->SetArgAddress(i, nullptr);
			else if (arg_typeid == asTYPEID_BOOL || arg_typeid == asTYPEID_INT8 || arg_typeid == asTYPEID_UINT8) success = ctx->SetArgByte(i, *(asBYTE*)gen->GetArgAddress(i + 2));
			else if (arg_typeid == asTYPEID_INT16 || arg_typeid == asTYPEID_UINT16) success = ctx->SetArgWord(i, *(asWORD*)gen->GetArgAddress(i + 2));
			else if (arg_typeid == asTYPEID_INT32 || arg_typeid == asTYPEID_UINT32) success = ctx->SetArgDWord(i, *(asDWORD*)gen->GetArgAddress(i + 2));
			else if (arg_typeid == asTYPEID_INT64 || arg_typeid == asTYPEID_UINT64) success = ctx->SetArgQWord(i, *(asQWORD*)gen->GetArgAddress(i + 2));
			else if (arg_typeid == asTYPEID_FLOAT) success = ctx->SetArgFloat(i, *(float*)gen->GetArgAddress(i + 2));
			else if (arg_typeid == asTYPEID_DOUBLE) success = ctx->SetArgDouble(i, *(double*)gen->GetArgAddress(i + 2));
			else if (arg_typeid & asTYPEID_MASK_OBJECT && arg_typeid & asTYPEID_OBJHANDLE) success = ctx->SetArgObject(i, gen->GetArgObject(i + 2));
			else if (arg_typeid & asTYPEID_MASK_OBJECT) {
				void* obj = engine->CreateScriptObjectCopy(gen->GetArgAddress(i + 2), arg_type);
				if (!obj) {
					aCtx->SetException(format("Cannot copy object for argument %u of async function call", i + 1).c_str());
					engine->ReturnContext(ctx);
					return false;
				}
				success = ctx->SetArgObject(i, obj);
				if (success >= 0) value_args[obj] = arg_type;
				else engine->ReleaseScriptObject(obj, arg_type);
			}
			if (success < 0) {
				aCtx->SetException(format("Angelscript error %d while setting argument %u in async call to %s", success, i + 1, std::string(func->GetDeclaration())).c_str());
				engine->ReturnContext(ctx);
				return false;
			}
		}
		if (defCtx) engine->ReturnContext(defCtx);
		// Finally our context is actually prepared for execution, which will take place in the thread we're about to spin up.
		duplicate(); // Insure that this object won't get destroyed while the function is executing encase the user chose not to keep a handle to the async_result.
		try {
			if (pool) pool->start(*this);
			else {
				task = angelscript_refcounted_factory<Thread>();
				task->start(*this);
			}
		} catch (...) {
			engine->ReturnContext(ctx);
			release();
			throw;
		}
		return true;
	}
	void run() {
		int result = ctx->Execute();
		if (result == asEXECUTION_ABORTED) exception = "function call aborted";
		else if (result == asEXECUTION_SUSPENDED) exception = "function call suspended";
		else if (result == asEXECUTION_EXCEPTION) exception = ctx->GetExceptionString();
		else if (result == asEXECUTION_FINISHED && subtypeid != asTYPEID_VOID) {
			// Looking at and being heavily enspired from the scriptgrid addon as I write this.
			if (subtypeid & asTYPEID_MASK_OBJECT) value = malloc(sizeof(asPWORD));
			else value = malloc(ctx->GetEngine()->GetSizeOfPrimitiveType(subtypeid));
			if ((subtypeid & ~asTYPEID_MASK_SEQNBR) && !(subtypeid & asTYPEID_OBJHANDLE)) *(void**)value = ctx->GetEngine()->CreateScriptObjectCopy(ctx->GetReturnObject(), subtype->GetSubType());
			else if (subtypeid & asTYPEID_OBJHANDLE) {
				void* tmp = value;
				*(void**)value = ctx->GetReturnObject();
				ctx->GetEngine()->AddRefScriptObject(*(void**)value, subtype->GetSubType());
				if (tmp) ctx->GetEngine()->ReleaseScriptObject(*(void**)tmp, subtype->GetSubType());
			} else if (subtypeid == asTYPEID_BOOL || subtypeid == asTYPEID_INT8 || subtypeid == asTYPEID_UINT8) *(char*)value = ctx->GetReturnByte();
			else if (subtypeid == asTYPEID_INT16 || subtypeid == asTYPEID_UINT16) *(short*)value = ctx->GetReturnWord();
			else if (subtypeid == asTYPEID_INT32 || subtypeid == asTYPEID_UINT32 || subtypeid > asTYPEID_DOUBLE) *(int*)value = ctx->GetReturnDWord();
			else if (subtypeid == asTYPEID_FLOAT) *(float*)value = ctx->GetReturnFloat();
			else if (subtypeid == asTYPEID_INT64 || subtypeid == asTYPEID_UINT64) *(double*)value = ctx->GetReturnQWord();
			else if (subtypeid == asTYPEID_DOUBLE) *(double*)value = ctx->GetReturnDouble();
		}
		ctx->GetEngine()->ReturnContext(ctx);
		release_value_args();
		release();
		progress.set();
	}
	void release_value_args() {
		for (const auto& obj : value_args) g_ScriptEngine->ReleaseScriptObject(obj.first, obj.second);
		value_args.clear();
	}
	bool complete() { return ctx && progress.tryWait(0); }
	bool failed() { return progress.tryWait(0) && exception != ""; }
};
async_result* async_unprepared_factory(asITypeInfo* type) { return new async_result(type); }
void async_factory(asIScriptGeneric* gen) {
	asITypeInfo* ti = *(asITypeInfo**)gen->GetAddressOfArg(0);
	async_result* r = new async_result(ti);
	if (!r->call(gen)) delete r;
	else *(async_result**)gen->GetAddressOfReturnLocation() = r;
}

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
		ctx->Execute(); // Todo: Work out what we want to do with exceptions or errors that take place in threads.
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

// STL atomics support (thanks @ethindp)!
template <class T, typename... A> void atomics_construct(void* mem, A... args) {
	new (mem) T(args...);
}
template <class T> void atomics_destruct(T* obj) {
	obj->~T();
}
template<typename T> bool is_always_lock_free(T* obj) {
	return obj->is_always_lock_free;
}
template<typename atomic_type, typename divisible_type> void register_atomic_type(asIScriptEngine* engine, const std::string& type_name, const std::string& regular_type_name) {
	// The following functions are available on all atomic types
	engine->RegisterObjectType(type_name.c_str(), sizeof(atomic_type), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<atomic_type>());
	engine->RegisterObjectBehaviour(type_name.c_str(), asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(atomics_construct<atomic_type>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type_name.c_str(), asBEHAVE_DESTRUCT, "void f()", asFUNCTION(atomics_destruct<atomic_type>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(type_name.c_str(), "bool is_lock_free()", asMETHODPR(atomic_type, is_lock_free, () const noexcept, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("void store(%s val, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name).c_str(), asMETHODPR(atomic_type, store, (divisible_type, std::memory_order) noexcept, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opAssign(%s val)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator=, (divisible_type) noexcept, divisible_type), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s load(memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name).c_str(), asMETHODPR(atomic_type, load, (std::memory_order) const noexcept, divisible_type), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opImplConv()", regular_type_name).c_str(), asMETHODPR(atomic_type, operator divisible_type, () const noexcept, divisible_type), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s exchange(%s desired, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, exchange, (divisible_type, std::memory_order) noexcept, divisible_type), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool compare_exchange_weak(%s& expected, %s desired, memory_order success, memory_order failure)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, compare_exchange_weak, (divisible_type&, divisible_type, std::memory_order, std::memory_order) noexcept, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool compare_exchange_weak(%s& expected, %s desired, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, compare_exchange_weak, (divisible_type&, divisible_type, std::memory_order) noexcept, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool compare_exchange_strong(%s& expected, %s desired, memory_order success, memory_order failure)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, compare_exchange_strong, (divisible_type&, divisible_type, std::memory_order, std::memory_order) noexcept, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool compare_exchange_strong(%s& expected, %s desired, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, compare_exchange_strong, (divisible_type&, divisible_type, std::memory_order) noexcept, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), Poco::format("void wait(%s old, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name).c_str(), asMETHODPR(atomic_type, wait, (divisible_type, std::memory_order) const noexcept, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), "void notify_one()", asMETHODPR(atomic_type, notify_one, () noexcept, void), asCALL_THISCALL);
	engine->RegisterObjectMethod(type_name.c_str(), "void notify_all()", asMETHODPR(atomic_type, notify_all, () noexcept, void), asCALL_THISCALL);
	// Begin type-specific atomics
	if constexpr((std::is_integral_v<divisible_type> || std::is_floating_point_v<divisible_type>) && !std::is_same_v<divisible_type, bool>) {
		engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_add(%s arg, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_add, (divisible_type, std::memory_order) noexcept, divisible_type), asCALL_THISCALL);
		engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_sub(%s arg, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_sub, (divisible_type, std::memory_order) noexcept, divisible_type), asCALL_THISCALL);
		#ifdef __cpp_lib_atomic_min_max // Only available in C++26 mode or later
		if constexpr(std::is_integral_v<divisible_type>) {
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_max(%s arg, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_max, (divisible_type, std::memory_order) noexcept, divisible_type), asCALL_THISCALL);
		engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_min(%s arg, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_min, (divisible_type, std::memory_order) noexcept, divisible_type), asCALL_THISCALL);
	}
		#endif
		engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opAddAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator+=, (divisible_type) noexcept, divisible_type), asCALL_THISCALL);
		engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opSubAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator-=, (divisible_type) noexcept, divisible_type), asCALL_THISCALL);
		if constexpr(std::is_integral_v<divisible_type>) {
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPreInc()", regular_type_name).c_str(), asMETHODPR(atomic_type, operator++, () noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPostInc(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator++, (int) noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPreDec()", regular_type_name).c_str(), asMETHODPR(atomic_type, operator--, () noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPostDec(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator--, (int) noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_and(%s arg, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_and, (divisible_type, std::memory_order) noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_or(%s arg, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_or, (divisible_type, std::memory_order) noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_xor(%s arg, memory_order order = MEMORY_ORDER_SEQ_CST)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_xor, (divisible_type, std::memory_order) noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opAndAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator&=, (divisible_type) noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opOrAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator|=, (divisible_type) noexcept, divisible_type), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opXorAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator^=, (divisible_type) noexcept, divisible_type), asCALL_THISCALL);
		}
	}
	engine->RegisterObjectMethod(type_name.c_str(), "bool get_is_always_lock_free() property", asFUNCTION(is_always_lock_free<atomic_type>), asCALL_CDECL_OBJFIRST);
}

void RegisterAtomics(asIScriptEngine* engine) {
	// Memory order
	engine->RegisterEnum("memory_order");
	engine->RegisterEnumValue("memory_order", "MEMORY_ORDER_RELAXED", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_relaxed));
	engine->RegisterEnumValue("memory_order", "MEMORY_ORDER_ACQUIRE", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_acquire));
	engine->RegisterEnumValue("memory_order", "MEMORY_ORDER_RELEASE", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_release));
	engine->RegisterEnumValue("memory_order", "MEMORY_ORDER_ACQ_REL", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_acq_rel));
	engine->RegisterEnumValue("memory_order", "MEMORY_ORDER_SEQ_CST", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_seq_cst));
	// Atomic flag
	engine->RegisterObjectType("atomic_flag", sizeof(std::atomic_flag), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<std::atomic_flag>());
	engine->RegisterObjectBehaviour("atomic_flag", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(atomics_construct<std::atomic_flag>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour("atomic_flag", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(atomics_destruct<std::atomic_flag>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("atomic_flag", "bool test(memory_order order = MEMORY_ORDER_SEQ_CST) const", asMETHODPR(std::atomic_flag, test, (std::memory_order) const noexcept, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("atomic_flag", "void clear(memory_order order = MEMORY_ORDER_SEQ_CST)", asMETHODPR(std::atomic_flag, clear, (std::memory_order), void), asCALL_THISCALL);
	engine->RegisterObjectMethod("atomic_flag", "bool test_and_set(memory_order order = MEMORY_ORDER_SEQ_CST)", asMETHODPR(std::atomic_flag, test_and_set, (std::memory_order) noexcept, bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("atomic_flag", "void wait(bool old, memory_order order = MEMORY_ORDER_SEQ_CST) const", asMETHODPR(std::atomic_flag, wait, (bool, std::memory_order) const noexcept, void), asCALL_THISCALL);
	engine->RegisterObjectMethod("atomic_flag", "void notify_one()", asMETHOD(std::atomic_flag, notify_one), asCALL_THISCALL);
	engine->RegisterObjectMethod("atomic_flag", "void notify_all()", asMETHOD(std::atomic_flag, notify_all), asCALL_THISCALL);
	register_atomic_type<std::atomic_int, int>(engine, "atomic_int", "int");
	register_atomic_type<std::atomic_uint, unsigned int>(engine, "atomic_uint", "uint");
	register_atomic_type<std::atomic_int8_t, std::int8_t>(engine, "atomic_int8", "int8");
	register_atomic_type<std::atomic_uint8_t, std::uint8_t>(engine, "atomic_uint8", "uint8");
	register_atomic_type<std::atomic_int16_t, std::int16_t>(engine, "atomic_int16", "int16");
	register_atomic_type<std::atomic_uint16_t, std::uint16_t>(engine, "atomic_uint16", "uint16");
	register_atomic_type<std::atomic_int32_t, std::int32_t>(engine, "atomic_int32", "int32");
	register_atomic_type<std::atomic_uint32_t, std::uint32_t>(engine, "atomic_uint32", "uint32");
	register_atomic_type<std::atomic_int64_t, std::int64_t>(engine, "atomic_int64", "int64");
	register_atomic_type<std::atomic_uint64_t, std::uint64_t>(engine, "atomic_uint64", "uint64");
	register_atomic_type<std::atomic_bool, bool>(engine, "atomic_bool", "bool");
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
	engine->RegisterGlobalFunction(_O("bool thread_sleep(uint ms)"), asFUNCTION(Thread::trySleep), asCALL_CDECL);
	engine->RegisterGlobalFunction(_O("thread@+ get_thread_current() property"), asFUNCTION(Thread::current), asCALL_CDECL);
	engine->RegisterFuncdef(_O("void thread_callback(dictionary@ args)"));
	engine->RegisterObjectBehaviour(_O("thread"), asBEHAVE_FACTORY, _O("thread@ t()"), asFUNCTION(angelscript_refcounted_factory<Thread>), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("thread"), asBEHAVE_FACTORY, _O("thread@ t(const string&in name)"), asFUNCTION((angelscript_refcounted_factory<Thread, const std::string&>)), asCALL_CDECL);
	engine->RegisterObjectMethod(_O("thread"), _O("int get_id() const property"), asMETHOD(Thread, id), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("void set_priority(thread_priority priority) property"), asMETHOD(Thread, setPriority), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("thread_priority get_priority() const property"), asMETHOD(Thread, getPriority), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("void set_name(const string&in name) property"), asMETHOD(Thread, setName), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("string get_name() const property"), asMETHOD(Thread, getName), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("void join()"), asMETHODPR(Thread, join, (), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("bool join(uint ms)"), asMETHOD(Thread, tryJoin), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("bool get_running() const property"), asMETHOD(Thread, isRunning), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread"), _O("void start(thread_callback@ routine, dictionary@ args = null)"), asFUNCTION(thread_begin), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterObjectBehaviour("rw_scoped_lock", asBEHAVE_CONSTRUCT, "void f(rw_lock@ lock, bool write)", asFUNCTION(scoped_rw_lock_construct), asCALL_CDECL_OBJFIRST);
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
	engine->RegisterObjectBehaviour("thread_event", asBEHAVE_FACTORY, "thread_event@ e(thread_event_type type = THREAD_EVENT_AUTO_RESET)", asFUNCTION((angelscript_refcounted_factory<Event, Event::EventType>)), asCALL_CDECL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("void set()"), asMETHOD(Event, set), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("void wait()"), asMETHODPR(Event, wait, (), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("void wait(uint ms)"), asMETHODPR(Event, wait, (long), void), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("bool try_wait(uint ms)"), asMETHOD(Event, tryWait), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_event"), _O("void reset()"), asMETHOD(Event, reset), asCALL_THISCALL);
	angelscript_refcounted_register<ThreadPool>(engine, "thread_pool");
	engine->RegisterObjectBehaviour("thread_pool", asBEHAVE_FACTORY, format("thread_pool@ p(int min_capacity = 2, int max_capacity = 16, int idle_time = 60, int stack_size = %d)", POCO_THREAD_STACK_SIZE).c_str(), asFUNCTION((angelscript_refcounted_factory<ThreadPool, int, int, int, int>)), asCALL_CDECL);
	engine->RegisterObjectMethod("thread_pool", "void add_capacity(int modifier)", asMETHOD(ThreadPool, addCapacity), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_capacity() const property", asMETHOD(ThreadPool, capacity), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "void set_stack_size(int size) property", asMETHOD(ThreadPool, setStackSize), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_stack_size() const property", asMETHOD(ThreadPool, getStackSize), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_used() const property", asMETHOD(ThreadPool, used), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_allocated() const property", asMETHOD(ThreadPool, allocated), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "int get_available() const property", asMETHOD(ThreadPool, available), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("thread_pool"), _O("void start(thread_callback@ routine, dictionary@ args = null)"), asFUNCTIONPR(pooled_thread_begin, (ThreadPool*, asIScriptFunction*, CScriptDictionary*), void), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("thread_pool"), _O("void start(thread_callback@ routine, dictionary@ args, thread_priority priority)"), asFUNCTIONPR(pooled_thread_begin, (ThreadPool*, asIScriptFunction*, CScriptDictionary*, Thread::Priority), void), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("thread_pool"), _O("void start(thread_callback@ routine, dictionary@ args, const string&in name)"), asFUNCTIONPR(pooled_thread_begin, (ThreadPool*, asIScriptFunction*, CScriptDictionary*, const std::string&), void), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod(_O("thread_pool"), _O("void start(thread_callback@ routine, dictionary@ args, const string&in name, thread_priority priority)"), asFUNCTIONPR(pooled_thread_begin, (ThreadPool*, asIScriptFunction*, CScriptDictionary*, const std::string&, Thread::Priority), void), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectMethod("thread_pool", "void stop_all()", asMETHOD(ThreadPool, stopAll), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "void join_all()", asMETHOD(ThreadPool, joinAll), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "void collect()", asMETHOD(ThreadPool, collect), asCALL_THISCALL);
	engine->RegisterObjectMethod("thread_pool", "const string& get_name() const property", asMETHOD(ThreadPool, name), asCALL_THISCALL);
	engine->RegisterGlobalFunction(_O("thread_pool& get_thread_pool_default() property"), asFUNCTION(ThreadPool::defaultPool), asCALL_CDECL);
	engine->RegisterObjectType("async<class T>", 0, asOBJ_REF | asOBJ_TEMPLATE);
	engine->RegisterObjectBehaviour("async<T>", asBEHAVE_FACTORY, "async<T>@ f(int&in)", asFUNCTION(async_unprepared_factory), asCALL_CDECL);
	std::string filler; // It would seem for now that the best way is to register as many factories as we support number of arguments+1, for a couple of reasons too long to explain in a comment.
	for (int i = 0; i < 16; i++) {
		filler += "const ?&in";
		engine->RegisterObjectBehaviour("async<T>", asBEHAVE_FACTORY, std::string(std::string("async<T>@ f(int&in, ") + filler + ")").c_str(), asFUNCTION(async_factory), asCALL_GENERIC);
		filler += ", ";
	}
	engine->RegisterObjectBehaviour("async<T>", asBEHAVE_ADDREF, "void f()", asMETHODPR(async_result, duplicate, () const, void), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("async<T>", asBEHAVE_RELEASE, "void f()", asMETHODPR(async_result, release, () const, void), asCALL_THISCALL);
	engine->RegisterObjectMethod("async<T>", "const T& get_value() property", asMETHOD(async_result, get_value), asCALL_THISCALL);
	engine->RegisterObjectMethod("async<T>", "bool get_complete() const property", asMETHOD(async_result, complete), asCALL_THISCALL);
	engine->RegisterObjectMethod("async<T>", "bool get_failed() const property", asMETHOD(async_result, failed), asCALL_THISCALL);
	engine->RegisterObjectMethod("async<T>", "string get_exception() const property", asMETHOD(async_result, get_exception), asCALL_THISCALL);
	engine->RegisterObjectMethod("async<T>", "void wait()", asMETHOD(Event, wait), asCALL_THISCALL, 0, asOFFSET(async_result, progress), false);
	engine->RegisterObjectMethod("async<T>", "bool try_wait(uint ms)", asMETHOD(Event, tryWait), asCALL_THISCALL, 0, asOFFSET(async_result, progress), false);
	RegisterAtomics(engine);
}
