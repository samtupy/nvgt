# `grounded`

Determines if the player is on the ground for simulation purposes.

```nvgt
void set_grounded(const bool grounded) property final;
```

## Remarks

What is defined as the "ground" is left up to subclasses. For sane behavior, the "ground" is, by default, a vertical axis of 0 in the position vector. However, you are free to change this by overriding the `on_position_changed` callback. To lock the player at whatever you determine is the ground:

1. Set the vertical axis with respect to position and velocity to zero. Do not modify any other axis of either vector.
2. Set this property to true.

Note that gravity will always be applied, regardless of whether the player is on the ground or airborn. When overriding the `on_position_changed` callback, always implement some form of ground detection; should you fail to do so, the character will fall forever.