# audioform_errorcodes
This enum contains any error values that can be returned by the `audio_form::get_last_error();` function.

* form_error_none: No error.
* form_error_invalid_index: you provided a control index that doesn't exist.
* form_error_invalid_control: you are attempting to do something on an invalid control.
* form_error_invalid_value: You provided an invalid value.
* form_error_invalid_operation: you tried to perform an invalid operation.
* form_error_no_window: you haven't created an audio_form window yet.
* form_error_window_full: the window is at its maximum number of controls
* form_error_text_too_long: the text provided is too long.
* form_error_list_empty: indicates that a list control is empty.
* form_error_list_full: indicates that a list control is full.
* form_error_invalid_list_index: the list has no item at that index.
* form_error_control_invisible: the specified control is invisible.
* form_error_no_controls_visible: no controls are currently visible.
