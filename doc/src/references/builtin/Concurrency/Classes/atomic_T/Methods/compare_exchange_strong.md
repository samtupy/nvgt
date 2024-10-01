# compare_exchange_strong
Atomically compares the value representation of this atomic object with that of `expected`. If both are bitwise-equal, performs an atomic read-modify-write operation on this atomic object with `desired` (that is, replaces the current value of this atomic object with `desired`); otherwise, performs an atomic load of this atomic object and places it's actual value into `expected`. If failure is either `MEMORY_ORDER_RELEASE` or `MEMORY_ORDER_ACQ_REL`, the behavior is undefined. 

1: `bool compare_exchange_strong(T& expected, T desired, memory_order success, memory_order failure);`
2: `bool compare_exchange_strong(T& expected, T desired, memory_order order = MEMORY_ORDER_SEQ_CST);`

## Parameters (1):
* `T& expected`: reference to the value expected to be found in this atomic object.
* `T desired`: the value that SHALL replace the one in this atomic object if and only if it is bitwise-equal to `expected`.
* `memory_order success`: the memory synchronization ordering that SHALL be used for the read-modify-write operation if the comparison succeeds.
* `memory_order failure`: the memory synchronization ordering that SHALL be used for the load operation if the comparison fails.
* `memory_order order`: the memory synchronization order that SHALL be used for both the read-modify-write operation and the load operation depending on whether the comparison succeeds or fails.

## Returns:
`true` if the atomic value was successfully changed, false otherwise.

## Remarks:
This function is available on all atomic types.

Within the above function signatures, `T` is used as a placeholder for the actual type. For example, if this object is an `atomic_int`, then `T` SHALL be `int`.

The operations of comparison and copying SHALL be executed in a bitwise manner. Consequently, no invocation of a constructor, assignment operator, or similar function SHALL occur, nor SHALL any comparison operators be utilized during these operations.

In contrast to the `compare_exchange_weak` function, this function SHALL NOT spuriously fail.

In scenarios where the use of the `compare_exchange_weak` function would necessitate iteration, whereas this function would not, the latter SHALL be considered preferable. Exceptions to this preference exist in cases where the object representation of type T might encompass trap bits or offer multiple representations for the same value, such as floating-point NaNs. Under these circumstances, `compare_exchange_weak` generally proves effective, as it tends to rapidly converge upon a stable object representation.
