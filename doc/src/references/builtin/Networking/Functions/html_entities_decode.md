# html_entities_decode
Replace the HTML entities in a string, such as `&amp;`, `&lt;` or `&#233;`, with the characters they stand for.

`string html_entities_decode(const string&in input);`

## Arguments:
* const string&in input: the text to decode, such as text taken from a web page.

## Returns:
string: the decoded text, in UTF-8.
