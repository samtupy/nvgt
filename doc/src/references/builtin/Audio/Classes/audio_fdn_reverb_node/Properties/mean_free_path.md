# mean_free_path
The average time in seconds between reflections, which is how large the room sounds, between 0 and 0.5.

`float audio_fdn_reverb_node::mean_free_path;`

## Remarks:
The default is 0.1. For a real room, 4 times its volume divided by its surface area and by the speed of sound, 343 meters per second, is a good estimate, which is about 0.01 for a small room and 0.05 or more for a hall.
