## Algorithms Book 
Reading *Artificial Intelligence A Systems Approach* by M Tim Jones
<br>Writing out some of the algorithms myself as I go along for practice. Might throw some random Julia files in here too, that arent insprired or from the book, hence the name "Julia_Stuff"
<br><br>

## Julia Stuff:
*Random functions and things I wrote in Julia*

**DeviseSum.jl:** Given a target number n and a set of numbers N, this returns a sum of the numbers from N (repeats allowed) that result in n if possible. For instance n = 17, N = {2,5,7}. Solution = 2 + 5 + 5 + 5

**EightPuzzle.jl:** Solves the EightPuzzle problem using the A* algorithm.

**Genetic.jl:** First try at a genetic algorithm. Trying to finding the global minimum of a function (ideally one that has many local minima, like the one I tested against). Seems to work well, definitely want to do more of these.

**IterChoose.jl:** Iterative version of the Choose function.

**NodeStuff.jl:** Practice with making custom classes in Julia. Just wrote most a Doubly LinkedList, nothing spectacular.

**Lagrange.jl:** Implements Lagrange interpolation for any amount of points. Very silly to give it a lot of points, as a polynomial with a high order is wildly unstable. But I did this cool way to multiply all the (x-?)(x+?)(x+?)...(x-?) together using the Choose function. So there was that.

**QuasiNewton.jl:** N-dimensional root finding method using a numerically approximated Jacobian matrix.

**ShooterMethods.jl:** Functions for solving ODE's both IVP's and BVP's. Linear and Non-Linear.

**ShortestPath.jl:** Uses Dijkstras Algorithm to calculate the shortest path. I store the Graph as a Dictionary. Prints the path and the cost.

# Julia_Modules
Custom Julia Modules for use in Numerical Math, as well as useful functions for general programming.

## jlnum.jl:
*This module contains functions for use in Numerical Mathematics. Some are my own spin on well known functions, with the intention to use them in niche circumstance or increase optimization. It contains the following functions:*

**ArcLen:** Finds the length of a function between two points. 

**RomInt:** Uses Romberg Integration to find the area under a curve. *Uses a function as a parameter!*

**TrapZ:** Uses the Trapazoidal method to give the area under a curve. *Uses Data Points*

**UnevenTrapZ:** Uses the Trapazoidal method to give the area under a curve. To be used when the data points are *NOT* evenly spaced. 

**CumTrapZ:** Estimates the data points of the integral. Only should be used for visualization of the shape of the integral. Plotting is strongly advisable. 

**Lagrange:** Uses the Lagrangian technique to interpolate between data points. 

**TaylorPoly:** Gives the Taylor Series appoximation in the form of a vector of coefficients. Point of expansion and order can both be specified in parameters.

**TaylorEval:** Evaluates a vector of Taylor Series coefficients at the supplied data points. *Must specify the point of expansion at which the coefficients were obtained.*

**PolyVecEval:** Evaluates a vector as a single variable polynomial at the supplied value.

**PolyForm:** Returns a vector of the specified order, with the coefficients being subsequent powers of the supplied value.

**PolyDiff:** Differentiates a vector representing a polynomial.

**PolyInt:** Integrates a vector representing a polynomial.

**Rootz:** Finds all avaiable roots of a function on the supplied interval. Returns a vector of the roots. Spacing can be specified for desired accuracy.

**fzero:** Uses a combination of the Bisection Method and the Newton Method to find the root of a function between two guesses.

**Fibs:** Finds the Nth Fibonacci number requested. Can either return a single value, or all the Fibonacci numbers up the requested Nth number.

**NumDeriv:** Computes the numerical derivative of supplied data points. Uses Lagrangian interpolation to return a derivative with the same amount of data points as the original.

**ColZ:** The 3D equivalent of TrapZ. Instead of using 2D rectangles, this function uses 3D columns to approximate the volume under the function 

**Monte3D:** Uses Monte Carlo integration to approximate the volume under the function.  

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
