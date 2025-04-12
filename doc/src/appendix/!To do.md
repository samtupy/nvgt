# To do list
NVGT is still a relatively young project with many areas that need improvement, and there are also several long-term goals for this project that are not yet realized. This document attempts to keep track of any intended development activity that has not yet taken place, both for existing NVGT developers and for anyone looking to find a way to help contribute to the engine.

## User facing items
Items in this section generally effect end-users in some way and are not related directly to the codebase. Items may include classes we intend to add to the engine or areas of the website we wish to improve.

### Documentation
There has been absolutely loads of work so far put into documenting NVGT's API reference and feature set, but the task is not complete. Any contributions to the docs are welcome.

### examples
We have been holding off on these until the API stabalizes so that we don't teach people things that are soon to be changed and because we're limited to a public domain sound catelog, but we need to create several example projects that can help get people started with NVGT. Not just for the docs, but full runnable projects in the other repository. They should range from basic card game to small platformer to online client where people can walk around.

### Joystick object
The joystick class in NVGT is still a no-op interface. There has already been a bit of code to begin the process of wrapping SDL's joystick support, but it is not yet complete.

### tone_synth
Another object from BGT we have not yet reimplemented, though the beginnings of tone generation will appear in miniaudio.

### Speech dispatcher and the `tts_voice` object
Currently, NVGT's Speech Dispatcher implementation for Linux only works with the screen reader speech functions. At this time, we are still considering if we should implement it into the `tts_voice` object as well.

### VSCode extension
A plan that has existed for a few months now is to create a VSCode extension for Angelscript that works with NVGT scripts. To facilitate this we have wrapped a function called script_dump_engine_configuration, an example of which you can see in test/quick/dump_engine_config.nvgt. This function dumps a complete reference of everything registered in the engine, enough to compile scripts. This will, once time permits to learn the needed components, allow us to create an extension for VSCode that allows everything from symbol lookup to intellisense. As of 0.89.0 many of the function and method parameters have been properly named, which helps us get just a bit closer to this goal.

### JAWS keyhook
There has been loads of progress made with NVGT's JAWS keyhook, and it should now work in almost all senarios. The only thing to be aware of is that if JAWS crashes, you may have to alt+tab a couple of times. Other than that though, the keyhook is stable and useable!

### SDL dialog boxes
At the moment, we are using SDL's message box system to show simple dialogs rather than implementing it on our own. However, this implementation is not ideal for 3 reasons.
1. shortcuts with an ampersand don't work, we can't create a button called `&yes` that works with alt+y.
2. Copying text does not work with ctrl+c.
3. No internationalization, yes and no buttons are English on non-English windows.
Either we will see if SDL will improve message boxes soon, or switch to something else.

### Switch to miniaudio (in progress)
Currently we use the Bass audio library for sound output, which functionally speaking does work great. However Bass is not open source, and a commercial license must be purchased from [Un4seen](https://www.un4seen.com/bass.html) in order to sell commercial projects. For NVGT, this is not ideal and Bass was only used because it worked quite well at the time that NVGT was only being used to bolster Survive the Wild development with no opensource intentions. Instead, we plan to switch to [miniaudio](https://github.com/mackron/miniaudio) which is open source and in the public domain, and thus which will solve such commercial licensing issues. There has been much progress here and we are hopefully to have miniaudio integrated soon.

### Recording from a microphone
Especially since Survive the Wild has implemented voice chat support, people rightfully wonder how to record audio in NVGT. Survive the Wild does this with a plugin specifically designed for it's voice chat. The API is not one which we wish to support publicly as it is very limited and confined to stw's use case. This should come soon as miniaudio implementation has made much progress.

### Subscripting improvements
* NVGT allows a scripter to execute Angelscript code from within their Angelscript code, such as the python eval function. The user is given control of what builtin NVGT functions and classes these subscripts have access to, but it's still a bit rough. Basically Angelscript provides us with this 32 bit DWORD where we can map certain registered functions to bitflags and restrict access to them if a calling module's access bitmask doesn't include a flag the functions were registered with. However this means that we have 32 systems or switches to choose from, so either we need to assign builtin systems to them in a better way, or investigate this feature Angelscript has which is known as config groups and see if we can use them for permission control. C++ plugins in particular complicate this issue.
* Register asIScriptObject and asITypeInfo which would allow people to traverse script classes and execute functions in them.

### Provide user facing pack file encryption
Currently pack file encryption uses internal methods requiring a user to rebuild NVGT to change the encryption routines, but there is full intention of also adding a `pack.set_encryption` so that users of NVGT can also manage how their packs are encrypted. A secondary SQL based pack file object has been contributed to the project which does include this functionality though we still intend to make it a part of the smaller, primary pack object. A contributor is in the process of implementing this functionality to be included with miniaudio.

### CI improvements
NVGT is now set up to work with the Github releases page for it's next release, and at this time anyone can fork the project and run the release action to build the latest development version of the engine. However, the process isn't yet automated and we'd like to set up builds on some sort of schedule so that users can download the latest development NVGT for all platforms by just clicking a link. We also need to separate the public version docs with the development version docs on the website instead of showing the development version all the time, which is seriously confusing users of the public builds of the engine.

### anticheat
We have some pull requests open regarding anticheat particularly on windows, those should be finished up and merged.

### Angelscript version checks
One issue we run into relatively often is that someone will try building NVGT from source and then will report bytecode load errors to us because they're running from an outdated stub or something similar. We should encode the Angelscript version string into the bytecode payload and verify it upon application load. This way if bytecode gets attached to the wrong stub, we can catch it with a graceful error message instead of showing some random bytecode load aerror.

### get_last_error()
One area of NVGT that still needs heavy improvement is error handling. Some things use exceptions, some libraries have a get_error function, some things may use the backwards compatibility function get_last_error() etc. We need to find a way to unify this as much as possible into one system.

### library object
NVGT does have a library object similar to BGT which allows one to call into most standard dlls. However NVGT's library object is still rougher than BGT's and could do with some work, particularly we may switch to libffi or dyncall or something like that. This object in nvgt is so sub-par because the engine's open source nature combined with the c++ plugins feature deprioritised the fixing of this system to the point where it remained broken beyond the official prerelease of NVGT. The library object functions, but one may have an issue for example when working with various types of pointers.

### dictionary serialization
Currently, NVGT's dictionaries can only serialize bool, int, double and string. This is highly limiting. In Angelscript we can traverse the properties of any class instance and even read the properties from it. Therefor, at least so long as a class inherits from a certain base of some kind, the user should be able to serialize and deserialize full objects including graceful handling for class structures changing over time.

### force_key methods
A rare request is that we add bgt's force_key_down/force_key_up methods and friends to the engine, this is a good idea and we will do so. We are very close now with the new simulate_key_down and simulate_key_up functions, the only difference between these and the force methods is that the player still controls the keyboard E. simulate arrow down then real arrow down followed by real arrow up means arrow released, where as with bgt force methods the arrow key would stay forced down until manually reset.

### nvgt.dll
A very long-term goal is to export as much of the engine as possible into a cdll so that it's features can be integrated into anyone's programs in other languages.

### Very basic graphics
No work has been done here yet, but a goal of ours is to utilize sdl / sdlttf to allow audio game developers to draw at least basic text to the screen, if not much more.

### wrap more of Poco
Poco is a massive library with many useful classes that touch on many areas, from networking to a process launcher to our datetime facility to several other utilities. We want to wrap much more of this library, including but not limited to:
* configuration facility, it supports various formats and is extensable
* SMTP, we can send emails directly from nvgt game servers if we wrap this.
* more sockets, we've registered raw tcp socket and web_socket, we should register the datagram socket, dialog socket, raw socket and more, though some are pretty low priority.
* ProcessRunner and pipes or at least something similar to it, people want to capture process output.
* Logging facility potentially. Do we need it or do I just think it's cool?
* Notification queues for interthread communication.
* UUID, I've held off because it forces us to use their bsd3 licensed random number generator but it could still be useful.

### audio_form rewrite
While the current audio form will always be here for backwards compatibility, it is unfortunately very old code which keeps gaining appendage after appendage after hack after hack in order to keep working propperly. It is a nightmare to integrate into a game translation system, control objects are private, it's just getting hardre to maintain. We need to provide a new audio form instead of encouraging people to use the existing one. Someone has started working on one, but it is in early stages given my last update on the situation.

### input_box on Linux and Mobile
The input_box function is currently only implemented on Windows and MacOS, we need to get it working on all platforms.

### reactphysics3d
We're working on integrating a physics engine into NVGT for much more advanced games. There are many of these out there, we chose reactphysics3d because it builds on all of our desired platforms, it's not utterly massive, it seems to contain many of the features we can imagine needing and it does not come with a huge learning curb. Much work has been put into implementing reactphysics, though  most of it is on a different branch at this time called rp3d.

### tts_voice parameter scaling
In bgt, tts_voice parameters went from -10 to 10 for rate and pitch, and -100 to 0 for volume. However in NVGT, this currently differs per platform. We need to set up a couple of conversion functions that make bgt's old values work across the board, though possibly in floatingpoint so as to give NVGT users more precision if they desire it.

### package managers
This is a long-term goal, but consider figuring out how to create an apt repo / get on homebrew / other package managers for easy installs of NVGT.

### IOS
NVGT now has Android support, leaving one more target platform which is IOS!

### MacOS Code Signing
This is likely to be fixed very soon: Currently, it is not possible to code sign MacOS app bundles generated by NVGT, and the binaries in them do not have an executable bit set at this time. Once these issues are resolved, a vast portion of remaining MacOS issues will be resolved.

### Authenticode signing for official installers
Currently nvgt's official installers are unsigned and I am hoping to fix that.

### Android touchups
Android support is getting pretty stable, but there are a couple of areas that still need improvement. We still need to finish asset management, and so until that is done you must embed a pack file into your app for sounds to be played. More improvements to tts_voice will follow as well, you can only use the default voice at this time and parameter ranges may need adjustment. The gesture support though functional is still very young, and needs more testing and expansion.


## Code improvements
This section specifically lists tasks we wish to perform related to NVGT's c++ code, repository, or other backend. Other than performance, items here should rarely effect application functionality but are instead designed to allow developers to engage in a bit less painful wincing when reading or contributing to NVGT's code.

### types.h
Due to lack of experience towards the beginning of this project's development, our types are currently all over the place. There are random and completely unneeded mixes of asUINT, uint32_t, unsigned long, unsigned int, Poco::UInt32 and more all over the project. Instead we need to create types.h that define preferably types similar to angelscript (uint8, uint16, uint32, uint64) which we can use in the project, or at least we need to choose an existing set like Poco's or Angelscript's and stick with it consistently.

### Naming of globals
Along the same line, partly due to initial closed source intentions and also partly do to the use of sample Angelscript code, some of NVGT's global symbols are not named ideally. The best example right now is g_CommandLine vs. g_command_line_args. We need to decide on a scheme and stick to it unless forced by a dependency, and then do a quick symbol renaming session in vscode.

### Rewrite system_fingerprint.cpp
Currently we are using parts of an apache2 licensed library for system fingerprint generation. Not only is it a bit rough but it also uses several architecture specific assembly instructions at times when we probably don't need any. We should rewrite this to use our own system instead comprised of calls into Poco, SDL and other libraries that can return various bits of system information, or at the very least find a solid tiny dependency that can handle it for us. Legacy functions will still be provided.

### increased plugin security
Currently, one can achieve mischief by replacing a game's plugin dll with a hacked or modified version which uses the plugin's access to the underlying Angelscript engine to access sensative information within a game's loaded bytecode. While in the end we cannot prevent this entirely (it's a given downside when developing a plugin system like this that is still extensaable), but what we cann do is make it annoying. A pull request is already in progress which attempts to add cryptographic signatures to the plugin dlls loaded by a game which are verified by NVGT, at least applying an extra layer of annoyance/difficulty to anyone's attempt to go hacking around with an NVGT plugin, and it just needs some cleaning up/a bit of fixing before we can merge it. Anyone who is extremely worried about this will need to build NVGT from source with staticly linked plugins.

### Automated process to build platform specific dev packages
Currently when someone wants to build NVGT, they download something like windev.zip or macosdev.tar.gz or droidev.zip etc. That is helpful because many people who are in the middle between something like NVGT and getting started with C++ probably only want to change a few lines of NVGT and rebuild it. It's also helpful for speeding up our CI. However the problem is that these packages are manually maintained, when in reality we should be using something like vcpkg to set these up via a CI action of some sort.

### rewrite random.cpp somewhat
At the moment, I directly register the c interfaces of the public domain rnd.h library we are using with Angelscript. This however has created some undesirable issues, for example it's not possible to select a default rng, array.random() has several overloads for each type because they don't have a base class etc. Instead, create a base random interface with whatever generaters we want inheriting from it, then allow the user to select the default generator instance that the random() function uses.

### test cases
NVGT has a test runner, but it only tests a minimal subset of the engine at this time. Once we have more tests, we will hook the test runner up to the CI so we can instantly see if something goes wrong with engine.
