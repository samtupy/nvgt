/* linux.h - header containing functions only applicable to Linux and Unix platforms
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

#pragma once
#include <string>
#include "tts.h"
#if !defined(__ANDROID__) && (defined(__linux__) || defined(__unix__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__))
#include <gtk/gtk.h>
#include <libspeechd.h>
#endif

bool screen_reader_is_speaking();

class speechd_engine : public tts_engine_impl {
	void* connection;
public:
	speechd_engine();
	virtual ~speechd_engine();
	virtual bool is_available() override;
	virtual bool speak(const std::string &text, bool interrupt = false, bool blocking = false) override;
	virtual bool is_speaking() override;
	virtual bool stop() override;
};

[[nodiscard]] std::string posix_input_box(GtkWindow*         parent, std::string const& title, std::string const& prompt, std::string const& default_text = "", bool secure = false);
[[nodiscard]] bool posix_info_box(GtkWindow*         parent, std::string const& title, std::string const& prompt, std::string const& text);
