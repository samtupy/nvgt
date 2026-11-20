# datasource
The audio_data_source that the sound is playing from, or null if nothing is loaded.

`const audio_data_source@ sound::datasource;`

## Remarks:
The sound and its data source share the same audio, so reading details from either gives the same answers, and the same object is returned every time. Use the data source for what the sound doesn't offer itself, such as `set_loop_point()`, `set_range()` or chaining sources with `set_next()`. These are best set while the sound isn't playing.

For things that both offer, prefer the sound's own methods and properties. Most of them, such as `length`, `looping` and `get_data_format()`, simply pass through to the data source, so using either makes no difference beyond readability. Changing the position is the exception:
* `sound::seek()` hands the new position to the audio thread, which moves the data source before it next reads from it, and keeps the timing of the sound's fades and scheduled starts and stops in step. Seeking the data source directly moves it at once from the script, which can happen while the audio thread is in the middle of reading from it, and leaves those timings behind.
* After a sound has played to its end, `play()` starts it again from the beginning, overriding a position set on its data source in the meantime, whereas a position set with `sound::seek()` is kept.
* Calling `read()` or `skip_frames()` on the data source of a sound takes that audio away from the sound, which skips ahead by however much was read. To analyse audio without disturbing a sound, open the file separately with an audio_decoder.
