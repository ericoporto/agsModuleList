AGSScriptModule    monkey_05_06 Allows for queued background speech with animation and voice speech support. QueuedSpeech 4.2 7(  QueuedSpeech_t QueuedSpeech;
export QueuedSpeech;

// increase capacity of queue, if needed
void Grow(this QueuedSpeech_t*, int minCapacity)
{
  if (minCapacity <= this._capacity) return; // already meeting or exceeding capacity
  if ((this._capacity == 1000000) || (minCapacity > 1000000))
  {
    // requested invalid capacity
    AbortGame("QueuedSpeech module error!: Attempted to grow capacity beyond 1000000 items.");
  }
  int copy = this._capacity; // number of items to copy to new array
  do
  {
    // resize capacity until it is >= min
    if (this._capacity == 0) this._capacity = 1;
    else if (this._capacity >= 500000) this._capacity = 1000000;
    else this._capacity *= 2;
  } while (this._capacity < minCapacity);
  // create new arrays at specified capacity
  Character *chara[] = new Character[this._capacity];
  int delay[] = new int[this._capacity];
  String messages[] = new String[this._capacity];
  AudioClip *clips[] = new AudioClip[this._capacity];
  int i;
  for (i = 0; i < copy; i++)
  {
    // copy old arrays into new ones
    chara[i] = this._character[i];
    delay[i] = this._delay[i];
    messages[i] = this._messages[i];
    clips[i] = this._clips[i];
  }
  // reassign current arrays
  this._character = chara;
  this._delay = delay;
  this._messages = messages;
  this._clips = clips;
}

void QueuedSpeech_t::RemoveMessage(int index)
{
  if ((index < 0) || (index >= this.MessageCount)) return;
  this.MessageCount--;
  int i;
  for (i = index; i < this.MessageCount; i++)
  {
    this._character[i] = this._character[i + 1];
    this._delay[i] = this._delay[i + 1];
    this._messages[i] = this._messages[i + 1];
    this._clips[i] = this._clips[i + 1];
  }
  this._character[i] = null;
  this._delay[i] = 0;
  this._messages[i] = null;
  this._clips[i] = null;
  if (this.CurrentIndex >= this.MessageCount)
  {
    this.CurrentIndex = 0;
  }
}

bool IsNullOrInvalid(static Overlay, Overlay *theOverlay)
{
  return ((theOverlay == null) || (!theOverlay.Valid));
}

void QueuedSpeech_t::SkipCurrentMessage()
{
  if (!Overlay.IsNullOrInvalid(this._overlay))
  {
    this._overlay.Remove();
  }
  this._overlay = null;
  if ((this._character[this.CurrentIndex] != null) && (this._lockedView))
  {
    this._character[this.CurrentIndex].UnlockView();
  }
  this._delayTimer = 0;
  if (this.Looping)
  {
    this.CurrentIndex++;
    if (this.CurrentIndex >= this.MessageCount)
    {
      this.CurrentIndex = 0;
    }
  }
  else this.RemoveMessage(this.CurrentIndex);
  if (this._channel != null) this._channel.Stop();
  this._channel = null;
  this._speechTimer = 0;
}

bool Insert(this QueuedSpeech_t*, int slot, Character *theCharacter,
            String message, AudioClip *speechClip, int delay)
{
  if ((slot < 0) || (slot > this.MessageCount) || (slot == SCR_NO_VALUE))
  {
    slot = this.MessageCount;
  }
  if (delay < 0) delay = 0;
  this.MessageCount++;
  this.Grow(this.MessageCount);
  int i;
  for (i = this.MessageCount - 1; i > slot; i--)
  {
    this._character[i] = this._character[i - 1];
    this._delay[i] = this._delay[i - 1];
    this._messages[i] = this._messages[i - 1];
    this._clips[i] = this._clips[i - 1];
  }
  this._character[slot] = theCharacter;
  this._delay[slot] = delay;
  this._messages[slot] = message;
  this._clips[slot] = speechClip;
}

bool SayQueued(this Character*, String message, AudioClip *speechClip,
               int delay, int slot)
{
  return QueuedSpeech.Insert(slot, this, message, speechClip, delay);
}

Overlay* CreateTextualAligned(static Overlay, int x, int y, int width, FontType font,
                              int color, String message, Alignment align)
{
  int height = GetTextHeight(message, font, width);
  DynamicSprite *sprite = DynamicSprite.Create(width, height);
  DrawingSurface *surface = sprite.GetDrawingSurface();
  surface.DrawingColor = color;
  surface.DrawStringWrapped(0, 0, width, font, align, message);
  surface.Release();
  Overlay *result = Overlay.CreateGraphical(x, y, sprite.Graphic, true);
  sprite.Delete();
  return result;
}

Overlay* BuildOverlay(this Character*, String message)
{
	//fix for room scrolling
	int char_x = this.x - Game.Camera.X;
	int char_y = this.y - Game.Camera.Y;
	
	//fix for localization
	message = GetTranslation(message);
	
	//fix for newer AGS versions
	Camera* cam;
	cam = Camera.Create();
	
	//original
  int width = GetTextWidth(message, Game.SpeechFont);
  int d = ((cam.Width / 6) * 4);
  if ((this.x <= (cam.Width / 4)) ||
      (this.x >= ((cam.Width / 4) * 3)))
  {
    d -= (cam.Width / 5);
  }
  if (width > d) width = d;
  int x = (this.x - (width / 2)) - 6;
  width += 6;
  if ((x + width) > cam.Width)
  {
    x = (cam.Width - width);
  }
  if (x < 0) x = 0;
  int height = GetTextHeight(message, Game.SpeechFont, width);
  ViewFrame *frame = Game.GetViewFrame(this.View, this.Loop, this.Frame);
  int y = (this.y - (((Game.SpriteHeight[frame.Graphic] * this.Scaling) / 100)
           + height + 2)) - 6;
  if ((y < 0) || ((y + height) > cam.Height))
  {
    y = (cam.Height - height);
  }
  return Overlay.CreateTextualAligned(x, y, width, Game.SpeechFont,
    this.SpeechColor, message, eAlignMiddleCenter);
}

void CheckForSpeechTimeout(this QueuedSpeech_t*)
{
  if (((this._channel != null) && (!this._channel.IsPlaying)) ||
      ((this._channel == null) && (this._speechTimer == 0))) //fix for audio message skipping
  {
    this.SkipCurrentMessage();
  }
  else if (this._speechTimer > 0) this._speechTimer--;
}

void Update(this QueuedSpeech_t*)
{
  if (this.MessageCount == 0) return;
  if (this.Paused)
  {
    if (this._overlay != null)
    {
      this.CheckForSpeechTimeout();
    }
    return;
  }
  int n = this.CurrentIndex;
  // if there is a delay but the timer is not set, then set the delay timer
  if (this._delayTimer == 0) this._delayTimer = this._delay[n];
  if (this._delayTimer > 0)
  {
    this._delayTimer--;
    if (this._delayTimer == 0) this._delayTimer--; // use -1 to show delay timer is finished
    return; // delay, so don't process the next item yet
  }
  Character *theCharacter = this._character[n];
  if (this._overlay == null)
  {
    if (String.IsNullOrEmpty(this._messages[n]))
    {
      this.SkipCurrentMessage();
      return;
    }
    this._overlay = theCharacter.BuildOverlay(this._messages[n]);
    int timer = ((this._messages[n].Length / Game.TextReadingSpeed) + 1) * GetGameSpeed();
    if (IntToFloat(timer) < (IntToFloat(Game.MinimumTextDisplayTimeMs) / 1000.0))
    {
      timer = FloatToInt(IntToFloat(Game.MinimumTextDisplayTimeMs) / 1000.0, eRoundNearest);
    }
    this._speechTimer = timer;
    if (this._clips[n] != null) this._channel = this._clips[n].Play();
    if (theCharacter.SpeechView != 0)
    {
      this._lockedView = true;
      if (!theCharacter.Moving)
      {
        theCharacter.LockView(theCharacter.SpeechView);
        theCharacter.Animate(theCharacter.Loop, theCharacter.SpeechAnimationDelay, eRepeat,
                             eNoBlock, eForwards);
      }
    }
    else this._lockedView = false;
  }
  else this.CheckForSpeechTimeout();
}

bool IsNullOrStopped(static AudioChannel, AudioChannel *channel)
{
  return ((channel == null) || (!channel.IsPlaying));
}

void QueuedSpeech_t::ClearQueue()
{
  int i;
  for (i = 0; i < this.MessageCount; i++)
  {
    this._character[i] = null;
    this._delay[i] = 0;
    this._messages[i] = null;
    this._clips[i] = null;
  }
  if (!Overlay.IsNullOrInvalid(this._overlay))
  {
    this._overlay.Remove();
  }
  this._overlay = null;
  this._delayTimer = 0;
  this.CurrentIndex = 0;
  this.Looping = false;
  this.MessageCount = 0;
  if (!AudioChannel.IsNullOrStopped(this._channel))
  {
    this._channel.Stop();
  }
  this._channel = null;
  this._speechTimer = 0;
  this._lockedView = false;
}

int get_Capacity(this QueuedSpeech_t*)
{
  return this._capacity;
}

void set_Capacity(this QueuedSpeech_t*, int value)
{
  this.Grow(value);
}

bool IsValidIndex(this QueuedSpeech_t*, int index)
{
  return ((index >= 0) && (index < this.MessageCount));
}

Character* geti_Characters(this QueuedSpeech_t*, int index)
{
  if (!this.IsValidIndex(index)) return null;
  return this._character[index];
}

int geti_MessageDelay(this QueuedSpeech_t*, int index)
{
  if (!this.IsValidIndex(index)) return 0;
  return this._delay[index];
}

String geti_Messages(this QueuedSpeech_t*, int index)
{
  if (!this.IsValidIndex(index)) return null;
  return this._messages[index];
}

AudioClip* geti_SpeechClips(this QueuedSpeech_t*, int index)
{
  if (!this.IsValidIndex(index)) return null;
  return this._clips[index];
}

function repeatedly_execute()
{
  QueuedSpeech.Update();
}

Overlay* GetOverlay(this QueuedSpeech_t*)
{
  return this._overlay;
}

bool IsViewLocked(this QueuedSpeech_t*)
{
  return this._lockedView;
}

function repeatedly_execute_always()
{
  if (QueuedSpeech.GetOverlay() != null)
  {
    if (!IsInterfaceEnabled())
    {
      QueuedSpeech.CheckForSpeechTimeout(); // ensure speech is removed if blocking event has begun
    }
    Character *chara = QueuedSpeech.geti_Characters(QueuedSpeech.CurrentIndex);
    if ((chara != null) && (chara.SpeechView != 0) && (QueuedSpeech.IsViewLocked()))
    {
      if (chara.Moving)
      {
        if (chara.View == chara.SpeechView)
        {
          #ifdef AGS_SUPPORTS_IFVER
          #ifver 3.4.1
          chara.UnlockView(false);
          #endif // 3.4.1+
          // else, we can't unlock the speech view without stopping the movement,
          // and we can't recreate the movement (WalkWhere param is unknown, even if we did it outside rep_ex_always)
          #endif // AGS_SUPPORTS_IF_VER
        }
        return;
      }
      if ((chara.View != chara.SpeechView) || (!chara.Animating))
      {
        chara.LockView(chara.SpeechView);
        chara.Animate(chara.Loop, chara.SpeechAnimationDelay, eRepeat, eNoBlock, eForwards);
      }
    }
  }
}
 �+  
#ifdef AGS_SUPPORTS_IFVER       
#ifver 3.4.0.3                  
#define QueuedSpeech_VERSION 4.2
#define QueuedSpeech_VERSION_420
#define QueuedSpeech_VERSION_400
#endif                          
#endif                          
#ifndef QueuedSpeech_VERSION    
#error QueuedSpeech module error: This module requires AGS version 3.4.0.3 or higher! Please upgrade to a higher version of AGS to use this module.
#endif                          

/*******************************************\
              AGS SCRIPT MODULE
                 QUEUEDSPEECH
               by monkey_05_06
---------------------------------------------

Description:

    Allows for queued background speech with animation and voice speech
    support.

Dependencies:

    AGS 3.4.0.3 (Alpha) or higher

Macros (#defines):

    QueuedSpeech_VERSION_420 - Defines version 4.2 of the module.
    QueuedSpeech_VERSION_400 - Defines version 4.0 of the module.
    QueuedSpeech_VERSION     - Defines the current version of the module.

What's New:

    The QueuedSpeech module v4.1 is a bugfix for the incorrectly
    implemented feature in v4.0 to unlock a character's view if they
    attempt to walk while also speaking in the background. The public
    API of the module has not changed.

---------------------------------------------

Functions and Properties:

bool Character.SayQueued(String message, optional AudioClip *speechClip, optional int delay, optional int slot)

  Displays MESSAGE as background speech in a queued fashion. You may
  optionally specify an AudioClip to use for voice-speech, and a delay
  to prevent the item being immediately displayed. SLOT may be
  specified to insert an item at a specific location in the queue,
  though you should generally add items in the order you want them to
  be displayed.
  
  Character speech animations will be played when they are speaking in
  the background, but may be stopped by calling Character.UnlockView.
  The character view will also automatically unlock if the character
  starts moving while speaking in the background, though the speech
  will not be removed or stopped.

void QueuedSpeech.ClearQueue()

  Clears all items from the background speech queue. Note that this
  will also remove any currently displayed item.

void QueuedSpeech.RemoveMessage(int index)

  Removes the specified item from the queue.
  
void QueuedSpeech.SkipCurrentMessage()

  Stops any background speech, and removes the current message from
  the queue. If looping, the item is not removed, but the
  CurrentIndex is advanced instead.

int QueuedSpeech.Capacity

  Gets or sets the capacity of the queue (from 1 to 1000000). May
  be increased only. If you are adding several items at once, then
  setting the capacity before-hand may improve performance. Note
  that the queue's capacity will automatically grow larger as
  items are needed, though setting it manually before adding
  several items can reduce copying, resulting in faster speeds.

readonly Character* QueuedSpeech.Characters[int index]

  Returns the Character associated with the specified message in
  the queue, or NULL if an invalid index is given.

readonly int QueuedSpeech.CurrentIndex

  Returns the index of the currently displayed message in the queue.
  If the queue is not currently looping then this will usually be
  zero, though when looping is turned off the queue will finish the
  remaining messages in their specified order before they are
  removed.

bool QueuedSpeech.Looping

  Gets or sets whether the queue should loop items, otherwise they
  are removed after they are used. The default is FALSE.

readonly String QueuedSpeech.Messages[int index]

  Returns the specified message in the queue, or NULL if an invalid
  index is specified.

readonly int QueuedSpeech.MessageCount

  Returns the number of messages currently stored in the
  background speech queue. Messages are added using the
  Character.SayQueued function.

readonly int QueuedSpeech.MessageDelay[int index]

  Returns the delay associated with the specified message in the
  queue, or zero if an invalid index is given or the message
  does not have a delay.

bool QueuedSpeech.Paused

  Gets or sets whether the queue is paused. New items will not be
  displayed while the queue is paused, though current items will
  be removed as normal. The default is FALSE.

AudioClip* QueuedSpeech.SpeechClips[int index]

  Returns the speech clip associated with the specified message in
  the queue, or NULL if an invalid index is specified.

---------------------------------------------

Licensing:

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation  files  (the  "Software"),  to
// deal in the Software without restriction, including without  limitation  the
// rights to use, copy, modify, merge, publish, distribute, sublicense,  and/or
// sell copies of the Software, and to permit persons to whom the  Software  is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be  included  in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,  EXPRESS  OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO  THE  WARRANTIES  OF  MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL  THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE  FOR  ANY  CLAIM,  DAMAGES  OR  OTHER
// LIABILITY, WHETHER IN AN ACTION OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

---------------------------------------------

Changelog:


Version:     4.2
Date:        1 October 2016
Author:      Potajito
Description: Bugfix for v4.0's fix the audio not playing, and adaptations for 
             AGS 3.5+

Version:     4.1
Date:        1 October 2016
Author:      monkey_05_06
Description: Bugfix for v4.0's incorrectly implemented unlocking feature. That
             feature is future-dated to AGS 3.4.1 (pending pull request #362).
             The public API is unchanged in this version.

Version:     4.0
Date:        27 January 2015
Author:      monkey_05_06
Description: Added support for dynamic-sized queue, added QueuedSpeech.Capacity,
             removed MaxLinesInQueue enum; removed all static functions,
             replaced with non-static functions and properties; IsQueueEmpty
             and IsQueueFull removed; GetItemCountInQueue() renamed to property
             MessageCount; IsLooping, StartLooping, and StopLooping renamed to
             property Looping; GetCurrentIndex() renamed to property
             CurrentIndex; GetCharacter(INDEX) renamed to property
             Characters[INDEX]; GetMessage(INDEX) renamed to property
             Messages[INDEX]; GetSpeechClip(INDEX) renamed to property
             SpeechClips[INDEX]; GetDelay(INDEX) renamed to property
             MessageDelay[INDEX]; PauseQueue and UnPauseQueue renamed to
             property Paused. Added RemoveMessage(INDEX). Characters now
             unlock from speech view if they begin moving while speaking in
             the background.

Version:     3.5
Date:        25 January 2013
Author:      monkey_05_06
Description: Update to AGS 3.2+'s new audio system (does not include old-style
             audio support). Minimum required AGS version increased to 3.2.
             VERSION macro is now formatted as a floating-point number for
             convenience. Global function QueuedSpeech.GetSpeechNumber(slot)
             has been renamed to QueuedSpeech.GetSpeechClip(slot) to reflect
             the changed return type from int to AudioClip*. Added AudioClip*
             parameter "speechClip" to Character.SayQueued (between message
             and delay parameters).

Version:     3.0
Date:        07 January 2009
Author:      monkey_05_06
Description: Rewrite of module for AGS 3.1+. Now uses extender method for
             better integration with AGS's functions. Renamed most functions
             and otherwise changed the general behaviours of them all anyway.
             See above for current functionality.

Version:     2.0
Date:        14 December 2005
Author:      monkey_05_06
Description: Added support for old-style strings, fixed SkipCurrentMessage
             skipping the current and next messages instead of just the
             current one, fixed speech sound continuing if message skipped.

Version:     1.0
Date:        04 December 2005
Author:      monkey_05_06
Description: First public version of module, based on scripts by Scorpiorus.

\*******************************************/

///QueuedSpeech module: Displays MESSAGE as background speech in a queued fashion.
import bool SayQueued(this Character*, String message, AudioClip *speechClip=0, int delay=0, int slot=SCR_NO_VALUE);

struct QueuedSpeech_t
{
  protected int _capacity;
  protected Character *_character[];
  protected AudioClip *_clips[];
  protected int _delay[];
  protected String _messages[];
  protected Overlay *_overlay;
  protected int _delayTimer;
  protected AudioChannel *_channel;
  protected int _speechTimer;
  protected bool _lockedView;
  ///QueuedSpeech module: Clears all items from the background speech queue.
  import void ClearQueue();
  ///QueuedSpeech module: Removes the specified message from the background speech queue.
  import void RemoveMessage(int index);
  ///QueuedSpeech module: Removes the current message from the queue, and stops any current background speech.
  import void SkipCurrentMessage();
  ///QueuedSpeech module: Gets or sets the capacity of the queue (from 1 to 1000000). May be increased only.
  import attribute int Capacity;
  ///QueuedSpeech module: Gets or sets whether the queue should loop items, otherwise they are removed after they are used.
  bool Looping;
  ///QueuedSpeech module: Gets or sets whether the queue is paused. New items will not be displayed while the queue is paused.
  bool Paused;
  ///QueuedSpeech module: Returns the number of messages currently stored in the background speech queue.
  writeprotected int MessageCount;
  ///QueuedSpeech module: Returns the index of the currently displayed message in the queue.
  writeprotected int CurrentIndex;
  ///QueuedSpeech module: Returns the Character associated with the specified message in the queue.
  readonly import attribute Character* Characters[];
  ///QueuedSpeech module: Returns the delay associated with the specified message in the queue.
  readonly import attribute int MessageDelay[];
  ///QueuedSpeech module: Returns the specified message in the queue.
  readonly import attribute String Messages[];
  ///QueuedSpeech module: Returns the speech clip associated with the specified message in the queue.
  readonly import attribute AudioClip* SpeechClips[];
};

import QueuedSpeech_t QueuedSpeech;
 	��        ej��