# Newlines
These string constants contain the character sequences used to end lines of text on different systems. They are in the `spec` namespace, so they must be written as `spec::NEWLINE_LF` and so on.

* spec::NEWLINE_CR: a carriage return (character 13), used by classic Mac OS.
* spec::NEWLINE_LF: a line feed (character 10), used by Linux, macOS, Android and most other Unix-like systems.
* spec::NEWLINE_CRLF: a carriage return followed by a line feed (characters 13 and 10), used by Windows and by many internet protocols.
* spec::NEWLINE_DEFAULT: the line ending of the platform the script is running on. This is the same as spec::NEWLINE_CRLF on Windows and spec::NEWLINE_LF everywhere else.

## Remarks
These are most often used with the line_converting_reader and line_converting_writer datastreams, which convert every line ending passing through them to the one you choose. Both use spec::NEWLINE_DEFAULT unless told otherwise.

## Example
```NVGT
void main() {
	string text = "first line" + spec::NEWLINE_CRLF + "second line";
	alert("Contains a Windows line ending", text.find(spec::NEWLINE_CRLF) > -1 ? "yes" : "no");
	alert("This platform uses Windows line endings", spec::NEWLINE_DEFAULT == spec::NEWLINE_CRLF ? "yes" : "no");
}
```
