# boxes_intersect
Find out whether two rectangles on the x y plane, each of which may be rotated, overlap.

`bool boxes_intersect(float minx1, float maxx1, float miny1, float maxy1, float r1, float minx2, float maxx2, float miny2, float maxy2, float r2);`

## Arguments:
* float minx1: the lowest x of the first rectangle.
* float maxx1: the highest x of the first rectangle.
* float miny1: the lowest y of the first rectangle.
* float maxy1: the highest y of the first rectangle.
* float r1: the rotation of the first rectangle in radians.
* float minx2: the lowest x of the second rectangle.
* float maxx2: the highest x of the second rectangle.
* float miny2: the lowest y of the second rectangle.
* float maxy2: the highest y of the second rectangle.
* float r2: the rotation of the second rectangle in radians.

## Returns:
bool: true if the rectangles overlap, false otherwise.
