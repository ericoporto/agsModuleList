AGSScriptModule    Gunnar Harboe (Snarky) Speech-based lip sync for all speech styles, supporting Pamela, Papagayo, Annosoft SAPI and Rhubarb formats Total Lip Sync 0.5 @S  //////////////////////////////////////////////////////////////////////////////////////////////////////////
// TOTAL LIP SYNC MODULE - Script
// by Gunnar Harboe (Snarky), v0.5
//////////////////////////////////////////////////////////////////////////////////////////////////////////

#define TLS_PHONEMES_LINE_MAX 50 // How long a lip-sync animation can be, in number of phonemes (=frames)
#define TLS_PHONEMES_MAP_MAX 100 // How many different phoneme-to-frame mappings we can define

String _dataDirectory;
String _fileExtension;
TotalLipSyncFileFormat _lipSyncFormat;
int _sierraDummyView = -1;
int _frameRate = 24;
String _currentPhoneme;
int _currentFrame = -1;
Character* _syncChar;         // The character we're lip-sync'ing

// A frame in a lip-sync'ed animation
struct _SyncFrame {
  int time;
  bool played;
  String phoneme;
};

// A mapping from a phoneme to an animation frame
struct _PhonemeFrameMap {
  String phoneme;
  int frame;
};

// The lip-sync data (phonemes and timing) for a line of speech, read from a lip-sync file
_SyncFrame _syncFrames[TLS_PHONEMES_LINE_MAX];
// The set of mappings from phonemes to animation frames
_PhonemeFrameMap _phonemeFrameMaps[TLS_PHONEMES_MAP_MAX];
// How many phoneme mappings are defined so far
int _phonemeFrameMapCount=0;
// Has the module been initialized?
bool _initialized=false;

// Splits a string into sections separated by the divider, and returns an array of the sections. (Last entry is a null)
String[] _Split(this String*, String divider)
{
  int arrayLength = 2;   // We always need at least two entries, to store original string and null
  // First, count how large an array we need
  String remainder = this;
  if(!String.IsNullOrEmpty(divider))
  {
    int splitIndex = remainder.IndexOf(divider);
    while(splitIndex >= 0)
    {
      arrayLength++;
      remainder = remainder.Substring(splitIndex + divider.Length, remainder.Length - splitIndex - divider.Length);
      splitIndex = remainder.IndexOf(divider);
    }
  }
  String list[] = new String[arrayLength];
  
  // Now put the segments into the array
  if(arrayLength > 2)
  {
    int i=0;
    remainder = this;
    int splitIndex = remainder.IndexOf(divider);
    while(splitIndex >= 0)
    {
      list[i] = remainder.Substring(0, splitIndex);
      remainder = remainder.Substring(splitIndex + divider.Length, remainder.Length - splitIndex - divider.Length);
      splitIndex = remainder.IndexOf(divider);
      i++;
    }
    list[i] = remainder;
  }
  else
  {
    list[0] = this;
  }
  list[arrayLength-1] = null;
  return list;
}

// Reset all the lip-sync data (for a new line of speech)
void _resetSyncFrames()
{
  int i = 0;
  while (i < TLS_PHONEMES_LINE_MAX)
  {
    _syncFrames[i].played = false;
    _syncFrames[i].time = -1;
    _syncFrames[i].phoneme = "";
    i++;
  }
}

// Map from phoneme to animation frame
int _getFrame(String phoneme)
{
  phoneme = phoneme.LowerCase();
  int i=0;
  while(i < _phonemeFrameMapCount)
  {
    if(phoneme == _phonemeFrameMaps[i].phoneme)
      return _phonemeFrameMaps[i].frame;
    i++;
  }
  // Return 0 if not found
  return 0;
}

// Add a mapping from a phoneme to an animation frame
static void TotalLipSync::AddPhonemeMapping(String phoneme, int frame)
{
  if(_phonemeFrameMapCount < TLS_PHONEMES_MAP_MAX)
  {
    _phonemeFrameMaps[_phonemeFrameMapCount].phoneme = phoneme.LowerCase();
    _phonemeFrameMaps[_phonemeFrameMapCount].frame = frame;
    _phonemeFrameMapCount++;
  }
  else
    AbortGame(String.Format("TotalLipSync.AddPhonemeMapping is limited to %d mappings. Overflow at '%s'.", TLS_PHONEMES_MAP_MAX, phoneme));
}

// Add mappings from multiple phonemes (separated by '/') to an animation frame
static void TotalLipSync::AddPhonemeMappings(String phonemes, int frame)
{
  String phones[] = phonemes._Split("/");
  int i=0;
  while(phones[i] != null)
  {
    TotalLipSync.AddPhonemeMapping(phones[i], frame);
    i++;
  }
}

// Delete all phoneme mappings
static void TotalLipSync::ClearPhonemeMappings()
{
  _phonemeFrameMapCount = 0;
}

// Define a default set of mappings for Pamela files (that distinguishes stressed and unstressed vowels)
void _autoMapPhonemesPamelaStressed()
{
  // Phoneme list from Pamela Help: http://users.monash.edu.au/~myless/catnap/pamela/
  TotalLipSync.AddPhonemeMapping("None",0);
  TotalLipSync.AddPhonemeMappings("M/B/P",1);
  TotalLipSync.AddPhonemeMappings("K/S/T/D/G/DH/TH/R/HH/CH/Y/N/NG/SH/Z/ZH/JH",2);
  TotalLipSync.AddPhonemeMappings("IH0/IH1/IH2/IY0/IY1/IY2/EH0/EH1/EH2/AH0/AH1/AH2/EY0/EY1/EY2/AW0/AW1/AW2/ER0/ER1/ER2",3);
  TotalLipSync.AddPhonemeMappings("AA0/AA1/AA2/AE0/AE1/AE2/AY0/AY1/AY2",4);
  TotalLipSync.AddPhonemeMappings("AO0/AA1/AA2/OW0/OW1/OW2",5);
  TotalLipSync.AddPhonemeMappings("UW0/UW1/UW2/OY0/OY1/OY2/UH0/UH1/UH2",6);
  TotalLipSync.AddPhonemeMapping("W",7);
  TotalLipSync.AddPhonemeMappings("F/V",8);
  TotalLipSync.AddPhonemeMappings("L",9);
  /*
  TotalLipSync.AddPhonemeMappings("None",0);
  TotalLipSync.AddPhonemeMappings("B/M/P",1);
  TotalLipSync.AddPhonemeMappings("S/Z/IH0/IH1/IH2/IY0/IY1/IY2/SH/T/TH/D/DH/JH/N/NG/ZH",2);
  TotalLipSync.AddPhonemeMappings("EH0/EH1/EH2/CH/ER0/ER1/ER2/EY0/EY1/EY2/G/K/R/Y/HH",3);
  TotalLipSync.AddPhonemeMappings("AY0/AY1/AY2/AA0/AA1/AA2/AH0/AH1/AH2/AE0/AE1/AE2",4);
  TotalLipSync.AddPhonemeMappings("AO0/AO1/AO2/AW0/AW1/AW2/UH0/UH1/UH2",5);
  TotalLipSync.AddPhonemeMappings("W/OW0/OW1/OW2/OY0/OY1/OY2/UW0/UW1/UW2",6);
  // Frame 7 unassigned to match Moho mapping
  TotalLipSync.AddPhonemeMappings("F/V",8);
  TotalLipSync.AddPhonemeMappings("L",9);
  */
}

// Define a default set of mappings for Pamela files (that does not distinguish stressed and unstressed vowels)
void _autoMapPhonemesPamelaIgnoreStress()
{
  // Phoneme list from Pamela Help: http://users.monash.edu.au/~myless/catnap/pamela/
  TotalLipSync.AddPhonemeMapping("None",0);
  TotalLipSync.AddPhonemeMappings("M/B/P",1);
  TotalLipSync.AddPhonemeMappings("K/S/T/D/G/DH/TH/R/HH/CH/Y/N/NG/SH/Z/ZH/JH",2);
  TotalLipSync.AddPhonemeMappings("IH/IY/EH/AH/EY/AW/ER",3);
  TotalLipSync.AddPhonemeMappings("AA/AE/AY",4);
  TotalLipSync.AddPhonemeMappings("AO/OW",5);
  TotalLipSync.AddPhonemeMappings("UW/OY/UH",6);
  TotalLipSync.AddPhonemeMapping("W",7);
  TotalLipSync.AddPhonemeMappings("F/V",8);
  TotalLipSync.AddPhonemeMappings("L",9);
  
  /*
  TotalLipSync.AddPhonemeMappings("None",0);
  TotalLipSync.AddPhonemeMappings("B/M/P",1);
  TotalLipSync.AddPhonemeMappings("S/Z/IH/IY/SH/T/TH/D/DH/JH/N/NG/ZH",2);
  TotalLipSync.AddPhonemeMappings("EH/CH/ER/EY/G/K/R/Y/HH",3);
  TotalLipSync.AddPhonemeMappings("AY/AA/AH/AE",4);
  TotalLipSync.AddPhonemeMappings("AO/AW/UH",5);
  TotalLipSync.AddPhonemeMappings("W/OW/OY/UW",6);
  // Frame 7 unassigned to match Moho mapping
  TotalLipSync.AddPhonemeMappings("F/V",8);
  TotalLipSync.AddPhonemeMappings("L",9);
  */
}


void _autoMapPhonemesMoho()
{
  // http://www.k-3d.org/wiki/PapagayoLipsyncReader
  TotalLipSync.AddPhonemeMapping("rest",0);
  TotalLipSync.AddPhonemeMapping("MBP",1);
  TotalLipSync.AddPhonemeMapping("etc",2);
  TotalLipSync.AddPhonemeMapping("E",3);
  TotalLipSync.AddPhonemeMapping("AI",4);
  TotalLipSync.AddPhonemeMapping("O",5);
  TotalLipSync.AddPhonemeMapping("U",6);
  TotalLipSync.AddPhonemeMapping("WQ",7);
  TotalLipSync.AddPhonemeMapping("FV",8);
  TotalLipSync.AddPhonemeMapping("L",9);
}

void _autoMapPhonemesAnno()
{
  // http://www.annosoft.com/sapi_lipsync/docs/group__anno40.html
  // http://www.adventuregamestudio.co.uk/forums/index.php?topic=34516.msg451624#msg451624
  TotalLipSync.AddPhonemeMapping("x",0);
  TotalLipSync.AddPhonemeMappings("m/b/p",1);
  TotalLipSync.AddPhonemeMappings("k/s/t/d/g/DH/TH/r/h/CH/y/n/NG/SH/z/ZH/j/JH",2);  // Sources differ on whether Anno uses j or JH 
  TotalLipSync.AddPhonemeMappings("IH/IY/EH/AH/EY/AW/ER",3);
  TotalLipSync.AddPhonemeMappings("AA/AE/AY",4);
  TotalLipSync.AddPhonemeMappings("AO/OW",5);
  TotalLipSync.AddPhonemeMappings("UW/OY/UH",6);
  TotalLipSync.AddPhonemeMapping("w",7);
  TotalLipSync.AddPhonemeMappings("f/v",8);
  TotalLipSync.AddPhonemeMappings("l",9);
}

// Define a default set of mappings for Rhubarb files
void _autoMapPhonemesRhubarb()
{
  // https://github.com/DanielSWolf/rhubarb-lip-sync#mouth-shapes
  TotalLipSync.AddPhonemeMapping("X",0);
  TotalLipSync.AddPhonemeMapping("A",1);  // mbp
  TotalLipSync.AddPhonemeMapping("B",2);  // other consonants
  TotalLipSync.AddPhonemeMapping("C",3);  // EH/AH/EY etc. (bed, hut, bait)
  TotalLipSync.AddPhonemeMapping("D",4);  // AA/AE/AY (father, bat, like)
  TotalLipSync.AddPhonemeMapping("E",5);  // AO/OW (thaw, slow)
  TotalLipSync.AddPhonemeMapping("F",6);  // UW/OY/UH/OW (you, toy, poor)
  // Frame 7 unassigned to match Moho mapping
  TotalLipSync.AddPhonemeMapping("G",8);  // F/V (fine, very)
  TotalLipSync.AddPhonemeMapping("H",9);  // L (letter)
}

static void TotalLipSync::AutoMapPhonemes()
{
  if(_initialized)
  {
    TotalLipSync.ClearPhonemeMappings();
    if(_lipSyncFormat == eLipSyncPamelaStressed)
      _autoMapPhonemesPamelaStressed();
    else if(_lipSyncFormat == eLipSyncPamelaIgnoreStress)
      _autoMapPhonemesPamelaIgnoreStress();
    else if(_lipSyncFormat == eLipSyncMoho)
      _autoMapPhonemesMoho();
    else if(_lipSyncFormat == eLipSyncAnno)
      _autoMapPhonemesAnno();
    else if(_lipSyncFormat == eLipSyncRhubarb)
      _autoMapPhonemesRhubarb();
  }
  else AbortGame("Calling TotalLipSync.AutoMapPhonemes() when TotalLipSync has not been initialized");
}

static void TotalLipSync::Init(TotalLipSyncFileFormat lipSyncFormat)
{
  _lipSyncFormat = lipSyncFormat;
  _dataDirectory = "$INSTALLDIR$/sync";
  
  if(lipSyncFormat == eLipSyncPamelaStressed || lipSyncFormat == eLipSyncPamelaIgnoreStress)
    _fileExtension = "pam";
  else if(lipSyncFormat == eLipSyncMoho)
    _fileExtension = "dat";
  else if(lipSyncFormat == eLipSyncAnno)
    _fileExtension = "anno";
  else if(lipSyncFormat == eLipSyncRhubarb)
    _fileExtension = "tsv";
    
  _initialized = true;
}

static void TotalLipSync::SetDataDirectory(String dataDirectory)
{
  // Strip trailing slashes
  while(dataDirectory.Length>0 && (dataDirectory.Chars[dataDirectory.Length-1]=='/')) // || dataDirectory.Chars[dataDirectory.Length-1] == '\\'))
    dataDirectory = dataDirectory.Truncate(dataDirectory.Length-1);
  _dataDirectory = dataDirectory;
}

static void TotalLipSync::SetFileExtension(String fileExtension)
{
  _fileExtension = fileExtension;
}

static void TotalLipSync::SetDataFileFrameRate(int frameRate)
{
  _frameRate = frameRate;
}

static void TotalLipSync::SetSierraDummyView(int viewNumber)
{
  _sierraDummyView = viewNumber;
}

static Character* TotalLipSync::GetCurrentLipSyncingCharacter()
{
  return _syncChar;
}

static String TotalLipSync::GetCurrentPhoneme()
{
  return _currentPhoneme;
}

static int TotalLipSync::GetCurrentFrame()
{
  return _currentFrame;
}

bool _parsePamela(String filepath)
{
  File* pamFile = File.Open(filepath, eFileRead);
  if (pamFile != null)
  {
    bool processing;
    int index = 0;
    while(!pamFile.EOF)
    {
      String line = pamFile.ReadRawLineBack();
      if (processing && !line.StartsWith("//"))
      {
        int colon = line.IndexOf(":");
        if (colon > 0)
        {
          String strtime = line.Substring(0, colon);
          _syncFrames[index].time = ((strtime.AsInt * 1000) / (15*_frameRate)); // Convert from Pamela XPOS to milliseconds
          _syncFrames[index].phoneme = line.Substring(colon + 1, line.Length - colon - 1);
          index ++;
          
          // If we're ignoring stress, discard stress information on vowels (a number at the end of the phoneme code)
          if(_lipSyncFormat == eLipSyncPamelaIgnoreStress)
          {
            String phone = _syncFrames[index].phoneme;
            if(phone.Length>1)
            {
              char x = phone.Chars[phone.Length-1];
              if(x >= '0' && x <= '9')
                _syncFrames[index].phoneme = phone.Truncate(phone.Length-1);
            }
          }
          //Display("%d;%s",SyncFrames[index].time, SyncFrames[index].phoneme);
        }
      }
      // We only process the [Speech] section
      if (line == "[Speech]")
        processing = true;
      else if(line.StartsWith("[",false))
        processing = false;
    }
    pamFile.Close();
    return true;
  }
  else
    return false;
}

bool _parseMoho(String filepath)
{
  File* datFile = File.Open(filepath, eFileRead);
  if(datFile != null)
  {
    bool processing=false;
    int i=0;
    while(!datFile.EOF)
    {
      String line = datFile.ReadRawLineBack();
      if(processing)
      {
        int space = line.IndexOf(" ");
        if(space > 0)
        {
          String strFrame = line.Substring(0, space);
          _syncFrames[i].time = (strFrame.AsInt * 1000) / _frameRate; // Convert from frame count to milliseconds
          _syncFrames[i].phoneme = line.Substring(space + 1, line.Length - space - 1);
          i++;
        }
      }
      
      if(line == "MohoSwitch1")
        processing=true;
    }
    datFile.Close();
    return true;
  }
  else
    return false;
}

bool _parseAnno(String filepath)
{
  File* annoFile = File.Open(filepath, eFileRead);
  if(annoFile != null)
  {
    bool processing = true;
    int i=0;
    while(!annoFile.EOF)
    {
      String line = annoFile.ReadRawLineBack();
      if(processing && line.IndexOf(" ") > 0)
      {
        String segment[] = line._Split(" ");
        if(segment[0] == "phn")
        {
          _syncFrames[i].time = segment[1].AsInt;
          _syncFrames[i].phoneme = segment[4];
          i++;
        }
      }
      if(line == "%%-begin-anno-text-%% ")
        processing = false;
      else if(line == "%%-end-anno-text-%%")
        processing = true;
    }
  }
  return false;
}

bool _parseRhubarb(String filepath)
{
  File* tsvFile = File.Open(filepath, eFileRead);
  if(tsvFile != null)
  {
    int i=0;
    while(!tsvFile.EOF)
    {
      String line = tsvFile.ReadRawLineBack();
      int tab = line.IndexOf("	"); // tab
      if(tab > 0)
      {
        String strSec = line.Substring(0, tab);
        _syncFrames[i].time = FloatToInt(strSec.AsFloat * 1000.0);
        _syncFrames[i].phoneme = line.Substring(tab + 1, line.Length - tab - 1);
        i++;
      }
    }
    tsvFile.Close();
    return true;
  }
  return false;
}

float _speechTimer = 0.0;     // _speechTimer counts in milliseconds
int _nextTime=-1;             // Time of the next frame, in milliseconds
int _nextFrame=-1;            // The next lip sync frame
bool _doLipSync=false;        // Whether we're actually doing lip sync (only true if message starts with speech clip prefix and there is a matching data file)
int _realSpeechView = -1;     // Used to backup the real speech view for non-LucasArts lip sync
//int _dummyFramebkup;          // Backup of the dummy frame sprite slot (reset in order to avoid crash)
DynamicSprite* _sierraFrame;  // Used to assign a flipped sprite to the "dummy" speech view we display for non-LucasArts lip sync

// Because we can't control the frame display during Sierra-style speech, we instead set the view to a single-frame loop, and overwrite its .Graphic sprite
void _setDummyFrame(int realView, int realLoop, int realFrame)
{
  ViewFrame* vfReal = Game.GetViewFrame(realView, realLoop, realFrame);
  ViewFrame* vfDummy = Game.GetViewFrame(_sierraDummyView, 0, 0);
  
  if(vfReal.Flipped)
  {
    if(_sierraFrame != null) _sierraFrame.Delete();
    _sierraFrame = DynamicSprite.CreateFromExistingSprite(vfReal.Graphic, true);
    _sierraFrame.Flip(eFlipLeftToRight);
    vfDummy.Graphic = _sierraFrame.Graphic;
  }
  else
    vfDummy.Graphic = vfReal.Graphic;
}

void _stopLipSync()
{
  // Make sure our dummy view isn't set to a dynamic sprite about to be deleted
  if(_sierraDummyView != -1)
  {
    ViewFrame* vfDummy = Game.GetViewFrame(_sierraDummyView, 0, 0);
    vfDummy.Graphic = 0;
  }
  if(_syncChar != null)
  {
    if(Speech.Style != eSpeechLucasarts && _realSpeechView != -1)
    {
      _syncChar.SpeechView = _realSpeechView;
      _realSpeechView = -1;
    }
    _syncChar.UnlockView();
    _syncChar = null;
  }
  if(_sierraFrame != null)
  {
    _sierraFrame.Delete();
    _sierraFrame = null;
  }
  _speechTimer = 0.0;
  _nextFrame = -1;
  _nextTime = -1;
  _doLipSync = false;
  _currentFrame = -1;
  _currentPhoneme = null;
}

void _sync(Character* c,  String message)
{
  // Make sure to stop any already running lip sync animations
  _stopLipSync();
  _resetSyncFrames();
  
  // We only sync if the line starts with a speech clip prefix (e.g. "&111 Blah blah blah.")
  if (message.StartsWith("&",false))
  {
    // Generate the filename for the matching lip sync data file:
    // -the first four letters of the character name (without the initial c)...
    String filename = String.Format("%s",c.scrname);
    filename = filename.Substring(1, 4);
    // -... followed by the speech clip number
    int firstspace = message.IndexOf(" ");
    filename = filename.Append(message.Substring(1, firstspace - 1));
    
    String filepath = String.Format("%s/%s.%s", _dataDirectory, filename, _fileExtension);
    
    if(_lipSyncFormat == eLipSyncPamelaStressed || _lipSyncFormat == eLipSyncPamelaIgnoreStress)
      _doLipSync = _parsePamela(filepath);
    else if(_lipSyncFormat == eLipSyncMoho)
      _doLipSync = _parseMoho(filepath);
    else if(_lipSyncFormat == eLipSyncAnno)
      _doLipSync = _parseAnno(filepath);
    else if(_lipSyncFormat == eLipSyncRhubarb)
      _doLipSync = _parseRhubarb(filepath);
    
  }
  
  _syncChar = c;
  
  if(Speech.Style != eSpeechLucasarts)
  {
    _realSpeechView = _syncChar.SpeechView;
    _syncChar.SpeechView = _sierraDummyView;
    _setDummyFrame(_realSpeechView, c.Loop, 0);
  }
  
}
void SaySync(this Character*,  String message)
{
  _sync(this, message);
  this.Say(message);
}

void SayAtSync(this Character*, int x, int y, int width, String message)
{
  _sync(this, message);
  this.SayAt(x, y, width, message);
}

int _getFrameNumber(int millis, bool next)
{
  // Because the frames aren't necessarily in order, we have to scan through all of them to see which one is current
  int i = 0;
  int closestTime = -1;
  int closestFrame = -1;
  while (i < TLS_PHONEMES_LINE_MAX)
  {
    if (  (next && (!_syncFrames[i].played && (closestTime < 0 || _syncFrames[i].time < closestTime) && _syncFrames[i].time > millis))    // Searches for next frame
        ||(!next && (!_syncFrames[i].played && (closestTime < 0 || _syncFrames[i].time > closestTime) && _syncFrames[i].time <= millis))) // Searches for current frame
    {
      closestTime = _syncFrames[i].time;
      closestFrame = i;
    }
    i++;
  }
  return closestFrame;
}

void _updateNextFrame(int millis)
{
  _nextFrame = _getFrameNumber(millis, true);
  if(_nextFrame == -1)
    _nextTime = -1;
  else
    _nextTime = _syncFrames[_nextFrame].time;
}

void _playFrame(int frame)
{
  // Look up the frame based on phoneme, unless argument is -1, in which case use frame 0
  if(frame == -1)
  {
    _currentPhoneme = "";
    _currentFrame = 0;
  }
  else
  {
    _currentPhoneme = _syncFrames[frame].phoneme;
    _currentFrame = _getFrame(_currentPhoneme);
  }
    
  if(Speech.Style == eSpeechLucasarts)
    _syncChar.LockViewFrame(_syncChar.SpeechView, _syncChar.Loop, _currentFrame);
  else
    _setDummyFrame(_realSpeechView, _syncChar.Loop, _currentFrame);
  if(frame != -1)
    _syncFrames[frame].played = true;
}

// Update the animation of lip-synced speaking characters
void _updateLipSync()
{
  if (_syncChar != null)
  {
    if(_syncChar.Speaking)
    {
      // Start animation. If the first phoneme defined in the animation isn't at the very beginning, use frame 0 for now
      if(_speechTimer == 0.0)
      {
        if(_doLipSync)
        {
          int frame = _getFrameNumber(0, false);
          _playFrame(frame);

          _updateNextFrame(0);
        }
        else
        {
          _playFrame(-1);
        }
      }
      
      if(_doLipSync)
      {
        // If it's time to play the next frame, do so (if there is one) and update the next frame to the one after that
        int millis = FloatToInt(_speechTimer, eRoundNearest);
        if(millis >= _nextTime && _nextFrame != -1)
        {
          _playFrame(_nextFrame);
          _updateNextFrame(millis);
        }
        _speechTimer += 1000.0 / IntToFloat(GetGameSpeed());
      }
    }
    else
    {
      _stopLipSync();
    }
  }
}

function game_start()
{
#ifdef TLS_DUMMY
  _sierraDummyView = TLS_DUMMY;
#endif
}

function repeatedly_execute_always()
{
  _updateLipSync();
} `  //////////////////////////////////////////////////////////////////////////////////////////////////////////
// TOTAL LIP SYNC MODULE - Header
// by Gunnar Harboe (Snarky), v0.5
//
// Description:
// This module enables speech-based lip sync animation for any speech mode (while the AGS built-in 
// speech-based lip sync does not currently work for LucasArts-style speech), and supports a number of
// different file formats for the lip sync data files.
//
// Use:
// You need to generate and edit the synchronization data in an external application (see below),
// or with the AGS Lip Sync Manager plugin. This module then reads the data files created and plays
// back the animation in sync with the audio.
//
// To lip sync a character, give them a speech view where each frame has the mouth position
// for a particular sound (a "phoneme"). Frame 0 should be the "no sound"/"mouth closed" frame.
// Then set up the module to define the mapping from phonemes to frames. This is done similarly to
// the built-in speech-based lip sync described in the manual.
//
// When using this module, the built-in AGS lip sync should be set to "disabled".
//
// Configure the module on startup - for example:
// 
//     function game_start()
//     {
//       TotalLipSync.Init(eLipSyncPamelaIgnoreStress);
//       TotalLipSync.AddPhonemeMappings("None",0);
//       TotalLipSync.AddPhonemeMappings("AY/AA/AH/AE",1);
//       TotalLipSync.AddPhonemeMappings("W/OW/OY/UW",2);
//       // etc.
//     }
// 
// A default mapping for each format is also provided, and can be activated with:
//
//     TotalLipSync.AutoMapPhonemes();
//
// To use lip sync, simply call the function Character.SaySync(String message) with a speech clip
// prefix - for example:
//
//     function cOceanSpiritDennis_Interact()
//     {
//       cOceanSpiritDennis.SaySync("&13 No touching, or it's FIGHTS!");
//     }
//
// This will play speech file number 13, and (given the configuration settings above) lip sync the
// speech animation according to the data in the file ocea13.pam in the game installation directory.
// There's also Character.SayAtSync(), which works like Character.SayAt().
//
//
//
// The file formats supported by this module are:
//
// Pamela (.pam):
// This format is produced by PAMELA and the AGS Lip Sync Manager plugin.
// http://www-personal.monash.edu.au/~myless/catnap/pamela/
// http://www.adventuregamestudio.co.uk/forums/index.php?topic=37792.0
//
// Moho Switch (.dat)
// This format is used by Papagayo; PAMELA and other applications can also export to it.
// http://www.lostmarble.com/papagayo/
// 
// Annosoft (.anno)
// This is the format used by SAPI 5.1 Lipsync.
// http://www.annosoft.com/sapi_lipsync/docs/index.html
//
// Rhubarb Lip-Sync (.tsv)
// This is one format used by Rhubarb Lip-Sync, a tool developed for lip-syncing 'Thimbleweed Park'.
// https://github.com/DanielSWolf/rhubarb-lip-sync
//
//
//
// This work is licensed under a Creative Commons Attribution 4.0 International License.
// https://creativecommons.org/licenses/by/4.0/
//
// It is based on code by Steven Poulton (Calin Leafshade):
// http://www.adventuregamestudio.co.uk/forums/index.php?topic=36284.msg554642#msg554642
//
// And on AGS engine code:
// https://github.com/adventuregamestudio/ags/
// ags/Editor/AGS.Editor/Components/SpeechComponent.cs 
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////

/// The format of lip sync data files to parse
enum TotalLipSyncFileFormat
{
  /// Lip sync data in Pamela format, distinguishing vowel stress (.pam files)
  eLipSyncPamelaStressed,
  /// Lip sync data in Pamela format, ignoring vowel stress (.pam files)
  eLipSyncPamelaIgnoreStress,
  /// Lip sync data in Moho Switch format (used by e.g. Papagayo; .dat files)
  eLipSyncMoho,
  /// Lip sync data in Anno format (used by SAPI 5.1 Lipsync; .anno files)
  eLipSyncAnno, 
  /// Lip sync data in Rhubarb format (.tsv files)
  eLipSyncRhubarb
};

struct TotalLipSync
{
  /// Initializes TotalLipSync. This method should be called on startup.
  import static void Init(TotalLipSyncFileFormat lipSyncFormat);
  /// Sets the directory to read the lip sync data files from. Default "$INSTALLDIR$/sync" (a sync/ folder inside 
  import static void SetDataDirectory(String dataDirectory);
  /// Sets the file extension of the data files. Default depends on the lipSyncFormat set with TotalLipSync.Init()
  import static void SetFileExtension(String fileExtension);
  /// Sets the frame rate of the lip sync data file. Used by Pamela and Moho formats. Default 24
  import static void SetDataFileFrameRate(int frameRate);
  /// Sets a dummy view that is used to enable Sierra lip sync. This view must have exactly 1 loop and 1 frame, and should not be used for anything else (since it will be overwritten by this module).
  import static void SetSierraDummyView(int viewNumber);
  /// Sets up a default mapping of phonemes to animation frames, according to the lipSyncFormat set with TotalLipSync.Init()
  import static void AutoMapPhonemes();
  /// Adds a mapping from a phoneme to an animation frame that will be displayed for this phoneme. Phonemes are case-insensitive.
  import static void AddPhonemeMapping(String phoneme, int frame);
  /// Adds mappings from a set of phonemes to an animation frame that will be displayed for those phonemes, separated by a slash '/'. Phonemes are case-insensitive.
  import static void AddPhonemeMappings(String phonemes, int frame);
  /// Clears all phoneme mappings.
  import static void ClearPhonemeMappings();
  /// Returns the character that is currently being lip synced, or null if none.
  import static Character* GetCurrentLipSyncingCharacter();
  /// Returns the phoneme code that is currently active (i.e. the phoneme being spoken at this time). If lip sync not currently running, null. If running but no phoneme set yet, "".
  import static String GetCurrentPhoneme();
  /// Returns the animation frame (i.e. the mouth shape) that is currently being displayed. -1 if no character is currently being lip synced.
  import static int GetCurrentFrame();
};

/// Says the specified text using the character's speech settings, while playing a speech-based lip-sync animation. The line must have a speech clip prefix ("&N " where N is the number of the speech file), and there must be a matching lip-sync data file in the data directory.
import void SaySync(this Character*,  String message);
/// Says the specified text at the specified position of the screen using the character's speech settings, while playing a speech-based lip-sync animation. The line must have a speech clip prefix ("&N " where N is the number of the speech file), and there must be a matching lip-sync data file in the data directory.
import void SayAtSync(this Character*, int x, int y, int width, String message); ��P+        ej��