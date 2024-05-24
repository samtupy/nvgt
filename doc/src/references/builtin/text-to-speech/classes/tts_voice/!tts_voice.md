# tts_voice
This class provides a convenient way to communicate with all of the text-to-speech voices a user has installed on their system.

## Notes:
NVGT implements a tiny [builtin fallback speech synthesizer](https://github.com/mattiasgustavsson/libs/blob/main/speech.h) that is used either when there is no speech engine available on the system, or if it is explicitly set with the tts_voice::set_voice() function. It sounds terrible, and is only intended for emergencies, after all understandable speech is better than no speech at all. It was used heavily when porting NVGT to other platforms, because it allowed focus to be primarily fixed on getting nvgt to run while individual tts engine support on each platform could be added later. If you don't want your end users to be able to select this speech synthesizer, initialize your tts_voice object with a single blank string ("") argument passed to the tts_voice constructor.
