AGSScriptModule        �2  /** 
 * @author  Artium Nihamkin, artium@nihamkin.com
 * @date    09/2018
 * @version 2.2.0
 *  
 * @brief This is an AGS module that makes it possible to add a hinting
 *        system to a game. Upon user action, a shape will be drawn
 *        around each enabled hotspot in the room.
 *  
 * @section LICENSE
 *
 * The MIT License (MIT)
 * Copyright � 2018 Artium Nihamkin, artium@nihamkin.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the �Software�), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED �AS IS�, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * @section DESCRIPTION 
 *
 * Please refer the ash file for complete description.
 */


// C O N F I G U R A T I O N 
/////////////////////////////

/** 
  * The the highest ID of a hotspot in the room. This is required because a 
  * static allocation for data in this module.
  * To disable hints on hotspots, set this to 0.
  */
#define MAX_ROOM_HOTSPOSTS_SUPPORTED 50

/** 
  * The the highest ID of a character in the game. This is required because a 
  * static allocation for data in this module.
  * To disable hints on charaters, set this to 0.
  */
#define MAX_CHARACTERS_SUPPORTED 50

/** 
  * The the highest ID of an object. This is required because a 
  * static allocation for data in this module.
  * To disable hints on objects, set this to 0.
  */
#define MAX_ROOM_OBJECTS_SUPPORTED 50

/*
 * IMPORTANT: This value should be the sum of 
 * MAX_ROOM_HOTSPOSTS_SUPPORTED,MAX_ROOM_OBJECTS_SUPPORTED,MAX_CHARACTERS_SUPPORTED
 */
#define TOTAL_HINTS_SUPPORTED 150

/** 
  * Which shape to use for hints. Can be circle, rectangle or mixed as 
  * define by the HintShapeType enum.
  * Mixed will a separate decision for each hotspot whether to use 
  * circle or to use rectangle. The decision will be based on the ratio of 
  * height to width defined separately.
  */
#define HINT_SHAPE_TO_USE eHintMixed

/**
  * If eHintMixed is selected, this will be the ratio used for deciding
  * which shape to use.
  * If the width/height or height/width of the area is larger than this
  * defined value, then a rectangle will be used, otherwise, a circle. 
  */
#define HINT_SHAPE_MIXED_RATIO 1.5

/**
 * The width of the highlight shape
 */
#define BORDER_WIDTH 2

/**
 * Padding around objects/hotspots/characters
 */
#define PADDING 5

/** 
  * The color of the highlight shape
  */
#define BORDER_COLOR Game.GetColorFromRGB(Random(255), Random(255), Random(255))


/**
 * To prevent highlights that are too small, it is possible to define minimal
 * size. If the shape is smaller that that size, it's size will be increased.
 * For circles, size is the diameter.
 * For rectangles, size is the edge's length (each dimension increased separately)
 */
#define MINIMAL_SHAPE_SIZE 20

/**
 * If this parameter set to true, the user of the module is responsible for
 * calling the module's interface functions for calculating and displaying hints.
 */
#define USE_CUSTOM_HANDLING false

/**
 * Used only when USE_CUSTOM_HANDLING is set to false.
 * When this key is held down, the overlay is displayed.
 */
#define KEY_FOR_DISPLAYING_HINTS eKeySpace

// T Y P E S
////////////

struct HotspotExtendedDataType
{  
  bool initialised;
  int boundRight;
  int boundLeft;
  int boundTop;
  int boundBottom;
};


enum HintShapeType
{
   eHintCircle,
   eHintRectangle, 
   eHintMixed
};

// I N T E R N A L  D A T A
////////////////////////////

DynamicSprite* sprite;
Overlay* overlay;

HotspotExtendedDataType hintsData[TOTAL_HINTS_SUPPORTED];
bool hintsEnabled = true;

bool lastPassCalculated = false;

bool gamePausedByModule = false;

// I N T E R N A L  F U N C T I O N S
/////////////////////////////////////

/**
 * This is an internal method. It draws a rectangle around the hotspot.
 * It must be run in the context of the CalculateHintsForRoom after 
 * hintsData was calculated.
 * @surface The surface on which to draw the higlight.
 * @hotspotID The id of the hotspot to draw a rectangle for.
 */
function DrawRectangle(DrawingSurface* surface,  int hotspotID)
{
  int h = hintsData[hotspotID].boundBottom - hintsData[hotspotID].boundTop;
  int w = hintsData[hotspotID].boundRight - hintsData[hotspotID].boundLeft;
  
  int left   = hintsData[hotspotID].boundLeft;
  int right  = hintsData[hotspotID].boundRight;
  int top    = hintsData[hotspotID].boundTop;
  int bottom = hintsData[hotspotID].boundBottom;
  
  top -= PADDING;
  bottom += PADDING;
  left -= PADDING;
  right += PADDING;
  
  // Increase edges' length if too small
  if (h < MINIMAL_SHAPE_SIZE) {
    top    -= (MINIMAL_SHAPE_SIZE - h) / 2;
    bottom += (MINIMAL_SHAPE_SIZE - h) / 2;
    h = MINIMAL_SHAPE_SIZE;
    
  }

  if (w < MINIMAL_SHAPE_SIZE) {
    left  -= (MINIMAL_SHAPE_SIZE - w) / 2;
    right += (MINIMAL_SHAPE_SIZE - w) / 2;
    w = MINIMAL_SHAPE_SIZE;
  }

  // Draw clockwise
  surface.DrawingColor = BORDER_COLOR;
  
  // Top
  surface.DrawLine(
    left,     top,  
    right,    top, 
    BORDER_WIDTH);
  
  // Right
  surface.DrawLine(
    right,     top,  
    right    , bottom, 
    BORDER_WIDTH);
    
  // Bottom
  surface.DrawLine(
    right,     bottom,  
    left,      bottom, 
    BORDER_WIDTH);
    
  // Left
  surface.DrawLine(
    left,     bottom,  
    left    , top, 
    BORDER_WIDTH);
}

/**
 * This is an internal method. It draws a rectangle around the hotspot.
 * It must be run in the context of the CalculateHintsForRoom after 
 * hintsData was calculated.
 * @surface The surface on which to draw the higlight.
 * @hotspotID The id of the hotspot/character/object to draw a circle for.
 */
function DrawCircle(DrawingSurface* surface,  int hotspotID)
{
  int h = hintsData[hotspotID].boundBottom - hintsData[hotspotID].boundTop;
  int w = hintsData[hotspotID].boundRight - hintsData[hotspotID].boundLeft;
  
  int radius;
  
  if (w > h) {
    radius = w / 2;
  } else {
    radius = h / 2;
  }
  
  radius += PADDING;
  
  if (2 * radius < MINIMAL_SHAPE_SIZE) {
    radius = MINIMAL_SHAPE_SIZE / 2;
  }
  
  // Prepare the drawing of the highlight on a separate sprite.
  
  // Sprite big enough to draw a circle of that radius
  DynamicSprite* tempSprite = DynamicSprite.Create(2*radius + 1, 2*radius + 1, true);
  DrawingSurface* tempSurface = tempSprite.GetDrawingSurface();
      
  tempSurface.DrawingColor = BORDER_COLOR;
  tempSurface.DrawCircle(radius,  radius,  radius);
  tempSurface.DrawingColor = COLOR_TRANSPARENT;
  tempSurface.DrawCircle(radius,  radius,  radius - BORDER_WIDTH);
  tempSurface.Release();
  
  // Draw the prepared sprite onto the surface that contains all the highlights.
  int centerX = hintsData[hotspotID].boundLeft + w / 2;
  int centerY = hintsData[hotspotID].boundTop  + h / 2;
  surface.DrawImage(
    centerX - radius, 
    centerY - radius, 
    tempSprite.Graphic,
    0); // 0 for no tranparency
  tempSprite.Delete();
}

// F U N C T I O N S
/////////////////////

static function HintsHighlighter::UpdateHintWithNewPoint(int ID,  int x,  int y)
{
  hintsData[ID].initialised = true;
  
  // y coordinate is 0 at the top and increasing towards the buttom
  if(hintsData[ID].boundBottom < y) {
    hintsData[ID].boundBottom = y;
  }

  if(hintsData[ID].boundTop > y) {
    hintsData[ID].boundTop = y;
  }
  
  if(hintsData[ID].boundLeft > x) {
    hintsData[ID].boundLeft = x;
  }

  if(hintsData[ID].boundRight < x) {
    hintsData[ID].boundRight = x;
  }
}

static function HintsHighlighter::CalculateHintsForRoom()
{
  for(int i = 0; i < TOTAL_HINTS_SUPPORTED; i++)
  {
      hintsData[i].boundBottom = 0;
      hintsData[i].boundTop    = System.ScreenHeight;
      hintsData[i].boundRight  = 0;
      hintsData[i].boundLeft   = System.ScreenWidth;
      hintsData[i].initialised = false;
  }
    
  // Precalculate the bounding rectangle of each visible hotspot/object/character
  // Please notice that x,y are screen coordinares
  // We simply ignore stuff  that are not currently visible.
  for(int x = Random(1); x < System.ScreenWidth; x+=2)
  {
    for(int y = Random(1); y < System.ScreenHeight; y+=2)
    {
      Hotspot *h = Hotspot.GetAtScreenXY(x, y);
      if ( h != hotspot[0] && h.Enabled && h.ID < MAX_ROOM_HOTSPOSTS_SUPPORTED)
      {
        HintsHighlighter.UpdateHintWithNewPoint(h.ID, x, y); 
      }
      
      // NOTE: Any characters with the "Clickable" property set to false will not 
      // be seen by this function.
      Character *c = Character.GetAtScreenXY(x, y);
      if (c != null && c.ID < MAX_CHARACTERS_SUPPORTED) {
        HintsHighlighter.UpdateHintWithNewPoint(c.ID + MAX_ROOM_HOTSPOSTS_SUPPORTED, x, y); 
      }
      
      Object *obj = Object.GetAtScreenXY(x, y);
      if (obj != null && obj.ID < MAX_ROOM_OBJECTS_SUPPORTED) {
        HintsHighlighter.UpdateHintWithNewPoint(obj.ID + MAX_ROOM_HOTSPOSTS_SUPPORTED + MAX_CHARACTERS_SUPPORTED, x, y); 
      }
    }
  }
  
  // Construct the sprite that will later be used as overlay of all the hints
  sprite = DynamicSprite.Create(System.ScreenWidth, System.ScreenHeight,  true);
  DrawingSurface* surface = sprite.GetDrawingSurface();
  
  for(int i = 0; i < TOTAL_HINTS_SUPPORTED; i++)
  {
    if (hintsData[i].initialised)
    {
      if (HINT_SHAPE_TO_USE == eHintRectangle) {
        DrawRectangle(surface,  i);
      } else if (HINT_SHAPE_TO_USE == eHintCircle) {
        DrawCircle(surface,  i);
      } else if (HINT_SHAPE_TO_USE == eHintMixed) {
        
        float h = IntToFloat(hintsData[i].boundBottom - hintsData[i].boundTop);
        float w = IntToFloat(hintsData[i].boundRight  - hintsData[i].boundLeft);

        if (h == 0.0) h = 1.0;
        if (w == 0.0) w = 1.0;
        
        if (h/w > HINT_SHAPE_MIXED_RATIO || w/h > HINT_SHAPE_MIXED_RATIO) {
          DrawRectangle(surface,  i);
        } else {
          DrawCircle(surface,  i);
        }
        
      } else {
        AbortGame("Invalid value for HINT_SHAPE_TO_USE");
      }
    }
  }  
  
  surface.Release();
}

static function HintsHighlighter::DisplayHints()
{
  // Sprite is null before the first calculation
  if (sprite)
  {
    if (hintsEnabled)
      {
      // Calling DisplayHints repeatedly must not leak resources
      if (overlay != null && overlay.Valid  ) {
        overlay.Remove();
      }
      
      overlay = Overlay.CreateGraphical(0, 0, sprite.Graphic,  true);
    }
  }
}
  
static function HintsHighlighter::HideHints()
{
  if (overlay != null && overlay.Valid)
  {
    overlay.Remove();
  }
}


static function HintsHighlighter::EnableHints()
{
   hintsEnabled = true;
}


static function HintsHighlighter::DisableHints()
{
  HintsHighlighter.HideHints();
  hintsEnabled = false;
}


// G L O B A L  S C R I P T  F U N C T I O N S
//////////////////////////////////////////////

function game_start()
{
  if (TOTAL_HINTS_SUPPORTED !=
        MAX_ROOM_HOTSPOSTS_SUPPORTED + 
        MAX_ROOM_OBJECTS_SUPPORTED +
        MAX_CHARACTERS_SUPPORTED) 
  {
      AbortGame("Invalid value for TOTAL_HOTSPOTS_SUPPORTED");
  }
}

function repeatedly_execute()
{
  if (USE_CUSTOM_HANDLING == false) {
    
    // Calculate hints once, when the button is pressed. If overlay is already displayed, do not recalculate.
    if (IsKeyPressed(KEY_FOR_DISPLAYING_HINTS)) {

      if (lastPassCalculated == false) {
        HintsHighlighter.CalculateHintsForRoom();
        lastPassCalculated =true;
      }
      
      HintsHighlighter.DisplayHints();
      
      if (IsGamePaused() == false) {
        gamePausedByModule = true;
        PauseGame();
      }
    } else {
      lastPassCalculated = false;
      if(gamePausedByModule) {
        gamePausedByModule = false;
        UnPauseGame();
      }
      HintsHighlighter.HideHints();
    }
  }
}
 �  /** 
 * @author  Artium Nihamkin, artium@nihamkin.com
 * @date    09/2018
 * @version 2.2.0
 *  
 * @brief This is an AGS module that makes it possible to add a hinting
 *        system to a game. Upon user action, a shape will be drawn
 *        around each enabled hotspot in the room.
 *  
 * @section LICENSE
 *
 * The MIT License (MIT)
 * Copyright � 2018 Artium Nihamkin, artium@nihamkin.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the �Software�), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED �AS IS�, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * @section DESCRIPTION 
 *
 * This module adds a hinting system to your game. Hints are circles or rectangles
 * which highlight hotspots in the game. Players which are stuck and wish to skip the
 * "pixel hunting" stage of a game, can press a button to display an overlay layer with
 * all clickable hotspots highlighted by a shape.
 * 
 * The most basic way to integrate this module into you game is to add the script files.
 * 
 * The default implementation displays the layer as long as the "H" key is help down. 
 * 
 * The user of this module can also provide it's own implementation of when and how to
 * activate the layer with the hints. This is configurable through the USE_CUSTOM_HANDLING
 * parameter. After setting USE_CUSTOM_HANDLING to true, the user must call CalculateHintsForRoom
 * and DisplayHints/HideHints on it's own.
 *
 * Additionally, DisableHints/EnableHints to control when it is applicable to show the layer. 
 * For example, upon entering the menu, a user can call DisableHints and upon returning to 
 * the game, EnableHints can be called.
 *
 * Please see the asc file for more configuration options.
 *
 */


struct HintsHighlighter {
  
  /**
   * Helper function for CalculateHintsForRoom
   */
  import static function UpdateHintWithNewPoint(int ID,  int x,  int y);
  
  /**
    * This function will recalculate the overlay that contains all the hints.
    * Do not run it every frame, it will cripple game's frame rate.
    */
	import static function CalculateHintsForRoom();
  
  /**
   * Display the overlay that contains the hints.
   */
  import static function DisplayHints();
  
  /**
   * Hide the overlay that contains the hints.
   */
  import static function HideHints();
  
  /**
   * Enable the displaying of the hints.
   */
  import static function EnableHints();
  
  /**
   * Disable the displaying of the hints. Calling DisplayHints will
   * do nothing.
   */
  import static function DisableHints();
  
}; ��K        ej��