# physics_character
A physics_character is a body in a physics_world made for the player or another person or creature that walks around. It is a real physical body that collides with the world, is pulled down by gravity, stands on floors, and slides along walls, but unlike a crate it can't be knocked over, and it never rotates by itself. Instead of pushing it with forces you move it by setting its `linear_velocity`, as you would give a person a walking speed, and the physics engine keeps it out of walls and on the ground.

1. `physics_character@ physics_character(physics_world@ world, physics_shape@ shape, const vector&in position, const quaternion&in rotation = IDENTITY_QUATERNION, float mass = 80.0f, float friction = 0.2f, uint16 layer = PHYSICS_LAYER_MOVING);`
2. `physics_character@ physics_character(physics_world@ world, float height, float radius, const vector&in position, float mass = 80.0f, float friction = 0.2f, uint16 layer = PHYSICS_LAYER_MOVING);`

## Arguments:
* physics_world@ world: the world the character lives in.
* physics_shape@ shape (1): the shape of the character.
* float height (2): the total height of the character in meters, which must be at least twice the radius.
* float radius (2): the radius of the character's capsule in meters.
* const vector&in position: where to put the character. With the second constructor this is the point on the floor below the character's center, with the first it is the origin of the shape.
* const quaternion&in rotation = IDENTITY_QUATERNION (1): how the shape is turned.
* float mass = 80.0f: the mass of the character in kilograms, which determines how hard it pushes things it walks into.
* float friction = 0.2f: how much the character grips the surfaces it touches.
* uint16 layer = PHYSICS_LAYER_MOVING: the layer of the character, see the `physics_object_layer` enum.

## Remarks:
The second constructor builds a capsule, a good shape for a standing person that slides smoothly along walls, and stands it up along the direction that is opposite of the world's gravity, so set the world's gravity before creating characters. It returns null if the radius is not positive or the height is less than twice the radius. The first constructor returns null if the world or shape is null.

The character's `up` direction, set when it is created, is the direction that its ground detection considers up and that slopes are measured against. A character cannot turn, so to rotate the listener or other things with the player you track the direction yourself.

A character is in a physics_world like any other body, which is updated with `physics_world::update()`. After each update, the character works out what it is standing on, and the `ground_state`, `supported` and other ground properties show the result. Setting `linear_velocity` while on the ground makes the character walk, but remember it also holds the character's falling speed, so keep the up component when you set it, otherwise the character will stop falling:
```
vector v = c.linear_velocity;
c.linear_velocity = vector(walk_x, walk_y, v.z);
```

Characters are acoustically transparent by default, so that the listener and the sounds the character makes, which are usually inside its shape, are not blocked by it in a sound_environment. See the `acoustically_transparent` property.

## Example:
```
void main() {
	physics_world world;
	world.create_and_add_body(physics_box_shape_create(vector(20, 20, 0.5)), vector(0, 0, -0.5), IDENTITY_QUATERNION, PHYSICS_BODY_STATIC, PHYSICS_LAYER_NON_MOVING);
	physics_character player(world, 1.8, 0.3, vector(0, 0, 2)); // A person 1.8 meters tall dropped from 2 meters up.
	for (int i = 0; i < 120; i++) world.update(1.0 / 60);
	alert("Character", "The character is standing at a height of " + player.position.z + (player.supported ? " on the ground." : " in the air."));
}
```
