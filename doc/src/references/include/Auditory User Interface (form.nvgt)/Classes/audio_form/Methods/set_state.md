# set_state
Set the enabled/visible state of a control.

`bool audio_form::set_state(int control_index, bool enabled, bool visible);`

## Arguments:
* int control_index: the index of the control.
* bool enabled: is the control enabled (e.g. if it's a button, being disabled would make the button unpressable).
* bool visible: can the user access the control with the navigation commands?

## Returns:
bool: true if the state was successfully set, false otherwise.
