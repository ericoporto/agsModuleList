AGSScriptModule    Daniel Eakins Allow characters to follow the player character from behind, walking exactly in the player character's footsteps and changing rooms with them Caterpillar 0.1 *  // Main script for module 'Caterpillar'

#define NMAX 4 // Maximum number of followers
#define LENGTH 100 // Maximum length of the caterpillar, in game cycles
#define MAXWALKINGDISTANCE 10000 // Maximum walking distance. If one of your rooms is bigger in width or height, just increase this.

int xpath[LENGTH], ypath[LENGTH]; // coordinates of the path walked by the player
int xspeed[LENGTH], yspeed[LENGTH]; // speed of the player at each point of this path
int i; // variable for placing the various followers on this path

Character* follower[NMAX]; // script names of the followers
int dxold[NMAX], dyold[NMAX], dx[NMAX], dy[NMAX]; // walking directions of the followers
bool originalsolid[NMAX]; // original solid values of the followers (restored when they are removed from the caterpillar)

bool Enabled = true; // by default, the module is enabled at game start

//****************************************************************************************************

static function Caterpillar::Disable() {
  int n;
  while (n < NMAX && Enabled) {
    if (follower[n]) {
      follower[n].StopMoving();
      follower[n].Solid = originalsolid[n];
    }
    n++;
  }
  Enabled = false;
}


static function Caterpillar::Enable() {
  int n;
  while (n < NMAX && !Enabled) {
    if (follower[n]) {
      follower[n].Solid = false;
      int j = i - (LENGTH/NMAX)*(n+1);
      if (j < 0) {j = LENGTH + j;}
      follower[n].Walk(xpath[j], ypath[j], eNoBlock, eAnywhere);
    }
    n++;
  }
  Enabled = true;
}


static function Caterpillar::Status() {
  return Enabled;
}


static function Caterpillar::Set(int spot, Character* name) {
  // If 'name' is already at 'spot' or is the player, do nothing
  int n;
  while (n < NMAX) {
    if (name == follower[n] || name == player) {return;}
    n++;
  }
  // If 'name' is null, remove current character from 'spot'
  if (name == null) {
    follower[spot].StopMoving();
    follower[spot].Solid = originalsolid[spot];
    follower[spot] = null;
  }
  // Else, add character to 'spot'
  else {
    follower[spot] = name;
    originalsolid[spot] = name.Solid;
    follower[spot].Solid = false;
    int j = i - (LENGTH/NMAX)*(spot+1);
    if (j < 0) {j = LENGTH + j;}
    if (follower[spot].Room != player.Room)
      {follower[spot].ChangeRoom(player.Room, xpath[j], ypath[j]);}
  }
}


static function Caterpillar::Get(int spot) {
  if (follower[spot]) {return follower[spot].ID;}
}

//****************************************************************************************************

function on_event (EventType event, int data) {
  if (event == eEventEnterRoomBeforeFadein || event == eEventLeaveRoom) {
    while (i < LENGTH) {
      xpath[i] = player.x;
      ypath[i] = player.y;
      xspeed[i] = player.WalkSpeedX;
      yspeed[i] = player.WalkSpeedY;
      i++;
    }
    i = 0;
    int n;
    while (n < NMAX) {
      if (follower[n]) {
        follower[n].Loop = player.Loop;
        follower[n].ChangeRoom(player.Room, player.x, player.y);
      }
      n++;
    }
  }
}

//****************************************************************************************************

function repeatedly_execute() {

  if (IsGamePaused() || !IsInterfaceEnabled()) {return;}

  // Get player's movement
  if (player.Moving) {
    xpath[i] = player.x;
    ypath[i] = player.y;
    xspeed[i] = player.WalkSpeedX;
    yspeed[i] = player.WalkSpeedY;
    i++;
    if (i >= LENGTH) {i = i - LENGTH;}
  }

  // Set each follower's movement
  int n;
  while (n < NMAX && Enabled) {
    i = i - LENGTH/NMAX;
    if (i < 0) {i = LENGTH + i;}
    if (follower[n]) {

      // Get directions
      dxold[n] = dx[n];
      dyold[n] = dy[n];
      dx[n] = 0;
      dy[n] = 0;

      if (player.WalkSpeedX > 0) {
        if (follower[n].x < xpath[i] - player.WalkSpeedX) {dx[n] =  MAXWALKINGDISTANCE;}
        if (follower[n].x > xpath[i] + player.WalkSpeedX) {dx[n] = -MAXWALKINGDISTANCE;}
      }
      else {
        if (follower[n].x < xpath[i]) {dx[n] =  MAXWALKINGDISTANCE;}
        if (follower[n].x > xpath[i]) {dx[n] = -MAXWALKINGDISTANCE;}
      }

      if (player.WalkSpeedY > 0) {
        if (follower[n].y < ypath[i] - player.WalkSpeedY) {dy[n] =  MAXWALKINGDISTANCE;}
        if (follower[n].y > ypath[i] + player.WalkSpeedY) {dy[n] = -MAXWALKINGDISTANCE;}
      }
      else {
        if (follower[n].y < ypath[i]) {dy[n] =  MAXWALKINGDISTANCE;}
        if (follower[n].y > ypath[i]) {dy[n] = -MAXWALKINGDISTANCE;}
      }

      // Move
      if (dx[n] != dxold[n] || dy[n] != dyold[n])
        {follower[n].Walk(follower[n].x + dx[n], follower[n].y + dy[n], eNoBlock, eAnywhere);}

      // Change speed if player's speed has changed
      if (follower[n].WalkSpeedX != xspeed[i] || follower[n].WalkSpeedX != yspeed[i]) {
        follower[n].StopMoving();
        follower[n].SetWalkSpeed(xspeed[i], yspeed[i]);
        follower[n].Walk(follower[n].x + dx[n], follower[n].y + dy[n], eNoBlock, eAnywhere);
      }
    }
    n++;
  }

}
 �  /* Script header for module 'Caterpillar'

Description:

	This module allows you to have characters follow the player character from
  behind, walking exactly in the player character's footsteps and changing
  rooms with them, forming a 'caterpillar' system.

  It was primarily designed for RPGs using keyboard controls (in particular,
  the KeyboardMovement module by Rui "Brisby" Pires & strazer). It currently
  does not work well with mouse controls.

Functions:

  Disable();
    Disables caterpillar movement.

  Enable();
    Enables caterpillar movement. By default, the module is automatically
    enabled at game start.

  Status();
    Returns whether caterpillar movement is currently enabled.

	Set(int spot, Character* name);
		Adds a character to the specified spot in the caterpillar (spot 0 is the
    first character that follows the player's character, spot 1 is the second,
    etc.). Note that adding a character makes them become non-solid.

    To remove a character from a spot, just set name to null. The character's
    original solid property will be restored.

  Get(int spot);
    Returns the ID number of the character in the specified spot.

Version history:

  v0.1 (November 2011)  First release by Daniel Eakins

License:

	This module is released into the public domain.

*****************************************************************************************************/

struct Caterpillar {
  import static function Disable();
  import static function Enable();
  import static function Status();
  import static function Set(int spot, Character* name);
  import static function Get(int spot);
};
 ���        ej��