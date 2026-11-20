# set_loop_point
Set the part of the source that is repeated when it loops.

`bool audio_data_source::set_loop_point(uint64 start_frame, uint64 end_frame);`

## Arguments:
* uint64 start_frame: the frame that looping goes back to.
* uint64 end_frame: the frame at which looping goes back to the start frame.

## Returns:
bool: true if the loop point was set.

## Remarks:
This suits music with an introduction that plays once before the main part repeats. Looping must also be turned on with `set_looping()`, or by playing a sound that plays this source with `play_looped()`.
