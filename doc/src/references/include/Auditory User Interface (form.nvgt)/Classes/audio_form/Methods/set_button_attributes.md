# set_button_attributes
Set the primary and cancel flags of a button.

`bool audio_form::set_button_attributes(int control_index, bool primary, bool cancel, bool overwrite = true);

## Arguments:
* int control_index: the index of the button to update.
* bool primary: should this button be made primary (e.g. pressing enter from anywhere on the form activates it)?
* bool cancel: should this button be made the cancel button (e.g. should pressing escape from anywhere on the form always activate it?).
* bool overwrite = true: should the previous primary and cancel buttons (if any) be overwritten?

## Returns:
bool: true if the attributes were successfully set, false otherwise.
