# opEquals
Overloads the == operator, comparing two planes.

`bool plane::opEquals(const plane&in other) const;`

## Arguments:
* const plane&in other: the plane to compare with.

## Returns:
bool: true if the normals and constants are equal.

## Remarks:
Two planes in the same place but facing opposite ways are not equal.
