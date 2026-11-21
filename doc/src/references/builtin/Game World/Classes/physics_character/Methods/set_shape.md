# set_shape
Change the character's shape, for example to crouch.

`bool physics_character::set_shape(physics_shape@ shape, float max_penetration_depth = FLOAT_MAX);`

## Arguments:
* physics_shape@ shape: the new shape.
* float max_penetration_depth = FLOAT_MAX: the most the new shape may overlap the world for the change to be allowed. By default there is no limit.

## Returns:
bool: true if the shape was changed, false if the new shape would overlap the world too much, such as when trying to stand up under a low ceiling.
