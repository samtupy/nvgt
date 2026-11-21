# resolve
Resolve a relative URI against this one, which should be absolute, replacing this URI with the result.

1. `void uri::resolve(const string&in relative_uri);`
2. `void uri::resolve(const spec::uri&in relative_uri);`

## Arguments:
* const string&in relative_uri: the URI to resolve, such as `../manual/` or `/downloads`. An absolute URI simply replaces this one.

## Remarks:
This follows the algorithm in section 5.2 of RFC 3986, the same one a web browser uses for the links on a page.
