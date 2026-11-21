# user_agent
The User-Agent header sent with requests, which identifies the program making them.

`string http::user_agent;`

## Remarks:
This defaults to `nvgt` followed by NVGT's version. Setting it to an empty string restores the default. It applies to requests started after it is set.
