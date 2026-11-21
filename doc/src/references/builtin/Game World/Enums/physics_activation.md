# physics_activation
This is a list of the values that choose whether changing a body wakes it up, accepted by `physics_world::create_and_add_body()`, `physics_world::set_position()` and similar methods.

* PHYSICS_ACTIVATE: the body is awake after the operation and is simulated.
* PHYSICS_DONT_ACTIVATE: the body is left asleep if it was asleep (or starts asleep when created). It wakes when something touches it or `physics_world::activate_body()` is called.

Bodies that stop moving fall asleep by themselves, which keeps big worlds cheap.
