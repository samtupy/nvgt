# Compiling your project for distribution
Once your game is ready to be distributed to others, you may want to turn it into a compiled binary executable, or perhaps even a complete bundle. The compilation procedure assembles all the individual nvgt files of your source code into a single file that can run natively on its targeted operating system without having Nvgt available to interpret it, and the bundling facility can then take that binary along with your sounds/assets, documentation, shared libraries/plugins as well as any other material your game requires and compress/bundle all of that into a complete package ready for you to directly share with the world.

## Here are some thoughts about reasons to do this:
* Doing this can let you make your work more of a closed-source affair which limits the ease at which someone can reverse engineer your work and hack in changes if that is something you don't want to happen, which is probably the case if your game isn't a free one for sure.
* The end user will just be able to run the executable file natively, no need to have Nvgt installed. Just like a regular program they download anywhere else!
* Fewer files, especially if you have a lot of scripts included. That all can turn into just one file, except for the libraries, which can clean up the directory considerably.
* Stability. No need to worry about whether someone's going to be trying to run your code on an older or newer version of Nvgt with script-breaking changes.

## Some thoughts about reasons not to do this:
* Your project is open for all to hack and slash at, with the code readily available.
* You want people to be able to review your work for what ever reason. Since the code is right there, they can read it if they know how and determine what the code does if they so choose.
* You're creating tutorials or test scripts for others to learn by or to provide examples for how to do something or get feedback, such as trying to find a bug or teaching others how to do something in Nvgt. Hey, that's kinda the same thing as item 2!

## What is an executable file?
This will be sometimes called a binary. It's a file that is a complete program directly compatible with the operating system for which it is intended. It can be launched directly, and is usually bundled along side sounds, shared libraries and other data required to run your game.

## What is a bundle?
A bundle, unlike a plain executable binary, is instead a full game package which contains everything your game needs to run including any sounds, shared libraries, and the aforementioned executable file. It might be a .zip that the user extracts, a .dmg on MacOS, a .apk file for android and similar for other supported platforms.

## What about all the different operating systems?
Since Nvgt is intended to be able to run on Windows, Linux, Mac OS and mobile platforms like Android and IOS, there will be different executables for each targeted operating system. On windows, the resulting binary will have a .exe extension like other programs you may have seen. On other platforms though, there is no standard file extension for executable files and on Android, you never see the executable directly but instead only the final .APK file as there is no reasonable way to run NVGT applications on mobile without fully bundling them first.

e.g. if you disable the bundling facility and then compile my_game.nvgt on Windows you'll get a my_game.exe but if you compile on linux, you'll just get a file called my_game. Keep this in mind when trying to compile on a non-windows platform. If you have a file called my_game.nvgt and next to it is a directory called my_game, the compilation process will fail because my_game already exists and is a directory!

When compiling on a non-windows platform, the executable permission bitt on the resulting file is automatically set for you.

## How to compile:
* on Windows, navigate to the main script file of your code (the one with the void main () function in it). For example it might be called my_game.nvgt
	* Right click the .nvgt file (you can use the context key or shift+f10) and expand the "Compile Script" sub menu. Each platform you'll see there has 2 options:
		* Choose "platform (debug)" if you will want extra debugging information to be included in the program. This can be handy if you're working on it still and want to gain all information about any crashes that may happen that you can get.
		* Choose "platform (release)" if you don't want the extra debug information. You probably should always use release for anything you don't want others to be able to hack and slash at, since the debug information could make it easier on them.
	* If you've disabled the bundling facility, ensure that the necessary library files are located in the same directory your new exe is, or within a lib folder there.
	* If you would rather, you can also run the nvgtw.exe program itself and use the buttons there to compile for any given platform.
* On Linux, cd to the path containing a .nvgt script.
	* Now run /path/to/nvgt -c scriptname.nvgt where scriptname.nvgt should of course be replaced with the name of your script file. You can select a platform with the -p argument E. -pwindows.
* On Mac OS, it's best to just click on the NVGT application directly.
	* After launching NVGT you can select compile a script in release/debug mode, choose a platform, and browse to your script file.
	* If, however, you wish to build on MacOS using the command line, cd to the directory containing a .nvgt script and run the command /applications/nvgt.app/Contents/MacOS/nvgt -c scriptname.nvgt, or alternatively open -a nvgt --args -c \`pwd\`/scriptname.nvgt

You will receive a popup or STDOut print letting you know how long the compilation took. You should find a new file in the same folder you just compiled that has the same name it does but with a different extension e.g. when compiling my_game.nvgt you'll have my_game.exe. Distribute this along with the necessary libraries in what ever form is required. You can set it all up with an installer, such as Inno Setup, or if your game will be portable you can just zip it up, etc.

## Configuring the bundling facility:
NVGT tries to provide a one-click bundling facility, that is, clicking the compile option on an NVGT script will directly create a package that you can distribute to your end users with little hastle. You don't need to go searching for libraries, you don't need too learn how app bundles on MacOS or Android APK files work, you can just build your game into a distribution ready package.

While this is a very powerful system that does work out of the box, it likely needs input from you if it is to produce the most optimal results. The facility needs to know where your assets are, it is best if it knows what version your game is / a good display name string for the app (used on various platforms), and various other options allow for anything from custom app manifest files to custom system commands that you can cause to be executed before or after a successful compile.

Other than including assets like sounds, most inputs to the bundling facility are provided via configuration options. Usually a file called .nvgtrc containing configuration directives is created along side a project, though it can also be called gamename.properties, gamename.json or gamename.ini where gamename is the name of your main nvgt script without the extension. You can learn more about the configuration subsystem specifically in the toolkit configuration tutorial, which includes a list of every available bundling option.

All of the bundling related options are in the build section of the configuration. So if you want to disable the bundling facility entirely on windows for your project, for example, you might add the line build.windows_bundle = 0 to your .nvgtrc file which would cause a standalone executable to be created when the game is compiled rather than a full bundle. If the bundling facility is not for you at all, you can disable it globally by creating a file alongside the nvgt.exe application itself called config.properties with the same key, more details and alternate configuration filenames are also described in the configuration tutorial.

Many of the directives here allow you to control how your product is identified to end users and to the systems the app is running on. While some are purely for display, others are manditory in certain situations especially when you plan to distribute your app on networks like the app store, google play and similar.

If you plan to release your game on MacOS, IOS, or Android, it is highly recommended that you create what's known as a reverse domain identifier for your app by setting the build.product_identifier property. It's called the reverse domain identifier because the format is like a website in reverse, such as com.samtupy.nvgt. In mild cases it might be used to group similar apps together E. the operating system or distribution service can implicitly tell that apps with an identifier starting with com.samtupy all belong to the same company, but in extreme cases this identifier might be used by the system as the main way your app is identified, such as on Android for example where the filesystem paths to the apps data folders actually include this identifier. The identifier can contain periods, uppercase / lowercase letters, and numbers, so long as a number is not the first character following a period. There should be at least 2 period delimited segments in this identifier (prefferably at minimum 3), and it might be a good idea to limit the first segment to popular top level domains like com, org, net etc. While in reality a couple of other characters like dashes and underscores might work in identifiers, they may not be as platform agnostic as the rules listed above. It is not important that the reverse website/app identifier you come up with here actually exists on the internet. If you do not provide this value, the default is com.NVGTUser.scriptname where scriptname is the name of the NVGT file passed to the compiler without the extension. It is possible, however, to only customize the com.NVGTUser part if you want NVGT to use the script filename to derive the rest of the identifier for you. So for example if you know that all games you'll be developing on your computer will be from the company com.epicdevelopers, you can set the key build.product_identifier_domain = com.epicdevelopers in nvgt's global config files. Now when you compile mygame.nvgtt, the full reverse domain identifier for that app will be set to com.epicdevelopers.mygame.

Unfortunately, different operating systems and services use different versioning schemes. Windows and MacOS really want version numbers in major.minor.patch format, in fact the windows version resource actually contains 4 binary words in it's structure to store each period separated version component. While the parsed format isn't actually embedded into a binary structure on MacOS, it's still manditory as soon as you want to distribute your game in the app store, because that service reads such a property from the bundle to identify the version of the app to track updates. As such, the build.product_version_semantic property must be set for MacOS app store distributions, while on windows it is an optional display feature that will cause version information to show for your compiled executable. On the other hand, Android and the google play store use an integer version code to track when a given version of an APK is newer than any installed version. This simple requirement makes it very easy to manage this property automatically on android, it is done by dividing the unix timestamp in seconds by 60, you can also set the build.product_version_code property if you wish to control this manually. Finally, the build.product_version configuration option allows you to set, where possible, the version string that is actually displayed to end users.

Another configuration option worth mentioning is the build.shared_library_excludes property. This defaults to the string "plist TrueAudioNext GPUUtilities systemd_notify sqlite git2 curl", meaning that by default the shared libraries for plugins are not bundled. As such, you may need to replace this property with your own list of excludes if you use any of NVGT's plugins. We intend to make this step unnecessary, instead determining the list of plugin libraries based on the plugin pragmas contained in the script. So for example if you wanted to include the curl plugin at the moment, you might set the property build.shared_library_excludes = "plist TrueAudioNext GPUUtilities systemd_notify sqlite git2" in your project's configuration file.

To include assets like sounds and documents into your bundle, the asset and document pragmas are used. A pragma is a type of code statement, similar to `#include,` that allows you to feed NVGT various extra information about your game. For example if one wants to bundle the sounds.dat file with their product, they can add the line of code`#pragma asset sounds.dat` to the top level of one of any .nvgt files that make up the project, or `#pragma document changelog.txt` to include a text file intended for the user rather than the game to access.

The asset and document pragmas are very similar, on  most platforms indeed they do the same thing. The distinction is that in some cases it can be useful for NVGT to know whether an included asset is intended for access by the game or by the user. The changelog and readme documents for your game should be included as documents rather than assets, for example, because they are included outside the .app folder within a .dmg bundle on MacOS as opposed to assets which are placed in the MacOS/Content/Resources directory, which may be inconvenient for the user to access. Similar distinction is applied on other platforms when required/possible.

Sometimes you may have a file that you wish to include as an asset, but as a different name in the bundle than that of the file stored on disk. To do this, you can express the asset pragma like `#pragma asset sounds.dat;audio.dat` if you want sounds.dat to actually be called audio.dat in the bundle. The asset and document pragmas will copy/include directories recursively. For example if you have a folder called sounds, the code `#pragma asset sounds` will successfully include the entire sounds folder in your bundle.

## Libraries needed for distribution:
The following information can be helpful if you have disabled NVGT's bundling facility and you wish to package your compiled games yourself.

There are a few libraries (dependencies) that Nvgt code relies on. When running from source, Nvgt is just interpreting your .nvgt scripts and using the libraries found in its own installation folder. Generally, if all is normal that will be:
* On Windows, c:\Nvgt
* On Linux, where you extracted NVGT's tarball to.
* On Mac OS, `/Applications/nvgt.app/Contents`

Within that folder you should have a subfolder that is called "lib" (or "Frameworks" on macOS). Lib contains the redistributable dependencies Nvgt uses for certain functionality. When you run from source, the Nvgt interpreter uses this very folder. However, when you compile, you must provide the files in the same directory as the compiled program so that it can find them. You may copy the entire lib folder to the location of the compiled game, or you can optionally just copy the files directly there if you don't want a lib folder for some reason. In other words, you can have a subdirectory within the program's directory called lib with the files inside, or you can also just place the dlls right in the program's directory where the binary is. On windows, you can omit some of the dll files not needed by your code, and we plan to add more and more support for this on other platforms as time goes on. A list is provided below of the basic purpose and importance of each library so you can hopefully know what to omit if you don't want all of them. These files must be included where ever the program ends up, so installers need to copy those over as well, and they should be included in any zip files for portable programs, etc. Again remember that NVGT usually handles this for you and this step is only required if you wish to create your own bundles by hand.

At time of writing, the files are:
* bass.dll is required for the sound object and the tts_voice object, though will not be later once we switch from bass to the miniaudio library. The moment one of these objects exists in your script, your program will crash if this dll is not present.
* bassmix.dll is just as important as bass.dll and allows things like nvgt's mixer class to exist, where we can combine many bass channels into one. It is always required when bass.dll is used
* bass_fx.dll is used for reverb, filters, etc and is also required whenever bass.dll is used.
* nvdaControllerClient64.dll used to speak and Braille through the NVDA screen reader.
* SAAPI64.dll used to speak and Braille through the System Access screen reader.
* ZDSRAPI.dll used to speak and Braille through the ZDSR screen reader.
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
	if (!SCREEN_READER_AVAILABLE) alert("error", "cannot load screen reader components");
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
