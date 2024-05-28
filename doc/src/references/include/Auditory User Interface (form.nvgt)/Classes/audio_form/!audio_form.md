# audio_form
This class fecilitates the easy creation of user interfaces that convey their usage entirely through audio.

## Notes:
* many of the methods in this class only work on certain types of controls, and will return false and set an error value if used on invalid types of controls. This will generally be indicated in the documentation for each function.
* Exceptions are not used here. Instead, we indicate errors through `audio_form::get_last_error();`.
