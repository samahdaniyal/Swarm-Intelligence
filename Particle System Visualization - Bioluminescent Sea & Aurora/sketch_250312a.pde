import controlP5.*;
ControlP5 cp5;

ArrayList<SeaParticle> seaParticles;
ArrayList<AuroraParticle> auroraParticles;
float auroraSpeed = 0.1, seaBrightness = 50, planktonDensity = 500;
float cohesion = 0.5, separation = 0.5, alignment = 0.5;
float windInfluence = 0.5, tideInfluence = 0.5, solarActivity = 0.5;
float waveHeight = 0;
float waveSpeed = 0.02;
float foodFeedbackTimer = 0;
float disturbanceRadius = 50;
PVector lastMouse;
PVector target;
boolean foodActive = false;
boolean isPaused = false;

int gridSize = 25;
HashMap<Integer, ArrayList<SeaParticle>> grid;
ArrayList<SeaParticle> newParticles;
boolean predatorMode = false;
Predator predator;

// PSO global best
PVector GBest; // Global best position
float globalBestFitness = 0; // Global best fitness

void setup() {
  frameRate(50);
  size(1200, 800);
  seaParticles = new ArrayList<SeaParticle>();
  auroraParticles = new ArrayList<AuroraParticle>();
  grid = new HashMap<Integer, ArrayList<SeaParticle>>();
  newParticles = new ArrayList<SeaParticle>();
  GBest = new PVector(width/2, height * 3/4); // Initial guess for GBest
  
  cp5 = new ControlP5(this);
  int sliderX = 20;
  cp5.addSlider("auroraSpeed").setPosition(sliderX, 20).setSize(200, 20).setRange(0.1, 3).setValue(0.1);
  cp5.addSlider("seaBrightness").setPosition(sliderX, 50).setSize(200, 20).setRange(50, 255).setValue(50);
  cp5.addSlider("planktonDensity").setPosition(sliderX, 80).setSize(200, 20).setRange(500, 2000).setValue(500);
  cp5.addSlider("cohesion").setPosition(sliderX, 110).setSize(200, 20).setRange(0, 2).setValue(0.5);
  cp5.addSlider("separation").setPosition(sliderX, 140).setSize(200, 20).setRange(0, 2).setValue(0.5);
  cp5.addSlider("alignment").setPosition(sliderX, 170).setSize(200, 20).setRange(0, 2).setValue(0.5);
  cp5.addSlider("windInfluence").setPosition(sliderX, 200).setSize(200, 20).setRange(0.5, 2.5).setValue(0.5);
  cp5.addSlider("tideInfluence").setPosition(sliderX, 230).setSize(200, 20).setRange(0.5, 2.5).setValue(0.5);
  cp5.addSlider("solarActivity").setPosition(sliderX, 260).setSize(200, 20).setRange(0.5, 5.0).setValue(0.5);
  
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
  for (int i = 0; i < 1000; i++) {
    float x = random(width);
    float y = random(0, height/2.25);
    auroraParticles.add(new AuroraParticle(x, y));
  }
  lastMouse = new PVector();
  target = new PVector(width/2, height * 3/4);
  predator = new Predator();
  GBest.set(target); // Initialize GBest to target position
  globalBestFitness = 1.0 / (dist(GBest.x, GBest.y, target.x, target.y) + 0.1); // Initial fitness
}

void drawWaves() {
  if (isPaused) return;
  noFill();
  stroke(0, 100, 200, 50);
  strokeWeight(2);
  for (int y = height/2; y < height; y += 10) {
    beginShape();
    for (int x = 0; x < width; x += 10) {
      float waveOffset = sin(x * 0.01 + waveHeight) * 10 * tideInfluence;
      vertex(x, y + waveOffset);
      if (abs(waveOffset) > 8 && random(1) < 0.1) {
        int gridX = floor(x / gridSize);
        int gridY = floor((y + waveOffset) / gridSize);
        int key = gridX + gridY * floor(width / gridSize);
        if (grid.containsKey(key)) {
          for (SeaParticle p : grid.get(key)) {
            if (dist(x, y + waveOffset, p.pos.x, p.pos.y) < disturbanceRadius) {
              p.brighten();
              p.disturb();
            }
          }
        }
      }
    }
    endShape();
  }
  waveHeight += waveSpeed;
}

void generateParticles() {
  float m_p = planktonDensity / 100;
  float sigma_p = m_p * 0.2;
  int N = max(0, (int)(m_p + randomGaussian() * sigma_p));
  for (int i = 0; i < N; i++) {
    float x = random(width);
    float y = height/2 + randomGaussian() * (height/4);
    seaParticles.add(new SeaParticle(x, constrain(y, height/2, height)));
  }
}

void generateAuroraParticles() {
  float m_p = 1000 / 100.0; 
  float sigma_p = m_p * 0.2; // 20% variance
  int N = max(0, (int)(m_p + randomGaussian() * sigma_p));
  for (int i = 0; i < N; i++) {
    float x = random(width);
    float y = random(0, height/2.25); 
    auroraParticles.add(new AuroraParticle(x, y));
  }
}

void resetSliders() {
  cp5.getController("auroraSpeed").setValue(0.1);
  cp5.getController("seaBrightness").setValue(50);
  cp5.getController("planktonDensity").setValue(500);
  cp5.getController("cohesion").setValue(0);
  cp5.getController("separation").setValue(0);
  cp5.getController("alignment").setValue(0);
  cp5.getController("windInfluence").setValue(0.5);
  cp5.getController("tideInfluence").setValue(0.5);
  cp5.getController("solarActivity").setValue(0.5);
}

void drawBackground() {
  background(10, 20, 50);
  blendMode(ADD);
  for (int i = 0; i < 100; i++) {
    fill(255, random(50, 255));
    ellipse(random(width), random(height/2), 2, 2);
  }
}

void updateParticles() {
  // Aurora particles
  if (!isPaused) {
    generateAuroraParticles();
    for (AuroraParticle p : auroraParticles) {
      p.update();
      p.display();
    }
    auroraParticles.removeIf(p -> p.lifetime <= 0);
  } else {
    for (AuroraParticle p : auroraParticles) {
      p.display();
    }
  }

  // Sea particles
  if (!isPaused) {
    generateParticles();
    updateGrid();
    // Update GBest
    for (SeaParticle p : seaParticles) {
      p.update();
      p.display();
      float fitness = 1.0 / (dist(p.pos.x, p.pos.y, target.x, target.y) + 0.1);
      if (fitness > p.pBestFitness) {
        p.pBestFitness = fitness;
        p.pBestPos.set(p.pos);
      }
      if (fitness > globalBestFitness) {
        globalBestFitness = fitness;
        GBest.set(p.pos);
      }
    }
    seaParticles.removeIf(p -> p.lifetime <= 0);
    drawWaves();

    // Food source logic
    if (foodActive) {
      fill(255, 215, 0, 150);
      ellipse(target.x, target.y, 20, 20);
      if (foodFeedbackTimer > 0) {
        noFill();
        stroke(255, 215, 0, map(foodFeedbackTimer, 0, 1, 0, 255));
        strokeWeight(3);
        ellipse(target.x, target.y, 40, 40);
        noStroke();
        foodFeedbackTimer -= 0.05;
      }
    }
  } else {
    for (SeaParticle p : seaParticles) {
      p.display();
    }
    if (foodActive) {
      fill(255, 215, 0, 150);
      ellipse(target.x, target.y, 20, 20);
    }
  }

  // Predator logic
  if (predatorMode) {
    if (!isPaused) predator.update();
    predator.display();
  }
}

void drawUI() {
  blendMode(BLEND);
  fill(0, 100);
  cp5.draw();
  fill(255);
  textSize(12);
  textAlign(RIGHT);
  text("Predator Mode: " + (predatorMode ? "On" : "Off"), width - 20, 40);
  text("Food Source: " + (foodActive ? "On" : "Off"), width - 20, 60);
  text("Paused: " + (isPaused ? "Yes" : "No"), width - 20, 80);
}

void draw() {
  drawBackground();
  updateParticles();
  drawUI();
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
    float effectiveRadius = predatorMode ? disturbanceRadius * 2 : disturbanceRadius;
    for (SeaParticle p : seaParticles) {
      float d = dist(mouseX, mouseY, p.pos.x, p.pos.y);
      if (d < effectiveRadius) {
        PVector scatter = PVector.sub(p.pos, new PVector(mouseX, mouseY)).normalize().mult(2);
        p.vel.add(scatter);
        p.brighten();
        p.disturb();
      }
    }
  }
}

void mouseDragged() {
  if (mouseY > height/2) {
    PVector current = new PVector(mouseX, mouseY);
    PVector force = PVector.sub(current, lastMouse).normalize().mult(2);
    float effectiveRadius = predatorMode ? disturbanceRadius * 2 : disturbanceRadius;
    for (SeaParticle p : seaParticles) {
      float d = dist(mouseX, mouseY, p.pos.x, p.pos.y);
      if (d < effectiveRadius) {
        PVector scatter = PVector.sub(p.pos, new PVector(mouseX, mouseY)).normalize().mult(1.5);
        p.vel.add(force);
        p.vel.add(scatter);
        p.brighten();
        p.disturb();
      }
    }
  }
  lastMouse.set(mouseX, mouseY);
}

void keyPressed() {
  if (key == 'P' || key == 'p') predatorMode = !predatorMode;
  if (key == 'F' || key == 'f') {
    foodActive = !foodActive;
    if (foodActive) {
      target.set(mouseX, mouseY);
      foodFeedbackTimer = 1.0;
      GBest.set(target); // Reset GBest to new target
      globalBestFitness = 1.0 / (dist(GBest.x, GBest.y, target.x, target.y) + 0.1);
    }
  }
  if (key == ' ') isPaused = !isPaused;
  if (key == 'R' || key == 'r') {
    initializeParticles();
    resetSliders();
  }
}
