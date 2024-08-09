# datetime
This class stores an instance in time represented as years, months, days, hours, minutes, seconds, milliseconds and microseconds.

The class stores time independent of timezone, and thus uses UTC by default. You can use a calendar object in place of this one if you need to check local time, however it is faster to calculate time without needing to consider the timezone and thus any time difference calculations should be done with this object instead of calendar.

1. `datetime();`
2. datetime(double julian_day);
3. datetime(int year, int month, int day, int hour = 0, int minute = 0, int second = 0, int millisecond = 0, int microsecond = 0);

## Arguments (2):
* double julian_day: The julian day to set the time based on.

## Arguments (3):
* int year: the year to set.
* int month: the month to set.
* int day: the day to set.
* int hour = 0: the hour to set (from 0 to 23).
* int minute = 0: the minute to set (from 0 to 59).
* int second = 0: the second to set (0 to 59).
* int millisecond = 0: the millisecond to set (0 to 999).
* int microsecond = 0: the microsecond to set (0 to 999).

