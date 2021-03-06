AGSScriptModule    Ivan Mogilko Collection of helper structs and functions for simplified TypedText usage TypedTextHelper 0.7.0 7?  /////////////////////////////////////////////////////////////////////////////
//
// Preset functions
//
/////////////////////////////////////////////////////////////////////////////

// Caret setup
struct TypedTextPreset
{
  // Delay (in ticks) between every typing event
  int TypeDelayMin;
  int TypeDelayMax;
  TypedDelayStyle TypeDelayStyle;
  int TextReadTime;
  
  int CaretFlashOnTime;
  int CaretFlashOffTime;
  TypedCaretStyle CaretStyle;
  String CaretString;
  int CaretSprite;
  
  AudioClip *TypeSound[TYPEDTEXTRENDER_MAXSOUNDS];
  int        TypeSoundCount;
  AudioClip *CaretSound;
  AudioClip *EndSound;
};

TypedTextPreset Presets[TYPEDTEXTHELPER_MAXPRESETS];

//===========================================================================
//
// TypewriterPreset::SetGeneral()
//
//===========================================================================
static void TypewriterPreset::SetGeneral(int preset, int delay_min, int delay_max, TypedDelayStyle style, int read_time)
{
  if (preset < 0 || preset >= TYPEDTEXTHELPER_MAXPRESETS)
  {
    AbortGame("Attempt to set typewriter preset ID=%d, while only (0 - %d) are supported.", preset, TYPEDTEXTHELPER_MAXPRESETS);
    return;
  }
  
  Presets[preset].TypeDelayMin = delay_min;
  Presets[preset].TypeDelayMax = delay_max;
  Presets[preset].TypeDelayStyle = style;
  Presets[preset].TextReadTime = read_time;
}

//===========================================================================
//
// TypewriterPreset::SetCaret()
//
//===========================================================================
static void TypewriterPreset::SetCaret(int preset, int caret_on_time, int caret_off_time, TypedCaretStyle style, String caret_str, int caret_sprite)
{
  if (preset < 0 || preset >= TYPEDTEXTHELPER_MAXPRESETS)
  {
    AbortGame("Attempt to set typewriter preset ID=%d, while only (0 - %d) are supported.", preset, TYPEDTEXTHELPER_MAXPRESETS);
    return;
  }
  
  Presets[preset].CaretFlashOnTime = caret_on_time;
  Presets[preset].CaretFlashOffTime = caret_off_time;
  Presets[preset].CaretStyle = style;
  Presets[preset].CaretString = caret_str;
  Presets[preset].CaretSprite = caret_sprite;
}

//===========================================================================
//
// TypewriterPreset::SetSounds()
//
//===========================================================================
static void TypewriterPreset::SetSounds(int preset, AudioClip *type_sound, AudioClip *caret_sound, AudioClip *end_sound)
{
  if (preset < 0 || preset >= TYPEDTEXTHELPER_MAXPRESETS)
  {
    AbortGame("Attempt to set typewriter preset ID=%d, while only (0 - %d) are supported.", preset, TYPEDTEXTHELPER_MAXPRESETS);
    return;
  }
  
  Presets[preset].TypeSound[0] = type_sound;
  Presets[preset].TypeSoundCount = 1;
  Presets[preset].CaretSound = caret_sound;
  Presets[preset].EndSound = end_sound;
}

//===========================================================================
//
// TypewriterPreset::SetSoundArray()
//
//===========================================================================
static void TypewriterPreset::SetSoundArray(int preset, AudioClip *type_sounds[], int type_sound_count,
                                            AudioClip *caret_sound, AudioClip *end_sound)
{
  if (preset < 0 || preset >= TYPEDTEXTHELPER_MAXPRESETS)
  {
    AbortGame("Attempt to set typewriter preset ID=%d, while only (0 - %d) are supported.", preset, TYPEDTEXTHELPER_MAXPRESETS);
    return;
  }
  
  if (type_sound_count > TYPEDTEXTRENDER_MAXSOUNDS)
    type_sound_count = TYPEDTEXTRENDER_MAXSOUNDS;
  
  Presets[preset].TypeSoundCount = type_sound_count;

  int i = 0;
  while (i < type_sound_count)
  {
    Presets[preset].TypeSound[i] = type_sounds[i];
    i++;
  }
  Presets[preset].CaretSound = caret_sound;
  Presets[preset].EndSound = end_sound;
}

//===========================================================================
//
// TypewriterPreset::GetTypeSoundArray()
//
// Returns dynamic array which contains typing sounds.
// This function is required because pre-3.4.0 AGS could not have dynamic
// arrays inside the struct :-(.
//
//===========================================================================
AudioClip* [] GetTypeSoundArray(this TypedTextPreset*)
{
  if (this.TypeSoundCount <= 0)
    return null;
  AudioClip *arr[] = new AudioClip[this.TypeSoundCount];
  int i = 0;
  while (i < this.TypeSoundCount)
  {
    arr[i] = this.TypeSound[i];
    i++;
  }
  return arr;
}


/////////////////////////////////////////////////////////////////////////////
//
// Typewriter functions
//
// Note that because AGS does not really support polymorphism and virtual
// methods, we have to keep subclass ID and use few other workarounds here.
//
/////////////////////////////////////////////////////////////////////////////

// Available typewriters
enum TypewriterSubclass
{
  eTWNone = 0, 
  eTWButton, 
  eTWLabel, 
  eTWOverlay
};

struct TWRunInfo
{
  // big ID of this typewriter
  int                ID;
  // is typewriter running in blocking mode
  BlockingStyle      BS;
  // typewriter subclass (button, overlay, etc)
  TypewriterSubclass Subclass;
};

TWRunInfo           TWRun[TYPEDTEXTHELPER_MAXTYPEWRITERS];
TypewriterButton    TTButtons[TYPEDTEXTHELPER_MAXTYPEWRITERS];
TypewriterLabel     TTLabels[TYPEDTEXTHELPER_MAXTYPEWRITERS];
TypewriterOverlay   TTOverlays[TYPEDTEXTHELPER_MAXTYPEWRITERS];

// Unique typewriter identifier
int BigTypewriterID = NO_TYPEWRITER;

//===========================================================================
//
// PreparePreset()
//
// Tests whether requested preset is available.
//
//===========================================================================
bool PreparePreset(int preset)
{
  if (preset < 0 || preset >= TYPEDTEXTHELPER_MAXPRESETS)
    return false;
  return true;
}

//===========================================================================
//
// TestIfIdle()
//
// Tests whether typewriter is idle.
//
//===========================================================================
bool TestIfIdle(int twi)
{
  int subclass = TWRun[twi].Subclass;
  if (subclass == eTWNone)
    return true;
  if (subclass == eTWButton)
    return TTButtons[twi].IsIdle;
  if (subclass == eTWLabel)
    return TTLabels[twi].IsIdle;
  if (subclass == eTWOverlay)
    return TTOverlays[twi].IsIdle;
  AbortGame("Unknown typewriter class %d of typewriter ID=%d", subclass, TWRun[twi].ID);
  return true;
}


//===========================================================================
//
// CreateTypewriter()
//
// Sets up TypedText base object, and returns its index.
//
//===========================================================================
int CreateTypewriter(TypewriterSubclass subclass, BlockingStyle bs, int preset)
{
  // Test that presets exist
  if (!PreparePreset(preset))
  {
    AbortGame("Cannot find typewriter preset ID = %d).", preset);
    return -1;
  }
  
  // Find available typewriter
  int twi = -1;
  int i = 0;
  while (twi < 0 && i < TYPEDTEXTHELPER_MAXTYPEWRITERS)
  {
    if (TestIfIdle(i))
      twi = i;
    i++;
  }
  if (twi < 0)
    twi = 0;
  
  BigTypewriterID++;
  if (BigTypewriterID == NO_TYPEWRITER)
    BigTypewriterID++;
  TWRun[twi].ID = BigTypewriterID;
  TWRun[twi].Subclass = subclass;
  TWRun[twi].BS = bs;
  return twi;
}

//===========================================================================
//
// RunTypewriterOnce()
//
// Runs a non-blocking typewriter for one tick. Returns TRUE if typewriter
// is still running, and FALSE if it is idle.
//
//===========================================================================
bool RunTypewriterOnce(int twi)
{
  int subclass = TWRun[twi].Subclass;
  if (subclass == eTWNone)
    return false;
  if (subclass == eTWButton)
    TTButtons[twi].Tick();
  else if (subclass == eTWLabel)
    TTLabels[twi].Tick();
  else if (subclass == eTWOverlay)
    TTOverlays[twi].Tick();
  else
  {
    AbortGame("Unknown typewriter class %d of typewriter ID=%d", subclass, TWRun[twi].ID);
    return false;
  }
  return !TestIfIdle(twi);
}

//===========================================================================
//
// ReleaseTypewriter()
//
// Stops typewriter and frees it for the future use.
//
//===========================================================================
void ReleaseTypewriter(int twi)
{
  int subclass = TWRun[twi].Subclass;
  if (subclass == eTWButton)
    TTButtons[twi].Clear();
  else if (subclass == eTWLabel)
    TTLabels[twi].Clear();
  else if (subclass == eTWOverlay)
    TTOverlays[twi].Clear();
  else if (subclass != eTWNone)
  {
    AbortGame("Unknown typewriter class %d of typewriter ID=%d", subclass, TWRun[twi].ID);
    return;
  }
  TWRun[twi].ID = NO_TYPEWRITER;
  TWRun[twi].Subclass = eTWNone;
}

//===========================================================================
//
// RunBlockingTypewriter()
//
// Runs a blocking typewriter until it finishes working.
//
//===========================================================================
void RunBlockingTypewriter(int twi)
{
  while (RunTypewriterOnce(twi))
  {
    Wait(1);
  }
  ReleaseTypewriter(twi);
}

//===========================================================================
//
// TypewriterRunners::ActiveCount property
//
//===========================================================================
int get_ActiveCount(this TypewriterRunners*)
{
  int active = 0;
  int i = 0;
  while (i < TYPEDTEXTHELPER_MAXTYPEWRITERS)
  {
    if (TWRun[i].ID != NO_TYPEWRITER)
      active++;
    i++;
  }
  return active;
}

//===========================================================================
//
// TypewriterRunners::MaxCount property
//
//===========================================================================
int get_MaxCount(this TypewriterRunners*)
{
  return TYPEDTEXTHELPER_MAXTYPEWRITERS;
}

//===========================================================================
//
// TypewriterRunners::IsActive[] property
//
//===========================================================================
bool geti_IsActive(this TypewriterRunners*, int id)
{
  int i = 0;
  while (i < TYPEDTEXTHELPER_MAXTYPEWRITERS)
  {
    if (TWRun[i].ID == id)
      return TWRun[i].ID != NO_TYPEWRITER;
    i++;
  }
  return false;
}

//===========================================================================
//
// TypewriterRunners::IsBlocking[] property
//
//===========================================================================
bool geti_IsBlocking(this TypewriterRunners*, int id)
{
  int i = 0;
  while (i < TYPEDTEXTHELPER_MAXTYPEWRITERS)
  {
    if (TWRun[i].ID == id)
      return TWRun[i].BS == eBlock;
    i++;
  }
  return false;
}

//===========================================================================
//
// TypewriterRunners::Cancel()
//
//===========================================================================
static void TypewriterRunners::Cancel(int id)
{
  int i = 0;
  while (i < TYPEDTEXTHELPER_MAXTYPEWRITERS)
  {
    if (TWRun[i].ID == id)
    {
      ReleaseTypewriter(i);
      return;
    }
    i++;
  }
}


//===========================================================================
//
// Button::TypewriterPrint()
//
//===========================================================================
int Typewriter(this Button*, String text, BlockingStyle bs, int preset)
{
  int twi = CreateTypewriter(eTWButton, bs, preset);
  TTButtons[twi].TypeOnButton = this;
  TTButtons[twi].TypeDelayMin = Presets[preset].TypeDelayMin;
  TTButtons[twi].TypeDelayMax = Presets[preset].TypeDelayMax;
  TTButtons[twi].TypeDelayStyle = Presets[preset].TypeDelayStyle;
  TTButtons[twi].CaretFlashOnTime = Presets[preset].CaretFlashOnTime;
  TTButtons[twi].CaretFlashOffTime = Presets[preset].CaretFlashOffTime;
  TTButtons[twi].CaretStyle = Presets[preset].CaretStyle;
  TTButtons[twi].CaretString = Presets[preset].CaretString;
  TTButtons[twi].CaretStyle = Presets[preset].CaretStyle;
  TTButtons[twi].TextReadTime = Presets[preset].TextReadTime;
  TTButtons[twi].SetRandomTypeSounds(Presets[preset].GetTypeSoundArray(), Presets[preset].TypeSoundCount);
  TTButtons[twi].CaretSound = Presets[preset].CaretSound;
  TTButtons[twi].EndSound = Presets[preset].EndSound;
  TTButtons[twi].Start(text);
  if (bs == eBlock)
    RunBlockingTypewriter(twi);
  return TWRun[twi].ID;
}

//===========================================================================
//
// Label::TypewriterPrint()
//
//===========================================================================
int Typewriter(this Label*, String text, BlockingStyle bs, int preset)
{
  int twi = CreateTypewriter(eTWLabel, bs, preset);
  TTLabels[twi].TypeOnLabel = this;
  TTLabels[twi].TypeDelayMin = Presets[preset].TypeDelayMin;
  TTLabels[twi].TypeDelayMax = Presets[preset].TypeDelayMax;
  TTLabels[twi].TypeDelayStyle = Presets[preset].TypeDelayStyle;
  TTLabels[twi].CaretFlashOnTime = Presets[preset].CaretFlashOnTime;
  TTLabels[twi].CaretFlashOffTime = Presets[preset].CaretFlashOffTime;
  TTLabels[twi].CaretStyle = Presets[preset].CaretStyle;
  TTLabels[twi].CaretString = Presets[preset].CaretString;
  TTLabels[twi].CaretStyle = Presets[preset].CaretStyle;
  TTLabels[twi].TextReadTime = Presets[preset].TextReadTime;
  TTLabels[twi].SetRandomTypeSounds(Presets[preset].GetTypeSoundArray(), Presets[preset].TypeSoundCount);
  TTLabels[twi].CaretSound = Presets[preset].CaretSound;
  TTLabels[twi].EndSound = Presets[preset].EndSound;
  TTLabels[twi].Start(text);
  if (bs == eBlock)
    RunBlockingTypewriter(twi);
  return TWRun[twi].ID;
}

//===========================================================================
//
// TypewriteOver()
//
//===========================================================================
#ifver 3.4.0
int Typewriter(static Overlay, int x, int y, int color, FontType font, String text, BlockingStyle bs, int preset)
#endif
#ifnver 3.4.0
int TypewriteOnOverlay(int x, int y, int color, FontType font, String text, BlockingStyle bs, int preset)
#endif
{
  int twi = CreateTypewriter(eTWOverlay, bs, preset);
  
  // Start typewriter
  TTOverlays[twi].X = x;
  TTOverlays[twi].Y = y;
  TTOverlays[twi].Width = System.ViewportWidth - x * 2;
  TTOverlays[twi].Color = color;
  TTOverlays[twi].Font = font;
  TTOverlays[twi].TypeDelayMin = Presets[preset].TypeDelayMin;
  TTOverlays[twi].TypeDelayMax = Presets[preset].TypeDelayMax;
  TTOverlays[twi].TypeDelayStyle = Presets[preset].TypeDelayStyle;
  TTOverlays[twi].CaretFlashOnTime = Presets[preset].CaretFlashOnTime;
  TTOverlays[twi].CaretFlashOffTime = Presets[preset].CaretFlashOffTime;
  TTOverlays[twi].CaretStyle = Presets[preset].CaretStyle;
  TTOverlays[twi].CaretString = Presets[preset].CaretString;
  TTOverlays[twi].CaretStyle = Presets[preset].CaretStyle;
  TTOverlays[twi].TextReadTime = Presets[preset].TextReadTime;
  TTOverlays[twi].SetRandomTypeSounds(Presets[preset].GetTypeSoundArray(), Presets[preset].TypeSoundCount);
  TTOverlays[twi].CaretSound = Presets[preset].CaretSound;
  TTOverlays[twi].EndSound = Presets[preset].EndSound;
  TTOverlays[twi].Start(text);
  
  if (bs == eBlock)
    RunBlockingTypewriter(twi);
  return TWRun[twi].ID;
}

//===========================================================================
//
// repeatedly_execute()
//
// Runs non-blocking typewriters
//
//===========================================================================
function repeatedly_execute()
{
  int twi = 0;
  while (twi < TYPEDTEXTHELPER_MAXTYPEWRITERS)
  {
    if (TWRun[twi].Subclass != eTWNone)
    {
      if (!RunTypewriterOnce(twi))
        ReleaseTypewriter(twi);
    }
    twi++;
  }
}
 �  // TypedTextHelper is open source under the MIT License.
//
// TERMS OF USE - TypedTextHelper MODULE
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
// Collection of helper structs and functions for simplified TypedText usage.
//
//////////////////////////////////////////////////////////////////////////////////////////

#ifndef __TYPEDTEXTHELPER_MODULE__
#define __TYPEDTEXTHELPER_MODULE__

#ifndef __TYPEDTEXT_MODULE__
#error TypedTextHelper requires TypedText module
#endif

#define TYPEDTEXTHELPER_VERSION_00_00_70_00

#ifver 3.4.0
  #ifdef SCRIPT_COMPAT_v321
    #define TYPEDTEXTHELPER_USEOLDOVERLAY
  #endif
#endif
#ifnver 3.4.0
  #define TYPEDTEXTHELPER_USEOLDOVERLAY
#endif

/// Maximal supported presets, per each kind
#define TYPEDTEXTHELPER_MAXPRESETS 8
/// Maximal supported active typewriters (handled by TypedTextHelper module)
#define TYPEDTEXTHELPER_MAXTYPEWRITERS 8

/// Static methods for setting up presets
struct TypewriterPreset
{
  /// Set general parameters for the specified preset
  import static void SetGeneral(int preset, int delay_min, int delay_max, TypedDelayStyle style, int read_time = 12);
  /// Set caret parameters for the specified preset
  import static void SetCaret(int preset, int flash_on_time, int flash_off_time, TypedCaretStyle style, String caret_str, int caret_sprite = 0);
  /// Set sound parameters for the specified preset
  import static void SetSounds(int preset, AudioClip *type_sound, AudioClip *caret_sound, AudioClip *end_sound);
  import static void SetSoundArray(int preset, AudioClip *type_sounds[], int type_sound_count,
                                   AudioClip *caret_sound, AudioClip *end_sound);
};

#define NO_TYPEWRITER 0

struct TypewriterRunners
{
  /// Get number of currently running typewriters
  readonly import static attribute int  ActiveCount;
  /// Get number of maximal supported typewriters that can run simultaneously
  readonly import static attribute int  MaxCount;
  /// Get whether given typewriter ID is currently running
  readonly import static attribute bool IsActive[];
  /// Get whether given typewriter ID is blocking
  readonly import static attribute bool IsBlocking[];
  
  /// Stop typewriter under given ID
  import static void Cancel(int id);
};

/// Print TypedText as a text on button; returns typewriter ID
import int Typewriter(this Button*, String text, BlockingStyle bs, int preset = 0);
/// Print TypedText as a text on label; returns typewriter ID
import int Typewriter(this Label*, String text, BlockingStyle bs, int preset = 0);
#ifver 3.4.0
/// Print TypedText as a text on created overlay; returns typewriter ID
import int Typewriter(static Overlay, int x, int y, int color, FontType font, String text, BlockingStyle bs, int preset = 0);
#endif
#ifdef TYPEDTEXTHELPER_USEOLDOVERLAY
/// Print TypedText as a text on created overlay; returns typewriter ID
import int TypewriteOnOverlay(int x, int y, int color, FontType font, String text, BlockingStyle bs, int preset = 0);
#endif

#endif  // __TYPEDTEXTHELPER_MODULE__
 #�d        ej��