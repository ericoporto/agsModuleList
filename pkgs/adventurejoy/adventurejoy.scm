AGSScriptModule          // new module script
bool isOn;
int oldbuttons = 0;
bool joy_moved;
int old_x_pos;
int old_y_pos;
int accellx;
int accelly;
int tryoncepertimes;
bool selectJoy;
int old_pov;
struct inventoryDimensions {
  int x;
  int y;
  int w;
  int h;
  int columns;
  int rows;
  int current;
};
inventoryDimensions inv;
Joystick *joy;

Joystick * OpenDefaultJoystick()
{
  Joystick *j;
  
  JoystickRescan();
  int count = JoystickCount();
  
  int i = 0;
  while (i < count)
  {
    j = Joystick.Open(i);
    
    if ((j != null) && j.Valid() && !j.Unplugged())
      return (j);
    
    i++;
  }
  
  return (null);
}

function triesToReconnect(){
  if(joy==null){
    joy = OpenDefaultJoystick();
    if( joy != null){
      isOn=true;
    }
  }
}



bool turnJoyOn(){
  joy = OpenDefaultJoystick();
  selectJoy = true;
  if( joy == null){
    isOn = false;
    return false;
  }
  
  return true;
}

bool turnJoyOff(){
  selectJoy = false;
  if (joy != null) {
    joy.Close();
    return true;
  }
  
  return false;
}



static bool adventureJoy::isOn(){
  return isOn;
}

static void adventureJoy::on(){
  if(!adventureJoy.isOn()){
    isOn = true;
    if(!turnJoyOn()){
      isOn = false; 
    }
  }
}

static void adventureJoy::off(){
  if(adventureJoy.isOn()){
    isOn = false;
    turnJoyOff();
  }
}

static void adventureJoy::beforeSave(){
  adventureJoy.off();
}

static void adventureJoy::afterSaveLoad(){
  adventureJoy.on();
}

static void adventureJoy::setInventoryWindow(InvWindow  * invwin){
  inv.x = invwin.X;
  inv.y = invwin.Y;
  inv.h = invwin.Height;
  inv.w = invwin.Width;
  inv.columns = invwin.ItemsPerRow;
  inv.rows = invwin.RowCount;
}

static void adventureJoy::setInventoryArea(int x, int y, int width, int height, int columns, int rows){
  inv.x = x;
  inv.y = y;
  inv.h = height;
  inv.w = width;
  inv.columns = columns;
  inv.rows = rows;
}



int clampHeight(int y){
  if(y < 0){
    y =0;  
  }
  if(y > System.ViewportHeight-1){
    y = System.ViewportHeight-1; 
  }
  return y;
}

int clampWidth(int x){
  if(x < 0){
    x =0;  
  }
  if(x > System.ViewportWidth-1){
    x = System.ViewportWidth-1; 
  }  
  return x;
}

void next_item(){
  inv.current++;
  if(inv.current >= inv.columns * inv.rows){
    inv.current =0;  
  }
  
  int xpos = inv.x +(inv.w/inv.columns)/2+ (inv.w/inv.columns)*(inv.current/inv.rows);  
  int ypos = inv.y +(inv.h/inv.rows)/2+ (inv.h/inv.rows)*(inv.current%inv.rows);  
  
  old_x_pos = mouse.x;
  old_y_pos = mouse.y;
  
  Mouse.SetPosition(xpos, ypos);
}

void back_item(){
  inv.current--;
  if(inv.current < 0){
    inv.current = inv.columns * inv.rows-1;  
  }
  
  int xpos = inv.x +(inv.w/inv.columns)/2+ (inv.w/inv.columns)*(inv.current/inv.rows);  
  int ypos = inv.y +(inv.h/inv.rows)/2+ (inv.h/inv.rows)*(inv.current%inv.rows);  
  
  old_x_pos = mouse.x;
  old_y_pos = mouse.y;
  
  Mouse.SetPosition(xpos, ypos);
}


//pressed a hat
void pressedPov(int pov){
  if(pov == ePOVCenter){
    return;  
  } else if(pov == ePOVDown){
    next_item();
    return;  
  } else if(pov == ePOVLeft){
    back_item();
    return;  
  } else if(pov == ePOVRight){
    next_item();
    return;  
  } else if(pov == ePOVUp){
    back_item();
    return;  
  } else if(pov == ePOVDownLeft){
    back_item();
    return;  
  } else if(pov == ePOVDownRight){
    next_item();
    return;  
  } else if(pov == ePOVUpLeft){
    back_item();
    return;  
  } else if(pov == ePOVUpRight){
    next_item();
    return;  
  }
}

function on_joy_unpress(Joystick *j, int button) {
  //
}

function on_joy_press(Joystick *j, int button) {
  //
  if(button==2 || button==0){
    Mouse.Click(eMouseLeft);
  } else if(button==1 || button==3){
    Mouse.Click(eMouseRight);
  } else if(button==4){
    back_item();
  } else if(button==5){
    next_item();
  }
}

function repeatedly_execute_always(){
  if(!selectJoy){
    return;  
  }
  
  if(joy!=null){
    if(joy.Unplugged() || !joy.Valid()){
      joy.Close();
      joy = null;
      isOn = false;
      Display("joystick unplugged");
      return;
    }
  }

  if(joy== null){
    tryoncepertimes++;
    if(tryoncepertimes>GetGameSpeed()){
      tryoncepertimes=0;
      triesToReconnect();
    }
    return;  
  }  
  
  joy_moved = false;
  int joy_new_x= joy.x / (JOY_RANGE /64);
  int joy_new_y= joy.y / (JOY_RANGE /64);  
  
  if(joy_new_x > 15 || joy_new_x < -15) {
    joy_moved = true;
    accellx++;
    if(accellx>8){
      accellx=8;
    }
  } else {
    accellx--;  
    accellx--;  
    if(accellx<0){
      accellx=0;  
    }  
  }
  
  if(joy_new_y > 15 || joy_new_y < -15) {
    joy_moved = true;
    accelly++;
    if(accelly>8){
      accelly=8;
    }
  } else {
    accelly--;  
    accelly--;  
    if(accelly<0){
      accelly=0;  
    }  
  }
  
  if(joy_moved){
    int dividerx = 4*( 9 -accellx);
    int dividery = 4*(9 -accelly);
    
    int joy_move_x=   joy_new_x/dividerx;
    int joy_move_y= joy_new_y/dividery;
    int x_pos = mouse.x;
    int y_pos = mouse.y;
    x_pos += joy_move_x;
    y_pos += joy_move_y;
    
    x_pos = clampWidth(x_pos);
    y_pos = clampHeight(y_pos);

    mouse.SetPosition(x_pos, y_pos);  
    
  } 
  
 // TestLabel.Text = String.Format("joy_moved = %d [ joy_move_x = %d [ joy_move_y = %d [ counter = %d [ joyUnpugged = %d , joyValid = %d [ joyPOV = %d ",joy_moved, joy_new_x, joy_new_y,  counter, joy.Unplugged(), joy.Valid(),  joy.POV);
  
  if(joy.buttons != oldbuttons) {
    int unpressed = (oldbuttons ^ joy.buttons) & oldbuttons;
    int pressed = (oldbuttons ^ joy.buttons) & joy.buttons;
    
    int i = 0;
    while (i < 32) {
      if (unpressed & 1) {
        on_joy_unpress(joy, i);
      }
      if (pressed & 1) {
        on_joy_press(joy, i);
      }
      
      unpressed = unpressed >> 1;
      pressed = pressed>>1;
      i++;
    }
    
    oldbuttons = joy.buttons;
  }
 
  if(joy.POV != old_pov){
    old_pov=joy.POV;
    pressedPov(joy.POV);
  }
  

}

//----------------------------------------------------------------------------------------------------
// game_start
//----------------------------------------------------------------------------------------------------
function game_start() 
{
  inv.x = 0;
  inv.y = 0;
  inv.w = System.ViewportWidth;
  inv.h = 26;
  inv.columns = 10;
  inv.rows = 1;
  adventureJoy.on();
}
 t  // new module header
struct adventureJoy
{
  import static void setInventoryArea(int x, int y, int width, int height, int columns, int rows);
  import static void setInventoryWindow(InvWindow * invwin);
  import static void on();
  import static void off();
  import static void beforeSave();
  import static void afterSaveLoad();
  import static bool isOn();
}; ��^d        ej��