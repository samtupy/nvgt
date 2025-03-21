# set_disallowed_chars
Sets the whitelist/blacklist characters of a control.

`bool audio_form::set_disallowed_chars(int control_index, string chars, bool use_only_disallowed_chars = false, string char_disallowed_description = "");`

## Arguments:
* int control_index: the index of the control.
* string chars: the characters to set.
* bool use_only_disallowed_chars = false: sets whether the control should only use the characters in this list. true means use only characters that are in the list, and false means allow only characters that are not in the list.
* string char_disallowed_description = "": the text to speak when an invalid character is inputted.

## Returns:
bool: true if the characters were successfully set, false otherwise.

## Remarks:
Setting the `use_only_disallowed_chars` parameter to true will restrict all characters that are not in the list. This is useful to prevent other characters in number inputs.

Setting the chars parameter to empty will clear the characters and will switch back to default.

Please note that these character sets will also restrict the text from being pasted if the clipboard contains disallowed characters.
