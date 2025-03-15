# Swarm-Intelligence

**CS 451 - Computational Intelligence, Spring 2025, Habib University**

---

## Overview

This repository contains the report and implementation details for Assignment 2 – Swarm Intelligence. The project is divided into two main parts:

- **Facility Layout Optimization using Ant Colony Optimization (ACO)**
- **Swarm Visualization using Particle Swarm Optimization (PSO) and Particle Systems**

The report details the problem formulations, methodologies, experimental setups, results, and analysis for both sections.

---

## Objective

The primary goal of this assignment is to explore and demonstrate the application of swarm intelligence techniques to real-world challenges. The project showcases how:
- Fine-tuned ACO can effectively optimize hospital facility layouts by minimizing patient movement costs.
- An interactive simulation combining PSO and particle systems can visualize complex swarm dynamics in real-time.

---

## Problem Formulation

### Facility Layout Optimization using ACO

- **Challenge:** Assign hospital facilities to locations to minimize the overall patient movement cost.
- **Approach:** Formulated as a Quadratic Assignment Problem (QAP) using the Els19 instance (n = 19).  
- **Methodology:**  
  - Utilizes Ant Colony Optimization where ants construct solutions based on pheromone trails and heuristic desirability.
  - Involves parameter tuning (pheromone influence α, desirability influence β, evaporation rate γ, number of ants, and iterations) to balance exploration and exploitation.
  - Detailed experimental results illustrate convergence behavior and solution quality improvements.

### Swarm Visualization

- **Challenge:** Simulate and visually explore swarm dynamics inspired by natural phenomena.
- **Approach:** Combines Particle Swarm Optimization with particle system techniques to model two types of particles:
  - **Aurora Particles:** Exhibit glowing, trailing behavior driven by Perlin noise and sinusoidal functions.
  - **Sea Particles:** Use PSO-based movement and flocking behaviors, influenced by environmental factors and a predator element.
- **Methodology:**  
  - Implements interactive controls using Processing (with ControlP5 library) for real-time adjustments of simulation parameters such as speed, brightness, and environmental forces.
  - Provides an immersive visual platform to study emergent behaviors.

---

## Dependencies

- **Processing:** For running the interactive simulation.
- **Java:** Underlying language for Processing sketches.
- **ControlP5 Library:** For creating interactive UI components (sliders, buttons).
- Python 3.8+
- NumPy
- Matplotlib

---

## References

- **Els19 QAP Instance:** Retrieved from [QAPLIB](https://coral.ise.lehigh.edu/data-sets/qaplib/qaplib-problem-instances-and-solutions/#El)
