# move_kinematic
Move a kinematic body to a target over time so that it pushes other bodies along the way.

`void physics_world::move_kinematic(const physics_body_id&in id, const vector&in target_pos, const quaternion&in target_rot, float delta_time);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* const vector&in target_pos: where the body should be after delta_time.
* const quaternion&in target_rot: how the body should be turned after delta_time.
* float delta_time: the number of seconds it should take, normally the delta_time you are about to pass to `update()`.

## Remarks:
This gives the body the velocity needed to arrive at the target during the next update, so moving platforms and doors carry and push the bodies they touch, which `set_position()` would not do.
