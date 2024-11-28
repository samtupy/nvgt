# To do list
NVGT is still a relatively young project with many areas that need improvement, and there are also several long-term goals for this project that are not yet realized. This document attempts to keep track of any intended development activity that has not yet taken place, both for existing NVGT developers and for anyone looking to find a way to help contribute to the engine.

## User facing items
Items in this section generally effect end-users in some way and are not related directly to the codebase. Items may include classes we intend to add to the engine or areas of the website we wish to improve.

### Documentation
There has been absolutely loads of work so far put into documenting NVGT's API reference and feature set, but the task is not complete. Any contributions to the docs are welcome.

### Joystick object
The joystick class in NVGT is still a no-op interface. There has already been a bit of code to begin the process of wrapping SDL's joystick support, but it is not yet complete.

### tone_synth
Another object from BGT we have not yet reimplemented, we are considering [tonic](https://github.com/TonicAudio/Tonic) for this but are very open to other suggestions as not much research as been done yet here.

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

### Switch to miniaudio
Currently we use the Bass audio library for sound output, which functionally speaking does work great. However Bass is not open source, and a commercial license must be purchased from [Un4seen](https://www.un4seen.com/bass.html) in order to sell commercial projects. For NVGT, this is not ideal and Bass was only used because it worked quite well at the time that NVGT was only being used to bolster Survive the Wild development with no opensource intentions. Instead, we plan to switch to [miniaudio](https://github.com/mackron/miniaudio) which is open source and in the public domain, and thus which will solve such commercial licensing issues. This project has started, but there is still much to do here.

### Recording from a microphone
Especially since Survive the Wild has implemented voice chat support, people rightfully wonder how to record audio in NVGT. Survive the Wild does this with a plugin specifically designed for it's voice chat. The API is not one which we wish to support publicly as it is very limited and confined to stw's use case. Potentially after the switch to miniaudio but maybe before, we will wrap a microphone class in NVGT which will provide a stable API to capturing system audio.

### Consider access permissions for subscripting
NVGT allows a scripter to execute Angelscript code from within their Angelscript code, such as the python eval function. The user is given control of what builtin NVGT functions and classes these subscripts have access to, but it's still a bit rough. Basically Angelscript provides us with this 32 bit DWORD where we can map certain registered functions to bitflags and restrict access to them if a calling module's access bitmask doesn't include a flag the functions were registered with. However this means that we have 32 systems or switches to choose from, so either we need to assign builtin systems to them in a better way, or investigate this feature Angelscript has which is known as config groups and see if we can use them for permission control. C++ plugins in particular complicate this issue.

### Provide user facing pack file encryption
Currently pack file encryption uses internal methods requiring a user to rebuild NVGT to change the encryption routines, but there is full intention of also adding a `pack.set_encryption` so that users of NVGT can also manage how their packs are encrypted. A secondary SQL based pack file object has been contributed to the project which does include this functionality though we still intend to make it a part of the smaller, primary pack object.

### Integrate with Github releases
Currently, NVGT is downloaded from nvgt.gg/downloads instead of from Github releases. While it is likely that the mirror at nvgt.gg/downloads will remain in place, we plan to update our CI and properly use Github tags/releases.

### Angelscript version checks
One issue we run into relatively often is that someone will try building NVGT from source and then will report bytecode load errors to us because they're running from an outdated stub or something similar. We should encode the Angelscript version string into the bytecode payload and verify it upon application load. This way if bytecode gets attached to the wrong stub, we can catch it with a graceful error message instead of showing some random bytecode load aerror.

### get_last_error()
One area of NVGT that still needs heavy improvement is error handling. Some things use exceptions, some libraries have a get_error function, some things may use the backwards compatibility function get_last_error() etc. We need to find a way to unify this as much as possible into one system.

### library object
NVGT does have a library object similar to BGT which allows one to call into most standard dlls. However NVGT's library object is still rougher than BGT's and could do with some work, particularly we may switch to libffi or dyncall or something like that. This object in nvgt is so sub-par because the engine's open source nature combined with the c++ plugins feature deprioritised the fixing of this system to the point where it remained broken beyond the official prerelease of NVGT. The library object functions, but one may have an issue for example when working with various types of pointers.

### force_key methods
A rare request is that we add bgt's force_key_down/force_key_up methods and friends to the engine, this is a good idea and we will do so. We are very close now with the new simulate_key_down and simulate_key_up functions, the only difference between these and the force methods is that the player still controls the keyboard E. simulate arrow down then real arrow down followed by real arrow up means arrow released, where as with bgt force methods the arrow key would stay forced down until manually reset.

### IOS
NVGT now has Android support, leaving one more target platform which is IOS!

### Android touchups
Android support is getting pretty stable, but there are a couple of areas that still need improvement. We still need to finish asset management, and so until that is done you must embed a pack file into your app for sounds to be played. More improvements to tts_voice will follow as well, you can only use the default voice at this time and parameter ranges may need adjustment. The gesture support though functional is still very young, and needs more testing and expansion.


## Code improvements
This section specifically lists tasks we wish to perform related to NVGT's c++ code, repository, or other backend. Other than performance, items here should rarely effect application functionality but are instead designed to allow developers to engage in a bit less painful wincing when reading or contributing to NVGT's code.

### types.h
Due to lack of experience towards the beginning of this project's development, our types are currently all over the place. There are random and completely unneeded mixes of asUINT, uint32_t, unsigned long, unsigned int, Poco::UInt32 and more all over the project. Instead we need to create types.h that define preferably types similar to angelscript (uint8, uint16, uint32, uint64) which we can use in the project, or at least we need to choose an existing set like Poco's or Angelscript's and stick with it consistently.

### Naming of globals
Along the same line, partly due to initial closed source intentions and also partly do to the use of sample Angelscript code, some of NVGT's global symbols are not named ideally. The best example right now is g_CommandLine vs. g_command_line_args. We need to decide on a scheme and stick to it unless forced by a dependency, and then do a quick symbol renaming session in vscode.

### Rewrite system_fingerprint.cpp
Currently we are using parts of an apache2 licensed library for system fingerprint generation. Not only is it a bit rough but it also uses several architecture specific assembly instructions at times when we probably don't need any. We should rewrite this to use our own system instead comprised of calls into Poco, SDL and other libraries that can return various bits of system information, or at the very least find a solid tiny dependency that can handle it for us.

