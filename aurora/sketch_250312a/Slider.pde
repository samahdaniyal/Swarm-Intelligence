// Slider class with value display
class Slider {
  float x, y, w, h, minVal, maxVal, val;
  String label;
  
  Slider(float x, float y, float w, float h, float minVal, float maxVal, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.minVal = minVal;
    this.maxVal = maxVal;
    this.label = label;
    this.val = minVal;
  }
  
  void display() {
  fill(100);
  rect(x, y, w, h);
  float sliderX = map(val, minVal, maxVal, x, x + w);
  fill(200);
  rect(sliderX - 5, y - 5, 10, h + 10);
  fill(255);
  textSize(12);
  textAlign(LEFT, CENTER);
  text(label + ": " + nf(val, 1, 2), x + w + 10, y + h / 2); // Display value
}
  
  float getValue() {
    if (mousePressed && mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      val = map(mouseX, x, x + w, minVal, maxVal);
    }
    return val;
  }
}
