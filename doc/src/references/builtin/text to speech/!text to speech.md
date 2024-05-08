# Text to speech
This section contains references for the functionality that allows for speech output. Both direct speech engine support is available as well as outputting to screen readers.

## Notes on the tts_voice class
NVGT implements a tiny [builtin fallback speech synthesizer](https://github.com/mattiasgustavsson/libs/blob/main/speech.h) that is used either when there is no speech engine available on the system, or if it is explicitly set with the tts_voice::set_voice() function. It sounds terrible, and is only intended for emergencies, after all understandable speech is better than no speech at all. It was used heavily when porting NVGT to other platforms, because it allowed focus to be primarily fixed on getting nvgt to run while individual tts engine support on each platform could be added later. If you don't want your end users to be able to select this speech synthesizer, initialize your tts_voice object with a single blank string ("") argument passed to the tts_voice constructor.

## Notes on screen Reader Speech functions
This set of functions lets you output to virtually any screen reader, either through speech, braille, or both. In addition, you can query the availability of speech/braille in your given screen reader, get the name of the active screen reader, and much more!

On Windows, we use the [Tolk](https://github.com/dkager/tolk) library. If you want screen reader speech to work on Windows, you have to make sure Tolk.dll, nvdaControllerClient64.dll, and SAAPI64.dll are in the lib folder you ship with your games.
