/* win.h - header exposing windows only functions and classes
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
#include "tts.h"
#include <sapibridge.h>

class sapi5_engine : public tts_engine_impl {
	sb_sapi *inst;
public:
	sapi5_engine();
	virtual ~sapi5_engine();
	virtual bool is_available() override;
	virtual tts_pcm_generation_state get_pcm_generation_state() override;
	virtual tts_audio_data* speak_to_pcm(const std::string &text) override;
	virtual float get_rate() override;
	virtual float get_pitch() override;
	virtual float get_volume() override;
	virtual void set_rate(float rate) override;
	virtual void set_pitch(float pitch) override;
	virtual void set_volume(float volume) override;
	virtual bool get_rate_range(float& minimum, float& midpoint, float& maximum) override;
	virtual bool get_pitch_range(float& minimum, float& midpoint, float& maximum) override;
	virtual bool get_volume_range(float& minimum, float& midpoint, float& maximum) override;
	virtual int get_voice_count() override;
	virtual std::string get_voice_name(int index) override;
	virtual std::string get_voice_language(int index) override;
	virtual bool set_voice(int voice) override;
	virtual int get_current_voice() override;
};

