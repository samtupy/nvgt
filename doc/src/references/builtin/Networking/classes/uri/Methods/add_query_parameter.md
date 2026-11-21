# add_query_parameter
Add a parameter to the query of the URI, percent encoding its name and value.

`void uri::add_query_parameter(const string&in param, const string&in value = "");`

## Arguments:
* const string&in param: the name of the parameter, which must not be empty.
* const string&in value = "": the value of the parameter. If empty, the parameter is added as `name=`.

## Remarks:
Unlike setting the query property, this also encodes any & and = characters in the name and value, so they can contain anything.
