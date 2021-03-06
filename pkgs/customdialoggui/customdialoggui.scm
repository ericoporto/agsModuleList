AGSScriptModule    abstauber provides an easy way to customize Dialogs GUIs CustomDialogGui 1.7 ��  // CustomDialogGui 
// global vars
CustomDialogGui CDG;
int CDG_active_options[];
int CDG_active_options_height[];
int CDG_active_options_width[];
int CDG_active_options_sprite[];
int CDG_active_options_hisprite[];
int CDG_active_options_per_row[];
String CDG_active_options_text[];

/***********************************************************************
 * PUBLIC FUNCTION
 * init()
 * Set and modify your default GUI options here
 *
 ***********************************************************************/
function CustomDialogGui::init() {
  
  // whether it's a text or an icon based GUI
  // valid values are: eTextMode and eIconMode
  this.gui_type      = eTextMode;
  // Top-Left corner of the Dialog GUI
  this.gui_xpos        = 20;
  this.gui_ypos        = 20;
  this.gui_stays_centered_x = false;
  this.gui_stays_centered_y = false;
  
  //Size of the whole Dialog GUI
  this.gui_width       = 200;
  this.gui_height      = 100;
  
  // optional, dialog is shown at your mousecursor.
  // xyscreeenborders define the closest distance to the screen.
  // This overrides gui_xpos and ypos.
  this.gui_pos_at_cursor  = false;
  this.yscreenborder      = 0;
  this.xscreenborder      = 0;   
  
  // optional ParserTextBox
  this.gui_parser_xpos   = 20;
  this.gui_parser_ypos   = 100;
  this.gui_parser_width  = 200;
  
  // The font
  this.text_font        = eFontFont0;
  this.text_alignment   = eAlignLeft;
  this.text_color       = 4;
  this.text_color_active = 13;
  
  // optional background Image for the Text
  this.text_bg           = 0;
  this.text_bg_xpos      = 0;
  this.text_bg_scaling   = 0;
  this.text_bg_transparency = 0;
  this.text_line_space   = 2;
  this.text_numbering    = true; 
 
  
  // if you use icons instead of text
  // should they align vertical or horizontal
  this.icon_align_horizontal= false;
  // Should the text be vertically centered then?
  this.icon_text_vert_center= false;
  // sorts the inventory topics last
  this.icon_sort_inv = false;
  // Icon are centered in horizontal mode
  this.icon_horizontal_center = false;
  // Shows the inventory topics in a new line
  // and adds the number you define as a spacer, if icon_sort_inv is set true.
  this.icon_inv_linefeed = 0;
  // display the option text beside the icon (only in vertical mode)
  this.icon_show_text_vertical = true;
  // How many rows are to be scrolled per click
  this.scroll_rows = 5;
  
  // optional bullet image, 0 = off
  this.bullet = 48;
  
  // scrolling with mousewheel
  this.mousewheel      = true;
  
  // Always begins the dialog with the first option available
  this.reset_scrollstate = false;
  
  // First option on the bottom, last option on top
  // it doesn't not work with horizontal icons or icon_inv_sort
  this.dialog_options_upwards = false;
  
  // Image Number and XY-Coordinates for the Up-Arrow image
  // Highlight and push images are optional;
  //
  // WARNING:
  // Arrow highlighting is still beta! Don't use it in a 
  // productive release
  this.uparrow_img     = 45;
  this.uparrow_hi_img  = 0;
  this.uparrow_push_img= 0;  
  this.uparrow_xpos    = 189;
  this.uparrow_ypos    = 1;
  
  //Image Number and XY-Coordinates for the Down-Arrow image
  this.downarrow_img   = 46;
  this.downarrow_hi_img  = 0;
  this.downarrow_push_img= 0;  
  this.downarrow_xpos  = 189;
  this.downarrow_ypos  = 90;
  
  // Amount of time, after scrolling is being processed
  // use this if you have push-images for scrolling arrows
  this.scroll_btn_delay = 0.5;
  
  // Autoalign arrows so you don't need to supply XY-coordinates 
  // strongly recommended in combination with autoheight and autowidth
  // 0 = off, 1 = left, 2= center, 3=right
  this.auto_arrow_align = 0; 
  // Define the offset between the arrow sprite and the GUI edge. This value
  // is not affected by the borders, so you have to make sure that the offset
  // is not greater than the border size.
  this.auto_arrow_up_offset_x = 1;
  this.auto_arrow_up_offset_y = 1;
  this.auto_arrow_down_offset_x = 1;
  this.auto_arrow_down_offset_y = 1;  

  // Borders
  this.border_top      = 5;
  this.border_bottom   = 5;
  this.border_left     = 13;
  this.border_right    = 12;
  this.border_visible  = true;
  this.border_color    = 4;
  
  // this value is set when you use the setAutosizeCorners function
  this.borderDeco = false;
  
  // Seperationline on the left
  this.seperator_visible   = true;
  this.seperator_color     = 0;
  
  // Background
  // set bg_img_transparency to -1 if you're using 32-bit graphics and
  // want to preserve the alpha channel  
  this.bg_img                = 0;
  this.bg_img_scaling        = 0;
  this.bg_img_transparency   = 0;
  this.bg_color              = 14;
  
  // optional autosize, overrides your width and height setting
  // also overrides the position of your scrolling - arrows
  this.autosize_height       = false; 
  this.autosize_width        = false;
  this.autosize_minheight    = 20; 
  this.autosize_maxheight    = 150; 
  this.autosize_minwidth     = 60;
  this.autosize_maxwidth     = 200; 
  // set the anchorpoint of the GUI 
  // with this option you control to which side the gui expands
  this.anchor_point  = eAnchorTopLeft;  
  // Options end 
}

/***********************************************************************
 * PUBLIC FUNCTION
 * setAutosizeCorners()
 * 
 ***********************************************************************/
function CustomDialogGui::setAutosizeCorners(int upleft, int upright, int downleft, int downright)
{
  this.borderDeco = true;
  this.borderDecoCornerUpleft     = upleft;
  this.borderDecoCornerUpright    = upright;
  this.borderDecoCornerDownleft   = downleft;
  this.borderDecoCornerDownright  = downright;
}

/***********************************************************************
 * EXTENDER FUNCTION
 * DrawCharacter()
 *  
 * this function is called by DrawBackground
 ***********************************************************************/
function DrawCharacter(this DrawingSurface*, Character *theCharacter) {
  if (theCharacter == null) return;
  ViewFrame *frame = Game.GetViewFrame(theCharacter.View, theCharacter.Loop, theCharacter.Frame);
  DynamicSprite *sprite;
  int graphic = frame.Graphic;
  if (frame.Flipped) {
    sprite = DynamicSprite.CreateFromExistingSprite(graphic, true);
    sprite.Flip(eFlipLeftToRight);
  }
  if (theCharacter.Scaling != 100) {
    int scale = theCharacter.Scaling;
    if (sprite == null) sprite = DynamicSprite.CreateFromExistingSprite(graphic, true);
    sprite.Resize((Game.SpriteWidth[graphic] * scale) / 100, (Game.SpriteHeight[graphic] * scale) / 100);
  }
  Region *rat = Region.GetAtRoomXY(theCharacter.x, theCharacter.y);
  if ((rat != null) && (rat != region[0]) && (rat.TintEnabled)) {
    if (sprite == null) sprite = DynamicSprite.CreateFromExistingSprite(graphic, true);
    sprite.Tint(rat.TintRed, rat.TintGreen, rat.TintBlue, rat.TintSaturation, 100);
  }
  if (sprite != null) graphic = sprite.Graphic;
  this.DrawImage(theCharacter.x - (Game.SpriteWidth[graphic] / 2) - GetViewportX(), theCharacter.y - Game.SpriteHeight[graphic] - theCharacter.z - GetViewportY(), graphic, theCharacter.Transparency);
  if (sprite != null) sprite.Delete();
}

/***********************************************************************
 * EXTENDER FUNCTION
 * DrawObject()
 * 
 * this function is called by DrawBackground
 ***********************************************************************/
function DrawObject(this DrawingSurface*, Object *theObject) {
  if ((theObject == null) || (!theObject.Graphic) ||(!theObject.Visible)) return;
  
  DynamicSprite *sprite;
  int graphic = theObject.Graphic;
  if (theObject.View) {
    ViewFrame *frame = Game.GetViewFrame(theObject.View, theObject.Loop, theObject.Frame);
    if (frame.Flipped) {
      sprite = DynamicSprite.CreateFromExistingSprite(frame.Graphic, true);
      sprite.Flip(eFlipLeftToRight);
    }
  }
  int scale = GetScalingAt(theObject.X, theObject.Y);
  if ((!theObject.IgnoreScaling) && (scale != 100)) {
    if (sprite == null) sprite = DynamicSprite.CreateFromExistingSprite(graphic, true);
    sprite.Resize((Game.SpriteWidth[graphic] * scale) / 100, (Game.SpriteHeight[graphic] * scale) / 100);
  }
  Region *rat = Region.GetAtRoomXY(theObject.X, theObject.Y);
  if ((rat != null) && (rat != region[0]) && (rat.TintEnabled)) {
    if (sprite == null) sprite = DynamicSprite.CreateFromExistingSprite(graphic, true);
    sprite.Tint(rat.TintRed, rat.TintGreen, rat.TintBlue, rat.TintSaturation, 100);
  }
  if (sprite != null) graphic = sprite.Graphic;
  this.DrawImage(theObject.X  - GetViewportX(), theObject.Y - Game.SpriteHeight[graphic]- GetViewportY(), graphic, theObject.Transparency);
  if (sprite != null) sprite.Delete();
}

/***********************************************************************
 * EXTENDER FUNCTION
 * DrawBackground(this DialogOptionsRenderingInfo)
 *
 * AGS doesn't currently support alpha channeled DrawingSurface transparency 
 * (i.e., drawing alpha channeled sprites over a transparent surface)
 * This creates a flattened version of the background, objects, etc. to 
 * draw onto instead 
 *
 * calls the functions DrawObject and DrawCharacter
 ***********************************************************************/
function DrawBackground(this DialogOptionsRenderingInfo*) {
  int view_x = GetViewportX();
  int view_y = GetViewportY();
  DynamicSprite *sprite = DynamicSprite.CreateFromBackground(GetBackgroundFrame(), view_x, view_y, Room.Width-view_x, Room.Height-view_y);
  DrawingSurface *surface = sprite.GetDrawingSurface();
  int i = 0;
  while ((i < Game.CharacterCount) || (i < Room.ObjectCount)) {
    if ((i < Game.CharacterCount) && (character[i].Room == player.Room)) surface.DrawCharacter(character[i]);
    if (i < Room.ObjectCount) {
      surface.DrawObject(object[i]);
      if (object[i].Graphic) {
        int scale = GetScalingAt(object[i].X, object[i].Y);
        int ow = (Game.SpriteWidth[object[i].Graphic] * scale) / 100;
        int oh = (Game.SpriteHeight[object[i].Graphic] * scale) / 100;
        if (object[i].IgnoreScaling) {
          ow = Game.SpriteWidth[object[i].Graphic];
          oh = Game.SpriteHeight[object[i].Graphic];
        }
        int ox1 = object[i].X;
        int ox2 = ox1 + ow;
        int j = 0;
        while (j < Game.CharacterCount) {
          if (character[j].Room == player.Room) {
            ViewFrame *frame = Game.GetViewFrame(character[j].View, character[j].Loop, character[j].Frame);
            int cw = (Game.SpriteWidth[frame.Graphic] * character[j].Scaling) / 100;
            int cx1 = character[j].x - (cw / 2);
            if ((((cx1 + cw) >= ox1) && (cx1 <= ox2)) && (character[j].y > object[i].Baseline) && ((character[j].y - character[j].z) >= (object[i].Y - oh))) surface.DrawCharacter(character[j]);
          }
          j++;
        }
      }
    }
    i++;
  }
  surface.Release();
  sprite.Crop(this.X, this.Y, this.Width, this.Height);
  this.Surface.DrawImage(0, 0, sprite.Graphic);
  sprite.Delete();
}
 
/***********************************************************************
 * PUBLIC FUNCTION
 * setAutosizeBorders()
 * 
 *
 ***********************************************************************/
function CustomDialogGui::setAutosizeBorders(int top, int left, int bottom, int right)
{
    this.borderDeco = true;
    this.borderDecoFrameTop     = top;
    this.borderDecoFrameLeft    = left;
    this.borderDecoFrameBottom  = bottom;
    this.borderDecoFrameRight   = right;
}

/***********************************************************************
 * PRIVATE FUNCTION
 * prepare(DialogOptionsRenderingInfo)
 * Sets some global vars
 * 
 ***********************************************************************/
function _prepare(this CustomDialogGui*, DialogOptionsRenderingInfo *info)
{
  int i = 1;
  CDG.active_options_count = 1;
  CDG.linefeed_after_icon = 0;
  CDG.icon_rows =1;
  
  // count active options
  while (i <= info.DialogToRender.OptionCount) {
    if (info.DialogToRender.GetOptionState(i) == eOptionOn) CDG.active_options_count++;
    i++;
  }
  // prepare dynamic arrays
  CDG_active_options        = new int[CDG.active_options_count];
  CDG_active_options_height = new int[CDG.active_options_count];
  CDG_active_options_width  = new int[CDG.active_options_count];
  CDG_active_options_sprite = new int[CDG.active_options_count];
  CDG_active_options_hisprite=new int[CDG.active_options_count];
  CDG_active_options_per_row =new int[CDG.active_options_count];
  CDG_active_options_text   = new String[CDG.active_options_count];
}

/***********************************************************************
 * PRIVATE FUNCTION
 * _addOption(DialogOptionsRenderingInfo *info)
 * sets Dialog options up.
 * 
 ***********************************************************************/
function _addOption(this CustomDialogGui*, int position, int optionNumber, String optionText)
{
  String temp_option;
  int iconsprite, iconsprite_hi, temp_text_height;
  CDG_active_options[position] = optionNumber;
  
  // Text GUI
  if (CDG.gui_type == eTextMode) {
    if (CDG.text_numbering) {
      if (CDG.dialog_options_upwards) temp_option = String.Format ("%d.",CDG.active_options_count-position);
      else temp_option = String.Format ("%d.",position);
      temp_option = temp_option.Append(" ");
      temp_option = temp_option.Append(optionText);     
    }
    else temp_option = optionText;
    
    CDG_active_options_text[position]  = temp_option;
    CDG_active_options_height[position]= GetTextHeight(temp_option, CDG.text_font, 
          CDG.gui_width - CDG.border_left - CDG.border_right)+CDG.text_line_space;
    CDG_active_options_width[position] = GetTextWidth(temp_option, CDG.text_font)+ CDG.border_left + CDG.border_right +2;
    if (CDG.bullet!=0) 
      CDG_active_options_width[position] += Game.SpriteWidth[CDG.bullet];
  }
  
  // Icon GUI
  else if (CDG.gui_type == eIconMode)
  {
    temp_option   = optionText.Substring(2, optionText.IndexOf(","));
    iconsprite    = temp_option.AsInt;
    temp_option   = optionText.Substring(optionText.IndexOf(",")+1, optionText.IndexOf(")"));
    iconsprite_hi = temp_option.AsInt;            
    CDG_active_options_height[position]    = Game.SpriteHeight[iconsprite];
    CDG_active_options_width[position]     = Game.SpriteWidth[iconsprite];
    CDG_active_options_sprite[position]    = iconsprite;
    CDG_active_options_hisprite[position]  = iconsprite_hi;
    CDG_active_options_text[position]      = optionText.Substring(optionText.IndexOf(")")+1, optionText.Length);

    // get height for optiontext in vertical mode
    if (CDG.icon_show_text_vertical && !CDG.icon_align_horizontal) 
    {            
      temp_option = optionText.Substring(optionText.IndexOf(")")+1, optionText.Length);
      temp_text_height = GetTextHeight(temp_option, CDG.text_font, 
        CDG.gui_width - CDG.border_left - CDG.border_right -Game.SpriteWidth[iconsprite] );
        
      if (temp_text_height > CDG_active_options_height[position]) 
        CDG_active_options_height[position] = temp_text_height;
      if (CDG_active_options_height[position] < CDG.text_line_space)
        CDG_active_options_height[position] = CDG.text_line_space;
      CDG_active_options_width[position] += GetTextWidth(temp_option, CDG.text_font)+ CDG.border_left + CDG.border_right +2;    }    
  }
}



/***********************************************************************
 * PRIVATE FUNCTION
 * getOptionDetails(DialogOptionsRenderingInfo *info)
 * Get active option numbers, texts, icons and their max height  
 * 
 ***********************************************************************/
function _getOptionDetails(this CustomDialogGui*,DialogOptionsRenderingInfo *info){
  int i = 1, j = 1, option_count;
  String temp_option, temp_string;
  
  option_count = info.DialogToRender.OptionCount;
  
  // Text GUI
  if (CDG.gui_type == eTextMode) {
    // Normal Sorting
    if (!CDG.dialog_options_upwards) {
      while (i <= option_count) {
        if (info.DialogToRender.GetOptionState(i) == eOptionOn) 
        {
          temp_string   = info.DialogToRender.GetOptionText(i);
          CDG._addOption(j, i, temp_string);
          j++;
        }
        i++;
      }       
    }
    // Bottom-Up sorting
    else {
      i = option_count;
      while (i >= 1) {
        if (info.DialogToRender.GetOptionState(i) == eOptionOn) 
        {
          temp_string   = info.DialogToRender.GetOptionText(i);
          CDG._addOption(j, i, temp_string);
          j++;
        }
        i--;
      }   
    }
  }
  // Icon GUI
  else if (CDG.gui_type == eIconMode) 
  {
    // Normal Sorting
    if (!CDG.icon_sort_inv && !CDG.dialog_options_upwards) {
      while (i <= option_count) {
          if (info.DialogToRender.GetOptionState(i) == eOptionOn) 
          {  
            temp_string   = info.DialogToRender.GetOptionText(i);
            CDG._addOption(j, i, temp_string);
            j++;
          }
        i++;
      }
    }
    // Bottom -up sorting for vertical icons
    else if (!CDG.icon_sort_inv && CDG.dialog_options_upwards && !CDG.icon_align_horizontal) 
    {
      i = option_count;
       while (i >= 1) {
          if (info.DialogToRender.GetOptionState(i) == eOptionOn) 
          {  
            temp_string   = info.DialogToRender.GetOptionText(i);
            CDG._addOption(j, i, temp_string);
            j++;
          }
        i--;
      }      
    }
    // sort inventory (options starting with a "d" come first, "i" options come last
    else if(CDG.icon_sort_inv) {
      while (i <= option_count) {
        if (info.DialogToRender.GetOptionState(i) == eOptionOn) 
        {
          temp_string   = info.DialogToRender.GetOptionText(i);
          if (temp_string.Substring(1, 1) == "d") {
            CDG._addOption(j, i, temp_string);
            j++;
          }              
        }
        i++;
      }
      if (CDG.icon_sort_inv && CDG.icon_inv_linefeed > 0 )CDG.linefeed_after_icon = j-1;
      
      i=1;
      while (i <= option_count) {
        if (info.DialogToRender.GetOptionState(i) == eOptionOn) 
        {
          temp_string   = info.DialogToRender.GetOptionText(i);
          if (temp_string.Substring(1, 1) == "i") { 
            CDG._addOption(j, i, temp_string);
            j++;
          }
        }    
        i++;
      }
    }    
  }
}

/***********************************************************************
 * PRIVATE FUNCTION
 * _getRowCount()
 * Get the Number of Rows
 *
 * fills CDG.icon_rows     // how many rows need by supplied width
 * fills CDG.icons_per_row // how many icons fit in a row
 * 
 ***********************************************************************/
function _getRowCount(this CustomDialogGui*, int width)
{ 
  int i, j, k = 1, temp_height, shown_icons = 0, blank_icons =0; 
  bool first_call=false;
  
  j = 0;
  if ( CDG.scroll_from ==0) {
    CDG.scroll_from =1;      
    first_call = true;
  }
  i = CDG.scroll_from;
  
  // Text GUI
  if (CDG.gui_type == eTextMode) 
  {
    temp_height =CDG.max_option_height;
    // How many options fit in the max_height?

    while (i < CDG.active_options_count)
    {        
      if (temp_height > CDG_active_options_height[i]) {
        temp_height -= CDG_active_options_height[i];
        j++;
      }
      else i = CDG.active_options_count-1;
      CDG.scroll_to = j;
      i++;
    }
    
    CDG.scroll_to += CDG.scroll_from-1; 
    if (CDG.scroll_to >= CDG.active_options_count) CDG.scroll_to = CDG.active_options_count-1;   
    
    // Reverse counting to scroll down to the last option
    if (CDG.dialog_options_upwards && first_call) { 
      i = CDG.active_options_count-1;
      j = 0;
      temp_height = CDG.max_option_height;
      while (i > 0) {
        if (temp_height > CDG_active_options_height[i]) {
          temp_height -= CDG_active_options_height[i];
          j++;
        }else i=0;        
        i--;
      }
      CDG.scroll_to = CDG.active_options_count-1;  
      
      if (j >= CDG.active_options_count-1)CDG.scroll_from = 1;
      else CDG.scroll_from = CDG.active_options_count -j;
    }
  }
  // Icon GUI
  else if (CDG.gui_type == eIconMode) 
  {
    // vertical icon GUI
    if (!CDG.icon_align_horizontal) 
    {
      temp_height =CDG.max_option_height;
      // How many options fit in the max_height?
      while (i < CDG.active_options_count)
      {
        if (temp_height > CDG_active_options_height[i]) {
          temp_height -= CDG_active_options_height[i];
          if (CDG.linefeed_after_icon == i) temp_height -= CDG.icon_inv_linefeed;
          j++;
        }
        else i = CDG.active_options_count-1;
        CDG.scroll_to = j;
        i++;
      }
      i = CDG.scroll_from;
      CDG.icon_rows     = CDG.active_options_count;
      CDG.icons_per_row = 1;
      
      // Reverse counting to scroll down to the last option
      if (CDG.dialog_options_upwards && first_call && !CDG.icon_sort_inv) { 
        i = CDG.active_options_count-1;
        j = 0;
        temp_height =CDG.max_option_height;
        while (i > 0) {
          if (temp_height > CDG_active_options_height[i]) {
            temp_height -= CDG_active_options_height[i];
            j++;
          }else i=0;        
          i--;
        }
        CDG.scroll_to = CDG.active_options_count-1;  
        
        if (j >= CDG.active_options_count-1)CDG.scroll_from = 1;
        else CDG.scroll_from = CDG.active_options_count -j;
      }      
      
    }
    // horizontal icon GUI
    else if (CDG.icon_align_horizontal)
    {
      // Rounded down:(width - CDG.border_left - CDG.border_right) / CDG_active_options_width[1]
      CDG.icons_per_row = FloatToInt(IntToFloat(width - CDG.border_left - CDG.border_right) / IntToFloat(CDG_active_options_width[1]), eRoundDown);    
      
      if (CDG.icons_per_row > CDG.active_options_count-1) CDG.icons_per_row = CDG.active_options_count-1;
      
      while (k < CDG.active_options_count)
      {
        // Linefeed and not end of line
        if (k == CDG.linefeed_after_icon && (k % CDG.icons_per_row) != 0) 
        {
          blank_icons = CDG.icons_per_row - (CDG.linefeed_after_icon % CDG.icons_per_row);
          k += blank_icons;
        }
        
        // count complete row
        if ( (k % CDG.icons_per_row) == 0 )   
        {
          CDG_active_options_per_row[CDG.icon_rows] = CDG.icons_per_row - blank_icons;
          shown_icons += CDG.icons_per_row - blank_icons;
          CDG.icon_rows++;
          blank_icons = 0;
        }       
        k++;
      }
      
      // count remaining icons
      if (CDG.active_options_count-1 > shown_icons) 
        CDG_active_options_per_row[CDG.icon_rows] = CDG.active_options_count - 1 - shown_icons;
      
      if (CDG_active_options_per_row[CDG.icon_rows] == 0) CDG.icon_rows --;
      
      // How many rows fit in the max_height?
      temp_height = CDG.max_option_height;    
      
      while (i <= CDG.icon_rows)
      {
        if (temp_height > CDG_active_options_height[1]) {
          temp_height -= CDG_active_options_height[1];
          j++;
        }
        else i = CDG.icon_rows;
        i++;
      }
      CDG.scroll_to = j;
    }    
    CDG.scroll_to += CDG.scroll_from-1; 
    
    if ((CDG.scroll_to >= CDG.active_options_count) && !CDG.icon_align_horizontal) CDG.scroll_to = CDG.active_options_count-1;    
    else if ((CDG.scroll_to >= CDG.icon_rows) && CDG.icon_align_horizontal) CDG.scroll_to = CDG.icon_rows;     
  }
  
  
}

/***********************************************************************
 * AGS SUPPLIED FUNCTION 
 * dialog_options_get_dimensions
 * 
 ***********************************************************************/
function dialog_options_get_dimensions(DialogOptionsRenderingInfo *info)
{  
  int i=1, j=1, option_count=0, max_height=0, autoheight=0, active_options=1, 
      autowidth=0, max_width = 0,  temp_width = 0,  xpos,  ypos;
  String temp_option, temp_string;
  
  // Set proper alpha transparency for AGS 3.3 and above
#ifver 3.3
  if ((CDG.bg_img_transparency > 0 || CDG.bg_img_transparency == -1) && CDG.bg_img!=0 ) {
    info.HasAlphaChannel = true;
  }
#endif
    
    // Reserve space for bullet in textmode, if needed.
    if (CDG.bullet!=0 && CDG.gui_type == eTextMode) 
      if (CDG.border_left <Game.SpriteWidth[CDG.bullet]) {
        CDG.border_left   += Game.SpriteWidth[CDG.bullet];
    }

  ////////////////////////////////////////////////////////
  // calculate autowidth and autoheight                 //
  ////////////////////////////////////////////////////////
  if (CDG.autosize_height)
    CDG.max_option_height = CDG.autosize_maxheight - CDG.border_bottom - CDG.border_top;
  else
    CDG.max_option_height = CDG.gui_height - CDG.border_bottom - CDG.border_top;  
    
  if (CDG.autosize_height || CDG.autosize_width) {
    option_count = info.DialogToRender.OptionCount;       
    
    CDG._prepare(info);
    CDG._getOptionDetails(info);
    
    if (CDG.gui_type == eTextMode || !CDG.icon_align_horizontal)
    {
      while (i <= CDG.active_options_count-1) {
        max_height += CDG_active_options_height[i];
        temp_width = CDG_active_options_width[i];
        if (max_width < temp_width) max_width = temp_width;
        i++;
      }
      i=1;
    }
    
    // Icon GUI
    else if (CDG.gui_type == eIconMode){    
      if (CDG.autosize_width) CDG._getRowCount(CDG.autosize_maxwidth);
      else CDG._getRowCount(CDG.gui_width);
    
      max_height = CDG.icon_rows * CDG_active_options_height[1];

      if (CDG.autosize_width) {
        if (CDG.icon_align_horizontal) {
          
          while (i <= CDG.icon_rows) 
          {
            if (CDG_active_options_per_row[i] > active_options) active_options = CDG_active_options_per_row[i];
            i++;
          }
          max_width = active_options * CDG_active_options_width[1];
        }
      }
    }
    // check for min and max sizes
    autoheight = max_height + CDG.border_top + CDG.border_bottom +2;
    
    if (CDG.gui_type == eIconMode && CDG.icon_inv_linefeed > 0) 
      autoheight += CDG.icon_inv_linefeed-1;
    
    if (autoheight > CDG.autosize_maxheight) autoheight = CDG.autosize_maxheight;
    else if (autoheight <= CDG.autosize_minheight) autoheight = CDG.autosize_minheight; 
    
    autowidth = max_width + CDG.border_left+CDG.border_right +2;
    if (autowidth > CDG.autosize_maxwidth) autowidth = CDG.autosize_maxwidth;
    else if (autowidth <= CDG.autosize_minwidth) autowidth = CDG.autosize_minwidth;
  }
  
  
  if (!CDG.autosize_height) autoheight = CDG.gui_height;
  if (!CDG.autosize_width) autowidth = CDG.gui_width;  
  
  // Top-Left corner of the Dialog GUI
  // if the GUI has to follow the mouse
  
  if (CDG.gui_pos_at_cursor && CDG.lock_xy_pos == false) {
    if (CDG.anchor_point == eAnchorTopLeft) {
      xpos = mouse.x;
      ypos = mouse.y;      
    }
    else if (CDG.anchor_point == eAnchorTopRight) {
      xpos = mouse.x-autowidth;
      ypos = mouse.y; 
    }
    else if (CDG.anchor_point == eAnchorBottomLeft) {
      xpos = mouse.x;
      ypos = mouse.y-autoheight; 
    } 
    else if (CDG.anchor_point == eAnchorBottomRight) {
      xpos = mouse.x-autowidth;
      ypos = mouse.y-autoheight; 
    }     
    CDG.locked_xpos = xpos;
    CDG.locked_ypos = ypos;
  }
  else if (CDG.gui_pos_at_cursor && CDG.lock_xy_pos == true) {
    xpos = CDG.locked_xpos;
    ypos = CDG.locked_ypos;
  }
  else if (!CDG.gui_pos_at_cursor) {
    if (CDG.anchor_point == eAnchorTopLeft) {
      xpos = CDG.gui_xpos;
      ypos = CDG.gui_ypos;      
    }
    else if (CDG.anchor_point == eAnchorTopRight) {
      xpos = CDG.gui_xpos-autowidth;
      ypos = CDG.gui_ypos; 
    }
    else if (CDG.anchor_point == eAnchorBottomLeft) {
      xpos = CDG.gui_xpos;
      ypos = CDG.gui_ypos-autoheight; 
    } 
    else if (CDG.anchor_point == eAnchorBottomRight) {
      xpos = CDG.gui_xpos-autowidth;
      ypos = CDG.gui_ypos-autoheight; 
    }     
  }

  
  
// Check on Screenborders   
  
  if ((ypos + autoheight + CDG.yscreenborder) > System.ViewportHeight) {
    ypos = System.ViewportHeight - autoheight - CDG.yscreenborder;  
  }
  else if (ypos < CDG.yscreenborder) ypos =  CDG.yscreenborder;
    
  if ((xpos + autowidth + CDG.xscreenborder) > System.ViewportWidth) {
    xpos = System.ViewportWidth - autowidth - CDG.xscreenborder;      
  }
  else if (xpos < CDG.xscreenborder) xpos = CDG.xscreenborder;
      
  ////////////////////////////////////////////////////////
  // Set GUI sizes                                      //
  ////////////////////////////////////////////////////////      
  
  if (CDG.autosize_height) {  
    CDG.gui_height = autoheight;    
    
    if ((autoheight + ypos + CDG.yscreenborder) > System.ViewportHeight) {
      //CDG.bg_color=1;
      CDG.gui_height = System.ViewportHeight - ypos - CDG.yscreenborder;
    }
              
    else if ((CDG.gui_height + ypos + CDG.yscreenborder) > System.ViewportHeight) {
      //CDG.bg_color=1;
      CDG.gui_height = System.ViewportHeight - ypos - CDG.yscreenborder;
    }     
  }      

  if (CDG.autosize_width) {
    CDG.gui_width = autowidth;
    if (autowidth + xpos + CDG.xscreenborder > System.ViewportWidth) {
      CDG.gui_width = System.ViewportWidth- xpos - CDG.xscreenborder;  
    }        
    else if (CDG.gui_width + xpos + CDG.xscreenborder > System.ViewportWidth) {  
      CDG.gui_width = System.ViewportWidth- xpos - CDG.xscreenborder;  
    } 
  }  
  
  // Check, if GUI should be centerd
  if (CDG.gui_stays_centered_x)
    xpos = (System.ViewportWidth- CDG.gui_width) / 2;
  if (CDG.gui_stays_centered_y)
    ypos = (System.ViewportHeight - CDG.gui_height) /2;
    
  ////////////////////////////////////////////////////////
  // Arrow alignment                                    //
  ////////////////////////////////////////////////////////
  if (CDG.auto_arrow_align >0) {
   CDG.uparrow_ypos   = CDG.auto_arrow_up_offset_y;
   CDG.downarrow_ypos = CDG.gui_height - Game.SpriteHeight[CDG.downarrow_img] - CDG.auto_arrow_down_offset_y;  

      if (CDG.auto_arrow_align == 1) {
        CDG.uparrow_xpos   = CDG.border_left+ CDG.auto_arrow_up_offset_x;
        CDG.downarrow_xpos = CDG.border_left+ CDG.auto_arrow_down_offset_x;
      }
      else if (CDG.auto_arrow_align == 2) {
        CDG.uparrow_xpos   = CDG.gui_width / 2 - Game.SpriteWidth[CDG.downarrow_img] / 2;
        CDG.downarrow_xpos = CDG.uparrow_xpos;
      }      
      else if (CDG.auto_arrow_align ==3) {
        CDG.uparrow_xpos   = CDG.gui_width - Game.SpriteWidth[CDG.uparrow_img] - CDG.auto_arrow_up_offset_x; 
        CDG.downarrow_xpos = CDG.gui_width - Game.SpriteWidth[CDG.downarrow_img] - CDG.auto_arrow_down_offset_x; 
      }   
  }

  
  //Position of GUI
  info.X = xpos ;
  info.Y = ypos ;  
  //Size of GUI
  info.Width  = CDG.gui_width ;
  info.Height = CDG.gui_height;  
  
  // optional ParserTextBox
  info.ParserTextBoxX     = CDG.gui_parser_xpos;
  info.ParserTextBoxY     = CDG.gui_parser_ypos;
  info.ParserTextBoxWidth = CDG.gui_parser_width;
  
  //if (CDG.scroll_from == 0)CDG.scroll_from = 1;
}


/***********************************************************************
 * PRIVATE FUNCTION
 * _repexec
 * formally dialog_options_get_active
 *
 * 
 ***********************************************************************/
function _repexec(this CustomDialogGui*, DialogOptionsRenderingInfo *info)
{
    int i=0, ypos = CDG.border_top, xpos = CDG.border_left, xpos_offset,  
  icon_width = CDG_active_options_width[1], icon_height = CDG_active_options_height[1], j=1, 
  current_icon, current_option, icon_x1, icon_x2, icon_y1, icon_y2, linefeed_leftout_icons;
  
  CDG_Arrow uparrow;
  CDG_Arrow downarrow;
    
  int iconsprite;
  String temp_string, temp_option;
  bool linefeed_done;

  CDG.lock_xy_pos = true;

  // Up-Arrow coordinates
  uparrow.x1 = info.X + CDG.uparrow_xpos;
  uparrow.y1 = info.Y + CDG.uparrow_ypos ;
  uparrow.x2 = uparrow.x1 + Game.SpriteWidth[CDG.uparrow_img];
  uparrow.y2 = uparrow.y1 + Game.SpriteHeight[CDG.uparrow_img];

  // Down-Arrow coordinates
  downarrow.x1 = info.X + CDG.downarrow_xpos;
  downarrow.y1 = info.Y + CDG.downarrow_ypos ;
  downarrow.x2 = downarrow.x1 + Game.SpriteWidth[CDG.downarrow_img];
  downarrow.y2 = downarrow.y1 + Game.SpriteHeight[CDG.downarrow_img];    
  
  // scroll up-down: highlight / push
  // Scroll up
  if ((mouse.x >= uparrow.x1 && mouse.y >= uparrow.y1)&&(mouse.x <= uparrow.x2 && mouse.y <= uparrow.y2)) 
  {
    if (CDG.scroll_btn_push== true) 
    {
      if (CDG.uparrow_current_img != CDG.uparrow_push_img && CDG.uparrow_push_img !=0) 
      {
        CDG.uparrow_current_img = CDG.uparrow_push_img;
        CDG.downarrow_current_img = CDG.downarrow_img;
        CDG.scroll_btn_lock=true;
#ifver 3.4
        info.Update();
#endif
        return;
      }
    }
    else {
      if (CDG.uparrow_current_img !=CDG.uparrow_hi_img && CDG.uparrow_hi_img!=0) 
      { 
        CDG.uparrow_current_img = CDG.uparrow_hi_img;
        CDG.downarrow_current_img = CDG.downarrow_img;
        CDG.scroll_btn_lock=true;
#ifver 3.4
        info.Update();
#endif
        return;
      }
    }
  }
  // Scroll down
  else if ((mouse.x >= downarrow.x1 && mouse.y >= downarrow.y1) && (mouse.x <= downarrow.x2 && mouse.y <= downarrow.y2)) 
  {
    if (CDG.scroll_btn_push== true) {
      if (CDG.downarrow_current_img != CDG.downarrow_push_img && CDG.downarrow_push_img!=0) 
      {
        CDG.downarrow_current_img = CDG.downarrow_push_img;
        CDG.uparrow_current_img = CDG.uparrow_img;
        CDG.scroll_btn_lock=true;
#ifver 3.4
        info.Update();
#endif
        return;
      }         
    }
    else 
    {
      if (CDG.downarrow_current_img !=CDG.downarrow_hi_img && CDG.downarrow_hi_img !=0) 
      {
        CDG.downarrow_current_img = CDG.downarrow_hi_img;
        CDG.uparrow_current_img = CDG.uparrow_img;
        CDG.scroll_btn_lock=true;
#ifver 3.4
        info.Update();
#endif     
        return;
      }
    }
  }
  //Nothing
  else 
  {
    if ((CDG.downarrow_current_img !=CDG.downarrow_img ) ||(CDG.uparrow_current_img !=CDG.uparrow_img)) 
    {
      CDG.uparrow_current_img = CDG.uparrow_img;
      CDG.downarrow_current_img = CDG.downarrow_img;     
      CDG.scroll_btn_push=false;
      CDG.scroll_btn_timer = 0;
      CDG.scroll_btn_lock=true;
#ifver 3.4
        info.Update();
#endif     
      return;
    }
  }

        
  CDG.scroll_btn_lock = false;
  i = CDG.scroll_from;
  // Active option for vertical alignment
  if (!CDG.icon_align_horizontal || CDG.gui_type == eTextMode) 
  {
    while (i <= CDG.scroll_to) {
      
      ypos += CDG_active_options_height[i];
      if (CDG.linefeed_after_icon == i) ypos += CDG.icon_inv_linefeed;
      if ((mouse.y - info.Y) < ypos && 
          (mouse.y > info.Y + CDG.border_top) &&
         ((mouse.x > info.X + CDG.border_left)) && 
          (mouse.x < info.X+ CDG.gui_width - CDG.border_right))
      {
        info.ActiveOptionID = CDG_active_options[i];    
        return;
      }
      else  if ((mouse.y - info.Y) < ypos || 
                (mouse.y - info.Y > info.Height - CDG.border_bottom) ||
               ((mouse.x >info.X + CDG.gui_width - CDG.border_right))||
                (mouse.x<info.X))
       {        
        info.ActiveOptionID = 0;   
      }
      i++;
    }    
  }
  
  // Active options for horizontal alignment
  else if (CDG.icon_align_horizontal)
  { 
     // row
     while (i <= CDG.scroll_to) {       
       icon_y1 = info.Y + ypos; 
       icon_y2 = icon_y1 + icon_height;
       icon_x1 = info.X + xpos;
       icon_x2 = icon_x1 + icon_width;
       
        // count, how many icons are going to be drawn
        if (CDG.icon_horizontal_center) 
        {
          xpos_offset = 0;
            if (CDG_active_options_per_row[i] < CDG.icons_per_row) 
              xpos_offset = (CDG.icons_per_row - CDG_active_options_per_row[i])*CDG_active_options_width[i]/2;          
          xpos += xpos_offset;
        }     
       
       // iconline
       while (j<=CDG.icons_per_row)
       {
         icon_x1 = info.X + xpos;
         icon_x2 = icon_x1 + icon_width;
         
         if (linefeed_done)
           current_icon = ((i-1)*CDG.icons_per_row)+j-linefeed_leftout_icons;
         else current_icon = ((i-1)*CDG.icons_per_row)+j;         
         
         if ((mouse.x >= icon_x1 && mouse.y >= icon_y1) &&
             (mouse.x <= icon_x2 && mouse.y <= icon_y2))   
             {
                if ((current_icon) < CDG.active_options_count) {
                  info.ActiveOptionID = CDG_active_options[current_icon]; 
                  return;
                }
             }
             else info.ActiveOptionID = 0; 

         if (CDG.icon_inv_linefeed>0) 
           if (CDG.linefeed_after_icon == current_icon) {
             linefeed_done = true;
             ypos += CDG.icon_inv_linefeed-1; 
             linefeed_leftout_icons = CDG.icons_per_row - j;
             j = CDG.icons_per_row;   
           }           
         xpos += icon_width;    
         j++;
       }

       xpos = CDG.border_left;
       ypos += icon_height;
       j=1;
       i++;
     }
  }
}

/***********************************************************************
 * AGS SUPPLIED FUNCTION 
 * dialog_options_render
 * 
 ***********************************************************************/
function dialog_options_render(DialogOptionsRenderingInfo *info)
{

  int i = 1, j = 1, k = 1, ypos = CDG.border_top, ypos_offset, xpos = CDG.border_left, xpos_offset, current_height, 
      option_count=0, current_option, temp_height, current_icon, blank_icons, linefeed_leftout_icons, temp_text_height;
  String temp_option;
  bool linefeed_done;
  
  // Scoll Button workaround
  if (CDG.scroll_btn_lock == true) {
    info.ActiveOptionID =0;
    CDG.scroll_btn_lock = false;
  }  
  option_count = info.DialogToRender.OptionCount;
  
  ////////////////////////////////////////////////////////
  // Draw GUI decorations                               //
  ////////////////////////////////////////////////////////
  CDG.dialog_window = info;
 
  // Fill GUI Background
  if (CDG.bg_img==0)
    if (CDG.borderDeco){
      info.Surface.DrawingColor = CDG.bg_color;
      info.Surface.DrawRectangle(Game.SpriteWidth[CDG.borderDecoCornerUpleft]-1, Game.SpriteHeight[CDG.borderDecoCornerUpleft]-1, CDG.gui_width-Game.SpriteWidth[CDG.borderDecoCornerDownright], CDG.gui_height-Game.SpriteHeight[CDG.borderDecoCornerDownright]);
    }
    else info.Surface.Clear(CDG.bg_color);
  else 
  {
    // Fake alpha transparency for AGS < 3.3
#ifnver 3.3
    if ((CDG.bg_img_transparency > 0 || CDG.bg_img_transparency == -1) && CDG.bg_img!=0 ) {
      info.DrawBackground();
    }
#endif    
    
    if (CDG.bg_img_scaling==1) {
      if (CDG.borderDeco) 
        info.Surface.DrawImage(Game.SpriteWidth[CDG.borderDecoCornerUpleft]-1, Game.SpriteHeight[CDG.borderDecoCornerUpleft]-1, CDG.bg_img, CDG.bg_img_transparency, 
                              CDG.gui_width-Game.SpriteWidth[CDG.borderDecoCornerDownright]+1, CDG.gui_height-Game.SpriteHeight[CDG.borderDecoCornerDownright]+1);
      else {
        if (CDG.bg_img_transparency == -1) info.Surface.DrawImage(0, 0, CDG.bg_img, 0, info.Width, info.Height);
        else info.Surface.DrawImage(0, 0, CDG.bg_img, CDG.bg_img_transparency, info.Width, info.Height);        
      }
    }
    else {
      if (CDG.borderDeco)
        info.Surface.DrawImage(Game.SpriteWidth[CDG.borderDecoCornerUpleft]-1, Game.SpriteHeight[CDG.borderDecoCornerUpleft]-1, CDG.bg_img, CDG.bg_img_transparency);
      else {
        if (CDG.bg_img_transparency == -1) info.Surface.DrawImage(0, 0, CDG.bg_img);
        else info.Surface.DrawImage(0, 0, CDG.bg_img, CDG.bg_img_transparency);
      }
    }
  }
  
  // Draw fancy border decorations
  if (CDG.borderDeco) 
  {
    // top border
    info.Surface.DrawImage(Game.SpriteWidth[CDG.borderDecoCornerUpleft], 
                            0, 
                            CDG.borderDecoFrameTop, 0, 
                            CDG.gui_width-Game.SpriteWidth[CDG.borderDecoCornerUpright]-Game.SpriteWidth[CDG.borderDecoCornerUpleft],  
                            Game.SpriteHeight[CDG.borderDecoFrameTop]);
    // bottom border                            
    info.Surface.DrawImage(Game.SpriteWidth[CDG.borderDecoCornerDownleft], 
                            CDG.gui_height-Game.SpriteHeight[CDG.borderDecoFrameBottom], 
                            CDG.borderDecoFrameBottom, 0, 
                            CDG.gui_width - Game.SpriteWidth[CDG.borderDecoCornerDownright]-Game.SpriteWidth[CDG.borderDecoCornerDownleft],  
                            Game.SpriteHeight[CDG.borderDecoFrameBottom]);
                         
    // left border
    info.Surface.DrawImage(0, 
                            Game.SpriteHeight[CDG.borderDecoCornerUpleft], 
                            CDG.borderDecoFrameLeft, 0, 
                            Game.SpriteWidth[CDG.borderDecoFrameLeft], 
                            CDG.gui_height-Game.SpriteHeight[CDG.borderDecoCornerDownleft]-Game.SpriteHeight[CDG.borderDecoCornerUpleft]);
                          
    //right border
    info.Surface.DrawImage(CDG.gui_width-Game.SpriteWidth[CDG.borderDecoFrameRight], 
                            Game.SpriteHeight[CDG.borderDecoCornerUpright], 
                            CDG.borderDecoFrameRight, 0, 
                            Game.SpriteWidth[CDG.borderDecoFrameRight], 
                            CDG.gui_height-Game.SpriteHeight[CDG.borderDecoCornerDownright]-Game.SpriteWidth[CDG.borderDecoFrameRight]);
    
    // Corners
    info.Surface.DrawImage(0, 0, CDG.borderDecoCornerUpleft);
    info.Surface.DrawImage(CDG.gui_width-Game.SpriteWidth[CDG.borderDecoCornerUpright], 0, CDG.borderDecoCornerUpright);
    info.Surface.DrawImage(0, CDG.gui_height-Game.SpriteHeight[CDG.borderDecoCornerDownleft], CDG.borderDecoCornerDownleft);
    info.Surface.DrawImage(CDG.gui_width-Game.SpriteWidth[CDG.borderDecoCornerDownright], CDG.gui_height-Game.SpriteHeight[CDG.borderDecoCornerDownright], CDG.borderDecoCornerDownright);
  }
  
  
  // seperation line
  if (CDG.seperator_visible==true) {
    info.Surface.DrawingColor = CDG.seperator_color;
    info.Surface.DrawLine(CDG.uparrow_xpos-2, CDG.uparrow_ypos, CDG.uparrow_xpos-2, CDG.downarrow_ypos + Game.SpriteHeight[CDG.downarrow_img]);
  } 
  // Outline
  if (CDG.border_visible && ! CDG.borderDeco) {
    info.Surface.DrawingColor = CDG.border_color;
    info.Surface.DrawLine(0, 0, info.Width, 0);
    info.Surface.DrawLine(0, 0, 0, info.Height);
    if (System.ViewportWidth>320) {
      info.Surface.DrawLine(0, info.Height, info.Width, info.Height);
      info.Surface.DrawLine(info.Width, 0, info.Width, info.Height);   
    }
    else {
      info.Surface.DrawLine(0, info.Height-1, info.Width, info.Height-1);
      info.Surface.DrawLine(info.Width-1, 0, info.Width-1, info.Height);  
    }
  }
  CDG._prepare(info);
  CDG._getOptionDetails(info);

  ////////////////////////////////////////////////////////
  // Calculate, how many options fit in the GUI         //
  ////////////////////////////////////////////////////////
  CDG._getRowCount(CDG.gui_width);
  
  ////////////////////////////////////////////////////////
  // Finally draw the options                           //
  ////////////////////////////////////////////////////////
  i = CDG.scroll_from;
  
  // Text GUI
  if (CDG.gui_type == eTextMode) {
    while (i <= CDG.scroll_to)
    { 
      current_option = CDG_active_options[i];
      
      if (info.DialogToRender.GetOptionState(current_option) == eOptionOn)
      {             
        if (info.ActiveOptionID == current_option) info.Surface.DrawingColor = CDG.text_color_active;
        else info.Surface.DrawingColor = CDG.text_color;
        
        if (CDG.text_bg!=0) {
            if (CDG.text_bg_scaling==1)
              info.Surface.DrawImage(CDG.text_bg_xpos, ypos, CDG.text_bg, CDG.text_bg_transparency, 
              CDG.gui_width - CDG.text_bg_xpos - CDG.border_left , CDG_active_options_height[i]);
            else info.Surface.DrawImage(CDG.text_bg_xpos, ypos, CDG.text_bg, CDG.text_bg_transparency);
        }
        
        if (CDG.bullet!=0) info.Surface.DrawImage (CDG.border_left - Game.SpriteWidth[CDG.bullet], ypos, CDG.bullet);

        info.Surface.DrawStringWrapped(CDG.border_left, ypos, CDG.gui_width - CDG.border_left-CDG.border_right, 
                           CDG.text_font, CDG.text_alignment, CDG_active_options_text[i]);
        
        ypos += CDG_active_options_height[i];
      } 
      
      i++;
    }
  }
  // ICON GUI vertical mode
  else if (CDG.gui_type == eIconMode && !CDG.icon_align_horizontal) {
    while (i <= CDG.scroll_to)
    {

      current_option = CDG_active_options[i]; 
      if (info.DialogToRender.GetOptionState(current_option) == eOptionOn)
      {         
        if (info.ActiveOptionID == current_option)
          info.Surface.DrawImage(xpos, ypos, CDG_active_options_hisprite[i]);
        else
          info.Surface.DrawImage(xpos, ypos, CDG_active_options_sprite[i]);
        
        temp_height = CDG_active_options_height[i];
        ypos_offset = 0;
        
        // show optiontext in vertical mode
        if (CDG.icon_show_text_vertical ) 
        { 
          if (info.ActiveOptionID == current_option) info.Surface.DrawingColor = CDG.text_color_active;
          else info.Surface.DrawingColor = CDG.text_color;
          
          temp_option = CDG_active_options_text[i]; 

          temp_text_height = GetTextHeight(temp_option, CDG.text_font, 
              CDG.gui_width - CDG.border_left - CDG.border_right);
          if (temp_text_height > temp_height) temp_height = temp_text_height; 
          
          if (CDG.icon_text_vert_center) {
            if (temp_height <= CDG_active_options_height[i]){
              ypos_offset = (CDG_active_options_height[i] - temp_text_height)/2;
            }
          }
          
          info.Surface.DrawStringWrapped(CDG.border_left+Game.SpriteWidth[CDG_active_options_sprite[i]], ypos + ypos_offset, 
              CDG.gui_width  - CDG.border_left-CDG.border_right-CDG_active_options_height[i], 
              CDG.text_font, CDG.text_alignment, temp_option);                    
        }        
        
        ypos += temp_height;
        if (CDG.icon_inv_linefeed>0) 
          if (CDG.linefeed_after_icon == i) ypos += CDG.icon_inv_linefeed-1;
      }
      i++;
    }
  }
  // ICON GUI horizontal mode
  else if (CDG.gui_type == eIconMode && CDG.icon_align_horizontal) {
    
    // Rows
    while (i <= CDG.scroll_to)
    {
      // count, how many active icons there are per row
      if (CDG.icon_horizontal_center) 
      { 
        xpos_offset =0;
        if (CDG_active_options_per_row[i] < CDG.icons_per_row) 
          xpos_offset = (CDG.icons_per_row - CDG_active_options_per_row[i])*CDG_active_options_width[i]/2;
          
        xpos += xpos_offset;
      }
      // Iconline
      while (k <= CDG.icons_per_row) 
      {
        if (linefeed_done)
          current_icon = ((i-1)*CDG.icons_per_row)+k-linefeed_leftout_icons;
        else current_icon = ((i-1)*CDG.icons_per_row)+k;
        
        if ((current_icon) < CDG.active_options_count) {
          current_option = CDG_active_options[current_icon];
          if (info.DialogToRender.GetOptionState(current_option) == eOptionOn)
          {            
            if (info.ActiveOptionID == current_option)
              info.Surface.DrawImage(xpos, ypos, CDG_active_options_hisprite[current_icon]);
            else
              info.Surface.DrawImage(xpos, ypos, CDG_active_options_sprite[current_icon]); 
              
            //xpos += CDG_active_options_height[current_icon];
            xpos += CDG_active_options_width[current_icon];
          }
        if (CDG.icon_inv_linefeed>0) 
          if (CDG.linefeed_after_icon == current_icon) {
            linefeed_done = true;
            ypos += CDG.icon_inv_linefeed -1; 
            linefeed_leftout_icons = CDG.icons_per_row - k;
            k = CDG.icons_per_row;   
          }
        }
        k++;
      }
      
      ypos +=CDG_active_options_height[i];
      xpos = CDG.border_left;
      k = 1;
      i++;
    }
  }
 
  // Remove pushed state, if the mouse has left the buttons
  CDG_Arrow uparrow;
  CDG_Arrow downarrow;

  // Up-Arrow coordinates
  uparrow.x1 = info.X + CDG.uparrow_xpos;
  uparrow.y1 = info.Y + CDG.uparrow_ypos ;
  uparrow.x2 = uparrow.x1 + Game.SpriteWidth[CDG.uparrow_img];
  uparrow.y2 = uparrow.y1 + Game.SpriteHeight[CDG.uparrow_img];

  // Down-Arrow coordinates
  downarrow.x1 = info.X + CDG.downarrow_xpos;
  downarrow.y1 = info.Y + CDG.downarrow_ypos ;
  downarrow.x2 = downarrow.x1 + Game.SpriteWidth[CDG.downarrow_img];
  downarrow.y2 = downarrow.y1 + Game.SpriteHeight[CDG.downarrow_img];   
  
  if (!((mouse.x >= uparrow.x1 && mouse.y >= uparrow.y1)&&(mouse.x <= uparrow.x2 && mouse.y <= uparrow.y2)) &&
      !((mouse.x >= downarrow.x1 && mouse.y >= downarrow.y1) && (mouse.x <= downarrow.x2 && mouse.y <= downarrow.y2))){
      CDG.scroll_btn_push = false;
      CDG.scroll_btn_timer = 0;
      CDG.uparrow_current_img = CDG.uparrow_img;
      CDG.downarrow_current_img = CDG.downarrow_img;
      }
   
  
  // Draw scrolling sprites
  if (CDG.scroll_from!=1 || CDG.scroll_btn_push == true){ 
    info.Surface.DrawImage(CDG.uparrow_xpos, CDG.uparrow_ypos,  CDG.uparrow_current_img);
  }
  //Vertical alignment
  if (!CDG.icon_align_horizontal || CDG.gui_type == eTextMode) {
    if (CDG.scroll_to != CDG.active_options_count-1 || CDG.scroll_btn_push == true) 
      info.Surface.DrawImage(CDG.downarrow_xpos, CDG.downarrow_ypos,  CDG.downarrow_current_img);    
  }
  // horizontal alignment
  else if (CDG.icon_align_horizontal) {
    if (CDG.scroll_to < CDG.icon_rows || CDG.scroll_btn_push == true){
      info.Surface.DrawImage(CDG.downarrow_xpos, CDG.downarrow_ypos,  CDG.downarrow_current_img);     
    }
  }
}



/***********************************************************************
 * AGS SUPPLIED FUNCTION in 3.2 and 3.3
 * dialog_options_get_active
 * Highlight the textoptions on mouseover
 *
 ***********************************************************************/
#ifnver 3.4
function dialog_options_get_active(DialogOptionsRenderingInfo *info)
{
  CDG._repexec(info);
}
#endif
/***********************************************************************
 * AGS SUPPLIED FUNCTION in 3.4
 * dialog_options_repexec
 * repexec for custom dialog rendering
 *
 ***********************************************************************/
#ifver 3.4
function dialog_options_repexec(DialogOptionsRenderingInfo *info)
{
  CDG._repexec(info);
}
#endif


/***********************************************************************
 * AGS SUPPLIED FUNCTION 
 * dialog_options_mouse_click
 * 
 ***********************************************************************/
function dialog_options_mouse_click(DialogOptionsRenderingInfo *info, MouseButton button)
{

  CDG_Arrow uparrow;
  CDG_Arrow downarrow;
  int i;
  CDG.lock_xy_pos = true;

  // Up-Arrow coordinates
  uparrow.x1 = info.X + CDG.uparrow_xpos;
  uparrow.y1 = info.Y + CDG.uparrow_ypos ;
  uparrow.x2 = uparrow.x1 + Game.SpriteWidth[CDG.uparrow_img];
  uparrow.y2 = uparrow.y1 + Game.SpriteHeight[CDG.uparrow_img];

  // Down-Arrow coordinates
  downarrow.x1 = info.X + CDG.downarrow_xpos;
  downarrow.y1 = info.Y + CDG.downarrow_ypos ;
  downarrow.x2 = downarrow.x1 + Game.SpriteWidth[CDG.downarrow_img];
  downarrow.y2 = downarrow.y1 + Game.SpriteHeight[CDG.downarrow_img];
  

  // scroll up
  if (((mouse.x >= uparrow.x1 && mouse.y >= uparrow.y1) &&
       (mouse.x <= uparrow.x2 && mouse.y <= uparrow.y2))||
       (button == eMouseWheelNorth && CDG.mousewheel)) {
        i=0;
        
        while (i<CDG.scroll_rows)
        {
          if (CDG.scroll_from >1)
          { 
            CDG.scroll_from --;
            if (CDG.uparrow_push_img != 0 && CDG.downarrow_push_img !=0) {
              CDG.scroll_btn_timer = FloatToInt(CDG.scroll_btn_delay * IntToFloat(GetGameSpeed()), eRoundNearest);
              CDG.scroll_btn_push = true;
            }
          }
          dialog_options_render(info);          
          i++;
        }
  } 
  // scroll down
  else if (((mouse.x >= downarrow.x1 && mouse.y >= downarrow.y1) &&
            (mouse.x <= downarrow.x2 && mouse.y <= downarrow.y2)) ||
            (button == eMouseWheelSouth && CDG.mousewheel)) {
      
      i=0; 
      while (i<CDG.scroll_rows)
      {      
        if ((!CDG.icon_align_horizontal || CDG.gui_type == eTextMode) && (CDG.scroll_to != CDG.active_options_count-1)) {
          dialog_options_render(info); 
          if (CDG.uparrow_push_img != 0 && CDG.downarrow_push_img !=0) {
            CDG.scroll_btn_timer = FloatToInt(CDG.scroll_btn_delay * IntToFloat(GetGameSpeed()), eRoundNearest);
            CDG.scroll_btn_push = true;
          }
          CDG.scroll_from ++;
        }
        else if (CDG.icon_align_horizontal &&(CDG.scroll_to < CDG.icon_rows)) {
          dialog_options_render(info);   
          if (CDG.uparrow_push_img != 0 && CDG.downarrow_push_img !=0) {
            CDG.scroll_btn_timer = FloatToInt(CDG.scroll_btn_delay * IntToFloat(GetGameSpeed()), eRoundNearest);
            CDG.scroll_btn_push = true;
          }
          CDG.scroll_from ++;
        } 
        i++;
      }
  }
  
  #ifnver 3.4
  dialog_options_get_active(info);  
  #endif
  
  #ifver 3.4
  info.Update();
  if (button != eMouseWheelSouth && button != eMouseWheelNorth) info.RunActiveOption();
  #endif
}

function game_start() 
{
   CDG.scroll_btn_timer = 0;
   CDG.scroll_btn_push  = false;
   CDG.uparrow_current_img = CDG.uparrow_img;
   CDG.downarrow_current_img = CDG.downarrow_img;   
   CDG.init();
}

// Handle scroll button push event
function repeatedly_execute_always()
{
  if (CDG.scroll_btn_timer > 0) CDG.scroll_btn_timer--;
  if (CDG.scroll_btn_timer == 0 && CDG.scroll_btn_push==true) CDG.scroll_btn_push= false;
}

function repeatedly_execute() {
  if (CDG.lock_xy_pos) CDG.lock_xy_pos = false;
  if (CDG.reset_scrollstate) { 
    if (CDG.dialog_options_upwards) {
      CDG.scroll_from =0;
    }
    else CDG.scroll_from = 1;
  }
}

export CDG;   // Script header for module 'CustomDialogGui'
//
// Version: 1.6.2
//
// Author: Dirk Kreyenberg (abstauber)
//   Please use the PM function at the AGS forums to contact
//   me about problems with this module
// 
// Abstract: Adds a scrollable dialog GUI, which is easy to customize.
//
// Dependencies:
//
//   AGS 3.1.2 SP1 or later
//
//
// Usage:
// Inside your scripts (like room or global),
// you can access the GUI options this way:
//
//   CDG.bg_color=10;
//
//
// Syntax of dialog options in icon mode:
//  ([d/i][icon],[highlighted icon])Text
// 
//  Example: (d12,13)Want a cup of tea?
// 
//  This means, the topic uses sprite slot 12 as a normal icon,
//  slot 13 for the highlighted icon and it's a dialog item.
//
//  Example: (i14,15)Jelly Beans
//
//  This adds an "inventory-topic" which is sorted after the dialog topics.
//
// Please make also sure to uncheck "say" in the dialog editor. If you want the topic to be said,
// you have to add the text in the dialog itself.
//
//
// Caveats:
//  - The border line thickness is fixed at 1px
//  - There's no space between the bullets and the dialog text
//    You have to manage that via transparent pixels
//  - Arrow highlighting is experimental in AGS < 3.4.0
//  - For proper alpha channel support, in General settings:
//    set "sprite alpha rendering style" to "Proper Alpha Blending"
//    
//
// Revision History
// 1.0    initial release
// 1.1    customizable from roomscripts
// 1.2    Mousewheel support, fixed scrolling bugs, added optional space between lines,
//        added optional line numbering
// 1.2.1  Bugs fixed: wrong text height with auto numbering, outline border in hires. 
// 1.2.2  Bug fixed: translated options weren't shown correctly
// 1.3    Added auto-adjusting height and width
//        Added GUI appearing at mouse position
//        Added background scaling
// 1.4    Added support for icons as dialog options
//        Added Icons can be sorted vertically or horizontally
//        Added custom border decorations
//        Added sorting two kinds of dialog options
//        Added GUI stays centered on screen
//        Bugfix: GUI borders sometimes not accurate  
// 1.5    Added: Anchor point for autosize
//        Added: x/y-offset for scroll arrow images 
//        Added: Bottom-up sorting for text and vertical icons
//        Bugfix: GUI borders and highlighting corrected        
// 1.6    Fixed: Fullscreen Sideborders affecting position (Thanks to Genaral_Knox and Pumaman)
//        Fixed: Wrong icon position with non-square icons in horizontal mode
//        Added: scroll multiple rows per click
//        Added: highlight and push images for scroll arrows (experimental)
//        Added: semi-transparent backgrounds (Thanks to monkey_05_06)
// 1.6.1  Fixed: code cleanup, no need to manually import the CDG struct anymore
// 1.6.2  Added: 32-bit alpha channel support
// 1.6.3  Fixed: scrolling rooms with semi-transparent backgrounds
//
// 1.7    Added: AGS 3.4 support, 
//        Fixed: removed alpha-channel workaround for AGS >= 3.3
//
// Licence:
//
//   CustomDialogGui AGS script module
//   Copyright (C) 2008 - 2017 Dirk Kreyenberg
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to 
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.

enum CDGMode {
	eTextMode,
  eIconMode
};

enum CDGAnchorPoint {
  eAnchorTopLeft, 
  eAnchorTopRight, 
  eAnchorBottomLeft, 
  eAnchorBottomRight
};

struct CustomDialogGui {
  import function init();
  import function setAutosizeCorners(int upleft, int upright, int downleft, int downright);
  import function setAutosizeBorders(int top, int left, int bottom, int right);
  CDGMode gui_type;
  DialogOptionsRenderingInfo *dialog_window;
  int gui_xpos;
  int gui_ypos;
  bool gui_pos_at_cursor;
  int gui_width;
  int gui_height;
  int gui_parser_xpos;
  int gui_parser_ypos;
  int gui_parser_width;
  bool autosize_height;
  bool autosize_width;
  int yscreenborder;
  int xscreenborder;
  CDGAnchorPoint anchor_point;
  int autosize_minheight;
  int autosize_maxheight;
  int autosize_minwidth;
  int autosize_maxwidth;  
  bool gui_stays_centered_x;
  bool gui_stays_centered_y;
  int auto_arrow_align;
  int auto_arrow_up_offset_x;
  int auto_arrow_up_offset_y;
  int auto_arrow_down_offset_x;
  int auto_arrow_down_offset_y;  
  
  int bullet;
  
  int uparrow_img;
  int uparrow_hi_img;
  int uparrow_push_img;
  int uparrow_xpos;
  int uparrow_ypos;
  
  int downarrow_img;
  int downarrow_hi_img;
  int downarrow_push_img;
  int downarrow_xpos;
  int downarrow_ypos;

  float scroll_btn_delay;
  int border_top;
  int border_bottom;
  int border_left;
  int border_right;
  int border_visible;
  int border_color;

  bool seperator_visible;
  bool seperator_color;
  bool mousewheel;
  bool reset_scrollstate;
  bool dialog_options_upwards;
  int bg_img; 
  int bg_img_scaling;
  int bg_img_transparency;
  int bg_color;
  int scroll_rows;

  int text_font;
  int text_color;
  int text_color_active;
  int text_alignment;
  int text_bg;
  int text_bg_xpos;
  int text_bg_scaling;
  int text_bg_transparency;  
  int text_line_space;
  int text_numbering;
  bool icon_align_horizontal;
  bool icon_show_text_vertical;
  bool icon_text_vert_center;
  bool icon_horizontal_center;
  
  bool icon_sort_inv;
  int icon_inv_linefeed;
  
  // internal Stuff from here on
  int scroll_from;
  int scroll_to;
  int icons_per_row;
  int icon_rows;
  int icon_count_first_row;
  int linefeed_after_icon;
  int max_option_height;
  int max_option_width;
  int active_options_count;  
  int debug_ocount;
  int debug_maxheight;
  int debug_maxwidth;
  int debug_calcguiwidth;
  int debug_calcguiheight;
  bool lock_xy_pos;
  bool borderDeco;
  int borderDecoCornerUpleft;
  int borderDecoCornerUpright;
  int borderDecoCornerDownleft;
  int borderDecoCornerDownright;
  int borderDecoFrameTop;
  int borderDecoFrameLeft;
  int borderDecoFrameBottom;
  int borderDecoFrameRight;
  int locked_xpos;
  int locked_ypos;
  int scroll_btn_timer;
  bool scroll_btn_push;
  bool scroll_btn_lock;
  int uparrow_current_img;
  int downarrow_current_img;  
};

struct CDG_Arrow {
  int x1;
  int y1;
  int x2;
  int y2;
};

import CustomDialogGui CDG;


 	B�         ej��