# Screen Reader Speech
This set of functions lets you output to virtually any screen reader, either through speech, braille, or both. In addition, you can query the availability of speech/braille in your given screen reader, get the name of the active screen reader, and much more!

## Notes
On Windows, we use the [Tolk](https://github.com/dkager/tolk) library. If you want screen reader speech to work on Windows, you have to make sure Tolk.dll, nvdaControllerClient64.dll, and SAAPI64.dll are in the lib folder you ship with your games.
