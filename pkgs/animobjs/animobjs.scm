AGSScriptModule        �+  // new module script
int animObjs_XScrn( Object *obj, float percentX ){
  float XoffRightScreen = IntToFloat( Room.Width);
  float XoffLeftScreen = IntToFloat( -Game.SpriteWidth[obj.Graphic] );
  return FloatToInt((XoffRightScreen*(percentX)) + 
      (XoffLeftScreen*(1.0 - percentX))); }
int animObjs_YScrn( Object *obj, float percentY ){
  float YoffTopScreen = IntToFloat( Room.Height + Game.SpriteHeight[obj.Graphic] );
  float YoffBottomScreen = 0.0;
  return FloatToInt(YoffTopScreen*(percentY)); }    

/*
bool MoveFromAtoBifAtA( Object *obj, 
  int Ax,  int Ay, int Bx, int By, int speed){
      //SPEED TAKES NEGETIVE NUMBERS FOR SLOW MOVEMENT!!!
      if(obj.Moving == false){
        
        if(obj.X == Ax && obj.Y == Ay){ 
          obj.Move( Bx, By, speed, eNoBlock, eAnywhere); 
        return true; }  }
    return false;
}
*/
bool ifAt_Or_MoveTooIfTrue( Object *obj, int x,  int y,  int speed,  bool runMovementIfTrue){
      //SPEED TAKES NEGETIVE NUMBERS FOR SLOW MOVEMENT!!!
      if(obj.Moving == false){
        if(obj.X == x && obj.Y == y){ return true;
      }else{ if(runMovementIfTrue){ obj.Move( x, y, speed, eNoBlock, eAnywhere); }} }
      return false;
} 
bool ifAt_Or_PauseNHideIfTrue(  
      Object *obj, int xGet,  int yGet,  float speed,  bool runMovementIfTrue,  bool hide, bool useObjY){
  int speedToTimeModifier; float s = speed; 
  if(s == 0.5){ speedToTimeModifier = -20;} if(s == 1.0){ speedToTimeModifier = -40;} 
  if(s == 2.0){ speedToTimeModifier = -80;} if(s == 4.0){ speedToTimeModifier = -160;} 
  if(s == 8.0){ speedToTimeModifier = -320;} 
  int x = xGet; int y = yGet; if(hide){ x = -8000 + x; y = -8000 + y;}
  
  if(obj.Moving == false){  //Display("%i", FloatToInt( speedToTimeModifier));
      if( obj.X  == x && (obj.Y  == y + 3 || useObjY)){
      obj.X = xGet; obj.Y = yGet; if(useObjY){obj.Y = obj.Y -3;}
      return true;
    }else{  if(runMovementIfTrue == true){ 
              obj.X = x; obj.Y = y;}} }
  
  //Display("%i", runMovementIfTrue);
  return ifAt_Or_MoveTooIfTrue( obj, x, y + 3, speedToTimeModifier, runMovementIfTrue);
}

///////////////////////////////////////
////////////////////////////////
////////////////////
///////////////////
////////////////////////
/////////////////////////
/*
function MoveFromAtoBWarpBack( Object *obj, 
  int Ax,  int Ay, int Bx, int By, int speed, bool flipFlop ){
      //SPEED TAKES NEGETIVE NUMBERS FOR SLOW MOVEMENT!!!
      
      int INSTANT_MOVE_SPEED = 10000;
      
      MoveFromAtoBifAtA(obj, Ax, Ay, Bx, By, speed);
      //these run at start/end
      if(flipFlop){ MoveFromAtoBifAtA(obj, obj.X, obj.Y, Ax, Ay, speed);
      }else{ MoveFromAtoBifAtA(obj, obj.X, obj.Y, Ax, Ay, INSTANT_MOVE_SPEED); }
 }
 */
 int[] animObjs_Objs(
          int obj1ID,  int obj2ID, int obj3ID, 
          int obj4ID, int obj5ID, int obj6ID, 
          int obj7ID, int obj8ID, int obj9ID){
    int rtrnList[]; rtrnList = new int[ANIM_OBJS_LENGTH]; int i = 0;
    rtrnList[i] = obj1ID; i+=1; rtrnList[i] = obj2ID; i+=1; rtrnList[i] = obj3ID; i+=1;
    rtrnList[i] = obj4ID; i+=1;  rtrnList[i] = obj5ID; i+=1;  rtrnList[i] = obj6ID; i+=1; 
    rtrnList[i] = obj7ID; i+=1;  rtrnList[i] = obj8ID; i+=1;  rtrnList[i] = obj9ID; i+=1; 
    return rtrnList;}
int[] animObjs_SXYs(
          int speedOR_NOANIM1, int x1, int y1,   
          int speedOR_NOANIM2, int x2, int y2,
          int speedOR_NOANIM3, int x3, int y3, 
          int speedOR_NOANIM4, int x4, int y4){
      int rtrnList[]; rtrnList = new int[ANIM_SPD_X_Y_LENGTH]; int i = 0;
      rtrnList[i] = speedOR_NOANIM1; i+=1; rtrnList[i] = x1; i+=1; rtrnList[i] = y1; i+=1;
      rtrnList[i] = speedOR_NOANIM2; i+=1; rtrnList[i] = x2; i+=1; rtrnList[i] = y2; i+=1;
      rtrnList[i] = speedOR_NOANIM3; i+=1; rtrnList[i] = x3; i+=1; rtrnList[i] = y3; i+=1;
      rtrnList[i] = speedOR_NOANIM4; i+=1; rtrnList[i] = x4; i+=1; rtrnList[i] = y4; i+=1;
      return rtrnList;}
 int[] animObjs_JoinLists( int speedOR_NOANIM1_x_y_ListA[], 
                          int speedOR_NOANIM1_x_y_ListB[], 
                          int speedOR_NOANIM1_x_y_ListC[]){
   int rtrnList[]; rtrnList = new int[ANIM_SPD_X_Y_LENGTH*3];
   int i2 = 0; 
   int i = 0; while(i < ANIM_SPD_X_Y_LENGTH){
     rtrnList[i2] = speedOR_NOANIM1_x_y_ListA[i2];
     i2 +=1; i +=1;}
   i = 0; while(i < ANIM_SPD_X_Y_LENGTH){
     rtrnList[i2] = speedOR_NOANIM1_x_y_ListB[i];
     i2 +=1; i +=1;}
   i = 0; while(i < ANIM_SPD_X_Y_LENGTH){
     rtrnList[i2] = speedOR_NOANIM1_x_y_ListC[i];
     i2 +=1; i +=1;}
   
   return rtrnList;
 }
 
 
function animObjs_core(   bool relativeUsing_BlockingBorders,      
                          int getObjList[], 
                          int speedOR_NOANIM1_x_y_ListA[], 
                          int speedOR_NOANIM1_x_y_ListB[], 
                          int speedOR_NOANIM1_x_y_ListC[]){ 
    bool runNextIfTrue; int speed = -1; int x=-1; int y=-1; //SPEED TAKES NEGETIVE NUMBERS FOR SLOW MOVEMENT!!!
    int spdXYListint[];  spdXYListint = new int[ ANIM_SPD_X_Y_LENGTH*3 ];
    spdXYListint = animObjs_JoinLists(  speedOR_NOANIM1_x_y_ListA,  
                      speedOR_NOANIM1_x_y_ListB, speedOR_NOANIM1_x_y_ListC  );
   
     int i =0; int i_SXY = 0;Object *o; bool endLoop; bool useObjY = false;
     ///////////////////////SORT THROUGH OBJECTS
     while( i < ANIM_OBJS_LENGTH){
       if(getObjList[i] != ANIM_OFF){
          o = object[ getObjList[ i ] ];
          runNextIfTrue = false; endLoop = false; i_SXY = 0; useObjY = false;
            ////////////////////////SORT THROUGH COMMANDS
             while( o.Moving == false && endLoop == false ){  
                speed = spdXYListint[ i_SXY ]; 
                x = spdXYListint[ i_SXY + 1 ]; 
                y = spdXYListint[ i_SXY + 2 ]; 
                //use if relative to object
                if( relativeUsing_BlockingBorders ){ 
                  if( o.BlockingHeight >= 0 ){
                    o.BlockingHeight = -o.Y; o.BlockingWidth = -o.X;
                    if( o.Y <= 0 ){ o.BlockingHeight = -1; }
                  }else{ x -= o.BlockingWidth; y -= o.BlockingHeight;}}
                if( x == ANIM_INOBJ_X ){ x = o.X; }
                if( y == ANIM_INOBJ_Y ){ y = o.Y; useObjY = true;}
                
                if(speed == ANIM_OFF_PERMINATELY ){ 
                    if((x == o.X && y == o.Y) || runNextIfTrue){ o.X = x; o.Y = y; endLoop = true;} 
                }else if(speed == ANIM_OFF ){ 
                }else if(speed == ANIM_PAUSE_HALF_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 0.5, runNextIfTrue,  false, useObjY );
                }else if(speed == ANIM_PAUSE_1_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 1.0, runNextIfTrue,  false, useObjY);
                }else if(speed == ANIM_PAUSE_2_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 2.0, runNextIfTrue,  false, useObjY);
                }else if(speed == ANIM_PAUSE_4_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 4.0, runNextIfTrue,  false, useObjY);
                }else if(speed == ANIM_PAUSE_8_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 8.0, runNextIfTrue,  false, useObjY);
                }else if(speed == ANIM_PAUSEHIDE_HALF_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 0.5, runNextIfTrue,  true, useObjY);
                }else if(speed == ANIM_PAUSEHIDE_1_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 1.0, runNextIfTrue,  true, useObjY);
                }else if(speed == ANIM_PAUSEHIDE_2_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 4.0, runNextIfTrue,  true, useObjY);
                }else if(speed == ANIM_PAUSEHIDE_4_SEC ){  
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 8.0, runNextIfTrue,  true, useObjY);
                }else if(speed == ANIM_PAUSEHIDE_8_SEC ){ 
                  runNextIfTrue = ifAt_Or_PauseNHideIfTrue( o, x, y, 4.0, runNextIfTrue,  true, useObjY);
                }else{ runNextIfTrue = ifAt_Or_MoveTooIfTrue( o, x, y, speed, runNextIfTrue); 
                } 
                ////////////////////////////Resets if ANIM_OFF... plus break if it is on number 1
                if( spdXYListint[i_SXY] ==  ANIM_OFF || (i_SXY + 3 + 1) >  ANIM_SPD_X_Y_LENGTH*3 ){ 
                    if( i_SXY == 0 ){ endLoop = true; }
                    i_SXY = 0;  runNextIfTrue = true; 
                }else{ i_SXY += 3; }  
      } }  
   i += 1;  }
}
 
 
 
 function animObjs(        int getObjList[], 
                          int speedOR_NOANIM1_x_y_ListA[], 
                          int speedOR_NOANIM1_x_y_ListB[], 
                          int speedOR_NOANIM1_x_y_ListC[]){ 
   animObjs_core(false,  getObjList, speedOR_NOANIM1_x_y_ListA, 
          speedOR_NOANIM1_x_y_ListB,  speedOR_NOANIM1_x_y_ListC);}
 function animObjs_relativeToObjStrt(        int getObjList[], 
                          int speedOR_NOANIM1_x_y_ListA[], 
                          int speedOR_NOANIM1_x_y_ListB[], 
                          int speedOR_NOANIM1_x_y_ListC[]){ 
   animObjs_core(true,  getObjList, speedOR_NOANIM1_x_y_ListA, 
          speedOR_NOANIM1_x_y_ListB,  speedOR_NOANIM1_x_y_ListC);}
 ////////////////////////////
 //////////////////////////////////////
 /////////////////////////////////////
 //////////////////////////////////
 ///////////////////////////////////////////////////////
  
  
  /*
   bool t; int speed = 10; //SPEED TAKES NEGETIVE NUMBERS FOR SLOW MOVEMENT!!!
   
    int NumbObjects = 3 + 1;
    int ol[]; ol = new int[NumbObjects + 1]; ol[0] = NumbObjects;
    ol[1] = o1In.ID; ol[2] = o2In.ID; ol[3] = o3In.ID;
     
     int i =1; Object *o;
     while( i < ol[0]){
       o = object[ ol[i] ]; 
       t = false;
       
       ///THIS IS HOW THIS SYSTEM WORKS, I LEFT THE COMMENT HERE INCASE I NEED IT AT
       ///SOME POINT!!!
       /// IT LOOPS THROUGH LOCATIONS, AND IF THE OBJECT IS THERE, 
       /// IT SETS t TO TRUE AND RUNS THE NEXT MOVEMENT. 
       /// (ONLY WORKS IF OBJ IS NOT MOVING, RUNS FIRST MOVE COMMAND IF AT NO LOCATIONS)
       /// 
       /// THE ONLY PROBLEM IS IT CAN'T TAKE 2 LOCATIONS THAT ARE THE SAME 
       /// WITHOUT ONE RUNNING INSTEAD OF THE OTHER 
       /// 
       while(o.Moving == false ){
        t = ifAt_Or_MoveTooIfTrue( o, animObjs_XScrn(o, 0.6), animObjs_YScrn(o, 0.25), -speed/4, t);
        t = ifAt_Or_MoveTooIfTrue( o, animObjs_XScrn(o, 0.8), animObjs_YScrn(o, 0.5),  speed, t);
        //t = ifAt_Or_MoveTooIfTrue( o, o2In.X, o2In.Y, 1000, t);
        t = ifAt_Or_MoveTooIfTrue( o, player.x, player.y, speed/2, t);
        t = ifAt_Or_MoveTooIfTrue( o, animObjs_XScrn(o, 0.0), animObjs_YScrn(o, 0.5), speed, t);
        //t = ifAt_Or_MoveTooIfTrue( o, o2In.X, o2In.Y, speed, t);
        t = true;  }
      i += 1;
     }
    
    */
    

 \	  // new module header
//
// ANIM_OFF, 
// ANIM_PAUSE_HALF_SEC, ANIM_PAUSE_1_SEC, ANIM_PAUSE_2_SEC, ANIM_PAUSE_4_SEC, ANIM_PAUSE_8_SEC
// ANIM_PAUSEHIDE_HALF_SEC, ANIM_PAUSEHIDE_1_SEC, ANIM_PAUSEHIDE_2_SEC, ANIM_PAUSEHIDE_4_SEC, ANIM_PAUSEHIDE_8_SEC,
// ANIM_OFF_PERMINATELY
//
//
/*
  ////////// Put these in repeatedly_execute functions.
  //OR   animObjs_relativeToObjStrt, takes same paramiters.
  
  animObjs( animObjs_Objs(  ), 
          //Don't use the same location twice
            animObjs_SXYs( ), 
            animObjs_SXYs( ),  
              animObjs_SXYs( ));
*/
//
int ANIM_OFF = -9999;
int ANIM_PAUSE_HALF_SEC = -9998;
int ANIM_PAUSE_1_SEC = -9989;
int ANIM_PAUSE_2_SEC = -9997;
int ANIM_PAUSE_4_SEC = -9996;
int ANIM_PAUSE_8_SEC = -9995;
int ANIM_PAUSEHIDE_HALF_SEC = -9994;
int ANIM_PAUSEHIDE_1_SEC = -9993;
int ANIM_PAUSEHIDE_2_SEC = -9992;
int ANIM_PAUSEHIDE_4_SEC = -9991;
int ANIM_PAUSEHIDE_8_SEC = -9990;
int ANIM_OFF_PERMINATELY = -9988;

int ANIM_INOBJ_X = -9986;
int ANIM_INOBJ_Y = -9985;

int ANIM_OBJS_LENGTH = 9;
int ANIM_SPD_X_Y_LENGTH = 12;


import function animObjs(  int getObjList[], 
                       //Don't use the same location twice
                          int speedOR_ANIM_CMD_x_y_ListA[], 
                          int speedOR_ANIM_CMD_x_y_ListB[], 
                          int speedOR_ANIM_CMD_x_y_ListC[]);
import function animObjs_relativeToObjStrt( int getObjList[], 
   //Don't use the same location twice //USES BlockingWidth, BlockingHeight, so don't use solid
                          int speedOR_NOANIM1_x_y_ListA[], 
                          int speedOR_NOANIM1_x_y_ListB[], 
                          int speedOR_NOANIM1_x_y_ListC[]);
 
import int[] animObjs_Objs(
          int obj1ID = -9999,  int obj2ID = -9999, int obj3ID = -9999, 
          int obj4ID = -9999, int obj5ID = -9999, int obj6ID = -9999, 
          int obj7ID = -9999, int obj8ID = -9999, int obj9ID = -9999 );
import int[] animObjs_SXYs(
  int speedOR_ANIMCMD1 = -9999, int x1 = -1, int y1 = -1,   
  int speedOR_ANIMCMD2 = -9999, int x2 = -1, int y2 = -1,
  int speedOR_ANIMCMD3 = -9999, int x3 = -1, int y3 = -1, 
  int speedOR_ANIMCMD4 = -9999, int x4 = -1, int y4 = -1);


import int animObjs_XScrn( Object *obj, float percentX );
import int animObjs_YScrn( Object *obj, float percentY );
    ��_-        ej��