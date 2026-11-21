# version
The version of the UUID, which says how it was generated.

`const int uuid::version;`

## Remarks:
1 is time based, 3 name based with MD5, 4 random, 5 name based with SHA1, 6 time based ordered by time and 7 time based with Unix time, which sorts in order of creation.
