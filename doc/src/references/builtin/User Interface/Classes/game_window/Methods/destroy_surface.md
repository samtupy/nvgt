# destroy_surface
Destroy the window's software surface.

`bool game_window::destroy_surface();`

## Returns:
bool: true on success, false otherwise.

## Remarks:
Most programs never need this. A window can be drawn to in two different ways. NVGT's own drawing methods, such as draw_rect() and draw_text(), use the window's renderer, which is the usual and recommended way. The other way, rarely used, is the software surface, a block of ordinary memory holding the window's pixels that a program fills in by itself and then copies to the screen with update_surface(). The surface is created the first time something asks for it, and a window can't use both the surface and the renderer at once.
This function throws the surface away and frees its memory, after which the window carries on as usual. Nothing is changed on screen and the window remains open, and the renderer and the drawing methods that use it are unaffected. A fresh surface is made if one is requested again, and it must be, as an existing one becomes invalid whenever the window is resized. Calling it when the window has no surface is harmless.
