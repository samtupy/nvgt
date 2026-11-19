/* nodes.cpp - Steam Audio's HRTF panner and attenuator, and phonon_binaural_node
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

#define NVGT_PLUGIN_INCLUDE
#include "../../src/nvgt_plugin.h"
#include <algorithm>
#include <atomic>
#include <stdexcept>
#include "../../src/sound_nodes.h"
#include "phonon.h"

using namespace std;

int g_phonon_hrtf_panner = -1, g_phonon_attenuator = -1;

// Steam Audio's binaural effect, spatializing a sound by the direction to it from the listener, blended to the unspatialized sound within 5 meters of the listener.
class phonon_panner : public audio_plugin_spatializer_component_interface {
	ipl_ref<api::IBinauralEffect> effect;
	IPLBinauralEffectParams effect_params{};
	ipl_buffer input, output;
public:
	phonon_panner(audio_engine* engine) {
		api::IContext* ctx = phonon_context();
		IPLAudioSettings settings = phonon_audio_settings();
		IPLBinauralEffectSettings effect_settings{reinterpret_cast<IPLHRTF>(phonon_hrtf())};
		if (ctx->createBinauralEffect(&settings, &effect_settings, effect.put()) != IPL_STATUS_SUCCESS) throw runtime_error("Failed to create binaural effect");
		if (!input.allocate(ctx, engine->get_channels(), settings.frameSize) || !output.allocate(ctx, 2, settings.frameSize)) throw runtime_error("Failed to allocate audio buffers");
		effect_params.interpolation = IPL_HRTFINTERPOLATION_NEAREST;
		effect_params.hrtf = effect_settings.hrtf;
	}
	void process(const audio_spatialization_parameters& params, const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		const float fully_spatialized_distance = 5.0f;
		effect_params.direction = {params.listener_direction_x * params.directional_attenuation_factor, params.listener_direction_y * params.directional_attenuation_factor, params.listener_direction_z * params.directional_attenuation_factor};
		effect_params.spatialBlend = clamp(params.listener_distance * params.directional_attenuation_factor / fully_spatialized_distance, 0.0f, 1.0f);
		api::IContext* ctx = phonon_context();
		const unsigned int frames = min(*frame_count_in, *frame_count_out), frame_size = phonon_audio_settings().frameSize, channels = input.b.numChannels;
		for (unsigned int offset = 0; offset < frames; offset += frame_size) {
			input.b.numSamples = output.b.numSamples = min(frame_size, frames - offset);
			ctx->deinterleaveAudioBuffer(const_cast<float*>(frames_in[0]) + offset * channels, &input.b);
			effect->apply(&effect_params, &input.b, &output.b);
			ctx->interleaveAudioBuffer(&output.b, frames_out[0] + offset * 2);
		}
	}
};
static spatializer_component_node* create_phonon_panner(audio_spatializer* spatializer, audio_engine* engine) {
	if (!phonon_init()) return nullptr;
	try {
		return nvgt_audio_spatializer_component_create(new phonon_panner(engine), spatializer, engine, 0, 2);
	} catch (exception&) {
		return nullptr;
	}
}

// Steam Audio's inverse distance attenuation and air absorption. The distance is scaled by the sound's rolloff, so that a rolloff of 1 attenuates about as much as the other attenuators.
static float phonon_attenuation(const audio_spatialization_parameters& params, float distance) {
	if (distance > params.max_distance) return params.min_volume;
	return clamp(1.0f / max(distance * params.rolloff * 0.7f, max(params.min_distance, 0.0001f)), params.min_volume, params.max_volume);
}
class phonon_attenuator : public audio_plugin_spatializer_component_interface {
	ipl_ref<api::IDirectEffect> effect;
	IPLDirectEffectParams effect_params{};
	ipl_buffer input, output;
public:
	phonon_attenuator(audio_engine* engine) {
		api::IContext* ctx = phonon_context();
		IPLAudioSettings settings = phonon_audio_settings();
		IPLDirectEffectSettings effect_settings{engine->get_channels()};
		if (ctx->createDirectEffect(&settings, &effect_settings, effect.put()) != IPL_STATUS_SUCCESS) throw runtime_error("Failed to create direct effect");
		if (!input.allocate(ctx, engine->get_channels(), settings.frameSize) || !output.allocate(ctx, engine->get_channels(), settings.frameSize)) throw runtime_error("Failed to allocate audio buffers");
		effect_params.flags = (IPLDirectEffectFlags)(IPL_DIRECTEFFECTFLAGS_APPLYDISTANCEATTENUATION | IPL_DIRECTEFFECTFLAGS_APPLYAIRABSORPTION);
		effect_params.directivity = 1.0f;
	}
	void process(const audio_spatialization_parameters& params, const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		api::IContext* ctx = phonon_context();
		const float scale = params.rolloff * 0.7f;
		IPLAirAbsorptionModel air{};
		air.type = IPL_AIRABSORPTIONTYPE_DEFAULT;
		ctx->calculateAirAbsorption({params.sound_x * scale, params.sound_y * scale, params.sound_z * scale}, {params.listener_x * scale, params.listener_y * scale, params.listener_z * scale}, &air, effect_params.airAbsorption);
		effect_params.distanceAttenuation = phonon_attenuation(params, params.listener_distance);
		const unsigned int frames = min(*frame_count_in, *frame_count_out), frame_size = phonon_audio_settings().frameSize, channels = input.b.numChannels;
		for (unsigned int offset = 0; offset < frames; offset += frame_size) {
			input.b.numSamples = output.b.numSamples = min(frame_size, frames - offset);
			ctx->deinterleaveAudioBuffer(const_cast<float*>(frames_in[0]) + offset * channels, &input.b);
			effect->apply(&effect_params, &input.b, &output.b);
			ctx->interleaveAudioBuffer(&output.b, frames_out[0] + offset * channels);
		}
	}
};
static spatializer_component_node* create_phonon_attenuator(audio_spatializer* spatializer, audio_engine* engine) {
	if (!phonon_init()) return nullptr;
	try {
		return nvgt_audio_spatializer_component_create(new phonon_attenuator(engine), spatializer, engine, 0, 0);
	} catch (exception&) {
		return nullptr;
	}
}

// Steam Audio's binaural effect as an audio node a script points in a direction itself. The node owns this object, and scripts hold references to the node through it.
class phonon_binaural_node : public audio_plugin_node_interface {
	ipl_ref<api::IBinauralEffect> effect;
	IPLAudioSettings settings;
	ipl_buffer input, output;
	int input_channels; // The engine's channels are downmixed to this many before the effect.
	atomic<float> direction_x = 0.0f, direction_y = 0.0f, direction_z = 0.0f, spatial_blend = 0.0f, spatial_blend_max_distance = 4.0f;
public:
	plugin_node* node = nullptr;
	phonon_binaural_node(audio_engine* engine, int channels, int sample_rate, int frame_size) : input_channels(channels) {
		if (channels < 1 || channels > 2) throw invalid_argument("phonon_binaural_node only supports mono and stereo input");
		if (!phonon_init()) throw runtime_error("Steam Audio could not be initialized");
		api::IContext* ctx = phonon_context();
		settings = {sample_rate, frame_size ? frame_size : phonon_audio_settings().frameSize};
		IPLBinauralEffectSettings effect_settings{reinterpret_cast<IPLHRTF>(phonon_hrtf())};
		if (ctx->createBinauralEffect(&settings, &effect_settings, effect.put()) != IPL_STATUS_SUCCESS || !input.allocate(ctx, channels, settings.frameSize) || !output.allocate(ctx, 2, settings.frameSize)) throw runtime_error("phonon_binaural_node was not created");
		node = nvgt_audio_plugin_node_create(this, 1, 1, 0, engine);
		if (!node) throw runtime_error("phonon_binaural_node was not created");
	}
	void on_node_destroyed(plugin_node* destroyed) override { delete this; }
	void process(audio_plugin_node_interface* self, const float** frames_in, unsigned int* frame_count_in, float** frames_out, unsigned int* frame_count_out) override {
		IPLBinauralEffectParams params{};
		params.direction = {direction_x, direction_y, direction_z};
		params.interpolation = IPL_HRTFINTERPOLATION_NEAREST;
		params.spatialBlend = spatial_blend;
		params.hrtf = reinterpret_cast<IPLHRTF>(phonon_hrtf());
		api::IContext* ctx = phonon_context();
		const unsigned int engine_channels = node->get_engine()->get_channels(), frames = min(*frame_count_in, *frame_count_out);
		for (unsigned int offset = 0; offset < frames; offset += settings.frameSize) {
			const unsigned int n = min<unsigned int>(settings.frameSize, frames - offset);
			input.b.numSamples = output.b.numSamples = n;
			const float* in = frames_in[0] + offset * engine_channels;
			for (unsigned int i = 0; i < n; i++) {
				if (input_channels == 1) {
					float sum = 0.0f;
					for (unsigned int c = 0; c < engine_channels; c++) sum += in[i * engine_channels + c];
					input.b.data[0][i] = sum / engine_channels;
				} else for (int c = 0; c < 2; c++) input.b.data[c][i] = in[i * engine_channels + min<unsigned int>(c, engine_channels - 1)];
			}
			effect->apply(&params, &input.b, &output.b);
			float* out = frames_out[0] + offset * engine_channels;
			for (unsigned int i = 0; i < n; i++) for (unsigned int c = 0; c < engine_channels; c++) out[i * engine_channels + c] = c < 2 ? output.b.data[c][i] : 0.0f;
		}
	}
	void set_direction(float x, float y, float z, float distance) {
		direction_x = x;
		direction_y = y;
		direction_z = z;
		spatial_blend = spatial_blend_max_distance > 0 ? min(distance / spatial_blend_max_distance, 1.0f) : 1.0f;
	}
	void set_direction_vector(const vector3& direction, float distance) { set_direction(direction.GetX(), direction.GetY(), direction.GetZ(), distance); }
	void set_spatial_blend_max_distance(float distance) { spatial_blend_max_distance = distance; }
	static phonon_binaural_node* create(audio_engine* engine, int channels, int sample_rate, int frame_size) {
		try {
			return new phonon_binaural_node(engine ? engine : phonon_default_engine(), channels, sample_rate, frame_size);
		} catch (exception& e) {
			if (asIScriptContext* ctx = asGetActiveContext()) ctx->SetException(e.what());
			return nullptr;
		}
	}
	// References from scripts are references to the node.
	void add_ref() { node->duplicate(); }
	void release() { node->release(); }
	audio_node* get_node() {
		node->duplicate();
		return node;
	}
};

void RegisterPhononNodes(asIScriptEngine* engine) {
	g_phonon_hrtf_panner = nvgt_register_audio_panner(create_phonon_panner, true);
	g_phonon_attenuator = nvgt_register_audio_attenuator(create_phonon_attenuator, true, phonon_attenuation);
	engine->RegisterGlobalProperty("const int audio_panner_phonon_hrtf", &g_phonon_hrtf_panner); // Values can't be added to NVGT's audio_panner and audio_attenuator enums from a plugin's configuration group, but the functions selecting them take ints.
	engine->RegisterGlobalProperty("const int audio_attenuator_phonon", &g_phonon_attenuator);
	engine->RegisterObjectType("phonon_binaural_node", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("phonon_binaural_node", asBEHAVE_FACTORY, "phonon_binaural_node@ n(audio_engine@+ engine, int channels, int sample_rate, int frame_size = 0)", asFUNCTION(phonon_binaural_node::create), asCALL_CDECL);
	engine->RegisterObjectBehaviour("phonon_binaural_node", asBEHAVE_ADDREF, "void f()", asMETHOD(phonon_binaural_node, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("phonon_binaural_node", asBEHAVE_RELEASE, "void f()", asMETHOD(phonon_binaural_node, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("phonon_binaural_node", "audio_node@ get_node() property", asMETHOD(phonon_binaural_node, get_node), asCALL_THISCALL);
	engine->RegisterObjectMethod("phonon_binaural_node", "audio_node@ opImplCast()", asMETHOD(phonon_binaural_node, get_node), asCALL_THISCALL);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_direction(float x, float y, float z, float distance)", asMETHOD(phonon_binaural_node, set_direction), asCALL_THISCALL);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_direction(const vector&in direction, float distance)", asMETHOD(phonon_binaural_node, set_direction_vector), asCALL_THISCALL);
	engine->RegisterObjectMethod("phonon_binaural_node", "void set_spatial_blend_max_distance(float max_distance)", asMETHOD(phonon_binaural_node, set_spatial_blend_max_distance), asCALL_THISCALL);
}
