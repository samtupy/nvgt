# create_link
Creates a new link and adds it to the audio form.

`int audio_form::create_link(string caption, string url);`

## Arguments:
* string caption: the label of the link.
* string url: The link to open.

## Returns:
int: the control index of the new link, or -1 if there was an error. To get error information, see `audio_form::get_last_error();`.

## Remarks:
The link control is similar to buttons, but this opens the given link when pressed. This also speaks the error message if the link cannot be opened or the link isn't an actual URL. If you want the maximum possible customization, use `audio_form::create_button` method instead.
