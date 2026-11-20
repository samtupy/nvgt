# start
Begin producing audio.

`bool audio_engine::start();`

## Returns:
bool: true if the engine started.

## Remarks:
Engines start automatically unless AUDIO_ENGINE_NO_AUTO_START was passed to their constructor, or `stop()` was called.
