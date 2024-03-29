AGSScriptModule    Steve McCrea, abstauber Animates a water surface like the once-popular Java lake applet. Lake 1.5 M  // Main script for module 'Lake'
// v1.3 by Steve McCrea, 3rd January 2010
// v1.4 by abstauber

// uses this code taken from a java lake applet's source
// h/14*(i+28)*sin(h/14*(h-i)/(i+1) + phase)/h

function Lake::DefaultConstruct()
{
  this.enabled = true;
  this.x = 0;
  this.y = 100;
  this.w = 320;
  this.h = 100;
  this.speed = 1.0;
  this.tintObjects = false;
  
  this.baseline = 100;
  this.backgroundFrameIndex = 0;
  
  this.yRipplePhaseScale = 1.0;
  this.yRippleSize = 1.0;
  this.yRippleDensity = 1.0;
  
  this.xRipplePhaseScale = 0.5;
  this.xRippleDensity = 8.0;
  this.xRippleSize = 1.0;

  this.yPhase = 0.0;
  this.xPhase = 0.5*Maths.Pi;
}

struct ThingToReflect
{
  bool isCharacter;
  int index;
  int baseline;
};

#define LAKE_MAX_THINGS 512
ThingToReflect thingList[LAKE_MAX_THINGS];

function Lake::Update()
{
  if (this.enabled)
  {
    DynamicSprite *bg = DynamicSprite.CreateFromBackground();
    DrawingSurface *ds = bg.GetDrawingSurface();

    int n = 0;
    
    int i = 0;
    while ((i < Game.CharacterCount) && (n < LAKE_MAX_THINGS))
    {
      int charBase = character[i].Baseline;
      if (charBase == 0)
      {
        charBase = character[i].y;
      }
      if ((character[i].Room == player.Room)
        && (charBase < this.baseline)
        && (character[i].Transparency < 100))
      {
        thingList[n].isCharacter = true;
        thingList[n].index = i;
        thingList[n].baseline = charBase;
        n++;
      }
      i++;
    }

    i = 0;
    while (i < Room.ObjectCount && n < LAKE_MAX_THINGS)
    {
      int objBase = object[i].Baseline;
      if (objBase == 0)
      {
        objBase = object[i].Y;
      }
      if (object[i].Visible
        && object[i].Baseline < this.baseline
        && object[i].Transparency < 100)
      {
        thingList[n].isCharacter = false;
        thingList[n].index = i;
        thingList[n].baseline = objBase;
        n++;
      }
      i++;
    }

    i = 0;
    while (i < (n - 1))
    {
      int j = i + 1;
      while (j < n)
      {
        if (thingList[i].baseline > thingList[j].baseline)
        {
          bool ic = thingList[i].isCharacter;
          int in = thingList[i].index;
          int bl = thingList[i].baseline;
          thingList[i].isCharacter = thingList[j].isCharacter;
          thingList[i].index = thingList[j].index;
          thingList[i].baseline = thingList[j].baseline;
          thingList[j].isCharacter = ic;
          thingList[j].index = in;
          thingList[j].baseline = bl;
        }
        j++;
      }
      i++;
    }

    i = 0;
    while (i < n)
    {
      int in = thingList[i].index;
      ViewFrame *vf;
      DynamicSprite *dsf;
      Region *rat;
      
      // Objects
      if (!thingList[i].isCharacter)
      {
        if (object[in].Visible) {
          if (object[in].View) {
            vf = Game.GetViewFrame(object[in].View, object[in].Loop, object[in].Frame);
            dsf = DynamicSprite.CreateFromExistingSprite(vf.Graphic, true);
            if (vf.Flipped)
            {
              dsf.Flip(eFlipLeftToRight);
            }          
          }
          else {
            dsf = DynamicSprite.CreateFromExistingSprite(object[in].Graphic, true);
          }

          #ifver 3.00
          rat = Region.GetAtRoomXY(object[in].X - Game.Camera.X, object[in].Y - Game.Camera.Y );
          #endif

          #ifnver 3.00
          rat = Region.GetAtRoomXY(object[in].X - GetViewportX(), object[in].Y - GetViewportY() );
          #endif

          if ( (this.tintObjects) && (rat != null) && (rat != region[0]) && (rat.TintEnabled)) {
            dsf.Tint(rat.TintRed, rat.TintGreen, rat.TintBlue, rat.TintSaturation, 100);
          }
          
          int scale = GetScalingAt(object[in].X, object[in].Y);
          
          #ifver 3.00
          bool ignoreScaling = !object[in].ManualScaling;
          #endif

          #ifnver 3.00
          bool ignoreScaling = !object[in].IgnoreScaling;
          #endif
          
          if ((ignoreScaling) && (scale != 100)) {
            dsf.Resize((dsf.Width * scale) / 100, (dsf.Height * scale) / 100);
          }
          
          ds.DrawImage(object[in].X, object[in].Y - dsf.Height, dsf.Graphic, object[in].Transparency);
        }
      }
      // Characters
      else {
        vf = Game.GetViewFrame(character[in].View, character[in].Loop, character[in].Frame);
        dsf = DynamicSprite.CreateFromExistingSprite(vf.Graphic, true);
        
        #ifver 3.00
        rat = Region.GetAtRoomXY(character[in].x - Game.Camera.X , character[in].y - Game.Camera.Y );
        #endif

        #ifnver 3.00
        rat = Region.GetAtRoomXY(character[in].x - GetViewportX() , character[in].y - GetViewportY() );
        #endif
        
        if ((rat != null) && (rat != region[0]) && (rat.TintEnabled)) {
          dsf.Tint(rat.TintRed, rat.TintGreen, rat.TintBlue, rat.TintSaturation, 100);
        }
        
        if (vf.Flipped)
        {
          dsf.Flip(eFlipLeftToRight);
        }
        int w = (character[in].Scaling*dsf.Width)/100;
        int h = (character[in].Scaling*dsf.Height)/100;
        
        ds.DrawImage(character[in].x - w/2, (character[in].y - character[in].z) - h, dsf.Graphic, character[in].Transparency, w, h);
      }
      i++;
    }
    
    float phaseScalar = Maths.Pi/IntToFloat(GetGameSpeed());

		this.yPhase += this.speed*this.yRipplePhaseScale*phaseScalar;
		while (this.yPhase > 2.0*Maths.Pi) this.yPhase -= 2.0*Maths.Pi;
		
		this.xPhase += this.speed*this.xRipplePhaseScale*phaseScalar;
		while (this.xPhase > 2.0*Maths.Pi) this.xPhase -= 2.0*Maths.Pi;
	
		float fh = IntToFloat(this.h);
    
    DrawingSurface *bgSurf = Room.GetDrawingSurfaceForBackground();
		
		i = 0;
		while (i < this.h)
		{
			float fi = IntToFloat(i);
			float yAngle = ((this.yRippleDensity*fh/14.0)*(fh-fi)/(fi+1.0)) + this.yPhase;
			float yoff = this.yRippleSize*((28.0+fi)/14.0)*(1.0 + Maths.Sin(yAngle));
			int yoffi = FloatToInt(yoff);
			int yi = i - yoffi;
			if (yi >= 0)
			{
			  float xAngle = ((this.xRippleDensity*fh/14.0)*(fh-fi)/(fi+1.0)) + this.xPhase;
				float xoff = this.xRippleSize*((28.0+fi)/14.0)*(1.0 + Maths.Sin(xAngle));
				int xoffi = FloatToInt(xoff);
 				DynamicSprite *s = DynamicSprite.CreateFromDrawingSurface(ds, this.x + xoffi, this.y - yi, this.w - 2*xoffi, 1);
        bgSurf.DrawImage(this.x, this.y + i, s.Graphic, 0, this.w, 1);
			}
			i++;
		}

    ds.Release();
    bgSurf.Release();
	}
} >  // Script header for module 'Lake'
//
// Add a Lake to the top of a room script
//   Lake swimmingPoolSurface;
// In the room's player enters room (before fade in)
//   swimmingPoolSurface.DefaultConstruct();
// In the room's repeatedly execute
//   swimmingPoolSurface.Update();
//
//

struct Lake {
  // sets up the module with sensible default values
  import function DefaultConstruct();
  // call this from repeatedly execute
  import function Update();
  
  // whether to apply the effect
  bool enabled;
  // the area of the screen which is the water surface
  // it must be more than half way down the screen
  int x, y, w, h;
  // the speed of the ripple animation
  float speed;
  // use this baseline to choose which characters/objects to reflect/ignore
  int baseline;
  // if using the background, can reflect a different background
  // if using a screenshot, it's drawn to this frame first
  int backgroundFrameIndex;
  // if region tints should affect the refelction of objects too
  bool tintObjects;
  // how much to offset reflections
  float yRippleSize;
  // a parameter to control the y animation
  float yRipplePhaseScale;
  // how tightly packed the ripples are
  float yRippleDensity;

  // how much to offset reflections
  float xRippleSize;
  // a parameter to control the x animation
  float xRipplePhaseScale;
  // how tightly packed the ripples are
  float xRippleDensity;

  // normally updated internally but can be played with for special effects  
  float xPhase;
  float yPhase;
};

//
// Author: Steve McCrea
// Version: 1.5
// Released: 9th August 2023
// Notes: fixed compatibility with ver 3.6 by Nahuel
// 
// Version: 1.4
// Released: 27th January 2017
// Notes: added tints and scaling
//
// Version: 1.3
// Released: 29th March 2010
// Notes: fixed oo compatibility
//        moved to AGS3 only
// Version: 1.2
// Released: 3rd January 2010
// Notes: fixed right-to-left precedence
// Version: 1.1
// Released: 3rd January 2010
// Notes: one code path
// Version: 1.0
// Released: 8th July 2006
 A^@�        fj����  ej��