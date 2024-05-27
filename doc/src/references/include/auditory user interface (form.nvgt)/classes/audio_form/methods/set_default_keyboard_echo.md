# set_default_keyboard_echo
Sets the default keyboard echo of controls on your form.

`bool audio_form::set_default_keyboard_echo(int keyboard_echo, bool update_controls = true);`

## Arguments:
* int keyboard_echo: the keyboard echo mode to use (see text_entry_speech_flags for more information).
* bool update_controls = true: whether or not this echo should be applied to any controls that already exist on your form.

## Returns:
bool: true if the echo was successfully set, false otherwise.
