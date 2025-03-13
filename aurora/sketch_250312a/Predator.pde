//// Predator class for repulsion behavior
//class Predator {
//  PVector pos, vel;
  
//  Predator() {
//    pos = new PVector(width/2, height * 3/4);
//    vel = PVector.random2D().mult(2);
//  }
  
//  void update() {
//    pos.add(vel);
//    if (pos.x < 0 || pos.x > width) vel.x *= -1;
//    if (pos.y < height/2 || pos.y > height) vel.y *= -1;
//  }
  
//  void display() {
//    fill(255, 0, 0);
//    ellipse(pos.x, pos.y, 20, 20);
//  }
//}
