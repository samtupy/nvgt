# max_slope_angle
The steepest slope the character can stand on, in radians.

`float physics_character::max_slope_angle;`

## Remarks:
The default is 50 degrees (about 0.87 radians). On steeper ground the character slides and `ground_state` is PHYSICS_GROUND_STATE_ON_STEEP_GROUND.
