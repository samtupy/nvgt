# `update`

Instructs the controller that a new frame is about to begin and it should perform all necessary actions to realize field/property changes.

```nvgt
void update(const float delta_time) final;
```

## Parameters

* `const float delta_time`: the difference between the time of the previous frame and this new frame. This value should be reasonably consistant; drastic changes will cause dramatic changes in the controller's internal state.

## Remarks

This function should be called once per iteration of your game loop. Your loop should take as little time as possible, and there should be as little time between `update` calls as you can manage. This function should be called *after* making any changes to public properties or fields; calling it *before* changes are made will work, but changes will not be realized until the subsequent frame.

Warning: do not insert extreme delays between calls to this function. If the delta time is too extreme, the simulation and physics will be unpredictable.
