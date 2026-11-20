# ground_material
The material of the surface the character is standing on.

`const physics_material@ physics_character::ground_material;`

## Remarks:
This is null when the character is in the air or the shape underfoot has no material. It is what you would use to choose the sound of a footstep, for example by the material's `name`.
