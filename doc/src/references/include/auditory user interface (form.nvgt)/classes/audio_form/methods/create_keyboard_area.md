# create_keyboard_area
Creates a new keyboard area and adds it to the audio form.

`int audio_form::create_keyboard_area(string caption);`

## Arguments:
* string caption: the text to be read when tabbing onto the keyboard area.

## Returns:
int: the control index of the new keyboard area, or -1 if there was an error. To get error information, see `audio_form::get_last_error();`.
