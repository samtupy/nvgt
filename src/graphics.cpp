/* graphics.cpp - Classes and functions for graphics and other visual rendering features
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2026 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include "graphics.h"
#include "UI.h"
#include "nvgt_plugin.h"
std::string get_font_path(const std::string& name); // defined in xplatform.cpp

// graphic

graphic::graphic(SDL_Surface* surface) : _surface(surface), _refcount(1) {}

graphic::~graphic() {
	SDL_DestroySurface(_surface);
	_surface = nullptr;
}

unsigned int graphic::get_blend_mode() const {
	SDL_BlendMode mode = SDL_BLENDMODE_NONE;
	SDL_GetSurfaceBlendMode(_surface, &mode);
	return (unsigned int)mode;
}

bool graphic::get_color_mod(unsigned int& r, unsigned int& g, unsigned int& b) const {
	Uint8 rv, gv, bv;
	bool ok = SDL_GetSurfaceColorMod(_surface, &rv, &gv, &bv);
	r = rv; g = gv; b = bv;
	return ok;
}

unsigned int graphic::get_alpha_mod() const {
	Uint8 alpha = 255;
	SDL_GetSurfaceAlphaMod(_surface, &alpha);
	return (unsigned int)alpha;
}

graphic* load_bmp(const std::string& file) {
	SDL_Surface* s = SDL_LoadBMP(file.c_str());
	return s ? new graphic(s) : nullptr;
}

graphic* load_png(const std::string& file) {
	SDL_Surface* s = SDL_LoadPNG(file.c_str());
	return s ? new graphic(s) : nullptr;
}

graphic* load_surface(const std::string& file) {
	SDL_Surface* s = SDL_LoadSurface(file.c_str());
	return s ? new graphic(s) : nullptr;
}

graphic* create_surface(int width, int height, unsigned int pixel_format) {
	SDL_Surface* s = SDL_CreateSurface(width, height, (SDL_PixelFormat)pixel_format);
	return s ? new graphic(s) : nullptr;
}

graphics_texture::graphics_texture(SDL_Texture* texture) : _texture(texture), _refcount(1), _width(0), _height(0) {
	if (_texture) {
		float w, h;
		SDL_GetTextureSize(_texture, &w, &h);
		_width = (int)w;
		_height = (int)h;
	}
}

graphics_texture::~graphics_texture() {
	if (_texture) {
		SDL_DestroyTexture(_texture);
		_texture = nullptr;
	}
}

bool graphics_texture::set_color_mod(unsigned int r, unsigned int g, unsigned int b) {
	return SDL_SetTextureColorMod(_texture, (Uint8)r, (Uint8)g, (Uint8)b);
}

bool graphics_texture::get_color_mod(unsigned int& r, unsigned int& g, unsigned int& b) const {
	Uint8 rv, gv, bv;
	bool ok = SDL_GetTextureColorMod(_texture, &rv, &gv, &bv);
	r = rv; g = gv; b = bv;
	return ok;
}

bool graphics_texture::set_alpha_mod(unsigned int alpha) {
	return SDL_SetTextureAlphaMod(_texture, (Uint8)alpha);
}

unsigned int graphics_texture::get_alpha_mod() const {
	Uint8 alpha = 255;
	SDL_GetTextureAlphaMod(_texture, &alpha);
	return (unsigned int)alpha;
}

bool graphics_texture::set_blend_mode(unsigned int mode) {
	return SDL_SetTextureBlendMode(_texture, (SDL_BlendMode)mode);
}

unsigned int graphics_texture::get_blend_mode() const {
	SDL_BlendMode mode = SDL_BLENDMODE_NONE;
	SDL_GetTextureBlendMode(_texture, &mode);
	return (unsigned int)mode;
}

// text_font

text_font::text_font(const std::string& name, float size, unsigned int initial_style) : _font(nullptr), _refcount(1) {
	_font = TTF_OpenFont(get_font_path(name).c_str(), size);
	if (_font && initial_style != TTF_STYLE_NORMAL) TTF_SetFontStyle(_font, (TTF_FontStyleFlags)initial_style);
}

text_font::~text_font() {
	clear_fallback_fonts();
	if (_font) {
		TTF_CloseFont(_font);
		_font = nullptr;
	}
}

bool text_font::add_fallback_font(text_font* font) {
	if (!font || !font->_font) return false;
	font->duplicate();
	_fallback_fonts.push_back(font);
	return TTF_AddFallbackFont(_font, font->_font);
}

bool text_font::remove_fallback_font(text_font* font) {
	if (!font || !font->_font) return false;
	TTF_RemoveFallbackFont(_font, font->_font);
	for (auto it = _fallback_fonts.begin(); it != _fallback_fonts.end(); ++it) {
		if (*it == font) {
			_fallback_fonts.erase(it);
			font->release();
			return true;
		}
	}
	return false;
}

void text_font::clear_fallback_fonts() {
	TTF_ClearFallbackFonts(_font);
	for (text_font* f : _fallback_fonts) f->release();
	_fallback_fonts.clear();
}

bool text_font::get_dpi(int& hdpi, int& vdpi) const {
	return TTF_GetFontDPI(_font, &hdpi, &vdpi);
}

graphic* text_font::get_glyph_image(unsigned int ch) const {
	TTF_ImageType image_type;
	SDL_Surface* s = TTF_GetGlyphImage(_font, ch, &image_type);
	return s ? new graphic(s) : nullptr;
}

bool text_font::get_glyph_metrics(unsigned int ch, int& minx, int& maxx, int& miny, int& maxy, int& advance) const {
	return TTF_GetGlyphMetrics(_font, ch, &minx, &maxx, &miny, &maxy, &advance);
}

bool text_font::get_kerning_size(unsigned int prev_ch, unsigned int ch, int& kerning) const {
	return TTF_GetGlyphKerning(_font, prev_ch, ch, &kerning);
}

bool text_font::get_string_size(const std::string& text, int& w, int& h) const {
	return TTF_GetStringSize(_font, text.c_str(), text.size(), &w, &h);
}

bool text_font::get_string_size_wrapped(const std::string& text, int wrap_width, int& w, int& h) const {
	return TTF_GetStringSizeWrapped(_font, text.c_str(), text.size(), wrap_width, &w, &h);
}

bool text_font::measure_string(const std::string& text, int max_width, int& measured_width, int& measured_length) const {
	size_t len = 0;
	bool ok = TTF_MeasureString(_font, text.c_str(), text.size(), max_width, &measured_width, &len);
	measured_length = (int)len;
	return ok;
}

// font free functions

static std::unordered_map<std::string, text_font*> g_font_cache;

text_font* get_font(const std::string& name, float size, unsigned int initial_style, bool allow_caching) {
	if (allow_caching) {
		std::string key = name + "|" + std::to_string(size) + "|" + std::to_string(initial_style);
		auto it = g_font_cache.find(key);
		if (it != g_font_cache.end()) {
			it->second->duplicate();
			return it->second;
		}
		text_font* font = new text_font(name, size, initial_style);
		font->duplicate(); // held by cache
		g_font_cache[key] = font;
		return font; // refcount=2: one for cache, one for caller
	}
	return new text_font(name, size, initial_style);
}

unsigned int font_string_to_tag(const std::string& str) {
	return TTF_StringToTag(str.c_str());
}

std::string font_tag_to_string(unsigned int tag) {
	char buf[5] = {0};
	TTF_TagToString(tag, buf, 4);
	return std::string(buf, 4);
}

// graphics_renderer

graphics_renderer::graphics_renderer() : _renderer(nullptr), _refcount(1) {
	// Default renderer attaches to whichever window SDL currently considers the focused one, if any.
	SDL_Window* win = SDL_GetKeyboardFocus();
	if (win) _renderer = SDL_CreateRenderer(win, nullptr);
}

graphics_renderer::graphics_renderer(game_window* window) : _renderer(nullptr), _refcount(1) {
	if (window) _renderer = SDL_CreateRenderer(window->get_sdl_window(), nullptr);
}

graphics_renderer::~graphics_renderer() {
	if (_renderer) {
		SDL_DestroyRenderer(_renderer);
		_renderer = nullptr;
	}
}

bool graphics_renderer::get_draw_color(unsigned int& r, unsigned int& g, unsigned int& b, unsigned int& a) const {
	Uint8 rv, gv, bv, av;
	bool ok = SDL_GetRenderDrawColor(_renderer, &rv, &gv, &bv, &av);
	r = rv; g = gv; b = bv; a = av;
	return ok;
}

bool graphics_renderer::get_scale(float& sx, float& sy) const {
	return SDL_GetRenderScale(_renderer, &sx, &sy);
}

bool graphics_renderer::get_vsync(int& vsync) const {
	return SDL_GetRenderVSync(_renderer, &vsync);
}

float graphics_renderer::get_color_scale() const {
	float scale = 1.0f;
	SDL_GetRenderColorScale(_renderer, &scale);
	return scale;
}

unsigned int graphics_renderer::get_draw_blend_mode() const {
	SDL_BlendMode mode = SDL_BLENDMODE_NONE;
	SDL_GetRenderDrawBlendMode(_renderer, &mode);
	return (unsigned int)mode;
}

bool graphics_renderer::get_output_size(int& w, int& h) const {
	return SDL_GetRenderOutputSize(_renderer, &w, &h);
}

bool graphics_renderer::get_current_output_size(int& w, int& h) const {
	return SDL_GetCurrentRenderOutputSize(_renderer, &w, &h);
}

bool graphics_renderer::draw_rect(float x, float y, float w, float h) {
	SDL_FRect r = {x, y, w, h};
	return SDL_RenderRect(_renderer, &r);
}

bool graphics_renderer::fill_rect(float x, float y, float w, float h) {
	SDL_FRect r = {x, y, w, h};
	return SDL_RenderFillRect(_renderer, &r);
}

bool graphics_renderer::render_graphic(graphic* gfx, float dst_x, float dst_y) {
	if (!gfx || !gfx->get_surface()) return false;
	SDL_Texture* tex = SDL_CreateTextureFromSurface(_renderer, gfx->get_surface());
	if (!tex) return false;
	SDL_FRect dst = {dst_x, dst_y, (float)gfx->get_width(), (float)gfx->get_height()};
	bool ok = SDL_RenderTexture(_renderer, tex, nullptr, &dst);
	SDL_DestroyTexture(tex);
	return ok;
}

bool graphics_renderer::render_graphic_ex(graphic* gfx, float src_x, float src_y, float src_w, float src_h, float dst_x, float dst_y, float dst_w, float dst_h) {
	if (!gfx || !gfx->get_surface()) return false;
	SDL_Texture* tex = SDL_CreateTextureFromSurface(_renderer, gfx->get_surface());
	if (!tex) return false;
	SDL_FRect src = {src_x, src_y, src_w, src_h};
	SDL_FRect dst = {dst_x, dst_y, dst_w, dst_h};
	bool ok = SDL_RenderTexture(_renderer, tex, &src, &dst);
	SDL_DestroyTexture(tex);
	return ok;
}

graphics_texture* graphics_renderer::create_texture(graphic* gfx) {
	if (!gfx || !gfx->get_surface()) return nullptr;
	SDL_Texture* tex = SDL_CreateTextureFromSurface(_renderer, gfx->get_surface());
	return tex ? new graphics_texture(tex) : nullptr;
}

bool graphics_renderer::render_texture(graphics_texture* tex, float dst_x, float dst_y) {
	if (!tex || !tex->get_texture()) return false;
	SDL_FRect dst = {dst_x, dst_y, (float)tex->get_width(), (float)tex->get_height()};
	return SDL_RenderTexture(_renderer, tex->get_texture(), nullptr, &dst);
}

bool graphics_renderer::render_texture_ex(graphics_texture* tex, float src_x, float src_y, float src_w, float src_h, float dst_x, float dst_y, float dst_w, float dst_h) {
	if (!tex || !tex->get_texture()) return false;
	SDL_FRect src = {src_x, src_y, src_w, src_h};
	SDL_FRect dst = {dst_x, dst_y, dst_w, dst_h};
	return SDL_RenderTexture(_renderer, tex->get_texture(), &src, &dst);
}

bool graphics_renderer::set_logical_presentation(int w, int h, unsigned int mode) {
	return SDL_SetRenderLogicalPresentation(_renderer, w, h, (SDL_RendererLogicalPresentation)mode);
}

bool graphics_renderer::get_logical_presentation(int& w, int& h, unsigned int& mode) const {
	SDL_RendererLogicalPresentation m;
	bool ok = SDL_GetRenderLogicalPresentation(_renderer, &w, &h, &m);
	mode = (unsigned int)m;
	return ok;
}

bool graphics_renderer::set_viewport(int x, int y, int w, int h) {
	SDL_Rect r = {x, y, w, h};
	return SDL_SetRenderViewport(_renderer, &r);
}

bool graphics_renderer::get_viewport(int& x, int& y, int& w, int& h) const {
	SDL_Rect r;
	bool ok = SDL_GetRenderViewport(_renderer, &r);
	x = r.x; y = r.y; w = r.w; h = r.h;
	return ok;
}

bool graphics_renderer::set_clip_rect(int x, int y, int w, int h) {
	SDL_Rect r = {x, y, w, h};
	return SDL_SetRenderClipRect(_renderer, &r);
}

bool graphics_renderer::get_clip_rect(int& x, int& y, int& w, int& h) const {
	SDL_Rect r;
	bool ok = SDL_GetRenderClipRect(_renderer, &r);
	x = r.x; y = r.y; w = r.w; h = r.h;
	return ok;
}

static graphics_renderer* graphics_renderer_factory() { return new graphics_renderer(); }
static text_font* text_font_factory(const std::string& name, float size, unsigned int style) { return new text_font(name, size, style); }

void RegisterGraphics(asIScriptEngine* engine) {
	engine->SetDefaultAccessMask(NVGT_SUBSYSTEM_UI);
	// blend_mode enum (SDL_BlendMode)
	engine->RegisterEnum("blend_mode");
	engine->RegisterEnumValue("blend_mode", "BLEND_MODE_NONE", SDL_BLENDMODE_NONE);
	engine->RegisterEnumValue("blend_mode", "BLEND_MODE_BLEND", SDL_BLENDMODE_BLEND);
	engine->RegisterEnumValue("blend_mode", "BLEND_MODE_BLEND_PREMULTIPLIED", SDL_BLENDMODE_BLEND_PREMULTIPLIED);
	engine->RegisterEnumValue("blend_mode", "BLEND_MODE_ADD", SDL_BLENDMODE_ADD);
	engine->RegisterEnumValue("blend_mode", "BLEND_MODE_ADD_PREMULTIPLIED", SDL_BLENDMODE_ADD_PREMULTIPLIED);
	engine->RegisterEnumValue("blend_mode", "BLEND_MODE_MOD", SDL_BLENDMODE_MOD);
	engine->RegisterEnumValue("blend_mode", "BLEND_MODE_MUL", SDL_BLENDMODE_MUL);
	// flip_mode enum (SDL_FlipMode)
	engine->RegisterEnum("flip_mode");
	engine->RegisterEnumValue("flip_mode", "FLIP_NONE", SDL_FLIP_NONE);
	engine->RegisterEnumValue("flip_mode", "FLIP_HORIZONTAL", SDL_FLIP_HORIZONTAL);
	engine->RegisterEnumValue("flip_mode", "FLIP_VERTICAL", SDL_FLIP_VERTICAL);
	// pixel_format enum (SDL_PixelFormat, common subset)
	engine->RegisterEnum("pixel_format");
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_UNKNOWN", SDL_PIXELFORMAT_UNKNOWN);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_INDEX8", SDL_PIXELFORMAT_INDEX8);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_RGB24", SDL_PIXELFORMAT_RGB24);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_BGR24", SDL_PIXELFORMAT_BGR24);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_XRGB8888", SDL_PIXELFORMAT_XRGB8888);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_XBGR8888", SDL_PIXELFORMAT_XBGR8888);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_ARGB8888", SDL_PIXELFORMAT_ARGB8888);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_RGBA8888", SDL_PIXELFORMAT_RGBA8888);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_ABGR8888", SDL_PIXELFORMAT_ABGR8888);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_BGRA8888", SDL_PIXELFORMAT_BGRA8888);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_RGBA32", SDL_PIXELFORMAT_RGBA32);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_ARGB32", SDL_PIXELFORMAT_ARGB32);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_BGRA32", SDL_PIXELFORMAT_BGRA32);
	engine->RegisterEnumValue("pixel_format", "PIXELFORMAT_ABGR32", SDL_PIXELFORMAT_ABGR32);
	// renderer_logical_presentation enum (SDL_RendererLogicalPresentation)
	engine->RegisterEnum("renderer_logical_presentation");
	engine->RegisterEnumValue("renderer_logical_presentation", "LOGICAL_PRESENTATION_DISABLED", SDL_LOGICAL_PRESENTATION_DISABLED);
	engine->RegisterEnumValue("renderer_logical_presentation", "LOGICAL_PRESENTATION_STRETCH", SDL_LOGICAL_PRESENTATION_STRETCH);
	engine->RegisterEnumValue("renderer_logical_presentation", "LOGICAL_PRESENTATION_LETTERBOX", SDL_LOGICAL_PRESENTATION_LETTERBOX);
	engine->RegisterEnumValue("renderer_logical_presentation", "LOGICAL_PRESENTATION_OVERSCAN", SDL_LOGICAL_PRESENTATION_OVERSCAN);
	engine->RegisterEnumValue("renderer_logical_presentation", "LOGICAL_PRESENTATION_INTEGER_SCALE", SDL_LOGICAL_PRESENTATION_INTEGER_SCALE);
	// font_style flags (TTF_FontStyleFlags)
	engine->RegisterEnum("font_style");
	engine->RegisterEnumValue("font_style", "FONT_STYLE_NORMAL", TTF_STYLE_NORMAL);
	engine->RegisterEnumValue("font_style", "FONT_STYLE_BOLD", TTF_STYLE_BOLD);
	engine->RegisterEnumValue("font_style", "FONT_STYLE_ITALIC", TTF_STYLE_ITALIC);
	engine->RegisterEnumValue("font_style", "FONT_STYLE_UNDERLINE", TTF_STYLE_UNDERLINE);
	engine->RegisterEnumValue("font_style", "FONT_STYLE_STRIKETHROUGH", TTF_STYLE_STRIKETHROUGH);
	// font_hinting enum (TTF_HintingFlags)
	engine->RegisterEnum("font_hinting");
	engine->RegisterEnumValue("font_hinting", "FONT_HINTING_NORMAL", TTF_HINTING_NORMAL);
	engine->RegisterEnumValue("font_hinting", "FONT_HINTING_LIGHT", TTF_HINTING_LIGHT);
	engine->RegisterEnumValue("font_hinting", "FONT_HINTING_MONO", TTF_HINTING_MONO);
	engine->RegisterEnumValue("font_hinting", "FONT_HINTING_NONE", TTF_HINTING_NONE);
	engine->RegisterEnumValue("font_hinting", "FONT_HINTING_LIGHT_SUBPIXEL", TTF_HINTING_LIGHT_SUBPIXEL);
	// font_direction enum (TTF_Direction)
	engine->RegisterEnum("font_direction");
	engine->RegisterEnumValue("font_direction", "FONT_DIRECTION_LTR", TTF_DIRECTION_LTR);
	engine->RegisterEnumValue("font_direction", "FONT_DIRECTION_RTL", TTF_DIRECTION_RTL);
	engine->RegisterEnumValue("font_direction", "FONT_DIRECTION_TTB", TTF_DIRECTION_TTB);
	engine->RegisterEnumValue("font_direction", "FONT_DIRECTION_BTT", TTF_DIRECTION_BTT);
	// font_align enum (TTF_HorizontalAlignment)
	engine->RegisterEnum("font_align");
	engine->RegisterEnumValue("font_align", "FONT_ALIGN_LEFT", TTF_HORIZONTAL_ALIGN_LEFT);
	engine->RegisterEnumValue("font_align", "FONT_ALIGN_CENTER", TTF_HORIZONTAL_ALIGN_CENTER);
	engine->RegisterEnumValue("font_align", "FONT_ALIGN_RIGHT", TTF_HORIZONTAL_ALIGN_RIGHT);
	// graphic
	engine->RegisterObjectType("graphic", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("graphic", asBEHAVE_ADDREF, "void f()", asMETHOD(graphic, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("graphic", asBEHAVE_RELEASE, "void f()", asMETHOD(graphic, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "int get_width() const property", asMETHOD(graphic, get_width), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "int get_height() const property", asMETHOD(graphic, get_height), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "int get_pitch() const property", asMETHOD(graphic, get_pitch), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool get_is_valid() const property", asMETHOD(graphic, is_valid), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool lock()", asMETHOD(graphic, lock), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "void unlock()", asMETHOD(graphic, unlock), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool save_bmp(const string&in file) const", asMETHOD(graphic, save_bmp), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool save_png(const string&in file) const", asMETHOD(graphic, save_png), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool set_rle(bool enabled)", asMETHOD(graphic, set_rle), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool set_color_mod(uint r, uint g, uint b)", asMETHOD(graphic, set_color_mod), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool get_color_mod(uint&out r, uint&out g, uint&out b) const", asMETHOD(graphic, get_color_mod), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool set_alpha_mod(uint alpha)", asMETHOD(graphic, set_alpha_mod), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "uint get_alpha_mod() const", asMETHOD(graphic, get_alpha_mod), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool set_blend_mode(blend_mode mode)", asMETHOD(graphic, set_blend_mode), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "blend_mode get_blend_mode() const", asMETHOD(graphic, get_blend_mode), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "bool flip(flip_mode mode)", asMETHOD(graphic, flip), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "graphic@ convert(pixel_format pixel_format) const", asMETHOD(graphic, convert), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphic", "graphic@ duplicate() const", asMETHOD(graphic, duplicate_surface), asCALL_THISCALL);
	// graphic free functions
	engine->RegisterGlobalFunction("graphic@ load_bmp(const string&in file)", asFUNCTION(load_bmp), asCALL_CDECL);
	engine->RegisterGlobalFunction("graphic@ load_png(const string&in file)", asFUNCTION(load_png), asCALL_CDECL);
	engine->RegisterGlobalFunction("graphic@ load_surface(const string&in file)", asFUNCTION(load_surface), asCALL_CDECL);
	engine->RegisterGlobalFunction("graphic@ create_surface(int width, int height, pixel_format pixel_format)", asFUNCTION(create_surface), asCALL_CDECL);
	
	// graphics_texture
	engine->RegisterObjectType("graphics_texture", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("graphics_texture", asBEHAVE_ADDREF, "void f()", asMETHOD(graphics_texture, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("graphics_texture", asBEHAVE_RELEASE, "void f()", asMETHOD(graphics_texture, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "int get_width() const property", asMETHOD(graphics_texture, get_width), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "int get_height() const property", asMETHOD(graphics_texture, get_height), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "bool get_is_valid() const property", asMETHOD(graphics_texture, is_valid), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "bool set_color_mod(uint r, uint g, uint b)", asMETHOD(graphics_texture, set_color_mod), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "bool get_color_mod(uint&out r, uint&out g, uint&out b) const", asMETHOD(graphics_texture, get_color_mod), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "bool set_alpha_mod(uint alpha)", asMETHOD(graphics_texture, set_alpha_mod), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "uint get_alpha_mod() const", asMETHOD(graphics_texture, get_alpha_mod), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "bool set_blend_mode(blend_mode mode)", asMETHOD(graphics_texture, set_blend_mode), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_texture", "blend_mode get_blend_mode() const", asMETHOD(graphics_texture, get_blend_mode), asCALL_THISCALL);

	// text_font
	engine->RegisterObjectType("text_font", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("text_font", asBEHAVE_ADDREF, "void f()", asMETHOD(text_font, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("text_font", asBEHAVE_RELEASE, "void f()", asMETHOD(text_font, release), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("text_font", asBEHAVE_FACTORY, "text_font@ f(const string&in name, float size, uint style = FONT_STYLE_NORMAL)", asFUNCTION(text_font_factory), asCALL_CDECL);
	engine->RegisterObjectMethod("text_font", "uint get_generation() const property", asMETHOD(text_font, get_generation), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool add_fallback_font(text_font@+ font)", asMETHOD(text_font, add_fallback_font), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool remove_fallback_font(text_font@+ font)", asMETHOD(text_font, remove_fallback_font), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "void clear_fallback_fonts()", asMETHOD(text_font, clear_fallback_fonts), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool set_size(float ptsize)", asMETHOD(text_font, set_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "float get_size() const property", asMETHOD(text_font, get_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool set_size_dpi(float ptsize, int hdpi, int vdpi)", asMETHOD(text_font, set_size_dpi), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_dpi(int&out hdpi, int&out vdpi) const", asMETHOD(text_font, get_dpi), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "void set_style(uint style) property", asMETHOD(text_font, set_style), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "uint get_style() const property", asMETHOD(text_font, get_style), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool set_outline(int outline)", asMETHOD(text_font, set_outline), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "int get_outline() const property", asMETHOD(text_font, get_outline), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "int get_faces_count() const property", asMETHOD(text_font, get_faces_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool set_sdf(bool enabled)", asMETHOD(text_font, set_sdf), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_sdf() const property", asMETHOD(text_font, get_sdf), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "int get_weight() const property", asMETHOD(text_font, get_weight), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "void set_wrap_alignment(font_align alignment) property", asMETHOD(text_font, set_wrap_alignment), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "font_align get_wrap_alignment() const property", asMETHOD(text_font, get_wrap_alignment), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "int get_height() const property", asMETHOD(text_font, get_height), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "int get_ascent() const property", asMETHOD(text_font, get_ascent), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "int get_descent() const property", asMETHOD(text_font, get_descent), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "void set_line_skip(int skip) property", asMETHOD(text_font, set_line_skip), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "int get_line_skip() const property", asMETHOD(text_font, get_line_skip), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "void set_kerning(bool enabled) property", asMETHOD(text_font, set_kerning), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_kerning() const property", asMETHOD(text_font, get_kerning), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_is_fixed_width() const property", asMETHOD(text_font, is_fixed_width), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_is_scalable() const property", asMETHOD(text_font, is_scalable), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "string get_family_name() const property", asMETHOD(text_font, get_family_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "string get_style_name() const property", asMETHOD(text_font, get_style_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool set_direction(font_direction dir)", asMETHOD(text_font, set_direction), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "font_direction get_direction() const property", asMETHOD(text_font, get_direction), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool set_script(uint script)", asMETHOD(text_font, set_script), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "uint get_script() const property", asMETHOD(text_font, get_script), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool set_language(const string&in language_bcp47)", asMETHOD(text_font, set_language), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool has_glyph(uint codepoint)", asMETHOD(text_font, has_glyph), asCALL_THISCALL);
	// text_font render methods
	engine->RegisterObjectMethod("text_font", "graphic@ render_text_solid(const string&in text, uint r, uint g, uint b)", asMETHOD(text_font, render_text_solid), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_text_solid_wrapped(const string&in text, int wrap_width, uint r, uint g, uint b)", asMETHOD(text_font, render_text_solid_wrapped), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_text_blended(const string&in text, uint r, uint g, uint b)", asMETHOD(text_font, render_text_blended), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_text_blended_wrapped(const string&in text, int wrap_width, uint r, uint g, uint b)", asMETHOD(text_font, render_text_blended_wrapped), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_text_shaded(const string&in text, uint fg_r, uint fg_g, uint fg_b, uint bg_r, uint bg_g, uint bg_b)", asMETHOD(text_font, render_text_shaded), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_text_shaded_wrapped(const string&in text, int wrap_width, uint fg_r, uint fg_g, uint fg_b, uint bg_r, uint bg_g, uint bg_b)", asMETHOD(text_font, render_text_shaded_wrapped), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_text_lcd(const string&in text, uint fg_r, uint fg_g, uint fg_b, uint bg_r, uint bg_g, uint bg_b)", asMETHOD(text_font, render_text_lcd), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_text_lcd_wrapped(const string&in text, int wrap_width, uint fg_r, uint fg_g, uint fg_b, uint bg_r, uint bg_g, uint bg_b)", asMETHOD(text_font, render_text_lcd_wrapped), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_glyph_solid(uint ch, uint r, uint g, uint b)", asMETHOD(text_font, render_glyph_solid), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_glyph_blended(uint ch, uint r, uint g, uint b)", asMETHOD(text_font, render_glyph_blended), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_glyph_shaded(uint ch, uint fg_r, uint fg_g, uint fg_b, uint bg_r, uint bg_g, uint bg_b)", asMETHOD(text_font, render_glyph_shaded), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ render_glyph_lcd(uint ch, uint fg_r, uint fg_g, uint fg_b, uint bg_r, uint bg_g, uint bg_b)", asMETHOD(text_font, render_glyph_lcd), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "graphic@ get_glyph_image(uint ch) const", asMETHOD(text_font, get_glyph_image), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_glyph_metrics(uint ch, int&out minx, int&out maxx, int&out miny, int&out maxy, int&out advance) const", asMETHOD(text_font, get_glyph_metrics), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_kerning_size(uint prev_ch, uint ch, int&out kerning) const", asMETHOD(text_font, get_kerning_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_string_size(const string&in text, int&out w, int&out h) const", asMETHOD(text_font, get_string_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool get_string_size_wrapped(const string&in text, int wrap_width, int&out w, int&out h) const", asMETHOD(text_font, get_string_size_wrapped), asCALL_THISCALL);
	engine->RegisterObjectMethod("text_font", "bool measure_string(const string&in text, int max_width, int&out measured_width, int&out measured_length) const", asMETHOD(text_font, measure_string), asCALL_THISCALL);
	// text_font free functions
	engine->RegisterGlobalFunction("text_font@ get_font(const string&in name, float size, uint style = FONT_STYLE_NORMAL, bool allow_caching = true)", asFUNCTION(get_font), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint font_string_to_tag(const string&in str)", asFUNCTION(font_string_to_tag), asCALL_CDECL);
	engine->RegisterGlobalFunction("string font_tag_to_string(uint tag)", asFUNCTION(font_tag_to_string), asCALL_CDECL);
	// graphics_renderer
	engine->RegisterObjectType("graphics_renderer", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("graphics_renderer", asBEHAVE_ADDREF, "void f()", asMETHOD(graphics_renderer, duplicate), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("graphics_renderer", asBEHAVE_RELEASE, "void f()", asMETHOD(graphics_renderer, release), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("graphics_renderer", asBEHAVE_FACTORY, "graphics_renderer@ f()", asFUNCTION(graphics_renderer_factory), asCALL_CDECL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_is_valid() const property", asMETHOD(graphics_renderer, is_valid), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "string get_name() const property", asMETHOD(graphics_renderer, get_name), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool clear()", asMETHOD(graphics_renderer, clear), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool present()", asMETHOD(graphics_renderer, present), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool draw_point(float x, float y)", asMETHOD(graphics_renderer, draw_point), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool draw_line(float x1, float y1, float x2, float y2)", asMETHOD(graphics_renderer, draw_line), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool draw_rect(float x, float y, float w, float h)", asMETHOD(graphics_renderer, draw_rect), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool fill_rect(float x, float y, float w, float h)", asMETHOD(graphics_renderer, fill_rect), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool set_draw_color(uint r, uint g, uint b, uint a)", asMETHOD(graphics_renderer, set_draw_color), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_draw_color(uint&out r, uint&out g, uint&out b, uint&out a) const", asMETHOD(graphics_renderer, get_draw_color), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool set_scale(float sx, float sy)", asMETHOD(graphics_renderer, set_scale), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_scale(float&out sx, float&out sy) const", asMETHOD(graphics_renderer, get_scale), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool set_vsync(int vsync)", asMETHOD(graphics_renderer, set_vsync), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_vsync(int&out vsync) const", asMETHOD(graphics_renderer, get_vsync), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool flush()", asMETHOD(graphics_renderer, flush), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool set_color_scale(float scale)", asMETHOD(graphics_renderer, set_color_scale), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "float get_color_scale() const property", asMETHOD(graphics_renderer, get_color_scale), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool set_draw_blend_mode(blend_mode mode)", asMETHOD(graphics_renderer, set_draw_blend_mode), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "blend_mode get_draw_blend_mode() const property", asMETHOD(graphics_renderer, get_draw_blend_mode), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_viewport_set() const property", asMETHOD(graphics_renderer, viewport_set), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_clip_enabled() const property", asMETHOD(graphics_renderer, clip_enabled), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_output_size(int&out w, int&out h) const", asMETHOD(graphics_renderer, get_output_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_current_output_size(int&out w, int&out h) const", asMETHOD(graphics_renderer, get_current_output_size), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool render_graphic(graphic@+ gfx, float dst_x, float dst_y)", asMETHOD(graphics_renderer, render_graphic), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool render_graphic(graphic@+ gfx, float src_x, float src_y, float src_w, float src_h, float dst_x, float dst_y, float dst_w, float dst_h)", asMETHOD(graphics_renderer, render_graphic_ex), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "graphics_texture@ create_texture(graphic@+ gfx)", asMETHOD(graphics_renderer, create_texture), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool render_texture(graphics_texture@+ tex, float dst_x, float dst_y)", asMETHOD(graphics_renderer, render_texture), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool render_texture(graphics_texture@+ tex, float src_x, float src_y, float src_w, float src_h, float dst_x, float dst_y, float dst_w, float dst_h)", asMETHOD(graphics_renderer, render_texture_ex), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool set_logical_presentation(int w, int h, renderer_logical_presentation mode)", asMETHOD(graphics_renderer, set_logical_presentation), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_logical_presentation(int&out w, int&out h, renderer_logical_presentation&out mode) const", asMETHOD(graphics_renderer, get_logical_presentation), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool set_viewport(int x, int y, int w, int h)", asMETHOD(graphics_renderer, set_viewport), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_viewport(int&out x, int&out y, int&out w, int&out h) const", asMETHOD(graphics_renderer, get_viewport), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool set_clip_rect(int x, int y, int w, int h)", asMETHOD(graphics_renderer, set_clip_rect), asCALL_THISCALL);
	engine->RegisterObjectMethod("graphics_renderer", "bool get_clip_rect(int&out x, int&out y, int&out w, int&out h) const", asMETHOD(graphics_renderer, get_clip_rect), asCALL_THISCALL);
}
