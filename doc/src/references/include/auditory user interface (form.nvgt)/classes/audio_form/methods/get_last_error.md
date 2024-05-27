# get_last_error
Get the last error that was raised from this form.

`int audio_form::get_last_error();`

## Returns:
int: the last error code raised by this audio_form ( see audioform_errorcodes for more information).

## Remarks:
As noted in the introduction to this class, exceptions are not used here. Instead, we indicate errors through this function.
