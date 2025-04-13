# `nearest_compass_point`

Snaps the provided yaw to the closest compass point based on `step`.

```nvgt
float nearest_compass_point(const float deg, const float step = 2.8125);
```

## Parameters

* `const float deg`: the yaw that should be adjusted.
* `const float step`: the granularity of the adjustment performed.
