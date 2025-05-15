#include "posix.h"
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
	g_return_val_if_fail( (!parent) || GTK_IS_WINDOW(parent),	"" );
	g_return_val_if_fail( !title.empty(),						"" );
	g_return_val_if_fail( !prompt.empty(),					   "" );
	if (!gtk_init_check()) return "";
	GtkWindow* win = GTK_WINDOW(gtk_window_new());
	assert(win);
	gtk_window_set_title	 (win, title.c_str());
	gtk_window_set_modal	 (win, TRUE);
	gtk_window_set_transient_for(win, parent);
	gtk_window_set_destroy_with_parent(win, TRUE);
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
	gtk_widget_set_can_focus (GTK_WIDGET(b_ok), TRUE);
	gtk_window_set_default_widget (GTK_WINDOW(win), GTK_WIDGET(b_ok));
	gtk_widget_add_css_class (GTK_WIDGET(b_ok), "suggested-action");
	gtk_box_append			(vbox, GTK_WIDGET(b_ok));
	auto *b_cancel = GTK_BUTTON(gtk_button_new_with_mnemonic("_Cancel"));
	assert(b_cancel);
	gtk_widget_set_can_focus   (GTK_WIDGET(b_cancel), TRUE);
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
	gtk_window_destroy(win);
	return data.result;
}

[[nodiscard]] bool posix_info_box(GtkWindow*		 parent, std::string const& title, std::string const& prompt, std::string const& text) {
	g_return_val_if_fail( (!parent) || GTK_IS_WINDOW(parent), FALSE );
	g_return_val_if_fail( !title.empty(),					   FALSE );
	g_return_val_if_fail( !prompt.empty(),					 FALSE );
	g_return_val_if_fail( !text.empty(),					   FALSE );
	if (!gtk_init_check()) return "";
	GtkWindow* win = GTK_WINDOW(gtk_window_new());
	assert(win);
	gtk_window_set_title	 (win, title.c_str());
	gtk_window_set_modal	 (win, TRUE);
	gtk_window_set_transient_for(win, parent);
	gtk_window_set_destroy_with_parent(win, TRUE);
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
	gtk_widget_set_can_focus(GTK_WIDGET(b_close), TRUE);
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
	gtk_window_destroy(win);
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
