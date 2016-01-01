import processing.opengl.*;
import SimpleOpenNI.*;
import ddf.minim.*;
SimpleOpenNI kinect;
Minim minim;

color[] players;
AudioSnippet[] se;
Hotpoint[] boxs;

static final int CAM_WIDTH = 640;
static final int CAM_HEIGHT = 480;
static final float RATE = 1.0f;
static final int APP_WIDTH = (int)(CAM_WIDTH * RATE);
static final int APP_HEIGHT = (int)(CAM_HEIGHT * RATE);


static final float size = 50.0f;
static final float sizeV = size + 100.0f;
static final float posY = -64.0f;
static final float depth = 1000.0f;

static final float MIN_DEPTH = depth-sizeV;
static final float MAX_DEPTH = depth+sizeV;


void setup() {
  size(APP_WIDTH, APP_HEIGHT, OPENGL);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  kinect.alternativeViewPointDepthToImage();

  minim = new Minim(this);

  // load both audio files
  se = new AudioSnippet[8];
  se[0] = minim.loadSnippet("0.wav");
  se[1] = minim.loadSnippet("1.wav");
  se[2] = minim.loadSnippet("2.wav");
  se[3] = minim.loadSnippet("3.wav");
  se[4] = minim.loadSnippet("4.wav");
  se[5] = minim.loadSnippet("5.wav");
  se[6] = minim.loadSnippet("6.wav");
  se[7] = minim.loadSnippet("7.wav");

  // initialize hotpoints with their origins (x,y,z) and their size
  boxs = new Hotpoint[8];
  for (int i=0; i<8; i++) {
    PVector center = new PVector(128*-3.5f + i*128, posY, depth);
    PVector boxSize = new PVector(size, size*0.75f, size*2);
    boxs[i] = new Hotpoint(center, boxSize);
    
    PVector convertedCenter = new PVector();
    kinect.convertRealWorldToProjective(center, convertedCenter);
    boxs[i].setDrawCent(convertedCenter);
  }
  
  boxs[0].setStr("c");
  boxs[0].setColor(255, 63, 63);
  boxs[1].setStr("d");
  boxs[1].setColor(255, 143, 63);
  boxs[2].setStr("e");
  boxs[2].setColor(255, 255, 63);
  boxs[3].setStr("f");
  boxs[3].setColor(143, 255, 63);
  boxs[4].setStr("g");
  boxs[4].setColor(63, 211, 255);
  boxs[5].setStr("a");
  boxs[5].setColor(63, 143, 255);
  boxs[6].setStr("b");
  boxs[6].setColor(127, 63, 255);
  boxs[7].setStr("C");
  boxs[7].setColor(255, 63, 255);
  
  players = new color[10];
  for(int i=0; i<10; i++)  {players[i] = color(random(255), random(255), random(255));}
}
void draw() {
  background(0);
  kinect.update();
  image(kinect.rgbImage(), 0, 0);
  strokeWeight(4);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {
    for(int i=0; i<userList.size(); i++) {
      int userId = userList.get(i);
      if ( kinect.isTrackingSkeleton(userId)) {
        stroke( red(players[i]), blue(players[i]), green(players[i]), 255 );
        
        PVector rightHand = new PVector(), convertedJointR;
        float confidenceR, ellipseSizeR, alphaR;
        PVector leftHand = new PVector(), convertedJointL;
        float confidenceL, ellipseSizeL, alphaL;
        
        confidenceR = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
        if ( 0.5 < confidenceR ) {convertedJointR = new PVector();
          ellipseSizeR = map(rightHand.z, 0, 2048, 55, 15);
          alphaR = map(rightHand.z, MIN_DEPTH, MAX_DEPTH, -1.570796326794897, 1.570796326794897);
          kinect.convertRealWorldToProjective(rightHand, convertedJointR);

          if( MIN_DEPTH < rightHand.z && rightHand.z < MAX_DEPTH ) {
//            fill( 255, 0, 0, 255 );            textSize( 24 );
//            text( "(?, "+(rightHand.y-posY)+", "+(rightHand.z-depth)+")", convertedJointR.x + ellipseSizeR, convertedJointR.y );
            fill( 255, 0, 0, 200*cos(alphaR)+55 );
            
            for (int j=0; j<8; j++) {boxs[j].check(rightHand);}
          }
          else {fill( red(players[i]), blue(players[i]), green(players[i]), 55 );}
          
          ellipse(convertedJointR.x, convertedJointR.y, ellipseSizeR, ellipseSizeR);
        }
        confidenceL = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
        if ( 0.5 < confidenceL ) {convertedJointL = new PVector();
          ellipseSizeL = map(leftHand.z, 0, 2048, 55, 15);
          alphaL = map(leftHand.z, MIN_DEPTH, MAX_DEPTH, -1.570796326794897, 1.570796326794897);
          kinect.convertRealWorldToProjective(leftHand, convertedJointL);
          
          if( MIN_DEPTH < leftHand.z && leftHand.z < MAX_DEPTH ) {
//            fill( 255, 0, 0, 255 );            textSize( 24 );
//            text( "(?, "+(leftHand.y-posY)+", "+(leftHand.z-depth)+")", convertedJointL.x + ellipseSizeL, convertedJointL.y );
            fill( 255, 0, 0, 200*cos(alphaL)+55 );
            
            for (int j=0; j<8; j++) {boxs[j].check(leftHand);}
          }
          else {fill( red(players[i]), blue(players[i]), green(players[i]), 55 );}
          
          ellipse(convertedJointL.x, convertedJointL.y, ellipseSizeL, ellipseSizeL);
        }
      }
    }
  }
  
  strokeWeight(6);
  for (int i=0; i<8; i++) {
    
    if ( boxs[i].isHit() ) {
//    if ( boxs[i].currentlyHit() ) {
      boxs[i].addEff();
      se[i].play();
    }
    if ( !se[i].isPlaying() ) {se[i].rewind();}

    // display each hotpoint and clear its points
    boxs[i].draw();
    boxs[i].clear();
  }
}
void stop()
{
  // make sure to close
  // both AudioPlayer objects
  for (int i=0; i<8; i++) {
    se[i].close();
  }

  minim.stop();
  super.stop();
}

void drawSkeleton(int userId) {
  stroke(0);
  strokeWeight(4);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, 
  SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, 
  SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, 
  SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, 
  SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, 
  SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, 
  SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, 
  SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, 
  SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, 
  SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, 
  SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, 
  SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, 
  SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, 
  SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, 
  SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, 
  SimpleOpenNI.SKEL_RIGHT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, 
  SimpleOpenNI.SKEL_LEFT_HIP);
  noStroke();
  fill(0);
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD); 
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
//  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
//  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
}
void drawJoint(int userId, int jointID) { 
  PVector joint = new PVector();

  float confidence = kinect.getJointPositionSkeleton(userId, jointID, 
  joint);
  if (confidence < 0.5) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 25, 25);
}
// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startPoseDetection("Psi", userId);
}
void onEndCalibration(int userId, boolean successful) {
  if (successful) {
    println(" User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  }
  else {
    println(" Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}
void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}

