# uuid_create_from_name_sha1
Create a UUID from a name, which is always the same for the same namespace and name, using SHA1.

`uuid uuid_create_from_name_sha1(const uuid&in namespace_id, const string&in name);`

## Arguments:
* const uuid&in namespace_id: the namespace the name belongs to, such as uuid_namespace_dns() for host names, or any UUID of your own.
* const string&in name: the name.

## Returns:
uuid: the UUID of the name, which is version 5.

## Remarks:
This gives an item a stable identifier derived from something already unique about it, such as a player's account name.
