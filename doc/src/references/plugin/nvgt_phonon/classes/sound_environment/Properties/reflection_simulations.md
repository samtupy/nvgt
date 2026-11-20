# reflection_simulations
The number of reflection simulations that have completed since the environment was created.

`const uint reflection_simulations;`

## Remarks:
This is mostly useful for waiting until the first reflections of a new environment or scene are ready, for example `while (env.reflection_simulations < 2) { env.update(); wait(10); }`.
