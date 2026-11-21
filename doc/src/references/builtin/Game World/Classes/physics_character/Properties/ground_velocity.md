# ground_velocity
How fast the ground the character is standing on is moving.

`const vector physics_character::ground_velocity;`

## Remarks:
This is zero for static ground and non zero on a moving platform, which a character should add to its own movement to be carried along.
