# random_interface
Defines the class structure that is available in NVGT's object based pseudorandom number generators. A class specifically called random_interface does not exist in the engine, but instead this reference describes methods available in multiple classes that do exist (see remarks).
1. random_interface();
2. random_interface(uint seed);
## Arguments (2):
* uint seed: The number used as the seed/starting point for the RNG, passing the same seed will yield the same sequence of random numbers.
## Remarks:
NVGT contains several different pseudorandom number generators which can all be instanciated as many times as the programmer needs.

These generators all share pretty much exactly the same methods by signature and are interacted with in the same way, and so it will be documented only once here. Small topics explaining the differences for each actual generator are documented below this interface.

These classes all wrap a public domain single header library called [rnd.h](https://github.com/mattiasgustavsson/libs/blob/main/rnd.h) by mattiasgustavsson on Github. The explinations for each generator as well as the following more general expination about all of them were copied verbatim from the comments in that header, as they are able to describe the generators best and already contain links to more details.

The library includes four different generators: PCG, WELL, GameRand and XorShift. They all have different characteristics, and you might want to use them for different things. GameRand is very fast, but does not give a great distribution or period length. XorShift is the only one returning a 64-bit value. WELL is an improvement of the often used Mersenne Twister, and has quite a large internal state. PCG is small, fast and has a small state. If you don't have any specific reason, you may default to using PCG.
