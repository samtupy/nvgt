# setup
Sets up the settings object.

`bool settings::setup(const string company, const string product, const bool local_path, const string format = "ini");`

## Arguments:
* const string company: the name of your company.
* const string product: the name of your product.
* const bool local_path: toggles whether the data should be saved in the path where the script is being executed, or in the appdata.
* const string format = "ini": the format you wish to use, see remarks.

## Returns:
bool: true on success, false on failure.

## Remarks:
The following is a list of supported formats:
* `ini`
* `json`
* `nvgt`: this format will use built-in dictionary.
