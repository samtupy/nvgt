# `target_yaw`

Determines the target yaw to which the character should rotate.

```nvgt
void set_target_yaw(const float value) property;
float get_target_yaw() property;
```

## Remarks

This property can be used to instruct the controller to orient the player to any arbitrary yaw. If the value exceeds 360 or is negative, the behavior is undefined. The controller will attempt to automatically correct for this problem when handling rotation, but depending on this behavior is strongly discouraged.

Note that setting this property does not immediately cause a rotation to occur. Rotation will be performed per frame (that is, every time `update` is called with a steady `delta_time`). This ensures that rotation feels natural to the player. If you wish to cause an immediate rotation, expose a way for your character controller subclass to force `yaw` to a specific value. This behavior is, however, discouraged, but it should not break the simulation if you do so.