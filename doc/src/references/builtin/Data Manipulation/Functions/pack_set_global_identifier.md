# pack_set_global_identifier
Set the global identifier of all your packs (e.g. the first 8-bytes that determine if you have a valid pack or not).

`bool pack_set_global_identifier(const string&in ident);`

## Arguments:
* const string&in ident: the new identifier (see remarks).

## Returns:
bool: true if the identifier was properly set, false otherwise.

## Remarks:
* The default pack identifier is "NVPK" followed by 4 NULL bytes.
* Your pack identifier should be 8 characters or less. If it's less than 8 characters, 0s will be added as padding on the end. If it's larger than 8, the first 8 characters will be used.
* NVGT will refuse to open any pack files that do not match this identifier.
