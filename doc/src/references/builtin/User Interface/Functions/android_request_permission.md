# android_request_permission
Request a permission from the Android operating system either synchronously or asynchronously.

`bool android_request_permission(string permission, android_permission_request_callback@ callback = null, string callback_data = "");`

## Arguments:
* string permission: A permission identifier such as android.permission.RECORD_AUDIO.
* android_permission_request_callback@ callback = null: An optional function that should be called when the user responds to the permission request (see remarks).
* string callback_data = "": An arbitrary string that is passed to the given callback function.

## Returns:
bool: true if the request succeeded (see remarks), false otherwise or if this function was not called on Android.

## Remarks:
The callback signature this function expects is registered as :
`funcdef void android_permission_request_callback(string permission, bool granted, string user_data);`

This function behaves very differently depending on whether you've provided a callback or not. If you do not, this function blocks the thread that called it until the user responds to the permission request, in which case it returns true or false depending on whether the user has actually granted the permission. On the other hand if you do provide a callback, the instant return value of this function only indicates whether the request has been made rather than whether the permission has been granted, as that information will be provided later in the given callback.

Beware that the callback you provide might get invoked on any thread, thus the provision of a more simple, blocking alternative. If you do provide a callback, you are responsible for handling any data races that may result.
