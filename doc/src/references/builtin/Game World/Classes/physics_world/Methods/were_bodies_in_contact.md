# were_bodies_in_contact
Check whether two bodies were touching at the last update.

`bool physics_world::were_bodies_in_contact(const physics_body_id&in a, const physics_body_id&in b) const;`

## Arguments:
* const physics_body_id&in a: the first body.
* const physics_body_id&in b: the second body.

## Returns:
bool: true if the bodies were in contact.

## Remarks:
To be told when contacts start and end rather than checking, use `set_contact_listener()`.
