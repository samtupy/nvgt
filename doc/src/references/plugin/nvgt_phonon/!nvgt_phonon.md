# nvgt_phonon
The nvgt_phonon plugin brings Steam Audio's world simulation to NVGT. Its main feature is the sound_environment class, which makes sounds in a physics_world sound like they are really there, muffled and quieter behind walls, sometimes heard through them, and with reverb that fits the size and materials of the room. It also provides Steam Audio's HRTF as an alternative to NVGT's built in one, and a phonon_binaural_node for applying it manually.

NVGT's own HRTF, used by `set_sound_global_hrtf()`, is derived from the Synthizer library by Austin Hicks (camlorn) and needs no plugin. You only need this plugin if you want sound_environment or Steam Audio's HRTF specifically.

To activate it, add the following line to your script:

`#pragma plugin nvgt_phonon`

A compiled game that uses the plugin will ship with the plugin's library (nvgt_phonon) and, where Steam Audio is built as a shared library (rare these days), with phonon too. See the section about shared libraries in the documentation on compiling your project for distribution if in doubt of what might get distributed with a game. If you are an advanced user who does not want to ship nvgt_phonon.dll or libnvgt_phonon.so with your games, you can compile the plugin statically instead.

The plugin adds these to the script engine:
* the `sound_environment` and `sound_environment_source` classes, with the `sound_environment_reflection_type` and `sound_environment_occlusion_type` enums,
* the `audio_panner_phonon_hrtf` and `audio_attenuator_phonon` values for selecting Steam Audio's panner and attenuator,
* the `phonon_binaural_node` class.
