# create_input_box
Creates an input box control on the audio form.

`int audio_form::create_input_box(string caption, string default_text = "", string password_mask = "", int maximum_length = 0, bool read_only = false, bool multiline = false, bool multiline_enter = true);`

## Arguments:
* string caption: the label of the input box (e.g. what will be read when you tab over it?).
* string default_text = "": the text to populate the input box with by default (if any).
*( string password_mask = "": a string to mask typed characters with, (e.g. "star"). Mainly useful if you want your field to be password protected. Leave blank for no password protection.
* int maximum_length = 0: the maximum number of characters that can be typed in this field, 0 for unlimited.
* bool read_only = false: should this text field be read-only?
* bool multiline = false: should this text field have multiple lines?
* bool multiline_enter = true: should pressing enter in this field insert a new line (if it's multiline)?

## Returns:
int: the control index of the new input box, or -1 if there was an error. To get error information, look at `audio_form::get_last_error();`.
