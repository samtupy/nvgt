# file
The file object is used to read and write files stored on the hard disk.

1. `file();`
2. `file(const string path, const string mode);`

## Arguments:
* const string path: the filename to open.
* const string mode: the mode to open as.

## Remarks:
When the file object is first created, it will not be active. To activate it, use the following methods:

* Call the open function.
* use the second constructor.

Please note that both methods require the filename that is to be associated, and the mode to open, and there is no differents. Using the second constructor makes it 1 line shorter. The possible open modes will not be documented in this remarks, you can see it in `file::open` method.
