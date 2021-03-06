AGSScriptModule        �  ////////////////////////////////////////////////////////////////////
//
//
//          STRINGUTIL
//
//
////////////////////////////////////////////////////////////////////



static String StringUtil::Trim(String s)
{
    String trimmedString=s;
    for (int i=0; i<s.Length; i++){
        if (trimmedString.StartsWith(" ")) 
            trimmedString = trimmedString.Substring(1,  trimmedString.Length-1);
        if (trimmedString.EndsWith(" ")) 
            trimmedString = trimmedString.Truncate(trimmedString.Length-1);
    }
    return trimmedString;
}

static bool StringUtil::IsNullOrEmpty(String s)
{
    if (s==null)
        return true;
    String trimmed = StringUtil.Trim(s);
    if (trimmed.Length==0)
        return true;
    
    return false;
}

static String StringUtil::SafeDisplay(String s)
{
    if(s==null) return "<null>";
    return s;
}


////////////////////////////////////////////////////////////////////
//
//
//          BLOCKING INPUT
//
//
////////////////////////////////////////////////////////////////////

struct Input
{
    String globalMessage;
    int lastInput;
    int lastInputModifier;
    int mouseClick;
    int mouseX;
    int mouseY;
    
    int eKeyLeftShift; // = 403;
    int eKeyRightShift; // = 404;
    int eKeyLowerCaseA; // = 97;

};
Input input;



void DetectCursor()
{
    /*
    int COLOR_RED = Game.GetColorFromRGB(255, 0, 0);
    
    DynamicSprite* s = DynamicSprite.CreateFromScreenShot(system.ViewportWidth,  system.ViewportHeight);
    DrawingSurface* ds = s.GetDrawingSurface();
    
    int color;
    for (int j=0; j<system.ViewportHeight/3; j++)
    {
        for (int i=0; i<system.ViewportWidth/3; i++)
        {
            color = ds.GetPixel(i*3, j*3); 
            if (color==COLOR_RED) //We detected a red pixel.
            {
                //Now Let's check if there are other red pixels around (at least two contiguous red pixels (one vertically, one horizontally)
                if (     i>0 && i < system.ViewportWidth-1 && (ds.GetPixel(i*3-1, j*3) == COLOR_RED || ds.GetPixel(i*3+1, j*3) == COLOR_RED)) 
                {
                    if ( j>0 && j < system.ViewportHeight-1  && (ds.GetPixel(i*3, j*3-1)   == COLOR_RED || ds.GetPixel(i*3+1, j*3+1)   == COLOR_RED))
                    {
                        //At this stage we're not 100% sure we've detected a 3x3 red square, but it's close enough
                        input.mouseX = i*3; input.mouseY = j*3;
                        break;
                    }
                }
            }
        }

        
    }
    ds.Release();
    s.Delete();
    */
    mouse.Update();
    input.mouseX = mouse.x;
    input.mouseY = mouse.y;
}

static void BlockingInput::ClearInput()
{    input.lastInput = -1;
    input.mouseClick = -1;
    input.globalMessage = "";
}

//To be called first after each major event (e.g. a call to "Display")
static void BlockingInput::UpdateInput()
{   
    
    BlockingInput.ClearInput();
    
    //Immediately capture the values to be faster than the player releasing the button. We'll process them later.
    if (mouse.IsButtonDown(eMouseLeft))
        input.mouseClick = eMouseLeft;
    else if (mouse.IsButtonDown(eMouseRight)) {
        input.mouseClick = eMouseRight;
    }
        
    //KEYBOARD (first because faster)
    if (IsKeyPressed(eKeyEscape))
    {
        input.lastInput = eKeyEscape;
        return;
    }

    for (int i=eKeyA; i<eKeyZ; i++)
    {
        if(IsKeyPressed(i)) {
            input.globalMessage = input.globalMessage.Append(String.Format("%c",i));
            //keyboardCount = 1;
            input.lastInput = i;
            break;
        }
    }
    if(IsKeyPressed(eKeyDownArrow)) {
        input.globalMessage = input.globalMessage.Append(String.Format("DOWN"));
        input.lastInput = eKeyDownArrow;
    }
    else if(IsKeyPressed(eKeyUpArrow)) {
        input.globalMessage = input.globalMessage.Append(String.Format("UP"));
        input.lastInput = eKeyUpArrow;
    }
    else if(IsKeyPressed(eKeyLeftArrow)) {
        input.globalMessage = input.globalMessage.Append(String.Format("LEFT"));
        input.lastInput = eKeyLeftArrow;
    }
    else if(IsKeyPressed(eKeyRightArrow)) {
        input.globalMessage = input.globalMessage.Append(String.Format("RIGHT"));
        input.lastInput = eKeyRightArrow;
    }
    else if(IsKeyPressed(eKeySpace)) {
        input.globalMessage = input.globalMessage.Append(String.Format("SPACE"));
        input.lastInput = eKeySpace;
    }    
    else if(IsKeyPressed(eKeyReturn)) {
        input.globalMessage = input.globalMessage.Append(String.Format("RETURN"));
        input.lastInput = eKeyReturn;
    }   
    else if(IsKeyPressed(eKeyBackspace)) {
        input.globalMessage = input.globalMessage.Append(String.Format("BACKSPACE"));
        input.lastInput = eKeyBackspace;
    }  
    else if(IsKeyPressed(eKeyDelete)) {
        input.globalMessage = input.globalMessage.Append(String.Format("DELETE"));
        input.lastInput = eKeyDelete;
    }  
    
    if(IsKeyPressed(input.eKeyLeftShift) || IsKeyPressed(input.eKeyRightShift)) {
        input.lastInputModifier = input.eKeyLeftShift;
    } else {
        input.lastInputModifier = -1;
    }
    
    //MOUSE (second because slower)
    DetectCursor();
    if (input.mouseClick == eMouseLeft) {
        input.globalMessage = String.Format("LEFT (x=%d, y=%d)", input.mouseX, input.mouseY);
    } else if(input.mouseClick == eMouseRight) {
        //message="RIGHT"
        input.lastInput = eKeyEscape;
        return;
    } 

}




        
static int BlockingInput::GetLastInput()
{
    return input.lastInput;    
}

//returns true if the last input was a capital letter. False the rest of the time (small letter or anything else)
static bool BlockingInput::IsLastInputCapital()
{
    return (input.lastInputModifier>0);
    
}
        
static int BlockingInput::GetMouseX()
{
    return input.mouseX;
    
}
        
static int BlockingInput::GetMouseY()
{
    return input.mouseY;
}

static int BlockingInput::GetMouseClick()
{
    return input.mouseClick;
}

void DefaultInit_BlockingInput()
{
    input.eKeyLeftShift = 403;
    input.eKeyRightShift = 404;
    input.eKeyLowerCaseA = 97;
    

}

    

////////////////////////////////////////////////////////////////////
//
//
//          DISPLAY-BASED GUI
//
//
////////////////////////////////////////////////////////////////////


String screen[]; //screenHeight_InChars rows of text


void Log(String msg) {
    //Checking if module "Console" is available
    #ifdef LOWEST
    MEDIUMLOW Console.W(msg);
    #endif
    
    ///...otherwise no logging for you!
}




struct SavedGameSettings
{
    //saved values taken from game settings
    int savedTopBarBorderColor;
    int savedTopBarBorderWidth;
    FontType savedTopBarFont;
    int savedMouseMode;
    int savedSkipStyle;
    int savedWaitGraphic;
    int savedPointerGraphic;
    int savedUserMode1Graphic;
    int savedNormalFont;
};
SavedGameSettings savedGameSettings;



TextControl textControls[30];
export textControls;


enum SpecialChars {
    //white spaces + cursor
    eChar_WhiteSpace1px = 0, 
    eChar_WhiteSpace2px, 
    eChar_Cursor, 
    eChar_WhiteSpace4px, //This actually useless; consider removing
    eChar_WhiteSpace5px, 
    
    //lines : 1px
    eChar_Line1px_TopLeft, 
    eChar_Line1px_Top, 
    eChar_Line1px_TopRight, 
    eChar_Line1px_Right, 
    eChar_Line1px_BottomRight, 
    eChar_Line1px_Bottom, 
    eChar_Line1px_BottomLeft, 
    eChar_Line1px_Left, 

    //lines : 2px
    eChar_Line2px_TopLeft, 
    eChar_Line2px_Top, 
    eChar_Line2px_TopRight, 
    eChar_Line2px_Right, 
    eChar_Line2px_BottomRight, 
    eChar_Line2px_Bottom, 
    eChar_Line2px_BottomLeft, 
    eChar_Line2px_Left, 
    
    //gizmos
    eChar_DownArrow, 
    
    
    //to be able to count items in enum
    eChar_LAST_IN_ENUM
    
};

struct Theme
{   

    
    //fonts
    FontType font;  
    int top_bar_font;    
    
    //colors
    int titleColor;
    int backColor;
    int top_bar_bordercolor;
    int top_bar_borderwidth;
};
Theme themes[2]; // 0 = default theme


struct TextWindowConstants
{
    char defaultCharacter ; // probably eChar_WhiteSpace5px
    int defaultCharacterWidth; //the default character's width expressed in pixels. This character will probably be eChar_WhiteSpace5px

    int specialCharAsciiCodes[];
    int NB_SPECIALCHARS; //Length of the 'specialCharAsciiCodes' array
    //int specialCursorGraphic;

};
TextWindowConstants textWindowConstants;

struct TextWindowSettings
{
    String title;
    
    int rowHeight; //height of a row of text, in pixels (usually character height + 1 for line spacing. There's an actual algorithm for calculating this properly but here we just set a value)
    
    int textWindowWidth_InChars; //expressed in number of characters; pixels calcualtions done using defaultCharacterWidth
    int textWindowHeight_InChars;

    DisplayTechnique displayTechnique;
    
    int nbClaimedControls;
    
};
TextWindowSettings textWindowSettings;




void ClearScreen()
{
    screen = new String[textWindowSettings.textWindowHeight_InChars];
    
    char emptyChar = textWindowConstants.specialCharAsciiCodes[textWindowConstants.defaultCharacter];
    String emptyChar5times = String.Format("%c%c%c%c%c", emptyChar, emptyChar, emptyChar, emptyChar, emptyChar);
    
    for (int row=0; row < textWindowSettings.textWindowHeight_InChars; row++)
    {
        String line = "";
        for (int column=0; column < (textWindowSettings.textWindowWidth_InChars/5); column++)
        {
            //this is the reason why textWindowSettings.textWindowWidth_InChars must be a multiple of 5
            line = line.Append(emptyChar5times);
        }
        
        screen[row] = line;
    }
    
    
}

//this will have no effect unless you've enabled TopBarDisplay rendering technique by calling DisplayGUI.SetDisplayTechnique();
//Pro: it's prettier. Con: there's a blink when clicking or pressing a key
static void DisplayBasedGUI::SetTheme(int titleColor,  int backColor,  int topBarBorderColor,  int topBarWidth,  FontType topBarFont)
{
    themes[1].titleColor = titleColor;
    themes[1].backColor = backColor;
    themes[1].top_bar_bordercolor = topBarBorderColor;
    themes[1].top_bar_borderwidth = topBarWidth;
    themes[1].top_bar_font = topBarFont;
}

//this will have no effect unless you've enabled TopBarDisplay rendering technique by calling DisplayGUI.SetDisplayTechnique();
static void DisplayBasedGUI::SetTitle(String title)
{
    textWindowSettings.title = title;
}


            

String RenderScreen_AsString()
{
    String result = "";
    for (int row=0; row < textWindowSettings.textWindowHeight_InChars; row++)
    {
        result = result.Append(screen[row]);
        result = result.Append("[");
    }
    return result;
    
}




void InitConstants()
{
    
    ///////////// SCPECIAL CHARACTERS ////////////
    textWindowConstants.NB_SPECIALCHARS = eChar_LAST_IN_ENUM + 1; //last one minus first one (+1 because zero-based)
    textWindowConstants.specialCharAsciiCodes = new int[textWindowConstants.NB_SPECIALCHARS];
    
    //white spaces
    textWindowConstants.specialCharAsciiCodes[eChar_WhiteSpace1px] = 1;
    textWindowConstants.specialCharAsciiCodes[eChar_WhiteSpace2px] = 2; 
    textWindowConstants.specialCharAsciiCodes[eChar_Cursor]        = 3; 
    textWindowConstants.specialCharAsciiCodes[eChar_WhiteSpace4px] = 4; 
    textWindowConstants.specialCharAsciiCodes[eChar_WhiteSpace5px] = 5; 
    
    //lines : 1px
    textWindowConstants.specialCharAsciiCodes[eChar_Line1px_TopLeft] =  6; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line1px_Top] =      7; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line1px_TopRight] = 8; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line1px_Right] =    9; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line1px_BottomRight] =  11;  //we skip '10' because it seems to be a reserved "carriage return" char 
    textWindowConstants.specialCharAsciiCodes[eChar_Line1px_Bottom] =       12; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line1px_BottomLeft] =   13; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line1px_Left] =         14; 

    //lines : 2px
    textWindowConstants.specialCharAsciiCodes[eChar_Line2px_TopLeft] =  15; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line2px_Top] =      16; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line2px_TopRight] = 17; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line2px_Right] =    18; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line2px_BottomRight] = 19; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line2px_Bottom] =       21; //we skip '20' because it's the "copyright" character and might be useful 
    textWindowConstants.specialCharAsciiCodes[eChar_Line2px_BottomLeft] =   22; 
    textWindowConstants.specialCharAsciiCodes[eChar_Line2px_Left] =         23; 
    
    //gizmos
    textWindowConstants.specialCharAsciiCodes[eChar_DownArrow]            = 25; 
    
    
    ////////// DEFAULT BLANK CHARACTER ///////////
    textWindowConstants.defaultCharacter = eChar_WhiteSpace5px;
    textWindowConstants.defaultCharacterWidth = GetTextWidth(String.Format("%c", textWindowConstants.specialCharAsciiCodes[textWindowConstants.defaultCharacter]), themes[1].font);


}

void CheckFont(FontType font)
{
    int NB_SPACES = 5;
    int firstChar = eChar_WhiteSpace1px;
    int lastChar = eChar_WhiteSpace5px;
    
    if ((lastChar-firstChar+1) != NB_SPACES) {
        String msg = String.Format("There aren't exactly %d characters from index of character for '1 pixel white space'(%d) to index of character for '5 pixels white space'(%d). Did you change something in the SpecialChars enum?", NB_SPACES,  firstChar,  lastChar);
        //Log(String.Format(msg));
        AbortGame(msg);
    }
    
    int expectedWidth=1;
    for (int c = firstChar; c<=lastChar;c++)
    {
        int width = GetTextWidth(String.Format("%c", textWindowConstants.specialCharAsciiCodes[c]),  font);
        if (c!= eChar_Cursor && width!=expectedWidth) {
            String msg = String.Format("Character with ascii code %d in Font %d expected to be all transparent and %d-pixels wide. It's not. Are you using the proper font shipped with the DisplayGUI module?", textWindowConstants.specialCharAsciiCodes[c], font, expectedWidth );
            //Log(String.Format(msg));
            AbortGame(msg); 
        }
        expectedWidth++;
    }
}

void CheckCursor(int graphic)
{
    int COLOR_RED = Game.GetColorFromRGB(255, 0, 0);
        
    bool fail = false;
    
    DynamicSprite* cursor = DynamicSprite.CreateFromExistingSprite(graphic);
    DrawingSurface* ds = cursor.GetDrawingSurface();
    if (ds.Width!=3 || ds.Height!=3)
        fail = true;

    int color;
    if (!fail)
    {
        for (int y=0; y<ds.Width;y++) {
            for (int x=0; x<ds.Width;x++) {
                color = ds.GetPixel(x, y);
                if (color!= COLOR_RED) {
                    fail = true;
                    break;
                }
            }
        }
    }
    
    if (fail)
        AbortGame("Not the expected cursor graphic. Did you use the one shipped with the module? (a 3x3 pixels red square). Also check the graphic slot provided (%d)", graphic);

    ds.Release();
    cursor.Delete();
}



void InitDefaultTheme()
{
    FontType font0 = 0;
    FontType font2 = 2;
    
    int COLOR_DARKBLUE = Game.GetColorFromRGB(10, 10, 150);
    int COLOR_WHITE = Game.GetColorFromRGB(255, 255, 254);
    int COLOR_LIGHTBLUE = Game.GetColorFromRGB(200, 200, 254);

    //themes[0].title = "<No title>";
    
    themes[0].font = font0;
    themes[0].top_bar_bordercolor = COLOR_DARKBLUE;
    themes[0].top_bar_borderwidth = 2;

    themes[0].titleColor = COLOR_DARKBLUE;
    themes[0].backColor = COLOR_LIGHTBLUE;
    
    if (Game.FontCount >= 3)
        themes[0].top_bar_font = font2; 
    else
        themes[0].top_bar_font = font0;
}


static int DisplayBasedGUI::GetWindowWidth_pixels()
{
    //Display("GetWindowWidth_pixels = %d x %d = %d", textWindowSettings.textWindowWidth_InChars, textWindowConstants.defaultCharacterWidth, textWindowSettings.textWindowWidth_InChars*textWindowConstants.defaultCharacterWidth);
    return textWindowSettings.textWindowWidth_InChars*textWindowConstants.defaultCharacterWidth;
}

  

static int DisplayBasedGUI::GetWindowHeight_pixels(bool includeTitleBar)
{
    int height = textWindowSettings.textWindowHeight_InChars*textWindowSettings.rowHeight;
    if (includeTitleBar)
        height+= textWindowSettings.rowHeight;
        
    return height;
}
    
static int DisplayBasedGUI::GetWindowTop_pixels(bool includeTitleBar)
{
    //return the top position for a window centered verticaly
   return (system.viewport_height - DisplayBasedGUI.GetWindowHeight_pixels(includeTitleBar))/2; //+3 is for the automated margin added by AGS all around the "Display" built-in popup
    
}

static int DisplayBasedGUI::GetWindowLeft_pixels()
{
    //return the left position for a window centered verticaly
    return (system.viewport_width - DisplayBasedGUI.GetWindowWidth_pixels())/2; //+3 is for the automated margin added by AGS all around the "Display" built-in popup
}


String GenerateWhiteSpaceAsChars(int width) 
{
    //primitive primary numbers factoring...
    int nbSpaces5 = width /5;
    int nbSpaces2 = (width-(nbSpaces5*5))/2;
    int nbSpaces1 = (width-(nbSpaces5*5)-(nbSpaces2*2)); //Will necessarily be 0 or 1 (I think? oh well should work anyways);
    
    String result = "";
    for (int i=0; i<nbSpaces5; i++) { result = result.Append(String.Format("%c", textWindowConstants.specialCharAsciiCodes[eChar_WhiteSpace5px])); }
    for (int i=0; i<nbSpaces2; i++) { result = result.Append(String.Format("%c", textWindowConstants.specialCharAsciiCodes[eChar_WhiteSpace2px])); }
    for (int i=0; i<nbSpaces1; i++) { result = result.Append(String.Format("%c", textWindowConstants.specialCharAsciiCodes[eChar_WhiteSpace1px])); }
    
    return result;
}

String GenerateHorizontalLine(int width,  bool topLine,  int lineThickness) 
{    
    int topLeftCharIndex = eChar_Line1px_TopLeft; //default
    switch(lineThickness) {
        case 1: topLeftCharIndex = eChar_Line1px_TopLeft; break;
        case 2: topLeftCharIndex = eChar_Line2px_TopLeft; break;
        default: AbortGame("Cannot render a rectangle of line thickness %d",lineThickness);
    }
    
    //top line
    int horizontalLineCharIndex = topLeftCharIndex+(eChar_Line1px_Top - eChar_Line1px_TopLeft);
    if (!topLine) { //bottom line
        horizontalLineCharIndex = topLeftCharIndex+(eChar_Line1px_Bottom - eChar_Line1px_TopLeft);
    }
   
    String renderedchar = String.Format("%c", textWindowConstants.specialCharAsciiCodes[horizontalLineCharIndex]);
    int charWidth = GetTextWidth(renderedchar, themes[1].font);
    int nbChars = width /charWidth;
    int additionalWhiteSpace = width - (nbChars*charWidth);
    String result = "";
    for (int i=0; i<nbChars; i++)
    {
        result = result.Append(renderedchar);
    }
    result = result.Append(GenerateWhiteSpaceAsChars(additionalWhiteSpace));
    return result;
}



String RenderText(String txt, DisplayGUIAlign align,  int width,  int cursorPosition)
{   
    if(StringUtil.IsNullOrEmpty(txt)) txt="";
        
    if (cursorPosition >=0) {
        if (txt.Length==0) {
            txt = String.Format("%c", textWindowConstants.specialCharAsciiCodes[eChar_Cursor]);
        } else if(cursorPosition >= txt.Length) {
            txt = txt.Append(String.Format("%c", textWindowConstants.specialCharAsciiCodes[eChar_Cursor])); 
        } else {
            //Display("txt=%s txt.Length=%d cursorPosition=%d txt.Length-cursorPosition=%d", txt,  txt.Length, cursorPosition, txt.Length-cursorPosition);
            String leftPart = txt.Truncate(cursorPosition);
            String rightPart = txt.Substring(cursorPosition,  txt.Length-cursorPosition);
            txt = String.Format("%s%c%s",leftPart, textWindowConstants.specialCharAsciiCodes[eChar_Cursor],  rightPart);
        }
    }
    
    
    Log(String.Format("RenderText: text=%s, align=%d, width=%d",txt, align, width));
    if (width<0)
        return "";
        
    
    int textWidth = GetTextWidth(txt, themes[1].font);
    while (textWidth > width) { //oops, the text doesn't fit. We'll remove characters one by one until it fits
        txt = txt.Truncate(txt.Length-1);
        textWidth = GetTextWidth(txt, themes[1].font);
    }
    
    //now, how many pixels do we need to fill with a white space?
    int totalWhiteSpace = width - textWidth;
    
    //how do we split this white pace depending on the alignment?
    int whiteSpaceLeft = 0;
    int whiteSpaceRight = totalWhiteSpace;
    
    if (align == eDisplayGUI_AlignLeft) {
        //nothing to do 
    } else if (align == eDisplayGUI_AlignRight) {
        whiteSpaceLeft = totalWhiteSpace;
        whiteSpaceRight = 0;
    } else if (align == eDisplayGUI_AlignCenter) {
        whiteSpaceLeft = totalWhiteSpace/2;
        whiteSpaceRight = totalWhiteSpace - whiteSpaceLeft;
    }
    else {
        AbortGame("unexpected value");
    }
    
    txt = String.Format("%s%s", GenerateWhiteSpaceAsChars(whiteSpaceLeft),  txt);
    txt = txt.Append(GenerateWhiteSpaceAsChars(whiteSpaceRight));
    
    return txt;
}


int min(int a,  int b) { if (a<b) return a; return b; }

//returns the actual blank space available
void DrawTextAt(String text, DisplayGUIAlign align,  int x_in_pixels,  int width,  int row_in_characters,  int cursorPosition) 
{    

    //Display("text=%s, x_in_pixels=%d, width=%d, row=%d", StringUtil.SafeDisplay(text),  x_in_pixels, width, row_in_characters);
    
    if (StringUtil.IsNullOrEmpty(text)) text="";
        
    //Basic safety measures
    if (row_in_characters < 0 || row_in_characters >= textWindowSettings.textWindowHeight_InChars) { 
        return; }
    
    if (x_in_pixels < 0) { x_in_pixels = 0; }
    if (x_in_pixels >= DisplayBasedGUI.GetWindowWidth_pixels())
        text="";
    //Slightly more advanced safety measure (truncate the text if it overflows on the right)

    
    String renderedText = RenderText(text,  align, width,   cursorPosition);
    int renderedWidth = GetTextWidth(renderedText,  themes[1].font); //should be equal to width!
    while ( x_in_pixels+renderedWidth > DisplayBasedGUI.GetWindowWidth_pixels() && text.Length > 0) {
        text = text.Truncate(text.Length-1);
        renderedText = RenderText(text,  align, DisplayBasedGUI.GetWindowWidth_pixels()-x_in_pixels, -1);
        renderedWidth = GetTextWidth(renderedText,  themes[1].font); //should be equal to width!
        //Display("text=%s, renderedT");
    }
    
    if (renderedText.Length==0)
    {
        //AbortGame("Text appears to be rendered outside of the screen?");
        return;
    }
    
    //Actual render.
    
    //looking for x pixel coordinate where actually starting (might make us erase more to the left than we wanted)
    int curXpx = 0;         //current pixel 
    int curColumn = 0;      //current column
    int startXpx=0;         //previous pixel (when looking for start)
    int startColumn=0;      //previous column (when looking for start)
    int endXpx=0;         //previous pixel (when looking for end)
    int endColumn=0;      //previous column (when looking for end)
    
    while (curColumn < textWindowSettings.textWindowWidth_InChars)
    {
        curXpx = GetTextWidth(String.Format("%s", screen[row_in_characters].Truncate(curColumn)), themes[1].font);
        if (curXpx > x_in_pixels) {
            break;
        }
        startXpx = curXpx;
        startColumn = curColumn;
        curColumn++;
    }
    
    curXpx = startXpx;
    curColumn = startColumn;
    while (curColumn < textWindowSettings.textWindowWidth_InChars)
    {
        curXpx = GetTextWidth(String.Format("%s", screen[row_in_characters].Truncate(curColumn)), themes[1].font);
        if (curXpx > x_in_pixels+renderedWidth) {
            endXpx = curXpx;
            endColumn = curColumn;
            break;
        }
        curColumn++;
    }
    
    String leftPart = screen[row_in_characters].Truncate(min(startColumn,  textWindowSettings.textWindowWidth_InChars));
    leftPart = leftPart.Append(GenerateWhiteSpaceAsChars(x_in_pixels - GetTextWidth(leftPart, themes[1].font)));
    
    String rightPart;
    if (startColumn>=endColumn)
        rightPart ="";
    else {
        rightPart = screen[row_in_characters].Substring(endColumn,  (screen[row_in_characters].Length)-endColumn); //-1 becaus elast character is [
        String whiteSpace = GenerateWhiteSpaceAsChars(endXpx - GetTextWidth(leftPart.Append(renderedText), themes[1].font));
        rightPart = whiteSpace.Append(rightPart);
    }

    //Display("leftPart='%s'", leftPart);


    screen[row_in_characters] = String.Format("%s%s%s", leftPart, renderedText, rightPart);
    //return endXpx - startXpx;    
}

String ControlTypeToText(TextControlsType type)
{
    switch (type) {
        case eDisplayGUI_TextControls_Button : return "button";
        case eDisplayGUI_TextControls_TextBox : return "textbox";
        case eDisplayGUI_TextControls_Label : return "label";
    }
    AbortGame("unknown type");
}


//returns the actual blank space available inbetween the sides (vertical lines) of the rectangle
int DrawRectangle(int left_InPixels,  int top_inRows, int width,  int thickness)
{
    if (thickness==0)
        return width;
        
    int topLeftCharIndex = eChar_Line1px_TopLeft; //default
    switch(thickness) {
        case 1: topLeftCharIndex = eChar_Line1px_TopLeft; break;
        case 2: topLeftCharIndex = eChar_Line2px_TopLeft; break;
        default: AbortGame("Cannot render a rectangle of line thickness %d",thickness);
    }
    
    //indices for ascii codes
    char topLeftChar            = textWindowConstants.specialCharAsciiCodes [topLeftCharIndex];
    char topRightChar           = textWindowConstants.specialCharAsciiCodes [topLeftCharIndex+(eChar_Line1px_TopRight     - eChar_Line1px_TopLeft)];
    char bottomLeftChar         = textWindowConstants.specialCharAsciiCodes [topLeftCharIndex+(eChar_Line1px_BottomLeft   - eChar_Line1px_TopLeft)];
    char bottomRightChar        = textWindowConstants.specialCharAsciiCodes [topLeftCharIndex+(eChar_Line1px_BottomRight  - eChar_Line1px_TopLeft)];
    char leftChar               = textWindowConstants.specialCharAsciiCodes [topLeftCharIndex+(eChar_Line1px_Left         - eChar_Line1px_TopLeft)];
    char rightChar              = textWindowConstants.specialCharAsciiCodes [topLeftCharIndex+(eChar_Line1px_Right        - eChar_Line1px_TopLeft)];
    
    int topLeftWidth = GetTextWidth(String.Format("%c",topLeftChar), themes[1].font);
    int topRightWidth = GetTextWidth(String.Format("%c",topRightChar), themes[1].font);
    int inbetweenWidth = width - topLeftWidth - topRightWidth;
            
    //Display("DrawRectangle : left=%d, top=%d, width=%d, inbetweenWidth=%d", left_InPixels,  top_inRows, width,  inbetweenWidth);
    
    for (int row=0; row<3; row++) 
    {
        String renderedRow;
        switch (row) {
            case 0 : renderedRow = String.Format("%c%s%c",topLeftChar, GenerateHorizontalLine(inbetweenWidth, true,   thickness), topRightChar ); break;
            case 1 : renderedRow = String.Format("%c%s%c",leftChar, GenerateWhiteSpaceAsChars(inbetweenWidth), rightChar ); break;
            case 2 : renderedRow = String.Format("%c%s%c",bottomLeftChar, GenerateHorizontalLine(inbetweenWidth, false,  thickness), bottomRightChar ); break;
            default : AbortGame("Not implemented");
        }
            
        DrawTextAt(renderedRow, eDisplayGUI_AlignLeft, left_InPixels, GetTextWidth(renderedRow,  themes[1].font), top_inRows+row, -1);
    }
    
    return inbetweenWidth;
    
}

/*
void DrawButton(TEXTCONTROL button)
{
    if (textControls[button].visible) {
        int thickness = 0;
        if (textControls[button].hasFocus) thickness = 2; else thickness = 1;
        if(String.IsNullOrEmpty(textControls[button].text)) textControls[button].text="";
        
        //Display("rendering control %d (%s) at row %d (left in pixels : %d)", button,  ControlTypeToText(textControls[button].type), textControls[button].top_inRows,  textControls[button].left_inPixels);     
        
        int inbetweenWidth = DrawRectangle(textControls[button].left_inPixels, textControls[button].top_inRows, textControls[button].width, thickness);
        inbetweenWidth--; //to compense rounding errors
        int inbetweenLeftOffset = (textControls[button].width - inbetweenWidth)/2; //-1 because of rounding errors
        DrawTextAt(textControls[button].text, textControls[button].align, textControls[button].left_inPixels+inbetweenLeftOffset, inbetweenWidth-1, textControls[button].top_inRows+1);
        
    }
}


void DrawTextBox(TEXTCONTROL textbox)
{
    Log(String.Format("Rendering textbox %d", textbox));
    
    if (textControls[textbox].visible) {         
        int thickness;
        

            
            
        for (int i=0; i<3; i++) {
            String renderedRow = RenderTextBox(textControls[textbox].text, textControls[textbox].width, i, textControls[textbox].align, thickness,  textControls[textbox].cursorPosition);
            DrawTextAt(renderedRow, eDisplayGUI_AlignLeft, textControls[textbox].left_inPixels, GetTextWidth(renderedRow,  themes[1].font), textControls[textbox].top_inRows+i);
        }
    }
}

*/

void DrawControl_Helper(String text, DisplayGUIAlign align,  int x_in_pixels,  int width,  int row_in_characters,  int thickness,  int cursorPosition)
{
        if(String.IsNullOrEmpty(text)) text="";

        int inbetweenWidth = DrawRectangle(x_in_pixels, row_in_characters, width, thickness);
        inbetweenWidth--; //to compense rounding errors
        int inbetweenLeftOffset = (width - inbetweenWidth)/2; 
        DrawTextAt(text, align, x_in_pixels+inbetweenLeftOffset, inbetweenWidth, row_in_characters+1, cursorPosition); //+1 because the text is at the 2nd line of the control
}


void DrawControl(TEXTCONTROL c)
{
    if (textControls[c].visible) {
        
        //custom settings for each control type
        int thickness = 0;
        int cursorPosition = -1;
        switch(textControls[c].type) {
            case eDisplayGUI_TextControls_Button : {
                if (textControls[c].hasFocus) thickness = 2; else thickness = 1;
                break;
            }
            case eDisplayGUI_TextControls_TextBox : {
                if (textControls[c].editable) {
                    if (textControls[c].hasFocus) thickness = 2; else thickness = 1;
                    if (textControls[c].editing) cursorPosition = textControls[c].cursorPosition;
                } else {
                    if (textControls[c].hasFocus) thickness = 2; else thickness = 0;
                }
                break;
            }
            case eDisplayGUI_TextControls_Label : {
                thickness=0;
                break;
            }
            default : AbortGame("unknown control type");
        }
        
        //generic rendering
        DrawControl_Helper(textControls[c].text, textControls[c].align, textControls[c].left_inPixels, textControls[c].width, textControls[c].top_inRows, thickness,  cursorPosition);
        

    }
}

void DrawControls()
{
    for (int c=0; c < textWindowSettings.nbClaimedControls; c++)
    {
        DrawControl(c);
    }
}

void ResetControl(TEXTCONTROL ctl)
{
    textControls[ctl].text              = "<no text>";
    textControls[ctl].type              = eDisplayGUI_TextControls_Label;
    textControls[ctl].left_inPixels     = 0;
    textControls[ctl].top_inRows        = 0;
    textControls[ctl].width             = 30;
    textControls[ctl].hasFocus          = false;
    textControls[ctl].align             = eDisplayGUI_AlignCenter;
    textControls[ctl].editing           = false;
    textControls[ctl].editable          = false;
    textControls[ctl].cursorPosition    = -1;
    textControls[ctl].clickable         = false;
    textControls[ctl].visible           = true;
       
}

void ResetAllControls()
{
    for (int c=0; c<MAXTEXTCONTROLS; c++) {
        ResetControl(c);
    }   
    textWindowSettings.nbClaimedControls = 0;
}
static TEXTCONTROL DisplayBasedGUI::ClaimControl(TextControlsType type)
{
    if (textWindowSettings.nbClaimedControls >= MAXTEXTCONTROLS) {
        AbortGame("Too many text-based controls (limit : %d). Increase MAXTEXTCONTROLS.", MAXTEXTCONTROLS);
    }
    
    ResetControl(textWindowSettings.nbClaimedControls);

    textControls[textWindowSettings.nbClaimedControls].type = type;
    
    if (type==eDisplayGUI_TextControls_Button)
        textControls[textWindowSettings.nbClaimedControls].clickable = true;
        
    textWindowSettings.nbClaimedControls++;
    return textWindowSettings.nbClaimedControls-1;
}


void SaveGameVariables()
{
    
    savedGameSettings.savedTopBarBorderColor = game.top_bar_bordercolor;
    savedGameSettings.savedTopBarBorderWidth = game.top_bar_borderwidth;
    savedGameSettings.savedTopBarFont = game.top_bar_font;
    
    savedGameSettings.savedNormalFont         = Game.NormalFont;
    savedGameSettings.savedMouseMode          = mouse.Mode;
    savedGameSettings.savedSkipStyle          = Speech.SkipStyle;
    savedGameSettings.savedWaitGraphic        = mouse.GetModeGraphic(eModeWait);
    savedGameSettings.savedPointerGraphic     = mouse.GetModeGraphic(eModePointer);
    savedGameSettings.savedUserMode1Graphic   = mouse.GetModeGraphic(eModeUsermode1);

}

void RestoreGameVariables()
{
    
    game.top_bar_bordercolor = savedGameSettings.savedTopBarBorderColor;
    game.top_bar_borderwidth = savedGameSettings.savedTopBarBorderWidth;
    game.top_bar_font = savedGameSettings.savedTopBarFont;
    
    Game.NormalFont = savedGameSettings.savedNormalFont;
    mouse.Mode = savedGameSettings.savedMouseMode ;
    Speech.SkipStyle = savedGameSettings.savedSkipStyle;
    mouse.ChangeModeGraphic(eModeWait,  savedGameSettings.savedWaitGraphic) ;
    mouse.ChangeModeGraphic(eModePointer,  savedGameSettings.savedPointerGraphic);
    mouse.ChangeModeGraphic(eModeUsermode1,  savedGameSettings.savedUserMode1Graphic);
}

void ApplyTemporaryGameVariables()
{
    mouse.Mode = eModeUsermode1;
    Speech.SkipStyle = eSkipKeyMouse;
    //mouse.ChangeModeGraphic(eModeWait, textWindowConstants.specialCursorGraphic);
    //mouse.ChangeModeGraphic(eModePointer, textWindowConstants.specialCursorGraphic);
    //mouse.ChangeModeGraphic(eModeUsermode1, textWindowConstants.specialCursorGraphic);
}

void ApplyThemeToGame()
{
    game.top_bar_bordercolor = themes[1].top_bar_bordercolor;
    game.top_bar_borderwidth = themes[1].top_bar_borderwidth;
    game.top_bar_font = themes[1].top_bar_font;
    
    Game.NormalFont = themes[1].font;
}

static void DisplayBasedGUI::FlipScreen()
{
    DrawControls();
    
    SaveGameVariables();
    ApplyTemporaryGameVariables();
    ApplyThemeToGame();
    
    
    if (textWindowSettings.displayTechnique == eDisplayGUI_usingBasicDisplay)
        Display(RenderScreen_AsString());
    else 
        DisplayTopBar(DisplayBasedGUI.GetWindowTop_pixels(true), themes[1].titleColor, themes[1].backColor,  StringUtil.SafeDisplay(textWindowSettings.title), RenderScreen_AsString());

    BlockingInput.UpdateInput(); //Do it here to make sure the mouse has the appearance that lets us detect it
    RestoreGameVariables();
}
    
void InitScreen()
{    
    screen = new String[textWindowSettings.textWindowHeight_InChars];
    ClearScreen();
}

void SetScreenDimensions(int width_InChars,  int height_InChars)
{
    if (width_InChars > 45) //You might want to adjust htis if using a different font or game resolution
        AbortGame("Text-based screen cannot be wider than %d pixels", 45*5);
     
    if (width_InChars%5!=0)
        AbortGame("Please choose a value that is a multiple of 5 (that's important for optimization in 'ClearScreen()')");

    if (height_InChars > 21) //You might want to adjust htis if using a different font or game resolution
        AbortGame("Text-based screen cannot be higher than 25 rows of characters");
        
    textWindowSettings.textWindowWidth_InChars = width_InChars;
    textWindowSettings.textWindowHeight_InChars = height_InChars;
    
    InitScreen();
    
}

static void DisplayBasedGUI::EnableDisableTheme(bool enabled)
{
    if (!enabled)
        textWindowSettings.displayTechnique = eDisplayGUI_usingBasicDisplay;
    else
        textWindowSettings.displayTechnique = eDisplayGUI_usingDisplayTopBar;
}


int CalculateRowHeight(FontType font)
{
        int fontHeight = 8; //todo : make it dynamic
        int spacing = 1;
        return fontHeight+spacing;
}

static void DisplayBasedGUI::InitSurface(String title,  int width_inChars,  int height_inChars,  FontType font)
{   
    //no value provided; keep the same as current
    if (font == -1)
        font = themes[1].font;
    else
        CheckFont(font); 
    textWindowSettings.rowHeight = CalculateRowHeight(font);
    
    textWindowSettings.title = title;

    SetScreenDimensions(width_inChars,  height_inChars);
    
    ResetAllControls();
}




//nbControls = number of buttons in the gui for which this is called
static TEXTCONTROL DisplayBasedGUI::FindControlAt(int x_on_screen,  int y_on_screen)
{    
    int left, right, down, top;
    bool themed = (textWindowSettings.displayTechnique==eDisplayGUI_usingDisplayTopBar);
    
    int windowTop_inPixels_underTitle = DisplayBasedGUI.GetWindowTop_pixels(themed);
    if (themed)
        windowTop_inPixels_underTitle += (textWindowSettings.rowHeight + 2*game.top_bar_borderwidth);
    
    //Display("topwindow (under title) = %d", windowTop_inPixels_underTitle);
    
    
    for (int i=0; i< textWindowSettings.nbClaimedControls; i++) {
        if (textControls[i].clickable) {
            left = DisplayBasedGUI.GetWindowLeft_pixels() + textControls[i].left_inPixels;
            right = DisplayBasedGUI.GetWindowLeft_pixels() + textControls[i].left_inPixels + textControls[i].width;
            top = windowTop_inPixels_underTitle + textControls[i].top_inRows * textWindowSettings.rowHeight;
            down = windowTop_inPixels_underTitle + (textControls[i].top_inRows+3)*textWindowSettings.rowHeight;
            /*
            if (themed)
            {
                top+= textWindowSettings.rowHeight;
                down+= textWindowSettings.rowHeight;
            }
            */
            //Display("nbButtons=%d, Comparing (%d, %d) to rectangle (%d, %d)-->(%d,%d) - top_in_rows=%d", textWindowSettings.nbClaimedControls,  x_on_screen,  y_on_screen,  left, top,  right,  down, textControls[i].top_inRows); //DEBUG
            
            if (   x_on_screen >= left
                && x_on_screen < right
                && y_on_screen >= top
                && y_on_screen < down ) 
            {
                //Display("control %d", i);
                return i;
            }
        }
    }
    
    return -1;
}



void CopyTheme(int source,  int dest)
{
    themes[dest].font                  = themes[source].font ;
    themes[dest].top_bar_bordercolor   = themes[source].top_bar_bordercolor;
    themes[dest].top_bar_borderwidth   = themes[source].top_bar_borderwidth;
    themes[dest].top_bar_font          = themes[source].top_bar_font;
    themes[dest].titleColor            = themes[source].titleColor;
    themes[dest].backColor             = themes[source].backColor;
}

static void DisplayBasedGUI::RestoreDefaultTheme() 
{
    CopyTheme(0, 1); //0 is default theme, 1 is custom theme (we implemented only one)
    
}


void DefaultInit_DisplayBasedGUI()
{
    //Font defaultFont = 0;
    
    InitConstants(); 
    InitDefaultTheme();
    
    DisplayBasedGUI.EnableDisableTheme(false);
    DisplayBasedGUI.RestoreDefaultTheme();
    
    //DisplayGUI.InitScreen(defaultFont);
    
    //textWindowConstants.specialCursorGraphic = 6; 
    //CheckCursor(textWindowConstants.specialCursorGraphic);
    
    
}

    

////////////////////////////////////////////////////////////////////
//
//
//          DISPLAY-BASED GUI
//
//
////////////////////////////////////////////////////////////////////



void game_start()
{
    DefaultInit_BlockingInput();
    
    DefaultInit_DisplayBasedGUI();
} �  ////////////////////////////////////////////////////////////////////
//
//
//          STRINGUTIL
//
//
////////////////////////////////////////////////////////////////////


struct StringUtil
{
import static String Trim(String s);
import static bool IsNullOrEmpty(String s);
import static String SafeDisplay(String s); 
};



////////////////////////////////////////////////////////////////////
//
//
//          BLOCKING INPUT
//
//
////////////////////////////////////////////////////////////////////

struct BlockingInput
{
    //To be called first after each major event (e.g. a call to "Display")
    import static void UpdateInput();
    import static void ClearInput();
    
    import static int GetMouseClick();
    
    import static int GetLastInput();
    import static bool IsLastInputCapital(); //returns true if the last input was a capital letter. False the rest of the time (small letter or anything else)

    import static int GetMouseX();
    import static int GetMouseY();
    
    
};




////////////////////////////////////////////////////////////////////
//
//
//          DISPLAY-BASED GUI
//
//
////////////////////////////////////////////////////////////////////

#define TEXTCONTROL int
#define MAXTEXTCONTROLS 30
enum TextControlsType
{
    eDisplayGUI_TextControls_Button = 0, 
    eDisplayGUI_TextControls_TextBox, 
    eDisplayGUI_TextControls_Label, 
};

enum DisplayTechnique {
    eDisplayGUI_usingBasicDisplay = 0, 
    eDisplayGUI_usingDisplayTopBar
};

struct DisplayBasedGUI
{
    
    //To be called once before any other function below
    //Warning : the font provided becomes Game.NormalFont
    import static void InitSurface(String title,  int width_inChars,  int height_inChars,  FontType font=-1);
    
    
    import static void EnableDisableTheme(bool enabled);
    
    //this will have no effect unless you've enabled TopBarDisplay rendering technique by calling DisplayGUI.SetDisplayTechnique();
    //Pro: it's prettier. Con: there's a blink when clicking or pressing a key
    import static void SetTheme(int titleColor,  int backColor,  int topBarBorderColor,  int topBarWidth,  FontType topBarFont);
    import static void SetTitle(String title);
    
    //Same as SetTheme but applies the shipped-in color scheme
    //this implicitly switches the display technique from eDisplayGUI_usingBasicDisplay to eDisplayGUI_usingDisplayTopBar
    //Pro: it's prettier. Con: there's a blink when clicking or pressing a key
    import static void RestoreDefaultTheme();

    
    import static int GetWindowTop_pixels(bool includeTitleBar);
    import static int GetWindowLeft_pixels();
    import static int GetWindowWidth_pixels();
    import static int GetWindowHeight_pixels(bool includeTitleBar);
    
    //After calling this, use textControls[result].property (where result is the method's TEXTCONTROL result and property is any property of TextControl struct)
    import static TEXTCONTROL ClaimControl(TextControlsType type);
    
    import static TEXTCONTROL FindControlAt(int x_on_screen,  int y_on_screen);
    
    import static void FlipScreen();
};


enum DisplayGUIAlign {
    eDisplayGUI_AlignLeft = 0, 
    eDisplayGUI_AlignCenter, 
    eDisplayGUI_AlignRight, 
};


struct TextControl
{
    TextControlsType type;
    
    int left_inPixels;
    int top_inRows;
    int width;
    String text;
    
    bool hasFocus;
    DisplayGUIAlign align; //text alignment
    
    //for an editable textbox
    bool editing;
    bool editable;
    int cursorPosition;
    
    //for textboxes and buttons
    bool clickable;
    
    bool visible;
    
};

import TextControl textControls[MAXTEXTCONTROLS]; �ߐ2        ej��