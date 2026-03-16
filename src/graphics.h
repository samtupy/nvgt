/* graphics.h - header defining classes and functions for graphics and other visual rendering features
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

#pragma once

#include <string>
#include <unordered_map>
#include <vector>
#include <angelscript.h>
#include <scriptarray.h>
#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>

class game_window;

inline std::string from_cstr(const char* str) { return str ? str : ""; }
inline SDL_Color to_sdl_color(unsigned int r, unsigned int g, unsigned int b) { return {(Uint8)r, (Uint8)g, (Uint8)b, 255}; }

class graphic {
	SDL_Surface* _surface;
	int _refcount;
public:
	graphic(SDL_Surface* surface);
	~graphic();
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	int get_width() const { return _surface ? _surface->w : 0; }
	int get_height() const { return _surface ? _surface->h : 0; }
	int get_pitch() const { return _surface ? _surface->pitch : 0; }
	bool is_valid() const { return _surface != nullptr; }
	bool lock() { return SDL_LockSurface(_surface); }
	void unlock() { SDL_UnlockSurface(_surface); }
	bool save_bmp(const std::string& file) const { return SDL_SaveBMP(_surface, file.c_str()); }
	bool save_png(const std::string& file) const { return SDL_SavePNG(_surface, file.c_str()); }
	bool set_rle(bool enabled) { return SDL_SetSurfaceRLE(_surface, enabled); }
	bool set_color_mod(unsigned int r, unsigned int g, unsigned int b) { return SDL_SetSurfaceColorMod(_surface, (Uint8)r, (Uint8)g, (Uint8)b); }
	bool set_alpha_mod(unsigned int alpha) { return SDL_SetSurfaceAlphaMod(_surface, (Uint8)alpha); }
	bool set_blend_mode(unsigned int mode) { return SDL_SetSurfaceBlendMode(_surface, (SDL_BlendMode)mode); }
	bool flip(unsigned int mode) { return SDL_FlipSurface(_surface, (SDL_FlipMode)mode); }
	graphic* convert(unsigned int pixel_format) const { SDL_Surface* s = SDL_ConvertSurface(_surface, (SDL_PixelFormat)pixel_format); return s ? new graphic(s) : nullptr; }
	graphic* duplicate_surface() const { SDL_Surface* s = SDL_DuplicateSurface(_surface); return s ? new graphic(s) : nullptr; }
	unsigned int get_blend_mode() const;
	bool get_color_mod(unsigned int& r, unsigned int& g, unsigned int& b) const;
	unsigned int get_alpha_mod() const;
	SDL_Surface* get_surface() const { return _surface; }
};
graphic* load_bmp(const std::string& file);
graphic* load_png(const std::string& file);
graphic* load_surface(const std::string& file);
graphic* create_surface(int width, int height, unsigned int pixel_format);

class graphics_texture {
	SDL_Texture* _texture;
	int _width;
	int _height;
	int _refcount;
public:
	graphics_texture(SDL_Texture* texture);
	~graphics_texture();
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	int get_width() const { return _width; }
	int get_height() const { return _height; }
	bool is_valid() const { return _texture != nullptr; }
	bool set_color_mod(unsigned int r, unsigned int g, unsigned int b);
	bool get_color_mod(unsigned int& r, unsigned int& g, unsigned int& b) const;
	bool set_alpha_mod(unsigned int alpha);
	unsigned int get_alpha_mod() const;
	bool set_blend_mode(unsigned int mode);
	unsigned int get_blend_mode() const;
	SDL_Texture* get_texture() const { return _texture; }
};

class text_font {
	TTF_Font* _font;
	std::vector<text_font*> _fallback_fonts;
	int _refcount;
public:
	text_font(const std::string& name, float size, unsigned int initial_style = TTF_STYLE_NORMAL);
	~text_font();
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	unsigned int get_generation() const { return TTF_GetFontGeneration(_font); }
	bool add_fallback_font(text_font* font);
	bool remove_fallback_font(text_font* font);
	void clear_fallback_fonts();
	bool set_size(float ptsize) { return TTF_SetFontSize(_font, ptsize); }
	float get_size() const { return TTF_GetFontSize(_font); }
	bool set_size_dpi(float ptsize, int hdpi, int vdpi) { return TTF_SetFontSizeDPI(_font, ptsize, hdpi, vdpi); }
	bool get_dpi(int& hdpi, int& vdpi) const;
	void set_style(unsigned int style) { TTF_SetFontStyle(_font, (TTF_FontStyleFlags)style); }
	unsigned int get_style() const { return TTF_GetFontStyle(_font); }
	bool set_outline(int outline) { return TTF_SetFontOutline(_font, outline); }
	int get_outline() const { return TTF_GetFontOutline(_font); }
	int get_faces_count() const { return TTF_GetNumFontFaces(_font); }
	bool set_sdf(bool enabled) { return TTF_SetFontSDF(_font, enabled); }
	bool get_sdf() const { return TTF_GetFontSDF(_font); }
	int get_weight() const { return TTF_GetFontWeight(_font); }
	void set_wrap_alignment(unsigned int alignment) { TTF_SetFontWrapAlignment(_font, (TTF_HorizontalAlignment)alignment); }
	unsigned int get_wrap_alignment() const { return (unsigned int)TTF_GetFontWrapAlignment(_font); }
	int get_height() const { return TTF_GetFontHeight(_font); }
	int get_ascent() const { return TTF_GetFontAscent(_font); }
	int get_descent() const { return TTF_GetFontDescent(_font); }
	void set_line_skip(int skip) { TTF_SetFontLineSkip(_font, skip); }
	int get_line_skip() const { return TTF_GetFontLineSkip(_font); }
	void set_kerning(bool enabled) { TTF_SetFontKerning(_font, enabled); }
	bool get_kerning() const { return TTF_GetFontKerning(_font); }
	bool is_fixed_width() const { return TTF_FontIsFixedWidth(_font); }
	bool is_scalable() const { return TTF_FontIsScalable(_font); }
	std::string get_family_name() const { return from_cstr(TTF_GetFontFamilyName(_font)); }
	std::string get_style_name() const { return from_cstr(TTF_GetFontStyleName(_font)); }
	bool set_direction(unsigned int dir) { return TTF_SetFontDirection(_font, (TTF_Direction)dir); }
	unsigned int get_direction() const { return (unsigned int)TTF_GetFontDirection(_font); }
	bool set_script(unsigned int script) { return TTF_SetFontScript(_font, script); }
	unsigned int get_script() const { return TTF_GetFontScript(_font); }
	bool set_language(const std::string& language_bcp47) { return TTF_SetFontLanguage(_font, language_bcp47.c_str()); }
	bool has_glyph(unsigned int codepoint) { return TTF_FontHasGlyph(_font, codepoint); }
	graphic* render_text_solid(const std::string& text, unsigned int r, unsigned int g, unsigned int b) { return new graphic(TTF_RenderText_Solid(_font, text.c_str(), text.size(), to_sdl_color(r, g, b))); }
	graphic* render_text_solid_wrapped(const std::string& text, int wrap_width, unsigned int r, unsigned int g, unsigned int b) { return new graphic(TTF_RenderText_Solid_Wrapped(_font, text.c_str(), text.size(), to_sdl_color(r, g, b), wrap_width)); }
	graphic* render_text_blended(const std::string& text, unsigned int r, unsigned int g, unsigned int b) { return new graphic(TTF_RenderText_Blended(_font, text.c_str(), text.size(), to_sdl_color(r, g, b))); }
	graphic* render_text_blended_wrapped(const std::string& text, int wrap_width, unsigned int r, unsigned int g, unsigned int b) { return new graphic(TTF_RenderText_Blended_Wrapped(_font, text.c_str(), text.size(), to_sdl_color(r, g, b), wrap_width)); }
	graphic* render_text_shaded(const std::string& text, unsigned int fg_r, unsigned int fg_g, unsigned int fg_b, unsigned int bg_r, unsigned int bg_g, unsigned int bg_b) { return new graphic(TTF_RenderText_Shaded(_font, text.c_str(), text.size(), to_sdl_color(fg_r, fg_g, fg_b), to_sdl_color(bg_r, bg_g, bg_b))); }
	graphic* render_text_shaded_wrapped(const std::string& text, int wrap_width, unsigned int fg_r, unsigned int fg_g, unsigned int fg_b, unsigned int bg_r, unsigned int bg_g, unsigned int bg_b) { return new graphic(TTF_RenderText_Shaded_Wrapped(_font, text.c_str(), text.size(), to_sdl_color(fg_r, fg_g, fg_b), to_sdl_color(bg_r, bg_g, bg_b), wrap_width)); }
	graphic* render_text_lcd(const std::string& text, unsigned int fg_r, unsigned int fg_g, unsigned int fg_b, unsigned int bg_r, unsigned int bg_g, unsigned int bg_b) { return new graphic(TTF_RenderText_LCD(_font, text.c_str(), text.size(), to_sdl_color(fg_r, fg_g, fg_b), to_sdl_color(bg_r, bg_g, bg_b))); }
	graphic* render_text_lcd_wrapped(const std::string& text, int wrap_width, unsigned int fg_r, unsigned int fg_g, unsigned int fg_b, unsigned int bg_r, unsigned int bg_g, unsigned int bg_b) { return new graphic(TTF_RenderText_LCD_Wrapped(_font, text.c_str(), text.size(), to_sdl_color(fg_r, fg_g, fg_b), to_sdl_color(bg_r, bg_g, bg_b), wrap_width)); }
	graphic* render_glyph_solid(unsigned int ch, unsigned int r, unsigned int g, unsigned int b) { return new graphic(TTF_RenderGlyph_Solid(_font, ch, to_sdl_color(r, g, b))); }
	graphic* render_glyph_blended(unsigned int ch, unsigned int r, unsigned int g, unsigned int b) { return new graphic(TTF_RenderGlyph_Blended(_font, ch, to_sdl_color(r, g, b))); }
	graphic* render_glyph_shaded(unsigned int ch, unsigned int fg_r, unsigned int fg_g, unsigned int fg_b, unsigned int bg_r, unsigned int bg_g, unsigned int bg_b) { return new graphic(TTF_RenderGlyph_Shaded(_font, ch, to_sdl_color(fg_r, fg_g, fg_b), to_sdl_color(bg_r, bg_g, bg_b))); }
	graphic* render_glyph_lcd(unsigned int ch, unsigned int fg_r, unsigned int fg_g, unsigned int fg_b, unsigned int bg_r, unsigned int bg_g, unsigned int bg_b) { return new graphic(TTF_RenderGlyph_LCD(_font, ch, to_sdl_color(fg_r, fg_g, fg_b), to_sdl_color(bg_r, bg_g, bg_b))); }
	graphic* get_glyph_image(unsigned int ch) const;
	bool get_glyph_metrics(unsigned int ch, int& minx, int& maxx, int& miny, int& maxy, int& advance) const;
	bool get_kerning_size(unsigned int prev_ch, unsigned int ch, int& kerning) const;
	bool get_string_size(const std::string& text, int& w, int& h) const;
	bool get_string_size_wrapped(const std::string& text, int wrap_width, int& w, int& h) const;
	bool measure_string(const std::string& text, int max_width, int& measured_width, int& measured_length) const;
};
text_font* get_font(const std::string& name, float size, unsigned int initial_style = TTF_STYLE_NORMAL, bool allow_caching = true);
unsigned int font_string_to_tag(const std::string& str);
std::string font_tag_to_string(unsigned int tag);

class graphics_renderer {
	SDL_Renderer* _renderer;
	int _refcount;
public:
	graphics_renderer();
	graphics_renderer(game_window* window);
	~graphics_renderer();
	void duplicate() { asAtomicInc(_refcount); }
	void release() { if (asAtomicDec(_refcount) < 1) delete this; }
	bool is_valid() const { return _renderer != nullptr; }
	std::string get_name() const { return from_cstr(SDL_GetRendererName(_renderer)); }
	bool clear() { return SDL_RenderClear(_renderer); }
	bool present() { return SDL_RenderPresent(_renderer); }
	bool draw_point(float x, float y) { return SDL_RenderPoint(_renderer, x, y); }
	bool draw_line(float x1, float y1, float x2, float y2) { return SDL_RenderLine(_renderer, x1, y1, x2, y2); }
	bool set_draw_color(unsigned int r, unsigned int g, unsigned int b, unsigned int a) { return SDL_SetRenderDrawColor(_renderer, (Uint8)r, (Uint8)g, (Uint8)b, (Uint8)a); }
	bool set_scale(float sx, float sy) { return SDL_SetRenderScale(_renderer, sx, sy); }
	bool set_vsync(int vsync) { return SDL_SetRenderVSync(_renderer, vsync); }
	bool flush() { return SDL_FlushRenderer(_renderer); }
	bool set_color_scale(float scale) { return SDL_SetRenderColorScale(_renderer, scale); }
	bool set_draw_blend_mode(unsigned int mode) { return SDL_SetRenderDrawBlendMode(_renderer, (SDL_BlendMode)mode); }
	bool viewport_set() const { return SDL_RenderViewportSet(_renderer); }
	bool clip_enabled() const { return SDL_RenderClipEnabled(_renderer); }
	bool get_draw_color(unsigned int& r, unsigned int& g, unsigned int& b, unsigned int& a) const;
	bool get_scale(float& sx, float& sy) const;
	bool get_vsync(int& vsync) const;
	float get_color_scale() const;
	unsigned int get_draw_blend_mode() const;
	bool get_output_size(int& w, int& h) const;
	bool get_current_output_size(int& w, int& h) const;
	bool draw_rect(float x, float y, float w, float h);
	bool fill_rect(float x, float y, float w, float h);
	bool render_graphic(graphic* gfx, float dst_x, float dst_y);
	bool render_graphic_ex(graphic* gfx, float src_x, float src_y, float src_w, float src_h, float dst_x, float dst_y, float dst_w, float dst_h);
	graphics_texture* create_texture(graphic* gfx);
	bool render_texture(graphics_texture* tex, float dst_x, float dst_y);
	bool render_texture_ex(graphics_texture* tex, float src_x, float src_y, float src_w, float src_h, float dst_x, float dst_y, float dst_w, float dst_h);
	bool set_logical_presentation(int w, int h, unsigned int mode);
	bool get_logical_presentation(int& w, int& h, unsigned int& mode) const;
	bool set_viewport(int x, int y, int w, int h);
	bool get_viewport(int& x, int& y, int& w, int& h) const;
	bool set_clip_rect(int x, int y, int w, int h);
	bool get_clip_rect(int& x, int& y, int& w, int& h) const;
	SDL_Renderer* get_renderer() const { return _renderer; }
};

void RegisterGraphics(asIScriptEngine* engine);
