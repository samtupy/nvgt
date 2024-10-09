# create_slider
Creates a new slider control and adds it to the audio form.

`int audio_form::create_slider(string caption, double default_value = 50, double minimum_value = 0, double maximum_value = 100, string text = "", double step_size = 1);`

## Arguments:
* string caption: the text to be spoken when this slider is tabbed over.
* double default_value = 50: the default value to set the slider to.
* double minimum_value = 0: the minimum value of the slider.
* double maximum_value = 100: the maximum value of the slider.
* string text = "": extra text to be associated with the slider.
* double step_size = 1: the value that will increment/decrement the slider value.

## Returns:
int: the control index of the new slider, or -1 if there was an error. To get error information, see `audio_form::get_last_error();`.
