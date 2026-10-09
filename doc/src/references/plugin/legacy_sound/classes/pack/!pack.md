# pack
The legacy pack class, which reads and writes pack files in the format used by NVGT before the `pack_file` class was introduced. It is only available when the legacy_sound plugin is loaded.

`pack();`

## Remarks:
A pack is a single file that contains many other files, usually the sounds and other assets of a game. Unlike `pack_file`, a legacy pack can be opened for appending, and files can be deleted from it or replaced in place.

New projects should use the built-in `pack_file` class instead. This class is documented so that existing projects can be maintained while they are migrated.
