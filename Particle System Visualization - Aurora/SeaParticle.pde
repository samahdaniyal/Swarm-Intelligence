class SeaParticle {
  PVector pos, vel, acc; 
  float brightness, lifetime, size = 3;
  boolean disturbed = false, isLure = false;
  float disturbTimer = 0;
  
  PVector pBestPos; 
  float pBestFitness; 
  
  SeaParticle(float x, float y) {
    pos = new PVector(x, y);
    vel = PVector.random2D().mult(0.5);
    acc = new PVector(); 
    brightness = 50;
    lifetime = random(50, 200);
    if (random(1) < 0.01) isLure = true;
    
    pBestPos = pos.copy(); // Start with current position as PBest
    pBestFitness = 0; 
  }
  
  void update() {
    lifetime--;
    if (lifetime <= 0) return;

    int gridX = floor(pos.x / gridSize);
    int gridY = floor(pos.y / gridSize);

    acc.set(0, 0);

    // PSO when food is active
    if (foodActive) {
      // Calculate fitness (inverse distance to food, with small offset to avoid division by zero)
      float fitness = 1.0 / (dist(pos.x, pos.y, target.x, target.y) + 0.1);
      if (fitness > pBestFitness) {
        pBestFitness = fitness;
        pBestPos.set(pos); // Update PBest
      }

      // PSO velocity update
      float w = 0.7; // Inertia weight
      float c1 = 2.0; // Cognitive learning factor
      float c2 = 2.0; // Social learning factor
      PVector inertia = vel.copy().mult(w);
      PVector cognitive = PVector.mult(PVector.sub(pBestPos, pos), c1 * random(1)).mult(0.3); // 30% weight
      PVector social = PVector.mult(PVector.sub(GBest, pos), c2 * random(1)).mult(0.7); // 70% weight
      vel.set(inertia.add(cognitive).add(social));
      vel.limit(2); // Limit velocity
      pos.add(vel);

    } else {
      //flocking behavior
      PVector cohesionVec = new PVector();
      PVector separationVec = new PVector();
      PVector alignmentVec = new PVector();
      int nearby = 0;

      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          int key = (gridX + dx) + (gridY + dy) * floor(width / gridSize);
          if (grid.containsKey(key)) {
            ArrayList<SeaParticle> cellParticles = grid.get(key);
            for (SeaParticle other : cellParticles) {
              if (other != this) {
                float d = PVector.dist(pos, other.pos);
                if (d < 50) {
                  cohesionVec.add(other.pos);
                  separationVec.add(PVector.sub(pos, other.pos).div(max(d, 0.1)));
                  alignmentVec.add(other.vel);
                  nearby++;
                  if (other.brightness > 150 && random(1) < 0.03) {
                    acc.add(PVector.sub(other.pos, pos).normalize().mult(0.3));
                  }
                }
              }
            }
          }
        }
      }

      if (nearby > 0) {
        cohesionVec.div(nearby).sub(pos).normalize().mult(cohesion);
        separationVec.div(nearby).normalize().mult(separation);
        alignmentVec.div(nearby).normalize().mult(alignment);
        if (disturbed) cohesionVec.mult(2);
        acc.add(cohesionVec);
        acc.add(separationVec);
        acc.add(alignmentVec);
      } else if (!disturbed) {
        acc.add(PVector.random2D().mult(0.1));
      }

      // Predator interaction
      if (predatorMode && PVector.dist(pos, predator.pos) < 100) {
        PVector fleeVec = PVector.sub(pos, predator.pos).normalize().mult(3);
        acc.add(fleeVec);
        brightness = lerp(brightness, 20, 0.2);
        disturbTimer = max(disturbTimer, 1.0);
      }

      if (disturbed) {
        disturbTimer -= 0.1;
        if (disturbTimer <= 0) disturbed = false;
      }

      // Environmental forces
      PVector wind = new PVector(sin(frameCount * 0.01 + pos.y * 0.01) * 0.2 * windInfluence, 0);
      PVector tide = new PVector(0, sin(frameCount * 0.02 + pos.x * 0.01) * 0.3 * tideInfluence);
      acc.add(wind);
      acc.add(tide);

      vel.add(acc);
      vel.limit(2);
      pos.add(vel);
    }

    float waveOffset = sin(pos.x * 0.01 + waveHeight) * 10 * tideInfluence;
    pos.y += waveOffset * 0.05;

    // Extinction conditions
    if (predatorMode && PVector.dist(pos, predator.pos) < 20) lifetime = 0;
    if (pos.x < 0 || pos.x > width || pos.y < height/2 || pos.y > height) lifetime = 0;

    // Brightness updates
    if (isLure) {
      brightness = seaBrightness * (0.8 + sin(frameCount * 0.05) * 0.2);
    } else {
      brightness *= 0.95;
    }
    brightness *= 0.95;
  }
  
  void display() {
    if (lifetime <= 0) return;
    float pulse = disturbed ? seaBrightness : brightness;
    float alpha = pulse;
    noStroke();
    if (size > 5) fill(0, 200, 255, alpha);
    else if (isLure) fill(255, 215, 0, alpha);
    else if (disturbed) fill(0, 255, 255, alpha);
    else fill(0, 200, 255, alpha * 0.5);

    beginShape();
    vertex(pos.x, pos.y + size);
    bezierVertex(pos.x - size/2, pos.y + size/2, pos.x - size/2, pos.y - size/2, pos.x, pos.y - size);
    bezierVertex(pos.x + size/2, pos.y - size/2, pos.x + size/2, pos.y + size/2, pos.x, pos.y + size);
    endShape(CLOSE);

    for (int i = 1; i <= 3; i++) {
      fill(0, 200, 255, alpha * 0.3 / i);
      ellipse(pos.x, pos.y, size + i * 5, size * 0.6 + i * 3);
    }
  }
  
  void brighten() {
    brightness = seaBrightness;
  }
  
  void disturb() {
    disturbed = true;
    disturbTimer = 2.0;
  }
}
