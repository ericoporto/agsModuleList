AGSScriptModule    eri0o, Dualnames Move your character with keyboard or joystick. controlz 0.1.0 ^  // controlz module script

  //  MIT License
  //
  //  Copyright (c) 2019 Dualnames, �rico Vieira Porto
  //
  //  Permission is hereby granted, free of charge, to any person obtaining a copy
  //  of this software and associated documentation files (the "Software"), to deal
  //  in the Software without restriction, including without limitation the rights
  //  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  //  copies of the Software, and to permit persons to whom the Software is
  //  furnished to do so, subject to the following conditions:
  //
  //  The above copyright notice and this permission notice shall be included in all
  //  copies or substantial portions of the Software.
  //
  //  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  //  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  //  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  //  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  //  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  //  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  //  SOFTWARE.

int frame;

int charaFrame[];
int cycleWaits[];
int countStopped[];
bool ismoving[];

// fix for ags 3.4.3.1
#ifndef SCRIPT_API_v3507
int GetWalkableAreaAtRoom(int room_x, int room_y){
  int screen_x = room_x-GetViewportX();
  int screen_y = room_y-GetViewportY();
  return GetWalkableAreaAt(screen_x, screen_y);  
}
#endif

void game_start(){
  charaFrame = new int[Game.CharacterCount];
  countStopped = new int[Game.CharacterCount];
  cycleWaits = new int[Game.CharacterCount];  
  ismoving = new bool[Game.CharacterCount];  
  
  // Characters are normally created with DiagonalLoops set to true
  // But they only have 4 views. So we set it to false when appropriate.
  int i=0;  
  while(i<Game.CharacterCount){  
    if(character[i].NormalView > 0){
      if(Game.GetLoopCountForView(character[i].NormalView) < 5){
        character[i].DiagonalLoops = false;  
      }
    }
    i++;
  }
}

void repeatedly_execute_always(){
  if(IsGamePaused()==1){
    return;  
  }
  frame++;
}

MovingState Controlz(Character* c, bool down,  bool left,  bool right,  bool up){
  if(c==null){
    return eControlzJustInvalid;  
  }
  
  if(c.View!=c.NormalView){
    return eControlzJustInvalid;  
  }
  
  if(c.MovementLinkedToAnimation && (frame % c.AnimationSpeed != 0)){
    return ismoving[c.ID];  
  }

  if(!(down || left || right || up)){
    if(countStopped[c.ID]<1){
      ismoving[c.ID] = false;
      countStopped[c.ID]++;
    } else {
      if(countStopped[c.ID]<2){
        countStopped[c.ID]++;
        ismoving[c.ID] = false;
        c.UnlockView();
        return eControlzJustStopped;
      }
    }
  } else {
    countStopped[c.ID] = 0;  
  }

  int setX, setY;
  setX=c.x;
  setY=c.y;

  int walkSpeedY = c.WalkSpeedY;

  if(c.MovementLinkedToAnimation){
    if (left) setX -=c.WalkSpeedX;
    if (right)setX +=c.WalkSpeedX;
    if (left||right && walkSpeedY>1) walkSpeedY=walkSpeedY/2;
    if (up) setY -=walkSpeedY;
    if (down) setY+=walkSpeedY;
  } else {
    if (left) setX -= 2*c.WalkSpeedX-1;
    if (right)setX += 2*c.WalkSpeedX-1;
    if (left||right){  
      if (up) setY -= walkSpeedY;
      if (down) setY+= walkSpeedY;
    } else {
      if (up) setY -= walkSpeedY*2;
      if (down) setY+= walkSpeedY*2;
    }
  }

  if (!(down || left || right || up)) {
    if (charaFrame[c.ID]!=1) {
      charaFrame[c.ID]=1;
      c.LockViewFrame(c.NormalView, c.Loop, charaFrame[c.ID]);
    }
  } else {
    int loops=-1;
    if (left) {
      if(c.DiagonalLoops){
        if (up)loops=7;
        else if (down) loops=6;
        else loops=1; 
      } else {
        loops=1;
      }
    } else if (right) {
      if(c.DiagonalLoops){
        if (up)loops=5;
        else if (down) loops=4;
        else loops=2;
      } else {
        loops=2;
      }
    } else if (up) {
      loops=3;
    } else if (down) {
      loops=0;
    }

    if (GetWalkableAreaAtRoom(c.x, c.y)==0 || c.Moving ) {
      loops=-1;
    }

    if (loops!=-1) {
      int pdx=c.x;
      int pdy=c.y;  

      bool moving = false;
      if (GetWalkableAreaAtRoom(setX, setY)==0) {
        if (GetWalkableAreaAtRoom(setX, c.y)==0) {
          if (GetWalkableAreaAtRoom(c.x, setY)!=0) {
            c.y=setY;
          }
        } else {
          c.x=setX;
        }
      } else {
        c.x=setX;
        c.y=setY;
      }

      if (c.x!=pdx || c.y!=pdy)moving=true;

      if (moving) {
        c.Loop=loops;
        if(c.MovementLinkedToAnimation){
          charaFrame[c.ID]++;
          if (charaFrame[c.ID]>=Game.GetFrameCountForLoop(c.NormalView, loops)-1)
            charaFrame[c.ID]=1;
          c.LockViewFrame(c.NormalView, loops, charaFrame[c.ID]); 
          ismoving[c.ID] = true;
        } else {
          cycleWaits[c.ID]++;
          if (cycleWaits[c.ID]>c.AnimationSpeed) {
            charaFrame[c.ID]++;
            if (charaFrame[c.ID]>=Game.GetFrameCountForLoop(c.NormalView, loops)-1) charaFrame[c.ID]=1;
            c.LockViewFrame(c.NormalView, loops, charaFrame[c.ID]);            
            cycleWaits[c.ID]=0;
          }
        }
        
      } else {
        if (c.View==c.NormalView && charaFrame[c.ID]!=1) {
          charaFrame[c.ID]=1;
          c.LockViewFrame(c.NormalView, c.Loop, charaFrame[c.ID]);
        }
      }
    }
  }
  return ismoving[c.ID];
}

 �	  // controlz module header
// # controlz
// Move your character with keyboard or joystick controlz for Adventure Game Studio.
// 
// ## usage
// 
// ```AGS Script
// // called on every game cycle, except when the game is blocked
// function repeatedly_execute() 
// {
//   Controlz(player, 
//     IsKeyPressed(eKeyDownArrow),  IsKeyPressed(eKeyLeftArrow), 
//     IsKeyPressed(eKeyRightArrow),  IsKeyPressed(eKeyUpArrow));
// 
//   Controlz(cEgo2, 
//     IsKeyPressed(eKeyS),  IsKeyPressed(eKeyA), 
//     IsKeyPressed(eKeyD),  IsKeyPressed(eKeyW));
// }
// ```
// 
// ## script API
// 
// Controlz only has a single function
// 
// `Controlz(Character* c, bool down,  bool left,  bool right,  bool up)`
// 
// Call it on your repeatedly execute or repeatedly execute always, 
// passing a character and which keys are pressed at that time.
// 
// ## Author and License
// 
// This code was originally made by Dualnames for Strangeland and I eri0o got my hands on
// it and wrapped in this function to be easier to repurpose.
//  MIT License
//
//  Copyright (c) 2019 Dualnames, �rico Vieira Porto
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

enum MovingState {
  eControlzJustInvalid=-1, 
  eControlzStopped=0, 
  eControlzMoving=1, 
  eControlzJustStopped=2, 
};

/// Pass a character and four directional booleans, like IsKeyPressed(eKeyDownArrow) .
import MovingState Controlz(Character* c, bool down,  bool left,  bool right,  bool up); rɛ!        ej��