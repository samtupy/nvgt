# Date Time Formats
These string constants contain format strings and regular expressions for common, standardized ways of writing dates and times.

## Format strings
Each format string can be passed to the `format()` method of the datetime, timestamp or calendar classes to produce a date in that format, or to `parse_datetime()` to read one. The example output shown for each is for 2:30:15 PM UTC on Monday, 5 October 2026.

* DATE_TIME_FORMAT_ISO8601: ISO 8601, `%Y-%m-%dT%H:%M:%S%z`, for example `2026-10-05T14:30:15Z`.
* DATE_TIME_FORMAT_ISO8601_FRAC: ISO 8601 with fractional seconds, `%Y-%m-%dT%H:%M:%s%z`, for example `2026-10-05T14:30:15.250000Z`.
* DATE_TIME_FORMAT_RFC822: the format from RFC 822, used by older email headers, `%w, %e %b %y %H:%M:%S %Z`, for example `Mon, 5 Oct 26 14:30:15 GMT`.
* DATE_TIME_FORMAT_RFC1123: the format from RFC 1123, which updates RFC 822 to use a four digit year, `%w, %e %b %Y %H:%M:%S %Z`, for example `Mon, 5 Oct 2026 14:30:15 GMT`.
* DATE_TIME_FORMAT_RFC850: the format from RFC 850, used by older Usenet messages, `%W, %e-%b-%y %H:%M:%S %Z`, for example `Monday, 5-Oct-26 14:30:15 GMT`.
* DATE_TIME_FORMAT_RFC1036: the format from RFC 1036, `%W, %e %b %y %H:%M:%S %Z`, for example `Monday, 5 Oct 26 14:30:15 GMT`.
* DATE_TIME_FORMAT_HTTP: the format used in HTTP headers, `%w, %d %b %Y %H:%M:%S %Z`, for example `Mon, 05 Oct 2026 14:30:15 GMT`.
* DATE_TIME_FORMAT_ASCTIME: the format produced by the C asctime() function, `%w %b %f %H:%M:%S %Y`, for example `Mon Oct  5 14:30:15 2026`.
* DATE_TIME_FORMAT_SORTABLE: a format that sorts correctly as plain text, `%Y-%m-%d %H:%M:%S`, for example `2026-10-05 14:30:15`.

## Regular expressions
Each of these constants contains a regular expression that matches a date written in the corresponding format. They can be used with `regexp_match()` or the regexp class to check whether a string contains a date in a particular format before trying to parse it.

* DATE_TIME_REGEX_ISO8601
* DATE_TIME_REGEX_RFC822
* DATE_TIME_REGEX_RFC1123
* DATE_TIME_REGEX_RFC850
* DATE_TIME_REGEX_RFC1036
* DATE_TIME_REGEX_HTTP
* DATE_TIME_REGEX_ASCTIME
* DATE_TIME_REGEX_SORTABLE

The ISO8601 regular expression also matches dates written in the ISO8601_FRAC format, so there is no separate DATE_TIME_REGEX_ISO8601_FRAC constant.

## Example
```NVGT
void main() {
	datetime now;
	string text = now.format(DATE_TIME_FORMAT_HTTP);
	alert("The current time in HTTP format", text);
	alert("Matches the HTTP date pattern", regexp_match(text, DATE_TIME_REGEX_HTTP) ? "yes" : "no");
	int tzd;
	datetime@ parsed = parse_datetime(DATE_TIME_FORMAT_HTTP, text, tzd);
	alert("Parsed back as ISO 8601", parsed.format(DATE_TIME_FORMAT_ISO8601));
}
```
