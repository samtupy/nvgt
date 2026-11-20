# reflections_width
How wide the stereo image of reflections is.

`float reflections_width;`

## Remarks:
The default is 4 and values are clamped between 0 and 8. Binaurally decoded reverb is highly correlated between the ears and sounds narrow, so the difference between the channels is multiplied by this value. 1 leaves the decoded reflections untouched and 0 makes them mono. This only has an effect on stereo output.
