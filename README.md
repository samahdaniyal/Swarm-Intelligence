# Swarm-Intelligence

This repository contains the Assignment 2 of CS 451 - Computational Intelligence (Spring 2025) by Syeda Samah Daniyal and Aina Shakeel. The assignment is divided into two main sections:

---

## 1. Facility Layout Problem using ACO

- **Objective:** Optimize hospital facility layouts by minimizing patient movement costs.
- **Problem:** Modeled as a Quadratic Assignment Problem (QAP) using the Els19 instance (n = 19).
- **Approach:** 
  - Utilizes Ant Colony Optimization (ACO) where facilities are assigned to locations based on pheromone trails and heuristic desirability.
  - Iteratively fine-tunes parameters such as the number of ants, iterations, pheromone influence (α), desirability influence (β), and evaporation rate (γ) to balance exploration and exploitation.
- **Results:** 
  - Initial runs and subsequent fine-tuning show significant improvements in the total cost, demonstrating the robustness of ACO for layout optimization.
  - Detailed convergence analysis and experimental results are provided in the full report.

---

## 2. Visualizing Swarms

- **Objective:** Simulate and visualize complex swarm dynamics.
- **Concept:** 
  - Combines Particle Swarm Optimization (PSO) with particle system techniques.
  - Models two types of particles: **Aurora particles** (with luminescent, trailing behavior) and **Sea particles** (exhibiting flocking and PSO-based dynamics).
- **Features:** 
  - Interactive simulation built using Processing.
  - Includes real-time controls via sliders and keyboard/mouse inputs to adjust parameters like speed, brightness, flocking coefficients, and environmental forces.
  - Incorporates additional elements such as a predator and dynamic environmental factors (wind, tide, solar activity) to enhance realism and interactivity.
- **Outcome:** Provides an engaging platform to explore emergent swarm behaviors and visualize complex interactions.
