AGSScriptModule    Ivan Mogilko Keeps record of keyboard and mouse button states Key Listener 0.9.7 �b  
#ifdef ENABLE_KEY_LISTENER

// Size of the keyboard keys lookup array
#define TOP_REF_KEY        408
// Size of the mouse button lookup array
#define TOP_REF_MOUSE_BTN  4

struct KeyListenerSettings
{
  bool Enabled;             // is listener enabled
  int KeyAutoRepeatDelay;   // minimal time for a key to be down to be considered "repeating"
  int KeyAutoRepeatPeriod;  // period for "repeating" key count increment
  int KeySequenceTimeout;   // delay between two key taps that lets to count them as one sequence
};

KeyListenerSettings Kls;


// Individual key records
struct KeyDefinition
{
  int       Key;              // actual key code; stores mouse button as a negative number
  bool      IsDown;           // is being held
  int       Repeats;          // number of automatic key repeats
  
  bool      StateJustChanged; // just pushed or released
  bool      JustRepeated;     // command was repeated for the held down key
  
  int       StateTimer;       // current state time
  int       AutoRepeatTimer;  // time passed since last key's auto repeat "command" was sent
};

KeyDefinition  KeyDefs[KEY_LISTENER_MAX_KEYS]; // array of listened keycodes
int            KeyDefCount; // number of valid items in array
int            KeyDefSize;  // memory size of array

// Lookup arrays; keep indices of KeyDef array related to particular keys or mouse buttons
int            KeyRef[TOP_REF_KEY];
int            MBtnRef[TOP_REF_MOUSE_BTN];


enum KeyGroupType
{
  eKeyGroupKeyboard = 0,
  eKeyGroupMouse    = 1,
  MAX_KEY_GROUP_TYPES
};

// Global sequenced key record
struct KeySequenceDef
{
  int       Key;              // a key being sequenced right now
  int       Taps;             // number of sequential key presses
  bool      JustSequenced;    // the key was just pressed new time in sequence
};

KeySequenceDef SeqKey[MAX_KEY_GROUP_TYPES]; // sequenced keys for each group type


//===========================================================================
//
// AddKeyDef()
// Adds new item to key defs array.
//
//===========================================================================
void AddKeyDef(eKeyCode keycode)
{
  if (KeyDefCount == KeyDefSize)
    return;
  
  KeyDefs[KeyDefCount].Key = keycode;
  bool key_down;
  if (keycode >= 0)
  {
    KeyRef[keycode] = KeyDefCount;
    key_down = IsKeyPressed(keycode);
  }
  else
  {
    MBtnRef[-keycode] = KeyDefCount;
    key_down = Mouse.IsButtonDown(-keycode);
  }
  KeyDefs[KeyDefCount].IsDown = key_down;
  KeyDefs[KeyDefCount].StateJustChanged = false;
  KeyDefs[KeyDefCount].JustRepeated = false;
  KeyDefs[KeyDefCount].Repeats = 0;
  
  KeyDefs[KeyDefCount].StateTimer = 0;
  KeyDefs[KeyDefCount].AutoRepeatTimer = 0;
  
  #ifdef KEY_LISTENER_DEBUG
  Display("Added key ref: slot = %d, keycode = %d", KeyDefCount, keycode);
  #endif
  
  KeyDefCount++;
}

//===========================================================================
//
// ResetKeySequence()
// Resets key sequence record for the given key group.
//
//===========================================================================
void ResetKeySequence(KeyGroupType keygroup)
{
  SeqKey[keygroup].Key = 0;
  SeqKey[keygroup].JustSequenced = false;
  SeqKey[keygroup].Taps = 0;
}

//===========================================================================
//
// RemoveKeyDef()
// Removes an item from the key defs array.
//
//===========================================================================
void RemoveKeyDef(int index)
{
  int keycode = KeyDefs[index].Key;
  if (keycode >= 0)
  {
    KeyRef[keycode] = -1;
    if (SeqKey[eKeyGroupKeyboard].Key == keycode)
      ResetKeySequence(eKeyGroupKeyboard);
  }
  else
  {
    MBtnRef[-keycode] = -1;
    if (SeqKey[eKeyGroupMouse].Key == -keycode)
      ResetKeySequence(eKeyGroupMouse);
  }
  
  int i = index;
  while (i < KeyDefCount - 1)
  {
    KeyDefs[i].Key = KeyDefs[i + 1].Key;
    KeyDefs[i].IsDown = KeyDefs[i + 1].IsDown;
    KeyDefs[i].StateJustChanged = KeyDefs[i + 1].StateJustChanged;
    KeyDefs[i].JustRepeated = KeyDefs[i + 1].JustRepeated;
    KeyDefs[i].Repeats = KeyDefs[i + 1].Repeats;
  
    KeyDefs[i].StateTimer = KeyDefs[i + 1].StateTimer;
    KeyDefs[i].AutoRepeatTimer = KeyDefs[i + 1].AutoRepeatTimer;
    i++;
  }
  KeyDefCount--;
}

//===========================================================================
//
// ListenKey()
// Commences or ceases to listen keycode.
//
//===========================================================================
void ListenKey(int keycode, bool enable)
{
  int key_index = 0;
  while (key_index < KeyDefCount)
  {
    if (KeyDefs[key_index].Key == keycode)
    {
      if (!enable)
        RemoveKeyDef(key_index);
      return;
    }
    key_index++;
  }
  AddKeyDef(keycode);
}

//===========================================================================
//
// KeyListener::ListenKey()
// Commences or ceases to listen keyboard keycode.
//
//===========================================================================
static void KeyListener::ListenKey(eKeyCode keycode, bool enable)
{
  if (keycode >= 0 && keycode < TOP_REF_KEY)
    ListenKey(keycode, enable);
}

//===========================================================================
//
// KeyListener::ListenMouse()
// Commences or ceases to listen all the mouse keycodes.
//
//===========================================================================
static void KeyListener::ListenMouse(bool enable)
{
  ListenKey(-eMouseLeft, enable);
  ListenKey(-eMouseRight, enable);
  ListenKey(-eMouseMiddle, enable);
}

//===========================================================================
//
// ResetGlobalKeyState()
// Resets global dynamic data.
//
//===========================================================================
void ResetGlobalKeyState()
{
  int i = 0;
  while (i < MAX_KEY_GROUP_TYPES)
  {
    SeqKey[i].Key = 0;
    SeqKey[i].Taps = 0;
    SeqKey[i].JustSequenced = false;
    i++;
  }
}

//===========================================================================
//
// ResetKeyStates()
// Resets all dynamic data, depicting keys state.
//
//===========================================================================
void ResetKeyStates()
{
  ResetGlobalKeyState();

  int i;
  while (i < KeyDefCount)
  {
    KeyDefs[i].IsDown = false;
    KeyDefs[i].Repeats = 0;
    KeyDefs[i].AutoRepeatTimer = 0;
    KeyDefs[i].StateJustChanged = false;
    KeyDefs[i].JustRepeated = false;
    KeyDefs[i].StateTimer = 0;
    i++;
  }
}

//===========================================================================
//
// KeyListener::StopListenAllKeys()
//
//===========================================================================
static void KeyListener::StopListenAllKeys()
{
  ResetGlobalKeyState();

  KeyDefCount = 0;
  
  int i = 0;
  while (i < TOP_REF_KEY)
  {
    KeyRef[i] = -1;
    i++;
  }
  i = 0;
  while (i < TOP_REF_MOUSE_BTN)
  {
    MBtnRef[i] = -1;
    i++;
  }
}

//===========================================================================
//
// KeyListener::Enabled property
//
//===========================================================================
bool get_Enabled(this KeyListener*)
{
  return Kls.Enabled;
}

void set_Enabled(this KeyListener*, bool value)
{
  if (Kls.Enabled && !value)
    ResetKeyStates();
  Kls.Enabled = value;
}

//===========================================================================
//
// KeyListener::ResetToDefaults()
//
//===========================================================================

static void KeyListener::ResetToDefaults()
{
  Kls.KeyAutoRepeatDelay  = KEY_LISTENER_DEFAULT_AUTO_REPEAT_DELAY;
  Kls.KeyAutoRepeatPeriod = KEY_LISTENER_DEFAULT_AUTO_REPEAT_PERIOD;
  Kls.KeySequenceTimeout  = KEY_LISTENER_DEFAULT_SEQUENCE_TIMEOUT;
}

//===========================================================================
//
// KeyListener::KeyAutoRepeatDelay property
//
//===========================================================================
int get_KeyAutoRepeatDelay(this KeyListener*)
{
  return Kls.KeyAutoRepeatDelay;
}

void set_KeyAutoRepeatDelay(this KeyListener*, int value)
{
  if (value < 0) value = 0;
  Kls.KeyAutoRepeatDelay = value;
}

//===========================================================================
//
// KeyListener::KeyAutoRepeatPeriod property
//
//===========================================================================
int get_KeyAutoRepeatPeriod(this KeyListener*)
{
  return Kls.KeyAutoRepeatPeriod;
}

void set_KeyAutoRepeatPeriod(this KeyListener*, int value)
{
  if (value < 0) value = 0;
  Kls.KeyAutoRepeatPeriod = value;
}

//===========================================================================
//
// KeyListener::KeySequenceTimeout property
//
//===========================================================================
int get_KeySequenceTimeout(this KeyListener*)
{
  return Kls.KeySequenceTimeout;
}

void set_KeySequenceTimeout(this KeyListener*, int value)
{
  if (value < 0) value = 0;
  Kls.KeySequenceTimeout = value;
}

//===========================================================================
//
// KeyListener::EvtKeyPushed[] property
//
//===========================================================================
bool geti_EvtKeyPushed(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return false;
  int ref = KeyRef[keycode];
  if (ref >= 0)
    return KeyDefs[ref].IsDown && KeyDefs[ref].StateJustChanged;
  return false;
}

//===========================================================================
//
// KeyListener::EvtMousePushed[] property
//
//===========================================================================
bool geti_EvtMousePushed(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return false;
  int ref = MBtnRef[keycode];
  if (ref >= 0)
    return KeyDefs[ref].IsDown && KeyDefs[ref].StateJustChanged;
  return false;
}

//===========================================================================
//
// KeyListener::EvtKeyReleased[] property
//
//===========================================================================
bool geti_EvtKeyReleased(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return false;
  int ref = KeyRef[keycode];
  if (ref >= 0)
    return !KeyDefs[ref].IsDown && KeyDefs[ref].StateJustChanged;
  return false;
}

//===========================================================================
//
// KeyListener::EvtMouseReleased[] property
//
//===========================================================================
bool geti_EvtMouseReleased(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return false;
  int ref = MBtnRef[keycode];
  if (ref >= 0)
    return !KeyDefs[ref].IsDown && KeyDefs[ref].StateJustChanged;
  return false;
}

//===========================================================================
//
// KeyListener::EvtKeyAutoRepeated[] property
//
//===========================================================================
bool geti_EvtKeyAutoRepeated(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return false;
  int ref = KeyRef[keycode];
  if (ref >= 0)
    return KeyDefs[ref].JustRepeated;
  return false;
}

//===========================================================================
//
// KeyListener::EvtMouseAutoRepeated[] property
//
//===========================================================================
bool geti_EvtMouseAutoRepeated(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return false;
  int ref = MBtnRef[keycode];
  if (ref >= 0)
    return KeyDefs[ref].JustRepeated;
  return false;
}

//===========================================================================
//
// KeyListener::EvtKeySequenced[] property
//
//===========================================================================
bool geti_EvtKeySequenced(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return false;
  if (SeqKey[eKeyGroupKeyboard].Key == keycode)
    return SeqKey[eKeyGroupKeyboard].JustSequenced;
  return false;
}

//===========================================================================
//
// KeyListener::EvtMouseSequenced[] property
//
//===========================================================================
bool geti_EvtMouseSequenced(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return false;
  if (SeqKey[eKeyGroupMouse].Key == keycode)
    return SeqKey[eKeyGroupMouse].JustSequenced;
  return false;
}

//===========================================================================
//
// KeyListener::EvtKeyDoubleTap[] property
//
//===========================================================================
bool geti_EvtKeyDoubleTap(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return false;
  if (SeqKey[eKeyGroupKeyboard].Key == keycode)
    return SeqKey[eKeyGroupKeyboard].JustSequenced && SeqKey[eKeyGroupKeyboard].Taps == 2;
  return false;
}

//===========================================================================
//
// KeyListener::EvtMouseDoubleClick[] property
//
//===========================================================================
bool geti_EvtMouseDoubleClick(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return false;
  if (SeqKey[eKeyGroupMouse].Key == keycode)
    return SeqKey[eKeyGroupMouse].JustSequenced && SeqKey[eKeyGroupMouse].Taps == 2;
  return false;
}

//===========================================================================
//
// KeyListener::IsKeyDown[] property
//
//===========================================================================
bool geti_IsKeyDown(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return false;
  if (KeyRef[keycode] >= 0)
    return KeyDefs[KeyRef[keycode]].IsDown;
  return false;
}

//===========================================================================
//
// KeyListener::IsMouseDown[] property
//
//===========================================================================
bool geti_IsMouseDown(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return false;
  if (MBtnRef[keycode] >= 0)
    return KeyDefs[MBtnRef[keycode]].IsDown;
  return false;
}

//===========================================================================
//
// KeyListener::KeyAutoRepeatCount[] property
//
//===========================================================================
int geti_KeyAutoRepeatCount(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return 0;
  if (KeyRef[keycode] >= 0)
    return KeyDefs[KeyRef[keycode]].Repeats;
  return 0;
}

//===========================================================================
//
// KeyListener::MouseAutoRepeatCount[] property
//
//===========================================================================
int geti_MouseAutoRepeatCount(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return 0;
  if (MBtnRef[keycode] >= 0)
    return KeyDefs[MBtnRef[keycode]].Repeats;
  return 0;
}

//===========================================================================
//
// KeyListener::KeySequenceLength[] property
//
//===========================================================================
int geti_KeySequenceLength(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return 0;
  if (SeqKey[eKeyGroupKeyboard].Key == keycode)
    return SeqKey[eKeyGroupKeyboard].Taps;
  return 0;
}

//===========================================================================
//
// KeyListener::MouseSequenceLength[] property
//
//===========================================================================
int geti_MouseSequenceLength(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return 0;
  if (SeqKey[eKeyGroupMouse].Key == keycode)
    return SeqKey[eKeyGroupMouse].Taps;
  return 0;
}

//===========================================================================
//
// KeyListener::KeyUpTime[] property
//
//===========================================================================
int geti_KeyUpTime(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return 0;
  int ref = KeyRef[keycode];
  if (ref >= 0)
  {
    if (!KeyDefs[ref].IsDown || KeyDefs[ref].StateJustChanged)
      return KeyDefs[ref].StateTimer;
    else
      return 0;
  }
  return 0;
}

//===========================================================================
//
// KeyListener::MouseUpTime[] property
//
//===========================================================================
int geti_MouseUpTime(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return 0;
  int ref = MBtnRef[keycode];
  if (ref >= 0)
  {
    if (!KeyDefs[ref].IsDown || KeyDefs[ref].StateJustChanged)
      return KeyDefs[ref].StateTimer;
    else
      return 0;
  }
  return 0;
}

//===========================================================================
//
// KeyListener::KeyDownTime[] property
//
//===========================================================================
int geti_KeyDownTime(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_KEY)
    return 0;
  int ref = KeyRef[keycode];
  if (ref >= 0)
  {
    if (KeyDefs[ref].IsDown || KeyDefs[ref].StateJustChanged)
      return KeyDefs[ref].StateTimer;
    else
      return 0;
  }
  return 0;
}

//===========================================================================
//
// KeyListener::MouseDownTime[] property
//
//===========================================================================
int geti_MouseDownTime(this KeyListener*, int keycode)
{
  if (keycode < 0 || keycode >= TOP_REF_MOUSE_BTN)
    return 0;
  int ref = MBtnRef[keycode];
  if (ref >= 0)
  {
    if (KeyDefs[ref].IsDown || KeyDefs[ref].StateJustChanged)
      return KeyDefs[ref].StateTimer;
    else
      return 0;
  }
  return 0;
}


//===========================================================================
//
// game_start()
// Initializing KeyListener.
//
//===========================================================================
function game_start()
{
  KeyDefSize = KEY_LISTENER_MAX_KEYS;
  KeyListener.ResetToDefaults();
  KeyListener.StopListenAllKeys();
}

//===========================================================================
//
// on_key_press()
// React to user pressing a key.
//
//===========================================================================
function on_key_press(eKeyCode keycode) 
{
  // Reset key sequence record if any other key was pressed in between;
  // we do it in the "on_key_press" callback, because player could press a key
  // that is not listened by our Listener.
  if (SeqKey[eKeyGroupKeyboard].Key !=0 && SeqKey[eKeyGroupKeyboard].Key != keycode)
    ResetKeySequence(eKeyGroupKeyboard);
}

//===========================================================================
//
// repeatedly_execute_always()
// The listening routine.
//
//===========================================================================
function repeatedly_execute_always()
{
  if (!Kls.Enabled || KeyDefCount == 0)
    return; // nothing to do
  
  int tick_ms = 1000 / GetGameSpeed(); // milliseconds per tick
  if (tick_ms == 0)
    tick_ms = 1; // very unlikely, but who knows...
  
  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------
  // Main iteration
  //
  // Iterate through all the listened keycodes and update their state.
  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------
  bool          key_down;      // new up/down state
  bool          key_was_down;  // last up/down state
  eKeyCode      keycode;
  KeyGroupType  keygroup;
  int           key_index = 0;
  
  while (key_index < KeyDefCount)
  {
    keycode = KeyDefs[key_index].Key;
    
    key_was_down = KeyDefs[key_index].IsDown;
    if (keycode >= 0)
    {
      key_down = IsKeyPressed(keycode);
      keygroup = eKeyGroupKeyboard;
    }
    else
    {
      keycode = -keycode;
      key_down = Mouse.IsButtonDown(keycode);
      keygroup = eKeyGroupMouse;
    }

    //*********************************************************************
    // Clear signal key data, which is kept for a single tick only
    //*********************************************************************
    if (KeyDefs[key_index].StateJustChanged)
    {
      KeyDefs[key_index].Repeats = 0;
      if (SeqKey[keygroup].Key == keycode)
          SeqKey[keygroup].JustSequenced = false;
      KeyDefs[key_index].StateTimer = 0;
      KeyDefs[key_index].StateJustChanged = false;
    }
    KeyDefs[key_index].JustRepeated = false;
    
    //*********************************************************************
    // Update SAME STATE
    //*********************************************************************
    if (key_was_down == key_down)  // same state is kept for one more tick
    {
      // update state timer
      KeyDefs[key_index].StateTimer += tick_ms;
      //-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      // The key is still DOWN
      //-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      if (key_down)
      {        
        // Process repeats
        if (KeyDefs[key_index].Repeats == 0 && KeyDefs[key_index].StateTimer > Kls.KeyAutoRepeatDelay)
        {
          // repeats started
          KeyDefs[key_index].Repeats = 1;
          KeyDefs[key_index].JustRepeated = true;
          KeyDefs[key_index].AutoRepeatTimer = 0; // reset repeats timer
        }
        else if (KeyDefs[key_index].Repeats > 0)
        {
          // continuing repeats
          KeyDefs[key_index].AutoRepeatTimer += tick_ms;
          if (KeyDefs[key_index].AutoRepeatTimer > Kls.KeyAutoRepeatPeriod)
          {
            KeyDefs[key_index].Repeats++; // increment repeats counter
            KeyDefs[key_index].JustRepeated = true;
            KeyDefs[key_index].AutoRepeatTimer = 0; // reset repeats timer
          }
        }
      }
      //-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      // The key is still UP
      //-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      else
      {
        if (KeyDefs[key_index].StateTimer > Kls.KeySequenceTimeout)
        {
          // too much time passed since last key press
          if (SeqKey[keygroup].Key == keycode)
          {
            // reset tap sequence
            SeqKey[keygroup].Key  = 0;
            SeqKey[keygroup].Taps = 0;
          }
        }
      }
    }
    //*********************************************************************
    // Update STATE CHANGED
    //*********************************************************************
    else
    {
      KeyDefs[key_index].StateJustChanged = true;
      // save state timer until next tick (so that user can know how long
      // the key was in previous state before changed to opposite one)
      //-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      // The key is NOW DOWN
      //-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      if (key_down)
      {
        KeyDefs[key_index].IsDown = true;
        // update sequencing
        if (SeqKey[keygroup].Key != keycode)
        {
          SeqKey[keygroup].Key = keycode;
          SeqKey[keygroup].Taps = 1;
        }
        else
        {
          SeqKey[keygroup].Taps++;
          SeqKey[keygroup].JustSequenced = true;
        }
      }
      //-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      // The key is NOW UP
      //-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
      else
      {
        KeyDefs[key_index].IsDown = false;
        // save repeat count until next tick (so that user can know how much
        // times the key repeated before being released)
      }
    }
    
    key_index++;
  }
}

#endif  // ENABLE_KEY_LISTENER
 �  // KeyListener is open source under the MIT License.
//
// TERMS OF USE - KeyListener MODULE
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

#ifndef __KEY_LISTENER_MODULE__
#define __KEY_LISTENER_MODULE__

#define KEY_LISTENER_VERSION_00_00_09_07

// Comment this line out to completely disable KeyListener during compilation
#define ENABLE_KEY_LISTENER

#ifdef ENABLE_KEY_LISTENER

// Uncomment this to enable debug messages (for testing purposes only)
//#define KEY_LISTENER_DEBUG

// Maximal supported number of keys to listen at the same time.
// Feel free to increase or decrease this for your project in relation to your needs.
// Remember, that more keys the listener tracks at the same time, the slower it works.
// Keep an eye on your game speed if you change this; but usually it should not affect
// your game much, because the key state processing is a simple task.
#define KEY_LISTENER_MAX_KEYS 32

// Default KeyListener settings.
// These values are declared here mainly for the reference. It is not recommended
// to change these; configure KeyListener by setting corresponding class properties
// instead (see class declaration below).
// All these values are in milliseconds.
//
// A time that has to pass before the held down key is considered "repeating"
#define KEY_LISTENER_DEFAULT_AUTO_REPEAT_DELAY     300
// A time that has to pass between each "repeating" key command
#define KEY_LISTENER_DEFAULT_AUTO_REPEAT_PERIOD    40
// A maximal time passed between two key taps while they still considered a sequence
#define KEY_LISTENER_DEFAULT_SEQUENCE_TIMEOUT      300


struct KeyListener
{
  ///////////////////////////////////////////////////////////////////////////
  //
  // Setting up
  // ------------------------------------------------------------------------
  // Functions and properties meant to configure the listener's behavior.
  //
  ///////////////////////////////////////////////////////////////////////////
  
  /// Enables or disables KeyListener, without cancelling tracked keys settings
  import static attribute bool Enabled;
  
  /// Commences or ceases to listen keycode
  import static void ListenKey(eKeyCode keycode, bool enable = true);
  import static void ListenMouse(bool enable = true);
  /// Stops listening all keycodes
  import static void StopListenAllKeys();
  
  /// Resets all listener parameters to default values
  import static void ResetToDefaults();
  
  /// Get/set minimal time (in milliseconds) for a held down key to be down to be considered "repeating"
  import static attribute int KeyAutoRepeatDelay;
  /// Get/set period (in milliseconds) between each "repeating" key count
  import static attribute int KeyAutoRepeatPeriod;
  /// Get/set maximal period (in milliseconds) between two key taps while they still considered a sequence
  import static attribute int KeySequenceTimeout;
  
  
  ///////////////////////////////////////////////////////////////////////////
  //
  // Event signals
  // ------------------------------------------------------------------------
  // Properties meant to signal user about keys events.
  //
  ///////////////////////////////////////////////////////////////////////////

  /// Gets if key was just pushed
  readonly import static attribute bool EvtKeyPushed[];
  readonly import static attribute bool EvtMousePushed[];
  /// Gets if key was just released after being held down
  readonly import static attribute bool EvtKeyReleased[];
  readonly import static attribute bool EvtMouseReleased[];
  /// Gets if key command was repeated for a held down key
  readonly import static attribute bool EvtKeyAutoRepeated[];
  readonly import static attribute bool EvtMouseAutoRepeated[];
  /// Gets if key was tapped another time in sequence
  readonly import static attribute bool EvtKeySequenced[];
  readonly import static attribute bool EvtMouseSequenced[];
  /// Gets if key was tapped twice in sequence just now
  readonly import static attribute bool EvtKeyDoubleTap[];
  readonly import static attribute bool EvtMouseDoubleClick[];
  
  
  ///////////////////////////////////////////////////////////////////////////
  //
  // Key records
  // ------------------------------------------------------------------------
  // Properties meant to tell gathered information about keys the listener
  // is listening to.
  //
  ///////////////////////////////////////////////////////////////////////////

  /// Gets if key is currently held down
  readonly import static attribute bool IsKeyDown[];
  readonly import static attribute bool IsMouseDown[];
  /// Gets how many times the pressed down key command was repeated
  readonly import static attribute int  KeyAutoRepeatCount[];
  readonly import static attribute int  MouseAutoRepeatCount[];
  /// Gets how many times the key was tapped in sequence
  readonly import static attribute int  KeySequenceLength[];
  readonly import static attribute int  MouseSequenceLength[];
  /// Gets how long (in milliseconds) the key was not pressed
  readonly import static attribute int  KeyUpTime[];
  readonly import static attribute int  MouseUpTime[];
  /// Gets how long (in milliseconds) the key was held down
  readonly import static attribute int  KeyDownTime[];
  readonly import static attribute int  MouseDownTime[];
};

#endif  // ENABLE_KEY_LISTENER

#endif  // __KEY_LISTENER_MODULE__
 6ghl        ej��