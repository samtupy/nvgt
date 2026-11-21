# is_relative
Whether the URI is a relative reference, which has no scheme.

`const bool uri::is_relative;`

## Remarks:
Relative references such as `../images/logo.png` are usually resolved against an absolute URI with resolve().
