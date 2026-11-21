# secure
Whether the timer is protected against speed hacking tools.

`bool timer::secure;`

## Remarks:
A secure timer measures time with the system's wall clock, which speed hacking tools usually leave alone, whereas a normal timer uses a clock that these tools can tamper with. See the `speedhack_protection` global property for more information, including the drawback of a secure timer. This is set from the `speedhack_protection` property when the timer is created without specifying it.

Changing the property doesn't change the time that has elapsed on the timer.
