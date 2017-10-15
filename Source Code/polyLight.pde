 //TODO: Update collision physics, move all global variables to top AKA MAKE CODE NEAT!
class Rect
{
  color fill;
  int x, y, w, h;

  int[] vertTL = new int[2];
  int[] vertTR = new int[2];
  int[] vertBR = new int[2];
  int[] vertBL = new int[2];

  final static int vertCount = 4;

  public Rect(color fill, int x, int y, int width_, int height_)
  {
    this.fill = fill;
    this.x = x;
    this.y = y;
    this.w = width_;
    this.h = height_;
    calcVerts();
  }

  private void calcVerts()
  {
    vertTL[0] = this.x; //top left corner
    vertTL[1] = this.y;

    vertTR[0] = this.x+this.w; //top right corner
    vertTR[1] = this.y;

    vertBR[0] = this.x+this.w; //bottom right corner
    vertBR[1] = this.y+this.h;

    vertBL[0] = this.x; //bottom left corner
    vertBL[1] = this.y+this.h;
  }

  public void render()
  {
    fill(this.fill);
    rect(this.x, this.y, this.w, this.h);
  }
}

class Light
{
  color col, bulbCol;
  int x, y, d;

  public Light(color col_, color bulbCol_, int x_, int y_, int d_)
  {
    this.col = col_;
    this.bulbCol = bulbCol_;
    this.x = x_;
    this.y = y_;
    this.d = d_;
  }

  public void renderBulb()
  {
    ellipseMode(CENTER);
    fill(bulbCol);
    ellipse(x, y, d, d);
  }
}

Light light = new Light(color(255, 241, 224), color(0, 150, 255), width/2, height/2, 25);
ArrayList<Rect> rects = new ArrayList<Rect>();
color rectCol = color(0, 0, 0);
color rayCol = color(0, 255, 0);
color shadowCol = color(0, 0, 0);
boolean renderRay = false, renderShadows = false;

int s0, s1, fps = 0, frames = 0;
void setup()
{
  size(800, 800);
  noStroke();
  s0 = second();
  s1 = s0;
  textSize(26);
  frameRate(10000);
}

void draw()
{
  s1 = second();
  frames++;
  background(light.col);
  light.renderBulb();
  if ((s1-s0) >= 1)
  {
    fps = frames;
    s0=second();
    s1=s0;
    frames=0;
  }
  
  if (rects.size() > 0)
  {
    float angleCCBL = getAngle(light.x, light.y, 0, height-1); //gets angles from rect center to corners of screen
    float angleCCBR = getAngle(light.x, light.y, width-1, height-1);
    float angleCCTL = getAngle(light.x, light.y, 0, 0);
    float angleCCTR = getAngle(light.x, light.y, width-1, 0);
    
    int[] cornerBR = renderRay(new int[]{light.x,light.y}, angleCCBR);
    int[] cornerBL = renderRay(new int[]{light.x,light.y}, angleCCBL);
    int[] cornerTR = renderRay(new int[]{light.x,light.y}, angleCCTR);
    int[] cornerTL = renderRay(new int[]{light.x,light.y}, angleCCTL);
    
    for (Rect rect : rects)
    {
      rect.render();
      float angleTL = getAngle(light.x, light.y, rect.vertTL[0], rect.vertTL[1]);
      float angleTR = getAngle(light.x, light.y, rect.vertTR[0], rect.vertTR[1]);
      float angleBL = getAngle(light.x, light.y, rect.vertBL[0], rect.vertBL[1]);
      float angleBR = getAngle(light.x, light.y, rect.vertBR[0], rect.vertBR[1]);
  
      int[] rTL = renderRay(rect.vertTL, angleTL);
      int[] rTR = renderRay(rect.vertTR, angleTR);
      int[] rBL = renderRay(rect.vertBL, angleBL);
      int[] rBR = renderRay(rect.vertBR, angleBR);
      if(renderShadows == true)
      { 
        int vertTopLine = rect.y;
        int vertBotLine = rect.y+rect.h;
        int horLeftLine = rect.x;
        int horRightLine = rect.x+rect.w;
        
        ArrayList<int[]> vertices = new ArrayList<int[]>(); //stores vertices of shadow
        
        //find where light is in relative to the rectangle
        if(light.y <= vertTopLine) //above rectangle
        {
          if(light.x <= horLeftLine) //left corner of rectangle
          {
            vertices.add(rect.vertTL);
            vertices.add(rect.vertBL);
            vertices.add(rBL);
            if(cornerBR[1] <= rBL[1] && cornerBR[1] >= rTR[1])
            {
              vertices.add(cornerBR);
            }
            vertices.add(rTR);
            vertices.add(rect.vertTR);
          }
          else if(light.x >= horRightLine) //right corner of rectangle
          {
            vertices.add(rect.vertTR);
            vertices.add(rect.vertBR);
            vertices.add(rBR);
            if(cornerBL[1] <= rBR[1] && cornerBL[1] >= rTL[1])
            {
              vertices.add(cornerBL);
            }
            vertices.add(rTL);
            vertices.add(rect.vertTL);
          }
        }
        else if(light.y >= vertBotLine) //below rectangle
        {
          if(light.x <= horLeftLine) //left corner of rectangle
          {
            vertices.add(rect.vertBL);
            vertices.add(rect.vertTL);
            vertices.add(rTL);
            if(cornerTR[1] >= rTL[1] && cornerTR[1] <= rBR[1])
            {
              vertices.add(cornerTR);
            }
            vertices.add(rBR);
            vertices.add(rect.vertBR);
          }
          else if(light.x >= horRightLine) //right corner of rectangle
          {
            vertices.add(rect.vertBR);
            vertices.add(rect.vertTR);
            vertices.add(rTR);
            if(cornerTL[1] >= rTR[1] && cornerTL[1] <= rBL[1])
            {
              vertices.add(cornerTL);
            }
            vertices.add(rBL);
            vertices.add(rect.vertBL);
          }
        }
        else if(light.y >= vertTopLine && light.y <= vertBotLine) //side of rectangle
        {
          if(light.x <= horLeftLine) //left side of rectangle
          {
            vertices.add(rect.vertBL);
            vertices.add(rBL);
            if(cornerBR[0] >= rBL[0] && cornerBR[1] <= rBL[1])
            {
              vertices.add(cornerBR);
            }
            if(cornerTR[0] >= rTL[0])
            {
              vertices.add(cornerTR);
            }
            vertices.add(rTL);
            vertices.add(rect.vertTL);
          }
          else if(light.x >= horRightLine) //right side of rectangle
          {
            vertices.add(rect.vertBR);
            vertices.add(rBR);
            if(cornerBL[0] <= rBR[0] && cornerBL[1] <= rBR[1])
            {
              vertices.add(cornerBL);
            }
            if(cornerTL[0] <= rTR[0])
            {
              vertices.add(cornerTL);
            }
            vertices.add(rTR);
            vertices.add(rect.vertTR);
          }
        }
        
        if(light.x > horLeftLine && light.x < horRightLine) //direct top/bottom of rectangle
        {
          if(light.y <= vertTopLine) //top of rectangle
          {
            vertices.add(rect.vertTL);
            vertices.add(rTL);
            if(cornerBL[0] >= rTL[0] && cornerBL[1] >= rTL[1])
            {
              vertices.add(cornerBL);
            }
            if(cornerBR[0] <= rTR[0] && cornerBR[1] >= rTR[1])
            {
              vertices.add(cornerBR);
            }
            vertices.add(rTR);
            vertices.add(rect.vertTR);
          }
          else if(light.y >= vertBotLine) //bottom of rectangle
          {
            vertices.add(rect.vertBL);
            vertices.add(rBL);
            if(cornerTL[0] >= rBL[0] && cornerTL[1] <= rBL[1])
            {
              vertices.add(cornerTL);
            }
            if(cornerTR[0] <= rBR[0] && cornerTR[1] <= rBR[1])
            {
              vertices.add(cornerTR);
            }
            vertices.add(rBR);
            vertices.add(rect.vertBR);
          }
        }
        
        //creates the shadow poly
        fill(shadowCol);
        beginShape();
        noStroke();
        for(int[] v : vertices)
        {
          vertex(v[0], v[1]);
        }
        endShape();
      }
    }
  }

  fill(150, 255, 0);
  text("FPS: "+str(fps), 25, 25);
}

boolean movingLight = false;
boolean dragging = false;
int dX, dY;
int margin = 5;
void mouseDragged()
{ 
  if (dragging == false && mouseButton == LEFT)
  {
    dragging = true;
    dX = mouseX;
    dY = mouseY;
  }

  if (movingLight == true && mouseButton == RIGHT)
  {
    int newX = mouseX;
    int newY = mouseY;
    boolean canMove = true;

    for (Rect rect : rects)
    {
      if ((rect.x < newX+light.d/2) && (rect.x+rect.w > newX-light.d/2) && (rect.y < newY+light.d/2) && (rect.y+rect.h > newY-light.d/2))
      {
        //TODO: Improve collision physics
        canMove = false;
        break;
      }
      
      if(!(((newX-light.d/2) > 0+margin && (newX+light.d/2) < width-1-margin) && ((newY-light.d/2) > 0+margin && (newY+light.d/2) < height-1-margin)))
      {
        canMove = false;
        break;
      }
    }

    if (canMove == true)
    {
      light.x = mouseX;
      light.y = mouseY;
    }
  }
}

int minRectW = 20;
int minRectH = 20;
void mouseReleased()
{
  if (movingLight == true && mouseButton == RIGHT)
  {
    movingLight = false;
  }

  if (dragging == true && mouseButton == LEFT)
  {
    dragging = false;

    int x1, y1, x2, y2;
    int mX, mY;

    mX = mouseX;
    mY = mouseY;

    if (mX < dX)
    {
      x1 = mX;
      x2 = dX;
    } else
    {
      x1 = dX;
      x2 = mX;
    }

    if (mY < dY)
    {
      y1 = mY;
      y2 = dY;
    } else
    {
      y1 = dY;
      y2 = mY;
    }

    if ((x2-x1) >= minRectW && (y2-y1) >= minRectH)
    {
      boolean add = true;
      for (Rect rect : rects)
      {
        if ((rect.x < x2) && (rect.x+rect.w > x1) && (rect.y < y2) && (rect.y+rect.h > y1))
        {
          add = false;
          break;
        }
      }

      if (add == true)
      {
        if (!((light.x-light.d/2 > x1 && light.x+light.d/2 < x2) && (light.y-light.d/2 > y1 && light.y+light.d/2 < y2)))
        {
          rects.add(new Rect(rectCol, x1, y1, (x2-x1), (y2-y1)));
        }
      }
    }
  }
}

void mousePressed()
{
  if (mouseButton == RIGHT)
  {
    int x = mouseX;
    int y = mouseY;

    //Determines if mouse is within the light bulb
    if ((x >= (light.x-(light.d/2)) && x <= (light.x+(light.d/2))) && (y >= (light.y-(light.d/2)) && y <= (light.y+(light.d/2))))
    {
      if (movingLight == false)
      {
        movingLight = true;
      }
    }
  }
}

void keyPressed()
{
  if (key == 'x')
  {
    int x = mouseX;
    int y = mouseY;

    for (int i = 0; i < rects.size(); i++)
    {
      //Determines if mouse is within rectangle
      Rect rect = rects.get(i);
      if ((x >= rect.x && x <= (rect.x+rect.w)) && (y >= rect.y && y <= (rect.y+rect.h)))
      {
        rects.remove(rect);
      }
    }
  }
  
  if(key == 'r')
  {
    if(renderRay == false)
    {
      renderRay = true;
    }
    else
    {
      renderRay = false;
    }
  }
  
  if(key == 's')
  {
    if(renderShadows == false)
    {
      renderShadows = true;
    }
    else
    {
      renderShadows = false;
    }
  }
}

//HELPING METHODS----------------------------------------------------------------------------------------------------------------------------------------
private int[] getRayPoint(int[] origin, float angle, int radius) //calculates point of ray
{
  int[] hit = new int[2];
  hit[0] = round(origin[0]+radius*cos(radians(angle)));
  hit[1] = round(origin[1]+radius*sin(radians(angle)));
  return hit;
}

private float getAngle(int x1, int y1, int x2, int y2)
{
  float dy = y2 - y1;
  float dx = x2 - x1;
  float theta = atan2(dy, dx);
  theta = degrees(theta);

  while (theta < 0) {
    theta += 360;
  }
  return theta;
}

private int[] renderRay(int[] origin, float angle)
{
  boolean run = true;
  int l = 0, x = 0, y = 0;
  while (run == true)
  {
    int[] xy = getRayPoint(origin, angle, l);

    if ( (xy[0] > 0 && xy[0] < width-1) && (xy[1] > 0 && xy[1] < height-1) ) //checks if ray is within screen
    {
      if(renderRay == true)
      {
        set(xy[0], xy[1], rayCol);
      }
      
      x = xy[0];
      y = xy[1];
    } 
    else
    {
      run = false;
    }

    l++;
  }

  return new int[]{x, y};
}
