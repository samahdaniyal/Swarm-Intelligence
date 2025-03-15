class AuroraParticle {
  float lifetime = random(100, 300); // Lifetime added
  PVector pos, vel, acc; // Added explicit acceleration
  color col;
  PVector[] trail;
  int trailLength = 20;
  
  AuroraParticle(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(0, random(-0.5, 0.5));
    acc = new PVector(); // Initialize acceleration
    trail = new PVector[trailLength];
    for (int i = 0; i < trailLength; i++) {
      trail[i] = pos.copy();
    }
    updateColor();
  }
  
  void update() {
    lifetime--; // Decrement each frame
    if (lifetime <= 0) return; // Skip update if dead
    
    // Explicit acceleration for dynamics
    acc.set(noise(pos.x * 0.01, frameCount * 0.02) * 2 - 1, 
            sin(frameCount * 0.03 + pos.x * 0.01) * 0.3 * solarActivity);
    
    // Alignment with nearby particles
    PVector alignmentVec = new PVector();
    int nearby = 0;
    for (AuroraParticle other : auroraParticles) {
      float d = dist(pos.x, pos.y, other.pos.x, other.pos.y);
      if (d > 0 && d < 50) {
        alignmentVec.add(other.vel);
        nearby++;
      }
    }
    if (nearby > 0) {
      alignmentVec.div(nearby).normalize().mult(0.15);
      acc.add(alignmentVec); // Add alignment to acceleration
    }
    
    vel.add(acc); // Update velocity with acceleration
    vel.limit(3 + solarActivity * 0.5);
    pos.add(vel.mult(auroraSpeed)); // Apply auroraSpeed
    
    // Update trail
    for (int i = trailLength - 1; i > 0; i--) {
      trail[i] = trail[i - 1].copy();
      trail[i].x += noise(pos.x * 0.01, frameCount * 0.02 + i * 0.1) * 8 - 4;
      trail[i].y += sin(frameCount * 0.05 + i * 0.2) * 1.5;
    }
    trail[0] = pos.copy();
    
    // Boundary: reset to top if beyond upper third
    if (pos.y > height/2.25) {
      pos.y = 0;
      vel.set(0, random(0.1, 0.5));
      acc.set(0, 0); // Reset acceleration
    }
    if (pos.x < 0) pos.x = width;
    if (pos.x > width) pos.x = 0;
    if (pos.y < 0) pos.y = 0; // Prevent going above screen
    
    updateColor();
  }
  
  void updateColor() {
    float r, g, b;
    float energy = map(solarActivity, 0.5, 5.0, 0.8, 1.5);
    float rand = noise(pos.x * 0.01, pos.y * 0.01, frameCount * 0.01);
    if (rand < 0.6) { // Green
      r = 50 * energy;
      g = 200 * energy;
      b = 80 * energy;
    } else if (rand < 0.8) { // Purple
      r = 150 * energy;
      g = 80 * energy;
      b = 200 * energy;
    } else if (rand < 0.9) { // Pink
      r = 200 * energy;
      g = 100 * energy;
      b = 150 * energy;
    } else { // Red
      r = 220 * energy;
      g = 50 * energy;
      b = 50 * energy;
    }
    float alpha = map(solarActivity, 0.5, 5.0, 150, 255);
    col = color(r, g, b, alpha);
  }
  
  void display() {
    if (lifetime <= 0) return; // Skip display if dead
    noFill();
    strokeWeight(25);
    beginShape();
    for (int i = 0; i < trailLength; i++) {
      float baseAlpha = alpha(col) * (1.0 - i / float(trailLength)) * 0.9;
      // Tie alpha to lifetime for fading effect
      float lifetimeAlpha = map(lifetime, 0, 300, 0, 1);
      // Horizontal banding and flicker
      float banding = sin(trail[i].y * 0.05) * 0.2 + 0.8;
      float flicker = noise(frameCount * 0.05 + trail[i].x * 0.01) * 0.3 + 0.7;
      float alpha = baseAlpha * banding * flicker * lifetimeAlpha;
      stroke(red(col), green(col), blue(col), alpha);
      float x = trail[i].x;
      float y = trail[i].y;
      curveVertex(x, y);
      if (i == 0 || i == trailLength - 1) curveVertex(x, y); // Smooth ends
    }
    endShape();
    noStroke();
  }
}

// Add this function to your main sketch (outside the class)
void generateAuroraParticles() {
  float m_p = 1000 / 100.0; // Mean particles per frame (adjust as needed)
  float sigma_p = m_p * 0.2; // 20% variance
  int N = max(0, (int)(m_p + randomGaussian() * sigma_p));
  for (int i = 0; i < N; i++) {
    float x = random(width);
    float y = random(0, height/3); // Spawn in upper third
    auroraParticles.add(new AuroraParticle(x, y));
  }
}
