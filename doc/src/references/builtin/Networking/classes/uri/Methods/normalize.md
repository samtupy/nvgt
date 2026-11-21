# normalize
Remove the `.` and `..` segments from the path, other than leading ones.

`void uri::normalize();`

## Remarks:
If the first segment of a relative path contains a colon, such as a Windows drive letter, `./` is put in front of it as RFC 3986 requires.
