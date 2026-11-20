# decay
How much of each echo is fed back into the delay to make the next one, from 0 to 1.

`float audio_delay_node::decay;`

## Remarks:
0 makes a single echo, and values closer to 1 make more echoes that fade more slowly. A value of 1 or more makes echoes that never fade.
