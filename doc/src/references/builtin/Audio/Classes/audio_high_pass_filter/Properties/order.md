# order
How steeply the filter cuts frequencies beyond its cutoff, from 1 to 8.

`uint audio_high_pass_filter::order;`

## Remarks:
Each step of order makes the cut about 6 decibels per octave steeper, so 2 is a gentle filter and 8 a very sharp one. Higher orders cost a little more processing. Values above 8 are treated as 8.
