# set_range
Limit the source to a part of its audio, so that it behaves as though that part was all there is.

`bool audio_data_source::set_range(uint64 start_frame, uint64 end_frame);`

## Arguments:
* uint64 start_frame: the first frame of the range.
* uint64 end_frame: the frame after the last one of the range.

## Returns:
bool: true if the range was set.

## Remarks:
This lets one file hold several sounds, each played by limiting a source to its part.
