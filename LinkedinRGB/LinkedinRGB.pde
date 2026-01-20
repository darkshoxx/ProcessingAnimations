// =======================
// Global timing / state
// =======================
int counter = 0;
int maxSteps = 5;
float stepDuration = 800; // ms per step
float startTime;
int initial_circle_offset = 25;
int circle_offset = initial_circle_offset;

// =======================
// Geometry constants
// =======================
float primitive_angle = PI / 15;

// =======================
// Text layer
// =======================
PGraphics textLayer;

// =======================
// Setup
// =======================
void setup() {
  size(800, 600); // trimmed width
  smooth(8);
  background(18);
  startTime = millis();

  textLayer = createGraphics(width, height);
}

// =======================
// Draw loop
// =======================
void draw() {

  // subtle fade for trails
  noStroke();
  fill(18, 12);
  rect(0, 0, width, height);

  // timing
  float elapsed = millis() - startTime;
  counter = int(elapsed / stepDuration);
  float interp = (elapsed % stepDuration) / stepDuration;
  float eased = easeInOutCubic(constrain(interp, 0, 1));

  // reset
  if (counter >= maxSteps) {
    counter = 0;
    startTime = millis();
    circle_offset = initial_circle_offset;
    return;
  }

  float scaleFactor = 0.5;

  // clear text layer
  textLayer.beginDraw();
  textLayer.clear();
  textLayer.endDraw();

  // =======================
  // LEFT: circle 1 (top)
  // =======================
  float tx1 = width * 0.2;
  float ty1 = height * 0.28;
  pushMatrix();
  translate(tx1, ty1);
  scale(scaleFactor);
  drawCircleMode(1, counter, eased, tx1, ty1, scaleFactor);
  popMatrix();

  // LEFT: circle 2 (bottom)
  float tx2 = width * 0.2;
  float ty2 = height * 0.72;
  pushMatrix();
  translate(tx2, ty2);
  scale(scaleFactor);
  drawCircleMode(2, counter, eased, tx2, ty2, scaleFactor);
  popMatrix();

  // RIGHT: circle 3
  float tx3 = width * 0.75;
  float ty3 = height * 0.5;
  pushMatrix();
  translate(tx3, ty3);
  scale(scaleFactor);
  drawCircleMode(3, counter, eased, tx3, ty3, scaleFactor);
  popMatrix();

  // =======================
  // Combination arrows (DRAWN ONCE)
  // =======================
  // Pull arrows away from circle centers using linear interpolation
  float trim = 0.3; // how much of the segment to trim on each side
  
  // top → right
  float sx1 = lerp(tx1, tx3, trim);
  float sy1 = lerp(ty1, ty3, trim);
  float ex1 = lerp(tx1, tx3, 1 - trim);
  float ey1 = lerp(ty1, ty3, 1 - trim);
  drawConnectionArrow(sx1, sy1, ex1, ey1);
  
  // bottom → right
  float sx2 = lerp(tx2, tx3, trim);
  float sy2 = lerp(ty2, ty3, trim);
  float ex2 = lerp(tx2, tx3, 1 - trim);
  float ey2 = lerp(ty2, ty3, 1 - trim);
  drawConnectionArrow(sx2, sy2, ex2, ey2);

  // =======================
  // Draw labels last
  // =======================
  image(textLayer, 0, 0);
}

// =======================
// Circle drawing logic
// =======================
void drawCircleMode(int circle_index, int step, float eased,
                    float tx, float ty, float scaleFactor) {

  int diameter = 400;
  int radius = diameter / 2;
  float length_offset = radius + circle_offset;
  float flag_height = diameter + 2 * circle_offset;
  float arcRadius = flag_height / 2;

  float startAngle = 0;
  float endAngle = 0;

  // hinted base circle
  float basePulse = 40 + 20 * sin(millis() * 0.002);
  stroke(255, basePulse);
  noFill();
  ellipse(0, 0, diameter, diameter);

  strokeWeight(2);

  // =======================
  // Modes
  // =======================
  if (circle_index == 1) {
    stroke(255, 180, 0, 220);
    startAngle = step * primitive_angle - HALF_PI;
    endAngle   = (step + eased) * primitive_angle - HALF_PI;

    float fx = length_offset * sin(step * primitive_angle);
    float fy = -length_offset * cos(step * primitive_angle);

    line(0, 0, fx, fy);
    arc(0, 0, flag_height, flag_height, startAngle, endAngle);
  }

  if (circle_index == 2) {
    stroke(170, 80, 220, 220);
    startAngle = -HALF_PI;
    endAngle   = (step + eased) * primitive_angle - HALF_PI;

    line(0, 0, 0, -length_offset);
    arc(0, 0, flag_height, flag_height, startAngle, endAngle);
  }

  if (circle_index == 3) {
    stroke(100, 255, 160, 220);

    int triEnd = (step + 1) * (step + 2) / 2;
    int triStart = step * (step + 1) / 2;
    float smoothTri = triStart + (triEnd - triStart) * eased;

    startAngle = triStart * primitive_angle - HALF_PI;
    endAngle   = smoothTri * primitive_angle - HALF_PI;

    float fx = length_offset * sin(triStart * primitive_angle);
    float fy = -length_offset * cos(triStart * primitive_angle);

    line(0, 0, fx, fy);
    arc(0, 0, flag_height, flag_height, startAngle, endAngle);
  }

  // =======================
  // Arrow
  // =======================
  float arrowAngle = endAngle;
  float ax = arcRadius * cos(arrowAngle);
  float ay = arcRadius * sin(arrowAngle);
  drawArrowHead(ax, ay, arrowAngle + HALF_PI, 12);

  // =======================
  // Label (stable, no fade)
  // =======================
  int labelValue = 1;
  if (circle_index == 2) labelValue = step;
  if (circle_index == 3) labelValue = (step + 1) * (step + 2) / 2;

  float canvasX = tx + ax * scaleFactor;
  float canvasY = ty + ay * scaleFactor;

  textLayer.beginDraw();
  textLayer.noStroke();
  textLayer.fill(18, 15); 
  textLayer.rect(0, 0, width, height); // fade numbers gradually
  // then draw the new numbers
  textLayer.fill(getModeColor(circle_index));
  textLayer.textAlign(CENTER, CENTER);
  textLayer.textSize(40);
  textLayer.text(labelValue,
    canvasX + 30 * cos(arrowAngle),
    canvasY + 30 * sin(arrowAngle));
  textLayer.endDraw();
}

// =======================
// Connection arrows
// =======================
void drawConnectionArrow(float x1, float y1, float x2, float y2) {
  stroke(180, 120);
  strokeWeight(1.5);
  line(x1, y1, x2, y2);

  float angle = atan2(y2 - y1, x2 - x1);
  float size = 10;

  pushMatrix();
  translate(x2, y2);
  rotate(angle);
  line(0, 0, -size,  size * 0.5);
  line(0, 0, -size, -size * 0.5);
  popMatrix();
}

// =======================
// Arrowhead helper
// =======================
void drawArrowHead(float x, float y, float angle, float size) {
  pushMatrix();
  translate(x, y);
  rotate(angle);
  line(0, 0, -size,  size * 0.5);
  line(0, 0, -size, -size * 0.5);
  popMatrix();
}

// =======================
// Easing
// =======================
float easeInOutCubic(float x) {
  return x < 0.5
    ? 4 * x * x * x
    : 1 - pow(-2 * x + 2, 3) / 2;
}

// =======================
// Color helper
// =======================
color getModeColor(int mode) {
  if (mode == 1) return color(255, 180, 0, 220);
  if (mode == 2) return color(170, 80, 220, 220);
  if (mode == 3) return color(100, 255, 160, 220);
  return color(255);
}
