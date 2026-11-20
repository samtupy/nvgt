# create_attachment
Create a splitter that sends audio both to a destination and to this reverb, for routing nodes that aren't sounds or mixers.

`audio_splitter_node@ reverb3d::create_attachment(audio_node@ dry_input = null, audio_node@ dry_output = null);`

## Arguments:
* audio_node@ dry_input = null: a node whose output is attached to the splitter's input, or null to attach something to it later.
* audio_node@ dry_output = null: the node that output bus 0 of the splitter, the unchanged audio, is attached to, or null to attach it later.

## Returns:
audio_splitter_node@: the splitter, whose output bus 1 is attached to the reverb3d, or null if one of the connections could not be made.

## Remarks:
Sounds and mixers don't need this, setting their `reverb3d` property creates and manages an attachment for them. The volume of an attachment made with this method is not updated as anything moves, so set it with `set_output_bus_volume(1, volume)` on the splitter, using `get_volume_at()` if you want it to follow the same rules as other sounds.
