# physics_transform
A physics_transform is a position and a rotation together, as returned by `physics_world::get_transform()`. It is a plain value that is copied when assigned.

1. `physics_transform();`
2. `physics_transform(const vector&in position, const quaternion&in rotation);`
3. `physics_transform(const physics_transform&in other);`

## Arguments (2):
* const vector&in position: the position.
* const quaternion&in rotation: the rotation.

## Arguments (3):
* const physics_transform&in other: the transform to copy.

## Remarks:
A default constructed transform has no position and no rotation, which is `IDENTITY_TRANSFORM`. Transforms can be compared with `==`. Besides the `position` and `rotation` properties, the plain numbers they are made of are available as `px`, `py` and `pz` for the position and `qx`, `qy`, `qz` and `qw` for the rotation.
