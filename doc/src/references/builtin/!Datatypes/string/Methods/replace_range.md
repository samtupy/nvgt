# replace_range
Replace a specified number of characters at the provided index with a new string.

`string string::replace_range(uint start, int count, const string&in replacement);`

## Arguments:
* uint start: The position to insert the new string.
* int count: The number of characters to replace.
* const string&in replacement: the string to insert.

## Returns:
string: the specified string with the replacement applied.

## Remarks
Note the word "replace" here implies the deletion of an old string and adding a new string in its place. A better, though still slightly ambiguous word might be "overwrite". It is similar, though by no means identical, to the following:
```
string.erase(start, count);
string.insert(start, replacement);
```

In the event of boundary errors (start + count >= length), an exception is thrown.

If count <= 0, no processing takes place.
