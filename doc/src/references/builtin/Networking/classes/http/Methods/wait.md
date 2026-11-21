# wait
Wait for the current request to finish.

`void http::wait();`

## Remarks:
This blocks the script until the request completes, which is simple but stops the game from doing anything else meanwhile. To keep the game running, check the complete property in the game loop instead.
