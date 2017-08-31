# Julia_Modules
Custom Julia Modules for use in Numerical Math, and String Manipulations

## jlnum.jl:
*This module contains functions for use in Numerical Mathematics. Some are my own spin on well known functions, with the intention to use them in niche circumstance or increase optimization. It contains the following functions:*

**ArcLen.jl:** Finds the length of a function between two points. 

**RomInt.jl:** Uses Romberg Integration to find the area under a curve. *Uses a function as parameter!*

**TrapZ.jl:** Uses the Trapazoidal Rule to give the area under a curve. *Uses Data Points*

**UnevenTrapZ.jl:** Uses the Trapazoidal Rule to give the area under a curve. To be used when the data points are *NOT* evenly spaced. 

**CumTrapZ.jl:** Estimates the data points of the integral. Works well with polynomials. Only should be used for visualization of the shape of the integral. Plotting is strongly advisable. 

**Lagrange.jl:** Uses the Lagrangian technique to interpolate between data points. 

**TaylorPoly.jl:** Gives the Taylor Series appoximation in the form of a vector of coefficients. Point of expansion and order can both be specified in parameters.

**TaylorEval.jl:** Evaluates a vector of Taylor Series coefficients at the supplied data points. *Must specify the point of expansion at which the coefficients were obtained.*

**PolyVecEval.jl:*** Evaluates a vector as a single variable polynomial at the supplied value.

**PolyForm.jl:** Returns a vector of the specified order, with the coefficients being subsequent powers of the supplied value.

**PolyDiff.jl:** Differentiates a vector representing a polynomial.

**PolyInt.jl:** Integrates a vector representing a polynomial.

**Rootz.jl:** Finds all avaiable roots of a function on the supplied interval. Returns a vector of the roots. Spacing can be specified for desired accuracy.

**fzero.jl:** Uses a combination of the Bisection Method and the Newton Method to find the root of a function between two guesses.

**Fibs.jl:** Finds the Nth Fibonacci number requested. Can either return a single value, or all the Fibonacci numbers up the requested Nth number.



