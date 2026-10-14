# get_keys
List all key names in a given section.

`string[] toml::get_keys(string name, bool all = false);`

## Arguments:
- `string name`: The name of the section. Can be blank if you want.
- `bool all = false`: Should the function fetch all keys of all sections? Note that this currently does not work if you have multiple keys with the same name.

## Returns:
`string[]`: An array containing all the keys.  An empty array means that the section is either blank or does not exist.
