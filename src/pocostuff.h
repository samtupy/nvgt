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
template <class T> struct angelscript_refcounted {
	T obj;
	int magic; // Verification encase a pointer of the objects type tries to get passed to the script, if this value doesn't match in memory we can return null or something, or even better create one of these structures so that the object could be supported?
	int refcount;
	bool keep; // If this is set to true then the release function shouldn't destroy the object upon 0 refcount.
};
template <class T> inline void* angelscript_refcounted_create(bool keep = false) {
	angelscript_refcounted<T>* rc = (angelscript_refcounted<T>*) malloc(sizeof(angelscript_refcounted<T>)); // We don't use the new operator here because we don't want the constructor of the containing object to fire until the user's factory function.
	rc->refcount = 1;
	rc-> keep = keep;
	rc->magic = 0x1234abcd;
	return &rc->obj;
}
template <class T> inline angelscript_refcounted<T>* angelscript_refcounted_get(void* obj) {
	angelscript_refcounted<T>* rc = reinterpret_cast<angelscript_refcounted<T>*>(obj); // Since obj is the first member of the angelscript_refcounted structure, we should be able to cast this pointer to that structure's type to get the refcount.
	if(rc->magic != 0x1234abcd) return NULL; // This pointer didn't originate from our factory.
	return rc;
}
template <class T> void angelscript_refcounted_duplicate(void* obj) {
	angelscript_refcounted<T>* rc = angelscript_refcounted_get<T>(obj);
	if(rc) asAtomicInc(rc->refcount);
}
template <class T> void angelscript_refcounted_release(void* obj) {
	angelscript_refcounted<T>* rc = angelscript_refcounted_get<T>(obj);
	if(!rc) return;
	if(asAtomicDec(rc->refcount)<1) {
		rc->obj.~T(); // Since we created the refcounted structure with malloc in order to manually call object's constructor, we need to manually call the destructor as well.
		free(obj);
	}
}
template <class T> inline void angelscript_refcounted_register(asIScriptEngine* engine, const char* type, const char* parent = NULL) {
	engine->RegisterObjectType(type, 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(type, asBEHAVE_ADDREF, "void f()", asFUNCTION(angelscript_refcounted_duplicate<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type, asBEHAVE_RELEASE, "void f()", asFUNCTION(angelscript_refcounted_release<T>), asCALL_CDECL_OBJFIRST);
}

void RegisterPocostuff(asIScriptEngine* engine);
