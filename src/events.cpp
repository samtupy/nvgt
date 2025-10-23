/* events.cpp - Code for distributing various events from the engine E. on_key_press, on_window_focus, on_touch, etc.
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include <string>
#include <unordered_set>
#include <vector>
#include <Poco/Format.h>
#include "events.h"
#include "nvgt.h"
#include "nvgt_angelscript.h"

using namespace std::string_literals;

engine_event_listener::engine_event_listener(asIScriptObject* obj, const engine_event* parent) : obj(new CScriptWeakRef(obj, obj->GetObjectType()->GetModule()->GetTypeInfoByDecl(Poco::format("weakref<%s>", std::string(obj->GetObjectType()->GetName())).c_str()))), func(nullptr), is_object(true) {
	asITypeInfo* ot = obj->GetObjectType();
	if (ot) func = ot->GetMethodByDecl(("void "s + parent->callback_declaration()).c_str());
	if (!func && ot) func = ot->GetMethodByDecl(("bool "s + parent->callback_declaration()).c_str());
	if (!func) throw std::runtime_error(Poco::format("engine_event_listener instanciation for %s failed, no void/bool %s method", std::string(ot? ot->GetName() : "unknown"), parent->callback_declaration()));
}
engine_event_listener::engine_event_listener(asIScriptFunction* func) : obj(nullptr), func(func), is_object(false) {
	if (func->GetFuncType() == asFUNC_DELEGATE) {
		this->obj = new CScriptWeakRef(func->GetDelegateObject(), func->GetDelegateObjectType()->GetModule()->GetTypeInfoByDecl(Poco::format("weakref<%s>", std::string(func->GetDelegateObjectType()->GetName())).c_str()));
		this->func = func->GetDelegateFunction();
		func->Release();
	}
}
engine_event_listener::~engine_event_listener() {}
bool engine_event_listener::good() const {
	if (!obj && !func) return false;
	else if (!obj) return true; // Static functions are always available.
	void* obj_strong = obj->Get();
	if (!obj_strong) return false;
	obj->GetRefType()->GetEngine()->ReleaseScriptObject(obj_strong, obj->GetRefType());
	return true;
}
bool engine_event_listener::operator==(const engine_event_listener& other) const {
	return obj == other.obj && func == other.func;
}

std::unordered_set<std::string> g_engine_event_registered_types;

engine_event::engine_event(const std::string& name, const std::string& type, const std::string& args, const asSFuncPtr& fire_func) : name(name), type(type), args(args), fire_func(fire_func) {}
void engine_event::clean_inactive_listeners() {
	for (unsigned int i = 0; i < listeners.size(); i++) {
		if (listeners[i].good()) continue;
		listeners.erase(listeners.begin() + i);
		i--;
	}
}
bool engine_event::insert(const engine_event_listener& listener, int index = -1) {
	if (find(listener) > -1) return false;
	if (index == -1) index = listeners.size();
	listeners.insert(listeners.begin() + index, listener);
	return true;
}
std::string engine_event::callback_declaration() const { return "on_"s + name + "("s + args + ")"; }
int engine_event::find(asIScriptObject* obj) const { return find(engine_event_listener(obj, this)); }
int engine_event::find(asIScriptFunction* func) const { return find(engine_event_listener(func)); }
int engine_event::find(const engine_event_listener& listener) const {
	auto it = std::find(listeners.begin(), listeners.end(), listener);
	if (it == listeners.end()) return -1;
	return distance(listeners.begin(), it);
}
bool engine_event::insert(asIScriptObject* obj, int index) { return insert(engine_event_listener(obj, this), index); }
bool engine_event::insert(asIScriptFunction* func, int index) { return insert(engine_event_listener(func), index); }
bool engine_event::remove(asIScriptObject* obj) { return remove(find(obj)); }
bool engine_event::remove(asIScriptFunction* func) { return remove(find(func)); }
bool engine_event::remove(unsigned int index) {
	if (index >= listeners.size()) return false;
	listeners.erase(listeners.begin() + index);
	return true;
}
void engine_event::clear() { listeners.clear(); }
unsigned int engine_event::count() const { return listeners.size(); }
void engine_event::angelscript_register(asIScriptEngine* engine, engine_event* global_address) {
	std::string type_name = Poco::format("engine_%s_event", type);
	if (!g_engine_event_registered_types.contains(type)) {
		std::string listener_name = Poco::format("%s_listener", type_name);
		std::string callback_name = Poco::format("%s_callback", type_name);
		std::string passthrough_callback_name = Poco::format("%s_passthrough_callback", type_name);
		std::vector<std::string> listener_types = {listener_name, callback_name, passthrough_callback_name};
		engine->RegisterInterface(listener_name.c_str());
		engine->RegisterFuncdef(Poco::format("bool %s_callback(%s)", type_name, args).c_str());
		engine->RegisterFuncdef(Poco::format("void %s_passthrough_callback(%s)", type_name, args).c_str());
		engine->RegisterObjectType(type_name.c_str(), 0, asOBJ_REF | asOBJ_NOHANDLE);
		for (const std::string& t : listener_types) {
			bool is_interface = t == listener_name;
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("int find(%s@ listener) const", t).c_str(), is_interface? asMETHODPR(engine_event, find, (asIScriptObject*) const, int) : asMETHODPR(engine_event, find, (asIScriptFunction*) const, int), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool insert(%s@ listener, int index = -1)", t).c_str(), is_interface? asMETHODPR(engine_event, insert, (asIScriptObject*, int), bool) : asMETHODPR(engine_event, insert, (asIScriptFunction*, int), bool), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool opAddAssign(%s@ listener)", t).c_str(), is_interface? asMETHODPR(engine_event, operator+=, (asIScriptObject*), bool) : asMETHODPR(engine_event, operator+=, (asIScriptFunction*), bool), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool remove(%s@ listener)", t).c_str(), is_interface? asMETHODPR(engine_event, remove, (asIScriptObject*), bool) : asMETHODPR(engine_event, remove, (asIScriptFunction*), bool), asCALL_THISCALL);
			engine->RegisterObjectMethod(type_name.c_str(), Poco::format("bool opSubAssign(%s@ listener)", t).c_str(), is_interface? asMETHODPR(engine_event, operator-=, (asIScriptObject*), bool) : asMETHODPR(engine_event, operator-=, (asIScriptFunction*), bool), asCALL_THISCALL);
		}
		engine->RegisterObjectMethod(type_name.c_str(), "bool remove(uint index)", asMETHODPR(engine_event, remove, (unsigned int), bool), asCALL_THISCALL);
		engine->RegisterObjectMethod(type_name.c_str(), Poco::format("void opCall(%s)", args).c_str(), fire_func, asCALL_THISCALL);
		engine->RegisterObjectMethod(type_name.c_str(), "void clear()", asMETHOD(engine_event, clear), asCALL_THISCALL);
		engine->RegisterObjectMethod(type_name.c_str(), "uint get_count() const property", asMETHOD(engine_event, count), asCALL_THISCALL);
		g_engine_event_registered_types.insert(type);
	}
	if (global_address) engine->RegisterGlobalProperty(Poco::format("%s on_%s", type_name, name).c_str(), (void*)global_address);
}

// Event declarations
engine_key_event on_key_press("key_press");
engine_key_event on_key_repeat("key_repeat");
engine_key_event on_key_release("key_release");
engine_character_event on_characters("characters");
engine_touch_event on_touch_finger_down("touch_finger_down");
engine_touch_event on_touch_finger_up("touch_finger_up");
engine_touch_motion_event on_touch_finger_move("touch_finger_move");
engine_touch_event on_touch_finger_cancel("touch_finger_cancel");

void RegisterEvents(asIScriptEngine* engine) {
	on_key_press.angelscript_register(engine, &on_key_press);
	on_key_repeat.angelscript_register(engine, &on_key_repeat);
	on_key_release.angelscript_register(engine, &on_key_release);
	on_characters.angelscript_register(engine, &on_characters);
	on_touch_finger_down.angelscript_register(engine, &on_touch_finger_down);
	on_touch_finger_up.angelscript_register(engine, &on_touch_finger_up);
	on_touch_finger_move.angelscript_register(engine, &on_touch_finger_move);
	on_touch_finger_cancel.angelscript_register(engine, &on_touch_finger_cancel);
}
