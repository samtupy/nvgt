# create_slider
Creates a new slider control and adds it to the audio form.

`int audio_form::create_slider(string caption, int default_value = 50, int minimum_value = 0, int maximum_value = 100, string text = "");`

## Arguments:
* string caption: the text to be spoken when this slider is tabbed over.
* int default_value = 50: the default value to set the slider to.
* int minimum_value = 0: the minimum value of the slider.
* int maximum_value = 100: the maximum value of the slider.
* string text = "": extra text to be associated with the slider.

## Returns:
int: the control index of the new slider, or -1 if there was an error. To get error information, see `audio_form::get_last_error();`.
