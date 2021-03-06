AGSScriptModule    monkey_05_06 Implements a "magnifying glass" style effect. Magnifier 1.0 �  
MagnifierType Magnifier;
export Magnifier;
bool CursorModeEnabled[];

bool IsModeEnabled(this Mouse*, CursorMode mode) {
  CursorMode prevmode = this.Mode;
  this.Mode = mode;
  bool enabled = (this.Mode == mode);
  this.Mode = prevmode;
  return enabled;
}

function game_start() {
  CursorModeEnabled = new bool[Game.MouseCursorCount];
  Magnifier.HideMouseCursor = true;
  Magnifier.ScaleFactor = 2.0;
}

void ShowCursor(this MagnifierType*) {
  mouse.ChangeModeGraphic(mouse.Mode, this.prevmodesprite);
  int i = 0;
  while (i < Game.MouseCursorCount) {
    if ((i != mouse.Mode) && (CursorModeEnabled[i])) mouse.EnableMode(i);
    i++;
  }
}

void HideCursor(this MagnifierType*) {
  this.prevmodesprite = mouse.GetModeGraphic(mouse.Mode);
  mouse.ChangeModeGraphic(mouse.Mode, 0);
  int i = 0;
  while (i < Game.MouseCursorCount) {
    if (i != mouse.Mode) {
      CursorModeEnabled[i] = mouse.IsModeEnabled(i);
      mouse.DisableMode(i);
    }
    i++;
  }
}

void Update(this MagnifierType*) {
  if ((this.AGSGUI == null) || (this.Sprite <= 0)) {
    this.Enabled = false;
    return;
  }
  if (this.prevenabled != this.Enabled) { // toggle on/off
    if ((this.HideMouseCursor) || (this.prevhidemouse)) {
      if (this.Enabled) this.HideCursor();
      else this.ShowCursor();
    }
  }
  else if ((this.prevhidemouse != this.HideMouseCursor) && (this.Enabled)) {
    if (this.HideMouseCursor) this.HideCursor();
    else this.ShowCursor();
  }
  this.prevhidemouse = this.HideMouseCursor;
  if (this.ScaleFactor <= 0.0) this.ScaleFactor = 0.1;
  this.prevenabled = this.Enabled;
  this.AGSGUI.Visible = false;
  if (!this.Enabled) return;
  this.AGSGUI.BackgroundGraphic = 0;
  this.X = mouse.x;
  this.Y = mouse.y;
  if ((this.X + this.XOffset) < 0) this.AGSGUI.X = 0;
  else if ((this.X + this.XOffset) >= System.ViewportWidth) this.AGSGUI.X = (System.ViewportWidth - 1);
  else this.AGSGUI.X = (this.X + this.XOffset);
  if ((this.Y + this.YOffset) < 0) this.AGSGUI.Y = 0;
  else if ((this.Y + this.YOffset) >= System.ViewportHeight) this.AGSGUI.Y = (System.ViewportHeight - 1);
  else this.AGSGUI.Y = (this.Y + this.YOffset);
  DynamicSprite *sprite = DynamicSprite.CreateFromExistingSprite(this.Sprite, false);
  int x = (FloatToInt(IntToFloat(this.X) * this.ScaleFactor) + this.XOffset);
  int y = (FloatToInt(IntToFloat(this.Y) * this.ScaleFactor) + this.YOffset);
  sprite.ChangeCanvasSize(FloatToInt(IntToFloat(System.ViewportWidth) * this.ScaleFactor), FloatToInt(IntToFloat(System.ViewportHeight) * this.ScaleFactor), x, y);
  this.BackgroundSprite = DynamicSprite.CreateFromBackground();
  DrawingSurface *surface = this.BackgroundSprite.GetDrawingSurface();
  int i = 0;
  while ((i < Game.CharacterCount) || (i < Room.ObjectCount)) {
    if (i < Game.CharacterCount) {
      if (character[i].Room == player.Room) {
        ViewFrame *frame = Game.GetViewFrame(player.View, player.Loop, player.Frame);
        int w = ((Game.SpriteWidth[frame.Graphic] * character[i].Scaling) / 100);
        int h = ((Game.SpriteHeight[frame.Graphic] * character[i].Scaling) / 100);
        surface.DrawImage(character[i].x - (w / 2), character[i].y - h, frame.Graphic, 0, w, h);
      }
    }
    if (i < Room.ObjectCount) {
      if (object[i].Visible) {
        int graphic = object[i].Graphic;
        if (object[i].View) {
          ViewFrame *frame = Game.GetViewFrame(object[i].View, object[i].Loop, object[i].Frame);
          graphic = frame.Graphic;
        }
        int w = Game.SpriteWidth[graphic];
        int h = Game.SpriteHeight[graphic];
        if (!object[i].IgnoreScaling) {
          int scale = GetScalingAt(object[i].X, object[i].Y);
          w = ((w * scale) / 100);
          h = ((h * scale) / 100);
        }
        surface.DrawImage(object[i].X, object[i].Y - Game.SpriteHeight[graphic], graphic);
      }
    }
    i++;
  }
  surface.Release();
  this.BackgroundSprite.Resize(FloatToInt(IntToFloat(this.BackgroundSprite.Width) * this.ScaleFactor), FloatToInt(IntToFloat(this.BackgroundSprite.Height) * this.ScaleFactor));
  this.BackgroundSprite.CopyTransparencyMask(sprite.Graphic);
  int w = Game.SpriteWidth[this.Sprite];
  int h = Game.SpriteHeight[this.Sprite];
  int ww = this.BackgroundSprite.Width;
  int hh = this.BackgroundSprite.Height;
  if ((ww > w) && (hh > h)) this.BackgroundSprite.Crop(x, y, w, h);
  else if (ww > w) {
    this.BackgroundSprite.Crop(x, 0, w, hh);
    if (hh < h) this.BackgroundSprite.ChangeCanvasSize(w, h, 0, (h - hh) / 2);
  }
  else if (hh > h) {
    this.BackgroundSprite.Crop(0, y, ww, h);
    if (ww < w) this.BackgroundSprite.ChangeCanvasSize(w, h, (w - ww) / 2, 0);
  }
  else this.BackgroundSprite.ChangeCanvasSize(w, h, (w - ww) / 2, (h - hh) / 2);
  if ((ww <= w) || (hh <= h)) {
    sprite = this.BackgroundSprite;
    this.BackgroundSprite = DynamicSprite.Create(w, h, false);
    surface = this.BackgroundSprite.GetDrawingSurface();
    surface.Clear(0);
    surface.DrawImage(0, 0, sprite.Graphic);
    surface.Release();
  }
  surface = this.BackgroundSprite.GetDrawingSurface();
  if (this.ScaleFactor < 1.0) {
    surface.DrawingColor = 0;
    int xm = FloatToInt(IntToFloat(System.ViewportWidth) * this.ScaleFactor);
    int xx = (x + w);
    if (x < 0) surface.DrawRectangle(0, 0, -x, surface.Height);
    if (xx >= xm) surface.DrawRectangle(xm - x, 0, xx - x, surface.Height);
    int ym = FloatToInt(IntToFloat(System.ViewportHeight) * this.ScaleFactor);
    int yy = (y + h);
    if (y < 0) surface.DrawRectangle(0, 0, surface.Width, -y);
    if (yy >= ym) surface.DrawRectangle(0, ym - y, surface.Width, yy - y);
    if ((x < 0) || (y < 0) || (xx >= xm) || (yy >= ym)) {
      surface.Release();
      sprite = DynamicSprite.CreateFromExistingSprite(this.Sprite, false);
      this.BackgroundSprite.CopyTransparencyMask(sprite.Graphic);
      surface = this.BackgroundSprite.GetDrawingSurface();
    }
  }
  surface.DrawImage(0, 0, this.Sprite);
  surface.Release();
  x = (this.X + this.XOffset);
  y = (this.Y + this.YOffset);
  int xx = (x + w);
  int yy = (y + h);
  if ((xx <= 0) || (yy <= 0) || (x >= System.ViewportWidth) || (y >= System.ViewportHeight)) {
    this.BackgroundSprite = null;
    this.AGSGUI.BackgroundGraphic = 0;
    this.AGSGUI.Width = 1;
    this.AGSGUI.Height = 1;
  }
  else {
    if ((x < 0) && (y < 0)) this.BackgroundSprite.Crop(-x, -y, this.BackgroundSprite.Width + x, this.BackgroundSprite.Height + y);
    else if (x < 0) this.BackgroundSprite.Crop(-x, 0, this.BackgroundSprite.Width + x, this.BackgroundSprite.Height);
    else if (y < 0) this.BackgroundSprite.Crop(0, -y, this.BackgroundSprite.Width, this.BackgroundSprite.Height + y);
    this.AGSGUI.BackgroundGraphic = this.BackgroundSprite.Graphic;
    this.AGSGUI.Width = this.BackgroundSprite.Width;
    this.AGSGUI.Height = this.BackgroundSprite.Height;
  }
  this.AGSGUI.Visible = true;
}

function repeatedly_execute() {
  Magnifier.Update();
}
 v  /*******************************************\

              AGS SCRIPT MODULE
                  MAGNIFIER
               by monkey_05_06

    -------------------------------------

 Description:
 
   The Magnifier module implements a "magnifying glass" style effect into your game
   to scale a specific section of the screen.

    -------------------------------------

 Dependencies:

  AGS v3.1.2+

    -------------------------------------

 Macros (#define-s):

  Magnifier_VERSION
    Defines the current version of the module, formatted as a float.

  Magnifier_VERSION_100
    Defines version 1.0 of the module.

    -------------------------------------

 Properties:

GUI* Magnifier.AGSGUI

  Gets/sets the AGS GUI used to display the magnifier effect. The GUI should not
  have any controls. The background will be set to reflect the magnified image of
  whatever is displayed behind it. This must be set before the effect may be
  enabled.

bool Magnifier.Enabled

  Gets/sets whether the magnifier effect is enabled, turning on Magnifier.AGSGUI,
  which shows the magnified image of whatever the mouse is over.

bool Magnifier.HideMouseCursor

  Gets/sets whether the mouse cursor should be hidden while the effect is enabled.

writeprotected int Magnifier.X

  Displays the X co-ordinate the magnifier effect is currently centering. This will
  be updated to reflect mouse.x and indicates the real X co-ordinate of the point
  displayed in the center of the effect.

int Magnifier.XOffset

  Gets/sets the X co-ordinate offset to position the effect as desired. This does
  not affect Magnifier.X, but rather just displaces the Magnifier.AGSGUI.

writeprotected int Magnifier.Y

  Displays the Y co-ordinate the magnifier effect is currently centering. This will
  be updated to reflect mouse.y and indicates the real Y co-ordinate of the point
  displayed in the center of the effect.

int Magnifier.YOffset

  Gets/sets the Y co-ordinate offset to position the effect as desired. This does
  not affect Magnifier.Y, but rather just displaces the Magnifier.AGSGUI.

int Magnifier.Sprite

  Gets/sets the sprite slot to use as the "magnifying glass" that will be displayed
  over the magnified background image. Supports alpha channeled images so you may
  have, for example, a slight blue tint over the magnified area. Note that at this
  time anti-aliasing on the outer edge of the "frame" will not work properly, you
  should only have any alpha information in the "lens" area.

float Magnifier.ScaleFactor

  Gets/sets the scaling factor for the magnifier effect. That is, a value of 2.0
  will display a portion of the background image the same size as Magnifier.Sprite
  centered around (Magnifier.X, Magnifier.Y) scaled to 200% or twice its normal
  size. Higher values are more system intensive so it is not recommended to set
  this value above 2.5. It is also possible to supply a value less than 1.0 to
  create a reversed effect, shrinking the displayed area instead of magnifying it.

    -------------------------------------

 Example:

  // inside of game_start
  Magnifier.AGSGUI = gMagnifier; // set the GUI we'll be using to display the effect
  Magnifier.Sprite = 11; // set the sprite to use as the "magnifying glass" drawn on top of the magnified area
  Magnifier.HideMouseCursor = true; // we don't need the mouse getting in the way
  Magnifier.ScaleFactor = 2.0; // we'll upscale the area to 2x normal size
  Magnifier.XOffset = -26; // and we'll offset the effect by half the width/height of our sprite
  Magnifier.YOffset = -26; // so it is displayed directly over the area it's magnifying

  // on_key_press
  if (keycode == 'M') Magnifier.Enabled = !Magnifier.Enabled; // toggle the effect when we press M

    -------------------------------------

 Changelog:

  Version:     1.0
  Author:      monkey_05_06
  Date:        April 2009
  Description: First public release.

    -------------------------------------

 Licensing:

  Permission is hereby granted, free of charge, to any person obtaining a  copy  of
  this script module and associated documentation files (the "Module"), to deal  in
  the Module  without  restriction, including without limitation the rights to use,
  copy, modify, merge, publish, distribute, sublicense, and/or sell copies  of  the
  Module, and to permit persons to whom the Module is furnished to do  so,  subject
  to the following conditions:

  The above copyright notice and this permission notice shall be  included  in  all
  copies or substantial portions of the Module.

  THE MODULE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF  MERCHANTABILITY,  FITNESS  FOR  A
  PARTICULAR PURPOSE  AND  NONINFRINGEMENT.  IN  NO  EVENT  SHALL  THE  AUTHORS  OR
  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR  IN  CONNECTION
  WITH THE MODULE OR THE USE OR OTHER DEALINGS IN THE MODULE.

\*******************************************/

#ifdef AGS_SUPPORTS_IFVER
  #ifver 3.1.2
    #define MAGNIFIER_VERSION 1.0
    #define MAGNIFIER_VERSION_100
  #endif
#endif
#ifndef MAGNIFIER_VERSION
  #error Magnifier module error!: This module requires AGS v3.1.2 or higher! Please upgrade to a higher version of AGS to use this module.
#endif

struct MagnifierType {
  ///Magnifier module: Gets/sets the AGS GUI used by the magnifier effect.
  GUI *AGSGUI;
  ///Magnifier module: Gets/sets whether the magnifier effect is currently enabled.
  bool Enabled;
  ///Magnifier module: Gets/sets whether the mouse cursor should be hidden when the magnifier effect is enabled.
  bool HideMouseCursor;
  ///Magnifier module: Gets the current X-coordinate for the magnifier effect.
  writeprotected int X;
  ///Magnifier module: Gets the current Y-coordinate for the magnifier effect.
  writeprotected int Y;
  ///Magnifier module: Gets/sets the X-coordinate offset for the magnifier effect.
  int XOffset;
  ///Magnifier module: Gets/sets the Y-coordinate offset for the magnifier effect.
  int YOffset;
  ///Magnifier module: Gets/sets the sprite slot to use as the "magnifying glass" for the magnifier effect.
  int Sprite;
  ///Magnifier module: Gets/sets the scaling factor for the magnifier effect.
  float ScaleFactor;
  ///Magnifier module: Gets the DynamicSprite used by our GUI.
  writeprotected DynamicSprite *BackgroundSprite;
  protected bool prevenabled;
  protected int prevmodesprite;
  protected bool prevhidemouse;
};

import MagnifierType Magnifier;
 u��        ej��