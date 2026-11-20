# max_separation_distance
How far in meters from the character's shape a contact can be and still count when working out what the character is standing on.

`float physics_character::max_separation_distance;`

## Remarks:
The default is 0.05. Increase it if the character loses contact with the ground when moving down slopes or stairs.
