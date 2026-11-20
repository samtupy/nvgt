# set_friction
Set how much a body grips the things it slides against.

`void physics_world::set_friction(const physics_body_id&in id, float v);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* float v: the friction, where 0 is as slippery as ice and 1 is very grippy.

## Remarks:
When two bodies touch, their frictions are combined, so the surface with the greater friction counts for more. The default is 0.2.
