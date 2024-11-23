# dump
This method will manually save the data.

`bool settings::dump();`

## Returns:
bool: true on success, false on failure.

## Remarks:
Especially if you have the `instant_save` property set to false, you need to call this function to save the data manually. Alternatively, the data will be saved if you close the object with `settings::close` method and set the `save_data` parameter to true, which is default.
