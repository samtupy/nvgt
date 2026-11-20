# min_volume
The volume in decibels at which a sound at the listener's position is sent to the reverb.

`float reverb3d::min_volume;`

## Remarks:
The default is -7. The send volume rises from this to `max_volume` as the sound moves out to `max_volume_distance`.
