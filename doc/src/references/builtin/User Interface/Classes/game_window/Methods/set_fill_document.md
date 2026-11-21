# set_fill_document
Set whether the window fills the whole page when running in a web browser.

`bool game_window::set_fill_document(bool fill);`

## Arguments:
* bool fill: whether the window fills the whole page when running in a web browser.

## Returns:
bool: true on success, false otherwise.

## Remarks:
This does nothing at present. It only applies when a program runs inside a web page, which NVGT can't currently be compiled for, so on Windows, macOS, Linux and Android it always returns false and changes nothing. It exists in case NVGT gains WebAssembly support in the future, and if that never happens it may be removed, so there is no reason to use it in a game.
