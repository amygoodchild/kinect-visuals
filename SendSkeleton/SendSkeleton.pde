/*****

 Send skeleton data over OSC 
 This means skeleton data can be used raw in another sketch, 
 Being in the same sketch as the Kinect library seemed to cause conflicts with perspective, measurements, distances etc
 which makes it laborious to draw animations, requiring lots of transforms and slowing framerate. 
 
 Heavily based on KinectPV2 Library Examples by Thomas Sanchez Lengeling - http://codigogenerativo.com/
 Edited to send over OSC by Amy Goodchild 2018

*****/


// Kinect libraries
import KinectPV2.KJoint;
import KinectPV2.*;

// OSC libraries
import oscP5.*;
import netP5.*;

NetAddress dest;

KinectPV2 kinect;

OscP5 oscP5;

float zVal = 300;
float rotX = PI;

void setup() {
  size(1024, 768, P3D);
  
  // Initiate kinect
  kinect = new KinectPV2(this);
  kinect.enableColorImg(true);
  kinect.enableSkeleton3DMap(true);
  kinect.init();
  
  // Set up OSC connection
  oscP5 = new OscP5(this,8000);
  dest = new NetAddress("127.0.0.1",6449);
  
}

void draw() {
  background(0);

  // Show the camera image in the top left
  image(kinect.getColorImage(), 0, 0, 320, 240);

  // Translate the scene to the center 
  pushMatrix();
  translate(width/2, height/2, 0);
  
  // Transform to scale/position the skeleton
  scale(zVal);
  rotateX(rotX);
  
  // Set up arraylist to hold the skeleton data
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeleton3d();

  // For each skeleton
  for (int i = 0; i < skeletonArray.size(); i++) {
    
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    
    if (skeleton.isTracked()) {
      
      // Get the joints and save to array of joint objects
      KJoint[] joints = skeleton.getJoints();

      // Draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);

      //Draw body
      color col  = skeleton.getIndexColor();
      stroke(col);
      drawBody(joints);
      
      // Send the joints over OSC
      sendOsc(joints);
    }
  }
  popMatrix();
  fill(255, 0, 0);
  text(frameRate, 50, 50);
}


// Send skeleton data over OSC
void sendOsc(KJoint[] joints) {
  OscMessage msg = new OscMessage("/joints");
  
  // Formatted so we send all the X values (for joints 0-24) and then all the Y values
  for (int i=0; i<25; i++){
    msg.add(joints[i].getX()); 
  }
  for (int i=0; i<25; i++){
    msg.add(joints[i].getY()); 
  }
  
  oscP5.send(msg, dest);
} 

// Draw a body with bones
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);

  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm   
  
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

// Draws all the tracked joints
void drawJoint(KJoint[] joints, int jointType) {
  strokeWeight(2.0f + joints[jointType].getZ()*8);
  point(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
}

// Draws bones as lines between two joints
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  strokeWeight(2.0f + joints[jointType1].getZ()*8);
  point(joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

// Draws hand state (open closed or lasso)
void drawHandState(KJoint joint) {
  handState(joint.getState());
  strokeWeight(5.0f + joint.getZ()*8);
  point(joint.getX(), joint.getY(), joint.getZ());
}

// Assesses whether a hand is open, closed, not tracked, or in the lasso shape. 
void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    stroke(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    stroke(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    stroke(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    stroke(100, 100, 100);
    break;
  }
}