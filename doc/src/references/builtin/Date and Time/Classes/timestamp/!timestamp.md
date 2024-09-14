# timestamp
Stores a unix timestamp with microsecond accuracy and provides methods for comparing them.
1. timestamp();
2. timestamp(int64 epoch_microseconds);

## Arguments 2:
* int64 epoch_microseconds: the initial value of the timestamp

## Remarks:
If a timestamp object is initialize with the default constructor, it will be set to the system's current date and time.
The unix epoch began on January 1st, 1970 at 12 AM UTC.
