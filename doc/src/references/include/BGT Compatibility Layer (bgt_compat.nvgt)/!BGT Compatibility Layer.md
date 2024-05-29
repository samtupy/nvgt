# BGT Compatibility Layer
This is an include file that attempts to make old BGT games run in NVGT with minimal modifications, mainly by remapping function names and writing a few convenience wrappers. All function signatures are exactly how they would've been in BGT unless otherwise noted.

Below, you'll find a list of everything this include does, as well as a reference for what each item roughly maps to in native nVGT.

## Key constants:
* KEY_PRIOR: KEY_PAGEUP.
* KEY_NEXT: KEY_PAGEDOWN.
* KEY_LCONTROL: KEY_LCTRL.
* KEY_RCONTROL: KEY_RCTRL.
* KEY_LWIN: KEY_LGUI.
* KEY_RWIN: KEY_RGUI.
* KEY_LMENU: KEY_LALT.
* KEY_RMENU: KEY_RALT.
* KEY_LBRACKET: KEY_LEFTBRACKET.
* KEY_RBRACKET: KEY_RIGHTBRACKET.
* KEY_NUMPADENTER: KEY_NUMPAD_ENTER.
* KEY_DASH: KEY_MINUS.

## Math functions:
* absolute: abs.
* cosine: cos.
* sine: sin.
* tangent: tan.
* arc_cosine: acos.
* arc_sine: asin.
* arc_tangent: atan.
* power: pow.
* square_root: sqrt.
* ceiling: ceil.

## Screen reader speech:
Note that these functions don't map cleanly to how NVGT's API works. As such, substitutions will not be provided here. It is recommended that you use NVGT's built-in screen reader speech functions if you can, they're much more efficient, and much more powerful.

### Constants:
* JAWS.
* WINDOW_EYES.
* SYSTEM_ACCESS.
* NVDA.

### Functions:
* screen_reader_is_running.
* screen_reader_speak.
* screen_reader_speak_interrupt.
* screen_reader_stop_speech.

## String functions:
* string_len: string.length.
* string_replace: string.replace.
* string_left: string.substr.
* string_right: string.slice.
* string_trim_left: string.substr.
* string_trim_right: string.slice.
* string_mid: string.substr.
* string_is_lower_case: string.is_lower.
* string_is_upper_case: string.is_upper.
* string_is_alphabetic: string.is_alphabetic.
* string_is_digits: string.is_digits.
* string_is_alphanumeric: string.is_alphanumeric.
* string_reverse: string.reverse.
* string_to_lower_case: string.lower.
* string_to_upper_case: string.upper.
* string_split: string.split.
* string_contains: string.find.
* get_last_error_text: supersceeded by exxceptions.
* string_to_number: parse_float.
* string_compress: string_deflate.
* string_decompress: string_inflate.

## String encryption/decryption:
Note that these functions don't work with existing BGT data.
* string_encrypt.
* string_decrypt.

## UI functions:
* show_game_window: show_window.
* is_game_window_active: is_window_active.
