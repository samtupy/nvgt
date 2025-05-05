# `yaw`

Determines the current yaw of the character.

```nvgt
float get_yaw() property;
private void set_yaw(const float value) property;
```

## Remarks

Setting this property is explicitly disallowed to subclasses because it is typically a very unusual thing to do. Although it does not break the simulation, it is not normally something implementors should contemplate. There are alternative methods of achieving this, such as setting the rotation speed to a very high value. If you do wish to be able to set this property, you are free to override this function.