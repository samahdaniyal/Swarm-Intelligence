
//// SeaParticle class with bioluminescence refinements
//class SeaParticle {
//  PVector pos, vel;
//  float brightness;
//  boolean disturbed = false;
//  float disturbTimer = 0;
//  boolean isLure = false;
//  float size = 5;
//  color smokeColor = color(0, 200, 255);
  
//  SeaParticle(float x, float y) {
//    pos = new PVector(x, y);
//    vel = PVector.random2D().mult(0.5);
//    brightness = 50;
//    if (random(1) < 0.01) isLure = true;
//  }
  
//  void update() {
//    int gridX = floor(pos.x / gridSize);
//    int gridY = floor(pos.y / gridSize);
    
//    PVector cohesionVec = new PVector();
//    PVector separationVec = new PVector();
//    PVector alignmentVec = new PVector();
//    int nearby = 0;
    
//    for (int dx = -1; dx <= 1; dx++) {
//      for (int dy = -1; dy <= 1; dy++) {
//        int key = (gridX + dx) + (gridY + dy) * floor(width / gridSize);
//        if (grid.containsKey(key)) {
//          ArrayList<SeaParticle> cellParticles = grid.get(key);
//          for (SeaParticle other : cellParticles) {
//            if (other != this) {
//              float d = PVector.dist(pos, other.pos);
//              if (d < 50) {
//                cohesionVec.add(other.pos);
//                separationVec.add(PVector.sub(pos, other.pos).div(max(d, 0.1)));
//                alignmentVec.add(other.vel);
//                nearby++;
//                if (brightness > 150 && random(1) < 0.02) {
//                  other.vel.add(PVector.sub(pos, other.pos).normalize().mult(0.5));
//                }
//              }
//            }
//          }
//        }
//      }
//    }
    
//    if (nearby > 0) {
//      cohesionVec.div(nearby).sub(pos).normalize();
//      separationVec.div(nearby).normalize().mult(separation);
//      alignmentVec.div(nearby).normalize().mult(alignment);
//      if (disturbed) {
//        vel.add(cohesionVec.mult(cohesion * 2));
//      }
//      vel.add(separationVec).add(alignmentVec);
//    } else if (!disturbed) {
//      vel.add(PVector.random2D().mult(0.1));
//    }
    
//    if (disturbed) {
//      disturbTimer -= 0.1;
//      if (disturbTimer <= 0) disturbed = false;
//    }
    
//    vel.x += sin(frameCount * 0.01 + pos.y * 0.01) * 0.1;
//    vel.y += sin(frameCount * 0.02 + pos.x * 0.01) * tideInfluence * 0.1;
//    float waveOffset = sin(pos.x * 0.01 + waveHeight) * 10 * tideInfluence;
//    pos.y += waveOffset * 0.05;
    
//    if (isLure) {
//      brightness = seaBrightness * (0.8 + sin(frameCount * 0.05) * 0.2);
//    } else {
//      brightness *= 0.95;
//    }
//    seaGlowInfluence += brightness * 0.001;
    
//    vel.limit(2);
//    pos.add(vel);
    
//    if (pos.x < 0) pos.x = width;
//    if (pos.x > width) pos.x = 0;
//    if (pos.y < height/2) pos.y = height;
//    if (pos.y > height) pos.y = height/2;
//  }
  
//  void display() {
//    float pulse = brightness;
//    if (disturbed) pulse = seaBrightness;
//    float alpha = isNight ? pulse : pulse * 0.2;
//    noStroke();
//    if (size > 5) { // Smokescreen particles
//      fill(smokeColor, alpha);
//    } else if (random(1) < 0.005) { // Rare red glow (0.5% chance)
//      fill(255, 50, 50, alpha);
//    } else if (random(1) < 0.01) {
//      fill(255, 215, 0, alpha);
//    } else {
//      fill(0, 200, 255, alpha);
//    }
//    ellipse(pos.x, pos.y, size, size * 0.6); // Adjusted aspect ratio
//    for (int i = 1; i <= 3; i++) {
//      fill(0, 200, 255, alpha * 0.3 / i);
//      ellipse(pos.x, pos.y, size + i * 5, size * 0.6 + i * 3);
//    }
//  }
  
//  void brighten() {
//    brightness = seaBrightness;
//  }
  
//  void disturb() {
//    disturbed = true;
//    disturbTimer = 2.0;
//  }
  
//  void smokescreen() {
//    for (int i = 0; i < 10; i++) {
//      float x = pos.x + random(-20, 20);
//      float y = pos.y + random(-20, 20);
//      if (y > height/2 && y < height) {
//        SeaParticle spark = new SeaParticle(x, y);
//        spark.brightness = seaBrightness * 0.5;
//        spark.vel = PVector.random2D().mult(1.5);
//        spark.size = 7;
//        spark.smokeColor = color(255, 150, 0, spark.brightness);
//        newParticles.add(spark);
//      }
//    }
//  }
//}
