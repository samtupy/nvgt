# token_gen_flag
This enum holds various constants that can be passed to the mode parameter of the generate_token function in order to control what characters appear in results.

* TOKEN_CHARACTERS = 1: Allows for characters, a-zA-Z
* TOKEN_NUMBERS = 2: Allows for numbers, 0-9
* TOKEN_SYMBOLS = 4: Uses only symbols, \`\~\!\@\#\$\%\^\&\*\(\)\_\+\=\-\[\]\{\}\/\.\,\;\:\|\?\>\<

## Remarks:
These are flags that should be combined together using the bitwise OR operator. To generate a token containing characters, numbers and symbols, for example, you would pass `TOKEN_CHARACTERS | TOKEN_NUMBERS | TOKEN_SYMBOLS` to the mode argument of generate_token. The default flags are `TOKEN_CHARACTERS | TOKEN_NUMBERS`.
