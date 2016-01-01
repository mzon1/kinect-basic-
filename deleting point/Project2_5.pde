import SimpleOpenNI.*;
SimpleOpenNI kinect;
import java.util.Random;

int closestValue;
int closestX;
int closestY;

float lastX;
float lastY;

int score = 0;
Ellipse ell;

void setup()
{
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.setMirror(true);
  ell = new Ellipse();
}

void draw()
{
  closestValue = 8000; 
  ell.count();
  kinect.update();
  // get the depth array from the kinect
  int[] depthValues = kinect.depthMap();
  // for each row in the depth image
  for(int y = 0; y < 480; y++){ 
    // look at each pixel in the row
    for(int x = 0; x < 640; x++){ 
      // pull out the corresponding value from the depth array
      //int reversedX = 640-x-1;
      //int i = reversedX + y * 640;
      int i = x + y * 640;
      int currentDepthValue = depthValues[i];
      // if that pixel is the closest one we've seen so far
      if(currentDepthValue > 610 && currentDepthValue < 1525
         && currentDepthValue < closestValue){
        // save its value
        closestValue = currentDepthValue;
        // and save its position (both X and Y coordinates)
        closestX = x;
        closestY = y;
      }
    }
  }
  
  float interpolatedX = lerp(lastX, closestX, 0.3f); 
  float interpolatedY = lerp(lastY, closestY, 0.3f);
  lastX = interpolatedX;
  lastY = interpolatedY;
  
  //draw the depth image on the screen
  image(kinect.depthImage(),0,0);
  // draw a red circle over it,
  // positioned at the X and Y coordinates
  // we saved of the closest pixel.
  for(int num = 0; num < ell.current_Num; num++)
  {
    Position position = new Position();
    position = ell.getellipse(num);
     ellipse(position.x, position.y, 50, 50);
     if(ell.collisionellipse(position.x, position.y, lastX, lastY))
      {
        ell.removeellipse(num);
        score++;
      } 
  }
  
  
  fill(255,0,0);
  ellipse(closestX, closestY, 25, 25);
  textSize(20);
  text("X: " + closestX + ", Y : " +  closestY + ", SCORE : " + score , 10, 50);
}
