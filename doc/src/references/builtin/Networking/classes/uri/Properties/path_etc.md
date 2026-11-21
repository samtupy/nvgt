# path_etc
The encoded path, query and fragment of the URI together, such as `/docs/?search=sound#top`.

`string uri::path_etc;`

## Remarks:
This is everything after the authority, and setting it parses it and sets path, query and fragment.
