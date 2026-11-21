# validate_email_address
Check whether a string looks like a valid email address.

`bool validate_email_address(const string&in address);`

## Arguments:
* const string&in address: the address to check, such as `sam@example.com`.

## Returns:
bool: true if the address has a valid form, false otherwise.

## Remarks:
This only checks the form of the address with a regular expression that accepts the common forms, it doesn't find out whether the address exists. Addresses with a name, such as `Sam <sam@example.com>`, aren't accepted.
