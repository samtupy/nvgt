# set_keyboard_echo
Set the keyboard echo for a particular control.

`bool audio_form::set_keyboard_echo(int control_index, int keyboard_echo);`

## Arguments:
* int control_index: the index of the control to modify.
* int keyboard_echo: the keyboard echo mode to use (see text_entry_speech_flags for more information).

## Returns:
bool: true if the keyboard echo was successfully set, false otherwise.
