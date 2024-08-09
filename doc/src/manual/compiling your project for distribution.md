# Compiling your project for distribution
Once your game is ready to be distributed to others, you may want to turn it into a compiled binary executable. This procedure assembles all the individual nvgt files of your source code into a single file that can run natively on its targeted operating system without having Nvgt available to interpret it.

## Here are some thoughts about reasons to do this:
* Doing this can let you make your work more a closed-source affair which limits the ease at which someone can reverse engineer your work and hack in changes if that is something you don't want to happen, which is probably the case if your game isn't a free one for sure.
* The end user will just be able to run the executable file natively, no need to have Nvgt installed. Just like a regular program they download anywhere else!
* Fewer files, especially if you have a lot of scripts included. That all can turn into just one file, except for the libraries, which can clean up the directory considerably.
* Stability. No need to worry about whether someone's going to be trying to run your code on an older or newer version of Nvgt with script-breaking changes.

## Some thoughts about reasons not to do this:
* Your project is open for all to hack and slash at, with the code readily available.
* You want people to be able to review your work for what ever reason. Since the code is right there, they can read it if they know how and determine what the code does if they so choose.
* You're creating tutorials or test scripts for others to learn by or to provide examples for how to do something or get feedback, such as trying to find a bug or teaching others how to do something in Nvgt. Hey, that's kinda the same thing as item 2!

## What is an executable file?
This will be sometimes called a binary. It's a file that is a complete program directly compatible with the operating system for which it is intended. It can be launched directly. 

## What about all the different operating systems?
Since Nvgt is intended to be able to run on Windows, Linux and Mac OS, there will be different executables for each targeted operating system. On windows, the resulting binary will have a .exe extension like other programs you may have seen. On other platforms though, there is no standard file extension for executable files.

e.g. if you compile my_game.nvgt on Windows you'll get a my_game.exe but if you compile on linux, you'll just get a file called my_game. Keep this in mind when trying to compile on a non-windows platform. If you have a file called my_game.nvgt and next to it is a directory called my_game, the compilation process will fail because my_game already exists and is a directory!

When compiling on a non-windows platform, the executable permission bitt on the resulting file is automatically set for you.

NVGT does support what is known as cross compiling projects, which means compiling a project on one platform that targets another one. For example, compiling a mac app on a windows computer. However, this support is still a bit rough and generally requires fiddling with command line options, configuration properties, manual app bundling etc and so the documentation for cross compiling will be written once this support becomes more stable in NVGT. The gist is that the --platform command line argument lets you select from auto, linux, mac or windows what type of executable you'd like to generate assuming you have the cross compilation stubs available.

## How to compile:
* on Windows, navigate to the main script file of your code (the one with the void main () function in it). For example it might be called my_game.nvgt
	* Right click the .nvgt file (you can use the context key or shift+f10) and expand the "Compile Script" sub menu.
		* Choose "debug" if you will want extra debugging information to be included in the program. This can be handy if you're working on it still and want to gain all information about any crashes that may happen that you can get.
		* Choose "release" if you don't want the extra debug information. You probably should always use release for anything you don't want others to be able to hack and slash at, since the debug information could make it easier on them.
	* ensure that the necessary library files are located in the same directory your new exe is, or within a lib folder there.
* On Linux, cd to the path containing a .nvgt script.
	* Now run /path/to/nvgt -c scriptname.nvgt where scriptname.nvgt should of course be replaced with the name of your script file.
* On Mac OS, cd to the directory containing a .nvgt script
	* Run the convoluted and to be improved command /applications/nvgt.app/Contents/MacOS/nvgt ``pwd``/scriptname.nvgt -I/applications/nvgt.app/Contents/Resources/include

You will receive a popup or STDOut print letting you know how long the compilation took. You should find a new file in the same folder you just compiled that has the same name it does but with a different extension e.g. when compiling my_game.nvgt you'll have my_game.exe. Distribute this along with the necessary libraries in what ever form is required. You can set it all up with an installer, such as Inno Setup, or if your game will be portable you can just zip it up, etc.

## Libraries needed for distribution:
There are a few libraries (dependencies) that Nvgt code relies on. When running from source, Nvgt is just interpreting your .nvgt scripts and using the libraries found in its own installation folder. Generally, if all is normal that will be:
* On Windows, c:\Nvgt
* On Linux, where you extracted NVGT's tarball to.
* On Mac OS, `/Applications/nvgt.app/Contents`

Within that folder you should have a subfolder that is called "lib" (or "Frameworks" on macOS). Lib contains the redistributable dependencies Nvgt uses for certain functionality. When you run from source, the Nvgt interpreter uses this very folder. However, when you compile, you must provide the files in the same directory as the compiled program so that it can find them. You may copy the entire lib folder to the location of the compiled game, or you can optionally just copy the files directly there if you don't want a lib folder for some reason. In other words, you can have a subdirectory within the program's directory called lib with the files inside, or you can also just place the dlls right in the program's directory where the binary is. On windows, you can omit some of the dll files not needed by your code, and we plan to add more and more support for this on other platforms as time goes on. A list is provided below of the basic purpose and importance of each library so you can hopefully know what to omit if you don't want all of them. These files must be included where ever the program ends up, so installers need to copy those over as well, and they should be included in any zip files for portable programs, etc.

At time of writing, the files are:
* bass.dll is required for the sound object and the tts_voice object, though will not be later once we switch from bass to the miniaudio library. The moment one of these objects exists in your script, your program will crash if this dll is not present.
* bassmix.dll is just as important as bass.dll and allows things like nvgt's mixer class to exist, where we can combine many bass channels into one. It is always required when bass.dll is used
* bass_fx.dll is used for reverb, filters, etc and is also required whenever bass.dll is used.
* polk.dll is how Nvgt interacts with Windows screen readers for speech and Braille output and support for direct interacting with SAPI text to speech.
* nvdaControllerClient64.dll used by Polk to speak and Braille through the NVDA screen reader.
* SAAPI64.dll used by Polk to speak and Braille through the System Access screen reader.
* git2.dll is the libgit2 library which allows people to programmatically access git repositories (can be good for adding version control to your online game's map world for example). You don't usually need it.
* git2nvgt.dll is the plugin for nvgt itself that wraps git2. So if your script does not include the line #pragma plugin git2nvgt, then you don't need either of the git2 dlls.
* nvgt_curl.dll is another plugin that wraps the libcurl library. It used to be the only way to do http requests, but it's now being phased out in favor of more portable options. It's only required if your script includes the line #pragma plugin nvgt_curl
* nvgt_sqlite.dll is similarly for interfacing with SQLite and is only needed if #pragma plugin nvgt_sqlite is defined.
* GPUUtilities.dll is used for the GPU acceleration of ray tracing used for geometric reverb in steam audio. It should always be completely optional.
* phonon.dll is steam audio, that's the HRTF and geometric reverb and cool things like that. You should only need it if you create a sound_environment class or set sound_global_hrtf=true in your script, but at time of writing, sound output using normal sound objects wasn't working as expected without this.
* TrueAudioNext.dll is more optional GPU acceleration for steam audio.
* systemd_notify.dll is a plugin wrapping the sd_notify linux function which can be useful if you are writing a systemd service. You probably do not need this otherwise.

These are organized here roughly in order of most critical to least, but it all depends generally on your project. The first few items are required for the game to even run, but the rest are only necessary if you're using them, and the documentation for using those plugins will ideally make that apparent.

## Detecting library availability
Sometimes, you might want to display a friendly error message to your users if a library is unavailable on platforms that allow you to do so rather than the application just crashing. You can do this with a function in NVGT called `bool preglobals()` which executes automatically similar to the main function but before any global variables that might tap into one of these libraries are ever initialized. It can return false to abort the execution of the application. Then, you can use the properties called SOUND_AVAILABLE and SCREEN_READER_AVAILABLE to safely determine if the subsystems could be loaded. The following code snippet would be OK, for example.
```
bool preglobals() {
	if (!SCREEN_READER_AVAILABLE) alert("error", "cannot load tolk.dll");
	else if (!SOUND_AVAILABLE) alert("error", "cannot load soundsystem");
	else return true; // success
	return false; // one of the libraries failed to load.
}
```

## Crediting open source libraries
NVGT is an open source project that uses open source dependencies. While aside from bass (which we will replace) we have been very careful to avoid any open source components that forbids or restricts commercial usage in any way, we do not always avoid dependencies that ask for a simple attribution in project documentation such as those under a BSD license. We'd rather focus on creating a good engine which we can fix quickly that can produce some epic games with awesome features, without needing to discard a library that implements some amazing feature just because it's devs simply ask users to do little more than just admit to the fact that they didn't write the library.

To facilitate the proper attribution of such libraries, a file called 3rd_party_code_attributions.html exists in the lib folder. We highly recommend that you distribute this file with your game in order to comply with all attribution requirements which you can read about in the aforementioned document.

The idea is that by simply distributing this attributions document within the lib folder of your app, any user who is very interested in this information can easily find and read it, while any normal game player will not stumble upon random code attributions in any kind of intrusive manner. The attributions document is currently well under 100kb, so it should not bloat your distribution.

The existing file attributes all open source components in NVGT, not just those that require it. If you want to change this, you can regenerate the file by looking in the doc/OSL folder in NVGT's github repository to see how.

For those who really care about not distributing this file, we hope to provide extra stubs in the future which do not include any components that require a binary attribution. However, there is no denying that this goal is very costly to reach and maintain, while yielding absolutely no true reward for all the time spent sans not needing to distribute an html file with game releases which players and even most developers will not be bothered by anyway. As such, it might be a while before this goal comes to fruition, and we could decide at any point that it is not a viable or worthwhile project to attempt if we find that doing so in any way detriments the development of NVGT, such as by making a feature we want to add very difficult due to lack of available public domain libraries for that feature.
