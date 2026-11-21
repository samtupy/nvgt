# make_scale_valid
Get the closest scale to a given one that the shape can be stretched by exactly.

`vector@ physics_shape::make_scale_valid(const vector&in scale) const;`

## Arguments:
* const vector&in scale: the scale that is wanted.

## Returns:
vector@: a scale for which `is_valid_scale()` is true.

## Remarks:
For example a sphere can only be scaled evenly, so `vector(1, 2, 3)` becomes the same amount along every axis. Compare the result with the scale you wanted to find out whether the shape will look very different from what you expected.
