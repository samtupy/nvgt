# is_near_zero
Check whether the vector is so short that it is practically zero.

`bool vector::is_near_zero(float max_dist_sq = 1.0e-12f) const;`

## Arguments:
* float max_dist_sq = 1.0e-12f: the largest squared length that counts as zero.

## Returns:
bool: true if the vector's squared length is no more than max_dist_sq.
