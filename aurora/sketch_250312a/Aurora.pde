//class AuroraParticle {
//  PVector pos, vel;
//  color col;
//  PVector[] trail;
//  int trailLength = 5;
  
//  AuroraParticle(float x, float y) {
//    pos = new PVector(x, y);
//    vel = new PVector(noise(x * 0.01, frameCount * 0.01) * 0.5, 0.5);
//    trail = new PVector[trailLength];
//    for (int i = 0; i < trailLength; i++) {
//      trail[i] = pos.copy();
//    }
//    updateColor();
//  }
  
//  void update() {
//    int index = floor(pos.x / 10) + floor(pos.y / 10) * (width / 10);
//    if (index >= 0 && index < flowField.length) {
//      PVector flow = flowField[index].copy().mult(auroraSpeed);
//      vel.add(flow);
//    }
    
//    PVector alignmentVec = new PVector();
//    int nearby = 0;
//    for (AuroraParticle other : auroraParticles) {
//      float d = dist(pos.x, pos.y, other.pos.x, other.pos.y);
//      if (d > 0 && d < 50) {
//        alignmentVec.add(other.vel);
//        nearby++;
//      }
//    }
//    if (nearby > 0) {
//      alignmentVec.div(nearby).normalize().mult(0.1);
//      vel.add(alignmentVec);
//    }
    
//    vel.limit(2);
//    pos.add(vel);
    
//    for (int i = trailLength - 1; i > 0; i--) {
//      trail[i] = trail[i - 1].copy();
//    }
//    trail[0] = pos.copy();
    
//    // Wrap horizontally
//    if (pos.x < 0) pos.x = width;
//    if (pos.x > width) pos.x = 0;
    
//    // Keep in upper half (aurora region)
//    if (pos.y > height/2) {
//      pos.y = 0; // Reset to top
//      vel.set(noise(pos.x * 0.01, frameCount * 0.01) * 0.5, random(-0.5, 0.5)); // Randomize y-velocity
//    } else if (pos.y < 0) {
//      pos.y = height/2; // Reset to bottom of aurora region
//      vel.set(noise(pos.x * 0.01, frameCount * 0.01) * 0.5, random(-0.5, 0.5)); // Randomize y-velocity
//    }
    
//    updateColor();
//  }
  
//  void updateColor() {
//    float r = 50, g = 255, b = 100;
//    if (random(1) < 0.2) {
//      r = random(100, 150);
//      g = random(50, 100);
//      b = random(200, 255);
//    }
//    float alpha = map(seaBrightness, 50, 255, 50, 150);
//    col = color(r, g, b, alpha);
//  }
  
//  void display() {
//    display(1.0);
//  }
  
//  void display(float fade) {
//    noStroke();
//    for (int i = 0; i < trailLength; i++) {
//      float trailAlpha = alpha(col) * (1.0 - i / float(trailLength)) * 0.5 * fade;
//      fill(red(col), green(col), blue(col), trailAlpha);
//      rect(trail[i].x - 5, trail[i].y, 10, 20 + i * 2);
//    }
//    fill(col, alpha(col) * fade);
//    rect(pos.x - 5, pos.y, 10, 20);
//  }
//}
