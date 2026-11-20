# density
The density of the shape in kilograms per cubic meter.

`float physics_convex_shape::density;`

## Remarks:
The default is 1000, the density of water. The mass of a dynamic body is its shape's volume times density, so the heavier a thing should be, the higher this should be before the body is created. Changing it does not change bodies that were already made with the shape.
