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
#include <Poco/RefCountedObject.h>
#include <Poco/Dynamic/Var.h>
#include <Poco/JSON/Array.h>
#include <Poco/JSON/Object.h>

// I wonder if this is gonna be one of those things I'll look back at in a year and lament the fact that I couldn't have found a better way before spending the same amount of time then that I'm about to spend now finding a better way to wrap Poco's shared pointers in a simplistic enough way for real use. These SharedPtr's literally have reference counting that we can't use because the pointers' reference counter is private, and I'm not sure I can use Angelscript's composition features directly either because raw access to the underlying pointer is also private! Maybe I can specify my own reference counter when constructing these pointers (not sure I could count on that for all pointers being received), I could mess with Angelscript scoped reference types (not sure how the user could choose between assigning a new reference or value to a variable), and I could try using angelscripts opHndlAssign thing but based on the docs I would need to do more research to answer questions about that as well! So we're left with this, a duplicate reference counter and a duplicate copy of any raw pointer assigned just so that the user gets to type @my_var=handle vs. my_var=variable to deepcopy.
template <class T> class poco_shared : public Poco::RefCountedObject {
public:
	Poco::SharedPtr<T> shared;
	T* ptr;
	poco_shared(Poco::SharedPtr<T> shared) : shared(shared), ptr(shared.get()) {}
};

class datastream;
class poco_json_array;
class poco_json_object : public poco_shared<Poco::JSON::Object> {
public:
	poco_json_object(Poco::JSON::Object::Ptr o);
	poco_json_object(poco_json_object* other);
	poco_json_object& operator=(poco_json_object* other);
	poco_shared<Poco::Dynamic::Var>* get(const std::string& key, poco_shared<Poco::Dynamic::Var>* default_value = nullptr) const;
	poco_shared<Poco::Dynamic::Var>* get_indexed(const std::string& key) const;
	poco_shared<Poco::Dynamic::Var>* query(const std::string& path, poco_shared<Poco::Dynamic::Var>* default_value = nullptr) const;
	poco_json_array* get_array(const std::string& key) const;
	poco_json_object* get_object(const std::string& key) const;
	void set(const std::string& key, poco_shared<Poco::Dynamic::Var>* v);
	bool is_array(const std::string& key) const;
	bool is_null(const std::string& key) const;
	bool is_object(const std::string& key) const;
	std::string stringify(unsigned int indent = 0, int step = -1) const;
	void stringify(datastream* ds, unsigned int indent = 0, int step = -1) const;
	CScriptArray* get_keys() const;
};
class poco_json_array : public poco_shared<Poco::JSON::Array> {
public:
	poco_json_array(Poco::JSON::Array::Ptr a);
	poco_json_array(poco_json_array* other);
	poco_json_array& operator=(poco_json_array* other);
	poco_shared<Poco::Dynamic::Var>* get(unsigned int index) const;
	poco_shared<Poco::Dynamic::Var>* query(const std::string& path) const;
	poco_json_array& extend(poco_json_array* array);
	poco_json_array* get_array(unsigned int index) const;
	poco_json_object* get_object(unsigned int index) const;
	void set(unsigned int index, poco_shared<Poco::Dynamic::Var>* v);
	void add(poco_shared<Poco::Dynamic::Var>* v);
	bool is_array(unsigned int index) const;
	bool is_null(unsigned int index) const;
	bool is_object(unsigned int index) const;
	std::string stringify(unsigned int indent = 0, int step = -1) const;
	void stringify(datastream* ds, unsigned int indent = 0, int step = -1) const;
};

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
	T2* obj_casted = dynamic_cast<T2*>(obj);
	if (!obj_casted) return NULL;
	angelscript_refcounted_duplicate<T2>(obj);
	return obj_casted;
}
template <class T> inline void angelscript_refcounted_register(asIScriptEngine* engine, const char* type, const char* parent = NULL) {
	engine->RegisterObjectType(type, 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(type, asBEHAVE_ADDREF, "void f()", asFUNCTION(angelscript_refcounted_duplicate<T>), asCALL_CDECL_OBJFIRST);
	engine->RegisterObjectBehaviour(type, asBEHAVE_RELEASE, "void f()", asFUNCTION(angelscript_refcounted_release<T>), asCALL_CDECL_OBJFIRST);
}

// This is a template constructor that generally stops one from needing to create factory functions for each object that uses this angelscript_refcounted mechanism.
template <class T, typename... A> T* angelscript_refcounted_factory(A... args) { return new (angelscript_refcounted_create<T>()) T(args...); }
// And similarly, a common trait of value typed objects is returning new versions of themselves, so handle functions that do that here too.
template <class T, auto F, typename... A> T* angelscript_refcounted_duplicating_method(T* obj, A... args) { return new (angelscript_refcounted_create<T>()) T((obj->*F)(args...)); }

void RegisterPocostuff(asIScriptEngine* engine);
