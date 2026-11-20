# is_normalized
Check whether the quaternion has a length of 1.

`bool quaternion::is_normalized(float tolerance = 1.0e-5f) const;`

## Arguments:
* float tolerance = 1.0e-5f: how far the length may be from 1.

## Returns:
bool: true if the quaternion is normalized to within the tolerance.
