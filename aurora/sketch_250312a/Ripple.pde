// Ripple class
class Ripple {
  float x, y, radius, alpha;
  
  Ripple(float x, float y) {
    this.x = x;
    this.y = y;
    this.radius = 0;
    this.alpha = 255;
  }
  
  void update() {
    radius += 2;
    alpha -= 5;
  }
  
  void display() {
    noFill();
    stroke(0, 255, 255, alpha);
    strokeWeight(2);
    ellipse(x, y, radius * 2, radius * 2);
  }
  
  boolean isFinished() {
    return alpha <= 0;
  }
}
