import java.util.*;
class Phenotype
{
	boolean pheno[];
	int fitness;

	public Phenotype(boolean[] pheno, int fitness)
	{
		this.pheno = pheno;
		this.fitness = fitness;
	}
}

class GeneticComparator implements Comparator<Phenotype>
{
	@Override
	public int compare(Phenotype p1, Phenotype p2)
	{
		return p2.fitness - p1.fitness;
	}
}

public class KnapSack
{
	//Max of two values
	public static int max(int a, int b) {return a > b ? a : b;}

	//Gets the capacity of the knapsack from the user
	public static int getCapacity()
	{
		Scanner input = new Scanner(System.in);
		System.out.print("Enter the capacity of your knapsack: ");
		return input.nextInt();
	}

	//Gets the value and weight of all the items from the user
	public static int[][]  getItems()
	{
		//Number of items
		Scanner input = new Scanner(System.in);
		System.out.print("Enter number of items: ");
		int[][] items = new int[2][input.nextInt()];

		//Populate the items
		for(int i = 0; i < items[0].length; i++)
		{
			System.out.print((i+1)+") Enter value and weight: ");
			items[0][i] = input.nextInt();
			items[1][i] = input.nextInt();
		}
		return items;
	}

	public static int fitness(boolean[] pheno, int capacity, int[][] items)
	{
		int retval = 0;
		for(int i = 0; i < pheno.length; i++)
		{
			if(pheno[i])
			{
				if(capacity - items[1][i] >= 0)
				{
					retval += items[0][i];
					capacity -= items[1][i];
				}
				else return 0;
			}
		}
		return retval;
	}

	public static double averageFitness(boolean[][] population, int capacity, int[][] items)
	{
		double retval = 0;
		for(int i = 0; i < population.length; i++) retval += fitness(population[i],capacity,items);
		return retval/population.length;
	}

	public static void mutate(boolean[] pheno)
	{
		for(int i = 0; i < pheno.length; i++)
		{
			if(Math.random() < 1.0/pheno.length) pheno[i] = !pheno[i];
		}
	}

	public static int pickParent(int index,int maxVal)
	{
		int retval = index;
		int bound = (int)(Math.random()*(index*2));
		for(int i = 0; i < bound; i++)
		{
			if(Math.random() <= 0.777) retval--;
			else retval++;
		}
		if(retval < 0) return 0;
		if(retval > maxVal) return maxVal;
		return retval;
	}
			
	public static int pickParent2(double[] wheel)
	{
		double rand = Math.random();
		int i = wheel.length - 1;
		while(i > -1 && wheel[i] >= rand) i--;
		return i == -1 ? 0 : i;
	}

	public static int breed(boolean[][] population,int capacity, int[][] items)
	{
		Phenotype[] pop = new Phenotype[population.length];
		for(int i = 0; i < pop.length; i++) pop[i] = new Phenotype(population[i],fitness(population[i], capacity, items));
		Arrays.sort(pop,new GeneticComparator());

		//Added here
		double fitnessSum = 0.0;
		for(int i = 0; i < pop.length; i++) fitnessSum += pop[i].fitness;
		double[] wheel = new double[pop.length];
		wheel[0] = pop[0].fitness/fitnessSum;
		for(int i = 1; i < wheel.length; i++) wheel[i] = pop[i].fitness/fitnessSum + wheel[i-1];

		int max = Integer.MIN_VALUE;
		for(int i = 0; i < population.length; i++)
		{
			int p1 = pickParent2(wheel);
			int p2 = pickParent2(wheel);

			//int p1 = pickParent((int)(Math.random()*population.length),population.length-1);
			//int p2 = pickParent((int)(Math.random()*population.length),population.length-1);

			population[i] = recombine(pop[p1].pheno,pop[p2].pheno);
			max = Math.max(fitness(population[i],capacity,items),max);
		}
		return max;
	}

	public static boolean[] recombine(boolean[] p1, boolean[] p2)
	{
		boolean[] c = new boolean[p1.length];
		for(int i = 0; i < p1.length; i++)
		{
			if(Math.random() <= 0.5) c[i] = p1[i];
			else c[i] = p2[i];
		}
		mutate(c);
		return c;
	}
		

	public static int geneticKS(int capacity, int[][] items, int popSize, int generations)
	{
		boolean[][] population = new boolean[popSize][items[0].length];
		for(int i = 0; i < population.length; i++)
		{
			int currentCapacity = capacity;
			int index = (int)(Math.random()*items[0].length);

			while(currentCapacity - items[1][index] >= 0)
			{
				population[i][index] = true;
				currentCapacity -= items[1][index];
				index = (int)(Math.random()*items[0].length);
			}
		}

		int max = Integer.MIN_VALUE;
		int count = 0;
		while(averageFitness(population,capacity,items) > 0 && count++ < generations) 
			max = Math.max(breed(population,capacity,items),max);

		/*Phenotype[] pop = new Phenotype[population.length];
		for(int i = 0; i < pop.length; i++) pop[i] = new Phenotype(population[i],fitness(population[i], capacity, items));
		Arrays.sort(pop,new GeneticComparator());
		return pop[0].fitness;*/
		return max;
	}
		
		

	public static int solveKS(int capacity, int[][] items)
	{
		//Create the table of sub knapsack problems
		int[][] table = new int[items[0].length+1][capacity+1];

		//Begin to iterate smaller problems and populate solution matrix
		for(int i = 1; i < table.length; i++)
		{
			for(int j = 1; j < table[i].length; j++)
			{
				/*If we can fit this item, compare the following
				 * Case 1) Stuffing the previous items knapsack, matching the remaining weight
				 * after taking this current item, into our current knapsack.
				 * Case 2) Not taking this item, and taking the previous items knapsack
				 * for this current weight.*/
				if(items[1][i-1] <= j)
				{
					table[i][j] = max(items[0][i-1] + table[i-1][j - items[1][i-1]],
							  table[i-1][j]);
				}
				//Otherwise, take previous items knapsack for this weight anyway
				else table[i][j] = table[i-1][j];
			}
		}
		//Prompt the user if they want to print the matrix
		/*Scanner input = new Scanner(System.in);
		int printMatrix = 0;
		System.out.print("\n0) No\n1) Yes\nPrint matrix?: ");
		printMatrix = input.nextInt();

		//Print matrix if yes
		if(printMatrix > 0)
		{
			for(int i = 0; i < table.length; i++)
			{
				for(int j = 0; j < table[i].length; j++) System.out.printf("%4d ",table[i][j]);
				System.out.println();
			}
		}
		//Return max value!
		System.out.println();*/
		return table[table.length-1][table[0].length-1];
	}

	//Solves the knapsack problem
	public static void main(String[] args)
	{
		int capacity = 10000;
		int numItems = capacity/10;
		int popSize = 250;
		int[][] items = new int[2][numItems];
		for(int i = 0; i < items[0].length; i++) 
		{
			items[0][i] = (int)(Math.random()*(numItems*2 + 1));
			items[1][i] = (int)(Math.random()*(capacity/1.618 + 1));
		}
		System.out.println("The max knapsack is: "+solveKS(capacity,items));
		System.out.println("The population size for the genetic algorithm is: "+popSize+"\n");
		System.out.println("The genetic algorithm with up to 100 generations got: "+geneticKS(capacity,items,popSize,100));
		System.out.println("The genetic algorithm with up to 250 generations got: "+geneticKS(capacity,items,popSize,250));
		System.out.println("The genetic algorithm with up to 500 generations got: "+geneticKS(capacity,items,popSize,500));
		System.out.println("The genetic algorithm with up to 750 generations got: "+geneticKS(capacity,items,popSize,750));
		System.out.println("The genetic algorithm with up to 1000 generations got: "+geneticKS(capacity,items,popSize,1000));
	}
}
