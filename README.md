# Julia_Modules
Custom Julia Modules for use in Numerical Math, and String Manipulations

### jlnum.jl:
*This module contains functions for use in Numerical Mathematics. Some are my own spin on well known functions, with the intention to use them in niche circumstance or increase optimization. It contains the following functions: *

**ArcLen:** Finds the length of a function between two points. 

**RomInt:** Uses Romberg Integration to find the area under a curve. *Uses a function as parameter!*

**TrapZ:** Uses the Trapazoidal Rule to give the area under a curve. *Uses Data Points*

**UnevenTrapZ:** Uses the Trapazoidal Rule to give the area under a curve. To be used when the data points are *NOT* evenly spaced. 

**CumTrapZ:** Estimates the data points of the integral. Works well with polynomials. Only should be used for visualization of the shape of the integral. Plotting is strongly advisable. 

**Lagrange:** Uses the Lagrangian technique to interpolate between data points. 

**TaylorPoly:** Gives the Taylor Series appoximation in the form of a vector of coefficients. Point of expansion and order can both be specified in parameters.

**TaylorEval:** Evaluates a vector of Taylor Series coefficients at the supplied data points. *Must specify the point of expansion at which the coefficients were obtained.*

