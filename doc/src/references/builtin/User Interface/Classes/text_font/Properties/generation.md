# generation
A number that changes whenever a setting of the font that affects how text looks is changed, such as its size or style.

`const uint text_font::generation;`

## Remarks:
Code that caches rendered text can compare this to find out when to render it again.
