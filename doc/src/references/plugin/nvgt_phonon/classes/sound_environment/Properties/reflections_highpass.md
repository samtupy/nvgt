# reflections_highpass
The cutoff in hertz of a high pass filter applied to the environment's reflections.

`float reflections_highpass;`

## Remarks:
The default is 160 and values are clamped between 0 and 45 percent of the engine's sample rate. Simulated reflections tend to sound boomy in the low end, and filtering it out makes them cleaner. 0 disables the filter.
