# create_button
Creates a new button and adds it to the audio form.

`int audio_form::create_button(string caption, bool primary = false, bool cancel = false, bool overwrite = true);`

## Arguments:
* string caption: the label to associate with the button.
* bool primary = false: should this button be activated by pressing enter anywhere in the form?
* bool cancel = false: should this button be activated by pressing escape anywhere in the form?
* bool overwrite = true: overwrite any existing primary/cancel settings.

## Returns:
int: the control index of the new button, or -1 if there was an error. To get error information, look at `audio_form::get_last_error();`.
