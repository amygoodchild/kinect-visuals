/*****

Receives skeleton data from a Kinect over OSC.
Draws weird bodies by joining up skeleton joints "wrong"
 
Requires "SendSkeleton" sketch to be running. 

Numbering of joints is as per Kinect SDK spec
Clicking the mouse cycles through the different weird bodies.

Amy Goodchild Jan 2018
https://twitter.com/amygoodchild

*****/

// Osc libraries
import oscP5.*;
import netP5.*;

// Set up OSC connection
OscP5 oscP5SkeletonReceiver;
NetAddress dest;

// Arrays to hold raw joint data and mapped joint data
// cols are x and y, rows are all the joints 
// i.e...
// [0][0] is Spine Base X; [0][1] is Spine Base Y
// [1][0] is Spine Mid X; [1][1] is Spine Mid Y and so on

float[][] jointArray;
float[][] jointArrayMapped;
float[][] jointArrayLerped;

float lerpPercent = .5;
float hue;
int weight = 2;
int bodyShape; 
int numberOfBodies = 6;

void setup(){
  size(1024,768);
  //fullScreen();
  colorMode(HSB,360);
  noStroke();
  
  // Initialise OSC connection
  oscP5SkeletonReceiver = new OscP5(this,6449);
  dest = new NetAddress("127.0.0.1",6448);
  
  // Initialise arrays of joint data
  jointArray = new float[25][2];
  jointArrayMapped = new float[25][2];
  jointArrayLerped = new float[25][2];
  
}

void draw(){
  // Lowering the opacity here gives a cool fadey effect
  fill(0,0,30);
  noStroke();
  rect(0,0,width,height);
 
  strokeWeight(2);
 
  // Uncomment this if you want to see a small "reference" skeleton in the top left.
  // Useful for posting to social media and demonstrating what's happening
  // drawRefBody();
  
  // Draws fun weird bodies, joining up skeleton joints "wrong"
  stroke(hue, 360,360);
  drawGeometricBody();
  
}

void drawGeometricBody(){
  if (bodyShape == 0){
    drawBodyLine(8, 14);
    drawBodyLine(4, 18);
  }
  if (bodyShape == 1){
    drawBodyLine(8, 18);
    drawBodyLine(3, 18);
    drawBodyLine(11, 18); 
    drawBodyLine(4, 14);
    drawBodyLine(3, 14);
    drawBodyLine(7, 14); 
  }
  if (bodyShape == 2){
    drawBodyLine(4, 18);
    drawBodyLine(7,18);
    drawBodyLine(8,14);
    drawBodyLine(11,14); 
  }
  if (bodyShape == 3){
    drawBodyLine(7,12);
    drawBodyLine(18,12);
    drawBodyLine(11,16);
    drawBodyLine(14,16);  
  }  
  if (bodyShape == 4){
    drawBodyLine(3, 11);
    drawBodyLine(3, 7);
    drawBodyLine(18, 16);
    drawBodyLine(14, 16);
    drawBodyLine(18, 12);
    drawBodyLine(14, 12);
  }   
  if (bodyShape == 5){
    drawBodyLine(3, 11);
    drawBodyLine(3, 7);
    drawBodyLine(3, 8);
    drawBodyLine(3, 4);
    drawBodyLine(3, 20);
  }   
  if (bodyShape == 6){
    drawBodyLine(3, 11);
    drawBodyLine(3, 7);
    drawBodyLine(18, 11);
    drawBodyLine(18, 7);
    drawBodyLine(14, 11);
    drawBodyLine(14, 7);
  }    
}


void drawRefBody(){
  fill(0,0,50);
  noStroke();
  rect(70,120,100,110);
  
  for (int i = 0; i < 25; i++) {
    fill(0,0,255);
    float x = map(jointArray[i][0],-1.7,1.7, 60, 180);
    float y = map(jointArray[i][1],-1.2,1.2, 210, 130);    
    ellipse(x,y,3,3);
  }
}




void drawBodyLine(int joint1, int joint2){
  strokeWeight(weight);
  line(jointArrayLerped[joint1][0], jointArrayLerped[joint1][1], jointArrayLerped[joint2][0], jointArrayLerped[joint2][1]);
}





void oscEvent(OscMessage theOscMessage) {
  
  // if the address is joints, we know we're looking at the joint data from the other processing sketch
  if (theOscMessage.checkAddrPattern("/joints") == true) {
    
   
    for (int i = 0; i < 25; i++) {                               // Go through each joint
        jointArray[i][0] = theOscMessage.get(i).floatValue();    // Populate that joint's x with the appropriate value from the osc message
        jointArray[i][1] = theOscMessage.get(i+25).floatValue(); // populate that point's y with the appropriate value from the osc message
                                                                 // +25 is because values 0-24 are all the x's, 25-48 are the y's.
    }
      
    for (int i = 0; i < 25; i++) {            // Go through each joint and map the raw X and Y values to something sensible
      jointArrayMapped[i][0] = map(jointArray[i][0],-1.7,1.7,0,width);
      jointArrayMapped[i][1] = map(jointArray[i][1],-1.2,1.2,height-150,-50);    
    }
    
    for (int i = 0; i < 25; i++) {            // Go through each joint and map the raw X and Y values to something sensible
      jointArrayLerped[i][0] = lerp(jointArrayLerped[i][0], jointArrayMapped[i][0], lerpPercent);
      jointArrayLerped[i][1] = lerp(jointArrayLerped[i][1], jointArrayMapped[i][1], lerpPercent); 
    }
    
    // For debugging, print out some values
    // but not every frame or it's impossible to read
    // Especially when half way across the room waving at a kinect
    if (frameCount % 30 == 0){
      // println("righthandx_: " + jointArray[11][0]);
      // println("righthandxm: " + jointArrayMapped[11][0]);
      // println("righthandy_: " + jointArray[11][1]);
      // println("righthandym: " + jointArrayMapped[11][1]);
    }
  }
}

// Cycles through different weird bodies when the mouse is clicked
void mousePressed(){
  bodyShape++;
  
  if (bodyShape > numberOfBodies){
    bodyShape = 0;
  }
  println(bodyShape);
  hue = random(0,255);

}