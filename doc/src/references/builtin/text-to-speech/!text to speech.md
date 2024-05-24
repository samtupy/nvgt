# Text to speech
This section contains references for the functionality that allows for speech output. Both direct speech engine support is available as well as outputting to screen readers.

## Notes on screen Reader Speech functions
This set of functions lets you output to virtually any screen reader, either through speech, braille, or both. In addition, you can query the availability of speech/braille in your given screen reader, get the name of the active screen reader, and much more!

On Windows, we use the [Tolk](https://github.com/dkager/tolk) library. If you want screen reader speech to work on Windows, you have to make sure Tolk.dll, nvdaControllerClient64.dll, and SAAPI64.dll are in the lib folder you ship with your games.
