/* linux.cpp - module containing functions only applicable to Linux and Unix platforms
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#if !defined(__ANDROID__) && (defined(__linux__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__))
#include "linux.h"
#include "tts.h"
#include <memory>
#include <Poco/SharedLibrary.h>
#include <stdexcept>
#include <cassert>
#ifndef _GNU_SOURCE
	#define _GNU_SOURCE
#endif
#include <link.h>
#include <dlfcn.h>
#include <iostream>
#include <unistd.h>
#include <cstdlib>
#include <SDL3/SDL_messagebox.h>
#include <Poco/Format.h>
#include <libspeechd.h>

using namespace std;

speechd_engine::speechd_engine() : tts_engine_impl("Speech Dispatcher"), connection(nullptr) {
	const auto *addr = spd_get_default_address(nullptr);
	if (!addr) return;
	connection = spd_open2("NVGT", nullptr, nullptr, SPD_MODE_THREADED, addr, true, nullptr);
	if (!connection) return;
}

speechd_engine::~speechd_engine() {
	if (connection) {
		spd_close((SPDConnection*)connection);
		connection = nullptr;
	}
}

bool speechd_engine::is_available() { return connection != nullptr; }

bool speechd_engine::speak(const std::string &text, bool interrupt, bool blocking) {
	if (!is_available() || text.empty()) return false;
	if (interrupt) {
		spd_stop((SPDConnection*)connection);
		spd_cancel((SPDConnection*)connection);
	}
	return spd_say((SPDConnection*)connection, interrupt ? SPD_IMPORTANT : SPD_TEXT, text.c_str()) >= 0;
}

bool speechd_engine::is_speaking() { return false; }

bool speechd_engine::stop() {
	if (!is_available()) return false;
	spd_cancel((SPDConnection*)connection);
	spd_stop((SPDConnection*)connection);
	return true;
}

bool screen_reader_is_speaking() { return false; }

void register_native_tts() { tts_engine_register("speechd", []() -> shared_ptr<tts_engine> { return make_shared<speechd_engine>(); }); }

static tts_voice* g_screen_reader_voice = nullptr;

bool screen_reader_load() {
	if (g_screen_reader_voice) return true;
	g_screen_reader_voice = new tts_voice("speechd");
	return g_screen_reader_voice != nullptr && g_screen_reader_voice->get_voice_count() > 0;
}

void screen_reader_unload() {
	if (g_screen_reader_voice) {
		g_screen_reader_voice->Release();
		g_screen_reader_voice = nullptr;
	}
}

std::string screen_reader_detect() {
	if (!screen_reader_load()) return "";
	return g_screen_reader_voice->get_voice_count() > 0 ? "Speech Dispatcher" : "";
}

bool screen_reader_has_speech() {
	if (!screen_reader_load()) return false;
	return g_screen_reader_voice->get_voice_count() > 0;
}

bool screen_reader_has_braille() { return false; }

bool screen_reader_output(const std::string& text, bool interrupt) {
	if (!screen_reader_load()) return false;
	return g_screen_reader_voice->speak(text, interrupt);
}

bool screen_reader_speak(const std::string& text, bool interrupt) {
	if (!screen_reader_load()) return false;
	return g_screen_reader_voice->speak(text, interrupt);
}

bool screen_reader_braille(const std::string& text) { return false; }

bool screen_reader_silence() {
	if (!screen_reader_load()) return false;
	return g_screen_reader_voice->stop();
}

struct input_data {
	GMainLoop*  loop;
	GtkWindow*  win;
	GtkEntry*   entry;
	std::string result;
};

struct info_data {
	GMainLoop*  loop;
	GtkWindow*  win;
};

static void on_ok(GtkButton*, gpointer ud) {
	assert(ud);
	auto *d = static_cast<input_data*>(ud);
	auto* buffer = gtk_entry_get_buffer(d->entry);
	const char* t = gtk_entry_buffer_get_text(buffer);
	if (const auto len = gtk_entry_buffer_get_length(buffer); len > 0)
		d->result.assign(t, len);
	else
		d->result.clear();
	g_main_loop_quit(d->loop);
}

static void on_cancel(GtkButton*, gpointer ud) {
	assert(ud);
	auto *d = static_cast<input_data*>(ud);
	d->result.clear();
	g_main_loop_quit(d->loop);
}

static void on_close(GtkButton*, gpointer ud) {
	assert(ud);
	auto *d = static_cast<info_data*>(ud);
	g_main_loop_quit(d->loop);
}

[[nodiscard]] std::string posix_input_box(GtkWindow*		 parent, std::string const& title, std::string const& prompt, std::string const& default_text, bool secure) {
	g_return_val_if_fail( (!parent) || GTK_IS_WINDOW(parent),	"\xff" );
	g_return_val_if_fail( !title.empty(),						"\xff" );
	g_return_val_if_fail( !prompt.empty(),					   "\xff" );
	if (!gtk_init_check()) return "\xff";
	GtkWindow* win = GTK_WINDOW(gtk_window_new());
	assert(win);
	gtk_window_set_title	 (win, title.c_str());
	gtk_window_set_modal	 (win, TRUE);
	gtk_window_set_transient_for(win, parent);
	auto *vbox = GTK_BOX(gtk_box_new(GTK_ORIENTATION_VERTICAL, 8));
	assert(vbox);
	gtk_widget_set_margin_top   (GTK_WIDGET(vbox),  12);
	gtk_widget_set_margin_bottom(GTK_WIDGET(vbox),  12);
	gtk_widget_set_margin_start (GTK_WIDGET(vbox),  12);
	gtk_widget_set_margin_end   (GTK_WIDGET(vbox),  12);
	gtk_window_set_child(win, GTK_WIDGET(vbox));
	auto *lbl = GTK_LABEL(gtk_label_new(prompt.c_str()));
	assert(lbl);
	gtk_label_set_xalign(lbl, 0.0);
	gtk_label_set_wrap  (lbl, TRUE);
	gtk_box_append	  (vbox, GTK_WIDGET(lbl));
	auto *ent = GTK_ENTRY(gtk_entry_new());
	assert(ent);
	gtk_entry_set_max_length	   (ent, 0);
	auto* buffer = gtk_entry_get_buffer(ent);
	assert(buffer);
	gtk_entry_buffer_set_text(buffer, default_text.c_str(), default_text.size());
	auto hints = static_cast<GtkInputHints>(GTK_INPUT_HINT_SPELLCHECK | GTK_INPUT_HINT_WORD_COMPLETION | GTK_INPUT_HINT_EMOJI);
	if (secure) {
		gtk_entry_set_input_purpose(ent, GTK_INPUT_PURPOSE_PASSWORD);
		hints = static_cast<GtkInputHints>(static_cast<int>(hints) | GTK_INPUT_HINT_PRIVATE);
	}
	gtk_entry_set_input_hints(ent, hints);
	gtk_entry_set_activates_default(ent, TRUE);
	gtk_box_append				 (vbox, GTK_WIDGET(ent));
	auto *b_ok = GTK_BUTTON(gtk_button_new_with_mnemonic("_OK"));
	assert(b_ok);
	gtk_widget_set_focusable (GTK_WIDGET(b_ok), TRUE);
	gtk_window_set_default_widget (GTK_WINDOW(win), GTK_WIDGET(b_ok));
	gtk_widget_add_css_class (GTK_WIDGET(b_ok), "suggested-action");
	gtk_box_append			(vbox, GTK_WIDGET(b_ok));
	auto *b_cancel = GTK_BUTTON(gtk_button_new_with_mnemonic("_Cancel"));
	assert(b_cancel);
	gtk_widget_set_focusable (GTK_WIDGET(b_cancel), TRUE);
	gtk_box_append			  (vbox, GTK_WIDGET(b_cancel));
	input_data data;
	data.loop  = g_main_loop_new(nullptr, FALSE);
	assert(data.loop );
	data.win   = win;
	data.entry = ent;
	g_signal_connect(b_ok,	 "clicked", G_CALLBACK(on_ok),	 &data);
	g_signal_connect(b_cancel, "clicked", G_CALLBACK(on_cancel), &data);
	gtk_widget_set_visible(GTK_WIDGET(vbox), TRUE);
	gtk_window_present(win);
	g_main_loop_run  (data.loop);
	g_main_loop_unref(data.loop);
	gtk_window_close(win);
	g_object_unref(win);
	return data.result;
}

[[nodiscard]] bool posix_info_box(GtkWindow*		 parent, std::string const& title, std::string const& prompt, std::string const& text) {
	g_return_val_if_fail( (!parent) || GTK_IS_WINDOW(parent), FALSE );
	g_return_val_if_fail( !title.empty(),					   FALSE );
	g_return_val_if_fail( !prompt.empty(),					 FALSE );
	g_return_val_if_fail( !text.empty(),					   FALSE );
	if (!gtk_init_check()) return false;
	GtkWindow* win = GTK_WINDOW(gtk_window_new());
	assert(win);
	gtk_window_set_title	 (win, title.c_str());
	gtk_window_set_modal	 (win, TRUE);
	gtk_window_set_transient_for(win, parent);
	auto *vbox = GTK_BOX(gtk_box_new(GTK_ORIENTATION_VERTICAL, 8));
	assert(vbox);
	gtk_widget_set_margin_top   (GTK_WIDGET(vbox),  12);
	gtk_widget_set_margin_bottom(GTK_WIDGET(vbox),  12);
	gtk_widget_set_margin_start (GTK_WIDGET(vbox),  12);
	gtk_widget_set_margin_end   (GTK_WIDGET(vbox),  12);
	gtk_window_set_child(win, GTK_WIDGET(vbox));
	auto *lbl = GTK_LABEL(gtk_label_new(prompt.c_str()));
	assert(lbl);
	gtk_label_set_xalign(lbl, 0.0);
	gtk_label_set_wrap  (lbl, TRUE);
	gtk_box_append	  (vbox, GTK_WIDGET(lbl));
	auto *sw = GTK_SCROLLED_WINDOW(gtk_scrolled_window_new());
	assert(sw);
	gtk_scrolled_window_set_policy(sw, GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);
	auto *tv = GTK_TEXT_VIEW(gtk_text_view_new());
	assert(tv);
	gtk_text_view_set_editable	  (tv, FALSE);
	gtk_text_view_set_cursor_visible(tv, FALSE);
	gtk_scrolled_window_set_child   (sw, GTK_WIDGET(tv));
	auto *buf = gtk_text_view_get_buffer(tv);
	assert(buf);
	gtk_text_buffer_set_text(buf, text.c_str(), text.size());
	gtk_box_append(vbox, GTK_WIDGET(sw));
	auto *b_close = GTK_BUTTON(gtk_button_new_with_mnemonic("_Close"));
	assert(b_close);
	gtk_widget_set_focusable (GTK_WIDGET(b_close), TRUE);
	gtk_box_append(vbox, GTK_WIDGET(b_close));
	info_data data;
	data.loop = g_main_loop_new(nullptr, FALSE);
	assert(data.loop);
	data.win  = win;
	g_signal_connect(b_close, "clicked", G_CALLBACK(on_close), &data);
	gtk_widget_set_visible(GTK_WIDGET(vbox), TRUE);
	gtk_window_present(win);
	g_main_loop_run  (data.loop);
	g_main_loop_unref(data.loop);
	gtk_window_close(win);
	g_object_unref(win);
	return true;
}

// These functions are for the dlopen/dlsym hooks in the arch-specific code
extern "C" {
void *nvgt_dlopen(const char *lib_name) {
auto* ptr = dlopen(lib_name, RTLD_NOW | RTLD_DEEPBIND);
if (!ptr)
if (isatty(fileno(stderr))) {
std::cerr << "Error: library loader could not load " << lib_name << "\n";
return nullptr;
} else {
const auto msg = Poco::format("Library loader could not load %s", std::string(lib_name));
SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", msg.c_str(), nullptr);
return nullptr;
}
return ptr;
}

void *nvgt_dlsym(void *handle, const char *sym_name) {
assert (handle);
assert(sym_name);
auto* ptr = dlsym(handle, sym_name);
if (!ptr) {
link_map *lm = NULL;
std::string libname;
if ((dlinfo(handle, RTLD_DI_LINKMAP, &lm) != 0 || lm == NULL) || (lm->l_name == NULL || lm->l_name[0] == '\0')) {
libname.clear();
}
libname = lm->l_name;
if (isatty(fileno(stderr))) {
std::cerr << Poco::format("Error: library loader could not find symbol %s in library %s\n", std::string(sym_name), libname.empty() ? "NVGT core" : std::string(libname));
return nullptr;
} else {
const auto msg = Poco::format("Library loader could not find symbol %s in library %s", sym_name, libname.empty() ? "NVGT core" : std::string(libname));
SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", msg.c_str(), nullptr);
return nullptr;
}
}
return ptr;
}
}

#endif
