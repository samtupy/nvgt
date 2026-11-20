# overlaps
Check whether another box overlaps this one.

`bool aabb::overlaps(const aabb&in other) const;`

## Arguments:
* const aabb&in other: the box to check.

## Returns:
bool: true if any part of the boxes overlap.

## Remarks:
`test_collision()` does the same.
