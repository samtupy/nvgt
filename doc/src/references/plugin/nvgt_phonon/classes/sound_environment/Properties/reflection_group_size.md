# reflection_group_size
How many meters apart sounds can be and still share a reflection group.

`float reflection_group_size;`

## Remarks:
The default is 3 and values are clamped between 0 and 1000. A sound joins an existing group if it is within this distance of the group and nothing blocks the view between them, otherwise it takes a group of its own while any are free. Larger values let more sounds share reflections and save groups, at the cost of those sounds hearing slightly less accurate reverb. This takes effect at the next update.
