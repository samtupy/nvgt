# reflection_order
The ambisonic order that reflections are simulated and decoded at.

`int reflection_order;`

## Remarks:
The default is 1 and values are clamped between 0 and 3. Higher orders resolve the direction of reflections more precisely but the cost grows with the square of (order + 1). Order 0 has no directional information at all.

Changing this rebuilds the environment's simulator and audio effects the next time the simulation is idle and `update()` is called, which cuts off reverb tails, so reflections briefly drop out. Avoid changing it every frame.
