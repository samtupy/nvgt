/* events.h - event broadcasting system header
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

#include <angelscript.h>
#include <weakref.h>
#include <SDL3/SDL_touch.h>
#include <string>
#include <vector>
#include <angelscript_call.hpp>
#include "nvgt.h"

// DO not instanciate manually, instances are created by engine_event.
class engine_event;
class engine_event_listener {
	CScriptWeakRef* obj;
	asIScriptFunction* func;
	bool is_object;
public:
	engine_event_listener(asIScriptObject* obj, const engine_event* parent);
	engine_event_listener(asIScriptFunction* func);
	~engine_event_listener();
	template<typename... Args> bool fire(Args&&... args);
	bool good() const;
	bool operator==(const engine_event_listener& other) const;
};
class engine_event {
	std::vector<engine_event_listener> listeners;
	std::string name, type, args;
	asSFuncPtr fire_func; // Set by children so they don't need to override angelscript_register.
	void clean_inactive_listeners();
	bool insert(const engine_event_listener& listener, int index);
protected:
	template <typename... Args> void fire(Args&... args) {
		clean_inactive_listeners();
		for (engine_event_listener& l : listeners) {
			if (l.fire(std::forward<Args>(args)...)) break;
		}
	}
	engine_event(const std::string& name, const std::string& type, const std::string& args, const asSFuncPtr& fire_func);
public:
	std::string callback_declaration() const; // Does not include return type (usually void or bool).
	int find(asIScriptObject* obj) const;
	int find(asIScriptFunction* func) const;
	int find(const engine_event_listener& listener) const;
	bool insert(asIScriptObject* obj, int index = -1);
	bool insert(asIScriptFunction* func, int index = -1);
	bool operator+=(asIScriptObject* obj) { return insert(obj); }
	bool operator+=(asIScriptFunction* func) { return insert(func); }
	bool remove(asIScriptObject* obj);
	bool remove(asIScriptFunction* func);
	bool remove(unsigned int index);
	bool operator-=(asIScriptObject* obj) { return  remove(obj); }
	bool operator-=(asIScriptFunction* func) { return remove(func); }
	void clear();
	unsigned int count() const;
	void angelscript_register(asIScriptEngine* engine, engine_event* global_address);
};

// Must be in the header because of being a template.
template<typename... Args> inline bool engine_event_listener::fire(Args&&... args) {
	void* obj_strong = obj? obj->Get() : nullptr;
	if (obj && !obj_strong || !func) return false; // Object this listener belongs to has died or we have no calling function.
	asIScriptContext* ACtx = asGetActiveContext();
	bool new_context = ACtx == NULL || ACtx->PushState() < 0;
	asIScriptContext* ctx = (new_context ? g_ScriptEngine->RequestContext() : ACtx);
	if (!ctx) {
		if (obj_strong) obj->GetRefType()->GetEngine()->ReleaseScriptObject(obj_strong, obj->GetRefType());
		throw std::runtime_error(Poco::format("engine_event::fire %s acquire context fail", std::string(func->GetDeclaration())));
	}
	if (ctx->Prepare(func) < 0) {
		new_context? g_ScriptEngine->ReturnContext(ctx) : (void)ctx->PopState();
		if (obj_strong) obj->GetRefType()->GetEngine()->ReleaseScriptObject(obj_strong, obj->GetRefType());
		throw std::runtime_error(Poco::format("engine_event::fire %s context prepare fail", std::string(func->GetDeclaration())));
	}
	if (obj_strong) ctx->SetObject(obj_strong);
	bool ret = false; // pass to next event.
	if (func->GetReturnTypeId() == asTYPEID_VOID) angelscript_call(ctx, std::forward<Args>(args)...);
	else ret = angelscript_call<bool>(ctx, std::forward<Args>(args)...);
	new_context? g_ScriptEngine->ReturnContext(ctx) : (void)ctx->PopState();
	if (obj_strong) obj->GetRefType()->GetEngine()->ReleaseScriptObject(obj_strong, obj->GetRefType());
	return ret;
}


class engine_key_event : public engine_event {
public:
	engine_key_event(const std::string& name) : engine_event(name, "key", "int key", asMETHOD(engine_key_event, operator())) {}
	void operator()(int key) { fire<int>(key); }
};
class engine_mouse_event : public engine_event {
public:
	engine_mouse_event(const std::string& name) : engine_event(name, "mouse", "int button", asMETHOD(engine_mouse_event, operator())) {}
	void operator()(int button) { fire<int>(button); }
};
class engine_character_event : public engine_event {
public:
	engine_character_event(const std::string& name) : engine_event(name, "character", "string character", asMETHOD(engine_key_event, operator())) {}
	void operator()(std::string character) { fire<std::string>(character); }
};
class engine_touch_event : public engine_event {
public:
	engine_touch_event(const std::string& name) : engine_event(name, "touch", "uint64 device, const touch_finger& finger", asMETHOD(engine_touch_event, operator())) {}
	void operator()(Uint64 device, const SDL_Finger& finger) { fire<Uint64, const SDL_Finger&>(device, finger); }
};
class engine_touch_motion_event : public engine_event {
public:
	engine_touch_motion_event(const std::string& name) : engine_event(name, "touch_motion", "uint64 device, const touch_finger& finger, float relative_x, float relative_y", asMETHOD(engine_touch_motion_event, operator())) {}
	void operator()(Uint64 device, const SDL_Finger& finger, float relative_x, float relative_y) { fire<Uint64, const SDL_Finger&, float, float>(device, finger, relative_x, relative_y); }
};

// Event externs.
extern engine_key_event on_key_press;
extern engine_key_event on_key_repeat;
extern engine_key_event on_key_release;
extern engine_character_event on_characters;
extern engine_touch_event on_touch_finger_down;
extern engine_touch_event on_touch_finger_up;
extern engine_touch_motion_event on_touch_finger_move;
extern engine_touch_event on_touch_finger_cancel;

void RegisterEvents(asIScriptEngine* engine);
