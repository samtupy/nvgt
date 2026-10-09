# Time Units
These constants give the length of common units of time in microseconds. They are int64 values.

* MICROSECONDS: 1.
* MILLISECONDS: 1000.
* SECONDS: 1000000.
* MINUTES: 60000000.
* HOURS: 3600000000.
* DAYS: 86400000000.

## Remarks
NVGT measures time internally in microseconds, so these constants make it easy to convert to and from other units. Multiply a number of units by the matching constant to get microseconds, or divide a number of microseconds by it to convert back.

They are also used as timer accuracies. A timer's `accuracy` property, the accuracy argument of the timer constructor and the `timer_default_accuracy` global property all take one of these values, and determine which unit a timer's elapsed value is reported in. For example, a timer with an accuracy of SECONDS counts in seconds.

A timespan can also be constructed from, compared with, or added to a number of microseconds, so these constants can be used with it directly.

## Example
```NVGT
void main() {
	timespan t(90 * SECONDS);
	alert("90 seconds as a timespan", t.format());
	timer seconds_timer(0, SECONDS);
	wait(1500);
	alert("Elapsed seconds", seconds_timer.elapsed);
}
```
