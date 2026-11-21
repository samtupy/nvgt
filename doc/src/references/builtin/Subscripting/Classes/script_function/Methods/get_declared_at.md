# get_declared_at
Find out where the function was declared.

`string script_function::get_declared_at(int&inout row, int&inout column);`

## Arguments:
* int&inout row: receives the line of the declaration.
* int&inout column: receives the column of the declaration.

## Returns:
string: the name of the section the function is in, or an empty string if it isn't known.
