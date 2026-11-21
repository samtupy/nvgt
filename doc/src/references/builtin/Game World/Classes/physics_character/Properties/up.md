# up
The direction the character considers to be up.

`vector physics_character::up;`

## Remarks:
It is the direction opposite to the world's gravity at the time the character was created, and used to work out what is ground and how steep slopes are. It is set with a vector of any length, which is normalized.
