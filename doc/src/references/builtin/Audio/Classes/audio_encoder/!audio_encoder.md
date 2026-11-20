# audio_encoder
The base class of the encoders, which turn samples into an audio file format such as WAV or Opus.

## Remarks:
An audio_encoder is an audio_node with one input and one output bus, and has all of the methods and properties of audio_node as well as the ones listed here, which every encoder shares. It can't be created directly, create an audio_wav_encoder or an audio_opus_encoder instead.

After opening the encoder with `open()`, audio can be given to it in two ways. Calling `write()` encodes samples that the script has, such as from a decoder or a microphone. Attaching other nodes to the encoder's input instead records whatever passes through it, such as the output of a mixer while the game plays, and as the encoder passes its input on unchanged it can be placed between a mixer and the speakers without affecting what is heard.

Close the encoder with `close()` when finished, which completes the file.
