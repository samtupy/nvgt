# uuid_generate_time
Generate a new time based UUID including the MAC address of one of the computer's network adapters.

`uuid uuid_generate_time();`

## Returns:
uuid: the new UUID, which is version 1.

## Remarks:
An exception is thrown if the computer has no network adapter, uuid_generate() falls back to a random UUID instead.
