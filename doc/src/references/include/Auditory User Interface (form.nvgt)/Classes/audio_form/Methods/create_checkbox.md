# create_checkbox
Creates a new checkbox and adds it to the audio form.

`int audio_form::create_checkbox(string caption, bool initial_value = false, bool read_only = false);`

## Arguments:
* string caption: the text to be read when tabbing over this checkbox.
*( bool initial_value = false: the initial value of the checkbox (true = checked, false = unchecked).
* bool read_only = false: can the user check/uncheck this checkbox?

## Returns:
int: the control index of the new checkbox, or -1 if there was an error. To get error information, see `audio_form::get_last_error();`.
