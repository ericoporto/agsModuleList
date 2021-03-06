AGSScriptModule    Steve McCrea Composite objs and chars on bg FakeScreen 1.0   // FakeScreen module script

__FakeScreen FakeScreen;
export FakeScreen;

bool gEnabled = false;

int gSrc = 0;
int gDst = 0;
int gBaseLine = 0;

struct SThingToDraw
{
  int objIndex;
  int chrIndex;
  int baseLine;
};

SThingToDraw gThingsToDraw[128];

function do_once(int src, int dst)
{
  int numThingsToDraw = 0;
  int i = 0;
  while (i < Room.ObjectCount)
  {
    int baseLine = object[i].Baseline;
    if (baseLine == 0)
    {
      baseLine = object[i].Y;
    }
    if (baseLine < gBaseLine)
    {
      gThingsToDraw[numThingsToDraw].objIndex = i;
      gThingsToDraw[numThingsToDraw].chrIndex = -1;
      gThingsToDraw[numThingsToDraw].baseLine = baseLine;
      numThingsToDraw++;
    }
    i++;
  }
  i = 0;
  while (i < Game.CharacterCount)
  {
    if (character[i].Room == player.Room)
    {
      int baseLine = character[i].Baseline;
      if (baseLine == 0)
      {
        baseLine = character[i].y;
      }
      if (baseLine < gBaseLine)
      {
        gThingsToDraw[numThingsToDraw].objIndex = -1;
        gThingsToDraw[numThingsToDraw].chrIndex = i;
        gThingsToDraw[numThingsToDraw].baseLine = baseLine;
        numThingsToDraw++;
      }
    }
    i++;
  }
  
  // now bubble sort
  i = 0;
  while (i < numThingsToDraw-1)
  {
    int j = i+1;
    while (j < numThingsToDraw)
    {
      if (gThingsToDraw[j].baseLine < gThingsToDraw[i].baseLine)
      {
        // swap
        int objIndex = gThingsToDraw[j].objIndex;
        int chrIndex = gThingsToDraw[j].chrIndex;
        int baseLine = gThingsToDraw[j].baseLine;
        gThingsToDraw[j].objIndex = gThingsToDraw[i].objIndex;
        gThingsToDraw[j].chrIndex = gThingsToDraw[i].chrIndex;
        gThingsToDraw[j].baseLine = gThingsToDraw[i].baseLine;
        gThingsToDraw[i].objIndex = objIndex;
        gThingsToDraw[i].chrIndex = chrIndex;
        gThingsToDraw[i].baseLine = baseLine;          
      }
      j++;
    }
    i++;
  }
  
  // draw
  DrawingSurface *surf = Room.GetDrawingSurfaceForBackground(dst);
  DynamicSprite *bg = DynamicSprite.CreateFromBackground(src);
  surf.DrawImage(0, 0, bg.Graphic);
  bg.Delete();

  i = 0;
  while (i < numThingsToDraw)
  {
    int objIndex = gThingsToDraw[i].objIndex;
    int chrIndex = gThingsToDraw[i].chrIndex;
    int baseLine = gThingsToDraw[i].baseLine;
    if (objIndex != -1)
    {
      int graphic = object[objIndex].Graphic;
      int height = Game.SpriteHeight[graphic];
      if (!object[objIndex].IgnoreScaling)
      {
        int scaling = GetScalingAt(object[objIndex].X, object[objIndex].Y);
        if (scaling != 100)
        {
          height = FloatToInt(IntToFloat(height*scaling)/100.0);
        }
      }
      surf.DrawImage(object[objIndex].X, object[objIndex].Y - height, graphic, object[objIndex].Transparency);
    }
    else
    {
      ViewFrame *frame = Game.GetViewFrame(character[chrIndex].View, character[chrIndex].Loop, character[chrIndex].Frame);
      DynamicSprite *sprite;
      int graphic = frame.Graphic;
      if (frame.Flipped)
      {
        sprite = DynamicSprite.CreateFromExistingSprite(graphic);
        sprite.Flip(eFlipLeftToRight);
        graphic = sprite.Graphic;
      }
      int height = FloatToInt(IntToFloat(Game.SpriteHeight[graphic]*character[chrIndex].Scaling)/100.0);
      int width  = FloatToInt(IntToFloat( Game.SpriteWidth[graphic]*character[chrIndex].Scaling)/100.0);
      surf.DrawImage(character[chrIndex].x - width/2, character[chrIndex].y - height - character[chrIndex].z, graphic, character[chrIndex].Transparency, width, height);
    }
    i++;
  }
  surf.Release();
}

function __FakeScreen::Enable(int frameToCopyFrom, int frameToCopyTo, int baseLine)
{
  gSrc = frameToCopyFrom;
  gDst = frameToCopyTo;
  gBaseLine = baseLine;
  gEnabled = true;

  do_once(frameToCopyFrom, 0);
}

function __FakeScreen::Disable()
{
  gEnabled = false;
}

function repeatedly_execute()
{
  if (gEnabled)
  {
    do_once(gSrc, gDst);
  }
}
 �  // FakeScreen module header
// To use, make sure the room this is in has the appropriate bg frames
// And add a walkbehind that fills the screen with a baseline low enough to hide the objects and characters

struct __FakeScreen
{
  import function Enable(int frameToCopyFrom, int frameToCopyTo, int baseLine);
  import function Disable();
};

import __FakeScreen FakeScreen;
 ��?'        ej��