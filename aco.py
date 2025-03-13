import numpy as np
import random
import matplotlib.pyplot as plt

def read_qap_instance(file_path):
    
    with open(file_path, 'r') as f:
        # Reading all non-empty lines and strip whitespace.
        lines = [line.strip() for line in f if line.strip() != ""]
    
    # The first line contains the instance size.
    n = int(lines[0])
    
    # Reading next n lines as the distance matrix.
    distance_matrix = []
    for i in range(1, n + 1):
        row = list(map(float, lines[i].split()))
        if len(row) != n:
            raise ValueError(f"Expected {n} numbers in row {i} of distance matrix, got {len(row)}.")
        distance_matrix.append(row)
    
    # Reading next n lines as the flow matrix.
    flow_matrix = []
    for i in range(n + 1, 2 * n + 1):
        row = list(map(float, lines[i].split()))
        if len(row) != n:
            raise ValueError(f"Expected {n} numbers in row {i - n} of flow matrix, got {len(row)}.")
        flow_matrix.append(row)
    
    return distance_matrix, flow_matrix

# QAP Instance Class
class QAPInstance:
    def __init__(self, distance_matrix, flow_matrix):
        # distance_matrix: n x n matrix with distances between locations.
        # flow_matrix: n x n matrix with flows between facilities.
        
        self.n = len(distance_matrix)
        self.distance = np.array(distance_matrix)
        self.flow = np.array(flow_matrix)
    
    def compute_cost(self, assignment):
        # Given an assignment (a permutation such that assignment[i] is the location for facility i),
        """ 
        compute the cost:
           Cost = sum_{i,j} flow[i][j] * distance[assignment[i]][assignment[j]]
        """
        cost = 0.0
        n = self.n
        for i in range(n):
            for j in range(n):
                cost += self.flow[i, j] * self.distance[assignment[i], assignment[j]]
        return cost

# Ant Class: Constructs a single solution
class Ant:
    def __init__(self, instance, pheromone, alpha, beta):
        # instance: QAPInstance object.
        # pheromone: A 2D array where pheromone[i][j] indicates the desirability (heuristic) of assigning facility i to location j.
        # alpha: Influence of pheromone.
        # beta: Influence of desirability (heuristic).
        
        self.instance = instance
        self.n = instance.n
        self.pheromone = pheromone
        self.alpha = alpha
        self.beta = beta
        self.solution = [-1] * self.n  # solution[i] = location assigned to facility i
        self.cost = None
        
        # Precomputing desirability (heuristic) information:
        # For each facility, computing the total flow (higher means more “central” facility)
        # For each location, computing the total distance (lower means more “central” location)
        self.flow_sums = np.sum(instance.flow, axis=1)
        self.dist_sums = np.sum(instance.distance, axis=1)
        self.desirability = np.zeros((self.n, self.n))
        for i in range(self.n):
            for j in range(self.n):
                # A higher desirability (heuristic) value suggests that facility i should go to location j.
                self.desirability[i, j] = self.flow_sums[i] / (self.dist_sums[j] + 1e-10)

    def construct_solution(self):
        """
        Constructs a complete assignment.
        The ant processes facilities in descending order of total flow
        and assigns each facility i to an available location j using:

            p_{ij} = (tau_{ij}^alpha * eta_{ij}^beta) / sum_{k in allowed}(tau_{ik}^alpha * eta_{ik}^beta)
        """
        n = self.n
        facilities = list(range(n))
        # Sorting facilities by total flow (descending).
        facilities.sort(key=lambda i: self.flow_sums[i], reverse=True)
        
        # Keeping track of which locations are still available.
        available_locations = list(range(n))
        solution = [-1] * n
        
        for i in facilities:
            # Calculating numerator for each available location
            numerators = []
            for j in available_locations:
                tau_ij = self.pheromone[i, j] ** self.alpha
                eta_ij = self.desirability[i, j] ** self.beta
                numerators.append(tau_ij * eta_ij)
            
            # Computing the denominator as the sum of numerators
            denominator = sum(numerators)
            
            # If denominator is zero, using uniform probability to avoid division by zero
            if denominator == 0:
                probabilities = [1 / len(available_locations)] * len(available_locations)
            else:
                probabilities = [num / denominator for num in numerators]
            
            # Choosing a location based on the probabilities
            chosen_location = random.choices(available_locations, weights=probabilities, k=1)[0]
            solution[i] = chosen_location
            available_locations.remove(chosen_location)
        
        self.solution = solution
        self.cost = self.instance.compute_cost(solution)
        return solution, self.cost

# Ant Colony Class: Overall ACO Algorithm
class AntColony:
    def __init__(self, instance, num_ants, alpha, beta, evaporation_rate, Q, initial_pheromone, tau_min=0.1, tau_max=10.0):
        """
        instance: QAPInstance object.
        num_ants: Number of ants to simulate per iteration.
        alpha, beta: ACO parameters (influence of pheromone and desirability (heuristic)).
        evaporation_rate: The rate (γ) at which pheromone evaporates.
        Q: Constant used for pheromone update.
        initial_pheromone: Initial pheromone value for all facility-location pairs.
        tau_min, tau_max: Minimum and maximum pheromone limits.
        """
        self.instance = instance
        self.num_ants = num_ants
        self.alpha = alpha
        self.beta = beta
        self.evaporation_rate = evaporation_rate
        self.Q = Q
        self.n = instance.n
        self.pheromone = np.ones((self.n, self.n)) * initial_pheromone
        self.tau_min = tau_min
        self.tau_max = tau_max
        
        self.best_solution = None
        self.best_cost = float('inf')
        self.iteration_best_costs = []
        self.iteration_avg_costs = []
    
    def run(self, iterations):
        for it in range(iterations):
            ants = [Ant(self.instance, self.pheromone, self.alpha, self.beta) for _ in range(self.num_ants)]
            costs = []
            for ant in ants:
                sol, cost = ant.construct_solution()
                costs.append(cost)
                if cost < self.best_cost:
                    self.best_cost = cost
                    self.best_solution = sol.copy()
            avg_cost = sum(costs) / len(costs)
            self.iteration_best_costs.append(self.best_cost)
            self.iteration_avg_costs.append(avg_cost)
            print(f"Iteration {it + 1}: Best Cost = {self.best_cost}, Average Cost = {avg_cost}")
            
            # Evaporate pheromone:
            self.pheromone = (1 - self.evaporation_rate) * self.pheromone
            
            # Depositing pheromone for each ant proportional to the quality of its solution.
            for ant in ants:
                for facility in range(self.n):
                    loc = ant.solution[facility]
                    self.pheromone[facility, loc] += self.Q / ant.cost
            
            # Enforcing maximum and minimum pheromone limits to avoid stagnation.
            self.pheromone = np.clip(self.pheromone, self.tau_min, self.tau_max)
    
    def plot_convergence(self):
        plt.figure(figsize=(10, 6))
        plt.plot(range(1, len(self.iteration_best_costs) + 1), self.iteration_best_costs, label="Best Cost")
        plt.plot(range(1, len(self.iteration_avg_costs) + 1), self.iteration_avg_costs, label="Average Cost")
        plt.xlabel("Iteration")
        plt.ylabel("Cost")
        plt.title("Iteration vs. Best and Average Cost")
        plt.legend()
        plt.grid(True)
        plt.show()

# Main Function
def main():
    # Path to the text file containing the instance data.
    file_path = "els19.txt"  
    
    # Reading the distance and flow matrices from the file.
    distance_matrix, flow_matrix = read_qap_instance(file_path)
    
    # Creating a QAP instance.
    instance = QAPInstance(distance_matrix, flow_matrix)
    
    # ACO Parameters
    num_ants = 80
    iterations = 200        # You can increase iterations for a more thorough search.
    alpha = 7                # Influence of pheromone.
    beta = 4                 # Influence of desirability (heuristic).
    evaporation_rate = 0.6   # γ: Pheromone evaporation rate.
    Q = 1                    # Constant for pheromone update.
    initial_pheromone = 1.0  # Starting pheromone value.
    tau_min = 0.1            # Minimum pheromone limit.
    tau_max = 10.0           # Maximum pheromone limit.
    
    # Running the ant colony optimization.
    colony = AntColony(instance, num_ants, alpha, beta, evaporation_rate, Q, initial_pheromone, tau_min, tau_max)
    colony.run(iterations)
    
    print("\nBest assignment (facility -> location):", colony.best_solution)
    print("Best cost:", colony.best_cost)
    
    # Plotting the convergence graph.
    colony.plot_convergence()

if __name__ == "__main__":
    main()
