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

### AVSpeech and speech dispatcher
Currently other than voice over support, the only speech output NVGT can produce on Linux and MacOS is based on a verry bad sounding RSynth derivative that is included as a fallback synthesizer intended to be used in an emergency situation where the user needs to know that their primary synth failed to load. We intend to wrap AVSpeechSynthesizer on MacOS and speechd on Linux to solve this problem.

### Switch to miniaudio
Currently we use the Bass audio library for sound output, which functionally speaking does work great. However Bass is not open source, and a comercial license must be purchased from [Un4seen](https://www.un4seen.com/bass.html) in order to sell comercial projects. For NVGT, this is not ideal and Bass was only used because it worked quite well at the time that NVGT was only being used to bolster Survive the Wild development with no opensource intentions. Instead, we plan to switch to [miniaudio](https://github.com/mackron/miniaudio) which is open source and in the public domain, and thus which will solve such comercial licensing issues.

### Consider access permissions for subscripting
NVGT allows a scripter to execute Angelscript code from within their Angelscript code, such as the python eval function. The user is given control of what builtin NVGT functions and classes these subscripts have access to, but it's still a bit rough. Basically Angelscript provides us with this 32 bit DWORD where we can map certain registered functions to bitflags and restrict access to them if a calling module's access bitmask doesn't include a flag the functions were registered with. However this means that we have 32 systems or switches to choose from, so either we need to assign builtin systems to them in a better way, or investigate this feature Angelscript has which is known as config groups and see if we can use them for permission control. C++ plugins in particular complicate this issue.

### get_last_error()
One area of NVGT that still needs heavy improvement is error handling. Some things use exceptions, some libraries have a get_error function, some things may use the backwards compatibility function get_last_error() etc. We need to find a way to unify this as much as possible into one system.


## Code improvements
This section specifically lists tasks we wish to perform related to NVGT's c++ code, repository, or other backend. Other than performance, items here should rarely effect application functionality but are instead designed to allow developers to engage in a bit less painful wincing when reading or contributing to NVGT's code.

### types.h
Due to lack of experience towards the beginning of this project's development, our types are currently all over the place. There are random and completely unneeded mixes of asUINT, uint32_t, unsigned long, unsigned int, Poco::UInt32 and more all over the project. Instead we need to create types.h that define preferably types similar to angelscript (uint8, uint16, uint32, uint64) which we can use in the project, or at least we need to choose an existing set like Poco's or Angelscript's and stick with it consistently.

### Naming of globals
Along the same line, partly due to initial closed source intentions and also partly do to the use of sample Angelscript code, some of NVGT's global symbols are not named ideally. The best example right now is g_CommandLine vs. g_command_line_args. We need to decide on a scheme and stick to it unless forced by a dependency, and then do a quick symbol renaming session in vscode.

