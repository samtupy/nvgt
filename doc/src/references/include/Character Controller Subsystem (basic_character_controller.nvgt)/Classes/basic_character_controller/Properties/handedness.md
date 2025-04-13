# `handedness`

Determines whether this controller uses a left-or right-handed coordinate system. The default is to use a right-handed coordinate system.

```nvgt
coordinate_handedness get_handedness() property final;
void set_handedness(const coordinate_handedness value) property final;
```

## Remarks

For information on handedness and exactly how this alters the behavior of the controller, see the introduction to this class.

When changing this property, the forward and right vectors are automatically recomputed. No other properties are modified.

It is strongly recommended that the handedness of the controller only be altered when operating in a setting where a left-handed coordinate system is required (e.g., for operating with an audio engine which defaults to it). Changing this property should be rare in practice.

It is safe to assume that the value of this property is always in a valid state.

## Exceptions

An assertion failure occurs if neither of the valid enumeration values is provided to the setter of this property. An assertion failure also occurs in the constructor if an invalid value is supplied.