# end_download
Finish a download started with begin_download().

`void ftp_client::end_download();`

## Remarks:
Call this once all data has been read, before sending any other command. Use abort() to cancel a download that you don't want to finish.
