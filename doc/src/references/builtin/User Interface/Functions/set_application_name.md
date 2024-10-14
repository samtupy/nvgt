# set_application_name
This function lets you set the name of your application. This is a name that's sent to your operating system in certain instances, for example in volume mixer dialogs or when an app goes not responding. It does not effect the window title or anything similar.

`bool set_application_name(const string&in application_name);`

## Arguments:
* const string&in application_name: the name to set for your application.

## Returns:
bool: true if the name was successfully set, false otherwise.
