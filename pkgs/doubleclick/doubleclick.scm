AGSScriptModule    Ivan Mogilko Detects double mouse clicks Double Click 1.0.0 �  // Size of the mouse button records array
#define TOP_REF_MOUSE_BTN  4

struct DoubleClickImpl
{
  int Timeout;  // delay between two clicks that lets to count them as one sequence
  
  int  MBtn;             // a mouse button being sequenced right now
  int  Taps;             // number of sequential clicks
  bool DblClick;         // the button was just double-clicked
};

DoubleClickImpl DblClk;

// Individual mouse button state record
struct MBtnRecord
{
  bool      IsDown;           // is being held
  bool      StateJustChanged; // just pushed or released
  int       StateTimer;       // current state time
};

MBtnRecord  MBtnRec[TOP_REF_MOUSE_BTN];

//===========================================================================
//
// DoubleClick::Timeout property
//
//===========================================================================
int get_Timeout(this DoubleClick*)
{
  return DblClk.Timeout;
}

void set_Timeout(this DoubleClick*, int value)
{
  if (value < 0) value = 0;
  DblClk.Timeout = value;
}

//===========================================================================
//
// DoubleClick::Event[] property
//
//===========================================================================
bool geti_Event(this DoubleClick*, MouseButton mb)
{
  if (mb < 0 || mb >= TOP_REF_MOUSE_BTN)
    return false;
  return DblClk.MBtn == mb && DblClk.DblClick;
}

//===========================================================================
//
// DoubleClick::ClaimThisEvent()
//
//===========================================================================
static void DoubleClick::ClaimThisEvent()
{
  DblClk.DblClick = false;
}

//===========================================================================
//
// DoubleClick::Reset()
//
//===========================================================================
static void DoubleClick::Reset()
{
  DblClk.MBtn = 0;
  DblClk.Taps = 0;
  DblClk.DblClick = false;
  
  MouseButton mb = eMouseLeft;
  while (mb < TOP_REF_MOUSE_BTN)
  {
    MBtnRec[mb].IsDown = false;
    MBtnRec[mb].StateJustChanged = false;
    MBtnRec[mb].StateTimer = 0;
    mb++;
  }
}

//===========================================================================
//
// game_start()
// Initializing DoubleClick.
//
//===========================================================================
function game_start()
{
  DblClk.Timeout = DOUBLECLICK_DEFAULT_TIMEOUT;
  DoubleClick.Reset();
}

//===========================================================================
//
// repeatedly_execute_always()
// The listening routine.
//
//===========================================================================
function repeatedly_execute_always()
{
  // find real milliseconds per tick
  int tick_ms = 1000 / GetGameSpeed();
  if (tick_ms == 0)
    tick_ms = 1; // very unlikely, but who knows...
  
  // Iterate through all the mouse buttons and update their state.
  MouseButton mb = eMouseLeft;
  while (mb < TOP_REF_MOUSE_BTN)
  {
    // new up/down state
    bool mb_was_down = MBtnRec[mb].IsDown;
    // last up/down state
    bool mb_down = Mouse.IsButtonDown(mb);

    // Clear signal key data, which is kept for a single tick only
    if (MBtnRec[mb].StateJustChanged)
    {
      if (DblClk.MBtn == mb)
        DblClk.DblClick = false;
      MBtnRec[mb].StateTimer = 0;
      MBtnRec[mb].StateJustChanged = false;
    }
    
    // Button state is the same
    if (mb_was_down == mb_down)
    {
      // update state timer
      MBtnRec[mb].StateTimer += tick_ms;
      if (!mb_down)
      { // button is still up
        if (MBtnRec[mb].StateTimer > DblClk.Timeout)
        {
          // too much time passed since last click
          if (DblClk.MBtn == mb)
          {
            // reset tap sequence
            DblClk.MBtn  = 0;
            DblClk.Taps = 0;
          }
        }
      }
    }
    // Button state changed
    else
    {
      MBtnRec[mb].StateJustChanged = true;
      if (mb_down)
      { // button is now down
        MBtnRec[mb].IsDown = true;
        // update sequencing
        if (DblClk.MBtn != mb)
        {
          DblClk.MBtn = mb;
          DblClk.Taps = 1;
        }
        else
        {
          DblClk.Taps++;
          if (DblClk.Taps == 2)
            DblClk.DblClick = true;
        }
      }
      else
      { // button is now up
        MBtnRec[mb].IsDown = false;
      }
    }
    
    mb++;
  }
}
 �  // DoubleClick is open source under the MIT License.
//
// TERMS OF USE - DoubleClick MODULE
//
// Copyright (c) 2018-present Ivan Mogilko
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

#ifndef __DOUBLECLICK_MODULE__
#define __DOUBLECLICK_MODULE__

#define DOUBLECLICK_VERSION_00_01_00_00


// A maximal time passed between two clicks while they are still considered a sequence
#define DOUBLECLICK_DEFAULT_TIMEOUT      300

struct DoubleClick
{
  /// Get/set maximal period (in milliseconds) between two clicks while they still considered a sequence
  import static attribute int Timeout;
  
  readonly import static attribute bool Event[];
  
  /// Reset double-click event; useful if you have several modules checking for double-click in order
  import static void ClaimThisEvent();
  // NOTE: cannot name it just ClaimEvent, because 3.2.1 compiler has a bug that prevents from naming
  // struct members identical to built-in global functions and variables.
  
  /// Reset the module state. Makes it forget the recorded information about mouse events.
  /// May become useful if you have some issues when switching between rooms or game modes.
  import static void Reset();
};

#endif  // __DOUBLECLICK_MODULE__
 �_�4        ej��