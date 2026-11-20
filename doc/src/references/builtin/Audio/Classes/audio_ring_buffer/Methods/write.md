# write
Add frames to the buffer.

`uint audio_ring_buffer::write(const float[]@ frames);`

`uint audio_ring_buffer::write(const memory_buffer<float>& frames);`

## Arguments:
* frames: the samples to add, interleaved when there is more than one channel.

## Returns:
uint: the number of frames that were added, which is fewer than given if the buffer didn't have room for all of them.

## Remarks:
Check `available_write` first if you need to know whether everything will fit.
