# set_shape
Give the mixer a shape, so that it is heard from the closest point of the shape to the listener rather than from a single point.

`bool mixer::set_shape(ref@ shape);`

## Arguments:
* ref@ shape: the shape, such as a sound_aabb_shape, or null to make the mixer a point again.

## Returns:
bool: true if the shape was set, false if it is null or of a type that can't be used as a sound shape.

## Remarks:
Shapes suit sounds that fill an area, such as a river, a crowd or the hum of a room, where the sound should come from the nearest part of the area and surround the listener when they are inside it. Once a shape is set, `set_position_3d()` moves the shape.
