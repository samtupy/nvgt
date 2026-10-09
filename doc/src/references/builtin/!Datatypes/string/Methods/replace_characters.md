# replace_characters
Replace a group of characters with another group of characters, returning a new string.

`string string::replace_characters(const string&in character_list, const string&in replace_with);`

## Arguments:
* character_list: The list of characters to replace.
* replace_with: The characters to replace them with.

## Returns:
string: A new string with the replacements applied.

## Remarks
Characters are replaced in sequence: The first character in the list is replaced with the first character in the replace string, the second with the second and so on. Thus, `"ladies".replace_characters("ld", "bb")` will return "babies".

The comparison is case-sensitive. `"ladies".replace_characters("LD", "bb")` will still return "ladies".

If the replacement string is shorter than the character list, the remaining characters in the list will be erased.

If the replacement string is longer than the character list, excess characters are ignored.
