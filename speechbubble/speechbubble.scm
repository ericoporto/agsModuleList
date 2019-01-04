AGSScriptModule    Gunnar Harboe (Snarky) Display speech in comic book-style speech bubbles Speech Bubble Module 0.8.0 �  /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * SPEECH BUBBLE MODULE - Script                                                           *
 * by Gunnar Harboe (Snarky), v0.8.0                                                       *
 *                                                                                         *
 * Copyright (c) 2017 Gunnar Harboe                                                        *
 *                                                                                         *
 * This code is offered under the MIT License                                              *
 * https://opensource.org/licenses/MIT                                                     *
 *                                                                                         *
 * It is also licensed under a Creative Commons Attribution 4.0 International License.     *
 * https://creativecommons.org/licenses/by/4.0/                                            *
 *                                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// Change this function to call a different Say() function
void SB_sayImpl(this Character*, String message)
{
  this.Say(message);
}

// If you want to use another function to animate background speech (e.g. to do lip-sync),
// call it here and return true
bool SB_sayBackgroundAnimateImpl(this Character*, String message)
{
  return false;
}

// If you're using another function to animate background speech, replace this with the
// appropriate test to see if the background speech animation is running
/*
bool SB_isSpeakingBackground(this Character*)
{
  SpeechBubble* sb = this.GetSpeechBubble();
  return (sb != null && sb.IsBackgroundSpeech);
}*/

#region Block functions
#define eMouseNone 0

enum BlockEndType
{
  eBlockTimeOut, 
  eBlockKeyInterrupt, 
  eBlockMouseInterrupt, 
  eBlockUnknownInterrupt
};

//#define MAX_WAIT 32767
#define MAX_WAIT 20

#define CTRL_OFFSET 64
#define ALT_OFFSET (-236)
#define CTRL_RANGE_START 1
#define CTRL_RANGE_END 26
#define ALT_RANGE_START 301
#define ALT_RANGE_END 326
#define MAX_KEYCODE 435

#define eKeyLeftShift 403
#define eKeyRightShift 404
#define eKeyLeftCtrl 405
#define eKeyRightCtrl 406
#define eKeyLeftAlt 407
#define eKeyRightAlt 420

int _waitLoops;
eKeyCode _interruptKey;
MouseButton _interruptButton;

bool _wasButtonDown;
bool _wasKeyDown;

int _maxInt(int a, int b)
{
  if(a>b) return a;
  return b;
}

int _minInt(int a, int b)
{
  if(a<b) return a;
  return b;
}

bool IsButtonDownAny(static Mouse)
{
  return Mouse.IsButtonDown(eMouseLeft) || Mouse.IsButtonDown(eMouseRight) || Mouse.IsButtonDown(eMouseMiddle);
}

bool IsKeyPressedCombi(eKeyCode keyCode)
{
  if(keyCode >= CTRL_RANGE_START && keyCode <= CTRL_RANGE_END)
  {
    return (IsKeyPressed(eKeyLeftCtrl) || IsKeyPressed(eKeyRightCtrl)) && IsKeyPressed(keyCode+CTRL_OFFSET);
  }
  else if(keyCode >= ALT_RANGE_START && keyCode <= ALT_RANGE_END)
  {
    return (IsKeyPressed(eKeyLeftAlt) || IsKeyPressed(eKeyRightAlt)) && IsKeyPressed(keyCode+ALT_OFFSET);
  }
  else
    return IsKeyPressed(keyCode);
}

bool IsModifier(eKeyCode keyCode)
{
  return (keyCode == eKeyLeftShift || keyCode == eKeyRightShift ||
          keyCode == eKeyLeftCtrl  || keyCode == eKeyRightCtrl  ||
          keyCode == eKeyLeftAlt   || keyCode == eKeyRightAlt);
}

eKeyCode GetKeyPressed()
{
  for(int i=1; i<MAX_KEYCODE; i++)
  {
    if(!IsModifier(i) && IsKeyPressed(i))
      return i;
  }
  return 0;
}

bool IsKeyPressedAny()
{
  return (GetKeyPressed() != 0);
}

bool CheckKey(eKeyCode keyCode)
{
  if(keyCode == eKeyNone)
    return IsKeyPressedAny();
  else
    return IsKeyPressedCombi(keyCode);
}

bool CheckMouse(MouseButton button)
{
  if(button == eMouseNone)
    return Mouse.IsButtonDownAny();
  else
    return Mouse.IsButtonDown(button);
}

BlockEndType EndBlock(BlockEndType endType)
{
  _waitLoops = 0;
  _wasButtonDown = false;
  _wasKeyDown = false;
  return endType;
}

BlockEndType Block(int loops)
{
  while(loops>0)
  {
    _waitLoops = _minInt(MAX_WAIT, loops);
    loops -= _waitLoops;
    Wait(_waitLoops);
  }
  return eBlockTimeOut;
}

BlockEndType BlockKey(int loops, eKeyCode keyCode)
{
  _interruptKey = keyCode;
  if(loops<0)
  {
    // Keep waiting indefinitely until the WaitKey() was interrupted
    while(true)
    {
      _waitLoops = MAX_WAIT;
      WaitKey(MAX_WAIT);
      // If the wrong key, ignore the interruption
      if((keyCode == eKeyNone && _waitLoops != 0) || IsKeyPressedCombi(keyCode) || _wasKeyDown)
        return EndBlock(eBlockKeyInterrupt);
    }
  }
  
  while(loops>0)
  {
    _waitLoops = _minInt(MAX_WAIT, loops);
    loops -= _waitLoops;
    WaitKey(_waitLoops);
    if((keyCode == eKeyNone && _waitLoops != 0) || IsKeyPressedCombi(keyCode) || _wasKeyDown)
      return EndBlock(eBlockKeyInterrupt);
    loops += _waitLoops;
  }
  return EndBlock(eBlockTimeOut);
}

BlockEndType BlockMouse(int loops, MouseButton button)
{
  _interruptButton = button;
  if(loops<0)
  {
    while(true)
    {
      _waitLoops = MAX_WAIT;
      WaitMouseKey(MAX_WAIT);
      if(CheckMouse(button) || _wasButtonDown)
        return EndBlock(eBlockMouseInterrupt);
    }
  }
  
  while(loops>0)
  {
    _waitLoops = _minInt(MAX_WAIT, loops);
    loops -= _waitLoops;
    WaitMouseKey(_waitLoops);
    if(CheckMouse(button) || _wasButtonDown)
      return EndBlock(eBlockMouseInterrupt);
    loops += _waitLoops;
  }
  return EndBlock(eBlockTimeOut);
}

BlockEndType BlockMouseKey(int loops, eKeyCode keyCode, MouseButton button)
{
  _interruptKey = keyCode;
  _interruptButton = button;
  if(loops<0)
  {
    // Keep waiting indefinitely until the WaitKey() was interrupted
    while(true)
    {
      _waitLoops = MAX_WAIT;
      WaitMouseKey(MAX_WAIT);
      if(CheckMouse(button) || _wasButtonDown)
        return EndBlock(eBlockMouseInterrupt);
      if(CheckKey(keyCode) || _wasKeyDown)
        return EndBlock(eBlockKeyInterrupt);
      // Fallback if we can't identify what was pressed, but it doesn't matter
      if(_waitLoops != 0 && button == eMouseNone && keyCode == eKeyNone)
        return EndBlock(eBlockUnknownInterrupt);
    }
  }
  
  while(loops>0)
  {
    _waitLoops = _minInt(MAX_WAIT, loops);
    loops -= _waitLoops;
    WaitMouseKey(_waitLoops);
    if(CheckMouse(button) || _wasButtonDown)
      return EndBlock(eBlockMouseInterrupt);
    if(CheckKey(keyCode) || _wasKeyDown)
      return EndBlock(eBlockKeyInterrupt);
    // Fallback if we can't identify what was pressed, but it doesn't matter
    if(_waitLoops != 0 && button == eMouseNone && keyCode == eKeyNone)
      return EndBlock(eBlockUnknownInterrupt);
    loops += _waitLoops;
  }
  return EndBlock(eBlockTimeOut);
}

BlockEndType BlockSpeech(int loops, bool forceTimeOut)
{
  switch(Speech.SkipStyle)
  {
    case eSkipKey:
      if(forceTimeOut)
        return BlockKey(loops, Speech.SkipKey);
      else
        return BlockKey(-1, Speech.SkipKey);
    case eSkipKeyMouse:
      if(forceTimeOut)
        return BlockMouseKey(loops, Speech.SkipKey, eMouseNone);
      else
        return BlockMouseKey(-1, Speech.SkipKey, eMouseNone);
    case eSkipKeyMouseTime:
      return BlockMouseKey(loops, Speech.SkipKey, eMouseNone);
    case eSkipKeyTime:
      return BlockKey(loops, Speech.SkipKey);
    case eSkipMouse:
      if(forceTimeOut)
        return BlockMouse(loops, eMouseNone);
      else
        return BlockMouse(-1, eMouseNone);
    case eSkipMouseTime:
      return BlockMouse(loops, eMouseNone);
    case -1: // In AGS 3.4.0, Speech.SkipStyle reports -1 instead of eSkipTime(==2) when set to that value
    case eSkipTime:
      return Block(loops);
  }
}

// called from repeatedly_execute_always()
function _block_always()
{
  if(_waitLoops != 0)
  {
    _wasButtonDown = CheckMouse(_interruptButton);
    _wasKeyDown = CheckKey(_interruptKey);
  }
  if(_waitLoops > 0)
    _waitLoops--;
}

#endregion

#region Variable declarations
// Variables for the SpeecBubble attributes
GUI* _defaultGui;
int _backgroundColor;
int _borderColor;
int _backgroundTransparency;
int _borderTransparency;
int _backgroundSpeechTint;
int _borderSpeechTint;

int _textTransparency;
int _textOutlineColor;
int _textOutlineSpeechTint;
int _textOutlineWidth;
TextOutlineStyle _textOutlineStyle;

int _maxTextWidth;
int _heightOverHead;
int _paddingTop;
int _paddingBottom;
int _paddingLeft;
int _paddingRight;
int _cornerRoundingRadius;

String _talkTail[];
String _thinkTail[];
int _talkTailHeight;
int _talkTailWidth;
int _thinkTailHeight;
int _thinkTailWidth;

GUI* _bubbleGui;
GUI* _textGui;
FontType _invisibleFont;
Alignment _textAlign;

// Internal script variables
Character* _bubbleChars[];
SpeechBubble* _charBubbles[];  // Array to store bubbles for all characters
String _bubbleMessages[];
DynamicSprite* _bubbleSprites[];
Overlay* _bubbleOverlays[];
GUI* _bubbleGuis[];
int _bubbleCount;

#endregion

// Helper functions

int _clampInt(int value, int minRange, int maxRange)
{
  if(value<minRange) return minRange;
  if(value>maxRange) return maxRange;
  return value;
}

// Calculate the color that comes closest to a mix of c1 and c2 (at 'mix' percent c1)
int mixColors(int c1, int c2, int mix)
{
  if(mix==0) return c2;
  if(mix==100) return c1;
  int r1, g1, b1;
  int r2, g2, b2;
  
  // Extract the c1 channels
  if(c1 < 32)
  {
    r1 = (palette[c1].r << 2) + (palette[c1].r >> 4);
    g1 = (palette[c1].g << 2) + (palette[c1].g >> 4);
    b1 = (palette[c1].b << 2) + (palette[c1].b >> 4);
  }
  else
  {
    r1 = (c1 & 63488) >> 11; // 63488 = binary 11111-000000-00000
    g1 = (c1 & 2016) >> 5;   //  2016 = binary 00000-111111-00000
    b1 = (c1 & 31);          //    31 = binary 00000-000000-11111
    
    r1 = (r1 << 3) + (r1 >> 2);
    g1 = (g1 << 2) + (g1 >> 4);
    b1 = (b1 << 3) + (b1 >> 2);
  }
  
  // Extract the c2 channels
  if(c2 < 32)
  {
    r2 = (palette[c2].r << 2) + (palette[c2].r >> 4);
    g2 = (palette[c2].g << 2) + (palette[c2].g >> 4);
    b2 = (palette[c2].b << 2) + (palette[c2].b >> 4);
  }
  else
  {
    r2 = (c2 & 63488) >> 11; // 63488 = binary 11111-000000-00000
    g2 = (c2 & 2016) >> 5;   //  2016 = binary 00000-111111-00000
    b2 = (c2 & 31);          //    31 = binary 00000-000000-11111
    
    r2 = (r2 << 3) + (r2 >> 2);
    g2 = (g2 << 2) + (g2 >> 4);
    b2 = (b2 << 3) + (b2 >> 2);
  }
  
  // Calculate the mix
  int r = (r1 * mix + r2*(100-mix) + 50) / 100; // +50 to round up to nearest
  int g = (g1 * mix + g2*(100-mix) + 50) / 100;
  int b = (b1 * mix + b2*(100-mix) + 50) / 100;
  
  // Convert back to AGS color num
  r = r >> 3;  
  g = g >> 2;
  b = b >> 3;
  
  r = r << 11;
  g = g << 5;
  
  int c = r+g+b;
  if(c < 32)
    c += 65536;
  return c;
}

// Attribute accessors
#region SpeechBubble Attribute accessors

#region static accessors
GUI* get_DefaultGui(static SpeechBubble)
{ return _defaultGui; }
void set_DefaultGui(static SpeechBubble, GUI* value)
{ _defaultGui = value; }

int get_BackgroundColor(static SpeechBubble)
{ return _backgroundColor; }
void set_BackgroundColor(static SpeechBubble, int value)
{ _backgroundColor = value; }

int get_BorderColor(static SpeechBubble)
{ return _borderColor; }
void set_BorderColor(static SpeechBubble, int value)
{ _borderColor = value; }

int get_BackgroundTransparency(static SpeechBubble)
{ return _backgroundTransparency; }
void set_BackgroundTransparency(static SpeechBubble, int value)
{ _backgroundTransparency = _clampInt(value, 0, 100); }

int get_BorderTransparency(static SpeechBubble)
{ return _borderTransparency; }
void set_BorderTransparency(static SpeechBubble, int value)
{ _borderTransparency = _clampInt(value, 0, 100); }

int get_BackgroundSpeechTint(static SpeechBubble)
{ return _backgroundSpeechTint; }
void set_BackgroundSpeechTint(static SpeechBubble, int value)
{ _backgroundSpeechTint = _clampInt(value, 0, 100); }

int get_BorderSpeechTint(static SpeechBubble)
{ return _borderSpeechTint; }
void set_BorderSpeechTint(static SpeechBubble, int value)
{ _borderSpeechTint = _clampInt(value, 0, 100); }

int get_TextTransparency(static SpeechBubble)
{ return _textTransparency; }
void set_TextTransparency(static SpeechBubble, int value)
{ _textTransparency = _clampInt(value, 0, 100); }

int get_TextOutlineColor(static SpeechBubble)
{ return _textOutlineColor; }
void set_TextOutlineColor(static SpeechBubble, int value)
{ _textOutlineColor = value; }

int get_TextOutlineSpeechTint(static SpeechBubble)
{ return _textOutlineSpeechTint; }
void set_TextOutlineSpeechTint(static SpeechBubble, int value)
{ _textOutlineSpeechTint = _clampInt(value, 0, 100); }

int get_TextOutlineWidth(static SpeechBubble)
{ return _textOutlineWidth; }
void set_TextOutlineWidth(static SpeechBubble, int value)
{ _textOutlineWidth = value; }

TextOutlineStyle get_TextOutlineStyle(static SpeechBubble)
{ return _textOutlineStyle; }
void set_TextOutlineStyle(static SpeechBubble, TextOutlineStyle value)
{ _textOutlineStyle = value; }

int get_MaxTextWidth(static SpeechBubble)
{ return _maxTextWidth; }
void set_MaxTextWidth(static SpeechBubble, int value)
{ _maxTextWidth = value; }

int get_HeightOverHead(static SpeechBubble)
{ return _heightOverHead; }
void set_HeightOverHead(static SpeechBubble, int value)
{ _heightOverHead = value; }

int get_PaddingTop(static SpeechBubble)
{ return _paddingTop; }
void set_PaddingTop(static SpeechBubble, int value)
{ _paddingTop = value; }

int get_PaddingBottom(static SpeechBubble)
{ return _paddingBottom; }
void set_PaddingBottom(static SpeechBubble, int value)
{ _paddingBottom = value; }

int get_PaddingLeft(static SpeechBubble)
{ return _paddingLeft; }
void set_PaddingLeft(static SpeechBubble, int value)
{ _paddingLeft = value; }

int get_PaddingRight(static SpeechBubble)
{ return _paddingRight; }
void set_PaddingRight(static SpeechBubble, int value)
{ _paddingRight = value; }

int get_CornerRoundingRadius(static SpeechBubble)
{ return _cornerRoundingRadius; }
void set_CornerRoundingRadius(static SpeechBubble, int value)
{ _cornerRoundingRadius = _maxInt(0, value); }

// Helper function to set tail width and height
int[] measureTail(String tail[])
{
  int dim[] = new int[2];
  if(tail == null)
  {
    dim[0] = -1;
    dim[1] = -1;
    return dim;
  }
  dim[0] = 0;
  int i;
  for(i=0; tail[i] != null; i++)
  {
    dim[0] = _maxInt(dim[0], tail[i].Length);
  }
  dim[1] = i;
  return dim;
}

String[] get_TalkTail(static SpeechBubble)
{ return _talkTail; }
void set_TalkTail(static SpeechBubble, String value[])
{
  _talkTail = value;
  int dim[] = measureTail(value);
  _talkTailWidth = dim[0];
  _talkTailHeight = dim[1];
}

String[] get_ThinkTail(static SpeechBubble)
{ return _thinkTail; }
void set_ThinkTail(static SpeechBubble, String value[])
{
  _thinkTail = value;
  int dim[] = measureTail(value);
  _thinkTailWidth = dim[0];
  _thinkTailHeight = dim[1];
}

int get_TalkTailHeight(static SpeechBubble)
{ return _talkTailHeight; }

int get_TalkTailWidth(static SpeechBubble)
{ return _talkTailWidth; }

int get_ThinkTailHeight(static SpeechBubble)
{ return _thinkTailHeight; }

int get_ThinkTailWidth(static SpeechBubble)
{ return _thinkTailWidth; }

FontType get_InvisibleFont(static SpeechBubble)
{ return _invisibleFont; }
void set_InvisibleFont(static SpeechBubble, FontType value)
{ _invisibleFont = value; }

Alignment get_TextAlign(static SpeechBubble)
{ return _textAlign; }
void set_TextAlign(static SpeechBubble, Alignment value)
{ _textAlign = value; }
#endregion

#region instance accessors
Character* get_OwningCharacter(this SpeechBubble*)
{
  if(this._id == -1) return null;
  else return character[this._id];
}

bool get_Valid(this SpeechBubble*)
{ return this._valid; }
bool get_IsBackgroundSpeech(this SpeechBubble*)
{ return this._isBackgroundSpeech; }
bool get_IsThinking(this SpeechBubble*)
{ return this._isThinking; }
bool get_IsAnimating(this SpeechBubble*)
{ return this._isAnimating; }
bool get_UsesGUI(this SpeechBubble*)
{ return this._usesGui; }
String get_Text(this SpeechBubble*)
{ return _bubbleMessages[this._id]; }
DynamicSprite* get_BubbleSprite(this SpeechBubble*)
{ return _bubbleSprites[this._id]; }
Overlay* get_BubbleOverlay(this SpeechBubble*)
{ return _bubbleOverlays[this._id]; }
GUI* get_BubbleGUI(this SpeechBubble*)
{ return _bubbleGuis[this._id]; }
int get_TotalDuration(this SpeechBubble*)
{ return this._totalDuration; }
int get_ElapsedDuration(this SpeechBubble*)
{ return this._elapsedDuration; }

int get_X(this SpeechBubble*)
{ return this._x; }
void set_X(this SpeechBubble*, int value)
{
  this._x = value;
  if(!this._valid) return;
  if(this.get_UsesGUI())
  {
    GUI* g = this.get_BubbleGUI();
    g.X = value;
  }
  else
  {
    Overlay* o = _bubbleOverlays[this._id];
    o.Remove();
    DynamicSprite* bs = this.get_BubbleSprite();
    _bubbleOverlays[this._id] = Overlay.CreateGraphical(this._x, this._y, bs.Graphic, true);
  }
}

int get_Y(this SpeechBubble*)
{ return this._y; }
int set_Y(this SpeechBubble*, int value)
{
  this._y = value;
  if(!this._valid) return;
  if(this.get_UsesGUI())
  {
    GUI* g = this.get_BubbleGUI();
    g.Y = value;
  }
  else
  {
    Overlay* o = _bubbleOverlays[this._id];
    o.Remove();
    DynamicSprite* bs = this.get_BubbleSprite();
    _bubbleOverlays[this._id] = Overlay.CreateGraphical(this._x, this._y, bs.Graphic, true);
  }
}

#endregion

// "Protected" setters: used internally to setup SpeechBubble instances
void setOwningCharacter(this SpeechBubble*, Character* value)
{
  if(value == null)
    this._id = -1;
  else
    this._id = value.ID;
}
void setValid(this SpeechBubble*, bool value)
{ this._valid = value; }
void setBackgroundSpeech(this SpeechBubble*, bool value)
{ this._isBackgroundSpeech = value; }
void setThinking(this SpeechBubble*, bool value)
{ this._isThinking = value; }
void setAnimating(this SpeechBubble*, bool value)
{ this._isAnimating = value; }
void setTotalDuration(this SpeechBubble*, int value)
{ this._totalDuration = value; }
void setElapsedDuration(this SpeechBubble*, int value)
{ this._elapsedDuration = value; }
void setX(this SpeechBubble*, int value)
{ this._x = value; }
void setY(this SpeechBubble*, int value)
{ this._y = value; }

SpeechBubble* Create(static SpeechBubble, Character* owner, String message, DynamicSprite* bubbleSprite, GUI* bubbleGui, Overlay* bubbleOverlay)
{
  SpeechBubble* sb = new SpeechBubble;
  sb.setOwningCharacter(owner);
  sb.setValid(true);
  int id = owner.ID;
  _charBubbles[id] = sb;
  _bubbleMessages[id] = message;
  _bubbleSprites[id] = bubbleSprite;
  _bubbleOverlays[id] = bubbleOverlay;
  _bubbleGuis[id] = bubbleGui;
  return sb;
}

void _addBubbleChar(Character* c)
{
  _bubbleChars[_bubbleCount] = c;
  _bubbleCount++;
}

bool _removeBubbleChar(Character* c)
{
  if(c == null)
    return false;
  for(int i=0; i<_bubbleCount; i++)
  {
    if(_bubbleChars[i] == c)
    {
      _bubbleCount--;
      _bubbleChars[i] = _bubbleChars[_bubbleCount];
      _bubbleChars[_bubbleCount] = null;
      return true;
    }
  }
  return false;
}

void Remove(this SpeechBubble*)
{
  SpeechBubble* _this = this;
  int id = this._id;
  if(id != -1)
  {
    _removeBubbleChar(this.get_OwningCharacter());
    
    _charBubbles[id] = null;
    _bubbleMessages[id] = null;
    if(_bubbleSprites[id] != null)
      _bubbleSprites[id].Delete();
    _bubbleSprites[id] = null;
    if(_bubbleOverlays[id] != null)
      _bubbleOverlays[id].Remove();
    _bubbleOverlays[id] = null;
    if(_bubbleGuis[id] != null)
      _bubbleGuis[id].Visible = false;
    _bubbleGuis[id] = null;
  }
  this._valid = false;
}


#endregion

// Calculate the height of the character at current scaling (due to rounding, believe this could be 1 pixel off)
int GetHeight(this Character*)
{
  ViewFrame* frame = Game.GetViewFrame(this.View, this.Loop, this.Frame);
  // TODO: Check that Z value is correctly calculated
  return ((Game.SpriteHeight[frame.Graphic] + this.z) * this.Scaling)/100;
}

// Whether the character is speaking in a speech bubble (if includeBackground, count background speech as speech)
bool IsSpeakingBubble(this Character*, bool includeBackground)
{
  SpeechBubble* bubble = _charBubbles[this.ID];
  return (bubble != null && (includeBackground || !bubble.get_IsBackgroundSpeech()));
}

/// Interrupt the character if they are speaking in the background
bool StopBackgroundBubble(this Character*)
{
  SpeechBubble* bubble = _charBubbles[this.ID];
  if(bubble != null && bubble.get_Valid() && bubble.get_IsBackgroundSpeech())
  {
    if(bubble.get_IsAnimating())
      this.UnlockView();
    bubble.Remove();
    return true;
  }
  return false;
}

void _stopAllBackgroundBubbles()
{
  for(int i=_bubbleCount-1; i >= 0; i--)
  {
    int id = _bubbleChars[i].ID;
    if(_charBubbles[id].get_IsBackgroundSpeech())
      _bubbleChars[i].StopBackgroundBubble();
  }
}

/// The speech bubble used by the character (null if none)
SpeechBubble* GetSpeechBubble(this Character*)
{
  return _charBubbles[this.ID];
}

// Initializations
void initSpeechBubble()
{
  // Initialize arrays
  _bubbleChars = new Character[Game.CharacterCount];
  _charBubbles = new SpeechBubble[Game.CharacterCount];
  _bubbleMessages = new String[Game.CharacterCount];
  _bubbleSprites = new DynamicSprite[Game.CharacterCount];
  _bubbleOverlays= new Overlay[Game.CharacterCount];
  _bubbleGuis = new GUI[Game.CharacterCount];

  // Set default values
  SpeechBubble.set_InvisibleFont(-1);
  SpeechBubble.set_TextAlign(eAlignCentre);
  
  SpeechBubble.set_BackgroundColor(15);
  SpeechBubble.set_BorderColor(0);
  
  SpeechBubble.set_BackgroundTransparency(0);
  SpeechBubble.set_BorderTransparency(0);

  SpeechBubble.set_MaxTextWidth(-1);
  SpeechBubble.set_CornerRoundingRadius(8);
  SpeechBubble.set_PaddingTop(10);
  SpeechBubble.set_PaddingBottom(10);
  SpeechBubble.set_PaddingLeft(20);
  SpeechBubble.set_PaddingRight(20);
  
  _talkTail = new String[10];
  _talkTail[0] = "OOOOOOOO";
  _talkTail[1] = "XOOOOOXX";
  _talkTail[2] = "XOOOOX  ";
  _talkTail[3] = "XOOOOX  ";
  _talkTail[4] = " XOOOX  ";
  _talkTail[5] = " XOOOX  ";
  _talkTail[6] = "  XOOOX ";
  _talkTail[7] = "   XOOOX";
  _talkTail[8] = "    XXX ";
  _talkTail[9] = null;
  SpeechBubble.set_TalkTail(_talkTail); // Just to set height/width
  
  _thinkTail = new String[14];
  _thinkTail[00] = "        ";
  _thinkTail[01] = "        ";
  _thinkTail[02] = "  XX    ";
  _thinkTail[03] = " XOOX   ";
  _thinkTail[04] = "XOOOOX  ";
  _thinkTail[05] = "XOOOOX  ";
  _thinkTail[06] = " XOOX   ";
  _thinkTail[07] = "  XX    ";
  _thinkTail[08] = "        ";
  _thinkTail[09] = "    XX  ";
  _thinkTail[10] = "   XOOX ";
  _thinkTail[11] = "   XOOX ";
  _thinkTail[12] = "    XX  ";
  _thinkTail[13] = null;
  SpeechBubble.set_ThinkTail(_thinkTail); // Just to set height/width
}

function game_start()
{
  initSpeechBubble();
}

// To work around the AGS bug where antialiasing "pokes holes" in semi-transparent canvases
void drawStringWrappedAA(this DrawingSurface*, int x, int y, int width, FontType font, Alignment alignment, String message, int transparency)
{
  DynamicSprite* textSprite = DynamicSprite.Create(this.Width, this.Height, true);
  DrawingSurface* textSurface = textSprite.GetDrawingSurface();
  textSurface.DrawingColor = this.DrawingColor;
  textSurface.DrawStringWrapped(x, y, width, font, alignment, message);
  textSurface.Release();
  this.DrawImage(0, 0, textSprite.Graphic, transparency);
  textSprite.Delete();
}

// Draw a string with outline (make sure the canvas has at least outlineWidth pixels on each side of the string)
void drawStringWrappedOutline(this DrawingSurface*, int x, int y, int width, TextOutlineStyle outlineStyle, FontType font,  Alignment alignment, String message, int transparency, int outlineColor, int outlineWidth)
{
  // This is what we draw on (because we might need to copy with transparency)
  DynamicSprite* outlineSprite = DynamicSprite.Create(this.Width, this.Height, true);
  DrawingSurface* outlineSurface = outlineSprite.GetDrawingSurface();
  
  // This holds multiple horizontal copies of the text
  // We copy it multiple times (shifted vertically) onto the outlineSprite to create the outline
  DynamicSprite* outlineStripSprite = DynamicSprite.Create(this.Width, this.Height, true);
  DrawingSurface* outlineStripSurface = outlineStripSprite.GetDrawingSurface();
  
  // This is our "text stamp" that we use to draw the outline, we copy it onto outlineStripSprite
  DynamicSprite* textSprite = DynamicSprite.Create(this.Width, this.Height, true);
  DrawingSurface* textSurface = textSprite.GetDrawingSurface();
  
  // Draw our text stamp
  textSurface.DrawingColor = outlineColor;
  textSurface.DrawStringWrapped(x, y, width, font, alignment, message);
  textSurface.Release();
  
  switch(outlineStyle)
  {
    case eTextOutlineRounded:
    {
      // Draw Circular outline
      int maxSquare = outlineWidth*outlineWidth+1; // Add 1 for rounding purposes, to avoid "pointy corners" 
      int maxWidth = 0;
      outlineStripSurface.DrawImage(0, 0, textSprite.Graphic);
      // We loop from top and bottom to the middle, making the outline wider and wider, to form circular outline
      for(int i = outlineWidth; i > 0; i--)
      {
        // Here's the circular calculation...
        while(i*i + maxWidth*maxWidth <= maxSquare)
        {
          // Increase width of the outline if necessary
          maxWidth++;
          outlineStripSurface.DrawImage(-maxWidth, 0, textSprite.Graphic);
          outlineStripSurface.DrawImage(maxWidth, 0, textSprite.Graphic);
          outlineStripSurface.Release();
          outlineStripSurface = outlineStripSprite.GetDrawingSurface();
        }
        // Draw outline strip above and below
        outlineSurface.DrawImage(0, -i, outlineStripSprite.Graphic);
        outlineSurface.DrawImage(0, i, outlineStripSprite.Graphic);
      }
      // Finally the middle strip
      outlineSurface.DrawImage(0, 0, outlineStripSprite.Graphic);
      break;
    }
    case eTextOutlineSquare:
    {
      // Draw square block outline
      // Just draw the full outline width onto the strip
      for(int i = -outlineWidth; i <= outlineWidth; i++)
        outlineStripSurface.DrawImage(i, 0, textSprite.Graphic);
      outlineStripSurface.Release();
      // Draw the full outline height
      for(int j = -outlineWidth; j <= outlineWidth; j++)
        outlineSurface.DrawImage(0, j, outlineStripSprite.Graphic);
      break;
    }
  }
  textSprite.Delete();
  outlineStripSurface.Release();
  outlineStripSprite.Delete();
  
  /// Now draw the text itself on top of the outline
  outlineSurface.DrawingColor = this.DrawingColor;
  outlineSurface.drawStringWrappedAA(x, y, width, font, alignment, message, 0);
  outlineSurface.Release();
  // ... And copy it onto our canvas
  this.DrawImage(0, 0, outlineSprite.Graphic, transparency);
  outlineSprite.Delete();
}

// Draw a "bitmap" stored as an array of Strings
void drawPixelArray(this DrawingSurface*, String array[], int x, int y, int w, int h, char p, bool flipH, bool flipV)
{
  for(int i=0; i<h; i++)
  {
    for(int j=0; j<array[i].Length; j++)
    {
      char c = array[i].Chars[j];
      if(c == p)
      {
        int px; int py;
        if(flipH)
          px = x+w-j;
        else
          px = x+j;
        if(flipV)
          py = y+h-i;
        else
          py = y+i;
          
        this.DrawPixel(px, py);
      }
    }
  }
}

// Round off the corners of the bubble by erasing to transparent and drawing border
void drawRoundedCorners32(DrawingSurface* background, DrawingSurface* border, int borderColor, int top, int bottom)
{
  // Uses Bresenham's circle formula, found online
  int r = _cornerRoundingRadius;
  
  int x = 0; 
  int y = r; 
  int p = 3 - 2 * r;
  while (y >= x) // only formulate 1/8 of circle
  {
    // Erase background corners
    // Top Left
    background.DrawingColor = COLOR_TRANSPARENT;
    background.DrawLine(r - x, top+r - y, r - x, top);
    background.DrawLine(r - y, top+r - x, r - y, top);
    
    // Top Right
    background.DrawLine(border.Width-r-1 + y, top+r - x,  border.Width-r-1 + y, top);
    background.DrawLine(border.Width-r-1 + x, top+r - y,  border.Width-r-1 + x, top);
    background.DrawingColor = COLOR_TRANSPARENT;
    
    // Bottom Left
    background.DrawLine(r - x, bottom-r + y, r - x,  bottom);
    background.DrawLine(r - y, bottom-r + x, r - y,  bottom);
    
    // Bottom Right
    background.DrawLine(border.Width-r-1 + y, bottom-r + x, border.Width-r-1 + y, bottom);
    background.DrawLine(border.Width-r-1 + x, bottom-r + y, border.Width-r-1 + x, bottom);

    // Draw border
    // Top Left
    border.DrawingColor = borderColor;
    border.DrawPixel(r - x, top+r - y);//upper left left
    border.DrawPixel(r - y, top+r - x);//upper upper left
    
    // Top Right
    border.DrawPixel(border.Width-r-1 + y, top+r - x);//upper upper right
    border.DrawPixel(border.Width-r-1 + x, top+r - y);//upper right right
    
    // Bottom Left
    border.DrawPixel(r - x, bottom-r + y);//lower left left
    border.DrawPixel(r - y, bottom-r + x);//lower lower left
    
    // Bottom Right
    border.DrawPixel(border.Width-r-1 + y, bottom-r + x);//lower lower right
    border.DrawPixel(border.Width-r-1 + x, bottom-r + y);//lower right right

    if (p < 0)
    {
      p += 4*x + 6;
      x++;
    }
    else
    {
      p += 4*(x - y) + 10;
      x++;
      y--;
    }
   } 
}

// Find the actual width of a text that has been linewrapped to maxTextWidth
int calculateExactTextWidth(String message, FontType font, int maxTextWidth, int maxHeight)
{
  // Binary search to find the minimum width, by trying the midpoint (rounding down)
  // between the smallest width we know to be working and the biggest we know to be too small,
  // until there's only a 1 pixel difference
  int cut = maxTextWidth;
  int height = maxHeight;
  while(cut>1)
  {
    cut = (cut+1) >> 1; // Subtract half as much as we tried last time, rounding up
    height = GetTextHeight(message, font, maxTextWidth-cut);
    if(height == maxHeight)
      maxTextWidth -= cut;
  }
  // ... one last time
  height = GetTextHeight(message, font, maxTextWidth-1);
  if(height == maxHeight)
    return maxTextWidth-1;
  else
    return maxTextWidth;
}

// AGS's formula for character speech width
int calculateDefaultTextWidth(Character* c)
{
  int w = System.ViewportWidth * 2/3;
  if(c.x - GetViewportX() <= System.ViewportWidth/4 || c.x - GetViewportX() >= System.ViewportWidth * 3/4)
    w -= System.ViewportWidth/5;
  return w;
}

// Draw a speech bubble in 32-bit (using transparency)
DynamicSprite* renderBubble32(this Character*, String message, bool talkTail)
{
  // Calculate text dimensions
  int textWidth = _maxTextWidth;
  if(textWidth <= 0)
    textWidth = calculateDefaultTextWidth(this);
  textWidth = _minInt(textWidth, System.ViewportWidth - _paddingLeft - _paddingRight);
  int textHeight = GetTextHeight(message, Game.SpeechFont, textWidth);
  textWidth = calculateExactTextWidth(message, Game.SpeechFont, textWidth, textHeight);
  
  // Calculate bubble dimensions
  int totalWidth = textWidth + _paddingLeft + _paddingRight;
  int bubbleHeight = textHeight + _paddingTop + _paddingBottom;
  int totalHeight;
  if(talkTail)
    totalHeight = bubbleHeight + _talkTailHeight;
  else
    totalHeight = bubbleHeight + _thinkTailHeight;
  
  // Set up the canvases
  DynamicSprite* bubbleSprite = DynamicSprite.Create(totalWidth, totalHeight, true);
  DrawingSurface* bubbleSurface = bubbleSprite.GetDrawingSurface();
  //bubbleSurface.Clear();
  
  DynamicSprite* bgSprite; DrawingSurface* bgSurface;
  DynamicSprite* borderSprite; DrawingSurface* borderSurface;
  if(_backgroundTransparency == 0)
  {
    bgSprite = bubbleSprite;
    bgSurface = bubbleSurface;
  }
  else
  {
    bgSprite = DynamicSprite.Create(totalWidth, totalHeight, true);
    bgSurface = bgSprite.GetDrawingSurface();
  }
  if(_borderTransparency == 0)
  {
    borderSprite = bubbleSprite;
    borderSurface = bubbleSurface;
  }
  else
  {
    borderSprite = DynamicSprite.Create(totalWidth, totalHeight, true);
    borderSurface = borderSprite.GetDrawingSurface();
  }
  
  int bgColor = mixColors(this.SpeechColor, _backgroundColor, _backgroundSpeechTint);
  int borderColor = mixColors(this.SpeechColor, _borderColor, _borderSpeechTint);
  
  // Draw!
  bgSurface.DrawingColor = bgColor;
  bgSurface.DrawRectangle(1, 1, totalWidth-2, bubbleHeight-1);
  drawRoundedCorners32(bgSurface, borderSurface, borderColor, 0, bubbleHeight);
  String tail[]; int tailWidth; int tailHeight;
  if(talkTail)
  {
    tail = _talkTail; tailWidth = _talkTailWidth; tailHeight = _talkTailHeight;
  }
  else
  {
    tail = _thinkTail; tailWidth = _thinkTailWidth; tailHeight = _thinkTailHeight;
  }
  bgSurface.DrawingColor = bgColor;
  bgSurface.drawPixelArray(tail, totalWidth/2-tailWidth, bubbleHeight, tailWidth, tailHeight, 'O', false, false);
  borderSurface.DrawingColor = borderColor;
  borderSurface.drawPixelArray(tail, totalWidth/2-tailWidth, bubbleHeight, tailWidth, tailHeight, 'X', false, false);
  borderSurface.DrawLine(_cornerRoundingRadius, 0, totalWidth - _cornerRoundingRadius, 0);
  // Left Line
  borderSurface.DrawLine(0, _cornerRoundingRadius, 0, bubbleHeight - _cornerRoundingRadius);
  // Right Line
  borderSurface.DrawLine(totalWidth-1, _cornerRoundingRadius, totalWidth-1, bubbleHeight - _cornerRoundingRadius);
  // Bottom Lines
  borderSurface.DrawLine(_cornerRoundingRadius, bubbleHeight, totalWidth/2 - tailWidth, bubbleHeight);
  borderSurface.DrawLine(totalWidth/2, bubbleHeight, totalWidth - _cornerRoundingRadius, bubbleHeight);
  
  if(_backgroundTransparency != 0)
  {
    bgSurface.Release();
    bubbleSurface.DrawImage(0, 0, bgSprite.Graphic, _backgroundTransparency);
    bgSprite.Delete();
  }
  if(_borderTransparency != 0)
  {
    borderSurface.Release();
    bubbleSurface.DrawImage(0, 0, borderSprite.Graphic, _borderTransparency);
    borderSprite.Delete();
  }
  
  bubbleSurface.DrawingColor = this.SpeechColor;
  int outlineColor = mixColors(this.SpeechColor, _textOutlineColor, _textOutlineSpeechTint);
  if(_textOutlineWidth > 0)
    bubbleSurface.drawStringWrappedOutline(_paddingLeft, _paddingTop, textWidth, _textOutlineStyle, Game.SpeechFont, _textAlign, message, _textTransparency, outlineColor, _textOutlineWidth);
  else
    bubbleSurface.drawStringWrappedAA(_paddingLeft, _paddingTop, textWidth, Game.SpeechFont, _textAlign, message, _textTransparency);
  
  bubbleSurface.Release();
  return bubbleSprite;
}

// Whether a speech string has a voice clip ID
bool hasVoiceClip(String message)
{
  return (message != null && message.Length>1 && message.Chars[0] == '&' && message.Chars[1] >= '0' && message.Chars[1] <= '9');
}

// Get the voice clip ID (speech line number) of a speech string, in the "&123" string format
String getLineNumber(String message)
{
  if(hasVoiceClip(message))
  {
    String s = message.Substring(1, message.Length-1);
    int n = s.AsInt;
    return String.Format("&%d", n);
  }
  return null;
}

int calculateDuration(String message)
{
  return _maxInt((Game.MinimumTextDisplayTimeMs * GetGameSpeed()) / 1000,
                ((message.Length / Game.TextReadingSpeed) + 1) * GetGameSpeed());
}

int calculateSpeechPause()
{
  return (Speech.DisplayPostTimeMs * GetGameSpeed())/1000;
}

// Run the character's speech animation and block for the appropriate time. Returns whether interrupted
bool animateSpeech(this Character*, String message)
{
  if(this.Moving)
    this.StopMoving();
  
  if(this.SpeechView > 0)
  {
    this.LockView(this.SpeechView);
    if(Game.GetFrameCountForLoop(this.SpeechView, this.Loop) > 1)
      this.Animate(this.Loop, this.SpeechAnimationDelay, eRepeat, eNoBlock, eForwards);
  }
  
  int speechDuration = calculateDuration(message);
  if(BlockSpeech(speechDuration, true) == eBlockTimeOut)
  {
    this.UnlockView();
    int speechPause = calculateSpeechPause();
    return (BlockSpeech(speechPause, false) != eBlockTimeOut);
  }
  else
  {
    this.UnlockView();
    return false;
  }
}

void realSayAtBubble(this Character*, int x, int y, String message, GUI* bubbleGui, DynamicSprite* bubbleSprite)
{
  // Render and display the speech bubble
  if(bubbleSprite == null)
    bubbleSprite = this.renderBubble32(message, true);
  Overlay* bubbleOverlay;
  if(bubbleGui == null && _defaultGui == null)
    bubbleOverlay = Overlay.CreateGraphical(x, y, bubbleSprite.Graphic, true);
  else
  {
    if(bubbleGui == null)
      bubbleGui = _defaultGui;
      
    bubbleGui.Clickable = false;
    bubbleGui.X = _clampInt(x, 0, System.ViewportWidth - bubbleSprite.Width);
    bubbleGui.Y = _clampInt(y, 0, System.ViewportHeight - bubbleSprite.Height);
    bubbleGui.Width = bubbleSprite.Width;
    bubbleGui.Height = bubbleSprite.Height;
    bubbleGui.BackgroundGraphic = bubbleSprite.Graphic;
    bubbleGui.Transparency = 0;
    bubbleGui.Visible = true;
  }
  SpeechBubble* bubble = SpeechBubble.Create(this, message, bubbleSprite, bubbleGui, bubbleOverlay);
  
  bubble.setX(x);
  bubble.setY(y);
  bubble.setBackgroundSpeech(false);
  bubble.setThinking(false);
  _addBubbleChar(this);
  
  // Play speech (this chunk blocks until speech is complete)

  String lineNumber = getLineNumber(message);
  // If we have set an invisible font, just call Say() - or whatever custom Say() implementation we have
  if(SpeechBubble.get_InvisibleFont() != -1)
  {
    FontType speechFont = Game.SpeechFont;
    Game.SpeechFont = _invisibleFont;
    this.SB_sayImpl(message);
    Game.SpeechFont = speechFont;
  }
  // Else if we're going to play a voice clip, call Say() with the clip number and a blank line of text
  // (takes care of animation and doesn't display any text). This doesn't work with text-based lip-sync,
  // so if you're using text-based lip-sync, you MUST set an invisible font to get lip-sync to work
  else if(lineNumber != null && Speech.VoiceMode != eSpeechTextOnly) // && !GetGameOption(OPT_LIPSYNCTEXT))
  {
    String s = lineNumber;
    while(s.Length < message.Length)
      s = s.AppendChar(' ');
    this.SB_sayImpl(s);
  }
  // Otherwise we have to do it manually...
  else
  {
    bubble.setAnimating(true);
    this.animateSpeech(message);
  }
  
  // Remove the bubble
  bubble.Remove();
}

void SayBubble(this Character*, String message, GUI* bubbleGui)
{
  if(message == null) return;
  if(!game.bgspeech_stay_on_display)
    _stopAllBackgroundBubbles();
  if((Speech.VoiceMode == eSpeechVoiceOnly && hasVoiceClip(message)) || message == "...")
    this.SB_sayImpl(message);
  else
  {
    DynamicSprite* bubbleSprite = this.renderBubble32(message, true);
    // Position bubble over character head
    int x = this.x - GetViewportX() - bubbleSprite.Width/2;
    x = _clampInt(x, 0, System.ViewportWidth - bubbleSprite.Width);
    int y = this.y - GetViewportY() - bubbleSprite.Height - this.GetHeight() - (_heightOverHead - _talkTailHeight + 1);
    y = _clampInt(y, 0, System.ViewportHeight - bubbleSprite.Height);

    this.realSayAtBubble(x, y, message, bubbleGui, bubbleSprite);
  }
}

void SayAtBubble(this Character*, int x, int y, String message, GUI* bubbleGui)
{
  if(message == null) return;
  if(!game.bgspeech_stay_on_display)
    _stopAllBackgroundBubbles();
  if((Speech.VoiceMode == eSpeechVoiceOnly && hasVoiceClip(message)) || message == "...")
    this.SB_sayImpl(message);
  else
    this.realSayAtBubble(x, y, message, bubbleGui, null);
}

SpeechBubble* SayBackgroundBubble(this Character*, String message, bool animate, GUI* bubbleGui)
{
  if(message == null)
    return null;
    
  this.StopBackgroundBubble();
  DynamicSprite* bubbleSprite = this.renderBubble32(message, true);
  int x = this.x - GetViewportX() - bubbleSprite.Width/2;
  x = _clampInt(x, 0, System.ViewportWidth - bubbleSprite.Width);
  int y = this.y - GetViewportY() - bubbleSprite.Height - this.GetHeight() - (_heightOverHead - _talkTailHeight + 1);
  y = _clampInt(y, 0, System.ViewportHeight - bubbleSprite.Height);

  Overlay* bubbleOverlay;
  if(bubbleGui == null)
    bubbleOverlay = Overlay.CreateGraphical(x, y, bubbleSprite.Graphic, true);
  else
  {
    bubbleGui.Clickable = false;
    bubbleGui.X = _clampInt(x, 0, System.ViewportWidth - bubbleSprite.Width);
    bubbleGui.Y = _clampInt(y, 0, System.ViewportHeight - bubbleSprite.Height);
    bubbleGui.Width = bubbleSprite.Width;
    bubbleGui.Height = bubbleSprite.Height;
    bubbleGui.BackgroundGraphic = bubbleSprite.Graphic;
    bubbleGui.Transparency = 0;
    bubbleGui.Visible = true;
  }
  SpeechBubble* bubble = SpeechBubble.Create(this, message, bubbleSprite, bubbleGui, bubbleOverlay);
  bubble.setX(x);
  bubble.setY(y);
  bubble.setBackgroundSpeech(true);
  bubble.setThinking(false);
  bubble.setTotalDuration(calculateDuration(message));
  bubble.setAnimating(animate);
  
  // Play animation
  if(animate && !this.SB_sayBackgroundAnimateImpl(message))
  {            
    if(this.Moving)
      this.StopMoving();
    
    if(this.SpeechView > 0)
    {
      this.LockView(this.SpeechView);
      if(Game.GetFrameCountForLoop(this.SpeechView, this.Loop) > 1)
        this.Animate(this.Loop, this.SpeechAnimationDelay, eRepeat, eNoBlock, eForwards);
    }
  }
  // Add to stack of running Speech Bubbles to update
  _addBubbleChar(this);
  
  // The background speech is terminated in StopBackgroundBubble(), called from repeatedly_execute()
}

// TODO
void ThinkBubble(this Character*, String message, GUI* bubbleGui)
{
}

function repeatedly_execute()
{
  int speechPause = calculateSpeechPause();
  // Update the time elapsed on running bubbles, remove background bubbles that have timed out
  for(int i=0; i<_bubbleCount; i++)
  {
    int id = _bubbleChars[i].ID;
    _charBubbles[id].setElapsedDuration(_charBubbles[id].get_ElapsedDuration() + 1);
    if(_charBubbles[id].get_IsBackgroundSpeech() && _charBubbles[id].get_ElapsedDuration() > _charBubbles[id].get_TotalDuration())
    {
      // Add the post-display time
      if(speechPause > 0 && _charBubbles[id].get_IsAnimating())
      {
        _bubbleChars[i].UnlockView();
        _charBubbles[id].setAnimating(false);
        _charBubbles[id].setTotalDuration(speechPause);
        _charBubbles[id].setElapsedDuration(0);
      }
      else
        _bubbleChars[i].StopBackgroundBubble();
    }
  }
}

function repeatedly_execute_always()
{
  _block_always();
} L;  /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * SPEECH BUBBLE MODULE - Header                                                           *
 * by Gunnar Harboe (Snarky), v0.8.0                                                       *
 *                                                                                         *
 * Copyright (c) 2017 Gunnar Harboe                                                        *
 *                                                                                         *
 * This module allows you to display conversation text in comic book-style speech bubbles. *
 * The appearance of the speech bubbles can be extensively customized.                     *
 *                                                                                         *
 * GitHub repository:                                                                      *
 * https://github.com/messengerbag/SpeechBubble                                            *
 *                                                                                         *
 * AGS Forum thread:                                                                       *
 * http://www.adventuregamestudio.co.uk/forums/index.php?topic=55542                       *
 *                                                                                         *
 * THIS MODULE IS UNFINISHED. SOME FEATURES ARE NOT YET IMPLEMENTED,                       *
 * AND OTHERS MAY CHANGE BEFORE THE FINAL RELEASE.                                         *
 *                                                                                         *
 * To use, you call Character.SayBubble(). For example:                                    *
 *                                                                                         *
 *     player.SayBubble("This line will be said in a speech bubble");                      *
 *                                                                                         *
 * You can also use Character.SayAtBubble() to position the bubble elsewhere on screen,    *
 * and Character.SayBackgroundBubble() for non-blocking speech.                            *
 * Character.ThinkBubble() IS NOT YET IMPLEMENTED.                                         *
 *                                                                                         *
 * To configure the appearance of the speech bubbles, you set the SpeechBubble properties. *
 * This is usually best done in GlobalScript game_start(). For example:                    *
 *                                                                                         *
 *   function game_start()                                                                 *
 *   {                                                                                     *
 *     SpeechBubble.BorderColor = Game.GetColorFromRGB(0,128,0);                           *
 *     SpeechBubble.BackgroundColor = Game.GetColorFromRGB(128,255,128);                   *
 *     SpeechBubble.BackgroundTransparency = 33;                                           *
 *     SpeechBubble.PaddingTop = 5;                                                        *
 *     SpeechBubble.PaddingBottom = 5;                                                     *
 *     SpeechBubble.PaddingLeft = 15;                                                      *
 *     SpeechBubble.PaddingRight = 15;                                                     *
 *     // Other code                                                                       *
 *   }                                                                                     *
 *                                                                                         *
 * See the declaration below for the full list and explanation of the properties.          *
 *                                                                                         *
 * The module relies on built-in AGS settings as far as possible. In particular, it uses   *
 * these settings to customize the appearance and behavior of the speech bubbles:          *
 *                                                                                         *
 * - Character.SpeechColor                                                                 *
 * - game.bgspeech_stay_on_display                                                         *
 * - Game.MinimumTextDisplayTimeMs                                                         *
 * - Game.SpeechFont                                                                       *
 * - Game.TextReadingSpeed                                                                 *
 * - Speech.DisplayPostTimeMs                                                              *
 * - Speech.SkipStyle                                                                      *
 * - Speech.VoiceMode                                                                      *
 *                                                                                         *
 * Note that to get text-based lip sync to work, you need to provide an invisible font,    *
 * and set the SpeechBubble.InvisibleFont property accordingly. You may download one here: *
 *                                                                                         *
 *   http://www.angelfire.com/pr/pgpf/if.html                                              *
 *                                                                                         *
 * Finally, the module (usually) calls Character.Say() to render speech animation and play *
 * voice clips. If you are already using some custom Say module (e.g. TotalLipSync), you   *
 * may want to call a custom Say() function instead. To do this, simply change the         *
 * function call in SB_sayImpl() at the top of SpeechBubble.asc.                           *
 *                                                                                         *
 * This code is offered under the MIT License                                              *
 * https://opensource.org/licenses/MIT                                                     *
 *                                                                                         *
 * It is also licensed under a Creative Commons Attribution 4.0 International License.     *
 * https://creativecommons.org/licenses/by/4.0/                                            *
 *                                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/// The shape of a text outline
enum TextOutlineStyle
{
  /// A circular, rounded outline
  eTextOutlineRounded = 0, 
  /// A square "block" outline
  eTextOutlineSquare
};

/// Speech bubble settings
managed struct SpeechBubble
{
  #region Static Properties
  /// The GUI that will be used to display blocking bubbles if no GUI argument is passed. Default: null (use overlays) 
  import static attribute GUI* DefaultGui;              // $AUTOCOMPLETESTATICONLY$
  /// The background color of speech bubbles (an AGS color number). Default: 15 (white) 
  import static attribute int BackgroundColor;          // $AUTOCOMPLETESTATICONLY$
  /// The percentage by which speech bubble backgrounds are tinted by the speech color (0-100). Default: 0
  import static attribute int BackgroundSpeechTint;          // $AUTOCOMPLETESTATICONLY$
  /// The transparency of the speech bubble backgrounds (0-100). Default: 0
  import static attribute int BackgroundTransparency;   // $AUTOCOMPLETESTATICONLY$
  /// The border color of speech bubbles (an AGS color number). Default: 0 (black)
  import static attribute int BorderColor;              // $AUTOCOMPLETESTATICONLY$
  /// The percentage by which speech bubble borders are tinted by the speech color (0-100). Default: 0
  import static attribute int BorderSpeechTint;          // $AUTOCOMPLETESTATICONLY$
  /// The transparency of the speech bubble borders (0-100). Default: 0
  import static attribute int BorderTransparency;       // $AUTOCOMPLETESTATICONLY$
  /// The transparency of speech bubble text (0-100). Default: 0
  import static attribute int TextTransparency;         // $AUTOCOMPLETESTATICONLY$
  
  /// The color of any outline applied to speech bubble text (an AGS color number). Default: 0 (black)
  import static attribute int TextOutlineColor;         // $AUTOCOMPLETESTATICONLY$
  /// The percentage by which text outlines are tinted by the speech color (0-100). Default: 0
  import static attribute int TextOutlineSpeechTint;         // $AUTOCOMPLETESTATICONLY$
  /// The width of the outline applied to speech bubble text. Default: 0 (none)
  import static attribute int TextOutlineWidth;         // $AUTOCOMPLETESTATICONLY$
  /// The style of the outline applied to speech bubble text. Default: eTextOutlineRounded
  import static attribute TextOutlineStyle TextOutlineStyle;         // $AUTOCOMPLETESTATICONLY$
  
  /// How wide a line of text can be before it wraps. Add left+right padding for total speech bubble width. If <= 0, use default AGS text wrapping. Default: 0
  import static attribute int MaxTextWidth;             // $AUTOCOMPLETESTATICONLY$
  /// Pixels between the text and the top of speech bubbles. Default: 10
  import static attribute int PaddingTop;               // $AUTOCOMPLETESTATICONLY$
  /// Pixels between the text and the bottom of speech bubbles. Default: 10
  import static attribute int PaddingBottom;            // $AUTOCOMPLETESTATICONLY$
  /// Pixels between the text and the left of speech bubbles. Default: 20
  import static attribute int PaddingLeft;              // $AUTOCOMPLETESTATICONLY$
  /// Pixels between the text and the right of speech bubbles. Default: 20
  import static attribute int PaddingRight;             // $AUTOCOMPLETESTATICONLY$
  /// Pixels between the top of the character sprite and the bottom of the speech bubble tail (can be negative)
  import static attribute int HeightOverHead;           // $AUTOCOMPLETESTATICONLY$
  /// How many pixels to round the corners of the speech bubble by. Default: 8
  import static attribute int CornerRoundingRadius;     // $AUTOCOMPLETESTATICONLY$
  
  /// The speech bubble "tail" to use for talk bubbles ("Say" functions), as a String "pixel array". Must be null-terminated!
  import static attribute String TalkTail[];            // $AUTOCOMPLETESTATICONLY$
  /// Get the width of the speech bubble tail for talk bubbles
  import readonly static attribute int TalkTailWidth;   // $AUTOCOMPLETESTATICONLY$
  /// Get the height of the speech bubble tail for talk bubbles
  import readonly static attribute int TalkTailHeight;  // $AUTOCOMPLETESTATICONLY$
  /// The speech bubble "tail" to use for thought bubbles ("Think" function), as a String "pixel array". Must be null-terminated!
  import static attribute String ThinkTail[];           // $AUTOCOMPLETESTATICONLY$
  /// Get the width of the speech bubble tail for think bubbles
  import readonly static attribute int ThinkTailWidth;  // $AUTOCOMPLETESTATICONLY$
  /// Get the height of the speech bubble tail for think bubbles
  import readonly static attribute int ThinkTailHeight; // $AUTOCOMPLETESTATICONLY$
  
  /// The text alignment in speech bubbles. Default: eAlignCentre
  import static attribute Alignment TextAlign;          // $AUTOCOMPLETESTATICONLY$
  /// Set a font where all characters are invisible, to improve integration. Default: -1 (none) 
  import static attribute FontType InvisibleFont;       // $AUTOCOMPLETESTATICONLY$
  #endregion
  
  #region Instance Properties
  /// Get the Character that this speech bubble belongs to
  import readonly attribute Character* OwningCharacter;
  /// Get whether this speech bubble is valid (not removed from screen)
  import readonly attribute bool Valid;
  /// Get whether this speech bubble is displaying non-blocking background speech
  import readonly attribute bool IsBackgroundSpeech;
  /// Get whether this is a thought bubble
  import readonly attribute bool IsThinking;
  /// Get whether this speech bubble is displayed on a GUI
  import readonly attribute bool UsesGUI;
  /// Get whether the character is being (manually) animated
  import readonly attribute bool Animating;
  /// Get the text of this speech bubble
  import readonly attribute String Text;
  /// Get the rendered version of this speech bubble, as a DynamicSprite
  import readonly attribute DynamicSprite* BubbleSprite;
  /// Get the Overlay this speech bubble is rendered on (null if none)
  import readonly attribute Overlay* BubbleOverlay;
  /// Get the GUI this speech bubble is rendered on (null if none)
  import readonly attribute GUI* BubbleGUI;
  /// Get the total number of game loops this speech bubble is displayed before it times out (-1 if no timeout)
  import readonly attribute int TotalDuration;
  /// Get how many game loops this speech bubble has been displayed
  import readonly attribute int ElapsedDuration;
  /// Get/set the X screen-coordinate of this speech bubble's top-left corner
  import attribute int X;
  /// Get/set the Y screen-coordinate of this speech bubble's top-left corner
  import attribute int Y;
  #endregion
  
  #region Protected member variables
  // The underlying variables for the instance properties
  protected int _id;
  protected bool _valid;
  protected bool _isBackgroundSpeech;
  protected bool _isThinking;
  protected bool _isAnimating;
  protected bool _usesGui;
  protected int _totalDuration;
  protected int _elapsedDuration;
  protected int _x;
  protected int _y;
  #endregion
};

#region Character Extender functions
/// Like Character.Say(), but using a speech bubble.
import void SayBubble(this Character*, String message, GUI* bubbleGui=0);
/// Like SayBubble(), but the bubble will be positioned with the top-left corner at the given coordinates
import void SayAtBubble(this Character*, int x, int y, String message, GUI* bubbleGui=0);
/// Non-blocking speech, similar to SayBackground() - if animate is true, will play the speech animation
import SpeechBubble* SayBackgroundBubble(this Character*, String message, bool animate=true, GUI* bubbleGui=0);
/// Like Character.Think(), but using this module's thought bubble
import void ThinkBubble(this Character*, String message, GUI* bubbleGui=0);

/// The current height of the character (pixels from the Character.x position to the top of their sprite)
import int GetHeight(this Character*);
/// Interrupt the character if they are speaking in the background (returns whether they were)
import bool StopBackgroundBubble(this Character*);
/// Whether the character is speaking in a bubble
import bool IsSpeakingBubble(this Character*, bool includeBackground=true);
/// The speech bubble used by the character (null if none)
import SpeechBubble* GetSpeechBubble(this Character*);
#endregion
 <0        ej��