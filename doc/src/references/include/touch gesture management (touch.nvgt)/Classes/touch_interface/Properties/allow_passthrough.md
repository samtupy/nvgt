# allow_passthrough
Determines whether gestures should continue to be processed by other interfaces after this one handles them.

```bool allow_passthrough = false;```

## Remarks:
When set to true, gesture events will be passed to the next interface in the chain even after this interface processes them. This allows multiple interfaces to respond to the same gesture.
