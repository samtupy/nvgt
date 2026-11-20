# physics_ground_state
This is a list of the states a character can be in with respect to the ground, returned by `physics_character::ground_state`.

* PHYSICS_GROUND_STATE_ON_GROUND: the character is standing on ground that it can walk on.
* PHYSICS_GROUND_STATE_ON_STEEP_GROUND: the character is touching ground that is too steep to stand on, so it would slide down. See `physics_character::max_slope_angle`.
* PHYSICS_GROUND_STATE_NOT_SUPPORTED: the character is touching something below it, such as the edge of a ledge, that is not enough to support it.
* PHYSICS_GROUND_STATE_IN_AIR: the character is not touching anything below it.
