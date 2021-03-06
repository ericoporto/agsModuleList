AGSScriptModule        �  // new module script

Overlay *oLabel;
DynamicSprite *sprite;
FontType Font = 0;
int Color = 16;
int MaxWidth;
bool SpringOn = true;
bool SlideIn = true;
int Offset = -5;


float lastMX,  lastMY;
bool isNew;
float moveTimer  = 0.0;

float saturate(float val)
{
    if (val < 0.0) return 0.0;
    if (val > 1.0) return 1.0;
    return val;
}

float _lerp(float value1,  float value2,  float amount)
{
    return value1 + (value2 - value1) * amount;
}

float _smoothstep(float edge0, float edge1, float x)
{
    // Scale, bias and saturate x to 0..1 range
    x = saturate((x - edge0)/(edge1 - edge0)); 
    // Evaluate polynomial
    return x * x * (3.0 - 2.0 * x);
}

function _clamp(int val, int min,  int max) 
{
    if (val < min) return min;
    if (val > max) return max;
    return val;
}

static void FloatingHotspot::SetSlideIn(bool on)
{
  SlideIn = on;
}

static void FloatingHotspot::SetSpring(bool on)
{
  SpringOn = on;
}

static void FloatingHotspot::SetVerticalOffset(int offset)
{
  Offset = offset;
}

static void FloatingHotspot::SetMaxWidth(int width)
{
  MaxWidth = _clamp(width, 10, System.ViewportWidth);
}

static void FloatingHotspot::SetFont(FontType font)
{
  Font = _clamp(font, 0,  Game.FontCount - 1);
  
}
 
static void FloatingHotspot::SetColor(int color)
{
  Color = _clamp(color, 0, 65535);
}

function game_start() 
{
    FloatingHotspot.SetMaxWidth(System.ViewportWidth);
}



function repeatedly_execute_always()
{
  Label1.Text = String.Format("movetimer: %f", moveTimer);
    isNew = true;
    if (oLabel != null && oLabel.Valid) {
      oLabel.Remove();
      isNew = false;
      
    }
    
    if (isNew) {
      moveTimer = 0.0;
    }
    String s = Game.GetLocationName(mouse.x,  mouse.y);
    if (s == null || s == "") return;
    
    int width = _clamp(GetTextWidth(s, Font), 0, MaxWidth);
    int height = GetTextHeight(s, Font, width + 2);
    
    float smooth = _smoothstep(0.0, 1.0, moveTimer);
    
    int drawY = FloatToInt(_lerp(IntToFloat(height), 0.0, smooth));
     //int drawY = FloatToInt(Maths.Sqrt((1.0 - moveTimer) * 100.0), eRoundNearest);
    moveTimer = saturate(moveTimer + 0.1);
    
     
    if (!SlideIn) drawY = 0;
    
    sprite = DynamicSprite.Create(width, height, true);
    DrawingSurface *surf = sprite.GetDrawingSurface();
    surf.DrawingColor = Color;
    surf.DrawStringWrapped(0, drawY, width + 1, Font, eAlignLeft, s);
    surf.Release();
    
    float targetx = IntToFloat(_clamp(mouse.x - width / 2, 0, System.ViewportWidth - width));
    float targety = IntToFloat(_clamp(mouse.y - height, 0, System.ViewportWidth - height));
    
    float x, y;
    
    
    if (isNew || !SpringOn){
      x = targetx;
      y = targety;
  
    }
    else 
    {


        x = lastMX - (lastMX - targetx) / 4.0;
        y = lastMY - (lastMY - targety) / 4.0;
    }
      
      lastMX = x;
      lastMY = y;
    
    //Display("Showing %s at: %d %d", s,  x,  y);
    
    oLabel = Overlay.CreateGraphical(FloatToInt(x, eRoundNearest), FloatToInt(y, eRoundNearest) + Offset, sprite.Graphic,  true);
    
}

 Q  // new module header


managed struct FloatingHotspot 
{
  import static void SetMaxWidth(int width);
  import static void SetFont(FontType font);
  import static void SetColor(int color);
  import static void SetSlideIn(bool on);
  import static void SetSpring(bool on);
  import static void SetVerticalOffset(int offset);
}; F�k        ej��