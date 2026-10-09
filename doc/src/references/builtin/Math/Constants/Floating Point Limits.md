# Floating Point Limits
These constants describe the characteristics of the float and double types on the machine running your script. NVGT measures them when the engine starts, so they always reflect the real hardware. On every platform NVGT currently supports, both types follow the IEEE 754 standard, so the values given below are the ones you will see in practice.

## float constants
* FLOAT_RADIX: the base used to represent floating point numbers (2).
* FLOAT_MANTISSA_DIGITS: the number of base FLOAT_RADIX digits in the mantissa, including the implicit leading bit (24).
* FLOAT_EPSILON: the smallest value that produces a result greater than 1 when added to 1 (about 1.19209e-07).
* FLOAT_EPSILON_EXPONENT: the exponent of FLOAT_EPSILON, that is FLOAT_EPSILON equals FLOAT_RADIX raised to this power (-23).
* FLOAT_NEG_EPSILON: the smallest value that produces a result less than 1 when subtracted from 1 (about 5.96046e-08).
* FLOAT_NEG_EPSILON_EXPONENT: the exponent of FLOAT_NEG_EPSILON (-24).
* FLOAT_EXPONENT_BITS: the number of bits used to store the exponent (8).
* FLOAT_MIN_EXPONENT: the smallest power of FLOAT_RADIX that can be represented without losing precision (-126).
* FLOAT_MIN_NORMALIZED: the smallest positive normalized value, FLOAT_RADIX raised to FLOAT_MIN_EXPONENT (about 1.17549e-38). Smaller values can still be stored as denormals, but with reduced precision.
* FLOAT_MAX_EXPONENT: the smallest power of FLOAT_RADIX that overflows (128).
* FLOAT_MAX: the largest finite value a float can hold (about 3.40282e+38).
* FLOAT_ROUNDING_MODE: a code describing how arithmetic results are rounded and how underflow is handled (5, see below).
* FLOAT_GUARD_DIGITS: the number of guard digits used when multiplying two values whose results are truncated rather than rounded (0).

## double constants
* DOUBLE_RADIX: the base used to represent floating point numbers (2).
* DOUBLE_MANTISSA_DIGITS: the number of base DOUBLE_RADIX digits in the mantissa, including the implicit leading bit (53).
* DOUBLE_EPSILON: the smallest value that produces a result greater than 1 when added to 1 (about 2.22045e-16).
* DOUBLE_EPSILON_EXPONENT: the exponent of DOUBLE_EPSILON (-52).
* DOUBLE_NEG_EPSILON: the smallest value that produces a result less than 1 when subtracted from 1 (about 1.11022e-16).
* DOUBLE_NEG_EPSILON_EXPONENT: the exponent of DOUBLE_NEG_EPSILON (-53).
* DOUBLE_EXPONENT_BITS: the number of bits used to store the exponent (11).
* DOUBLE_MIN_EXPONENT: the smallest power of DOUBLE_RADIX that can be represented without losing precision (-1022).
* DOUBLE_MIN_NORMALIZED: the smallest positive normalized value (about 2.22507e-308).
* DOUBLE_MAX_EXPONENT: the smallest power of DOUBLE_RADIX that overflows (1024).
* DOUBLE_MAX: the largest finite value a double can hold (about 1.79769e+308).
* DOUBLE_ROUNDING_MODE: a code describing how arithmetic results are rounded and how underflow is handled (5, see below).
* DOUBLE_GUARD_DIGITS: the number of guard digits used when multiplying two values whose results are truncated rather than rounded (0).

## Other constants
* EPSILON: the epsilon value used by NVGT's physics and 3D math code. It is the same value as FLOAT_EPSILON.

## Rounding mode codes
The FLOAT_ROUNDING_MODE and DOUBLE_ROUNDING_MODE constants hold one of the following values:
* 0 or 3: results are truncated (chopped) rather than rounded.
* 1 or 4: results are rounded, but not in the way the IEEE standard specifies.
* 2 or 5: results are rounded to the nearest value as the IEEE standard specifies.

A value of 3 or more means that underflow is gradual: values smaller than the minimum normalized value become denormals rather than flushing straight to 0.

## Remarks
The epsilon constants are useful for comparing floating point values, which rarely compare exactly equal after arithmetic. Keep in mind that they describe the precision of values near 1, so for comparing large values you should scale your tolerance accordingly.

FLOAT_MAX also has a special meaning in some audio functions. The `sound_play()` function and `audio_engine::play()` method default their position argument to `vector(FLOAT_MAX, FLOAT_MAX, FLOAT_MAX)`, which means that the sound should not be positioned in 3D space at all.

## Example
```NVGT
void main() {
	double sum = 0;
	for (int i = 0; i < 10; i++) sum += 0.1;
	alert("Ten tenths exactly equal 1", sum == 1.0 ? "yes" : "no");
	alert("Ten tenths equal 1 within a small tolerance", abs(sum - 1.0) <= 10 * DOUBLE_EPSILON ? "yes" : "no");
	alert("Largest float", FLOAT_MAX);
}
```
