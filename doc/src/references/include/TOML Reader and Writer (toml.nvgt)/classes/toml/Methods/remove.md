# remove
Removes a key or a section.

`bool toml::remove(string section, string key = "");`

## Arguments:
- `string section`: The section to remove or to look up the key from.
- `string key = ""`: The key to remove. If this is set to blank, the entire section (if any) will be removed.

## Returns:
`bool`: `true` if the key or the section was successfully removed, `false` otherwise.

## Remarks:
If the `key` argument is empty, the function will remove the entire section. Otherwise, it will remove a given key if exists.
