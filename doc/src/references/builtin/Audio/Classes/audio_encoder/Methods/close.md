# close
Finish encoding, writing anything still waiting and completing the file.

`bool audio_encoder::close();`

## Returns:
bool: true if the encoder was closed.

## Remarks:
A file isn't complete until the encoder is closed, so close it before using the file. This also happens when the encoder is destroyed.
