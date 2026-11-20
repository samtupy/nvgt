# play_wait
Play the sound and wait for it to finish before returning.

`bool sound::play_wait();`

## Returns:
bool: true if the sound played to its end, false if it couldn't be played.

## Remarks:
The script does nothing else while the sound plays, so this is mostly useful for simple programs and examples. A sound that is looping never finishes, and one being streamed with `stream_pcm()` can't be waited for.
