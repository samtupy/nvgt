# `translate_yaw_to_direction`

Translates the given yaw to a direction string.

```nvgt
string translate_yaw_to_direction(const float yaw);
```

## Parameters

* `const float yaw`: the yaw to translate to a direction.

## Returns

`string`: the direction string that this yaw would correspond to.

## Remarks

This function uses the Mariner's compass, which has 128 points and has some direction strings not typically scene outside specific applications or domains. This function includes these rarer points for completeness.

This function is a utility function provided so that it is one less thing you need to implement.