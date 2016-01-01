import java.util.Random;

class Ellipse
{
  final int MAX_ellipse = 15;
  int current_Num = 0;
  ArrayList<Position> pos;
  int current = 0;
  int interval = 100;
  int range = 25;
  
  public Ellipse()
  {
     pos = new ArrayList();
  }
  
  void addellipse()
  {
    if(MAX_ellipse > pos.size())
    {
      pos.add(new Position((int)(Math.random()*540)+50, (int)(Math.random()*380)+50));
      current_Num = pos.size();
    }   
  }
  
  Position getellipse(int index)
  {
    return pos.get(index);
  }
  
  void removeellipse(int index)
  {
      pos.remove(index);
       current_Num = pos.size();
  }
  
  boolean collisionellipse(int x1, int y1, float x2, float y2)
  {
    return range*range >= (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2);
  }

  void count()
  {
    current++;
    if(current == interval)
    {
      addellipse();
      current = 0;
    }
  }
}
