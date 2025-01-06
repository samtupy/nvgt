# thread_event_type
These are the possible event types that can be used to successfully construct thread_event objects.
* THREAD_EVENT_MANUAL_RESET: Many threads can wait on this event because the `thread_event::reset()` method must be manually called.
* THREAD_EVENT_AUTO_RESET: Only one thread can wait on this event because it will be automatically reset as soon as the waiting thread detects that the event has become signaled.
