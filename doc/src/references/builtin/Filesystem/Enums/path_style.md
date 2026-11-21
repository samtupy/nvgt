# path_style
The styles a spec::path can be parsed and written in, in the spec namespace, so written as `spec::PATH_STYLE_UNIX` and so on.

* PATH_STYLE_UNIX: Unix style paths, as on Linux, macOS, Android and iOS, such as `/home/sam/game`.
* PATH_STYLE_URI: the same as PATH_STYLE_UNIX, used for the paths of URIs.
* PATH_STYLE_WINDOWS: Windows style paths, such as `C:\Users\Sam\game`. Forward slashes are accepted when parsing.
* PATH_STYLE_VMS: OpenVMS style paths, such as `node::device:[dir1.dir2]file.ext;1`.
* PATH_STYLE_NATIVE: the style of the operating system NVGT is running on.
* PATH_STYLE_AUTO: guess the style when parsing, from the characters the path contains. This can't be used for writing a path.
