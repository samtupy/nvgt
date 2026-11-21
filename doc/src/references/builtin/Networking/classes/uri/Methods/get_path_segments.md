# get_path_segments
Get the parts of the path between its slashes.

`array<string>@ uri::get_path_segments() const;`

## Returns:
array<string>@: the segments of the path, so `/docs/audio/sound.html` gives docs, audio and sound.html.
