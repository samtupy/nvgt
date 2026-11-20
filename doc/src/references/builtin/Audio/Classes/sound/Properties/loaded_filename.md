# loaded_filename
The name of the file that the sound was loaded from.

`const string sound::loaded_filename;`

## Remarks:
This is the filename exactly as it was given to `load()` or `stream()`. It is empty if nothing is loaded, and a placeholder such as `:pcm` for sounds loaded from memory or samples.
