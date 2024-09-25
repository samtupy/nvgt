# refresh_window
Updates the game window, pulling it for any new events and responding to messages from the operating system.

`void refresh_window();`

## Remarks:
You do not need to call this function yourself so long as you use the recommended wait() function in your game's loops, as wait() implicitly calls this function. We provide refresh_window() standalone unless you want to use your own / a different sleeping mechanism such as nanosleep, in which case you do need to manually pull the window using this function.

For UI windows to function on the vast mejority of operating systems, they must maintain a constant stream of communication between the operating system and the program that created them. If a window stops receiving and handling such communications for even a few seconds, it will first become laggy before the operating system decides that the window has gone dead and begins reporting that the application is in a not responding or busy state.

To solve this problem in NVGT applications, refresh_window() is provided to do all of this message handling for you in one repeated function call. This function will pull the operating system for any new messages or events and process them, updating the states of functions like key_pressed, get_characters etc. If it is not repeatedly called in some way, your entire application will be disfunctional.
