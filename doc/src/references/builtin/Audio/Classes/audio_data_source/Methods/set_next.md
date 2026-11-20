# set_next
Set a source to continue with when this one reaches its end.

`bool audio_data_source::set_next(audio_data_source@ new_next);`

## Arguments:
* audio_data_source@ new_next: the source to play next, or null for none.

## Returns:
bool: true if it was set.

## Remarks:
Sources can be chained like this to play one after another without a gap, such as the parts of a piece of music. The sources must have the same format.
