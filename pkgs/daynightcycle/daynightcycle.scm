AGSScriptModule    Snarky Day/Night Cycle DayNight 1.2.0 K$  //===================================================================
// *** AGS MODULE SCRIPT ***
//
// Module: Day/Night Cycle
// Version: 1.2.0 (2014-02-01)
// Author: Gunnar Harboe (Snarky)
//-------------------------------------------------------------------

//===================================================================
// Variables:
// Variables used by this module. Don't mess with these without
// good reason.
//-------------------------------------------------------------------

  bool dayNight_timeIsRunning = false;
  int dayNight_frameCounter = 0;
  int dayNight_dayCounter = 0;
  int dayNight_minuteCounter = 0;
  
  // These are overridden in this module's game_start() below
  int dayNight_timeSpeed = 40;
  int dayNight_yearStart = 0;
  int dayNight_dayStart = 0;

  // These are populated in this module's game_start() below
  String DayNight_SeasonName[DAYNIGHT_SEASONS_PER_YEAR];
  String DayNight_TimeOfDayName[DAYNIGHT_TIMESOFDAY_PER_DAY];
  int    DayNight_TimeOfDayDuration[DAYNIGHT_TIMESOFDAY_PER_DAY];

  DayNight_TimeOfDay dayNight_oldTimeOfDay = -1;
  DayNight_Season dayNight_oldSeason = -1;
  int dayNight_oldYear = -1;
  
  bool dayNight_timeOfDayChanged = false;
  bool dayNight_seasonChanged = false;
  bool dayNight_yearChanged = false;

//===================================================================
// External variables:
// Variables exported by this module, so they can be accessed in
// other scripts.
//-------------------------------------------------------------------

  export DayNight_SeasonName;          // String DayNight_SeasonName[DAYNIGHT_SEASONS_PER_YEAR];
  export DayNight_TimeOfDayName;       // String DayNight_TimeOfDayName[DAYNIGHT_TIMESOFDAY_PER_DAY];
  export DayNight_TimeOfDayDuration;   // int DayNight_TimeOfDayDuration[DAYNIGHT_TIMESOFDAY_PER_DAY];
  
//===================================================================
// API Implementation:
// The logic for this module's public API. Self-documenting...
//-------------------------------------------------------------------

  static bool DayNight::IsTimeRunning()
  { return dayNight_timeIsRunning; }

  static void DayNight::SetTimeRunning(bool run)
  { dayNight_timeIsRunning = run; }

  static int DayNight::GetTimeSpeed()
  { return dayNight_timeSpeed; }

  static void DayNight::SetTimeSpeed(int speed)
  { dayNight_timeSpeed = speed; }

  static bool DayNight::HasTimeOfDayChanged()
  {
    bool htodc = dayNight_timeOfDayChanged;
    dayNight_timeOfDayChanged = false;
    return htodc;
  }

  static bool DayNight::HasSeasonChanged()
  {
    bool hsc = dayNight_seasonChanged;
    dayNight_seasonChanged = false;
    return hsc;
  }

  static bool DayNight::HasYearChanged()
  {
    bool hyc = dayNight_yearChanged;
    dayNight_yearChanged = false;
    return hyc;
  }

  static int DayNight::GetDay()
  { return dayNight_dayCounter; }

  static int DayNight::GetTime()
  { return dayNight_minuteCounter; }

  static int DayNight::GetHour()
  { return dayNight_minuteCounter / DAYNIGHT_MINUTES_PER_HOUR; }

  static int DayNight::GetMinute()
  { return dayNight_minuteCounter % DAYNIGHT_MINUTES_PER_HOUR; }

  static int DayNight::GetYear()
  { return dayNight_dayCounter / (DAYNIGHT_DAYS_PER_SEASON * DAYNIGHT_SEASONS_PER_YEAR); }

  static int DayNight::GetConfigDayStart()
  { return dayNight_dayStart; }

  static void DayNight::SetConfigDayStart(int dayStartMinutes)
  { dayNight_dayStart = dayStartMinutes; }

  static int DayNight::GetConfigYearStart()
  { return dayNight_yearStart; }

  static void DayNight::SetConfigYearStart(int yearStartDays)
  { dayNight_yearStart = yearStartDays; }

  static DayNight_Season DayNight::GetSeason()
  {
    return ((dayNight_dayCounter + dayNight_yearStart) / DAYNIGHT_DAYS_PER_SEASON) % DAYNIGHT_SEASONS_PER_YEAR;
  }

  static DayNight_TimeOfDay DayNight::GetTimeOfDay()
  {
    int time = dayNight_minuteCounter + dayNight_dayStart;
    int i = 0;
    int todRunningTotal = 0;
    while(i<DAYNIGHT_TIMESOFDAY_PER_DAY)
    {
      todRunningTotal += DayNight_TimeOfDayDuration[i];
      if(time<todRunningTotal)
        return i;
      i++;
    }
    return 0;
  }

  static String DayNight::GetSeasonName(DayNight_Season season)
  {
    if(season == -1)
      season = DayNight.GetSeason();
    return DayNight_SeasonName[season];
  }

  static String DayNight::GetTimeOfDayName(DayNight_TimeOfDay timeOfDay)
  {
    if(timeOfDay == -1)
      timeOfDay = DayNight.GetTimeOfDay();
    return DayNight_TimeOfDayName[timeOfDay];
  }

  static int DayNight::GetSeasonPercent()
  {
    int dayOfSeason = (dayNight_dayCounter + dayNight_yearStart) % DAYNIGHT_DAYS_PER_SEASON;
    return (100*dayOfSeason) / DAYNIGHT_DAYS_PER_SEASON;
  }

  static int DayNight::GetTimeOfDayPercent()
  {
    // In order to provide greater accuracy, these calculations also include the "fractional minutes" provided by dayNight_frameCounter/dayNight_timeSpeed.
    // This means the Sun Stage Percentage can change every frame.
    DayNight_TimeOfDay tod = DayNight.GetTimeOfDay();
    int time = dayNight_minuteCounter+dayNight_dayStart;
    
    // Treat the first Time of Day period differently because it might be both at the beginning and end of the day (before/after midnight)
    if(tod == 0 && time<DayNight_TimeOfDayDuration[0])
    {
      return (time*100 + (dayNight_frameCounter*100)/dayNight_timeSpeed) / DayNight_TimeOfDayDuration[0];
    }
    else
    {
      int i=0;
      int todRunningTotal=0;
      while(i < ((tod+DAYNIGHT_TIMESOFDAY_PER_DAY-1) % DAYNIGHT_TIMESOFDAY_PER_DAY)+1) // This calculation gives the modX but with X instead of 0
      {
        todRunningTotal+=DayNight_TimeOfDayDuration[i];
        i++;
      }
      return ((time-todRunningTotal)*100 + (dayNight_frameCounter*100)/dayNight_timeSpeed) / DayNight_TimeOfDayDuration[tod];
    }
  }

  static void DayNight::SetTime(int day,  int hour,  int minute)
  {
    dayNight_dayCounter = day;
    dayNight_minuteCounter = minute + hour*DAYNIGHT_MINUTES_PER_HOUR;
    
    //Set the season and time-of-day changed flags
    DayNight_Season currentSeason = DayNight.GetSeason();
    if(currentSeason != dayNight_oldSeason)
    {
      dayNight_seasonChanged = true;
      dayNight_oldSeason = currentSeason;
    }

    DayNight_TimeOfDay currentTimeOfDay = DayNight.GetTimeOfDay();
    if(currentTimeOfDay != dayNight_oldTimeOfDay)
    {
      dayNight_timeOfDayChanged = true;
      dayNight_oldTimeOfDay = currentTimeOfDay;
    }
  }

//===================================================================
// Internal methods:
// Additional methods used by the module.
//-------------------------------------------------------------------

  // Populate our tables of names at startup (edit this function to configure module)
  function game_start()
  {
    dayNight_timeSpeed = GetGameSpeed();
    DayNight_SeasonName[0] = "Winter";
    DayNight_SeasonName[1] = "Spring";
    DayNight_SeasonName[2] = "Summer";
    DayNight_SeasonName[3] = "Fall";
    
    DayNight_TimeOfDayName[0] = "Night";
    DayNight_TimeOfDayName[1] = "Dawn";
    DayNight_TimeOfDayName[2] = "Day";
    DayNight_TimeOfDayName[3] = "Dusk";
    
    // Make sure this always adds up to the length of a full day
    DayNight_TimeOfDayDuration[0] = 600;  // 10 hrs
    DayNight_TimeOfDayDuration[1] = 60;   //  1 hr
    DayNight_TimeOfDayDuration[2] = 720;  // 12 hrs
    DayNight_TimeOfDayDuration[3] = 60;   //  1 hr
    
    dayNight_yearStart = DAYNIGHT_DAYS_PER_SEASON / 2;     // The year starts in the middle of winter (the first season)
    dayNight_dayStart = DayNight_TimeOfDayDuration[0] / 2; // The day starts in the middle of the night
  }

  // Simply keep updating the time
  function repeatedly_execute_always()
  {
    if(dayNight_timeIsRunning)
    {
      dayNight_frameCounter++;
      if(dayNight_frameCounter >= dayNight_timeSpeed)
      {
        dayNight_frameCounter = 0;
        dayNight_minuteCounter++;
        
        
        if(dayNight_minuteCounter >= DAYNIGHT_MINUTES_PER_HOUR*DAYNIGHT_HOURS_PER_DAY)
        {
          dayNight_minuteCounter = 0;
          dayNight_dayCounter++;
          
          // Keep a flag for season changing
          DayNight_Season currentSeason = DayNight.GetSeason();
          dayNight_seasonChanged = dayNight_seasonChanged || (currentSeason != dayNight_oldSeason);
          dayNight_oldSeason = currentSeason;

          // Keep a flag for year changing
          int currentYear = DayNight.GetYear();
          dayNight_yearChanged = dayNight_yearChanged || (currentYear != dayNight_oldYear);
          dayNight_oldYear = currentYear;
        }
        
        // Keep a flag for time of day changing
        DayNight_TimeOfDay currentTimeOfDay = DayNight.GetTimeOfDay();
        dayNight_timeOfDayChanged = dayNight_timeOfDayChanged || (currentTimeOfDay != dayNight_oldTimeOfDay);
        dayNight_oldTimeOfDay = currentTimeOfDay;
      }
    }
  }

//------------------------------------------------------------------- @  //===================================================================
// *** AGS MODULE HEADER ***
//
// Module: Day/Night Cycle
// Version: 1.2.0 (2014-02-01)
// Author: Gunnar Harboe (Snarky)
//
// Description:
// This module provides dynamic in-game timekeeping, so that in-game
// time passes along with actual time (by default, at a ratio of
// 1/60, so one second in real time corresponds to one minute in the
// game). It also provides methods to provide in a convenient format
// the time-of-day (for day/night cycle), day number, and season.
//
// Note that this module does not by itself make nights dark or
// winter snowy etc., although the included demo game provides an
// example of how it can be used to easily achieve such effects.
//
// Example use:
// E.g. in game_start(), to start the clock:
//   DayNight.SetTimeRunning(true);
//
// In repeatedly_execute_always(), given a GUI label lblWatch, this
// will display something like "Day 3 (Dawn, 06:30)":
//   lblWatch.Text = String.Format("Day %s (%s, %02d:%02d)",
//                                 DayNight.GetDay(),
//                                 DayNight.GetTimeOfDayName(),
//                                 DayNight.GetHour(),
//                                 DayNight.GetMinute());
//
// Copyright (C) Notice:
// This module is public domain and free for all use.
// If you do use it in a game, feel free to credit the author.
// No warranty implied, use at your own risk.
//-------------------------------------------------------------------

//===================================================================
// Dependencies:
// The following constant definitions allow the compiler to check for
// module  dependencies and to issue appropiate error messages when a
// required module is not installed. There should be a definition for
// the current version and all previous compatiable versions. 
//-------------------------------------------------------------------

  // Define this module's version info
	#define DayNight_VERSION 0102

	// Check for minimum AGS version
  // (However, the demo game is an AGS 3.3 project)
	#ifdef AGS_SUPPORTS_IFVER
	#ifnver 2.72
	#error Module DayNight requires AGS V2.72 or above
	#endif
	#endif

//===================================================================
// Constants:
// The following constants are used by this module. You may edit
// these values to change the length of hours, time-of-day periods,
// days, seasons and years.
//-------------------------------------------------------------------

  #define DAYNIGHT_MINUTES_PER_HOUR  60 //$AUTOCOMPLETEIGNORE$
  #define DAYNIGHT_HOURS_PER_DAY     24 //$AUTOCOMPLETEIGNORE$

  #define DAYNIGHT_TIMESOFDAY_PER_DAY 4 //$AUTOCOMPLETEIGNORE$
  
  // Note: This gives a year 90*4=360 days long
  #define DAYNIGHT_SEASONS_PER_YEAR   4 //$AUTOCOMPLETEIGNORE$
  #define DAYNIGHT_DAYS_PER_SEASON   90 //$AUTOCOMPLETEIGNORE$
  
//===================================================================
// Data Types:
// The following data types are defined by this module. 
//-------------------------------------------------------------------

  // The defined seasons
  // If you change this, make sure you also edit
  // DAYNIGHT_SEASONS_PER_YEAR above and the DayNight_SeasonName[]
  // values in DayNight.asc game_start().
  enum DayNight_Season
  {
    DayNight_Winter=0,
    DayNight_Spring,
    DayNight_Summer,
    DayNight_Fall,
  };

  // The defined time-of-day periods
  // They are not all of equal duration, see DayNight.asc game_start().
  // If you change this, make sure you also edit
  // DAYNIGHT_TIMESOFDAY_PER_DAY above and the DayNight_TimeOfDayName[]
  // and DayNightTimeOfDayDuration[] values in DayNight.asc game_start().
  enum DayNight_TimeOfDay
  {
    DayNight_Night=0,
    DayNight_Dawn,
    DayNight_Day,
    DayNight_Dusk,
  };

//===================================================================
// Main module API:
// The following publicly accessible methods and variables are
// defined by this module. 
//-------------------------------------------------------------------

  struct DayNight
  {
    /// Check whether the Day/Night Cycle is currently running
    import static bool IsTimeRunning();
    /// Start or stop the Day/Night Cycle
    import static void SetTimeRunning(bool run);

    /// Get the current Day/Night Cycle speed (game cycles/in-game minute, higher values are slower)
    import static int GetTimeSpeed();
    /// Set the Day/Night Cycle speed (game cycles/in-game minute, higher values are slower)
    import static void SetTimeSpeed(int speed);
    
    /// Get the current day (as a 0-based counter) - doesn't reset when the year changes
    import static int GetDay();
    /// Get the total number of minutes so far this day (as a 0-based counter)
    import static int GetTime();    // Total minute count this day
    /// Get the current hour of the day (as a 0-based counter)
    import static int GetHour();
    /// Get the current minute of the hour (as a 0-based counter)
    import static int GetMinute();
    /// Get the current year (as a 0-based counter)
    import static int GetYear();
    
    /// Get the number of minutes into the first time-of-day period a new day starts (i.e. when midnight is)
    import static int GetConfigDayStart();
    /// Set the number of minutes into the first time-of-day period a new day starts (i.e. when midnight is) Note! Make sure this is not more than the duration of the first time-of-day period. Should only be set during initial configuration.
    import static void SetConfigDayStart(int dayStartMinutes);
    
    /// Get the number of days into the first season a new year starts (i.e. how far into the first season Day 0 is)
    import static int GetConfigYearStart();
    /// Set the number of days into the first season a new year starts (i.e. how far into the first season Day 0 is). Note! Make sure this is not more than the number of days/season. Should only be set during initial configuration.
    import static void SetConfigYearStart(int yearStartDays);
    
    /// Set the game date and time (using 0-based counters)
    import static void SetTime(int day,  int hour,  int minute);
    
    /// Get the current season, as an enum value
    import static DayNight_Season GetSeason();
    /// Get the current time of day, as an enum value
    import static DayNight_TimeOfDay GetTimeOfDay();
    
    /// Get the name of a particular season. (If no argument provided, uses current)
    import static String GetSeasonName(DayNight_Season season=-1);
    /// Get the name of a particular time of day. (If no argument provided, uses current)
    import static String GetTimeOfDayName(DayNight_TimeOfDay timeOfDay=-1);

    /// Get how far this season has progressed, as a percentage. (Useful for gradual transitions, e.g. chance of snow.)
    import static int GetSeasonPercent();
    /// Get how far this time of day has progressed, as a percentage. (Useful for gradual transitions, e.g. lightening at dawn.)
    import static int GetTimeOfDayPercent();

    /// Whether the season has changed since last check. Useful for e.g. pop-up notifications.
    import static bool HasSeasonChanged();
    /// Whether the time of day has changed since last check. Useful for e.g. pop-up notifications.
    import static bool HasTimeOfDayChanged();
    /// Whether the year has changed since last check. Useful for e.g. pop-up notifications.
    import static bool HasYearChanged();
  };

  // Access the arrays of season and time-of-day names, and time-of-day
  // durations, directly, e.g. to easily display them in a list.
  import String DayNight_SeasonName[DAYNIGHT_SEASONS_PER_YEAR];
  import String DayNight_TimeOfDayName[DAYNIGHT_TIMESOFDAY_PER_DAY];
  import int DayNight_TimeOfDayDuration[DAYNIGHT_TIMESOFDAY_PER_DAY]; οv        ej��