import processing.serial.*;
import peasy.*;

PeasyCam cam;

final float SIZE_MM = 1;
final float SIZE_CM = 10 * SIZE_MM;
final float SIZE_M = 1000 * SIZE_MM;

// 5 centimeter grid, extends in 3 meters in each direction
final float gridSpacing = 5 * SIZE_CM;
final float gridRange = 3 * SIZE_M;    

final float BOT_WIDTH = 15 * SIZE_CM;
final float BOT_LENGTH = 30 * SIZE_CM;
final float BOT_HEIGHT = 15 * SIZE_CM;

final color GENERIC_HIGHLIGHT_COLOR = #2EC664;
final color GENERIC_ALTERNATE_HIGHLIGHT_COLOR = #F6FA23;
final color GENERIC_FILL_COLOR = #000000;
final color GENERIC_BACKGROUND_OBJECT_COLOR = #202020;

float oriX = 0;
float oriY = 0;
float oriZ = 0;

int frontLidar = 10;
int backLidar = 20;
int leftLidar = 30;
int rightLidar = 40;

boolean isOrtho = false;

Serial serial;

void setup() {
  fullScreen(P3D);
  
  cam = new PeasyCam(this, 500); 
  cam.lookAt(0, 0, 0);                                       // center camera on grid origin
  cam.setRotations(radians(-90), radians(0), radians(0));    // look straight down
  
  serial = new Serial(this, Serial.list()[0], 115200);
  
}

void draw() {

  background(0);
  lights();
  
  if(isOrtho){
    float w = width / 2;
    float h = height / 2;
    ortho(-w, w, -h, h, 0, 100000);
  }
  else{
    perspective(PI / 3.0, (float)width / (float)height, 0.1, 100000);
  }  
  
  getDataFromSerial();
  drawGrid();
  drawRobot();

}

void drawGrid(){
 
  stroke(GENERIC_BACKGROUND_OBJECT_COLOR);
  strokeWeight(1);
  
  for(float x = -gridRange; x <= gridRange; x += gridSpacing){
    line(x, 0, -gridRange, x, 0, gridRange);
  }
  for(float z = -gridRange; z <= gridRange; z += gridSpacing){
    line(-gridRange, 0, z, gridRange, 0, z);
  }  
  
}

void keyPressed(){
 
  if(key == 'o' || key == 'O'){
    isOrtho = !isOrtho; 
  }
  
  if(key == 'c' || key == 'c'){
    cam.lookAt(0, 0, 0);                                       // center camera on grid origin
    cam.setRotations(radians(-90), radians(0), radians(0));    // look straight down
  }
  
}

void drawRobot() {
  
  final float LINE_LENGTH = 30 * SIZE_CM;
  final float LIDAR_BOX_LENGTH = 1 * SIZE_CM;
  final float LIDAR_BOX_WIDTH = 10 * SIZE_CM;
  final float LIDAR_BOX_HEIGHT = 10 * SIZE_CM;
  
  pushMatrix();
  stroke(GENERIC_ALTERNATE_HIGHLIGHT_COLOR);
  strokeWeight(5);
  fill(GENERIC_FILL_COLOR);
  
  translate(0, BOT_HEIGHT / 2, 0);
  rotateX(radians(oriX));
  rotateY(radians(oriY));
  rotateZ(radians(oriZ));
  
  box(BOT_WIDTH, BOT_HEIGHT, BOT_LENGTH);
  
  stroke(255, 255, 0);
  strokeWeight(3);
  line(0, 0, -BOT_LENGTH / 2, 0, 0, -BOT_LENGTH / 2 - LINE_LENGTH);
    
  pushMatrix();
  translate(0, 0, -BOT_LENGTH / 2 - LIDAR_BOX_LENGTH / 2 - frontLidar * SIZE_CM);
  fill(GENERIC_FILL_COLOR);
  box(LIDAR_BOX_WIDTH, LIDAR_BOX_HEIGHT, LIDAR_BOX_LENGTH);
  popMatrix();
  
  pushMatrix();
  translate(0, 0, BOT_LENGTH / 2 + LIDAR_BOX_LENGTH / 2 + backLidar * SIZE_CM);
  fill(GENERIC_FILL_COLOR);
  box(LIDAR_BOX_WIDTH, LIDAR_BOX_HEIGHT, LIDAR_BOX_LENGTH);
  popMatrix();
  
  pushMatrix();
  translate(-BOT_WIDTH / 2 - LIDAR_BOX_WIDTH / 2 - leftLidar * SIZE_CM, 0, 0);
  fill(GENERIC_FILL_COLOR);
  box(LIDAR_BOX_LENGTH, LIDAR_BOX_HEIGHT, LIDAR_BOX_WIDTH);
  popMatrix();
  
  pushMatrix();
  translate(BOT_WIDTH / 2 + LIDAR_BOX_WIDTH / 2 + rightLidar * SIZE_CM, 0, 0);
  fill(GENERIC_FILL_COLOR);
  box(LIDAR_BOX_LENGTH, LIDAR_BOX_HEIGHT, LIDAR_BOX_WIDTH);
  popMatrix();
  
  popMatrix();
  
}

void getDataFromSerial(){
 
  String data = serial.readString();
  
  if(data != null){
    String dataArray[] = data.split(",");
  
    if(dataArray.length >= 4){
      oriY = float(dataArray[1]);
      oriX = -float(dataArray[2]);
      oriZ = float(dataArray[3]);
    }
    
  }
  
}
