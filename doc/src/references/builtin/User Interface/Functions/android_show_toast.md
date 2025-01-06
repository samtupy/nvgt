# android_show_toast
Shows an Android toast notification, small popups that are unique to that operating system.

`bool android_show_toast(const string&in message, int duration, int gravity = -1, int x_offset = 0, int y_offset = 0);`

## Arguments:
* const string&in message: The message to display.
* int duration: 0 for short or 1 for long, all other values are undefined.
* int gravity = -1: One of [the values on this page](https://developer.android.com/reference/android/view/Gravity) or -1 for no preference.
* int x_offset = 0, int y_offset = 0: Only used if gravity is set, see Android developer documentation.

## Returns:
bool: true if the toast was shown, false otherwise or if called on a platform other than Android.

## Remarks:
[Learn more about android toasts notifications here.](https://developer.android.com/guide/topics/ui/notifiers/toasts)
