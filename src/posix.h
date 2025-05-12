#pragma once
#include <gtk/gtk.h>
#include <string>

[[nodiscard]] std::string posix_input_box(GtkWindow*         parent, std::string const& title, std::string const& prompt, std::string const& default_text = "", bool secure = false);
[[nodiscard]] bool posix_info_box(GtkWindow*         parent, std::string const& title, std::string const& prompt, std::string const& text);
