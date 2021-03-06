AGSScriptModule    monkey_05_06 Provides functions to simplify adding a countdown timer to your game and, optionally, display the remaining time on a label. CountDown 1.0 �  
__CountDown CountDown;
export CountDown;

bool __CountDown::SetRawTime(int gameLoops) {
  // if loops is less than 0 or greater than 99 hours, 59 minutes, 59 seconds, abort
  if ((gameLoops < 0) || (gameLoops > (((99 * 3600) + (59 * 60) + 59) * GetGameSpeed()))) return false;
  this.RawTimeRemaining = gameLoops;
  gameLoops = (gameLoops / GetGameSpeed());
  this.Hours = (gameLoops / 3600);
  gameLoops = (gameLoops % 3600);
  this.Minutes = (gameLoops / 60);
  this.Seconds = (gameLoops % 60);
  this.Paused = false;
}

int TimeToGameLoops(int seconds, int minutes, int hours) {
  return ((((hours * 3600) + (minutes * 60)) + seconds) * GetGameSpeed());
}

bool __CountDown::SetTime(int seconds, int minutes, int hours) {
  return this.SetRawTime(TimeToGameLoops(seconds, minutes, hours));
}

void __CountDown::Pause(int gameLoops) {
  if (!this.RawTimeRemaining) return;
  this.PauseTimer = gameLoops;
  this.Paused = true;
}

void __CountDown::UnPause() {
  if (!this.RawTimeRemaining) return;
  this.PauseTimer = -1;
  this.Paused = false;
}

void __CountDown::Stop() {
  this.PauseTimer = -1;
  this.Paused = true;
  this.RawTimeRemaining = 0;
  this.Hours = 0;
  this.Minutes = 0;
  this.Seconds = 0;
}

function game_start() {
  CountDown.Stop(); // initialize some protected settings
  CountDown.TimesUpNewRoom = -1;
  CountDown.TimesUpNewRoomX = SCR_NO_VALUE;
  CountDown.TimesUpNewRoomY = SCR_NO_VALUE;
}

void Update(this __CountDown*, bool always) {
  if ((IsGamePaused()) && (this.PauseWhileGamePaused)) this.Pause(-2);
  else if (this.PauseTimer == -2) this.UnPause();
  if ((!always) && (!this.Paused) && (!this.RawTimeRemaining)) {
    if (this.TimesUpText != null) {
      if (this.TimesUpAnnouncer != null) this.TimesUpAnnouncer.Say(this.TimesUpText);
      else Display(this.TimesUpText);
    }
    if (this.TimesUpNewRoom >= 0) player.ChangeRoom(this.TimesUpNewRoom, this.TimesUpNewRoomX, this.TimesUpNewRoomY);
    this.Stop();
    return;
  }
  else if (!always) return;
  if (!this.Paused) {
    if (this.RawTimeRemaining) this.SetRawTime(this.RawTimeRemaining - 1);
  }
  else if (this.PauseTimer > 0) this.PauseTimer--;
  else if (!this.PauseTimer) this.UnPause();
  if (this.ShowOnLabel != null) {
    if ((this.LabelText == null) || (this.ShowOnLabel.Text != this.LabelText)) this.LabelFormat = this.ShowOnLabel.Text; // if this is the first time, or if the label text has been explicitly changed
    else if (this.LabelFormat != null) this.ShowOnLabel.Text = this.LabelFormat; // otherwise, restore the formatting to the label so it can be updated
    if (!this.Paused) {
      this.ShowOnLabel.Text = this.ShowOnLabel.Text.Replace("RAWTIME", String.Format("%d", this.RawTimeRemaining));
      this.ShowOnLabel.Text = this.ShowOnLabel.Text.Replace("HH", String.Format("%02d", this.Hours));
      this.ShowOnLabel.Text = this.ShowOnLabel.Text.Replace("H", String.Format("%d", this.Hours), true);
      this.ShowOnLabel.Text = this.ShowOnLabel.Text.Replace("MM", String.Format("%02d", this.Minutes));
      this.ShowOnLabel.Text = this.ShowOnLabel.Text.Replace("M", String.Format("%d", this.Minutes), true);
      this.ShowOnLabel.Text = this.ShowOnLabel.Text.Replace("SS", String.Format("%02d", this.Seconds));
      this.ShowOnLabel.Text = this.ShowOnLabel.Text.Replace("S", String.Format("%d", this.Seconds), true);
    }
    this.LabelText = this.ShowOnLabel.Text; // store the currently shown text so we know if it's been changed to a new format
    if ((this.HideGUIWhileInactive) && (!this.RawTimeRemaining)) this.ShowOnLabel.OwningGUI.Visible = false;
    else if ((this.HideGUIWhilePaused) && (this.Paused)) this.ShowOnLabel.OwningGUI.Visible = false;
    else this.ShowOnLabel.OwningGUI.Visible = true;
    this.ShowOnLabel.Visible = true;
  }
}

function repeatedly_execute_always() {
  CountDown.Update(true);
}

function repeatedly_execute() {
  CountDown.Update(false);
}
 �8  //-----------------------------------------------------------------------------------
// Module: CountDown
// Author:     monkey_05_06
// Requires:   AGS 2.71 or higher
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// 1 Description
// 
// Provides functions to simplify adding a countdown timer to your game and,
// optionally, display the remaining time on a label.
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// 2 Macros (#define-s)
#define CountDown_VERSION 100
#define CountDown_VERSION_100
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// 3 Functions and Properties

struct __CountDown {
  ///CountDown module: The number of hours remaining in the countdown.
  writeprotected int Hours;
  // blargh:
  // Returns the number of hours remaining in the current countdown.
  // 
  //   See also: CountDown.Minutes, CountDown.Seconds, CountDown.RawTimeRemaining,
  //   CountDown.SetTime
  
  ///CountDown module: The number of minutes remaining in the countdown.
  writeprotected int Minutes;
  // blargh:
  // Returns the number of minutes remaining in the current countdown.
  // 
  //   See also: CountDown.Hours, CountDown.Seconds, CountDown.RawTimeRemaining,
  //   CountDown.SetTime
  
  ///CountDown module: The number of seconds remaining in the countdown.
  writeprotected int Seconds;
  // blargh:
  // Returns the number of seconds remaining in the current countdown.
  // 
  //   See also: CountDown.Hours, CountDown.Minutes, CountDown.RawTimeRemaining,
  //   CountDown.SetTime
  
  ///CountDown module: The raw number of game loops remaining in the countdown.
  writeprotected int RawTimeRemaining;
  // blargh:
  // Returns the raw number of game loops remaining in the current countdown.
  // 
  //   See also: CountDown.Hours, CountDown.Minutes, CountDown.Seconds,
  //   CountDown.SetRawTime
  
  ///CountDown module: Whether the countdown is currently paused. Always returns true if the countdown has run out.
  writeprotected bool Paused;
  // blargh:
  // Returns whether the countdown is currently paused. Always returns true if the
  // countdown has run out.
  // 
  //   See also: CountDown.PauseTimer, CountDown.Pause, CountDown.UnPause,
  //   CountDown.Stop, CountDown.HideGUIWhilePaused, CountDown.PauseWhileGamePaused
  
  ///CountDown module: If the countdown was paused for a specific time, this returns how many raw game loops remain until it is unpaused. Otherwise returns -1.
  writeprotected int PauseTimer;
  // blargh:
  // If the countdown was paused for a specific time this returns how many game loops
  // remain until the countdown is automatically unpaused. If PauseWhileGamePaused
  // is set to TRUE and the game is paused this will return -2. Otherwise this
  // returns -1.
  // 
  // See also: CountDown.Paused, CountDown.Pause, CountDown.UnPause,
  // CountDown.PauseWhileGamePaused
  
  ///CountDown module: Pauses the countdown. Optionally you may specify a certain number of game loops to pause the countdown for after which it will automatically be unpaused.
  import void Pause(int gameLoops=-1);
  // Pauses the countdown. You may optionally specify an exact number of game loops
  // to pause the countdown for after which it will automatically resume. Otherwise
  // the countdown will remain paused until manually unpaused.
  // 
  //   NOTE: If PauseWhileGamePaused is set to TRUE and the game is subsequently paused
  //   any existing timer value will be lost. If you want to use both features together
  //   you will need to manually track the time paused and unpause it with UnPause.
  // 
  //   See also: CountDown.Paused, CountDown.PauseTimer, CountDown.UnPause,
  //   CountDown.HideGUIWhilePaused, CountDown.PauseWhileGamePaused, TimeToGameLoops
  
  ///CountDown module: Unpauses the countdown.
  import void UnPause();
  // Resumes the countdown after a pause. If the countdown is paused for a specific
  // amount of time, this is automatically called when that time has run out.
  // 
  //   See also: CountDown.Pause, CountDown.PauseTimer, CountDown.Paused
  
  ///CountDown module: Stops the countdown running. This will not trigger any TimesUp events.
  import void Stop();
  // Stops the countdown completely. Note that this is NOT the same as just letting
  // the countdown run out, as any "TimesUp" events will not be triggered by this
  // function. If you want to end the countdown and trigger the events use
  // SetRawTime instead.
  // 
  //   See also: CountDown.SetRawTime
  
  ///CountDown module: Sets the countdown to a specific number of seconds, minutes, and hours.
  import bool SetTime(int seconds, int minutes=0, int hours=0);
  // Sets the time remaining in the countdown. Seconds and minutes will automatically
  // be converted into minutes and hours (respectively) if greater than 59. The total
  // time for the countdown cannot exceed 99 hours, 59 minutes, and 59 seconds though
  // there is no technical reason behind this. If this is too inhibiting contact me
  // at the AGS forums and I will see about changing this limitation.
  // 
  //   See also: CountDown.SetRawTime, CountDown.Hours, CountDown.Minutes,
  //   CountDown.Seconds
  
  ///CountDown module: Sets the countdown to a specific number of game loops.
  import bool SetRawTime(int gameLoops);
  // Sets the time remaining in the countdown. The total time for the countdown
  // cannot exceed 99 hours, 59 minutes, and 59 seconds though there is no technical
  // reason behind this. If this is too inhibiting contact me at the AGS forums and I
  // will see about changing this limitation.
  // 
  //   See also: CountDown.SetTime, CountDown.Hours, CountDown.Minutes,
  //   CountDown.Seconds, CountDown.RawTimeRemaining, TimeToGameLoops
  
  ///CountDown module: Gets/sets whether to hide the specified GUI (if available, see ShowOnLabel) after the timer has run out or has been stopped.
  bool HideGUIWhileInactive;
  // blargh:
  // Gets/sets whether the specified GUI should be hidden if the countdown is
  // disabled (never run, run out, or stopped). The GUI used is the OwningGUI of the
  // ShowOnLabel property. If ShowOnLabel is null this property is ignored.
  // 
  //   See also: CountDown.ShowOnLabel, CountDown.RawTimeRemaining, CountDown.Stop,
  //   CountDown.HideGUIWhilePaused
  
  ///CountDown module: Gets/sets whether to hide the specified GUI (if available, see ShowOnLabel) while the countdown is paused.
  bool HideGUIWhilePaused;
  // blargh:
  // Gets/sets whether the specified GUI should be hidden while the countdown is
  // paused. The GUI used is the OwningGUI of the ShowOnLabel property. If
  // ShowOnLabel is null this property is ignored.
  // 
  //   See also: CountDown.Paused, CountDown.Pause, CountDown.UnPause,
  //   CountDown.PauseWhileGamePaused, CountDown.HideGUIWhileInactive
  
  ///CountDown module: Gets/sets whether the countdown should be paused when the game is paused.
  bool PauseWhileGamePaused;
  // blargh:
  // Gets/sets whether the countdown should be paused when the game is paused. If the
  // countdown was already paused it may become unpaused in the event that this
  // property is set to TRUE and the game becomes unpaused.
  // 
  //   See also: PauseGame, UnPauseGame, IsGamePaused, CountDown.Paused
  
  ///CountDown module: If text is specified (TimesUpText), this sets the character that will say the text. If null Display will be used instead.
  Character *TimesUpAnnouncer;
  // blargh:
  // Gets/sets the character that will announce when the countdown has run out. If
  // TimesUpText is null this property will be ignored. If this property is null then
  // Display will be called instead.
  // 
  //   See also: CountDown.RawTimeRemaining, CountDown.TimesUpText
  
  ///CountDown module: Specifies the text displayed to the user after the countdown has run out.
  String TimesUpText;
  // blargh:
  // Gets/sets the text used to let the player know that the countdown has run out.
  // If this property is set then when the timer runs out the text will automatically
  // be said by the character set to announce it (see TimesUpAnnouncer).
  // 
  //   NOTE: This event will NOT be automatically triggered using the Stop function.
  //   If you want to stop the current countdown and run this event use the
  //   SetRawTime function to set the raw time to 0 game loops instead.
  // 
  //   See also: CountDown.RawTimeRemaining, CountDown.TimesUpAnnouncer
  
  ///CountDown module: Specifies the room to take the player to after the countdown has run out.
  int TimesUpNewRoom;
  // blargh:
  // Gets/sets the room to move the player character to when the countdown has run
  // out (-1 for none).
  // 
  //   NOTE: This event will NOT be automatically triggered using the Stop function.
  //   If you want to stop the current countdown and run this event use the
  //   SetRawTime function to set the raw time to 0 game loops instead.
  // 
  //   See also: CountDown.RawTimeRemaining, CountDown.TimesUpNewRoomX,
  //   CountDown.TimesUpNewRoomY
  
  ///CountDown module: Specifies the X co-ordinate in the new room to move the player to after the countdown has run out.
  int TimesUpNewRoomX;
  // blargh:
  // Gets/sets the X co-ordinate to move the player character to in the new room when
  // the countdown has run out. If TimesUpNewRoom has not been set then this property
  // will be ignored.
  // 
  //   NOTE: This event will NOT be automatically triggered using the Stop function.
  //   If you want to stop the current countdown and run this event use the
  //   SetRawTime function to set the raw time to 0 game loops instead.
  // 
  //   See also: CountDown.RawTimeRemaining, CountDown.TimesUpNewRoom,
  //   CountDown.TimesUpNewRoomY
  
  ///CountDown module: Specifies the Y co-ordinate in the new room to move the player to after the countdown has run out.
  int TimesUpNewRoomY;
  // blargh:
  // Gets/sets the Y co-ordinate to move the player character to in the new room when
  // the countdown has run out. If TimesUpNewRoom has not been set then this property
  // will be ignored.
  // 
  //   NOTE: This event will NOT be automatically triggered using the Stop function.
  //   If you want to stop the current countdown and run this event use the
  //   SetRawTime function to set the raw time to 0 game loops instead.
  // 
  //   See also: CountDown.RawTimeRemaining, CountDown.TimesUpNewRoom,
  //   CountDown.TimesUpNewRoomX
  
  ///CountDown module: Gets/sets the label used to display the current time remaining in the countdown.
  Label *ShowOnLabel;
  // blarg:
  // Gets/sets the label used to automatically display the current value of the
  // countdown. This accepts the following different values in formatting the label
  // text...
  // 
  //   H, HH - Displays the number of hours remaining in the countdown
  //   M, MM - Displays the number of minutes remaining in the countdown
  //   S, SS - Displays the number of seconds remaining in the countdown
  //   RAWTIME - Displays the raw time (in game loops) remaining in the countdown
  // 
  // The double-digit variants (HH, MM, SS) are all padded to 2 places; the rest of
  // the values are replaced with the exact value (no padding is applied). You can
  // set the formatting for the label in the editor, or by changing the label text
  // at any time. Some examples of how you might set the format include:
  // 
  //   H hours, M minutes, S seconds remaining
  //   HH:MM:SS remains
  //   The bomb will explode in RAWTIME.
  // 
  // Note that the values used by the module are case sensitive (they must be
  // capitalized to be replaced) however there is no other check against the
  // formatting, so if you used for example the string "Hours" the H WOULD be
  // replaced.
  // 
  //   See also: CountDown.Hours, CountDown.Minutes, CountDown.Seconds,
  //   CountDown.RawTimeRemaining, CountDown.HideGUIWhileInactive,
  //   CountDown.HideGUIWhilePaused

  protected String LabelFormat;
  protected String LabelText;
};

import __CountDown CountDown;
///CountDown module: Converts the specified time into raw game loops.
import int TimeToGameLoops(int seconds, int minutes=0, int hours=0);
// Converts the specified time into raw game loops.
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// 4 Licensing
// 
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
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// 5 Module Change Log
// 
// Version:     1.0
// Date:        15 December 2009
// Author:      monkey_05_06
// Description: First public version of module.
//-----------------------------------------------------------------------------------
 �(J        ej��