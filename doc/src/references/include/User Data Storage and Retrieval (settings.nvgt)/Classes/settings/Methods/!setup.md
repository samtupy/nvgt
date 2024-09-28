# setup
This method will setup your company and/or product, and thus the object will be activated, allowing you to interact with the data of the product.

`bool settings::setup(const string company, const string product, const bool local_path, const string format = "ini");`

## Arguments:
* const string company: the name of your company. This is the main folder for all your products related to this company.
* const string product: the name of your product. This will be the subfolder under the company.
* const bool local_path: toggles whether the data should be saved in the path where the script is being executed, or in the appdata.
* const string format = "ini": the format you wish to use, see remarks.

## Returns:
bool: true on success, false on failure.

## Remarks:
The following is a list of supported formats:
* `ini`: default format (.ini).
* `json`: JSON format (.json).
* `nvgt`: this format will use built-in dictionary (.dat).

Note that it does not currently allow you to modify the extentions, for instance, .savedata, .sd, etc. In the future it might be possible and will be documented as soon as it gets implemented.
