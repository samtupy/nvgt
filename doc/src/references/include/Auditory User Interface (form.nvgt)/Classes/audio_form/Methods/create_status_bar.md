# create_status_bar
Creates a new status bar and adds it to the audio form.

`int audio_form::create_status_bar(string caption, string text);`

## Arguments:
* string caption: the label of the status bar.
* string text: the text to display on the status bar.

## Returns:
int: the control index of the new status bar, or -1 if there was an error. To get error information, see `audio_form::get_last_error();`.
