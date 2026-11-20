# gain
The master gain of the engine in decibels.

`const float audio_engine::gain;`

## Remarks:
This is read only. To change it call `set_gain()`. A value of 0 is unchanged, 6 is about twice as loud and -6 about half.
