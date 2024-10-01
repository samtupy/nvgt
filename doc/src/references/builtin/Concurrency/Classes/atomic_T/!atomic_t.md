# atomic_t

The base class for all atomic types that NVGT has to offer.

## Remarks:

An atomic type SHALL be defined as a data type for which operations must be performed atomically, ensuring that modifications are indivisible and uninterrupted within a concurrent execution environment. An atomic operation MUST either fully succeed or completely fail, with no possibility of intermediate states or partial completion.

When one thread writes to an atomic object and another thread reads from the same atomic object, the behavior MUST be well-defined and SHALL NOT result in a data race.

Operations on atomic objects MAY establish inter-thread synchronization and MUST order non-atomic memory operations as specified by the `memory_order` parameter. Memory effects MUST be propagated and observed according to the constraints of the specified memory ordering.

Within this documentation, the `atomic_T` class is a placeholder class for any atomic type. Specifically, `T` may be any primitive type except void, but MAY NOT be any complex type such as string. For example, `atomic_bool` is an actual class, where `bool` replaces `T`. Additionally, an `atomic_flag` class exists which does not offer load or store operations but is the most efficient implementation of boolean-based atomic objects, and has separate documentation from all other atomic types.

Please note: atomic floating-point types are not yet implemented, though they will be coming in a future release. However, until then, attempts to instantiate an atomic floating-point type will behave as though the class in question did not exist. This notice will be removed once atomic floating-point types have been implemented.