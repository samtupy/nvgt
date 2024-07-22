# set_caption
Sets the caption of a control.

`bool audio_form::set_caption(int control_index, string caption);`

## Arguments:
* int control_index: the index of the control.
* string caption: the caption to set on the control (see remarks for more infromation).

## Returns:
bool: true if the caption was successfully set, false otherwise.

## Remarks:
The caption is read every time a user focuses this particular control.

It is possible to associate hotkeys with controls by putting an "&" symbol in the caption. For example, setting the caption of a button to "E&xit" would assign the hotkey alt+x to focus it.
