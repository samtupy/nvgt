# close
This method closes the settings object and therefore the object will be deactivated. From then on you will no longer be able to interact with the data of the company and/or products anymore unless you resetup with `settings::setup` method.

`bool settings::close(bool save_data = true);`

## Arguments:
* bool save_data = true: toggles whether the data should be saved before closing.

## Returns:
bool: true on success, false on failure.
