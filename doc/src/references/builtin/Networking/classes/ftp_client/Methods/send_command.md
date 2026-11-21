# send_command
Send a command to the server exactly as it is given and wait for the response.

1. `int ftp_client::send_command(const string&in command, string& response);`
2. `int ftp_client::send_command(const string&in command, const string&in argument, string& response);`

## Arguments:
* const string&in command: the FTP command, such as `NOOP`.
* const string&in argument (2): the argument of the command.
* string& response: receives the text of the response of the server.

## Returns:
int: the status code of the response, such as 200 for success.

## Remarks:
This is for commands that the other methods don't cover.
