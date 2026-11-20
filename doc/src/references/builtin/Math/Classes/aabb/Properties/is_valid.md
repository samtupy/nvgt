# is_valid
Whether the box is valid, meaning that its minimum is not past its maximum on any axis.

`const bool aabb::is_valid;`

## Remarks:
A default constructed box is not valid, until it has been given a point with `encapsulate()`.
