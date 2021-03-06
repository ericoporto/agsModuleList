AGSScriptModule    Steve McCrea Antialiased drawing primitives DrawAntialiased 1.1 J  // DrawAntialiased module
// Line based on Xiaolin Wu's line algorithm, Dr Dobbs, June 1992
// Circle is my own concoction

int ipart(float x)
{
  return FloatToInt(x, eRoundDown);
}

int round(float x)
{
  return FloatToInt(x, eRoundNearest);
}

float fpart(float x)
{
  return x - IntToFloat(ipart(x));
}

float rfpart(float x)
{
  return 1.0 - fpart(x);
}

DrawingSurface *gSurfaceToDrawOn;
DynamicSprite *gPixel;
float gOverallOpacity;

void plot(bool steep, int x, int y, float c)
{
  int t = 100 - FloatToInt(100.0*c*gOverallOpacity);
  if (steep)
  {
    gSurfaceToDrawOn.DrawImage(y, x, gPixel.Graphic, t);
  }
  else
  {
    gSurfaceToDrawOn.DrawImage(x, y, gPixel.Graphic, t);
  }
}

void plotline(int xl, int xr, int y)
{
  int t = 100 - FloatToInt(100.0*gOverallOpacity);
  gSurfaceToDrawOn.DrawImage(xl, y, gPixel.Graphic, t, xr - xl + 1, 1);
}

function DrawAntialiasedLine(this DrawingSurface *, float x1, float y1, float x2, float y2,  int transparency)
{
  gSurfaceToDrawOn = this;
  gOverallOpacity = 1.0 - IntToFloat(transparency)/100.0;
  gPixel = DynamicSprite.Create(1, 1);
  DrawingSurface *dss = gPixel.GetDrawingSurface();
  dss.Clear(this.DrawingColor);
  dss.Release();

  float dx = x2 - x1;
  float dy = y2 - y1;
  bool steep = false;
  if (dx*dx < dy*dy)
  {
    float s = x1;
    x1 = y1;
    y1 = s;
    
    s = x2;
    x2 = y2;
    y2 = s;
    
    steep = true;
  }
  if (x2 < x1)
  {
    float s = x1;
    x1 = x2;
    x2 = s;
    
    s = y1;
    y1 = y2;
    y2 = s;
  }
  dx = x2 - x1;
  dy = y2 - y1;
  float gradient = dy / dx;
  // handle first endpoint
  int xend = round(x1);
  float yend = y1 + gradient * (IntToFloat(xend) - x1);
  float xgap = rfpart(x1 + 0.5);
  int xpxl1 = xend;  // this will be used in the main loop
  int ypxl1 = ipart(yend);
  plot(steep, xpxl1, ypxl1, rfpart(yend) * xgap);
  plot(steep, xpxl1, ypxl1 + 1, fpart(yend) * xgap);
  float intery = yend + gradient; // first y-intersection for the main loop
  // handle second endpoint
  xend = round(x2);
  yend = y2 + gradient * (IntToFloat(xend) - x2);
  xgap = fpart(x2 + 0.5);
  int xpxl2 = xend;  // this will be used in the main loop
  int ypxl2 = ipart(yend);
  plot(steep, xpxl2, ypxl2, rfpart(yend) * xgap);
  plot(steep, xpxl2, ypxl2 + 1, fpart(yend) * xgap);  
  // main loop
  int x = xpxl1 + 1;
  while (x < xpxl2)
  {
    // inline these for speed during the loop
    int ipart_intery = FloatToInt(intery, eRoundDown);
    float fpart_intery = intery - IntToFloat(ipart_intery);
    float rfpart_intery = 1.0 - fpart_intery;

    plot(steep, x, ipart_intery, rfpart_intery);
    plot(steep, x, ipart_intery + 1, fpart_intery);
    intery = intery + gradient;
    x++;
  }
  
  gPixel.Delete();
}

function drawAntialiasedCircle(DrawingSurface *surf, float centre_x, float centre_y, float radius, int transparency, bool filled)
{
  gSurfaceToDrawOn = surf;
  gOverallOpacity = 1.0 - IntToFloat(transparency)/100.0;
  gPixel = DynamicSprite.Create(1, 1);
  DrawingSurface *dss = gPixel.GetDrawingSurface();
  dss.Clear(surf.DrawingColor);
  dss.Release();
  
  int ystage = 0;
  
  int y = FloatToInt(centre_y - radius) - 1;
  if (y < 0) y = 0;
  int ymax = FloatToInt(centre_y + radius) + 2;
  if (ymax > Room.Height) ymax = Room.Height;
  while (y < ymax)
  {
    float y_d = IntToFloat(y) - centre_y;
    float y_d_2 = y_d*y_d;
    float x_l = Maths.Sqrt((radius + 2.0)*(radius + 2.0) - y_d_2);
    int x = FloatToInt(centre_x - x_l);
    while (x < FloatToInt(centre_x + x_l) + 1)
    {
      float x_d = IntToFloat(x) - centre_x;
      float d = Maths.Sqrt(x_d*x_d + y_d_2);
      if (filled)
      {
        if (d < radius + 1.0)
        {
          if (d < radius - 1.0)
          {
            int c = FloatToInt(centre_x);
            if (x < c)
            {
              int rx = 2*c - x + 1;
              plotline(x, rx, y);
              x = rx;
            }
            else
            {
              plot(false, x, y, 1.0);
            }
          }
          else
          {
            float c = 0.5*(radius + 1.0 - d);
            plot(false, x, y, c);
          }
        }
      }
      else
      {
        if (d < radius - 1.0)
        {
          int c = FloatToInt(centre_x);
          if (x < c)
          {
            x = 2*c - x;
          }
        }
        else
        if (d > radius - 1.0 && d < radius + 1.0)
        {
          float c = radius - d;
          if (c < 0.0) c = -c;
          c = 1.0 - c;
          plot(false, x, y, c);
        }
      }
      x++;
    }
    y++;
  }

  gPixel.Delete();
}

function DrawAntialiasedCircle(this DrawingSurface *, float centre_x, float centre_y, float radius, int transparency)
{
  drawAntialiasedCircle(this, centre_x, centre_y, radius, transparency, false);
}

function DrawAntialiasedFilledCircle(this DrawingSurface *, float centre_x, float centre_y, float radius, int transparency)
{
  drawAntialiasedCircle(this, centre_x, centre_y, radius, transparency, true);
}

 �  // DrawAntialiased module header
// By Steve McCrea, 2010

// Adds extender functions to DrawingSurface
//
// Example usage:
// DrawingSurface *surf = Room.GetDrawingSurfaceForBackground();
// surf.DrawingColor = 455;
// surf.DrawAntialiasedLine(33.5, 44.2, 88.8, 22.7);
// surf.Release();

import function DrawAntialiasedLine(this DrawingSurface *, float x1, float y1, float x2, float y2, int transparency = 0);

import function DrawAntialiasedCircle(this DrawingSurface *, float centre_x, float centre_y, float radius, int transparency = 0);
import function DrawAntialiasedFilledCircle(this DrawingSurface *, float centre_x, float centre_y, float radius, int transparency = 0); ���U        ej��