AGSScriptModule        �  Overlay *backgroundSpeech[]; // pointer to any character's background speech overlay
 
function game_start()
{
  backgroundSpeech = new Overlay[Game.CharacterCount]; // initialize array of pointers
}
 
function repeatedly_execute()
{
  int i = 0;
  while (i < Game.CharacterCount) // iterate all pointers checking for ended background speech
  {
    if ((backgroundSpeech[i] != null) && (!backgroundSpeech[i].Valid))
    {
      character[i].UnlockView(); // unlock character from speech view when done talking
      backgroundSpeech[i] = null;
    }
    i++;
  }
}
 
Overlay* SayInBackground(this Character*, String text)
{
  Overlay *o = this.SayBackground(text);
  if ((o != null) && (this.SpeechView > 0))
  {
    backgroundSpeech[this.ID] = o;
    this.LockView(this.SpeechView);
    this.Animate(this.Loop, this.AnimationSpeed, eRepeat, eNoBlock, eForwards);
  }
} d   // Background Speech by Snarky 
import Overlay* SayInBackground(this Character*, String text);
 
  c        ej��