# get_slider_minimum_value
Get the minimum value of a slider.

`double audio_form::get_slider_minimum_value(int control_index);`

## Arguments:
* int control_index: the index of the slider to query.

## Returns:
double: the minimum allowable value the slider may be set to. In case of error, this may return -1. To get error information, see `audio_form::get_last_error();`.

## Remarks:
This method only works on slider control.
