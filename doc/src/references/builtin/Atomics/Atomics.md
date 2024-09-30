# Atomic types
An atomic type SHALL be defined as a data type for which operations must be performed atomically, ensuring that modifications are indivisible and uninterrupted within a concurrent execution environment. An atomic operation MUST either fully succeed or completely fail, with no possibility of intermediate states or partial completion.

When one thread writes to an atomic object and another thread reads from the same atomic object, the behavior MUST be well-defined and SHALL NOT result in a data race.

Operations on atomic objects MAY establish inter-thread synchronization and MUST order non-atomic memory operations as specified by the memory_order parameter. Memory effects MUST be propagated and observed according to the constraints of the specified memory ordering.