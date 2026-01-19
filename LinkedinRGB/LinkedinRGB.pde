int counter = 0;
int timer = 0;

int initial_circle_offset = 25;
int circle_offset = initial_circle_offset;

int center_x = 400;
int center_y = 400;
int diameter = 400;
int radius = diameter / 2;

float primitive_angle = PI / 15;
float start_time;

int triangle = 0;
int lagged_triangle = 0;

int circle_index = 2;   // 1, 2, or 3

void setup() {
  size(800, 800);
  smooth(8);
  start_time = millis();
  background(18);
}

void draw() {

  /* ===========================
     Soft fade
     =========================== */
  noStroke();
  fill(18, 30);
  rect(0, 0, width, height);

  /* ===========================
     Base reference circle
     =========================== */
  float basePulse = 40 + 20 * sin(millis() * 0.002);
  noFill();
  stroke(255, basePulse);
  strokeWeight(1);
  ellipse(center_x, center_y, diameter, diameter);

  /* ===========================
     Timing + interpolation
     =========================== */
  float interp = constrain(
    (millis() - (timer * 800 + start_time)) / 800.0,
    0, 1
  );

  float eased = easeInOutCubic(interp);
  float smoothCounter = counter + eased;

  float length_offset = radius + circle_offset;
  float flag_height = diameter + 2 * circle_offset;
  float arcRadius = flag_height * 0.5;

  float flag_x =
    center_x + length_offset * sin(primitive_angle * smoothCounter);

  float flag_y =
    center_y - length_offset * cos(primitive_angle * smoothCounter);

  strokeWeight(2.5);
  noFill();

  float startAngle = 0;
  float endAngle   = 0;

  /* ===========================
     MODE 1 — Incremental arm
     =========================== */
  if (circle_index == 1) {
    stroke(255, 180, 0, 220);

    line(center_x, center_y, flag_x, flag_y);

    startAngle = smoothCounter * primitive_angle - HALF_PI;
    endAngle   = (smoothCounter + 1) * primitive_angle - HALF_PI;

    arc(center_x, center_y,
        flag_height, flag_height,
        startAngle, endAngle);
  }

  /* ===========================
     MODE 2 — Fixed vertical arm
     =========================== */
  if (circle_index == 2) {
    stroke(200, 120, 255, 220);

    line(center_x, center_y,
         center_x,
         center_y - length_offset);

    startAngle = -HALF_PI;
    endAngle   = (smoothCounter + 1) * primitive_angle - HALF_PI;

    arc(center_x, center_y,
        flag_height, flag_height,
        startAngle, endAngle);
  }

  /* ===========================
     MODE 3 — Triangular sequence
     =========================== */
  if (circle_index == 3) {
    stroke(100, 255, 160, 220);

    triangle = (counter + 1) * (counter + 2) / 2;
    lagged_triangle = counter * (counter + 1) / 2;

    float triStart = lagged_triangle + eased;
    float triEnd   = triangle + eased;

    startAngle = triStart * primitive_angle - HALF_PI;
    endAngle   = triEnd   * primitive_angle - HALF_PI;

    float long_flag_x =
      center_x + length_offset * sin(primitive_angle * triStart);

    float long_flag_y =
      center_y - length_offset * cos(primitive_angle * triStart);

    line(center_x, center_y, long_flag_x, long_flag_y);

    arc(center_x, center_y,
        flag_height, flag_height,
        startAngle, endAngle);
  }

  /* ===========================
     Growing arrow along arc
     =========================== */
  // Arrow at the *current end* of the arc
  float arrowAngle = endAngle; // current tip of the arc
  float ax = center_x + arcRadius * cos(arrowAngle);
  float ay = center_y + arcRadius * sin(arrowAngle);
  drawArrowHead(ax, ay, arrowAngle + HALF_PI, 12);

  /* ===========================
     Original timing logic
     =========================== */
  if (millis() > timer * 800 + start_time) {
    counter = (counter + 1) % 20;
    timer++;
    circle_offset += initial_circle_offset;
  }

  if (counter == 5) {
    resetSketch();
  }
}

/* ===========================
   Helpers
   =========================== */

void drawArrowHead(float x, float y, float angle, float size) {
  pushMatrix();
  translate(x, y);
  rotate(angle);
  line(0, 0, -size,  size * 0.5);
  line(0, 0, -size, -size * 0.5);
  popMatrix();
}

void resetSketch() {
  counter = 0;
  timer = 0;
  circle_offset = initial_circle_offset;
  start_time = millis();
  background(18);
}

float easeInOutCubic(float x) {
  return x < 0.5
    ? 4 * x * x * x
    : 1 - pow(-2 * x + 2, 3) / 2;
}
