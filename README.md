# Julia_Modules
Custom Julia Modules for use in Numerical Math, as well as useful functions for general programming.

## jlnum.jl:
*This module contains functions for use in Numerical Mathematics. Some are my own spin on well known functions, with the intention to use them in niche circumstance or increase optimization. It contains the following functions:*

**ArcLen:** Finds the length of a function between two points. 

**RomInt:** Uses Romberg Integration to find the area under a curve. *Uses a function as a parameter!*

**TrapZ:** Uses the Trapazoidal Rule to give the area under a curve. *Uses Data Points*

**UnevenTrapZ:** Uses the Trapazoidal Rule to give the area under a curve. To be used when the data points are *NOT* evenly spaced. 

**CumTrapZ:** Estimates the data points of the integral. Works well with polynomials. Only should be used for visualization of the shape of the integral. Plotting is strongly advisable. 

**Lagrange:** Uses the Lagrangian technique to interpolate between data points. 

**TaylorPoly:** Gives the Taylor Series appoximation in the form of a vector of coefficients. Point of expansion and order can both be specified in parameters.

**TaylorEval:** Evaluates a vector of Taylor Series coefficients at the supplied data points. *Must specify the point of expansion at which the coefficients were obtained.*

**PolyVecEval:*** Evaluates a vector as a single variable polynomial at the supplied value.

**PolyForm:** Returns a vector of the specified order, with the coefficients being subsequent powers of the supplied value.

**PolyDiff:** Differentiates a vector representing a polynomial.

**PolyInt:** Integrates a vector representing a polynomial.

**Rootz:** Finds all avaiable roots of a function on the supplied interval. Returns a vector of the roots. Spacing can be specified for desired accuracy.

**fzero:** Uses a combination of the Bisection Method and the Newton Method to find the root of a function between two guesses.

**Fibs:** Finds the Nth Fibonacci number requested. Can either return a single value, or all the Fibonacci numbers up the requested Nth number.

**NumDeriv:** Computes the numerical derivative of supplied data points. Uses Lagrangian interpolation to return a derivative with the same amount of data points as the original.

## jlstr.jl
*This module contains functions mainly for operations on Strings or Arrays in general.*

**Count:** Counts the amount of times the supplied characters(s) occurs in the string.

**rotR:** Rotates the elements in an array the specified amount of places to the right.

**rotL:** Rotates the elements in an array the specified amount of places to the left.

**slowSort:** Sorts an array of numbers in nondecreasing order. Destroys the original array in the process. *Outperformed by Sort, please see below to use that instead*

**Sort:** Sorts an array of numbers in nondecreasing order. Returns the original array sorted.

**Sinput:** Prompts the user for input, and saves the input as a String.

**Finput:** Prompts the user for Float input, and saves the input to a variable.

**Ninput:** Prompts the user for Integer input, and saves the input to a variable.

**alphasort:** Alphabetically sorts an array. Returns the original array alphabetized.

**strcmp:** Compares the value of two strings, character by character and returns a value specifying which is lower in alphabetical order. Does not differentiate between upper and lowercase.

**Alpha:** Alphabetically sorts an array by calling strcmp. Far more efficient than alphasort, use this instead.

## jlphy.jl
*This module contains functions to be used for physics and chemistry related work.*

**distime:** Does a conversion for Distances over Time. Can work with...

*Millimeters*, *Centimeters*, *Decimeters*, *Meters*, *Kilometers*, *Inches*, *Feet*, *Yards*, *Miles*.

*Seconds*, *Minutes*, *Hours*, *Days*.
