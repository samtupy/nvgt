# reset
Resets an event to an unsignaled state.

`void reset();`

## Remarks:
This method is usually only needed if THREAD_EVENT_MANUAL_RESET was specified when the event was created, however you could also cancel the signaling of an event if another thread has not detected the signal yet.

See the main event and mutex chapters for examples.
