# half_extent
How far the plane goes in every direction from the point on it that is closest to the shape's origin, which is also how deep the solid part behind the plane is.

`const float physics_plane_shape::half_extent;`

## Remarks:
Nothing collides with the plane outside of this area, which is what the shape's `local_bounds` covers.
