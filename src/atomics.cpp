/* atomics.cpp - Integration of STL atomics
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

#include "atomics.h"
#include <atomic>
#include <new>
#include <angelscript.h>
#include <cstdint>
#include <cstddef>
#include <type_traits>
#include <Poco/Format.h>
#include <string>
#include <cassert>
#include "angelscript.h"

template <class T, typename... A> void atomics_construct(void* mem, A... args) {
new (mem) T(args...);
}

template <class T> void atomics_destruct(T* obj) {
obj->~T();
}

template<typename T>
bool is_always_lock_free(T* obj) {
return obj->is_always_lock_free;
}

template<typename atomic_type, typename divisible_type>
void register_atomic_type(asIScriptEngine* engine, const std::string& type_name, const std::string& regular_type_name) {
// The following functions are available on all atomic types
int r = 0;
r = engine->RegisterObjectType(type_name.c_str(), sizeof(atomic_type), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<atomic_type>()); assert (r >= 0);
r = engine->RegisterObjectBehaviour(type_name.c_str(), asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(atomics_construct<atomic_type>), asCALL_CDECL_OBJFIRST); assert (r >= 0);
r = engine->RegisterObjectBehaviour(type_name.c_str(), asBEHAVE_DESTRUCT, "void f()", asFUNCTION(atomics_destruct<atomic_type>), asCALL_CDECL_OBJFIRST); assert (r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), "bool is_lock_free()", asMETHODPR(atomic_type, is_lock_free, () const volatile noexcept, bool), asCALL_THISCALL); assert (r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("void store(%s val, memory_order order = memory_order_seq_cst)", regular_type_name).c_str(), asMETHODPR(atomic_type, store, (divisible_type, std::memory_order) volatile noexcept, void), asCALL_THISCALL); assert (r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opAssign(%s val)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator=, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s load(memory_order order = memory_order_seq_cst)", regular_type_name).c_str(), asMETHODPR(atomic_type, load, (std::memory_order) const volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opImplConv()", regular_type_name).c_str(), asMETHODPR(atomic_type, operator divisible_type, () const volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s exchange(%s desired, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, exchange, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert (r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool compare_exchange_weak(%s& expected, %s desired, memory_order success, memory_order failure)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, compare_exchange_weak, (divisible_type&, divisible_type, std::memory_order, std::memory_order) volatile noexcept, bool), asCALL_THISCALL); assert (r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool compare_exchange_weak(%s& expected, %s desired, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, compare_exchange_weak, (divisible_type&, divisible_type, std::memory_order) volatile noexcept, bool), asCALL_THISCALL); assert (r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool compare_exchange_strong(%s& expected, %s desired, memory_order success, memory_order failure)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, compare_exchange_strong, (divisible_type&, divisible_type, std::memory_order, std::memory_order) volatile noexcept, bool), asCALL_THISCALL); assert (r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool compare_exchange_strong(%s& expected, %s desired, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, compare_exchange_strong, (divisible_type&, divisible_type, std::memory_order) volatile noexcept, bool), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("void wait(%s old, memory_order order = memory_order_seq_cst)", regular_type_name).c_str(), asMETHODPR(atomic_type, wait, (divisible_type, std::memory_order) const volatile noexcept, void), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), "void notify_one()", asMETHODPR(atomic_type, notify_one, () volatile noexcept, void), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), "void notify_all()", asMETHODPR(atomic_type, notify_all, () volatile noexcept, void), asCALL_THISCALL); assert(r >= 0);
// Begin type-specific atomics
if constexpr(std::is_integral_v<divisible_type>) {
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_add(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_add, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_sub(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_sub, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
#ifdef __cpp_lib_atomic_min_max // Only available in C++26 mode or later
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_max(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_max, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_min(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_min, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
#endif
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opAddAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator+=, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opSubAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator-=, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPreInc()", regular_type_name).c_str(), asMETHODPR(atomic_type, operator++, () volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPostInc(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator++, (int) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPreDec()", regular_type_name).c_str(), asMETHODPR(atomic_type, operator--, () volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPostDec(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator--, (int) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_and(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_and, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_or(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_or, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_xor(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_xor, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opAndAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator&=, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opOrAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator|=, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opXorAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator^=, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
} else if constexpr (std::is_floating_point_v<divisible_type>) {
#if defined(__STDCPP_FLOAT32_T__) && defined(__STDCPP_FLOAT64_T__) // C++23 mode or later required
static_assert(std::disjunction_v<std::float32_t, std::float64_t> != std::false_type, "Must specify either std::float32_t or std::float64_t when instantiating floating-point atomics classes");
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_add(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_add, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_sub(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_sub, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
#ifdef __cpp_lib_atomic_min_max // Only available in C++26 mode or later
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_max(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_max, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s fetch_min(%s arg, memory_order order = memory_order_seq_cst)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, fetch_min, (divisible_type, std::memory_order) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
#endif
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opAddAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator+=, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opSubAssign(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator-=, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPreInc()", regular_type_name).c_str(), asMETHODPR(atomic_type, operator++, () volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPostInc(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator++, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name.c_str(), Poco::format("%s opPreDec()", regular_type_name).c_str(), asMETHODPR(atomic_type, operator--, () volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
r = engine->RegisterObjectMethod(type_name..c_str(), Poco::format("%s opPostDec(%s arg)", regular_type_name, regular_type_name).c_str(), asMETHODPR(atomic_type, operator--, (divisible_type) volatile noexcept, divisible_type), asCALL_THISCALL); assert(r >= 0);
#else
static_assert(0, "Floating-point atomics are not supported on this implementation");
#endif
}
r = engine->RegisterObjectMethod(type_name.c_str(), "bool get_is_always_lock_free() property", asFUNCTION(is_always_lock_free<atomic_type>), asCALL_CDECL_OBJFIRST); ShowAngelscriptMessages(); assert(r >= 0);
}

void register_atomics(asIScriptEngine* engine) {
// Memory order
engine->RegisterEnum("memory_order");
engine->RegisterEnumValue("memory_order", "memory_order_relaxed", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_relaxed));
engine->RegisterEnumValue("memory_order", "memory_order_consume", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_consume));
engine->RegisterEnumValue("memory_order", "memory_order_acquire", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_acquire));
engine->RegisterEnumValue("memory_order", "memory_order_release", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_release));
engine->RegisterEnumValue("memory_order", "memory_order_acq_rel", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_acq_rel));
engine->RegisterEnumValue("memory_order", "memory_order_seq_cst", static_cast<std::underlying_type_t<std::memory_order>>(std::memory_order_seq_cst));
// Atomic flag
engine->RegisterObjectType("atomic_flag", sizeof(std::atomic_flag), asOBJ_VALUE | asOBJ_POD | asGetTypeTraits<std::atomic_flag>());
engine->RegisterObjectBehaviour("atomic_flag", asBEHAVE_CONSTRUCT, "void f()", asFUNCTION(atomics_construct<std::atomic_flag>), asCALL_CDECL_OBJFIRST);
engine->RegisterObjectBehaviour("atomic_flag", asBEHAVE_DESTRUCT, "void f()", asFUNCTION(atomics_destruct<std::atomic_flag>), asCALL_CDECL_OBJFIRST);
engine->RegisterObjectMethod("atomic_flag", "bool test(memory_order order = memory_order_seq_cst)", asMETHODPR(std::atomic_flag, test, (std::memory_order) const volatile noexcept, bool), asCALL_THISCALL);
engine->RegisterObjectMethod("atomic_flag", "void clear(memory_order order = memory_order_seq_cst)", asMETHODPR(std::atomic_flag, clear, (std::memory_order), void), asCALL_THISCALL);
engine->RegisterObjectMethod("atomic_flag", "bool test_and_set(memory_order order = memory_order_seq_cst)", asMETHODPR(std::atomic_flag, test_and_set, (std::memory_order) volatile noexcept, bool), asCALL_THISCALL);
engine->RegisterObjectMethod("atomic_flag", "void wait(bool old, memory_order order = memory_order_seq_cst)", asMETHODPR(std::atomic_flag, wait, (bool, std::memory_order) const volatile noexcept, void), asCALL_THISCALL);
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
#if defined(__STDCPP_FLOAT32_T__) && defined(__STDCPP_FLOAT64_T__) // C++23 mode or later required
register_atomic_type<std::atomic<std::float32_t>, std::float32_t>(engine, "atomic_float", "float");
register_atomic_type<std::atomic<std::float64_t>, std::float64_t>(engine, "atomic_float", "double");
#endif
}
