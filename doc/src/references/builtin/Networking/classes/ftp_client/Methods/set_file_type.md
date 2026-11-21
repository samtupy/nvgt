# set_file_type
Choose how files are transferred.

`void ftp_client::set_file_type(ftp_file_type type);`

## Arguments:
* ftp_file_type type: FTP_FILE_TYPE_BINARY, which is the default, or FTP_FILE_TYPE_TEXT.

## Remarks:
Binary mode transfers files exactly as they are. In text mode, the receiving side is expected to convert line endings itself, and this client does no conversion, so binary is almost always correct. The current type is available in the file_type property.
