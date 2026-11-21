# Subscripting
This section contains the classes and functions for compiling and running AngelScript code while a game is running, which is known as subscripting.

Subscripting lets a game load code that isn't part of it, such as levels, items or quests written by the game's developers or players, scripts that server administrators can change without restarting the server, or a console for running code while debugging. The code is compiled into a script module of its own, separate from the game's code in the nvgt_game module, and the game then calls the functions in it.

* script_module holds the code. Get one with script_get_module(), add code to it, build it and initialize its global variables with reset_globals(), then find its functions and global variables.
* script_function is a function of a module, which can be called with a dictionary of arguments or retrieved into a funcdef handle and called like any other function.

The code in a module can only use the parts of NVGT allowed by its access mask, set with script_module::set_access_mask(), so that code from players can be kept away from files, the network and the operating system. Functions of the game can be shared with a module by importing them, and classes with the shared keyword.

The Subscripting Tutorial in the manual explains these concepts in depth, with a complete example.
