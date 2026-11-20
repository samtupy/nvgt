# read
Collect encoded data from an encoder opened to memory.

`string audio_encoder::read();`

## Returns:
string: the encoded data that has not been read yet.

## Remarks:
Some formats, such as Opus, can be read a piece at a time while encoding, which suits sending audio over a network. Others, such as WAV, need their header finished first, so they return nothing until the encoder has been closed, when the whole file is returned.
