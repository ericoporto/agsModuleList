AGSScriptModule    Ivan Mogilko Module performs continious text typing over time, in typewriter style TypedText 0.7.0 �x  /////////////////////////////////////////////////////////////////////////////
//
// TypedTextUtils class
//
/////////////////////////////////////////////////////////////////////////////
// Internal data container
struct TypedTextUtilsImpl
{
  String MetricsTestString;
  String SplitHintCharacters;
};
TypedTextUtilsImpl TTUtils;

//===========================================================================
//
// TypedTextUtils::SplitHintCharacters property
//
//===========================================================================
String get_SplitHintCharacters(this TypedTextUtils*)
{
  return TTUtils.SplitHintCharacters;
}

void set_SplitHintCharacters(this TypedTextUtils*, String value)
{
  TTUtils.SplitHintCharacters = value;
}

//===========================================================================
//
// TypedTextUtils::GetFontHeight property
//
//===========================================================================
static int TypedTextUtils::GetFontHeight(FontType font)
{
  return GetTextHeight(TTUtils.MetricsTestString, font, 1000);
}

//===========================================================================
//
// TypedTextUtils::SplitText
//
// Splits the long text into lines, that fit into bounding rectangle, by
// inserting AGS line break ('[') into them. This will help detect end of
// lines for both built-in classes, like Labels, and custom renderers.
//
//===========================================================================
#define LINE_BREAK '['
static String TypedTextUtils::SplitText(String text, int max_width, FontType font, int max_height, int line_height, int max_lines)
{
  //Display("TypedTextUtils::SplitText: %s", text);
  if (String.IsNullOrEmpty(text))
    return text;

  if (max_width <= 0)
    return "";

  if (max_height != SCR_NO_VALUE || max_lines != SCR_NO_VALUE)
  {
    if (line_height == SCR_NO_VALUE)
      line_height = TypedTextUtils.GetFontHeight(font);

    if (max_lines == SCR_NO_VALUE)
      max_lines = max_height / line_height;
    else if (max_height == SCR_NO_VALUE)
      max_height = max_lines * line_height;
    else
    {
      int real_max_lines = max_height / line_height;
      if (real_max_lines < max_lines)
        max_lines = real_max_lines;
    }
  }
  
  String split_text = "";
  int line_count = 0;            // number of lines
  int line_start = 0;            // first character in line
  
  // Text parsing & splitting loop
  while ((max_lines == SCR_NO_VALUE || line_count < max_lines) && line_start < text.Length)
  {
    int  line_end = line_start;  // first character beyond parsed line 
    int  line_width = 0;         // width of the current line
    int  last_break_index = -1;  // last found character that may serve as linebreak;
    bool line_break = false;     // if actual line breaker was met
    
    // Searching for a point of breaking the line
    while (!line_break && line_end < text.Length && line_width <= max_width)
    {
      String cur_char = text.Substring(line_end, 1); // current character
      if (cur_char.Chars[0] == LINE_BREAK)
      {
        line_break = true; // found the actual linebreak character, break immediately
      }
      else
      {
        // Measure the current line length
        line_width = GetTextWidth(text.Substring(line_start, line_end - line_start), font);
        if (line_width <= max_width)
        {
          // If line width still fits into the width, check for any character that can be
          // used as a breaking one, and remember it for the future.
          if (TTUtils.SplitHintCharacters.IndexOf(cur_char) >= 0)
          {
            last_break_index = line_end;
          }
          line_end++;
        }
      }
    }
    
    // Move line end to just beyond the last found breakchar, if any
    if (last_break_index >= line_start)
      line_end = last_break_index + 1;

    if (split_text.Length > 0)
      split_text = split_text.AppendChar(LINE_BREAK);
    String s = text.Substring(line_start, line_end - line_start);
    //Display("TypedTextUtils::SplitText: appended %s", s);
    split_text = split_text.Append(s);
    
    line_count++;
    line_start = line_end;
    if (line_break)
      line_start++; // skip break char, if there was one
    line_end = line_start;
  }
  // Return the final string
  //Display("TypedTextUtils::SplitText: return %s", split_text);
  return split_text;
}


/////////////////////////////////////////////////////////////////////////////
//
// TypedText class
//
/////////////////////////////////////////////////////////////////////////////

//===========================================================================
//
// TypedText::_Clear()
//
//===========================================================================
protected void TypedText::_Clear()
{
  this._full = "";
  this._cur = "";
  this._last = "";
  this._paused = false;
  this._typeTimer = 0;
  this._caretFlashTimer = 0;
  this._readerTimer = 0;
  this._justTyped = false;
  this._hasChanged = true;
}

//===========================================================================
//
// TypedText::Clear()
//
//===========================================================================
void TypedText::Clear()
{
  this._Clear();
}

//===========================================================================
//
// TypedText::GetDelayForChar()
//
// Returns delay (in ticks) after the given character.
//
//===========================================================================
int GetDelayForChar(this TypedText*, char c)
{
  int delay = Random(this._typeDelayMax - this._typeDelayMin) + this._typeDelayMin;
  if (c == ' ')
  {
    if (this._typeDelayStyle == eTypedDelay_LongSpace)
      delay = delay * 2;
    else if (this._typeDelayStyle == eTypedDelay_ShortSpace)
      delay = delay / 2;
    else if (this._typeDelayStyle == eTypedDelay_Mixed)
    {
      int r = Random(2);
      if (r == 0)
        delay = delay * 2;
      else if (r == 1)
        delay = delay / 2;
    }
  }
  else if (c == LINE_BREAK)
  {
    if (this._typeDelayStyle == eTypedDelay_LongSpace)
      delay = delay * 4;
    else if (this._typeDelayStyle == eTypedDelay_ShortSpace ||
             this._typeDelayStyle == eTypedDelay_Uniform)
      delay = delay * 2;
    else if (this._typeDelayStyle == eTypedDelay_Mixed)
    {
      int r = Random(2);
      if (r == 0)
        delay = delay * 4;
    }
  }
  return delay;
}

//===========================================================================
//
// TypedText::BeginTyping()
// Sets up TypingText to continue typing.
//
//===========================================================================
void BeginTyping(this TypedText*)
{
  this._typeTimer = this.GetDelayForChar(0);
  this._caretFlashTimer = this._caretOffTime + this._caretOnTime;
  this._readerTimer = this._full.Length * this._textReadTime;
  this._justTyped = false;
  this._paused = false;
}

//===========================================================================
//
// TypedText::PauseTyping()
// Sets up TypingText to pause typing.
//
//===========================================================================
void PauseTyping(this TypedText*)
{
  this._paused = true;
}

//===========================================================================
//
// TypedText::_Start()
//
//===========================================================================
protected void TypedText::_Start(String text)
{
  this.Clear();
  this._full = text;
  this._hasChanged = true;
  this.BeginTyping(); // reset typing iterator and timers
}

//===========================================================================
//
// TypedText::Start()
//
//===========================================================================
void TypedText::Start(String text)
{
  this._Start(text);
}

//===========================================================================
//
// TypedText::Skip()
//
//===========================================================================
void TypedText::Skip()
{
  this._cur = this._full;
  this._justTyped = false;
  this._hasChanged = true;
}

//===========================================================================
//
// TypedText::_Tick()
//
//===========================================================================
protected void TypedText::_Tick()
{
  // Reset one-tick events
  bool had_just_typed = this._justTyped;
  this._justTyped = false;
  this._justFinishedTyping = false;
  
  if (String.IsNullOrEmpty(this._full))
    return; // nothing to update

  if (this._paused)
    return; // paused, don't do anything

  // Update reader timer
  if (this._readerTimer > 0)
    this._readerTimer--;

  // Update text's state
  if (this._cur.Length < this._full.Length)
  {
    if (this._typeTimer <= 0)
    {
      // Type next part of the string
      char c = this._full.Chars[this._cur.Length];
      this._last = String.Format("%c", c);
      this._cur = this._cur.Append(this._last);
      // Signal that we just appended text
      this._justTyped = true;
        
      if (this._cur.Length < this._full.Length)
      {
        // Set up type timer
        this._typeTimer = this.GetDelayForChar(c);
      }
      
      // Reset flashing timer
      this._caretFlashTimer = this._caretOffTime + this._caretOnTime;
      this._hasChanged = true;
      return;
    }
    else
    {
      // Advance type timer
      this._typeTimer--;
    }
  }
  else if (had_just_typed)
  {
    // Rise just ended event
    this._justFinishedTyping = true;
  }
  
  // If no typing was done recently, do caret flashing
  if (this._caretFlashTimer <= 0)
    this._caretFlashTimer = this._caretOffTime + this._caretOnTime;
  else
    this._caretFlashTimer--;
  this._hasChanged = true;
}

//===========================================================================
//
// TypedText::Tick()
//
//===========================================================================
void TypedText::Tick()
{
  this._Tick();
}

//===========================================================================
//
// TypedText::TypeDelay property
//
//===========================================================================
int get_TypeDelay(this TypedText*)
{
  if (this._typeDelayMin == this._typeDelayMax)
    return this._typeDelayMin;
  return -1;
}

void set_TypeDelay(this TypedText*, int value)
{
  this._typeDelayMin = value;
  this._typeDelayMax = value;
}

//===========================================================================
//
// TypedText::TypeDelayMin property
//
//===========================================================================
int get_TypeDelayMin(this TypedText*)
{
  return this._typeDelayMin;
}

void set_TypeDelayMin(this TypedText*, int value)
{
  this._typeDelayMin = value;
  if (this._typeDelayMin > this._typeDelayMax)
  {
    this._typeDelayMax = value;
    this._typeDelayMin = this._typeDelayMax;
  }
}

//===========================================================================
//
// TypedText::TypeDelayMax property
//
//===========================================================================
int get_TypeDelayMax(this TypedText*)
{
  return this._typeDelayMin;
}

void set_TypeDelayMax(this TypedText*, int value)
{
  this._typeDelayMax = value;
  if (this._typeDelayMax < this._typeDelayMin)
  {
    this._typeDelayMin = value;
    this._typeDelayMax = this._typeDelayMin;
  }
}

//===========================================================================
//
// TypedText::TypeDelayStyle property
//
//===========================================================================
TypedDelayStyle get_TypeDelayStyle(this TypedText*)
{
  return this._typeDelayStyle;
}

void set_TypeDelayStyle(this TypedText*, TypedDelayStyle value)
{
  if (value < eTypedDelay_Uniform || value > eTypedDelay_Mixed)
    AbortGame("Unknown delay style ID = %d", value);
  this._typeDelayStyle = value;
}

//===========================================================================
//
// TypedText::CaretFlashOnTime property
//
//===========================================================================
int get_CaretFlashOnTime(this TypedText*)
{
  return this._caretOnTime;
}

void set_CaretFlashOnTime(this TypedText*, int value)
{
  this._caretOnTime = value;
}

//===========================================================================
//
// TypedText::CaretFlashOffTime property
//
//===========================================================================
int get_CaretFlashOffTime(this TypedText*)
{
  return this._caretOffTime;
}

void set_CaretFlashOffTime(this TypedText*, int value)
{
  this._caretOffTime = value;
}

//===========================================================================
//
// TypedText::TextReadTime property
//
//===========================================================================
int get_TextReadTime(this TypedText*)
{
  return this._textReadTime;
}

void set_TextReadTime(this TypedText*, int value)
{
  this._textReadTime = value;
}

//===========================================================================
//
// TypedText::EvtCharTyped property
//
//===========================================================================
bool get_EvtCharTyped(this TypedText*)
{
  return this._justTyped;
}

//===========================================================================
//
// TypedText::EvtFinishedTyping property
//
//===========================================================================
bool get_EvtFinishedTyping(this TypedText*)
{
  return this._justFinishedTyping;
}

//===========================================================================
//
// TypedText::FullString property
//
//===========================================================================
String get_FullString(this TypedText*)
{
  return this._full;
}
  
//===========================================================================
//
// TypedText::CurrentString property
//
//===========================================================================
String get_CurrentString(this TypedText*)
{
  return this._cur;
}
  
//===========================================================================
//
// TypedText::LastTyped property
//
//===========================================================================
String get_LastTyped(this TypedText*)
{
  return this._last;
}

//===========================================================================
//
// TypedText::IsActive property
//
//===========================================================================
bool get_IsActive(this TypedText*)
{
  return !String.IsNullOrEmpty(this._full);
}
  
//===========================================================================
//
// TypedText::IsTextBeingTyped property
//
//===========================================================================
bool get_IsTextBeingTyped(this TypedText*)
{
  return !String.IsNullOrEmpty(this._full) && (this._cur.Length < this._full.Length);
}

//===========================================================================
//
// TypedText::IsWaitingForReader property
//
//===========================================================================
bool get_IsWaitingForReader(this TypedText*)
{
  return this._readerTimer > 0;
}

//===========================================================================
//
// TypedText::IsIdle property
//
//===========================================================================
bool get_IsIdle(this TypedText*)
{
  return !this.get_IsWaitingForReader() && !this.get_IsTextBeingTyped();
}

//===========================================================================
//
// TypedText::IsCaretShown property
//
//===========================================================================
bool get_IsCaretShown(this TypedText*)
{
  return this._caretFlashTimer > this._caretOffTime;
}

//===========================================================================
//
// TypedText::Paused property
//
//===========================================================================
bool get_Paused(this TypedText*)
{
  return this._paused;
}

void set_Paused(this TypedText*, int value)
{
  if (this._paused != value)
  {
    if (value)
      this.BeginTyping();
    else
      this.PauseTyping();
  }
}


/////////////////////////////////////////////////////////////////////////////
//
// TypewriterRender class
//
/////////////////////////////////////////////////////////////////////////////

//===========================================================================
//
// TypewriterRender::GetStringWithCaret()
//
//===========================================================================
String TypewriterRender::GetStringWithCaret()
{
  if (this._caretStyle == eTypedCaret_LastChar)
  {
    if (!this.get_IsCaretShown())
      return this._cur.Truncate(this._cur.Length - this._last.Length);
  }
  else if (this._caretStyle == eTypedCaret_Explicit)
  {
    if (!String.IsNullOrEmpty(this._caretStr) && this.get_IsCaretShown())
      return this._cur.Append(this._caretStr);
  }
  return this._cur;
}

//===========================================================================
//
// TypewriterRender::CaretStyle property
//
//===========================================================================
TypedCaretStyle get_CaretStyle(this TypewriterRender*)
{
  return this._caretStyle;
}

void set_CaretStyle(this TypewriterRender*, TypedCaretStyle value)
{
  this._caretStyle = value;
}

//===========================================================================
//
// TypewriterRender::CaretString property
//
//===========================================================================
String get_CaretString(this TypewriterRender*)
{
  return this._caretStr;
}

void set_CaretString(this TypewriterRender*, String value)
{
  this._caretStr = value;
}

//===========================================================================
//
// TypewriterRender::TypeSound property
//
//===========================================================================
AudioClip* get_TypeSound(this TypewriterRender*)
{
  if (this._typeSoundCount > 0)
    return this._typeSound[0];
  return null;
}

void set_TypeSound(this TypewriterRender*, AudioClip *value)
{
  this._typeSoundCount = 1;
  this._typeSound[0] = value;
}

//===========================================================================
//
// TypewriterRender::TypeSounds[] property
//
//===========================================================================
AudioClip* geti_TypeSounds(this TypewriterRender*, int index)
{
  if (index < 0 || index >= TYPEDTEXTRENDER_MAXSOUNDS)
    return null;
  return this._typeSound[index];
}

//===========================================================================
//
// TypewriterRender::TypeSoundCount property
//
//===========================================================================
int get_TypeSoundCount(this TypewriterRender*)
{
  return this._typeSoundCount;
}

//===========================================================================
//
// TypewriterRender::CaretSound property
//
//===========================================================================
AudioClip* get_CaretSound(this TypewriterRender*)
{
  return this._caretSound;
}

void set_CaretSound(this TypewriterRender*, AudioClip *value)
{
  this._caretSound = value;
}

//===========================================================================
//
// TypewriterRender::EndSound property
//
//===========================================================================
AudioClip* get_EndSound(this TypewriterRender*)
{
  return this._endSound;
}

void set_EndSound(this TypewriterRender*, AudioClip *value)
{
  this._endSound = value;
}

//===========================================================================
//
// TypewriterRender::SetRandomTypeSounds()
//
//===========================================================================
void TypewriterRender::SetRandomTypeSounds(AudioClip *sounds[], int count)
{
  if (count > TYPEDTEXTRENDER_MAXSOUNDS)
    count = TYPEDTEXTRENDER_MAXSOUNDS;

  this._typeSoundCount = count;

  int i = 0;
  while (i < count)
  {
    this._typeSound[i] = sounds[i];
    i++;
  }
}

//===========================================================================
//
// TypewriterRender::_RenderClear()
//
//===========================================================================
protected void TypewriterRender::_RenderClear()
{
  this._Clear();
}

//===========================================================================
//
// TypewriterRender::_RenderStart()
//
//===========================================================================
protected void TypewriterRender::_RenderStart(String text)
{
  this._Start(text);
}

//===========================================================================
//
// TypewriterRender::_RenderTick()
//
//===========================================================================
protected void TypewriterRender::_RenderTick()
{
  this._Tick();
  if (this._justTyped)
  {
    if (this._last.Chars[0] == LINE_BREAK)
    {
      if (this._caretSound != null)
        this._caretSound.Play();
    }    
    else if (this._typeSoundCount > 0)
      this._typeSound[Random(this._typeSoundCount - 1)].Play();
  }
  else if (this._justFinishedTyping)
  {
    if (this._endSound != null)
      this._endSound.Play();
  }
}

//===========================================================================
//
// TypewriterRender::Clear()
//
//===========================================================================
void Clear(this TypewriterRender*)
{
  this._RenderClear();
}

//===========================================================================
//
// TypewriterRender::Start()
//
//===========================================================================
void Start(this TypewriterRender*, String text)
{
  this._RenderStart(text);
}

//===========================================================================
//
// TypewriterRender::Tick()
//
//===========================================================================
void Tick(this TypewriterRender*)
{
  this._RenderTick();
}


/////////////////////////////////////////////////////////////////////////////
//
// TypewriterButton class
//
/////////////////////////////////////////////////////////////////////////////

//===========================================================================
//
// TypewriterButton::TypeOnButton property
//
//===========================================================================
Button *get_TypeOnButton(this TypewriterButton*)
{
  return this._button;
}

void set_TypeOnButton(this TypewriterButton*, Button *value)
{
  this._button = value;
}

//===========================================================================
//
// TypewriterButton::Clear()
//
//===========================================================================
void Clear(this TypewriterButton*)
{
  this._RenderClear();
  this._button.Text = "";
}

//===========================================================================
//
// TypewriterButton::Start()
//
//===========================================================================
void Start(this TypewriterButton*, String text)
{
  this._RenderStart(TypedTextUtils.SplitText(text, this._button.Width - GetTextWidth("W", this._button.Font),
                                             this._button.Font, SCR_NO_VALUE, SCR_NO_VALUE, 1));
}

//===========================================================================
//
// TypewriterButton::Tick()
//
//===========================================================================
void Tick(this TypewriterButton*)
{
  this._RenderTick();
  if (this._hasChanged)
  {
    String cur = this.GetStringWithCaret();
    // NOTE: Button can only hold 50 characters
    this._button.Text = cur.Substring(0, 49);
    this._hasChanged = false;
  }
}


/////////////////////////////////////////////////////////////////////////////
//
// TypewriterLabel class
//
/////////////////////////////////////////////////////////////////////////////

//===========================================================================
//
// TypewriterLabel::TypeOnLabel property
//
//===========================================================================
Label *get_TypeOnLabel(this TypewriterLabel*)
{
  return this._label;
}

void set_TypeOnLabel(this TypewriterLabel*, Label *value)
{
  this._label = value;
}

//===========================================================================
//
// TypewriterLabel::Clear()
//
//===========================================================================
void Clear(this TypewriterLabel*)
{
  this._RenderClear();
  this._label.Text = "";
}

//===========================================================================
//
// TypewriterLabel::Start()
//
//===========================================================================
void Start(this TypewriterLabel*, String text)
{
  this._RenderStart(TypedTextUtils.SplitText(text, this._label.Width - GetTextWidth("W", this._label.Font),
                                             this._label.Font, this._label.Height, SCR_NO_VALUE, SCR_NO_VALUE));
}

//===========================================================================
//
// TypewriterLabel::Tick()
//
//===========================================================================
void Tick(this TypewriterLabel*)
{
  this._RenderTick();
  if (this._hasChanged)
  {
    this._label.Text = this.GetStringWithCaret();
    this._hasChanged = false;
  }
}


/////////////////////////////////////////////////////////////////////////////
//
// TypewriterOverlay class
//
/////////////////////////////////////////////////////////////////////////////

//===========================================================================
//
// TypewriterOverlay::X property
//
//===========================================================================
int get_X(this TypewriterOverlay*)
{
  return this._x;
}

void set_X(this TypewriterOverlay*, int value)
{
  this._x = value;
  if (this._o != null && this._o.Valid)
    this._o.X = value;
}

//===========================================================================
//
// TypewriterOverlay::Y property
//
//===========================================================================
int get_Y(this TypewriterOverlay*)
{
  return this._y;
}

void set_Y(this TypewriterOverlay*, int value)
{
  this._y = value;
  if (this._o != null && this._o.Valid)
    this._o.Y = value;
}

//===========================================================================
//
// TypewriterOverlay::Width property
//
//===========================================================================
int get_Width(this TypewriterOverlay*)
{
  return this._width;
}

void set_Width(this TypewriterOverlay*, int value)
{
  this._width = value;
  if (this._o != null && this._o.Valid)
    this._o.SetText(this._width, this._font, this._color, this.GetStringWithCaret());
}

//===========================================================================
//
// TypewriterOverlay::Font property
//
//===========================================================================
FontType get_Font(this TypewriterOverlay*)
{
  return this._font;
}

void set_Font(this TypewriterOverlay*, FontType value)
{
  this._font = value;
  if (this._o != null && this._o.Valid)
    this._o.SetText(this._width, this._font, this._color, this.GetStringWithCaret());
}

//===========================================================================
//
// TypewriterOverlay::Color property
//
//===========================================================================
int get_Color(this TypewriterOverlay*)
{
  return this._color;
}

void set_Color(this TypewriterOverlay*, int value)
{
  this._color = value;
  if (this._o != null && this._o.Valid)
    this._o.SetText(this._width, this._font, this._color, this.GetStringWithCaret());
}

//===========================================================================
//
// TypewriterOverlay::OwnedOverlay property
//
//===========================================================================
Overlay *get_OwnedOverlay(this TypewriterOverlay*)
{
  return this._o;
}

//===========================================================================
//
// TypewriterOverlay::Clear()
//
//===========================================================================
void Clear(this TypewriterOverlay*)
{
  this._RenderClear();
  if (this._o != null && this._o.Valid)
    this._o.Remove();
  this._o = null;
}

//===========================================================================
//
// TypewriterOverlay::Start()
//
//===========================================================================
void Start(this TypewriterOverlay*, String text)
{
  this._RenderStart(TypedTextUtils.SplitText(text, this._width - DEFAULT_DISPLAY_PADDING - INTERNAL_LINE_SPLIT_MISTAKE,
                                             this._font, SCR_NO_VALUE, SCR_NO_VALUE, SCR_NO_VALUE));
  this._o = Overlay.CreateTextual(this._x, this._y, this._width, this._font, this._color, "%s", this.GetStringWithCaret());
}

//===========================================================================
//
// TypewriterOverlay::Tick()
//
//===========================================================================
void Tick(this TypewriterOverlay*)
{
  this._RenderTick();
  if (this._hasChanged)
  {
    this._o.SetText(this._width, this._font, this._color, this.GetStringWithCaret());
    this._hasChanged = false;
  }
}


//===========================================================================
//
// game_start()
//
// Initializes static data.
//
//===========================================================================
function game_start()
{
  TTUtils.MetricsTestString = "WMIygj";
  TTUtils.SplitHintCharacters = " -=+.,:;!?";
}
 �7  // TypedText is open source under the MIT License.
//
// TERMS OF USE - TypedText MODULE
//
// Copyright (c) 2017-present Ivan Mogilko
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
//
//////////////////////////////////////////////////////////////////////////////////////////
//
// Module performs continious text typing over time, in typewriter style,
// letter by letter, optionally drawing custom caret in the end of the text.
//
//----------------------------------------------------------------------------------------
//
// TODO:
//  - Means for user to get number of lines currently displayed. This may
//    require advanced mechanism for updating TypedTextRenderer in case
//    derived implementation changes its size (similar to what Drawing
//    is doing).
//  - More clear solution for caret return sound timing (make sure it plays
//    before caret is drawn on the new line?).
//
//////////////////////////////////////////////////////////////////////////////////////////

#ifndef __TYPEDTEXT_MODULE__
#define __TYPEDTEXT_MODULE__

#define TYPEDTEXT_VERSION_00_00_70_00

/// Maximal allowed random sounds
/// ( because pre-3.4.0 AGS does not support dynamic arrays in structs... :-( )
#define TYPEDTEXTRENDER_MAXSOUNDS 3

/// Whitespace/caret-return delay style defines relation of special case
/// delays to the base type delay.
/// Idea is conforming to the Phemar's Typewriter module.
enum TypedDelayStyle
{
  /// wait for the same amount of time as after regular letters
  eTypedDelay_Uniform = 0,
  /// wait twice as long after whitespaces
  eTypedDelay_LongSpace,
  /// wait twice as less after whitespaces
  eTypedDelay_ShortSpace,
  /// randomly choose a style every time
  eTypedDelay_Mixed
};

///////////////////////////////////////////////////////////////////////////////
//
// TypedText class depicts a state of continiously typed string of text
// at any given time.
//
///////////////////////////////////////////////////////////////////////////////
struct TypedText
{
  //
  // Configuration
  //

  /// Base delay (in ticks) between every typing event
  import attribute int              TypeDelay;
  /// Bounds for random base delay
  import attribute int              TypeDelayMin;
  import attribute int              TypeDelayMax;
  import attribute TypedDelayStyle  TypeDelayStyle;
  /// Time (in ticks) the caret stays shown
  import attribute int              CaretFlashOnTime;
  /// Time (in ticks) the caret stays hidden
  import attribute int              CaretFlashOffTime;
  /// Time (in ticks) given to read one text character
  import attribute int              TextReadTime;
  
  //
  // Event signals
  //
  
  /// Gets if the new character was just typed
  readonly import attribute bool    EvtCharTyped;
  /// Gets if the text has just ended being typed
  readonly import attribute bool    EvtFinishedTyping;
  
  //
  // State control
  //
  
  /// Full string that has to be typed
  readonly import attribute String  FullString;
  /// Part of string that is supposed to be shown at current time
  readonly import attribute String  CurrentString;
  /// Part of string that was 'typed' during latest update
  readonly import attribute String  LastTyped;
  
  /// Tells whether TypedText has active content to process or display
  readonly import attribute bool    IsActive;
  /// Tells whether TypedText is in process of typing text
  /// (return FALSE if either no text is set, or text is already fully typed)
  readonly import attribute bool    IsTextBeingTyped;
  /// Tells whether TypedText is waiting for the text to be read by player
  /// (return FALSE when reading timer has ran out, regardless of other states)
  readonly import attribute bool    IsWaitingForReader;
  /// Tells whether TypedText is currently idling, either not having a content,
  /// or after finishing all the required actions (typing & waiting for reader)
  readonly import attribute bool    IsIdle;
  /// Tells whether caret should be currently displayed
  readonly import attribute bool    IsCaretShown;
  
  //
  // Main functionality
  //
  
  /// Gets/sets paused state
  import attribute bool             Paused;
  
  /// Clears all text and resets all timers
  import void                       Clear();
  /// Sets new string, resets all timers and commences typing
  import void                       Start(String text);
  /// Skips all the remaining typing
  import void                       Skip();
  
  /// Update typed text state, advancing it by single tick
  import void                       Tick();
  
  
  //
  // Internal implementation
  //
  
  // Internal commands implementation, for calling from inheriting classes
  protected import void             _Clear();
  protected import void             _Start(String line);
  protected import void             _Tick();
  
  // Strings
  protected String                  _full;
  protected String                  _cur;
  protected String                  _last;
  
  // Delay settings
  protected int                     _typeDelayMin;
  protected int                     _typeDelayMax;
  protected TypedDelayStyle	        _typeDelayStyle;
  // Caret settings
  protected int                     _caretOnTime;
  protected int                     _caretOffTime;
  // Ticks given to read one text character
  protected int                     _textReadTime;
  
  // Paused flag
  protected bool                    _paused;
  // Ticks left till next type event
  protected int                     _typeTimer;
  // Ticks left till caret state change
  protected int                     _caretFlashTimer;
  // Ticks left for the text to be read
  protected int                     _readerTimer;
  // Tells that the new character was just typed
  protected bool                    _justTyped;
  // Tells that the text has just ended being typed
  protected bool                    _justFinishedTyping;
  
  // Internal flag that tells whether object's state has changed
  protected bool                    _hasChanged;
};


/// Style of the caret displayed during typing
enum TypedCaretStyle
{
  /// No caret display
  eTypedCaret_None = 0, 
  /// Flash last character
  eTypedCaret_LastChar, 
  /// Draw separate caret at the next assumed character location
  eTypedCaret_Explicit
};

///////////////////////////////////////////////////////////////////////////////
//
// TypewriterRender is an abstract intermediate class for the TypedText
// renderers.
//
///////////////////////////////////////////////////////////////////////////////
struct TypewriterRender extends TypedText
{
  /// Caret display style
  import attribute TypedCaretStyle CaretStyle;
  /// A string (or single character) that represents typewriter caret
  import attribute String          CaretString;
  
  /// The only sound to play when a character is typed
  import attribute AudioClip *     TypeSound;
  /// Array of sounds to choose at random when a character is typed
  readonly import attribute AudioClip *TypeSounds[];
  /// Number of typing sounds registered
  readonly import attribute int    TypeSoundCount;
  /// Sound to play when the line break is met
  import attribute AudioClip *     CaretSound;
  /// Sound to play when the typewriter finished typing text
  import attribute AudioClip *     EndSound;
  
  /// Sets the array of sounds to play at random when character is typed
  import void                      SetRandomTypeSounds(AudioClip *sounds[], int count);
  

  // Returns current typed string modified according to the caret style:
  // - if style is LastChar and caret is currently flashing off, then returns
  //   string with last typed character erased; if caret is flashing on, then
  //   string is not changed;
  // - if style is Explicit and CaretString is set, then appends caret chars
  //   to the string (only if caret is currently flashing on)
  import String                    GetStringWithCaret();
  
  // Internal commands implementation, for calling from inheriting classes
  protected import void            _RenderClear();
  protected import void            _RenderSkip();
  protected import void            _RenderStart(String text);
  protected import void            _RenderTick();
  
  protected TypedCaretStyle        _caretStyle;
  protected String                 _caretStr;
  protected AudioClip *            _typeSound[TYPEDTEXTRENDER_MAXSOUNDS];
  protected int                    _typeSoundCount;
  protected AudioClip *            _caretSound;
  protected AudioClip *            _endSound;
};

/// Clears all text and resets all timers
import void Clear(this TypewriterRender*);
/// Skips all the remaining typing
import void Skip();
/// Sets new string, resets all timers and commences typing
import void Start(this TypewriterRender*, String text);
/// Update typed text state, advancing it by single tick
import void Tick(this TypewriterRender*);


///////////////////////////////////////////////////////////////////////////////
//
// TypewriterButton draws TypedText on the provided Button.
//
///////////////////////////////////////////////////////////////////////////////
struct TypewriterButton extends TypewriterRender
{
  /// Button to draw text on
  import attribute Button *TypeOnButton;
  
  protected Button* _button;
};

/// Clears all text and resets all timers
import void Clear(this TypewriterButton*);
/// Sets new string, resets all timers and commences typing
import void Start(this TypewriterButton*, String text);
/// Update typed text state, advancing it by single tick
import void Tick(this TypewriterButton*);


///////////////////////////////////////////////////////////////////////////////
//
// TypewriterLabel draws TypedText on the provided Label.
//
///////////////////////////////////////////////////////////////////////////////
struct TypewriterLabel extends TypewriterRender
{
  /// Label to draw text on
  import attribute Label *TypeOnLabel;
  
  protected Label* _label;
};

/// Clears all text and resets all timers
import void Clear(this TypewriterLabel*);
/// Sets new string, resets all timers and commences typing
import void Start(this TypewriterLabel*, String text);
/// Update typed text state, advancing it by single tick
import void Tick(this TypewriterLabel*);


///////////////////////////////////////////////////////////////////////////////
//
// TypewriterOverlay draws TypedText on the owned overlay.
//
///////////////////////////////////////////////////////////////////////////////
struct TypewriterOverlay extends TypewriterRender
{
  /// Default overlay parameters
  import attribute int X;
  import attribute int Y;
  import attribute int Width;
  import attribute FontType Font;
  import attribute int Color;
  
  /// Overlay the speech is printed on
  readonly import attribute Overlay *OwnedOverlay;
  
  // Overlay params
  protected int _x;
  protected int _y;
  protected int _width;
  protected FontType _font;
  protected int _color;
  // Created overlay
  protected Overlay *_o;
};

/// Clears all text and resets all timers
import void Clear(this TypewriterOverlay*);
/// Sets new string, resets all timers and commences typing
import void Start(this TypewriterOverlay*, String text);
/// Update typed text state, advancing it by single tick
import void Tick(this TypewriterOverlay*);


///////////////////////////////////////////////////////////////////////////////
//
// TypedTextUtils is a collection of static helpers.
//
///////////////////////////////////////////////////////////////////////////////
// Default padding that AGS subtracts from the width given to fit the text in,
// calculated as default padding 3 multiplied by 2 (both sides).
#define DEFAULT_DISPLAY_PADDING 6
// Number of pixels to counter some uncertain mistakes in the internal text
// splitting calculations of AGS.
#define INTERNAL_LINE_SPLIT_MISTAKE 2

struct TypedTextUtils
{
  /// Gets/sets string of characters, that are considered a good point at
  /// which the line of text could be split when needed (like spaces and
  /// punctuation characters. Default value is " -=+.,:;!?".
  import static attribute String SplitHintCharacters;
  /// Gets the average height of a line, printed with the given font.
  import static int              GetFontHeight(FontType font);
  // Splits given string into lines by inserting line break characters.
  // Returns the resulting string.
  // max_height, line_height and max_lines parameters are optional, pass
  // SCR_NO_VALUE if you do not want to impose any limit on them.
  // max_width is the obligatory parameter, if it is not set function will
  // return/ empty string.
  import static String SplitText(String text, int max_width, FontType font,
                                 int max_height = SCR_NO_VALUE, int line_height = SCR_NO_VALUE, int max_lines = SCR_NO_VALUE);
};


#endif  // __TYPEDTEXT_MODULE__
 �J;        ej��