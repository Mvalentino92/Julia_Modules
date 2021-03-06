## Optimization and Metaheuristics
*Some of the classic metaheuristics for real valued functions, and personal attempts at implementating such algorithms. 

### Ant Colony Optimization

**SACO.jl:** The Simple Ant Colony Opitimization algorithm. No heuristic information is used to guide the ants on their search, only phermone trails (positive feedback loop). Uses WeightedSimpleGraphs library. 

**AS.jl:** The Ant System algorithm. Adds a heurstic component to SACO. Uses the MetaGraphs library.

**FastAS.jl:** Another implementation of the Ant System Algorithm. The performance of SimpleWeightedGraphs (used in SACO), was superior to MetaGraphs (used in AS), but good random graph generation wasn't avaiable for SimpleWeightedGraphs. My soltution was to handle the phermone trails and weights myself, just using the LightGraphs library (SimpleWeighted and Meta are extensions). And accessing needed values using a double binary search on primitive 2xn arrays. Achieved the performance (even a little better), of SimpleWeighted, with the benefit of random graph generation.

### Evolutionary Algorithms

**EP.jl**: Evolutionary Programming. Implements only mutation operators. Strong selection pressure and elitism. The entire population of parents has 1 child (exact clone), which is then probablistically mutated with an average of 1 gene being mutated every iteration. The top 50% of the new population (N parents + N children) survive to next iteration. This ensures a higher, and potentially detrimental rate of convergence. 

<br>
<br>

**Heat Diff:** A person algorithm I came up with, after inspiration of learing of the Heat Equation in my PDE's class. Maps a bunch of solution vectors onto a "rod", that has fixed endpoints as the current best global solution. The fitness space of each point is used to loosely mirror the "average of your neighbors" concept from the Heat Equation. Then the actual components of the vectors are updated based on the "pull" (or influence in the fitness space) of each neighbor. When stabilization is reached, random points are replaced on the rod with new solutions, and the algorithm continues until the max iteration.

**Infection.jl:** Another attempt at a meatheuristic algorithm for function minimization. Models a state-based infection spreading, where solutions can be in one of several states: Susceptible, Infected, Recovered. All solutions maintain a personal best history, and when infected explore the area around the infecting solutions personal best. In order to explore the search space efficiently, multiple epidemics are ran, with each subsequent run focusing on a smaller subset of the solution space. Convergence is achieved through enough iterations. Recovery and infections rates are among parameters that can be tweaked for performance.
 
**Particle Swarm:** Implemented the basic PSO algorithms, with features such as:
<br> Velocity Clampming, Inertia Weight (decay potential for both), Constraint Coefficient, Swarm Convergence Testing, and lbest variant using a ring topology.

**Random Search:** Randomly searches through the solution space, and exploits the immediate area if in a good location (exploitation). Not intended to be an efficient function, but used to measure the effectiveness of any of the other algorithms. Basically I want to know, "Does this algorithm consistently perform significantly better than a "guided/exploitative" random search?".

**Simulated Annealing:** Standard simulated annealing algorithm. Has a personal spin of optionally having the thermal equilibrium ratio follow a sine wave. This accomplishes a fluctuating tradeoff between exploration and exploitation which then conveged to the initially specified ratio. Experimental, just because.

**Tabu Search:** Operates mainly as an auxillary function for *Particle Swarm*. Attempts to find a tighter more promising subspace of the solution space for *Particle Swarm* to spawn the intitial particle locations. Enforces exploration and exploitation by marking solutions as tabu, and tightening the area of solutions that are tabu over time. Basic memory structure of recency used, and hall of fame members are returned as the solutions for use in *Particle Swarm*

**Tournament Search:** A custom algorithm I created. Works under the concept of tournaments being held between a pool of solutions, where a winner is selected by sampling the space around each "fighter" and comparing the fitness at these new location. Whichever fighter wins the most matches, wins the fight persists to the next round of the tournament. The single winner is used to populate the next pool of fighters for the tournament. As iterations progress, the sampled space around each fighter during matches is reduced, as is the space where the winner populates the next tournament. Additionally, to foster exploitation as the algorithm runs, matches have a higher chance to be won based on the actual fitness of the current fighter, and not a solution in its sample space. 

## Algorithms Book 
Reading *Artificial Intelligence A Systems Approach* by M Tim Jones
<br>Writing out some of the algorithms myself as I go along for practice. Might throw some random Julia files in here too, that arent insprired or from the book, hence the name "Julia_Stuff"
<br><br>

## Julia Stuff:
*Random functions and things I wrote in Julia*

**Cgraph.jl:** Cleaned up the *CompGraph.jl* and fixed/added more functionality. You have the option to use _ as negatives (not subtraction), but it's not needed. You can also pass variables, and create a computation graph of the derivative. Evaluation of computation graphs require the user to pass a dictionary with mapps IE "x" => 5, if the computation graph was a function of x.

**CompGraph.jl:** Messing around with building Computation Graphs for evaluating expressions. Nothing crazy, just a POC. Might clean it up and add more functionality in the future.  

**DeviseSum.jl:** Given a target number n and a set of numbers N, this returns a sum of the numbers from N (repeats allowed) that result in n if possible. For instance n = 17, N = {2,5,7}. Solution = 2 + 5 + 5 + 5

**EightPuzzle.jl:** Solves the EightPuzzle problem using the A* algorithm.

**Genetic.jl:** First try at a genetic algorithm. Trying to finding the global minimum of a function (ideally one that has many local minima, like the one I tested against). Seems to work well, definitely want to do more of these.

**IterChoose.jl:** Iterative version of the Choose function.

**NodeStuff.jl:** Practice with making custom classes in Julia. Just wrote most a Doubly LinkedList, nothing spectacular.

**Palindrome.jl:** Uses Evolutionary Algorithms to construct palindromes with math words in them. 

**PolynomialFeatures.jl:** Implements the same functionality as sklearns PolynomialFeatures.

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
