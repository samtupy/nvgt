# is_disallowed_char
Determines whether the text of a given control contains characters that are not allowed, set by the `audio_form::set_disallowed_chars` method.

`bool audio_form::is_disallowed_char(int control_index, string char, bool search_all = true);`

## Arguments:
* int control_index: the index of the control.
* string char: one or more characters to query
* bool search_all = true: toggles whether to search character by character or to match the entire string.

## Returns:
bool: true if the text of the control contains disallowed characters, false otherwise.

## Remarks:
The `search_all` parameter will match the characters depending upon its state. If set to false, the entire string will be searched. If set to true, it will loop through each character and see if one of them contains disallowed character. Thus, you will usually set this to true. One example you might set to false is when the form only has 1 character length, but it is not required, it is looping each character already. However, it is also a good idea to turn this off for the maximum possible performance if you're sure that the input only requires 1 length of characters.
