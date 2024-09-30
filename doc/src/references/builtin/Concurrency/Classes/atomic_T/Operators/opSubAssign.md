Atomically replaces the current value with the result of computation involving the previous value and `arg`. The operation is a read-modify-write operation. Specifically, performs atomic subtraction. Equivalent to `return fetch_sub(arg) + arg;`.

```nvgt
T opSubAssign( T arg );
```

## Returns

The resulting value (that is, the result of applying the corresponding binary operator to the value immediately preceding the effects of the corresponding member function in the modification order of this atomic object).

## Remarks

This operator is only available on integral and floating-point atomic types.

Within the above function signature, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.

Unlike most compound assignment operators, the compound assignment operators for atomic types do not return a reference to their left-hand arguments. They return a copy of the stored value instead. 
