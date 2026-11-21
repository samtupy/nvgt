# update_surface
Copy the window's software surface to the screen.

`bool game_window::update_surface();`

## Returns:
bool: true on success, false otherwise.

## Remarks:
This is for software drawing to the window's surface rather than its renderer, which NVGT's drawing methods use.
