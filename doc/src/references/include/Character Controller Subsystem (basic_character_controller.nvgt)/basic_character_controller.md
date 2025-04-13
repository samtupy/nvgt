# Basic character controller include

An abstract character controller that implements a complete framework for 3D character movement without relying on a full physics engine. It accepts input flags for moving forward, backward, strafing, turning, jumping, and toggling crouch, and maintains state flags for conditions such as being grounded, crouching, and running. Internally, the class manages position, velocity, and orientation vectors along with previous states for these quantities.

It contains methods that update rotation by computing target and current yaw angles, adjusting the forward and right directional vectors accordingly. Vertical movement is handled by applying gravitational acceleration and jump impulses when grounded. Horizontal movement combines input-based directional movement with acceleration, deceleration, and different speed settings for walking, running, and crouching. The class also applies friction--varying between ground and air--and computes step cycles based on distance traveled.

Additional features include methods for rotating the character by specific degrees, turning around, and snapping to preset angular increments, as well as helper functions that translate yaw values into directional text. Callbacks are provided for position, rotation, vertical and horizontal movement updates, and friction application.

## Usage

This class is an abstract base class (ABC). As such, it cannot be directly instantiated. To use it, create a class deriving from `basic_character_controller`. Be sure to call the superclasses constructor within the subclasses constructor, as the superclasses constructor initializes core state and computes general attributes to get you started.

In your subclass, you are strongly encouraged to override at least one of the callbacks enumerated below. The callbacks notify your application about state changes from within the class and allow you to intercept these changes. For all callbacks returning `bool`, excepting `should_run`, returning `false` will cause the operations performed before that callback is called to be undone. However, other operations performed for each frame will be unaffected unless explicitly specified.

Do not call any base class callback from within a callback. The behavior is unspecified if this occurs.

When instantiating your derived class, set any of the below input signals to cause the character controller to take an action. Clear the input signal to cause the action to be halted in the next frame.

You will also need to compute delta time. Delta time is the duration between frames.

## Input signals

The basic character controller is devorsed from any specific input system. This allows it to be used by both human and machine operators; for example, the player could have a character controller class, as could an AI character in your game.

To facilitate movement and other operations, you set any of the following input signals. As long as they are true, the appropriate action will be called per frame.

| **Input Signal** | **Description** |
| ---------------- | --------------- |
| `move_forward`   | Causes the character to accelerate in the direction it is facing. |
| `move_backward`  | Causes the character to accelerate in the opposite direction to which it is facing. |
| `turn_left`      | Causes the character to rotate counterclockwise around its vertical axis. |
| `turn_right`     | Causes the character to rotate clockwise around its vertical axis. |
| `strafe_left`    | Causes the character to move sideways to the left relative to its facing direction. |
| `strafe_right`   | Causes the character to move sideways to the right relative to its facing direction. |
| `jump`           | Applies an upward force that moves the character vertically. |

## Callbacks

This class implements several callbacks. Override them to change the behavior of the character.

| **Callback**            | **Description**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `on_position_changed`     | Called after updating the character’s position. By default, this callback verifies the vertical coordinate and, if it is below zero, clamps the vertical position to zero, resets the vertical velocity to zero, and sets the grounded flag to true. If the callback returns false, the entire position update is reverted to the prior state.                                                       |
| `on_rotation_changed`     | Called after the rotation values (yaw, forward, and right vectors) have been updated. The default implementation does nothing and returns true. If a subclass returns false from this callback, the rotation update is undone and the previous orientation is restored.                                                                                                                                                                                                                                                                      |
| `on_vertical_movement`    | Called following any modification to the vertical component of the velocity, such as when applying gravity or jump impulses. The default behavior is to return true and to do nothing. Returning false will revert the vertical component back to its previous value.                                                                                                                           |
| `on_horizontal_movement`  | Called after adjustments are made to the horizontal components of the velocity based on movement inputs. By default, the function returns true and does nothing. If it returns false, the horizontal movement update is restored to the previous horizontal velocity state. |
| `on_friction_applied`      | Called after friction is applied to the current velocity to dampen motion. The default implementation returns true and does nothing. If a subclass returns false, the velocity changes resulting from friction are undone.                                                                                                                               |
| `on_step_cycle`           | Called when the cumulative horizontal distance traveled reaches a specified step threshold, typically used to signal step cycle events (such as footstep sounds). The default implementation is a no-op. Undoing this operation is not supported.                                                                                                                                                                                                                             |
| `should_run`              | Evaluated to determine if the character should be in a running state based on current movement and input flags. The default behavior returns false, meaning the character does not transition into a running state. This callback is purely evaluative, does not modify state, and its return value affects only the choice of movement speed during horizontal motion calculations. |

## Fields

When implementing callbacks or the constructor of a subclass, many fields are made available to grant you access to the internal state of the character. These fields are as follows:

| **Field**           | **Description**                                                                                                                                           |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| `is_grounded`         | Boolean indicating whether the character is in contact with the ground.                                                                                 |
| `is_crouching`        | Boolean indicating whether the character is in a crouched state.                                                                                          |
| `is_running`          | Boolean indicating whether the character is in a running state.                                                                                           |
| `position`            | Vector representing the current position of the character in the game world.                                                                              |
| `velocity`            | Vector representing the current rate of change of the character's position.                                                                               |
| `forward`             | Vector representing the current forward direction of the character.                                                                                     |
| `up`                  | Vector representing the upward direction relative to the character, commonly used as a vertical reference.                                                  |
| `right`               | Vector representing the rightward direction, computed as the normalized cross product of the up vector and the forward vector.                             |
| `old_position`        | Vector storing the character's position from the previous update cycle.                                                                                   |
| `old_velocity`        | Vector storing the character's velocity from the previous update cycle.                                                                                   |
| `old_forward`         | Vector storing the character's forward direction from the previous update cycle.                                                                          |
| `old_up`              | Vector storing the character's up direction from the previous update cycle.                                                                               |
| `old_right`           | Vector storing the character's right direction from the previous update cycle.                                                                            |
| `max_speed`           | Float representing the maximum speed that can be reached by the character.                                                                                |
| `walk_speed`          | Float defining the target speed when the character is walking.                                                                                            |
| `run_speed`           | Float defining the target speed when the character is running.                                                                                            |
| `crouch_speed`        | Float defining the target speed when the character is crouching.                                                                                          |
| `acceleration`        | Float that defines the rate at which the character's velocity increases when movement input is applied.                                                     |
| `deceleration`        | Float that defines the rate at which the character's velocity decreases when movement input is not applied.                                                 |
| `air_control`         | Float multiplier that scales the acceleration when the character is airborne, affecting maneuverability in the air.                                          |
| rotation_speed      | Float that defines the rate of angular change (rotation) of the character's orientation, measured in degrees per second.                |
| `current_speed`       | Float representing the current magnitude of the character's horizontal movement speed.                                                                     |
| `jump_force`          | Float representing the magnitude of the upward impulse applied when the character jumps.                                                                   |
| `gravity`             | Float representing the acceleration due to gravity that affects the character's vertical velocity.                                                        |
| `ground_friction`     | Float representing the frictional force applied to the character while it is in contact with the ground, reducing its horizontal velocity.                 |
| `air_friction`        | Float representing the frictional force applied to the character while airborne, reducing its horizontal velocity.                                          |
| `player_height`       | Float representing the current height of the character, which can be modified by actions like crouching. Currently unused internally.                                                    |
| `crouch_height`       | Float defining the character's height when in a crouched state. Currently unused internally.                                                                                            |
| `stand_height`        | Float defining the character's height when standing upright. Currently unused internally.                                                                                              |
| `mass`                | Float representing the character's mass, in kilograms. Currently unused internally.                                        |
| `step_distance`       | Float used as an incremental measure for calculating the distance required to complete one step cycle.                                                     |
| `distance_traveled`   | Float accumulating the horizontal distance the character has moved since the last reset of the step cycle.                                                   |
| `step_cycle`          | Float representing the progress through the current step cycle, often normalized to a value between 0 and 1.                                                  |
| `run_step_length`     | Float defining the distance threshold for a single step cycle when the character is running.                                                               |
| `walk_step_length`    | Float defining the distance threshold for a single step cycle when the character is walking.                                                               |
| `crouch_step_length`  | Float defining the distance threshold for a single step cycle when the character is crouching.                                                             |
| `yaw`                 | Float representing the current rotational angle (yaw) of the character around the vertical axis. You should normally not neeed to change this property; doing so will cause an (unnatural) "snapping" effect, which you may not typically want.                                                           |
| `target_yaw`          | Float representing the desired yaw angle toward which the character is currently rotating. To naturally rotate the character to a given yaw, set this field and allow the character to reach that yaw over time.                                                                |
| `old_yaw`             | Float storing the yaw angle from the previous update cycle.                                                                                              |
