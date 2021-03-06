AGSScriptModule    SSH Describe the current hotspot/action, using Overlay or GUI. Some code based on Gilbert/Strazer's OverHot module Description 1.06 �  // Main script for module 'Description'

Descriptions Description;
export Description;


function Descriptions::OLTidy() {
  if (this.DisplayType==eDescDisplayOverlay && this.ol!=null &&
		  this.ol.Valid) {
    this.ol.Remove();
  }
}

function Descriptions::GUIMode(GUIControl *gc) {
  this.OLTidy();
  if (gc==null) { 
		Display("ERROR! null GUIControl passed to Description.GUIMode, contact game author");
		return -1;
  }		
  this.DisplayType=eDescDisplayGUIControl;
  this.gc=gc;
}

function Descriptions::OverlayMode() {
  this.DisplayType=eDescDisplayOverlay;
}

function Descriptions::StringOnly() {
  this.OLTidy();
  this.DisplayType=eDescDisplayNone;
}


protected function Descriptions::Update_String() {
  // Special case of busy cursor
  if ((mouse.Mode==this.NoDescriptionWhenMode) ||
			(this.NoDescriptionWhenNotMode>=0 && mouse.Mode!=this.NoDescriptionWhenNotMode) ||
		  (this.NoDescriptionWhenMode==eModeWait && IsInterfaceEnabled()==0)) { 
		this.Text=""; return;
	}
  String hs=Game.GetLocationName(mouse.x, mouse.y);
  if (this.IncludeInventory && InventoryItem.GetAtScreenXY(mouse.x, mouse.y)!=null) {
    InventoryItem *ii=InventoryItem.GetAtScreenXY(mouse.x, mouse.y);
    hs=ii.Name;
	}
#ifdef AGS_SUPPORTS_IFVER
	if (this.ButtonsWithFont>=0 && GUIControl.GetAtScreenXY(mouse.x, mouse.y)!=null) {
	  GUIControl *bb=GUIControl.GetAtScreenXY(mouse.x, mouse.y);
	  if (bb.AsButton!=null && bb.AsButton.Font==this.ButtonsWithFont) hs=bb.AsButton.Text;
	}
#endif
  String verb="";
  if (this.VerbMode==eDescVerbModeNever || (hs=="" && this.NoVerbOverNothing) ) {
		this.Text=hs;
		return;
  } else if (player.ActiveInventory!=null && mouse.Mode==eModeUseinv) {
    String ai=player.ActiveInventory.Name;
    if (this.VerbMode==eDescVerbModeUser && this.VerbS!=null) verb=this.VerbS;
    else verb=this.UseS;
    this.Text=String.Format("%s %s %s %s", verb, ai, this.PrepositionS, hs);
  } else if (this.VerbMode==eDescVerbModeUseOnly) {
		this.Text=hs;
		return;
  } else {
    if (this.VerbMode==eDescVerbModeAuto) {
      if (mouse.Mode==eModeLookat) verb=this.LookS;
      if (mouse.Mode==eModePickup) verb=this.GetS;
      if (mouse.Mode==eModeTalkto) verb=this.TalkS;
      if (mouse.Mode==eModeInteract) verb=this.UseS;
      if (mouse.Mode==eModeWalkto) verb=this.WalkS;
    } else if (this.VerbS!=null) verb=this.VerbS;
    
    this.Text=String.Format("%s %s", verb, hs);
	}
	if (this.NoDescriptionWhenNoVerb && verb=="") this.Text="";
}

protected function Descriptions::Update_Position(int font, int width) {
  if (this.Location==eDescLocationFollow || 
			(this.Location==eDescLocationSticky && this.Text!="" && this.Text != this.last)) {
		this.width=GetTextWidth(this.Text, font);
		this.height=GetTextHeight(this.Text, font, width);
		this.x = mouse.x + this.OffsetX;
    if (this.OLAlignment==eAlignCentre) this.x-=this.width/2;
    else if (this.OLAlignment==eAlignRight) this.x-=this.width;
		if ((this.x + this.width) > this.MaxX) this.x = this.MaxX - this.width;
		if (this.x < this.MinX) this.x = this.MinX;
		this.y = mouse.y + this.OffsetY;
		if ((this.y + this.height) > this.MaxY) this.y = this.MaxY - this.height;
		if (this.y < this.MinY) this.y = this.MinY;
	}
}

protected function Descriptions::Update_DS() {
  this.ds=DynamicSprite.Create(this.OLWidth, this.height);
  DrawingSurface *dsds=this.ds.GetDrawingSurface();
  dsds.DrawingColor=this.OLColor;
  dsds.DrawStringWrapped(0, 0, this.OLWidth, this.OLFont, eAlignLeft, this.Text);
  dsds.Release();
}

protected function Descriptions::Update_Overlay() {
  if (this.Text=="") {
    this.OLTidy();
  } else {
		this.Update_Position(this.OLFont, this.OLWidth);	
		if (this.ol!=null && this.ol.Valid) {
      if (this.OLSierraBG) {
        this.Update_DS();
        this.ol=Overlay.CreateGraphical(this.x, this.y, this.ds.Graphic, true);
      } else {
        this.ol.SetText(this.OLWidth, this.OLFont, this.OLColor, this.Text);
        this.ol.X = this.x; // so the position of the overlay will be adjusted every game loop
        this.ol.Y = this.y;
      }
		} else {
      if (this.OLSierraBG) {
        this.Update_DS();
        this.ol=Overlay.CreateGraphical(this.x, this.y, this.ds.Graphic, true);
      } else {
			  this.ol=Overlay.CreateTextual(this.x, this.y, this.OLWidth, this.OLFont, this.OLColor, this.Text);
      }
		}  
	}
}      

protected function Descriptions::Update_GUI() {
	int font;
	if (this.gc.AsLabel!=null) font=this.gc.AsLabel.Font;
#ifdef AGS_SUPPORTS_IFVER
	else if (this.gc.AsButton!=null) font=this.gc.AsButton.Font;
#endif
	
	if (this.CropGUIToo) this.Update_Position(font, this.MaxX-this.MinX);
	else this.Update_Position(font, this.gc.OwningGUI.Width);

	if (this.Location!=eDescLocationStatic) {
		this.gc.OwningGUI.X=this.x;
		this.gc.OwningGUI.Y=this.y;
		this.gc.Width=this.width+1;
		if (this.CropGUIToo) this.gc.OwningGUI.Width=this.width+2;
	}	
  if (this.gc.AsLabel!=null) this.gc.AsLabel.Text=this.Text;
  else if (this.gc.AsButton!=null) this.gc.AsButton.Text=this.Text;
  
  // Fade control
	if ((this.Text=="") && (this.gc.OwningGUI.Visible) && (this.alpha<this.FadeStart)) {
    this.alpha+=this.FadeOutSpeed;
    if (this.alpha>=this.FadeStart) this.gc.OwningGUI.Visible=false;
  } else if (this.Text!="") {
    if (!this.gc.OwningGUI.Visible) {
      this.gc.OwningGUI.Visible=true;
      this.alpha=this.FadeStart;
    } else if (this.alpha>this.FadeEnd) {
      this.alpha-=this.FadeInSpeed;
    }
	}
	if (this.alpha>100) this.alpha=100;
	else if (this.alpha<0) this.alpha=0;
	this.gc.OwningGUI.Transparency=this.alpha;
}
  
function Descriptions::rep_ex() {
  this.last=this.Text;
  this.Update_String();
  if (this.DisplayType==eDescDisplayGUIControl) {
    this.Update_GUI();
  } else if (this.DisplayType==eDescDisplayOverlay) {
		this.Update_Overlay();
	}
}


function repeatedly_execute_always() {
  // Should this go in rep_ex_always?
  // easy enough for user to change, if required
  Description.rep_ex();
}

function on_event(EventType event, int data) {
  if (event==eEventLeaveRoom) Description.OLTidy();
}

function game_start() {
  // Set up defaults
  Description.LookS="Look at";
  Description.GetS="Get";
  Description.UseS="Use";
  Description.PrepositionS="on";
  Description.TalkS="Talk to";
  Description.WalkS="Walk to";
  Description.IncludeInventory=true;
  Description.NoVerbOverNothing=true;
  Description.OLWidth=100;
  Description.OLAlignment=eAlignLeft;
  Description.FadeStart=100;
  Description.FadeEnd=0;
  Description.FadeInSpeed=20;
  Description.FadeOutSpeed=5;
  Description.OffsetX=-16;
  Description.OffsetY=16;
  Description.MinX=0;
  Description.MinY=0;
  Description.MaxX=system.viewport_width-1;
  Description.MaxY=system.viewport_height-1;
  // Default to Overlay mode
  Description.OLColor=65000;
  Description.ButtonsWithFont=-1;
  Description.NoDescriptionWhenMode=-1;
  Description.NoDescriptionWhenNotMode=-1;
  Description.OverlayMode();
}
 �&  // Script header for module 'Description'
//
// Author: Andrew MacCormack (SSH)
//   Please use the PM function on the AGS forums to contact
//   me about problems with this module
// 
// Abstract: Provides descriptions of the current thing the mouse is over
// Dependencies:
//
//   AGS 2.71 or later
//
// Functions:
//
//  Description.OverlayMode();
//		Set the module to use an overlay to display text
//
//  Description.GUIMode(GUIControl *gc);
//    Set the module to use the specified GUI Control (button or label) to
//    display text
//
//  Description.StringOnly(); 
//  	Default: do not display text, but rather just set the Description.Text 
//    variable with the right value, for the user to play with. This can also be
//    used as an "off" mode.
//
// Configuration:
//
//  There are various variables used to configure how the module behaves:
//
// 	 Description.VerbMode
//		This is an enumerated setting that controls which text is displayed:
//												Using Inv Item				Normal
//		eDescVerbModeNever	@HS@									@HS@
// 	eDescVerbModeUseOnly  Use @AI@ on @HS@			@HS@
//	   eDescVerbModeAuto  Use @AI@ on @HS@			AutoVerb @HS@
// 		 eDescVerbModeUser  Use @AI@ on @HS@			VerbS @HS@
//
//    where @HS@ is the location name, and @AI@ is the active inventory name
//    "Use" is the content of the Description.UseS string, "on" is the content of
//    Description.PrepositionS, and "VerbS" is the content of the 
//		Description.VerbS string. "AutoVerb" is set by the following mapping:
//											Mouse mode						AutoVerb value
//												eModeLookat						Description.LookS
//												eModePickup						Description.GetS
//												eModeTalkto						Description.TalkS
//												eModeInteract					Description.UseS
//												eModeWalkto						Description.WalkS
//
//   
//   Description.Location
//    Another enumerated setting:
//			eDescLocationStatic
//				GUI stays in one place, like FoA or Monkey Island (not supported for
//				Overlays)
//			eDescLocationFollow
//				Text follows the mouse cursor around
// 			eDescLocationSticky
//        When mouse goes over location, Text appears by mouse, but does not 
//				move until mouse leaves location.
//
//	 Description.IncludeInventory
//		Boolean value: if true (default) then Inventory items count as locations
//		to be displayed, if false, they do not.
//
//   Description.ButtonsWithFont
//    Integer: if <0, ignore GUI buttons, otehrwise if buttons use the font
//    specified (e.g. an invisible one) then use the Text as tooltip.
//
//   Description.NoVerbOverNothing
//    Boolean: if false, displays the verb even if not over a location. If true
// 		(default) then displays nothing. Do not set to false in Sticky mode, as
//    it makes it look a mess.
//
//   Description.NoDescriptionWhenNoVerb
//    Boolean: if true, turns off Description when the AutoVerb or VerbS is empty.
//    if false, always displays description (default). This setting is ignored in 
//    Never and UseOnly verb modes.
//
//   Description.NoDescriptionWhenMode
//    Mouse mode: when mouse is in this mode (e.g. pointer) turn off the Description.
//    default is -1 (always show description)
//
//   Description.NoDescriptionWhenNotMode
//    Mouse mode: only when mouse is in this mode (e.g. look) turn on the Description.
//    default is -1 (always show description)
//
//   Description.OffsetX/Y
//    Integers that descibe the X/Y offset from mouse cursor to display the
//    text in Follow or Sticky mode
//
//   Description.Max/MinX/Y
//    4 numbers setting the outside bounds of where the text is allowed to be
//		displayed. Defaults to the screen edges.
//
//	 Description.CropGUIToo
//		Boolean, defaulting false. Normally Follow and Sticky mode trim the GUI
//    Control specified (in GUI mode) to the width of the text. Setting this
//    will crop the GUI, too.
//
//   Description.FadeStart/End/InSpeed/OutSpeed
//     Control the fading in/out of a GUI. Start and End specify the initial and
//     final transparency values for fading in, and the speeds specify the 
//		 change per cycle when fading in or out
//
//	 Description.OLFont/Width/Color
//     Specify the properties of the Overlay using in Overlay mode. For GUIs, 
//     they are picked up from the GUI settings
//
//   Description.OLAlignment
//     Sets the alignment of text in an overlay (GUI labels already have this
//     controllable), default is left-aligned
//
//   Description.OLSierraBG
//     Set this to true if you are using overlays and Sierra with Background 
//     style speech to avoid a white background, because the module cannot
//     detect if you are using this mode.
//
// Example:
//
// function game_start() // called when the game starts, before the first room is loaded
//  {
//    Description.Location=eDescLocationSticky;
//    Description.VerbMode=eDescVerbModeUseOnly;
//    Description.OLColor=65000;
//    Description.OverlayMode();
//  }
//
// Caveats:
//
//   Cannot use a GUI button for description in 2.71
//   Haven't tried ALL the combinations of settings yet!
//
// Revision History:
//
// 28 Apr 06: v1.0  First release of Description module
//  1 May 06: v1.01 Made 2.71 compatible and default to be more like OverHot
// 11 May 06: v1.02 Added ButtonsWithFont and fixed some bugs
// 11 Sep 06: v1.03 Added options to turn off Description automatically sometimes
// 28 Aug 07: v1.04 Added WhenNotMode, special case for Busy cursor, overlay x,y
// 28 Aug 07: v1.05 Tried to fix GUIs going out of bounds
//  8 Jul 08: v1.06 Added alignment for overlays and fix for SierraBG mode
//
// Licence:
//
//   Description AGS script module
//   Copyright (C) 2006, 2007, 2008 Andrew MacCormack
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to 
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.

enum DescriptionLocation {eDescLocationStatic, eDescLocationSticky, eDescLocationFollow};
enum DescriptionDisplayType {eDescDisplayNone, eDescDisplayGUIControl, eDescDisplayOverlay};
enum DescriptionVerbMode {eDescVerbModeNever, eDescVerbModeUseOnly, 
	eDescVerbModeAuto, eDescVerbModeUser };

struct Descriptions {
  import function OverlayMode(); // set to use overlay
  import function GUIMode(GUIControl *gc); // set to use GUI
  import function StringOnly(); // no display
  DescriptionVerbMode VerbMode; // how the text is formatted
  DescriptionLocation Location; // where to move the ol/gui to
  
  writeprotected String Text;   // The current value being used

	// Config
  String UseS;          // Default "Use"
  String PrepositionS;  // Default "on" (or "with"?)
  String TalkS;         // Default "Talk to"
  String GetS;          // Default "Get"
  String LookS;         // Default "Look at"
  String WalkS;         // Default "Walk to"
  String VerbS;         // User defined verb string
 
  bool IncludeInventory;// Should custom inv items also work? (default true)
	int ButtonsWithFont;  // Descriptions on GUI buttons with font N 
  bool NoDescriptionWhenNoVerb; // If verb is blank, don't display anything
  CursorMode NoDescriptionWhenMode; // if mouse in this mode, no description
  CursorMode NoDescriptionWhenNotMode; // only show description when in this mode
  
  // Follow and Static only:
  bool NoVerbOverNothing; // Don't have any text if not over something (default true)
  int x; // Set x/y pos of overlay in Static mode
  int y;
  
  // Follow and Sticky only:
  int OffsetX;  // relative to mouse
  int OffsetY;
  int MinX;     // min/max bounds
  int MinY;
  int MaxX;
  int MaxY;

  // GUI only:
  bool CropGUIToo; // set width of GUI as well as GUIControl (default false)
  int FadeStart; // (max) transparency when first at location
  int FadeEnd;   // (min) transparency after on location a while
  int FadeInSpeed; // value to change transparency by, per cycle
  int FadeOutSpeed; // value to change transparency by, per cycle
  
  // OL only:
  int OLFont;
  int OLWidth;
  int OLColor;
  Alignment OLAlignment;
  bool OLSierraBG;
  
  // Internal
  import function rep_ex(); // $AUTOCOMPLETEIGNORE$
  import function OLTidy(); // $AUTOCOMPLETEIGNORE$
  protected DescriptionDisplayType DisplayType; //gui, ol or none
  protected GUIControl *gc;
  protected Overlay *ol;
  protected DynamicSprite *ds; // Workaround for Sierra with BG mode
  protected String last;
  protected int alpha;
  protected int width;
  protected int height;
  protected import function Update_Position(int font, int width);
  protected import function Update_String();
  protected import function Update_GUI();
  protected import function Update_Overlay();
  protected import function Update_DS();
};
 
  
import Descriptions Description;
 ���        ej��