# max_volume_distance
The distance from the listener at which a sound is sent to the reverb at `max_volume`.

`float reverb3d::max_volume_distance;`

## Remarks:
The default is 7. Closer than this the send volume moves between `min_volume` and `max_volume`, and further away it fades out towards `max_audible_distance`.
