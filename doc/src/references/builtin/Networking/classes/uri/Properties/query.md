# query
The decoded query of the URI, the part after the question mark without it.

`string uri::query;`

## Remarks:
Decoding turns %26 back into &, so a parameter whose name or value contains an encoded ampersand becomes ambiguous. Use raw_query or get_query_parameters() in that case.

Setting the query percent encodes it, but leaves ampersands alone so that they still separate parameters, and encodes any percent encoding it already contains a second time. To set a query that is already encoded use raw_query, and to build one from names and values use add_query_parameter(), which encodes them properly.
