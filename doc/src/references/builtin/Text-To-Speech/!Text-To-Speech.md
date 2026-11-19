# Text to speech
This section contains references for the functionality that allows for speech output. Both direct speech engine support is available as well as outputting to screen readers.

## Notes on screen Reader Speech functions
This set of functions lets you output to virtually any screen reader, either through speech, braille, or both. In addition, you can query the availability of speech/braille in your given screen reader, get the name of the active screen reader, and much more!

On Windows, macOS and Linux, screen reader output goes through the [Prism](https://github.com/ethindp/prism) library, which is licensed under the Mozilla Public License 2.0 and built into NVGT, so no extra files need to be shipped with your games. Prism talks to the screen reader that is running, such as NVDA, JAWS, ZDSR, System Access, ZoomText or Narrator on Windows, VoiceOver on macOS, and Orca on Linux, falling back to Speech Dispatcher on Linux when Orca isn't available. The screen reader functions never fall back to a plain text to speech engine such as SAPI; use the `tts_voice` object for that.
