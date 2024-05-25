# create_progress_bar
Creates a new progress bar control and adds it to the audio form.

`int audio_form::create_progress_bar(string caption, int speak_interval = 5, bool speak_global = true);`

## Arguments:
* string caption: the label to associate with the progress bar.
* int speak_interval = 5: how often to spaek percentage changes.
* bool speak_global = true: should progress updates be spoken even when this control doesn't have keyboard focus?

## Returns:
int: the control index of the new progress bar, or -1 if there was an error. To get error information, look at `audio_form::get_last_error();`.
