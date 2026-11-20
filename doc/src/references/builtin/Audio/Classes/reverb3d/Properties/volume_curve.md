# volume_curve
The shape of the fade from `max_volume_distance` to `max_audible_distance`, between 0 and 1.

`float reverb3d::volume_curve;`

## Remarks:
The default is 0.4. At 0.5 the fade in decibels is even over the whole distance. Lower values keep the reverb loud for longer and then drop it quickly as the sound nears `max_audible_distance`, while higher values drop it quickly at first and then fade slowly. At 0 the reverb stays at `max_volume` at every distance, and at 1 it stays at `min_volume` beyond `max_volume_distance`.
