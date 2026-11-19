# replace_range_this
Replace a specified number of characters at the provided index with a new string, modifying the calling string.

`string& string::replace_range_this(uint start, int count, const string&in replacement);`

## Arguments:
* uint start: The position to insert the new string.
* int count: The number of characters to replace.
* const string&in replacement: the string to insert.

## Returns:
string&: a two-way reference to the specified string with the replacement applied.

## Remarks
Note the word "replace" here implies the deletion of an old string and adding a new string in its place. A better, though still slightly ambiguous word might be "overwrite". It is similar, though by no means identical, to the following:
```
string.erase(start, count);
string.insert(start, replacement);
```

If start is out of bounds, or count <= 0, no processing takes place and the string is left unmodified.
