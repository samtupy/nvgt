# Debugging Scripts
One very useful feature of NVGT is the ability to debug the scripts that you write. This means being able to pause script execution at any time (either triggered manually or automatically), view what's going on and even make changes or inject code, and then resume the execution. You can even execute one statement in your code at a time to get an idea of exactly what it is doing.

## The -d or --debug option
To debug a script in nvgt, it is required that you use the command line version of nvgt (nvgt.exe). On platforms other than Windows, only a command line version is available.

There is a command line argument you must pass to nvgt.exe along with the script you want to run in order to debug it, which is either -d, or --debug depending on what you prefer.

So for example, open a command prompt or terminal and change directory to the place where you have stored your game. You could then run, for example, `nvgt -d mygame.nvgt` assuming a correct installation of nvgt, which would cause mygame.nvgt to be launched with the Angelscript debugger getting initialized.

## the debugging interpreter
When you run a script with the debugger, it will not start immediately. Instead, you will be informed that debugging is in progress, that the system is waiting for commands, and that you can type h for help.

If the last line on your terminal is \[dbg\]\> , you can be sure that the system is waiting for a debug command.

If you press enter here without first typing a command, the last major debugger action is repeated. This is not necessarily the last command you have typed, but is instead the last major action (continue, step into, step over, step out). The default action is to continue, meaning that unless you have changed the debugger  action, pressing enter without typing a command will simply cause the execution of your script to either begin or resume where it left off.

Pressing ctrl+c while the debug interpreter is open will exit out of nvgt completely similar to how it works if the debugger is not attached. Pressing this keystroke while the interpreter is not active will perform a user break into the debugger, meaning that your script will immediately stop executing and the debug interpreter will appear.

To list all available commands, type h and enter. We won't talk about all of the commands here, but will discuss a few useful ones.

## Useful debugging commands
* c: set debugger action to continue, execute until next breakpoint or manual break
* s: set debugger action to step into, only execute the next instruction
* n: set debugger action to step over, execute until next instruction in current function
* o: set debugger action to step out, execute until the current function returns
* e \<return-type\> \<expression\>: Evaluate a simple code statement, anything from a simple math expression to calling a function in your script.
* p \<value\>: print the value of any existing variable
* l: list various information, for example "l v" would list local variables
* b: set a function or file breakpoint, type b standalone for instructions
* a: abort execution (more graceful version of ctrl+c)

## registered debugging functions
If you are working with a troublesome bit of code, you may find that breaking into the debugger at a specific point is a very helpful thing to do. For this situation, NVGT has the `debug_break()` function.

This function will do nothing if called without a debugger attached or from a compiled binary, so it is OK to leave some calls to this around in your application so long as you are aware of them for when you run your script with the debugger. This function will immediately halt the execution of your script and cause the debugger interpreter to appear.

You can also programmatically add file and function breakpoints with the functions `void debug_add_file_breakpoint(string filename, int line_number)` and `void debug_add_func_breakpoint(string function_name)`.

## breakpoints
To describe breakpoints, we'll break (pun intended) the word into it's 2 parts and describe what the words mean in this context.
* When debugging, a break means pausing your script's execution and running the debugging interpreter.
* In this context, a point is either a file/line number combo or a function name which, if reached, will cause a debugger break.

For example if you type the debug command "b mygame.nvgt:31" and continue execution, the debugging interpreter will run and the script execution will halt before line31 of mygame.nvgt executes.

It is also possible to break into the debugger whenever a function is about to execute, simply by passing a function name instead of a file:line combo to the b debug command.

## notes
* It is worth noting that when the debugger interpreter is active, your script's execution is completely blocked. This means that any window you have shown will not be processing messages. Some screen readers don't like unresponsive windows that well, so be careful when breaking into the debugger while your game window is showing! Maybe in the future we can consider a setting that hides the game window whenever a debug break takes place.
* This debugger has not been tested very well in a multi-threaded context, for example we do not know what happens at this time if 2 threads call the debug_break() function at the same time. We intend to investigate this, but for now it's best to debug on the main thread of your application. In particular no commands exist as of yet to give contextual thread information.
