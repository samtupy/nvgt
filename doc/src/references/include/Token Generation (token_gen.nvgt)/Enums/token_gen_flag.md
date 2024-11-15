# token_gen_flag
This enum holds various constants that can be passed to the mode parameter in order to change how tokens are generated in the `generate_token` function.

* token_gen_flag_all: Uses all characters, numbers and symbols, see below.
* token_gen_flag_characters: Uses only characters, a-zA-Z
* token_gen_flag_numbers: Uses only numbers, 0-9
* token_gen_flag_symbols: Uses only symbols, \`\~\!\@\#\$\%\^\&\*\(\)\_\+\=\-\[\]\{\}\/\.\,\;\:\|\?\>\<
* token_gen_flag_numbers_symbols: Uses numbers and symbols.
* token_gen_flag_characters_symbols: Uses characters and symbols.
