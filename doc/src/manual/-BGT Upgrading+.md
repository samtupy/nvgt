# Upgrading From BGT
Since for a while this is where most people who have heard of NVGT will likely start, we will begin by describing the relationship between NVGT and BGT, and more importantly the steps required to upgrade a BGT project to an NVGT one. If you have not heard of BGT or are completely new to game development and are wondering how NVGT can help you, you can probably skip this and move to the fresh start topic.

BGT stands for the Blastbay Gaming Toolkit, and is what initially inspired NVGT to be created after BGT was made into abandonware.

It is important to note that NVGT is not officially endorsed by BGT's developers and contributors, and NVGT is not in any way derived from BGT's source code. The only shared assets between NVGT and BGT are some of BGT's include files such as the audio_form and sound_pool used by many bgt games, which are released under a zlib license.

our goal is to make the transition as seamless as possible from BGT to NVGT, but here are some things you should know when porting an existing BGT game.

## Missing features
NVGT currently has some missing features compared with BGT. These may be added in the future, or have already been replaced with more flexible options.
* Security functions such as `file_encrypt`, `file_decrypt`, `file_hash`, `set_sound_decryption_key` do not exist in NVGT. These may or may not be added, but in the meantime you can encrypt/decrypt/hash files manually by using string_aes_encrypt/decrypt/hash_sha256/sha512.
* Objects such as tone_synth, combination and joystick do not exist in NVGT.
* NVGT does not interface with WindowEyes, which is now considered a legacy screen reader.

## Differences
### Functional
Some functions which have the same name as those in BGT work slightly differently.
* get_last_error: Currently doesn't trigger in all the situations that BGT does.
* When refering to an array's length, pass length as a method call and not as a property. For example, you would use `array.length();` rather than `array.length;`.
* Screen reader functions no longer need to specify the screen reader. If an active screen reader is detected it will automatically speak through there.
* Data encrypted with BGT cannot be decrypted with NVGT, and vice versa.
* The `sound::stream()` method does exist in NVGT, but it's simply an alias to `sound::load()`. For this reason it is recommended that you change all your `stream()` calls to `load()` instead. The load function performs an  efficient combination of streaming and preloading by default.
* load() contains a second optional argument to pass a pack file. set_sound_storage() is no longer used for the moment. However, you can set sound_pool.pack_file or even the global sound_default_pack property to a pack handle to get a similar effect.
* Take care to check any method calls using the tts_voice object as a few methods such as set_voice have changed from their BGT counterparts.
* When splitting a string, matching against \r\n is advised as BGT handles this differently. This will result in not having spurious line breaks at the ends of split text.
* The settings object no longer writes to the registry, but instead has been replaced by the settings.nvgt include which wraps the previous settings object API, but instead writes to configuration files in various formats.
* The dynamic_menu.bgt include is now called bgt_dynamic_menu.nvgt. This is because NVGT now includes it's own menu class called menu.nvgt.
* There is a type called `var` in the engine now, so you may need to be careful if your project contains any variables named var.
* It's worth noting that unlike BGT, NVGT by default attempts to fully package your game for you including sounds, libraries, documents and any other assets into a .zip file or similar on other platforms intended for distrobution. If you don't like this behavior, you can create a file next to nvgt.exe called config.properties and add the line build.windows_bundle = 0 which will cause NVGT to just produce a standalone executable like BGT did, though you now may need to copy some libraries from the lib folder for the compiled product to run.
* In bgt, you could include pack files with the `#include` directive. In nvgt, we've decided that this should only include code. To embed packs, you can instead add the line `#pragma embed packname.dat` to your project, the extension can be any of your choosing for both code and packs this way.
* Unlike BGT, you can embed multiple packs into an exe. For BGT compatibility, therefore, opening a pack file called `*` will open the first available pack, but it is recommended that you specify a filename such as `*mypack.dat`.
* The generate_profile function returns a string which you can write into a file if desired.

### Nominal
The names of many functions have changed in NVGT. Some have even been moved into the objects they are linked to.

Below is a list starting with the BGT function and the NVGT equivalent:
* clipboard_copy_text: clipboard_set_text
* clipboard_read_text: clipboard_get_text
* generate_computer_id: generate_system_fingerprint
* is_game_window_active: is_window_active
* show_game_window: show_window
* screen_reader_is_running: screen_reader_detect (see function in API reference for differing usage)
* screen_reader_speak_interrupt: screen_reader_speak
* screen_reader_stop_speech: screen_reader_silence
* absolute: abs
* arc_cosine: acos
* arc_sine: asin
* arc_tangent: atan
* ceiling: ceil
* cosine: cos
* power: pow
* sine: sin
* square_root: sqrt
* tangent: tan
* serialize: dictionary.serialize
* string_compress: string_deflate
* string_contains: string.find
* string_decompress: string_inflate
* string_decrypt: string_aes_decrypt
* string_encrypt: string_aes_encrypt
* string_hash: separated into two functions (string_hash_sha256, string_hash_sha512)
* string_is_alphanumeric: string.is_alphanumeric
* string_is_digits: string.is_digits
* string_is_lower_case: string.is_lower
* string_is_upper_case: string.is_upper
* string_len: string.length
* string_replace: string.replace
* string_reverse: string.reverse_bytes
* string_split: string.split
* string_to_lower_case: string.lower
* string_to_number: parse_float
* string_to_upper_case: string.upper
* The five substring functions string_left, string_mid, string_right, string_trim_left, string_trim_right, have been replaced with just two methods: string.substr and string.slice.

The following key constants are also different:
* KEY_PRIOR: KEY_PAGEUP
* KEY_NEXT: KEY_PAGEDOWN
* KEY_LCONTROL: KEY_LCTRL
* KEY_RCONTROL: KEY_RCTRL
* KEY_LWIN: KEY_LGUI
* KEY_RWIN: KEY_RGUI
* KEY_LMENU: KEY_LALT
* KEY_RMENU: KEY_RALT
* KEY_LBRACKET: KEY_LEFTBRACKET
* KEY_RBRACKET: KEY_RIGHTBRACKET
* KEY_NUMPADENTER: KEY_NUMPAD_ENTER
* KEY_DASH: KEY_MINUS

### BGT compatibility helper
You can `#include "bgt_compat.nvgt"`, which implements a lot of aliases to BGT-compatible functions and classes. However when doing this, please be aware of the following limitations:
* Using built-in functions may improve performance so this is more or less a stop-gap to get you up and running quickly; however if you wish for your code to just run, bgt_compat will certainly be of use.
* Please note you will not be able to use this script if you have disabled global variables.
* The joystick object is a ghost object and does not currently function.
* The set_sound_decryption_key is also a dummy function.
* Since the screen reader internal functions no longer require you to specify a screen reader, the reader parameter is ignored.
* The hardware_only parameter of generate_computer_id is ignored.
