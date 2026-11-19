# legacy_sound
The legacy_sound plugin replaces NVGT's built-in sound system with the older, BASS based implementation that NVGT shipped with before its current audio engine was written. It exists so that older projects can keep running unchanged while they are migrated, and it should not be used for new projects.

To activate it, add the following line to your script:

`#pragma plugin legacy_sound`

When the plugin is active, it registers its own versions of the `sound`, `mixer` and `sound_environment` classes in place of the built-in ones, along with the legacy `pack` class documented here. The built-in `pack_file` class is still available, but when the legacy sound class loads a sound from a pack, that pack must be a legacy `pack`. Includes such as menu.nvgt, number_speaker.nvgt and bgt_compat.nvgt detect the plugin with `#if plugin_legacy_sound` and switch to the legacy pack class automatically.

Packs created by the legacy `pack` class use a different file format from those created by `pack_file`, and the two classes cannot open each other's files.
