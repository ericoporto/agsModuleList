AGSScriptModule    Ivan Mogilko Module implements Timer class Timer 0.9.0 �/  // Check against this value instead of 0.0 to reduce potential floating-point mistakes
#ifndef TINY_FLOAT
#define TINY_FLOAT 0.001
#endif

//===========================================================================
//
// Internal data.
//
//===========================================================================
// Internal timer references, need them to actually count down
Timer *Timers[MAX_RUNNING_TIMERS];
// Number of seconds in a game tick (updated)
float GameTickTime;
// Whether all timers should be paused when game is paused
bool AllPauseWithGame;
// Whether game was paused last time we checked
bool WasGamePaused;
// Whether 
bool IsGamePausedNow;


//===========================================================================
//
// FindFreeSlot()
// Finds a free timer slot, returns internal ID, or -1 if timers limit reached.
//
//===========================================================================
int FindFreeSlot()
{
  int i;
  for (i = 0; i < MAX_RUNNING_TIMERS; i++)
  {
    if (Timers[i] == null)
      return i;
  }
  return -1;
}

//===========================================================================
//
// Timer::Init().
// Inits timer parameters.
//
//===========================================================================
void Init(this Timer*, int id, bool realtime, float timeout, RepeatStyle repeat)
{
  this._id = id;
  this._realtime = realtime;
  this._timeout = timeout;
  this._repeat = repeat;
  this._remains = timeout;
  this._evt = false;
  this._paused = 0;
  this._pauseWithGame = false;
  this._room = -1;
  this._whenLeavingRoom = eTimerStop;
}

//===========================================================================
//
// Timer::StopImpl(), PauseImpl() and ResumeImpl()
// Internal implementations for stopping, pausing and resuming a timer.
//
//===========================================================================
void StopImpl(this Timer*)
{
  this._timeout = 0.0;
  this._remains = 0.0;
  this._evt = false;
  this._paused = 0;
}

void PauseImpl(this Timer*, int flag)
{
  this._paused = this._paused | flag;
}

void ResumeImpl(this Timer*, int flag)
{
  // Had to do this, because AGS script does not have "~"
  this._paused = this._paused & (TIMER_PAUSED_BY_USER + TIMER_PAUSED_BY_GAME + TIMER_PAUSED_BY_ROOM - flag);
}

//===========================================================================
//
// Timer::RemoveRef()
// Removes timer reference from the internal array.
//
//===========================================================================
void RemoveRef(this Timer*)
{
  if (this._id >= 0)
  {
    Timers[this._id] = null;
    this._id = -1;
  }
}

//===========================================================================
//
// Timer's read-only properties meant to inspect the object.
//
//===========================================================================
bool get_IsActive(this Timer*)
{
  return this._id >= 0;
}

bool get_EvtExpired(this Timer*)
{
  return this._evt;
}

bool get_IsRealtime(this Timer*)
{
  return this._realtime;
}

int get_TimeoutTicks(this Timer*)
{
  if (this._realtime)
    return FloatToInt(this._timeout * IntToFloat(GetGameSpeed()), eRoundUp);
  else
    return FloatToInt(this._timeout, eRoundUp);
}

float get_TimeoutSeconds(this Timer*)
{
  if (this._realtime)
    return this._timeout;
  else
    return this._timeout * GameTickTime;
}

int get_RemainingTicks(this Timer*)
{
  if (this._realtime)
    return FloatToInt(this._remains * IntToFloat(GetGameSpeed()), eRoundUp);
  else
    return FloatToInt(this._remains, eRoundUp);
}

float get_RemainingSeconds(this Timer*)
{
  if (this._realtime)
    return this._remains;
  else
    return this._remains * GameTickTime;
}

int get_IsPaused(this Timer*)
{
  return this._paused;
}

int get_HomeRoom(this Timer*)
{
  return this._room;
}

LocalTimerBehavior get_WhenLeavingRoom(this Timer*)
{
  return this._whenLeavingRoom;
}

//===========================================================================
//
// Timer::MakeLocal().
// Makes timer local to current room
//
//===========================================================================
void MakeLocal(this Timer*, LocalTimerBehavior on_leave)
{
  this._room = player.Room;
  this._whenLeavingRoom = on_leave;
}

//===========================================================================
//
// Timer::StartTimer()
// Create and start the global timer with the given parameters.
//
//===========================================================================
Timer *StartTimer(bool realtime, float timeout, RepeatStyle repeat)
{
  int id = FindFreeSlot();
  if (id == -1)
  {
    Display("Timer.asc: timers limit reached, cannot start another timer before any of the active ones has stopped.");
    return null;
  }
  Timer *timer = new Timer;
  timer.Init(id, realtime, timeout, repeat);
  Timers[id] = timer;
  return timer;
}

//===========================================================================
//
// Timer::StartTimerLocal()
// Create and start the locl timer with the given parameters.
//
//===========================================================================
Timer *StartTimerLocal(bool realtime, float timeout, LocalTimerBehavior on_leave, RepeatStyle repeat)
{
  Timer *t = StartTimer(realtime, timeout, repeat);
  if (t == null)
    return null;
  t.MakeLocal(on_leave);
  return t;
}

//===========================================================================
//
// Timer::Start() and StartLocal()
// Create and start the global or local timer with timeout given in game ticks.
//
//===========================================================================
static Timer *Timer::Start(int timeout, RepeatStyle repeat)
{
  return StartTimer(false, IntToFloat(timeout), repeat);
}

static Timer *Timer::StartLocal(int timeout, LocalTimerBehavior on_leave, RepeatStyle repeat)
{
  return StartTimerLocal(false, IntToFloat(timeout), on_leave, repeat);
}

//===========================================================================
//
// Timer::StartRT() and StartLocalRT()
// Create and start the global or local timer with timeout in real time (seconds).
//
//===========================================================================
static Timer *Timer::StartRT(float timeout_s, RepeatStyle repeat)
{
  return StartTimer(true, timeout_s, repeat);
}

static Timer *Timer::StartLocalRT(float timeout_s, LocalTimerBehavior on_leave, RepeatStyle repeat)
{
  return StartTimerLocal(true, timeout_s, on_leave, repeat);
}

//===========================================================================
//
// Timer::IsExpired().
// Tells whether timer has just expired. Safe to pass null-pointer.
//
//===========================================================================
static bool Timer::IsExpired(Timer *t)
{
  return t != null && t.get_EvtExpired();
}

//===========================================================================
//
// Timer::Stop(), Pause() and Resume().
// Stops, pauses and resumes the running timer. Safe to pass null-pointer.
//
//===========================================================================
static void Timer::Stop(Timer *t)
{
  if (t != null) {
    t.StopImpl();
    t.RemoveRef();
  }
}

static void Timer::Pause(Timer *t)
{
  if (t != null)
    t.PauseImpl(TIMER_PAUSED_BY_USER);
}

static void Timer::Resume(Timer *t)
{
  if (t != null)
    t.ResumeImpl(TIMER_PAUSED_BY_USER);
}

//===========================================================================
//
// Timer::AllPauseWithGame static property.
// Gets/sets whether all timers should pause when game is paused.
//
//===========================================================================
bool get_AllPauseWithGame(static Timer)
{
  return AllPauseWithGame;
}

void set_AllPauseWithGame(static Timer, bool pause)
{
  AllPauseWithGame = pause;
}

//===========================================================================
//
// Timer::PauseWithGame property.
// Gets/sets whether this particular timer should pause when game is paused.
//
//===========================================================================
bool get_PauseWithGame(this Timer*)
{
  return this._pauseWithGame;
}

void set_PauseWithGame(this Timer*, bool pause)
{
  this._pauseWithGame = pause;
}

//===========================================================================
//
// Timer::Countdown().
// Main update function. Counts down once and checks if timeout was reached.
//
//===========================================================================
bool Countdown(this Timer*)
{
  // If timer has finished on last tick, and is not repeating one, then tell system to release the timer object
  if (this._evt && !this._repeat)
    return false;

  // If timer is paused, skip an update
  if (this.get_IsPaused())
    return true;

  // Otherwise, counting down
  if (this._realtime)
    this._remains -= GameTickTime;
  else
    this._remains -= 1.0;
  // If timer just ran out, set event flag
  if (this._remains < TINY_FLOAT)
  {
    this._evt = true;
    if (this._repeat)
      this._remains = this._timeout; // if repeating, then reset
    // keep the timer reference for one more tick even if it's not repeating one
  }
  else
  {
    this._evt = false;
  }
  return true;
}


//===========================================================================
//
// on_event()
//
// Reacts to leaving and entering rooms.
//
//===========================================================================
function on_event(EventType event, int data)
{
  int i;
  if (event == eEventLeaveRoom)
  {
    for (i = 0; i < MAX_RUNNING_TIMERS; i++)
    {
      Timer *timer = Timers[i];
      if (timer == null)
        continue;
      if (timer.get_HomeRoom() == data)
      {
        if (timer.get_WhenLeavingRoom() == eTimerStop)
          timer.StopImpl();
        else
          timer.PauseImpl(TIMER_PAUSED_BY_ROOM);
      }
    }
  }
  else if (event == eEventEnterRoomBeforeFadein)
  {
    for (i = 0; i < MAX_RUNNING_TIMERS; i++)
    {
      Timer *timer = Timers[i];
      if (timer == null)
        continue;
      if (timer.get_HomeRoom() == data)
      {
        if (timer.get_WhenLeavingRoom() == eTimerPause)
          timer.ResumeImpl(TIMER_PAUSED_BY_ROOM);
      }
    }
  }
}

//===========================================================================
//
// repeatedly_execute_always()
//
// Updates the active timers.
//
//===========================================================================
function repeatedly_execute_always()
{
  // We have to update value of GameTickTime each time, unfortunately, in case game speed changed
  GameTickTime = 1.0 / IntToFloat(GetGameSpeed());
  // Set game paused flag (we can only do this in rep_exec (no distinct event)
  IsGamePausedNow = IsGamePaused();

  int i;
  if (IsGamePausedNow != WasGamePaused)
  {
    for (i = 0; i < MAX_RUNNING_TIMERS; i++)
    {
      Timer *timer = Timers[i];
      if (timer == null)
        continue;
      if (AllPauseWithGame || timer.get_PauseWithGame())
      {
        if (IsGamePausedNow)
          timer.PauseImpl(TIMER_PAUSED_BY_GAME);
        else
          timer.ResumeImpl(TIMER_PAUSED_BY_GAME);
      }
    }
    WasGamePaused = IsGamePausedNow;
    // Note, that we still call timer's countdown afterwards, even if they
    // are supposed to be paused, because Countdown function also checks for
    // the finalized timers (the ones waiting for event signal to be reset).
  }

  for (i = 0; i < MAX_RUNNING_TIMERS; i++)
  {
    Timer *timer = Timers[i];
    if (timer == null)
      continue;
    if (!timer.Countdown())
    {
      // If timer finished working, then stop it and remove its reference from the array
      Timer.Stop(timer);
    }
  }
}
 L  // Timer is open source under the MIT License.
//
// TERMS OF USE - Timer MODULE
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
// Module implements Timer class.
//
// This module does not use built-in AGS timers in any way, and has its own limit of
// simultaneously running timmers.
//
// Timer's timeout can be defined in game ticks or real time.
// Timer can be tagged as "local", restricted to the room it created in, that either
// pause or stop completely when that room is unloaded (and may resume upon return).
// Timer can be paused and resumed at will, also told to pause and resume with game.
//
//////////////////////////////////////////////////////////////////////////////////////////

#ifndef __TIMER_MODULE__
#define __TIMER_MODULE__

#define TIMER_VERSION_00_00_90_00

// Maximal number of simultaneously running timers (not related to built-in AGS limit).
#define MAX_RUNNING_TIMERS 20

// Local timer behavior when room has changed
enum LocalTimerBehavior
{
  eTimerPause, 
  eTimerStop
};

// Flags determining the reason for timer's pause (can be combined using bitwise OR)
#define TIMER_PAUSED_BY_USER 1
#define TIMER_PAUSED_BY_GAME 2
#define TIMER_PAUSED_BY_ROOM 4


///////////////////////////////////////////////////////////////////////////////
//
// Managed Timer class.
//
///////////////////////////////////////////////////////////////////////////////
managed struct Timer
{
  //
  // General operations.
  //
  
  /// Start the timer, giving timeout in game ticks.
  import static Timer *Start(int timeout, RepeatStyle repeat = eOnce);
  /// Start the timer, giving timeout in real time (seconds).
  /// Remember that timer can be only as precise as your GameSpeed (40 checks per
  /// second, or 0.025s by default).
  import static Timer *StartRT(float timeout_s, RepeatStyle repeat = eOnce);
  /// Starts local timer working in game ticks, that may be paused when player leaves the room
  import static Timer *StartLocal(int timeout, LocalTimerBehavior on_leave = eTimerStop, RepeatStyle repeat = eOnce);
  /// Starts local timer working in real time (seconds), that may be paused when player leaves the room
  import static Timer *StartLocalRT(float timeout_s, LocalTimerBehavior on_leave = eTimerStop, RepeatStyle repeat = eOnce);
  
  /// Tells whether timer has JUST expired. Safe to pass null-pointer.
  import static bool   IsExpired(Timer *t);
  /// Stops the running timer. Safe to pass null-pointer.
  import static void   Stop(Timer *t);
  /// Pause the running timer. Safe to pass null-pointer.
  import static void   Pause(Timer *t);
  /// Resume the running timer. Safe to pass null-pointer.
  import static void   Resume(Timer *t);
  
  //
  // Additional setup.
  //
  
  /// Gets/sets whether all timers should pause when game is paused
  import static attribute bool    AllPauseWithGame;
  /// Gets/sets whether this particular timer should pause when game is paused
  import attribute bool           PauseWithGame;
  /// Gets the home room of the local timer (returns -1 if timer is global)
  import readonly attribute int   HomeRoom;
  /// Gets what this timer should do when home room gets unloaded
  import readonly attribute LocalTimerBehavior WhenLeavingRoom;
  
  //
  // Current state inspection.
  //
  
  /// Tells whether timer is currently active (counting down).
  import readonly attribute bool  IsActive;
  /// Signal property telling that the timer has expired. This flag will remain set
  /// for one game tick only and self-reset afterwards.
  import readonly attribute bool  EvtExpired;
  
  /// Gets whether this timer is working in real-time
  import readonly attribute bool  IsRealtime;
  /// Gets the timer's timeout in game ticks
  import readonly attribute int   TimeoutTicks;
  /// Gets the timer's timeout in real-time (considering current game speed)
  import readonly attribute float TimeoutSeconds;
  /// Gets the remaining time in current game ticks
  import readonly attribute int   RemainingTicks;
  /// Gets the remaining time in real-time (considering current game speed)
  import readonly attribute float RemainingSeconds;
  /// Gets current timer's paused state (0 - working, >= 1 - suspended)
  import readonly attribute int   IsPaused;
  
  
  //
  // Internal data.
  //
  
  protected int   _id; // internal ID of the timer
  protected bool  _realtime; // is timeout in seconds (otherwise in game ticks)
  protected float _timeout; // timeout (ticks or ms)
  protected bool  _repeat; // should auto-repeat or not
  protected float _remains; // time remaining (ticks or seconds)
  protected bool  _evt; // expired event flag
  protected int   _paused; // if the timer is paused
  
  protected bool  _pauseWithGame; // if the timer paused
  protected int   _room; // if the timer paused
  protected LocalTimerBehavior _whenLeavingRoom; // what local timer does when its room gets unloaded
};

#endif  // __TIMER_MODULE__
 ��`E        ej��