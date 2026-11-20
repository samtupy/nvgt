# get_friction
Get how much a body grips the things it slides against.

`float physics_world::get_friction(const physics_body_id&in id) const;`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.

## Returns:
float: the friction, where 0 is as slippery as ice and 1 is very grippy.
