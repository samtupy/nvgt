# uuid_create_from_name_md5
Create a UUID from a name, which is always the same for the same namespace and name, using MD5.

`uuid uuid_create_from_name_md5(const uuid&in namespace_id, const string&in name);`

## Arguments:
* const uuid&in namespace_id: the namespace the name belongs to, such as uuid_namespace_dns() for host names, or any UUID of your own.
* const string&in name: the name.

## Returns:
uuid: the UUID of the name, which is version 3.

## Remarks:
uuid_create_from_name() does the same with SHA1, which is preferred for new uses. This function exists for compatibility with identifiers that were already created with MD5.
