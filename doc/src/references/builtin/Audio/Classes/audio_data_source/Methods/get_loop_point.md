# get_loop_point
Get the part of the source that is repeated when it loops.

`void audio_data_source::get_loop_point(uint64&out start_frame, uint64&out end_frame) const;`

## Arguments:
* uint64&out start_frame: set to the frame that looping goes back to.
* uint64&out end_frame: set to the frame at which it goes back.
