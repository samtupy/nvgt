# uuid_generate
Generate a new time based UUID, falling back to a random one if the computer has no network adapter.

`uuid uuid_generate();`

## Returns:
uuid: the new UUID, which is version 1, or 4 if it is random.

## Remarks:
Time based UUIDs include the MAC address of one of the computer's network adapters, which some may consider private. uuid_generate_random() includes nothing about the computer.
