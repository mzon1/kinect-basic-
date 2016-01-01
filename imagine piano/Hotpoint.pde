class Hotpoint {
  PVector center;
  PVector drawCenter;
  PVector boxSize;
  String seStr;
  
  float colorR, colorG, colorB;
  ArrayList<Integer> eff;
  
  int pointsIncluded;
  int maxPoints;
  boolean wasJustHit;
  int threshold;
  Hotpoint(PVector Center, PVector BoxSize) { 
    center = new PVector();
    center.x = Center.x;
    center.y = Center.y;
    center.z = Center.z;
    drawCenter = new PVector();
    boxSize = new PVector();
    boxSize.x = BoxSize.x;
    boxSize.y = BoxSize.y;
    boxSize.z = BoxSize.z;
    
    eff = new ArrayList<Integer>();
    
    pointsIncluded = 0;
    maxPoints = 1000;
    threshold = 0;
  }
  void setThreshold( int newThreshold ) {
    threshold = newThreshold;
  }
  void setMaxPoints(int newMaxPoints) {
    maxPoints = newMaxPoints;
  }
  void setColor(float red, float green, float blue) {
    colorR = red;
    colorG = green;
    colorB = blue;
  }
  void setDrawCent(PVector dc) {
    drawCenter.x = dc.x;
    drawCenter.y = dc.y;
    drawCenter.z = dc.z;
  }
  void setStr(String str) {seStr = str;}
  
  void addEff() {eff.add(0);}
  
  boolean check(PVector point) {
    boolean result = false;
    if (point.x > center.x - boxSize.x && point.x < center.x + boxSize.x) {
      if (point.y > center.y - boxSize.y && point.y < center.y + boxSize.y) {
        if (point.z > center.z - boxSize.z && point.z < center.z + boxSize.z) {
          result = true;
          pointsIncluded++;
        }
      }
    }
    return result;
  }
  void draw() { 
    pushMatrix();
    translate(drawCenter.x, drawCenter.y, 0);
    fill(0, 0, 0, 0);    stroke(colorR, colorG, colorB, 255);
    box(boxSize.x, boxSize.y, 0);
    
    for(int i=0; i<eff.size(); i++) {
      int frame = eff.get(i);
      float rate = 1.0f+frame/12.0f;
      stroke(colorR, colorG, colorB, (12-frame)*20 );
      box(boxSize.x*rate, boxSize.y*rate, 0);
      
      eff.set( i, frame+1 );
    }
    
    fill(colorR, colorG, colorB, 255);
    textSize(24);    text(seStr, -6, -32, 0);
    popMatrix();
  }
  float percentIncluded() {
    return map(pointsIncluded, 0, maxPoints, 1, 0);
  }
  boolean currentlyHit() { 
    return (pointsIncluded > threshold);
  }
  boolean isHit() { 
    return currentlyHit() && !wasJustHit;
  }
  void clear() {
    wasJustHit = currentlyHit();
    pointsIncluded = 0;
    
    for(int i=0; i<eff.size(); i++) {
      if( 12 < eff.get(i) ) {eff.remove(i);}
    }
  }
}

