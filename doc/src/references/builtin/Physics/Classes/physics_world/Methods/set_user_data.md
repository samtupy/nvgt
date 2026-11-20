# set_user_data
Attach a value of your own to a body.

`void physics_world::set_user_data(const physics_body_id&in id, any@ data);`

## Arguments:
* const physics_body_id&in id: the body to operate on, as returned by `create_and_add_body()`.
* any@ data: the value to store, or null to clear it.

## Remarks:
This is a convenient way to find the game object that a body belongs to, for example when a contact listener or a ray reports a body. It is released when the body is destroyed.
