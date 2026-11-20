# stop
Pause the engine.

`bool audio_engine::stop();`

## Returns:
bool: true if the engine stopped.

## Remarks:
Nothing is played and no time passes for sounds while the engine is stopped. Call `start()` to resume.
