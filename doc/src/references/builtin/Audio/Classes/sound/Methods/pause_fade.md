# pause_fade
Fade the sound out and then pause it.

`bool sound::pause_fade(const uint64 length);`

## Arguments:
* const uint64 length: how long the fade takes, in milliseconds unless the engine was created with AUDIO_ENGINE_DURATIONS_IN_FRAMES, in which case it is in PCM frames.

## Returns:
bool: true if the fade was started.

## Remarks:
Pausing with a short fade, such as 50 milliseconds, avoids the click that cutting a sound off suddenly can make. Playing the sound again continues from where it was paused, at full volume.
