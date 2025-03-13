// Global variables (unchanged except for debug flag)
ArrayList<SeaParticle> seaParticles;
ArrayList<AuroraParticle> auroraParticles;
ArrayList<Ripple> ripples;
float auroraSpeed = 1;
float seaBrightness = 100;
float planktonDensity = 1000;
float waveHeight = 0;
float waveSpeed = 0.02;
float cohesion = 0.5;
float separation = 1.0;
float alignment = 0.3;
float solarActivity = 1.0;
PVector[] flowField;
Slider auroraSpeedSlider, seaBrightnessSlider, planktonDensitySlider, disturbanceRadiusSlider, waveSpeedSlider, flowUpdateRateSlider;
Slider cohesionSlider, separationSlider, alignmentSlider, windInfluenceSlider, tideInfluenceSlider, solarActivitySlider;

float windInfluence = 1.0;
float tideInfluence = 0.5;
float flowUpdateRate = 10;
int lastFlowUpdate = 0;
float disturbanceRadius = 50;
PVector lastMouse;
PVector target;
boolean foodActive = false;
boolean flowFieldVisible = false;
boolean isPaused = false;
boolean swarmLinesVisible = false;
boolean debugAurora = true; // Added for debugging

int gridSize = 50;
HashMap<Integer, ArrayList<SeaParticle>> grid;
ArrayList<SeaParticle> newParticles;
boolean predatorMode = false;
Predator predator;

void setup() {
  frameRate(30);
  size(1200, 800);
  seaParticles = new ArrayList<SeaParticle>();
  auroraParticles = new ArrayList<AuroraParticle>();
  ripples = new ArrayList<Ripple>();
  grid = new HashMap<Integer, ArrayList<SeaParticle>>();
  newParticles = new ArrayList<SeaParticle>();
  
  int sliderX = 20;
  auroraSpeedSlider = new Slider(sliderX, 20, 200, 20, 0.1, 3, "Aurora Speed");
  seaBrightnessSlider = new Slider(sliderX, 50, 200, 20, 50, 255, "Sea Brightness");
  planktonDensitySlider = new Slider(sliderX, 80, 200, 20, 500, 2000, "Plankton Density");
  disturbanceRadiusSlider = new Slider(sliderX, 110, 200, 20, 20, 100, "Disturbance Radius");
  waveSpeedSlider = new Slider(sliderX, 140, 200, 20, 0.01, 0.05, "Wave Speed");
  flowUpdateRateSlider = new Slider(sliderX, 170, 200, 20, 5, 20, "Flow Update Rate");
  cohesionSlider = new Slider(sliderX, 200, 200, 20, 0, 2, "Cohesion");
  separationSlider = new Slider(sliderX, 230, 200, 20, 0, 2, "Separation");
  alignmentSlider = new Slider(sliderX, 260, 200, 20, 0, 2, "Alignment");
  windInfluenceSlider = new Slider(sliderX, 290, 200, 20, 0.5, 2.5, "Wind Influence");
  tideInfluenceSlider = new Slider(sliderX, 320, 200, 20, 0.5, 2.5, "Tide Influence");
  solarActivitySlider = new Slider(sliderX, 350, 200, 20, 0.5, 5.0, "Solar Activity");
  
  flowField = new PVector[width * height / 100];
  updateFlowField();
  
  initializeParticles();
}

void initializeParticles() {
  seaParticles.clear();
  auroraParticles.clear();
  for (int i = 0; i < planktonDensity; i++) {
    float x = random(width);
    float y = height/2 + randomGaussian() * (height/4);
    seaParticles.add(new SeaParticle(x, constrain(y, height/2, height)));
  }
  for (int i = 0; i < 1000; i++) { // Increased to 1000 for denser curtains
    float x = random(width);
    float y = random(0, height/2); // Spawn across upper half for full coverage
    auroraParticles.add(new AuroraParticle(x, y));
  }
  lastMouse = new PVector();
  target = new PVector(width/2, height * 3/4);
  predator = new Predator();
}

void draw() {
  background(10, 20, 50); // Night scene
  blendMode(ADD);
  
  // Stars
  for (int i = 0; i < 100; i++) {
    fill(255, random(50, 255));
    ellipse(random(width), random(height/2), 2, 2);
  }
  
  // Aurora (moved to ensure visibility)
  for (AuroraParticle p : auroraParticles) {
    if (!isPaused) p.update();
    p.display();
  }
  
  if (!isPaused && frameCount - lastFlowUpdate >= flowUpdateRate) {
    updateFlowField();
    lastFlowUpdate = frameCount;
  }
  
  // Sliders and UI
  fill(0, 100);
  rect(10, 10, 230, 370);
  
  auroraSpeedSlider.display();
  seaBrightnessSlider.display();
  planktonDensitySlider.display();
  disturbanceRadiusSlider.display();
  waveSpeedSlider.display();
  flowUpdateRateSlider.display();
  cohesionSlider.display();
  separationSlider.display();
  alignmentSlider.display();
  windInfluenceSlider.display();
  tideInfluenceSlider.display();
  solarActivitySlider.display();
  
  auroraSpeed = auroraSpeedSlider.getValue();
  seaBrightness = seaBrightnessSlider.getValue();
  planktonDensity = planktonDensitySlider.getValue();
  disturbanceRadius = disturbanceRadiusSlider.getValue();
  waveSpeed = waveSpeedSlider.getValue();
  flowUpdateRate = flowUpdateRateSlider.getValue();
  cohesion = cohesionSlider.getValue();
  separation = separationSlider.getValue();
  alignment = alignmentSlider.getValue();
  windInfluence = windInfluenceSlider.getValue();
  tideInfluence = tideInfluenceSlider.getValue();
  solarActivity = solarActivitySlider.getValue();
  
  if (!isPaused) {
    while (seaParticles.size() + newParticles.size() < planktonDensity) {
      float x = random(width);
      float y = height/2 + randomGaussian() * (height/4);
      newParticles.add(new SeaParticle(x, constrain(y, height/2, height)));
    }
    while (seaParticles.size() + newParticles.size() > planktonDensity) {
      if (!seaParticles.isEmpty()) seaParticles.remove(seaParticles.size() - 1);
    }
    seaParticles.addAll(newParticles);
    newParticles.clear();
  }
  
  updateGrid();
  for (SeaParticle p : seaParticles) {
    if (!isPaused) p.update();
    p.display();
  }
  
  if (!isPaused) drawWaves();
  
  for (int i = ripples.size() - 1; i >= 0; i--) {
    Ripple r = ripples.get(i);
    if (!isPaused) r.update();
    r.display();
    if (r.isFinished()) ripples.remove(i);
  }
  
  if (predatorMode) {
    if (!isPaused) predator.update();
    predator.display();
  }
  
  if (foodActive) {
    fill(255, 215, 0, 150);
    ellipse(target.x, target.y, 20, 20);
  }
  
  if (flowFieldVisible) {
    stroke(255, 50);
    for (int y = 0; y < height; y += 50) {
      for (int x = 0; x < width; x += 50) {
        int index = (x / 10) + (y / 10) * (width / 10);
        if (index >= 0 && index < flowField.length) {
          PVector f = flowField[index].copy().normalize().mult(20);
          line(x, y, x + f.x, y + f.y);
          pushMatrix();
          translate(x + f.x, y + f.y);
          rotate(f.heading());
          line(0, 0, -5, -5);
          line(0, 0, -5, 5);
          popMatrix();
        }
      }
    }
    noStroke();
  }
  
  if (swarmLinesVisible) {
    stroke(255, 10);
    for (int i = 0; i < seaParticles.size(); i += 2) {
      SeaParticle p1 = seaParticles.get(i);
      for (SeaParticle p2 : grid.getOrDefault(getGridKey(p1.pos.x, p1.pos.y), new ArrayList<SeaParticle>())) {
        if (p1 != p2 && dist(p1.pos.x, p1.pos.y, p2.pos.x, p2.pos.y) < 50) {
          line(p1.pos.x, p1.pos.y, p2.pos.x, p2.pos.y);
        }
      }
    }
    noStroke();
  }
  
  blendMode(BLEND);
  
  // Debug aurora info
  if (debugAurora && frameCount % 60 == 0) {
    println("Aurora particles: " + auroraParticles.size());
    if (!auroraParticles.isEmpty()) {
      AuroraParticle p = auroraParticles.get(0);
      println("Sample pos: (" + p.pos.x + ", " + p.pos.y + "), col: " + hex(p.col));
    }
  }
  
  fill(255);
  textSize(12);
  textAlign(RIGHT);
  text("Wind: " + nf(windInfluence, 1, 1), width - 20, 20);
  text("Tide: " + nf(tideInfluence, 1, 1), width - 20, 40);
  text("Predator Mode: " + (predatorMode ? "On" : "Off"), width - 20, 60);
  text("Food Source: " + (foodActive ? "On" : "Off"), width - 20, 80);
  text("Flow Field: " + (flowFieldVisible ? "On" : "Off"), width - 20, 100);
  text("Swarm Lines: " + (swarmLinesVisible ? "On" : "Off"), width - 20, 120);
  text("Paused: " + (isPaused ? "Yes" : "No"), width - 20, 140);
  text("Solar Activity: " + nf(solarActivity, 1, 1), width - 20, 160);
}

void drawWaves() {
  noFill();
  stroke(0, 100, 200, 50);
  strokeWeight(2);
  for (int y = height/2; y < height; y += 10) {
    beginShape();
    for (int x = 0; x < width; x += 10) {
      float waveOffset = sin(x * 0.01 + waveHeight) * 10 * tideInfluence;
      vertex(x, y + waveOffset);
      if (abs(waveOffset) > 8 && random(1) < (waveSpeed < 0.03 ? 0.15 : 0.1)) {
        for (SeaParticle p : seaParticles) {
          float radius = predatorMode ? disturbanceRadius * 2 : disturbanceRadius;
          if (dist(x, y + waveOffset, p.pos.x, p.pos.y) < radius) {
            p.brighten();
            p.disturb();
          }
        }
      }
    }
    endShape();
  }
  waveHeight += waveSpeed;
}

void updateFlowField() {
  for (int i = 0; i < flowField.length; i++) {
    float x = (i % (width / 10)) * 10;
    float y = (i / (width / 10)) * 10;
    float distFromCenter = dist(x, y, width/2, height/4);
    float angle = noise(x * 0.01, y * 0.01, frameCount * 0.005) * TWO_PI;
    // Bias toward vertical flow to mimic curtains
    angle = map(y, 0, height/2, -PI/2, PI/2) + angle * 0.2; // Strong vertical component
    float mag = map(distFromCenter, 0, width/2, 0.5, 1.5) * solarActivity * windInfluence;
    flowField[i] = PVector.fromAngle(angle).mult(mag);
  }
}

void updateGrid() {
  grid.clear();
  for (SeaParticle p : seaParticles) {
    int gridX = floor(p.pos.x / gridSize);
    int gridY = floor(p.pos.y / gridSize);
    int key = gridX + gridY * floor(width / gridSize);
    if (!grid.containsKey(key)) {
      grid.put(key, new ArrayList<SeaParticle>());
    }
    grid.get(key).add(p);
  }
}

int getGridKey(float x, float y) {
  int gridX = floor(x / gridSize);
  int gridY = floor(y / gridSize);
  return gridX + gridY * floor(width / gridSize);
}

void mousePressed() {
  lastMouse.set(mouseX, mouseY);
  if (mouseY > height/2) {
    ripples.add(new Ripple(mouseX, mouseY));
    for (SeaParticle p : seaParticles) {
      float radius = predatorMode ? disturbanceRadius * 2 : disturbanceRadius;
      if (dist(mouseX, mouseY, p.pos.x, p.pos.y) < radius) {
        p.brighten();
        p.disturb();
        if (random(1) < 0.1) p.smokescreen();
      }
    }
  }
}

void mouseDragged() {
  if (mouseY > height/2) {
    PVector current = new PVector(mouseX, mouseY);
    PVector force = PVector.sub(current, lastMouse).normalize().mult(2);
    for (SeaParticle p : seaParticles) {
      float radius = predatorMode ? disturbanceRadius * 2 : disturbanceRadius;
      if (dist(mouseX, mouseY, p.pos.x, p.pos.y) < radius) {
        p.vel.add(force);
        p.brighten();
        p.disturb();
      }
    }
    ripples.add(new Ripple(mouseX, mouseY));
  }
  lastMouse.set(mouseX, mouseY);
}

void keyPressed() {
  if (key == 'P' || key == 'p') predatorMode = !predatorMode;
  if (key == 'F' || key == 'f') {
    foodActive = !foodActive;
    if (foodActive) target.set(mouseX, mouseY);
  }
  if (key == 'V' || key == 'v') flowFieldVisible = !flowFieldVisible;
  if (key == 'L' || key == 'l') swarmLinesVisible = !swarmLinesVisible;
  if (key == ' ') isPaused = !isPaused;
  if (key == 'R' || key == 'r') initializeParticles();
}

class SeaParticle {
  PVector pos, vel;
  float brightness;
  boolean disturbed = false;
  float disturbTimer = 0;
  boolean isLure = false;
  float size = 5;
  color smokeColor = color(0, 200, 255);
  
  SeaParticle(float x, float y) {
    pos = new PVector(x, y);
    vel = PVector.random2D().mult(0.5);
    brightness = 50;
    if (random(1) < 0.01) isLure = true;
  }
  
  void update() {
    int gridX = floor(pos.x / gridSize);
    int gridY = floor(pos.y / gridSize);
    
    PVector cohesionVec = new PVector();
    PVector separationVec = new PVector();
    PVector alignmentVec = new PVector();
    PVector targetVec = new PVector();
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
                if (brightness > 150 && random(1) < 0.02) {
                  other.vel.add(PVector.sub(pos, other.pos).normalize().mult(0.5));
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
      if (disturbed) vel.add(cohesionVec.mult(2));
      vel.add(cohesionVec).add(separationVec).add(alignmentVec);
    } else if (!disturbed) {
      vel.add(PVector.random2D().mult(0.1));
    }
    
    if (foodActive) {
      targetVec = PVector.sub(target, pos).normalize().mult(0.2);
      vel.add(targetVec);
    }
    
    if (predatorMode && PVector.dist(pos, predator.pos) < 100) {
      PVector fleeVec = PVector.sub(pos, predator.pos).normalize().mult(2);
      vel.add(fleeVec);
    }
    
    if (disturbed) {
      disturbTimer -= 0.1;
      if (disturbTimer <= 0) disturbed = false;
    }
    
    vel.x += sin(frameCount * 0.01 + pos.y * 0.01) * 0.1;
    vel.y += sin(frameCount * 0.02 + pos.x * 0.01) * tideInfluence * 0.1;
    float waveOffset = sin(pos.x * 0.01 + waveHeight) * 10 * tideInfluence;
    pos.y += waveOffset * 0.05;
    
    if (isLure) {
      brightness = seaBrightness * (0.8 + sin(frameCount * 0.05) * 0.2);
    } else {
      brightness *= 0.95;
    }
    
    vel.limit(2);
    pos.add(vel);
    
    if (pos.x < 0) pos.x = width;
    if (pos.x > width) pos.x = 0;
    if (pos.y < height/2) pos.y = height;
    if (pos.y > height) pos.y = height/2;
  }
  
  void display() {
    float pulse = brightness;
    if (disturbed) pulse = seaBrightness;
    float alpha = pulse;
    noStroke();
    if (size > 5) {
      fill(smokeColor, alpha);
    } else if (isLure) {
      fill(255, 215, 0, alpha);
    } else if (disturbed) {
      fill(0, 255, 255, alpha);
    } else {
      fill(0, 200, 255, alpha * 0.5);
    }
    ellipse(pos.x, pos.y, size, size * 0.6);
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
  
  void smokescreen() {
    for (int i = 0; i < 10; i++) {
      float x = pos.x + random(-20, 20);
      float y = pos.y + random(-20, 20);
      if (y > height/2 && y < height) {
        SeaParticle spark = new SeaParticle(x, y);
        spark.brightness = seaBrightness * 0.5;
        spark.vel = PVector.random2D().mult(1.5);
        spark.size = 7;
        spark.smokeColor = color(255, 150, 0, spark.brightness);
        newParticles.add(spark);
      }
    }
  }
}

class Predator {
  PVector pos, vel;
  
  Predator() {
    pos = new PVector(width/2, height * 3/4);
    vel = PVector.random2D().mult(2);
  }
  
  void update() {
    pos.add(vel);
    if (pos.x < 0 || pos.x > width) vel.x *= -1;
    if (pos.y < height/2 || pos.y > height) vel.y *= -1;
  }
  
  void display() {
    fill(255, 0, 0);
    ellipse(pos.x, pos.y, 20, 20);
  }
}

class AuroraParticle {
  PVector pos, vel;
  color col;
  PVector[] trail;
  int trailLength = 20; // Longer trails for smoother curtains
  
  AuroraParticle(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(0, random(-0.5, 0.5)); // Initial vertical bias
    trail = new PVector[trailLength];
    for (int i = 0; i < trailLength; i++) {
      trail[i] = pos.copy();
    }
    updateColor();
  }
  
  void update() {
    int index = floor(pos.x / 10) + floor(pos.y / 10) * (width / 10);
    if (index >= 0 && index < flowField.length) {
      PVector flow = flowField[index].copy().mult(auroraSpeed * solarActivity * 0.1); // Adjusted influence
      vel.add(flow);
    }
    
    // Alignment for cohesive curtains
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
      alignmentVec.div(nearby).normalize().mult(0.15); // Stronger alignment
      vel.add(alignmentVec);
    }
    
    // Dynamic waves
    if (random(1) < 0.05) {
      vel.x += noise(pos.x * 0.01, frameCount * 0.02) * 2 - 1; // Gentle horizontal wave
    }
    vel.y += sin(frameCount * 0.03 + pos.x * 0.01) * 0.3; // Vertical oscillation
    
    vel.limit(3);
    pos.add(vel);
    
    // Update trails with wavy motion
    for (int i = trailLength - 1; i > 0; i--) {
      trail[i] = trail[i - 1].copy();
      trail[i].x += noise(pos.x * 0.01, frameCount * 0.02 + i * 0.1) * 8 - 4; // Wider horizontal waves
      trail[i].y += sin(frameCount * 0.05 + i * 0.2) * 1.5; // Stronger vertical wave
    }
    trail[0] = pos.copy();
    
    // Boundary to keep in upper half
    if (pos.y > height/2) {
      pos.y = 0;
      vel.set(0, random(0.1, 0.5)); // Reset with upward bias
    }
    if (pos.x < 0) pos.x = width;
    if (pos.x > width) pos.x = 0;
    if (pos.y < 0) pos.y = height/2;
    
    updateColor();
  }
  
  void updateColor() {
    float r, g, b;
    float energy = map(solarActivity, 0.5, 5.0, 0.7, 1.2); // Slightly higher energy for vibrancy
    float rand = noise(pos.x * 0.01, pos.y * 0.01, frameCount * 0.01); // Per-particle color variation
    if (rand < 0.6) { // 60% green (dominant)
      r = 50 * energy;
      g = 200 * energy;
      b = 80 * energy;
    } else if (rand < 0.8) { // 20% purple
      r = 150 * energy;
      g = 80 * energy;
      b = 200 * energy;
    } else if (rand < 0.9) { // 10% pink
      r = 200 * energy;
      g = 100 * energy;
      b = 150 * energy;
    } else { // 10% red
      r = 220 * energy;
      g = 50 * energy;
      b = 50 * energy;
    }
    float alpha = map(solarActivity, 0.5, 5.0, 120, 250); // Higher alpha for visibility
    col = color(r, g, b, alpha);
  }
  
  void display() {
    noFill();
    strokeWeight(25); // Thicker for curtain effect
    beginShape();
    for (int i = 0; i < trailLength; i++) {
      float alpha = alpha(col) * (1.0 - i / float(trailLength)) * 0.9; // Stronger fade
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
