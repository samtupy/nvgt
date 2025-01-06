# file
The file datastream is used to read and write files stored on the hard disk.

1. `file();`
2. `file(const string path, const string mode);`

## Arguments (1):
* const string path: the filename to open.

## Arguments (2):
* const string path: the filename to open.
* const string mode: the mode to open as.

## Remarks:
Usually when the file object is first created, it will not be active, that is, it will not be associated with a file on disk. To activate it, use the following methods:

* Call the open function.
* use the second constructor.

Please note that both methods require the filename that is to be associated and the mode to open, with the only difference being that it is harder to tell whether the file was opened successfully if you use the constructor rather than the open method. Using the second constructor makes it 1 line shorter. The possible open modes will not be documented in this remarks, you can see it in `file::open` method.

Remember that as with all datastreams, all methods in the base datastream class will work on the file class unless noted otherwise and thus will not be redocumented here.
