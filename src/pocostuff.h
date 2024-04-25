/* pocostuff.h - header for wrapping various parts of the Poco c++ libraries
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

#include <angelscript.h>
#include <Poco/Format.h>

// Not sure if this should be in another header, if I use this for more than Poco I may consider it. I'm so tired of trying to decide whether to register angelscript types as value or reference. I'm always turned away from reference types because well, the classes I want to wrap have no reference counter. Look maybe this could have been done with c++ multiple inheritance or something, but my brain is tired of learning new concepts for the moment and so hopefully this is portable enough to make better later. Following are methods for attaching a reference counter to any class for registration with angelscript as a reference type.
struct angelscript_refcounted {
	int refcount;
	int magic; // Verification encase a pointer of the objects type tries to get passed to the script, if this value doesn't match in memory we can return null or something, or even better create one of these structures so that the object could be supported?
};
template <class T> inline void* angelscript_refcounted_create() {
	angelscript_refcounted* rc = (angelscript_refcounted*) malloc(sizeof(angelscript_refcounted) + sizeof(T)); // We don't use the new operator here because we don't want the constructor of the containing object to fire until the user's factory function.
	rc->refcount = 1;
	rc->magic = 0x1234abcd;
	return (char*)rc + sizeof(angelscript_refcounted);
}
inline angelscript_refcounted* angelscript_refcounted_get(void* obj) {
	angelscript_refcounted* rc = reinterpret_cast<angelscript_refcounted*>((char*)obj - sizeof(angelscript_refcounted));
	if (rc->magic != 0x1234abcd) return NULL; // This pointer didn't originate from our factory.
	return rc;
}
template <class T> void angelscript_refcounted_duplicate(void* obj) {
	angelscript_refcounted* rc = angelscript_refcounted_get(obj);
	if (rc) asAtomicInc(rc->refcount);
}
template <class T> void angelscript_refcounted_release(T* obj) {
	angelscript_refcounted* rc = angelscript_refcounted_get(obj);
	if (!rc) return;
	if (asAtomicDec(rc->refcount) < 1) {
		obj->~T(); // Since we created the refcounted structure with malloc in order to manually call object's constructor, we need to manually call the destructor as well.
		free(rc);
	}
}
template <class T1, class T2> T2* angelscript_refcounted_refcast(T1* obj) {
	T2* obj_casted = dynamic_cast<T2>(obj);
	if (!obj_casted) return NULL;
	angelscript_refcounted_duplicate(obj);
	return obj_casted;
}
template <class T> inline void angelscript_refcounted_register(asIScriptEngine* engine, const char* type, const char* parent = NULL) {
	engine->RegisterObjectType(type, 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(type, asBEHAVE_ADDREF, "void f()", asFUNCTION(angelscript_refcounted_duplicate<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type, asBEHAVE_RELEASE, "void f()", asFUNCTION(angelscript_refcounted_release<T>), asCALL_CDECL_OBJFIRST);
}

void RegisterPocostuff(asIScriptEngine* engine);
