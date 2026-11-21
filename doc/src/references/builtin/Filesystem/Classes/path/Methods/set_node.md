# set_node
Set the node of the path, the server name in a Windows UNC path such as `\\server\share`.

`spec::path& path::set_node(const string&in node);`

## Arguments:
* const string&in node: the node to set. A non-empty node makes the path absolute.

## Returns:
spec::path&: this path, so calls can be chained.

## Remarks:
The current node can be read with the node property.
