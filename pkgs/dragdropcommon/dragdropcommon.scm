AGSScriptModule    Ivan Mogilko Drag built-in AGS objects with mouse DragDropCommon 1.0.0 ;N  
#ifdef ENABLE_MOUSE_DRAGDROPCOMMON

// General settings
struct DragDropSettings
{
  bool ModeEnabled[NUM_DRAGDROPCOMMON_MODES]; // is particular mode enabled
  bool PixelPerfect;        // pixel-perfect hit mode for AGS objects
  bool TestClickable;       // test Clickable property for AGS objects
  DragDropCommonMove Move;  // whether object is dragged itself, or overlay with object's image on it
  int  GhostTransparency;   // transparency value of the overlay
  bool GhostAlpha;          // keep alpha channel when creating translucent overlays
  GUI* GhostGUI;            // GUI to use for dragged object representation
};

DragDropSettings DDSet;

// Current drag'n'drop state
struct DragDropState
{
  Character*    _Character;     // dragged character
  GUI*          _GUI;           // dragged GUI
  GUIControl*   _GUIControl;    // dragged GUIControl
  Object*       _Object;        // dragged room object
  InventoryItem* _Item;         // dragged inventory item
  DragDropCommonMove Move;      // current move style
  int           GhostGraphic;   // an image which represents dragged object
  DynamicSprite* GhostDspr;     // dynamic sprite which represents dragged object
  Overlay*      GhostOverlay;   // an overlay which represents dragged object
  GUI*          GhostGUI;       // a GUI which is currently used to represent dragged object
  int           OverlayOffX;    // overlay position offset (relative to object coords)
  int           OverlayOffY;
  bool          PostCleanup;    // extra tick has passed in the last step (workaround for overriding script modules)
};

DragDropState DDState;

//===========================================================================
//
// DragDropState::CreateRepresentation()
// Creates a graphical representation of an object for dragging around.
//
//===========================================================================
int CreateRepresentation(this DragDropState*, DragDropCommonMove move, int x, int y, int offx, int offy,
                         int slot, int trans, bool has_alpha)
{
  this.GhostGraphic = slot;
  if (move != eDDCmnMoveGhostGUI &&
      trans != 100 && trans != 0)
  {
    DynamicSprite* spr = DynamicSprite.Create(Game.SpriteWidth[slot], Game.SpriteHeight[slot], has_alpha);
    DrawingSurface* ds = spr.GetDrawingSurface();
    ds.DrawImage(0, 0, slot, trans);
    ds.Release();
    this.GhostDspr = spr;
    slot = spr.Graphic;
  }
  this.OverlayOffX = offx;
  this.OverlayOffY = offy;
  if (move == eDDCmnMoveGhostOverlay)
  {
    this.GhostOverlay = Overlay.CreateGraphical(x + offx, y + offy, slot, true);
  }
  else
  {
    this.GhostGUI = DDSet.GhostGUI;
    this.GhostGUI.BackgroundGraphic = slot;
    this.GhostGUI.Transparency = trans;
    this.GhostGUI.X = x + offx;
    this.GhostGUI.Y = y + offy;
    this.GhostGUI.Width = Game.SpriteWidth[slot];
    this.GhostGUI.Height = Game.SpriteHeight[slot];
    this.GhostGUI.ZOrder = 1000; // max zorder, according to the manual
    this.GhostGUI.Visible = true;
  }
  this.Move = move;
}

//===========================================================================
//
// DragDropState::RemoveRepresentation()
// Removes ghost overlay (if there was one)
//
//===========================================================================
void RemoveRepresentation(this DragDropState*)
{
  if (this.GhostOverlay != null && this.GhostOverlay.Valid)
    this.GhostOverlay.Remove();
  this.GhostOverlay = null;
  if (this.GhostGUI != null)
  {
    this.GhostGUI.BackgroundGraphic = 0;
    this.GhostGUI.Visible = false;
  }
  this.GhostGUI = null;
  if (this.GhostDspr != null)
    this.GhostDspr.Delete();
  this.GhostDspr = null;
  this.GhostGraphic = 0;
  this.OverlayOffX = 0;
  this.OverlayOffY = 0;
}

//===========================================================================
//
// DragDropState::ResetState()
// Resets state description to "idle".
//
//===========================================================================
void Reset(this DragDropState*)
{
  this._Character = null;
  this._GUI = null;
  this._GUIControl = null;
  this._Object = null;
  this._Item = null;
  this.RemoveRepresentation();
  this.PostCleanup = false;
}

//===========================================================================
//
// DragDropCommon::TryHookCharacter()
//
//===========================================================================
static bool DragDropCommon::TryHookCharacter()
{
  if (!DragDrop.EvtWantObject)
    return false;
    
  int was_pp = GetGameOption(OPT_PIXELPERFECT);
  SetGameOption(OPT_PIXELPERFECT, DDSet.PixelPerfect);
  Character *c = Character.GetAtScreenXY(DragDrop.DragStartX, DragDrop.DragStartY);
  SetGameOption(OPT_PIXELPERFECT, was_pp);
  if (c == null)
    return false;
  if (DDSet.TestClickable && !c.Clickable)
    return false;
  DDState._Character = c;
  DragDrop.HookObject(eDragDropCharacter, c.x, c.y);
  if (DDSet.Move != eDDCmnMoveSelf)
  {
    int sprite;
    ViewFrame* vf = Game.GetViewFrame(c.View, c.Loop, c.Frame);
    if (vf != null)
      sprite = vf.Graphic;
    DDState.CreateRepresentation(DDSet.Move, c.x, c.y, 0, -Game.SpriteHeight[sprite], sprite,
                                 DDSet.GhostTransparency, DDSet.GhostAlpha);
  }
  return true;
}

//===========================================================================
//
// DragDropCommon::TryHookGUI()
//
//===========================================================================
static bool DragDropCommon::TryHookGUI()
{
  if (!DragDrop.EvtWantObject)
    return false;
  // TODO: pixel perfect detection
  GUI *g = GUI.GetAtScreenXY(DragDrop.DragStartX, DragDrop.DragStartY);
  if (g == null)
    return false;
  if (DDSet.TestClickable && !g.Clickable)
    return false;
  DDState._GUI = g;
  DragDrop.HookObject(eDragDropGUI, g.X, g.Y);
  return true;
}

//===========================================================================
//
// DragDropCommon::TryHookGUIControl()
//
//===========================================================================
static bool DragDropCommon::TryHookGUIControl()
{
  if (!DragDrop.EvtWantObject)
    return false;
  GUIControl *gc;
  // TODO: pixel perfect detection
  gc = GUIControl.GetAtScreenXY(DragDrop.DragStartX, DragDrop.DragStartY);
  if (gc == null)
    return false;
  if (DDSet.TestClickable && !gc.Clickable)
    return false;
  DDState._GUIControl = gc;
  DragDrop.HookObject(eDragDropGUIControl, gc.X, gc.Y);
  return true;
}

//===========================================================================
//
// DragDropCommon::TryHookRoomObject()
//
//===========================================================================
static bool DragDropCommon::TryHookRoomObject()
{
  if (!DragDrop.EvtWantObject)
    return false;
  int was_pp = GetGameOption(OPT_PIXELPERFECT);
  SetGameOption(OPT_PIXELPERFECT, DDSet.PixelPerfect);
  Object *o = Object.GetAtScreenXY(DragDrop.DragStartX, DragDrop.DragStartY);
  SetGameOption(OPT_PIXELPERFECT, was_pp);
  if (o == null)
    return false;
  if (DDSet.TestClickable && !o.Clickable)
    return false;
  DDState._Object = o;
  DragDrop.HookObject(eDragDropRoomObject, o.X, o.Y);
  if (DDSet.Move != eDDCmnMoveSelf)
  {
    int sprite;
    if (o.View != 0)
    {
      ViewFrame* vf = Game.GetViewFrame(o.View, o.Loop, o.Frame);
      if (vf != null)
        sprite = vf.Graphic;
    }
    else
    {
      sprite = o.Graphic;
    }
    DDState.CreateRepresentation(DDSet.Move, o.X, o.Y, 0, -Game.SpriteHeight[sprite], sprite,
                                 DDSet.GhostTransparency, DDSet.GhostAlpha);
  }
  return true;
}

//===========================================================================
//
// DragDropCommon::TryHookInventoryItem()
//
//===========================================================================
static bool DragDropCommon::TryHookInventoryItem()
{
  if (!DragDrop.EvtWantObject)
    return false;
  // TODO: pixel perfect detection
  InventoryItem* i = InventoryItem.GetAtScreenXY(DragDrop.DragStartX, DragDrop.DragStartY);
  if (i == null)
    return false;
  DDState._Item = i;
  GUIControl* gc = InvWindow.GetAtScreenXY(DragDrop.DragStartX, DragDrop.DragStartY);
  InvWindow* wnd = gc.AsInvWindow;
  int i_x = DragDrop.DragStartX - (DragDrop.DragStartX - wnd.OwningGUI.X - wnd.X) % wnd.ItemWidth;
  int i_y = DragDrop.DragStartY - (DragDrop.DragStartY - wnd.OwningGUI.Y - wnd.Y) % wnd.ItemHeight;
  DragDrop.HookObject(eDragDropInvItem, i_x, i_y);
  int sprite = i.Graphic;
  DDState.CreateRepresentation(DDSet.Move, i_x, i_y, 0, 0, sprite,
                                 DDSet.GhostTransparency, DDSet.GhostAlpha);
  return true;
}

//===========================================================================
//
// DragDropCommon::TryHookDraggableObject()
// Looks for an applicable object under the mouse cursor position, assigns drag data.
// Returns 'true' if a drag object was found successfully.
//
//===========================================================================
static bool DragDropCommon::TryHookDraggableObject()
{
  if (!DragDrop.EvtWantObject)
    return false;

  bool result;
  if (DDSet.ModeEnabled[eDragDropCharacter])
    result = DragDropCommon.TryHookCharacter();
  if (!result && DDSet.ModeEnabled[eDragDropGUI])
    result = DragDropCommon.TryHookGUI();
  if (!result && DDSet.ModeEnabled[eDragDropGUIControl])
    result = DragDropCommon.TryHookGUIControl();
  if (!result && DDSet.ModeEnabled[eDragDropRoomObject])
    result = DragDropCommon.TryHookRoomObject();
  if (!result && DDSet.ModeEnabled[eDragDropInvItem])
    result = DragDropCommon.TryHookInventoryItem();
  return result;
}

//===========================================================================
//
// DragDropCommon::ModeEnabled[] property
//
//===========================================================================
bool geti_ModeEnabled(this DragDropCommon*, int index)
{
  if (index >= 0 && index < NUM_DRAGDROPCOMMON_MODES)
    return DDSet.ModeEnabled[index];
  return false;
}

void seti_ModeEnabled(this DragDropCommon*, int index, bool value)
{
  if (index >= 0 && index < NUM_DRAGDROPCOMMON_MODES)
  {
    if (!value && DragDrop.CurrentMode == index)
      DragDrop.Revert();
    DDSet.ModeEnabled[index] = value;
  }
}

//===========================================================================
//
// DragDropCommon::DisableAllModes()
//
//===========================================================================

static void DragDropCommon::DisableAllModes()
{
  int i = 0;
  while (i < NUM_DRAGDROPCOMMON_MODES)
  {
    if (DragDrop.CurrentMode == i)
      DragDrop.Revert();
    DDSet.ModeEnabled[i] = false;
    i++;
  }
}

//===========================================================================
//
// DragDropCommon::PixelPerfect property
//
//===========================================================================
bool get_PixelPerfect(this DragDropCommon*)
{
  return DDSet.PixelPerfect;
}

void set_PixelPerfect(this DragDropCommon*, bool value)
{
  DDSet.PixelPerfect = value;
}

//===========================================================================
//
// DragDropCommon::TestClickable property
//
//===========================================================================
bool get_TestClickable(this DragDropCommon*)
{
  return DDSet.TestClickable;
}

void set_TestClickable(this DragDropCommon*, bool value)
{
  DDSet.TestClickable = value;
}

//===========================================================================
//
// DragDropCommon::DragMove property
//
//===========================================================================
DragDropCommonMove get_DragMove(this DragDropCommon*)
{
  return DDSet.Move;
}

void set_DragMove(this DragDropCommon*, DragDropCommonMove value)
{
  DDSet.Move = value;
}

//===========================================================================
//
// DragDropCommon::GhostTransparency property
//
//===========================================================================
int get_GhostTransparency(this DragDropCommon*)
{
  return DDSet.GhostTransparency;
}

void set_GhostTransparency(this DragDropCommon*, int value)
{
  DDSet.GhostTransparency = value;
}

//===========================================================================
//
// DragDropCommon::GhostAlpha property
//
//===========================================================================
bool get_GhostAlpha(this DragDropCommon*)
{
  return DDSet.GhostAlpha;
}

void set_GhostAlpha(this DragDropCommon*, bool value)
{
  DDSet.GhostAlpha = value;
}

//===========================================================================
//
// DragDropCommon::GhostGUI property
//
//===========================================================================
GUI* get_GhostGUI(this DragDropCommon*)
{
  return DDSet.GhostGUI;
}

void set_GhostGUI(this DragDropCommon*, GUI* value)
{
  DDSet.GhostGUI = value;
}

//===========================================================================
//
// DragDropCommon::_Character property
//
//===========================================================================
Character* get__Character(this DragDropCommon*)
{
  return DDState._Character;
}

//===========================================================================
//
// DragDropCommon::_GUI property
//
//===========================================================================
GUI* get__GUI(this DragDropCommon*)
{
  return DDState._GUI;
}

//===========================================================================
//
// DragDropCommon::_GUIControl property
//
//===========================================================================
GUIControl* get__GUIControl(this DragDropCommon*)
{
  return DDState._GUIControl;
}

//===========================================================================
//
// DragDropCommon::_RoomObject property
//
//===========================================================================
Object* get__RoomObject(this DragDropCommon*)
{
  return DDState._Object;
}

//===========================================================================
//
// DragDropCommon::_InvItem property
//
//===========================================================================
InventoryItem* get__InvItem(this DragDropCommon*)
{
  return DDState._Item;
}

//===========================================================================
//
// DragDropCommon::ObjectWidth property
//
//===========================================================================
int get_ObjectWidth(this DragDropCommon*)
{
  if (DDState.GhostOverlay != null)
  {
    return Game.SpriteWidth[DDState.GhostGraphic];
  }
  else if (DragDrop.CurrentMode == eDragDropCharacter)
  {
    Character* c = DDState._Character;
    ViewFrame* vf = Game.GetViewFrame(c.View, c.Loop, c.Frame);
    if (vf != null)
      return Game.SpriteWidth[vf.Graphic];
  }
  else if (DragDrop.CurrentMode == eDragDropGUI)
  {
    return DDState._GUI.Width;
  }
  else if (DragDrop.CurrentMode == eDragDropGUIControl)
  {
    return DDState._GUIControl.Width;
  }
  else if (DragDrop.CurrentMode == eDragDropRoomObject)
  {
    Object* o = DDState._Object;
    if (o.View != 0)
    {
      ViewFrame* vf = Game.GetViewFrame(o.View, o.Loop, o.Frame);
      if (vf != null)
        return Game.SpriteWidth[vf.Graphic];
    }
    return Game.SpriteWidth[o.Graphic];
  }
  else if (DragDrop.CurrentMode == eDragDropInvItem)
  {
    return Game.SpriteWidth[DDState._Item.Graphic];
  }
  return 0;
}

//===========================================================================
//
// DragDropCommon::ObjectHeight property
//
//===========================================================================
int get_ObjectHeight(this DragDropCommon*)
{
  if (DDState.GhostOverlay != null)
  {
    return Game.SpriteHeight[DDState.GhostGraphic];
  }
  else if (DragDrop.CurrentMode == eDragDropCharacter)
  {
    Character* c = DDState._Character;
    ViewFrame* vf = Game.GetViewFrame(c.View, c.Loop, c.Frame);
    if (vf != null)
      return Game.SpriteHeight[vf.Graphic];
  }
  else if (DragDrop.CurrentMode == eDragDropGUI)
  {
    return DDState._GUI.Height;
  }
  else if (DragDrop.CurrentMode == eDragDropGUIControl)
  {
    return DDState._GUIControl.Height;
  }
  else if (DragDrop.CurrentMode == eDragDropRoomObject)
  {
    Object* o = DDState._Object;
    if (o.View != 0)
    {
      ViewFrame* vf = Game.GetViewFrame(o.View, o.Loop, o.Frame);
      if (vf != null)
        return Game.SpriteHeight[vf.Graphic];
    }
    return Game.SpriteHeight[o.Graphic];
  }
  else if (DragDrop.CurrentMode == eDragDropInvItem)
  {
    return Game.SpriteHeight[DDState._Item.Graphic];
  }
  return 0;
}

//===========================================================================
//
// DragDropCommon::UsedGhostGraphic property
//
//===========================================================================
int get_UsedGhostGraphic(this DragDropCommon*)
{
  return DDState.GhostGraphic;
}

//===========================================================================
//
// DragDropState::Drag()
// Updates dragging move.
//
//===========================================================================
void Drag(this DragDropState*)
{
  if (this.GhostOverlay != null)
  {
    this.GhostOverlay.X = DragDrop.ObjectX + this.OverlayOffX;
    this.GhostOverlay.Y = DragDrop.ObjectY + this.OverlayOffY;
  }
  else if (this.GhostGUI != null)
  {
    this.GhostGUI.X = DragDrop.ObjectX + this.OverlayOffX;
    this.GhostGUI.Y = DragDrop.ObjectY + this.OverlayOffY;
  }
  else if (DragDrop.CurrentMode == eDragDropCharacter)
  {
    this._Character.x = DragDrop.ObjectX;
    this._Character.y = DragDrop.ObjectY;
  }
  else if (DragDrop.CurrentMode == eDragDropGUI)
  {
    this._GUI.X = DragDrop.ObjectX;
    this._GUI.Y = DragDrop.ObjectY;
  }
  else if (DragDrop.CurrentMode == eDragDropGUIControl)
  {
    this._GUIControl.X = DragDrop.ObjectX;
    this._GUIControl.Y = DragDrop.ObjectY;
  }
  else if (DragDrop.CurrentMode == eDragDropRoomObject)
  {
    this._Object.X = DragDrop.ObjectX;
    this._Object.Y = DragDrop.ObjectY;
  }
}


//===========================================================================
//
// game_start()
// Initializing DragDrop.
//
//===========================================================================
function game_start()
{
  DDState.Reset();
}

//===========================================================================
//
// repeatedly_execute_always()
// Handling DragDrop events.
//
//===========================================================================
function repeatedly_execute_always()
{
  if (!DragDrop.Enabled)
    return;
    
  if (DDState.PostCleanup)
  {
    DDState.Reset();
  }
  
  // When DragDrop wants a draggable object, try to find one, taking currently enabled modes into account
  if (DragDrop.EvtWantObject)
  {
    DragDropCommon.TryHookDraggableObject();
  }
  // When DragDrop is dragging, and the mode is one we handle, move the object along with the cursor
  else if (DragDrop.IsDragging)
  {
    DDState.Drag();
  }
  // When DragDrop dropped (or reverted) the object, update its location just one final time, and reset our drag data
  else if (DragDrop.EvtDropped)
  {
    DDState.RemoveRepresentation();
    DDState.Drag();
    DDState.PostCleanup = true;
  }
}

#endif  // ENABLE_MOUSE_DRAGDROPCOMMON
 /  // DragDropCommon is open source under the MIT License.
//
// TERMS OF USE - DragDropCommon MODULE
//
// Copyright (c) 2016-present Ivan Mogilko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef __MOUSE_DRAGDROPCOMMON_MODULE__
#define __MOUSE_DRAGDROPCOMMON_MODULE__

#ifndef __MOUSE_DRAGDROP_MODULE__
#error DragDropCommon requires DragDrop module
#endif

#define MOUSE_DRAGDROPCOMMON_VERSION_00_01_00_00

// Comment this line out to completely disable DragDropCommon during compilation
#define ENABLE_MOUSE_DRAGDROPCOMMON

#ifdef ENABLE_MOUSE_DRAGDROPCOMMON

enum DragDropCommonMode
{
  eDragDropCharacter = 1, 
  eDragDropGUI, 
  eDragDropGUIControl,
  eDragDropRoomObject, 
  eDragDropInvItem, 
  NUM_DRAGDROPCOMMON_MODES
};

// DragDropCommonMove enumeration determines the way hooked object is being dragged around
enum DragDropCommonMove
{
  // drag actual object itself (position updates real-time)
  eDDCmnMoveSelf,
  // drag overlay with object's image, while object stays in place until drag ends;
  // this currently works only for characters and room objects!
  eDDCmnMoveGhostOverlay, 
  // drag GUI with object's image; this is currently only way to drag inventory items
  eDDCmnMoveGhostGUI
};

struct DragDropCommon
{
  ///////////////////////////////////////////////////////////////////////////
  //
  // Setting up
  // ------------------------------------------------------------------------
  // Functions and properties meant to configure the drag'n'drop behavior.
  //
  ///////////////////////////////////////////////////////////////////////////
  
  /// Get/set whether particular drag'n'drop mode is enabled
  import static attribute bool  ModeEnabled[];
  /// Disable drag'n'drop for all the modes
  import static void            DisableAllModes();
  
  /// Get/set whether click on AGS object should be tested using pixel-perfect detection
  /// (alternatively only hit inside bounding rectangle is tested)
  import static attribute bool  PixelPerfect;
  /// Get/set whether only Clickable AGS objects should be draggable
  import static attribute bool  TestClickable;
  
  /// Get/set the way object's drag around is represented
  import static attribute DragDropCommonMove DragMove;
  /// Get/set transparency of a representation used when DragStyle is NOT eDragDropMoveSelf
  import static attribute int   GhostTransparency;
  /// Get/set whether representation should keep sprite's alpha channel
  import static attribute bool  GhostAlpha;
  /// Get/set the GUI used to represent dragged object
  import static attribute GUI*  GhostGUI;
  
  
  ///////////////////////////////////////////////////////////////////////////
  //
  // State control
  // ------------------------------------------------------------------------
  // Properties and functions meant to tell about current drag'n'drop process
  // and control its state.
  //
  ///////////////////////////////////////////////////////////////////////////
  
  /// Gets current dragged character
  readonly import static attribute Character*   _Character;
  /// Gets current dragged GUI
  readonly import static attribute GUI*         _GUI;
  /// Gets current dragged GUIControl
  readonly import static attribute GUIControl*  _GUIControl;
  /// Gets current dragged room Object
  readonly import static attribute Object*      _RoomObject;
  /// Gets current dragged Inventory Item
  readonly import static attribute InventoryItem* _InvItem;
  /// Gets current dragged object's or its representation width
  readonly import static attribute int          ObjectWidth;
  /// Gets current dragged object's or its representation height
  readonly import static attribute int          ObjectHeight;
  /// Gets current dragged overlay's graphic (only if drag style is NOT eDragDropMoveSelf)
  readonly import static attribute int          UsedGhostGraphic;
  
  /// Start dragging a character under cursor
  import static bool  TryHookCharacter();
  /// Start dragging a GUI under cursor
  import static bool  TryHookGUI();
  /// Start dragging a GUI Control under cursor
  import static bool  TryHookGUIControl();
  /// Start dragging a room Object under cursor
  import static bool  TryHookRoomObject();
  /// Start dragging an Inventory Item under cursor
  import static bool  TryHookInventoryItem();
  /// Try to find an applicable object to drag under cursor, based on currently enabled modes
  import static bool  TryHookDraggableObject();
};

#endif  // ENABLE_MOUSE_DRAGDROPCOMMON

#endif  // __MOUSE_DRAGDROPCOMMON_MODULE__
 �U'        ej��