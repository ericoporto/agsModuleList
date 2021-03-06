AGSScriptModule    SSH Let all your characters have a shadow. Shadow 1.1   // Main script for module 'Shadow'

bool first_room;

Shadows Shadow;
export Shadow;

function Shadows::generate_cache() {
  #ifnver 3.0
	RawSaveScreen();
  #endif
  int i=1;
  while (i<SHADOW_MAX_WIDTH) {
    if (this.cache[i]!=null) this.cache[i].Delete(); // Clear old cache
    int half=i/2;
    #ifnver 3.0
    // Draw magenta background, as this becomes transparent in AGS grabbed sprites
		RawSetColorRGB(255, 0, 255);
    RawDrawRectangle(0, 0, i, i);
    // Draw circle in shadow colour and grab sprite
    RawSetColorRGB(this.Red,this.Green,this.Blue);
    RawDrawCircle(half, half, half);
    this.cache[i]=DynamicSprite.CreateFromBackground(GetBackgroundFrame(), 0, 0, i, i);
    #endif
    #ifver 3.0
    DynamicSprite *tmps=DynamicSprite.Create(i, i, false);
    DrawingSurface *tsds=tmps.GetDrawingSurface();
    tsds.Clear(COLOR_TRANSPARENT);
    tsds.DrawingColor=Game.GetColorFromRGB(this.Red,this.Green,this.Blue);
    tsds.DrawCircle(half, half, half);
    tsds.Release();
    this.cache[i]=tmps;
    #endif
    // Now squash circle to ellipse. Shame drawcircle doesn't have an optional ellipse thingy 
    int height=FloatToInt(this.PerspectiveFactor*IntToFloat(i), eRoundUp);
    this.cache[i].Resize(i, height);
	  i++;
	}
  #ifnver 3.0
  RawRestoreScreen();
  #endif
}

function Shadows::reset () {
	this.PerspectiveFactor=0.15;
	this.Red=35;
	this.Green=35;
	this.Blue=35;
}


function game_start() {
  Shadow.reset();
  first_room=true;
}

function Shadows::newroom() {
    int i=0;
    while (i<Game.CharacterCount) {
			this.lasts[i]=null;
			i++;
		}
}
  

function on_event(EventType event, int data) {
  if (event==eEventEnterRoomBeforeFadein) {
    Shadow.newroom();
    if (first_room) {
			Shadow.generate_cache(); // Cannot run in game_start, there's nowhere to draw
			first_room=false;
		}
	}
}

function Shadows::rep_ex() {
  int i=0;
  DrawingSurface *bgds=Room.GetDrawingSurfaceForBackground(GetBackgroundFrame());
  while (i<Game.CharacterCount) {
    // Redraw area under shadow from last cycle
    if (this.lasts[i]!=null) {
      #ifnver 3.0
      RawDrawImage(this.lastx[i],  this.lasty[i], this.lasts[i].Graphic);
      #endif
      #ifver 3.0
      bgds.DrawImage(this.lastx[i],  this.lasty[i], this.lasts[i].Graphic);
      #endif
			this.lasts[i].Delete();
			this.lasts[i]=null;
		}
		// Draw new shadow
    if (player.Room==character[i].Room && character[i].on && !this.off[i] && character[i].x>=0 && character[i].y>=0 && character[i].x<Room.Width && character[i].y<Room.Height) {
      Character *cs=character[i];
      ViewFrame *vf=Game.GetViewFrame(cs.View, cs.Loop, cs.Frame);
      #ifnver 3.0
      int scale=GetScalingAt(cs.x, cs.y);
      #endif
      #ifver 3.0
      int scale=character[i].Scaling;
      #endif
      int width=(Game.SpriteWidth[vf.Graphic]*scale)/100;
      if (width==0) width=1;
      int height=FloatToInt(this.PerspectiveFactor*IntToFloat(width), eRoundUp);
      int half=width/2;
      int halfh=height/2;
      this.lastx[i]=cs.x-half+((this.offsetx[i]*scale)/100);
      this.lasty[i]=(cs.y-halfh)+((this.offsety[i]*scale)/100);
      if (this.lastx[i]<0) this.lastx[i]=0;
			if (this.lasty[i]<0) this.lasty[i]=0;
			if (this.lastx[i]+width>Room.Width) width=Room.Width-this.lastx[i];
			if (this.lasty[i]+height>Room.Height) height=Room.Height-this.lasty[i];
      this.lastw[i]=width;
      this.lasth[i]=height;
      //Display("C %d x %d y %d tlx %d tly %d w %d h %d", i, character[i].x,  character[i].y, this.lastx[i], this.lasty[i], width, height); 
      this.lasts[i]=DynamicSprite.CreateFromBackground(GetBackgroundFrame(), this.lastx[i], this.lasty[i], width, height);
      #ifnver 3.0
      RawDrawImageTransparent(this.lastx[i], this.lasty[i], this.cache[width].Graphic, this.Transparency);
      #endif
      #ifver 3.0
      bgds.DrawImage(this.lastx[i],  this.lasty[i], this.cache[width].Graphic, this.Transparency);
      #endif
		}
		// Next character
		i++;
	}
  #ifver 3.0
  bgds.Release();
  #endif
}

function repeatedly_execute_always() {
	Shadow.rep_ex();
}

function Shadows::SetPerspective(float factor) {
  this.PerspectiveFactor=factor;
  // Remake cache, as long as we're not in game_start:
  if (!first_room) this.generate_cache(); 
}

function Shadows::Disable(Character *who) {
  this.off[who.ID]=true;
}

function Shadows::Enable(Character *who) {
  this.off[who.ID]=false;
}

function Shadows::SetOffset(Character *who, int y, int x) {
  this.offsetx[who.ID]=x;
  this.offsety[who.ID]=y;
}

function Shadows::SetRGB(int red, int green, int blue) {
  this.Red=red; this.Blue=blue; this.Green=green;
}

function Shadows::SetTransparency(int percent) {
  this.Transparency=percent;
}

 =  // Script header for module 'Shadow'

// Author: Andrew MacCormack (SSH)
//   Please use the messaging function on the AGS forums to contact
//   me about problems with this module
// 
// Abstract: Make a circular shadow underneath characters.
//
// Dependencies:
//
//   AGS 2.72 or later
//
// Functions:
//
//  function Shadow.SetPerspective(float factor);
//
//		Set the perspective factor of the circle. The default is for the
//    height of the circle to be 0.15 times the width
//
//  function Shadow.Disable(Character *who); 
//
//		Turn off the shadow for the specified character.
//
//  function Shadow.Enable(Character *who);
//
//		Turn on the shadow for the specified character.
//
//  function Shadow.SetOffset(Character *who, optional int y, optional int x);
//
//		Set the y and x offset for the specified character, for example 
//    if they generally have a lot of blank space around the edge of 
//		their frames. Default offsets are 0. If you pass only 1 parameter, the
//    x offset is assumed to be 0, which is usually right.
//
//  function Shadow.SetRGB(int red, int green, int blue);
//
//		Set the colour of the shadow. NB pure black shadows (0,0,0) do not
//    become transparent, so the default is (35, 35, 35).
//
//  function Shadow.SetTransparency(int percent);
//
//		Set the transparency level for the shadow. Default is 80%
//
//
// Configuration:
//
//  By default, all characters in the current room will have shadows.
//
// Example:
//
//   Just add the module, and everyone will have shadows
//
// Caveats:
//
//   Animated background frames mess it up.
//   Walkbehinds don't work on the shadow.
//
// Revision History:
//
// 31 Oct 06: v1.0  First release of Shadow module
//  5 Mar 09: v1.1  Updated to work with AGS 3.0+
//
// Licence:
//
//   Shadow AGS script module
//   Copyright (C) 2006, 2009 Andrew MacCormack
//
// This module is licenced under the Creative Commons Attribution Share-alike
// licence, (see http://creativecommons.org/licenses/by-sa/2.5/scotland/ )
// which basically means do what you like as long as you credit me and don't
// start selling modified copies of this module.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.

#define SHADOW_MAX_WIDTH 200

#ifndef AGS_MAX_CHARACTERS
#define AGS_MAX_CHARACTERS 300
#endif

struct Shadows {
	protected DynamicSprite *lasts[AGS_MAX_CHARACTERS];
	protected int lastx[AGS_MAX_CHARACTERS];
	protected int lasty[AGS_MAX_CHARACTERS];
  protected int lasth[AGS_MAX_CHARACTERS];
  protected int lastw[AGS_MAX_CHARACTERS];
  
  protected DynamicSprite *cache[SHADOW_MAX_WIDTH];
  import function generate_cache();
  import function rep_ex();
  import function newroom();
  import function reset();

	writeprotected float PerspectiveFactor;
  writeprotected int Red;
  writeprotected int Green;
  writeprotected int Blue;
  writeprotected int Transparency;
	
	writeprotected int offsetx[AGS_MAX_CHARACTERS];
	writeprotected int offsety[AGS_MAX_CHARACTERS];
  writeprotected bool off[AGS_MAX_CHARACTERS];
  
  import function SetPerspective(float factor);
  import function Disable(Character *who); 
  import function Enable(Character *who);
  import function SetOffset(Character *who, int y=0, int x=0);
  import function SetRGB(int red, int green, int blue);
  import function SetTransparency(int percent);
};

import Shadows Shadow;
 �+�0        ej��