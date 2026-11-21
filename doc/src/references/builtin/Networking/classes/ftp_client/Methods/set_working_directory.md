# set_working_directory
Change the current directory on the server.

`void ftp_client::set_working_directory(const string&in path);`

## Arguments:
* const string&in path: the directory to go to, either absolute or relative to the current one.

## Remarks:
An exception is thrown if the directory doesn't exist or can't be entered.
