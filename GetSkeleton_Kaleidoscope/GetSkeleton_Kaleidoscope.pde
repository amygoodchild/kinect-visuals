/*****

Receives skeleton data from a Kinect over OSC.
Draws ongoing graphics based on that data.
Also some graphics based on beat detection.
Requires "SendSkeleton" sketch to be running. 

Some additional graphics created by keyboard control. 
'c' changes the colours
'b' does the boom effect (an expanding circle)
'r' changes the number of repetitions of the kaleidoscope
(These used to be controlled by gestures trained in Wekinator but I've reduced them to keyboard taps for ease of sharing)

Amy Goodchild Jan 2018

*****/


// Osc libraries
import oscP5.*;
import netP5.*;

// Sound library
import ddf.minim.*;
import ddf.minim.analysis.*;

// Sets up the sound library
Minim minim;
AudioInput song;
//AudioPlayer song;
BeatDetect beat;

// Set up different OSC connections for the various communications
OscP5 oscP5SkeletonReceiver;
NetAddress dest;

// Arrays to hold raw joint data and mapped joint data
// cols are x and y, rows are all the joints 
// i.e...
// [0][0] is Spine Base X; [0][1] is Spine Base Y
// [1][0] is Spine Mid X; [1][1] is Spine Mid Y and so on
// Numbering of joints is as per Kinect SDK spec
float[][] jointArray;
float[][] jointArrayMapped;
float[][] jointArrayLerped;

// Array of curated colours. Each row contains 3 colours, two for the curved shape and one for a "boom" circle. 
color[][] colorArray;

// Which row of the colour array to use. (Typing 'c' changes the colour)
int colorRef = 0;

// How many times the body is repeated around the frame (adjusted by typing 'r')
int repetitions = 10;

// Lerping values that come in so the animation is a little smoother. 
float lerpPercent = .5;

// Weight of animated lines (it's a variable because I explored adjusting it with the beat)
int weight = 2;

// For triggering a circle to expand from the middle of frame
boolean boom;
float boomSize;

void setup(){
  size(1024,768);
  //fullScreen();
  colorMode(HSB);
  noStroke();
  
  // Initialise OSC connections/ports
  oscP5SkeletonReceiver = new OscP5(this,6449);
  dest = new NetAddress("127.0.0.1",6448);
  
  // Initialise arrays of joint data
  jointArray = new float[25][2];
  jointArrayMapped = new float[25][2];
  jointArrayLerped = new float[25][2];
  
  // Initialise color array
  colorArray = new color[5][3];
  
  colorArray[0][0] = color(229,244,107);
  colorArray[0][1] = color(7,205,195);
  colorArray[0][2] = color(191,188,86);  
  
  colorArray[1][0] = color(28,156,210);
  colorArray[1][1] = color(151,145,137);
  colorArray[1][2] = color(246,96,169);
  
  colorArray[2][0] = color(249,159,207);
  colorArray[2][1] = color(96,75,187);
  colorArray[2][2] = color(40,122,232);
  
  colorArray[3][0] = color(248,21,73);
  colorArray[3][1] = color(96,12,187);
  colorArray[3][2] = color(96,12,255);
  
  colorArray[4][0] = color(133,188,122);
  colorArray[4][1] = color(114,188,187);
  colorArray[4][2] = color(28,71,220);
  
  // Initialise stuff for listening to linein and checking the beat
  minim = new Minim(this);
  song = minim.getLineIn();
  beat = new BeatDetect();
  
}

void draw(){
  // Background is a rectangle with low opacity, to give some fading effect to the animations
  fill(0,0,30,40);
  noStroke();
  rect(0,0,width,height);
  
  // Find beats in the song
  beat.detect(song.mix);
  
  // When there's a beat, draw a thick circle in the centre of frame
  if ( beat.isOnset() ){
    stroke(0,0,255,90);
    strokeWeight(50);
    ellipse(width/2,height/2,height/1.8,height/1.8);
   }
   
  strokeWeight(2);
  
  
  // Draws the kalaidescopic animation based on the skeleton points
  drawKaleidescopeCurves();
  
  // If boom has been triggered by pressing 'b', then an expanding circle appears
  if (boom){
    boom();
  }
 
}



void drawKaleidescopeCurves(){
  // Two representationns of the body are drawn, as curved lines, using selected skeleton joints. 
  
  // Save the current transformation (none) to the matrix stack 
  pushMatrix();
  
    // For however many repetitions 
    for (int i = 0; i<repetitions; i++){
      
      // rotate from the centre of screen
      translate(width/2, height/2);
      
      // Total circle divided by number of repetitions so they're evenly spaced
      rotate(TWO_PI/repetitions);
      translate(-width/2, -height/2);   
      
      // Set stroke based on colour array
      stroke(colorArray[colorRef][0]);
      
      // Draw curve between these skeleton joints
      drawLongCurve(18,3,11,7,14);
    }
  
  // Return to the original transformation (none)
  popMatrix();
  
  // Save it again
  pushMatrix();
    for (int i = 0; i<4; i++){
      // Rotate from centre of the screen
      translate(width/2, height/2);
      
      // This one always gets drawn 4 times
      rotate(TWO_PI/4);
      translate(-width/2, -height/2);    
      stroke(colorArray[colorRef][1]);
      
      // Draw curve between these skeleton joints
      drawLongCurve(3,7,13,4,11);
    }
  
  // Return to no transformation
  popMatrix();
}


// Draw a normal body in dots (for testing)
void drawBody(){
  for (int i = 0; i < 25; i++) {
    fill(255,255,255);
    ellipse(jointArrayMapped[i][0],jointArrayMapped[i][1],10,10);
  }
}

// Draw a small body in the top left (to demonstrate to others (on social media etc) that the body is tracked, and is affecting the animations, without needing to film)
void drawRefBody(){
  fill(0,0,50);
  noStroke();
  rect(120,120,100,110);
  for (int i = 0; i < 25; i++) {
    fill(0,0,255);
    float x = map(jointArray[i][0],-1.7,1.7, 110, 230);
    float y = map(jointArray[i][1],-1.2,1.2, 210, 130);    
    ellipse(x,y,3,3);
  }
}

// Draw a curve with 4 joints
void drawBodyCurve(int joint1, int joint2, int joint3, int joint4){
  noFill();
  strokeWeight(weight);
  // joint 1 - control point 1
  // joint 2 - start of curve
  // joint 3 - end of curve
  // joint 4 - control point 2
  curve(jointArrayLerped[joint1][0], jointArrayLerped[joint1][1], jointArrayLerped[joint2][0], jointArrayLerped[joint2][1], jointArrayLerped[joint3][0], jointArrayLerped[joint3][1], jointArrayLerped[joint4][0], jointArrayLerped[joint4][1]);
}

// Draw a curve with 5 points, joined in a loop
void drawLongCurve(int joint1, int joint2, int joint3, int joint4, int joint5){
  noFill();
  beginShape();
    curveVertex(jointArrayLerped[joint1][0], jointArrayLerped[joint1][1]); // the first control point
    curveVertex(jointArrayLerped[joint1][0], jointArrayLerped[joint1][1]); // is also the start point of curve
    curveVertex(jointArrayLerped[joint2][0], jointArrayLerped[joint2][1]);
    curveVertex(jointArrayLerped[joint3][0], jointArrayLerped[joint3][1]);
    curveVertex(jointArrayLerped[joint4][0], jointArrayLerped[joint4][1]);
    curveVertex(jointArrayLerped[joint5][0], jointArrayLerped[joint5][1]); 
    curveVertex(jointArrayLerped[joint1][0], jointArrayLerped[joint1][1]); // the last point of curve
    curveVertex(jointArrayLerped[joint2][0], jointArrayLerped[joint2][1]); // is also the last control point
  endShape();
   
}

// When an OSC message is received
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

// Cycles through the rows of the colour array
void colorChange(){
  colorRef ++;
  if (colorRef>4) { colorRef = 0;}
}

// Cycles through various numbers of repetitions of the first kaleidoscope shape
void changeRepetitions(){
 repetitions-=3;
 if (repetitions < 2){repetitions = 12;}
}

// Draws an expanding circle
void boom(){
   stroke(colorArray[colorRef][2]);
   strokeWeight(10);
   ellipse(width/2,height/2,boomSize,boomSize);
   // Circle expands every frame
   boomSize+=50;
   
   // Until it's off the frame and then it's reset
   if(boomSize>width+400){
     boom = false; 
     boomSize = 0;
   }
}


// Change which gesture we're recording for. 
void keyPressed() {
  if (key == 'c') {
    // Changes the colour reference to use a different set of colours
    colorChange();
  }
  if (key == 'r') {
    // Changes the number of times the first kaleidoscope shape is repeated 
    changeRepetitions();
  }
  if (key == 'b') {
    // Sets off the expanding circle
    boom = true;
  }
}