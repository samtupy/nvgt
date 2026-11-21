# uuid_generate_time_v7
Generate a new UUID from the current Unix time and random bits, whose string sorts in order of creation.

`uuid uuid_generate_time_v7();`

## Returns:
uuid: the new UUID, which is version 7.

## Remarks:
This is a good choice for identifiers used as keys in a database, as new ones sort after old ones, and it doesn't reveal anything about the computer.
