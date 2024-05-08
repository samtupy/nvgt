# user interface
This section contains all functions that involve directly interacting with the user, be that by showing a window, checking the state of a key, or placing data onto the users clipboard. These handle generic input such as from the keyboard, and also generic output such as an alert box.

## Window management notes:
* You can only have one NVGT window showing at a time.
* without an nvgt window, there is no way to capture keyboard and mouse input from the user.
* It is strongly advised to always put `wait(5);` in your main loops. This prevents your game from hogging the CPU, and also prevents weird bugs with the game window sometimes freezing etc.
