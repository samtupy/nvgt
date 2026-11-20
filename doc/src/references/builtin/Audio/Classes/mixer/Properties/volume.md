# volume
The volume of the mixer, applied to everything in it.

`float mixer::volume;`

## Remarks:
In the default engine this is in decibels, where 0 is full volume and lower values are quieter, and in an engine you create it is a linear gain where 1 is full volume and 0 is silent. A mixer's volume multiplies the volumes of the sounds and mixers in it, so a sound at -10 decibels in a mixer at -10 decibels is heard at -20.
