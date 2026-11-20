# physics_body_id
A physics_body_id identifies a body in a physics_world. It is a small value that is cheap to copy and store, returned by `physics_world::create_and_add_body()` and accepted by the methods of the world that read or change bodies. Ids are only meaningful for the world that made them.

1. `physics_body_id();`
2. `physics_body_id(uint raw_id);`
3. `physics_body_id(const physics_body_id&in other);`

## Arguments (2):
* uint raw_id: a value previously obtained from the `raw` property.

## Arguments (3):
* const physics_body_id&in other: the id to copy.

## Remarks:
A default constructed id is invalid. Ids are compared with `==`, and convert to a string so that they can be printed.

The index of an id identifies the slot a body occupies in the world, while its sequence number changes every time the slot is reused, so an id of a destroyed body does not accidentally refer to a new one.
