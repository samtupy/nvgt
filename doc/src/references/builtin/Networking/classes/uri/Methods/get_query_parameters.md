# get_query_parameters
Get the parameters of the query as names and values.

`array<array<string>>@ uri::get_query_parameters(bool plus_as_space = true) const;`

## Arguments:
* bool plus_as_space = true: whether plus signs are decoded as spaces, as they are in the queries web forms submit.

## Returns:
array<array<string>>@: a list of parameters in the order they appear, each an array holding the name and then the value, both decoded.
