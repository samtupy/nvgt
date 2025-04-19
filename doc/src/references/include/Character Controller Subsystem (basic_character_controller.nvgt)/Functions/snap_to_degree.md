# `snap_to_degree`

Attempts to snap the degree to any of the given points. The behavior is undefined if no points are provided.

```nvgt
float snap_to_degree(const float deg, const float[] snaps);
```

## Parameters

* `const float deg`: the current yaw
* `const float[] snaps`: the list of valid compass points to pick from.

## Remarks

The points that callers provide should be whole numbers only. Fractional numbers may work, but are not guaranteed.

## Exceptions

An assertion error is triggered if the provided yaw is less than 0 or greater than 360.