# set_list_multinavigation
Configures how the multi-letter navigation works in a list control.

`bool audio_form::set_list_multinavigation(int control_index, bool letters, bool numbers, bool nav_translate = true);`

## Arguments:
* int control_index: the index of the list control.
* bool letters: can the user navigate with letters?
* bool numbers: can the user navigate with the numbers.
* bool nav_translate = true: should the letters work with the translated alphabet in use?

## Returns:
bool: true if the settings were successfully set, false otherwise.
