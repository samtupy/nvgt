# joystick_power_level
Represents various charging states of a joystick.

* JOYSTICK_POWER_UNKNOWN: the charging state is unknown.
* JOYSTICK_POWER_EMPTY: the battery is empty (<= 5%).
* JOYSTICK_POWER_LOW: the battery is low (<= 20%).
* JOYSTICK_POWER_MEDIUM: the battery is medium (<= 70%).
* JOYSTICK_POWER_FULL: the battery is full (<= 100%).
* JOYSTICK_POWER_WIRED: the joystick is currently plugged in.
    * Note: it is not possible to get the battery level of the joystick while it is charging.
