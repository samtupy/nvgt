# `rotate_right_by`

Instructs the controller that it should begin rotation of the character to the right by the given amount on it's vertical axis.

```nvgt
void rotate_right_by(const float degree, const float step = 2.8125, const bool snap = false) final;
```

## Parameters

* `const float degree`: the amount by which to rotate the character, in degrees.
* `const float step`: Used for snapping degrees to the nearest compass point, this parameter allows you to change the granularity of snapping behaviors.
* `const bool snap`: Determines whether the target yaw will be snapped to the nearest valid compass point, or whether it will be used as is.

## Remarks

The methods `rotate_left_by` and `rotate_right_by` update the character's yaw by subtracting or adding a specified angle, respectively. When the `snap` parameter is enabled, the input angle is adjusted, or "snapped", to the nearest multiple defined by the `step` parameter. By default, the system uses a `step` value of `2.8125` degrees, which results from dividing 360 degrees by 128, corresponding to a Mariner’s compass with 128 discrete points. For cases where a different level of angular granularity is preferred, the `step` value can be recalculated; for instance, using `360/4` (`90.0` degrees) restricts rotation to the four cardinal directions, or using `360/8` (`45.0` degrees) allows both cardinal and intercardinal directions. Once the angle is snapped (if applicable), the method updates the target yaw, which is used in subsequent rotation updates to interpolate the actual yaw toward the target value.