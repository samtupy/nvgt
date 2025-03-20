# initialize_section
Returns a TOML section with the given name, creating if necessary.

`toml_section@ toml::initialize_section(string name = "", bool create = false);`

## Arguments:
- `string name = ""`: The name of the section to retrieve. An empty string always means the main sectionless.
- `bool create = false`: Should this section be created if it does not exist?

## Returns:
`toml_section@`: The `toml_section` class on success, null otherwise.
