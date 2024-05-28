# create_list
Creates a new list control and adds it to the audio form.

`int audio_form::create_list(string caption, int maximum_items = 0, bool multiselect = false, bool repeat_boundary_items = false);`

## Arguments:
* string caption: the label to attach to this list.
* int maximum_items = 0: the maximum number of allowed items, 0 for unlimited.
* bool multiselect = false: can the user select multiple items in this list?
* bool repeat_boundary_items = false: do items repeat if you press the arrow keys at the edge of the list?

## Returns:
int: the control index of the new list, or -1 if there was an error. To get error information, look at `audio_form::get_last_error();`.
