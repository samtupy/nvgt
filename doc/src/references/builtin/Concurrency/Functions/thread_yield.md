# thread_yield
Yields CPU to other threads.
void thread_yield();

## Remarks:
This is a little bit like executing `wait(0);` accept that it does not pull the window, and there is absolutely no sleeping. It will temporarily yield code execution to the next scheduled thread that is of the same or higher priority as the one that called this function.
