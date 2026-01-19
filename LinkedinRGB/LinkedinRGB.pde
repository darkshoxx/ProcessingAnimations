int counter = 0;
int timer = 0;
int initial_circle_offset = 25;
int circle_offset = initial_circle_offset;
float flag_height = 0;
void setup() {
  background(128, 128, 128);
  fill(255, 255, 255);
  size(800, 800);
  stroke(0xFFAAAA00);
  circle(center_x, center_y, diameter);
  counter = 0;
  circle_offset = initial_circle_offset;
}
  float start_time = millis();
  int center_x = 400;
  int center_y = 400;
  int diameter = 400;
  int radius = diameter/2;
  float length_offset = radius + circle_offset;
  float primitive_angle = PI/15;
  float flag_x, flag_y, long_flag_x, long_flag_y;
  int triangle = 0;
  int lagged_triangle = 0;
  int circle_index = 3;
void draw() {
  // Circle for incremental addition
  length_offset = radius + circle_offset;
  flag_x = center_x + length_offset*sin(primitive_angle*counter);
  flag_y = center_y - length_offset*cos(primitive_angle*counter);
  flag_height = diameter + 2*circle_offset;
  noFill();
  if(circle_index == 1){
    line(center_x, center_y, flag_x, flag_y);
    arc(center_x, center_y, flag_height, flag_height, counter*primitive_angle - HALF_PI, (counter + 1)*primitive_angle - HALF_PI);
  } 
  if(circle_index == 2){
    stroke(0xFFAA22DD);
    line(center_x, center_y, center_x, center_y - length_offset);
    arc(center_x, center_y, flag_height, flag_height, 0 - HALF_PI, (counter + 1)*primitive_angle - HALF_PI);
    stroke(0xFFAAAA00);
  }
  if(circle_index == 3){
    stroke(0xFF44EE11);
    triangle = (counter+1)*(counter+1+1)/2;
    lagged_triangle = (counter-1+1)*(1+counter)/2;
    long_flag_x = center_x + length_offset*sin(primitive_angle*lagged_triangle);
    long_flag_y = center_y - length_offset*cos(primitive_angle*lagged_triangle);
    line(center_x, center_y, long_flag_x, long_flag_y);
    arc(center_x, center_y, flag_height, flag_height, lagged_triangle*primitive_angle - HALF_PI, triangle*primitive_angle - HALF_PI);
    
    stroke(0xFFAAAA00);
  }
  if (millis() > timer*800 + start_time){
    counter = (counter + 1) % 20;
    timer = timer + 1;
    circle_offset += initial_circle_offset;
    print(circle_offset);
  }
  if (counter == 5){
  setup();
  }
}
