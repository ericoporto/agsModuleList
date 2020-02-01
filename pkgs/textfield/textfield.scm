AGSScriptModule    Snarky Text input field with a movable cursor Text Field 1.2.0 J  /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * TEXT FIELD MODULE - Script                                                              *
 * by Gunnar Harboe (Snarky), v1.2.0                                                       *
 *                                                                                         *
 * Copyright (c) 2018 Gunnar Harboe                                                        *
 *                                                                                         *
 *                                                                                         *
 * This code is offered under multiple licenses. Choose whichever one you like.            *
 *                                                                                         *
 * You may use it under the MIT license:                                                   *
 * https://opensource.org/licenses/MIT                                                     *
 *                                                                                         *
 * You may also use it under the Creative Commons Attribution 4.0 International License.   *
 * https://creativecommons.org/licenses/by/4.0/                                            *
 *                                                                                         *
 * You may also use it under the Artistic License 2.0                                      *
 * https://opensource.org/licenses/Artistic-2.0                                            *
 *                                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

TextField* _focusedTextField;
int _textFieldCount;
int _textFieldSize;
bool _handlesReturn;
int _blinkTimer;
int _blinkDelay=20;

bool _wasShiftPressed;

TextField* _textFields[];
String _textFieldTexts[];
Button* _textDisplayButtons[];
DynamicSprite* _textSprites[];
DynamicSprite* _borderSprites[];
DynamicSprite* _focusedTextSpriteCaret;

// Helper functions
bool IsShiftPressed()
{
  return IsKeyPressed(403) || IsKeyPressed(404);
}

String DeleteChar(this String*, int index)
{
  if(index == this.Length)
    return this.Truncate(this.Length-1);
  String s1 = this.Truncate(index-1);
  String s2 = this.Substring(index, this.Length - index);
  return s1.Append(s2);
}

String InsertChar(this String*, char c, int index)
{
  if(index == this.Length)
    return this.AppendChar(c);
    
  String s1 = this.Truncate(index);
  s1 = s1.AppendChar(c);
  String s2 = this.Substring(index, this.Length - index);
  return s1.Append(s2);
}

String InsertString(this String*, String s, int index)
{
  if(index == this.Length)
    return this.Append(s);
    
  String s1 = this.Truncate(index);
  s1 = s1.Append(s);
  String s2 = this.Substring(index, this.Length - index);
  return s1.Append(s2);
}

void resizeArrays(static TextField, int newSize)
{
  TextField* fields[] = new TextField[newSize];
  String texts[] = new String[newSize];
  Button* buttons[] = new Button[newSize];
  DynamicSprite* txtSprites[] = new DynamicSprite[newSize];
  DynamicSprite* brdSprites[] = new DynamicSprite[newSize];
  
  for(int i=0; i<_textFieldSize; i++)
  {
    fields[i] = _textFields[i];
    texts[i] = _textFieldTexts[i];
    buttons[i] = _textDisplayButtons[i];
    txtSprites[i] = _textSprites[i];
    brdSprites[i] = _borderSprites[i];
  }
  
  _textFields = fields;
  _textFieldTexts = texts;
  _textDisplayButtons = buttons;
  _textSprites = txtSprites;
  _borderSprites = brdSprites;
  
  _textFieldSize = newSize;
}

// Init
function game_start()
{
  TextField.resizeArrays(TEXTFIELD_DEFAULT_COUNT);
}


// Getters and Setters

//readonly attribute int ID;
int get_ID(this TextField*)
{
  // This is because the field is initialized to 0 by default, and we want that to be an illegal value
  // in order to require users to use TextField.Create()
  return this._id-1;
}

void _setId(this TextField*, int value)
{
  this._id = value;
}

bool _isValid(this TextField*)
{
  return this._id > 0;
}

void _setPaddingLeft(this TextField*, int value)
{
  this._paddingLeft = value;
}

void _setPaddingTop(this TextField*, int value)
{
  this._paddingTop = value;
}

// attribute int BorderTransparency;
int get_BorderTransparency(this TextField*)
{
  return this._borderTransparency;
}

void RenderBorder(this TextField*)
{
  int id = this.get_ID();
  DynamicSprite* sprite = _borderSprites[id];
  Button* displayButton = _textDisplayButtons[id];
  
  DrawingSurface* surface = sprite.GetDrawingSurface();
  surface.Clear();
  surface.DrawingColor = displayButton.TextColor;
  // Draw border
  int hbwd = TEXTFIELD_BORDER_WIDTH/2; // Half border width, rounded down
  int hbwu = (TEXTFIELD_BORDER_WIDTH+1)/2; // Half border width, rounded up
  surface.DrawLine(hbwd, hbwd, surface.Width, hbwd, TEXTFIELD_BORDER_WIDTH); // Top
  surface.DrawLine(hbwd, hbwd, hbwd, surface.Height, TEXTFIELD_BORDER_WIDTH); // Left
  surface.DrawLine(hbwd, surface.Height-hbwu, surface.Width, surface.Height-hbwu, TEXTFIELD_BORDER_WIDTH); // Bottom
  surface.DrawLine(surface.Width-hbwu, hbwd, surface.Width-hbwu, surface.Height, TEXTFIELD_BORDER_WIDTH); // Right
  surface.Release();
}

void RenderText(this TextField*)
{
  int id = this.get_ID();
  DynamicSprite* sprite = _textSprites[id];
  Button* displayButton = _textDisplayButtons[id];

  DrawingSurface* surface = sprite.GetDrawingSurface();
  surface.Clear();
  surface.DrawingColor = displayButton.TextColor;
  if(!String.IsNullOrEmpty(_textFieldTexts[id]))
    surface.DrawString(this._paddingLeft, this._paddingTop, displayButton.Font, _textFieldTexts[id]);
  surface.DrawImage(0, 0, _borderSprites[id].Graphic, this._borderTransparency);
  surface.Release();
}

void RenderFocusSprite(this TextField*)
{
  int id = this.get_ID();
  DynamicSprite* sprite = _textSprites[id];
  if(_focusedTextSpriteCaret != null)
    _focusedTextSpriteCaret.Delete();
  _focusedTextSpriteCaret = DynamicSprite.CreateFromExistingSprite(sprite.Graphic, true);
  DrawingSurface* surface = _focusedTextSpriteCaret.GetDrawingSurface();
  // Draw caret
  surface.DrawingColor = _textDisplayButtons[id].TextColor;
  surface.DrawLine(this._caretX - TEXTFIELD_CARET_WIDTH/2 + (TEXTFIELD_CARET_OFFSET_X),
                   this._caretY,
                   this._caretX - TEXTFIELD_CARET_WIDTH/2 + (TEXTFIELD_CARET_OFFSET_X),
                   this._caretY + GetFontHeight(_textDisplayButtons[id].Font),
                   TEXTFIELD_CARET_WIDTH);
  surface.Release();
  _textDisplayButtons[id].NormalGraphic = _focusedTextSpriteCaret.Graphic;
}

void set_BorderTransparency(this TextField*, int value)
{
  if(value<0) value=0;
  if(value>100) value=100;
  
  if(value != this._borderTransparency)
  {
    this._borderTransparency = value;
    this.RenderText();
    this.RenderFocusSprite();
  }
}

//static attribute bool HandlesReturn;
bool get_HandlesReturn(static TextField)
{
  return _handlesReturn;
}

void set_HandlesReturn(static TextField, bool value)
{
  _handlesReturn = value;
}

//static attribute int BlinkDelay
int get_BlinkDelay(static TextField)
{
  return _blinkDelay;
}

void set_BlinkDelay(static TextField, int value)
{
  _blinkDelay = value;
}

//readonly attribute Button* TextDisplayButton;
Button* get_TextDisplayButton(this TextField*)
{
  if(!this._isValid())
    return null;
  return _textDisplayButtons[this.get_ID()];
}

// attribute bool Enabled;
bool get_Enabled(this TextField*)
{
  return this._isValid() && _textDisplayButtons[this.get_ID()].Enabled;
}

void set_Enabled(this TextField*, bool value)
{
  if(!this._isValid())
    return;
    
  int id = this.get_ID();
  _textDisplayButtons[id].Enabled = value;
  if(!value)
  {
    if(_focusedTextField == this)
      _focusedTextField = null;
    _textDisplayButtons[id].NormalGraphic = _textSprites[id].Graphic;
  }
}

//readonly attribute bool HasFocus;
bool get_HasFocus(this TextField*)
{
  return (this == _focusedTextField);
}

bool SetFocus(this TextField*, bool giveFocus)
{
  if(!this.get_Enabled())
    return false;
  if(giveFocus)
  {
    if(_focusedTextField != this)
    {
      // Unfocus any other field that has focus
      if(_focusedTextField != null)
        _textDisplayButtons[_focusedTextField.get_ID()].NormalGraphic = _textSprites[_focusedTextField.get_ID()].Graphic;

      _focusedTextField = this;
      
      this.RenderFocusSprite();
      _textDisplayButtons[this.get_ID()].NormalGraphic = _focusedTextSpriteCaret.Graphic;
    }
    return true;
  }
  else if(_focusedTextField == this)
  {
    _focusedTextField = null;
    int id = this.get_ID();
    _textDisplayButtons[id].NormalGraphic = _textSprites[id].Graphic;
  }
  return false;
}

//static attribute TextField* Focused;
TextField* get_Focused(static TextField)
{
  return _focusedTextField;
}

void set_Focused(static TextField, TextField* value)
{
  value.SetFocus(true);
}

//attribute FontType Font;
FontType get_Font(this TextField*)
{
  if(!this._isValid())
    return 0;
  
  return _textDisplayButtons[this.get_ID()].Font;
}

void set_Font(this TextField*, FontType value)
{
  if(this._isValid())
  {
    int id = this.get_ID();
    _textDisplayButtons[id].Font = value;
    this.RenderText();
    if(this.get_HasFocus())
      this.RenderFocusSprite();
  }
}

//attribute int TextColor;
int get_TextColor(this TextField*)
{
  if(!this._isValid())
    return 0;
  
  return _textDisplayButtons[this.get_ID()].TextColor;
}

void set_TextColor(this TextField*, int value)
{
  if(this._isValid())
  {
    int id = this.get_ID();
    _textDisplayButtons[id].TextColor = value;
    this.RenderText();
    if(this.get_HasFocus())
      this.RenderFocusSprite();
  }
}

//attribute int MaxLength;
int get_MaxLength(this TextField*)
{
  return this._maxLength;
}

void set_MaxLength(this TextField*, int value)
{
  if(value<0)
    value=0;
  this._maxLength = value;
  int id = this.get_ID();
  if(value > 0 && _textFieldTexts[id] != null && _textFieldTexts[id].Length > value)
  {
    _textFieldTexts[id] = _textFieldTexts[id].Truncate(value);
  }
}

bool Activated(this TextField*)
{
  bool a = this._activated;
  this._activated = false;
  return a;
}

//attribute String Text;
String get_Text(this TextField*)
{
  if(this._isValid())
    return _textFieldTexts[this.get_ID()];
  else return null;
}

//attribute int CaretIndex;
int get_CaretIndex(this TextField*)
{
  return this._caretIndex;
}

void calculateCaretPos(this TextField*)
{
  String caretString = _textFieldTexts[this.get_ID()].Truncate(this._caretIndex);
  this._caretX = GetTextWidth(caretString, this.get_Font()) + this._paddingLeft;
  this._caretY = this._paddingTop;
}

void set_CaretIndex(this TextField*, int value)
{
  String txt = this.get_Text();
  if(txt == null)
  {
    this._caretIndex = 0;
    return;
  }
  if(value < 0)
    value = 0;
  if(value > txt.Length)
    value = txt.Length;
  if(value != this._caretIndex)
  {
    this._caretIndex = value;
    this.calculateCaretPos();
    this.RenderFocusSprite();
  }
}

void set_Text(this TextField*, String value)
{
  if(this._isValid())
  {
    if(value == null)
      value = "";
    if(this.get_MaxLength() > 0 && value.Length > this.get_MaxLength())
      value = value.Truncate(this.get_MaxLength());
    int id = this.get_ID();
    if(value != _textFieldTexts[id])
    {
      _textFieldTexts[id] = value;
      this.RenderText();
      if(this._caretIndex > value.Length)
        this.set_CaretIndex(value.Length);
      if(this.get_HasFocus())
        this.RenderFocusSprite();
    }
  }
}

bool PositionCaret(this TextField*, int x, int y)
{
  if(!this.get_Enabled())
    return false;
  
  // Get x,y relative to the string position
  int id = this.get_ID();
  Button* displayButton = _textDisplayButtons[id];
  int xOffset = displayButton.X + displayButton.OwningGUI.X + this._paddingLeft;
  int yOffset = displayButton.Y + displayButton.OwningGUI.Y + this._paddingTop;
  
  x = x - xOffset;
  if(x <= 0)
    this.set_CaretIndex(0);
  else for(int caretIndex = _textFieldTexts[id].Length; caretIndex>0; caretIndex--)
  {
    String caretString = _textFieldTexts[id].Truncate(caretIndex);
    int textWidth = GetTextWidth(caretString, _textDisplayButtons[id].Font);
    if(x >= textWidth)
    {
      this.set_CaretIndex(caretIndex);
      return true;
    }
  }
  this.set_CaretIndex(0);
  return true;
}


TextField* Create(static TextField, Button* textDisplay, String text, int paddingLeft, int paddingTop) //, Button* caretDisplay)
{
  // Must provide a button
  if(textDisplay == null)
    return null;
    
  // Increase array sizes if we go over
  if(_textFieldCount >= _textFieldSize)
  {
    TextField.resizeArrays(_textFieldSize*2);
  }
  
  if(text == null)
    text = textDisplay.Text;
  
  _textFieldCount++;
  TextField* newField = new TextField;
  newField._setId(_textFieldCount);
  newField._setPaddingLeft(paddingLeft);
  newField._setPaddingTop(paddingTop);
  
  int id = newField.get_ID();
  _textFields[id] = newField;
  _textDisplayButtons[id] = textDisplay;
  _textFieldTexts[id] = text;

  _borderSprites[id] = DynamicSprite.Create(textDisplay.Width, textDisplay.Height, true);
  newField.RenderBorder();
  _textSprites[id] = DynamicSprite.Create(textDisplay.Width, textDisplay.Height, true);
  newField.RenderText();
  textDisplay.NormalGraphic = _textSprites[id].Graphic;
  textDisplay.MouseOverGraphic = 0;
  textDisplay.PushedGraphic = 0;
  textDisplay.Text = "";
  
  newField.set_CaretIndex(text.Length);
  if(text.Length == 0)
    newField.calculateCaretPos();
  newField.set_Enabled(textDisplay.Enabled);
  return newField;
}

TextField* FindByDisplayButton(static TextField, Button* textDisplayButton)
{
  for(int i=0; i<_textFieldCount;i++)
  {
    if(_textDisplayButtons[i] == textDisplayButton)
      return _textFields[i];
  }
  return null;
}

TextField* FindByID(static TextField, int id)
{
  if(id>=0 && id<_textFieldCount)
    return _textFields[id];
  return null;
}


void UpdateDisplay(this TextField*)
{
  this.calculateCaretPos();
  this.RenderText();
  this.RenderFocusSprite();
}

bool HandleKeyPress(this TextField*, eKeyCode keycode)
{
  if(!this._isValid())
    return false;
  int id = this.get_ID();
  switch(keycode)
  {
    case eKeyCtrlC:
      #ifdef CLIPBOARD_PLUGIN
      Clipboard.CopyText(this.get_Text());
      return true;
      #endif
      #ifndef CLIPBOARD_PLUGIN
      return false;
      #endif
    case eKeyCtrlV:
    {
      #ifdef CLIPBOARD_PLUGIN
      String s = Clipboard.PasteText();
      if(!String.IsNullOrEmpty(s))
      {
        String newString = _textFieldTexts[id].InsertString(s, this._caretIndex);
        if(this.get_MaxLength() > 0 && newString.Length > this.get_MaxLength())
          newString = newString.Truncate(this.get_MaxLength());
        _textFieldTexts[id] = newString;
        this._caretIndex += s.Length;
        if(this._caretIndex > newString.Length)
          this._caretIndex = newString.Length;
        this.UpdateDisplay();
      }
      return true;
      #endif
      #ifndef CLIPBOARD_PLUGIN
      return false;
      #endif
    }
    case eKeyReturn:
      if(_handlesReturn)
      {
        this._activated = true;
        return true;
      }
      return false;
    case eKeyLeftArrow:
      this.set_CaretIndex(this._caretIndex-1);
      return true;
    case eKeyRightArrow:
      this.set_CaretIndex(this._caretIndex+1);
      return true;
    case eKeyBackspace:
      if(this._caretIndex>0)
      {
        _textFieldTexts[id] = _textFieldTexts[id].DeleteChar(this._caretIndex);
        this._caretIndex--;
        this.UpdateDisplay();
      }
      return true;
    case eKeyDelete:
      if(this._caretIndex < _textFieldTexts[id].Length)
      {
        _textFieldTexts[id] = _textFieldTexts[id].DeleteChar(this._caretIndex+1);
        this.RenderText();
        this.RenderFocusSprite();
      }
      return true;
    default:
      if(keycode >= 32 && keycode<256)
      {
        if(this.get_MaxLength() <= 0 || _textFieldTexts[id].Length < this.get_MaxLength())
        {
          // AGS always reports A-Z buttons as uppercase, so we check if (Shift XOR CapsLock) is off, and if so shift to the lowercase range
          if(keycode >= 'A' && keycode <= 'Z' && ((IsShiftPressed() || _wasShiftPressed ) == System.CapsLock))
            keycode += 32;  // 32 = 'a' - 'A'
          
          _textFieldTexts[id] = _textFieldTexts[id].InsertChar(keycode, this._caretIndex);
          this._caretIndex++;
          this.UpdateDisplay();
        }
        return true;
      }
  }
  return false;
}

function on_key_press(eKeyCode keycode) 
{
  if(_focusedTextField != null && _focusedTextField.get_Enabled())
  {
    if(_focusedTextField.HandleKeyPress(keycode))
      ClaimEvent();
  }
}

bool HandleMouseClick(this TextField*, MouseButton button)
{
  if(!this.get_Enabled())
    return false;
  switch(button)
  {
    case eMouseWheelNorth:
      // do nothing
      return true;
    case eMouseWheelSouth:
      // do nothing
      return true;
    case eMouseLeft:
    default:
      this.SetFocus();
      this.PositionCaret(mouse.x, mouse.y);
      return true;
  }
}

bool HandleMouseClickAny(static TextField, GUIControl* control, MouseButton button)
{
  Button* b = control.AsButton;
  if(b == null)
    return false;
  TextField* tf = TextField.FindByDisplayButton(b);
  if(tf == null)
    return false;
  return tf.HandleMouseClick(button);
}

function late_repeatedly_execute_always()
{
  // Because AGS only updates state every 1/40 seconds, the SHIFT key may already be released by the time we poll it.
  // By also including the previous cycle, we get better results
  _wasShiftPressed = IsShiftPressed();
  if(_blinkTimer == 0 && _focusedTextField != null && _focusedTextField.get_Enabled())
  {
    int id = _focusedTextField.get_ID();
    Button* displayButton = _textDisplayButtons[id];
    if(displayButton.NormalGraphic == _focusedTextSpriteCaret.Graphic)
      displayButton.NormalGraphic = _textSprites[id].Graphic;
    else
      displayButton.NormalGraphic = _focusedTextSpriteCaret.Graphic;
  }
  _blinkTimer++;
  _blinkTimer = _blinkTimer % _blinkDelay;
} k1  /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * TEXT FIELD MODULE - Header                                                              *
 * by Gunnar Harboe (Snarky), v1.2.0                                                       *
 *                                                                                         *
 * Copyright (c) 2018 Gunnar Harboe                                                        *
 *                                                                                         *
 *                                                                                         *
 * This module provides a one-line text input field, to replace the built-in AGS           *
 * TextInput control. Its main benefit is that it allows you to position the text cursor   *
 * (caret) freely within the input string, using either arrow keys or mouse. It also has   *
 * a notion of focus, which makes it easier to have GUIs with multiple text fields.        *
 * Finally, you can customize the appearance and behavior of the text fields somewhat.     *
 *                                                                                         *
 * To use, you have to set up a GUI Button for each text field you want. The position,     *
 * size, font, and text color of the button will be used to format the text field. Then    *
 * you have to initialize the text field using TextField.Create(), providing the GUI       *
 * button as an argument, like so:                                                         *
 *                                                                                         *
 *   TextField* myTextField = TextField.Create(myButton);                                  *
 *                                                                                         *
 * You would typically do this in game_start(), and in any case before the text field is   *
 * displayed. After you've created the text field, don't set the button properties         *
 * directly!                                                                               *
 *                                                                                         *
 * You also need to hook up the events. Because we lose the TextInput OnActivate event,    *
 * we have to handle activating the field (typically by pressing Return) a little          *
 * differently. There are two alternatives: You can handle it yourself in the game's       *
 * general on_key_press() function:                                                        *
 *                                                                                         *
 *   function on_key_press(eKeyCode keycode)                                               *
 *   {                                                                                     *
 *     if(keycode == eKeyReturn)                                                           *
 *     {                                                                                   *
 *       if(TextField.Focused == myTextField)                                              *
 *       {                                                                                 *
 *         // Activate                                                                     *
 *       }                                                                                 *
 *       else if(TextField.Focused == myOtherTextField)                                    *
 *       {                                                                                 *
 *         // Activate                                                                     *
 *       }                                                                                 *
 *       // ...                                                                            *
 *     }                                                                                   *
 *     else // handle other keys                                                           *
 *   }                                                                                     *
 *                                                                                         *
 * Or the module can handle it, by setting TextField.HandleReturn = true; but then you     *
 * have to check textField.Activated() each game cycle to see if it was activated:         *
 *                                                                                         *
 *   function repeatedly_execute_always()                                                  *
 *   {                                                                                     *
 *     if(myTextField.Activated())                                                         *
 *     {                                                                                   *
 *       // Activate                                                                       *
 *     }                                                                                   *
 *   }                                                                                     *
 *                                                                                         *
 * You should also link the button's OnClick() event to a function to handle clicks in     *
 * the text field. Default behavior (set focus and position the text cursor) is provided,  *
 * so you can just do:                                                                     *
 *                                                                                         *
 *   function myButton_OnClick(GUIControl *control, MouseButton button)                    *
 *   {                                                                                     *
 *     myTextField.HandleMouseClick(button);                                               *
 *   }                                                                                     *
 *                                                                                         *
 * Or, if you want a common function you can use for all the text fields:                  *
 *                                                                                         *
 *   function myTextFieldButtons_OnClick(GUIControl *control, MouseButton button)          *
 *   {                                                                                     *
 *     TextField.HandleMouseClickAny(control, button);                                     *
 *   }                                                                                     *
 *                                                                                         *
 *                                                                                         *
 * This code is offered under multiple licenses. Choose whichever one you like.            *
 *                                                                                         *
 * You may use it under the MIT license:                                                   *
 * https://opensource.org/licenses/MIT                                                     *
 *                                                                                         *
 * You may also use it under the Creative Commons Attribution 4.0 International License.   *
 * https://creativecommons.org/licenses/by/4.0/                                            *
 *                                                                                         *
 * You may also use it under the Artistic License 2.0                                      *
 * https://opensource.org/licenses/Artistic-2.0                                            *
 *                                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#define TEXTFIELD_DEFAULT_COUNT 4   // How many text fields are created by default. If you have many, increasing this number may slightly improve startup performance
#define TEXTFIELD_BORDER_WIDTH 1    // How wide the border of the text field is
#define TEXTFIELD_CARET_WIDTH 1     // How wide the text cursor/caret is
#define TEXTFIELD_CARET_OFFSET_X -1 // Used to position the caret correctly between characters (depends on font)

/// A replacement for the built-in TextInput control, allowing users to move the text cursor 
managed struct TextField
{
  // STATIC METHODS AND PROPERTIES
  
  /// Create a TextField from a button. Only TextFields created by this function are valid
  import static TextField* Create(Button* textDisplay, String text=0, int paddingLeft=0, int paddingTop=0); // $AUTOCOMPLETESTATICONLY$
  /// Get or set which TextField currently has focus. Null if none.
  import static attribute TextField* Focused;                                                               // $AUTOCOMPLETESTATICONLY$
  
  /// Get or set the delay between text cursor blinks (default 20 game cycles)
  import static attribute int BlinkDelay;                                                                   // $AUTOCOMPLETESTATICONLY$
  /// Get or set whether the TextFields handle the Return key, or pass it along to on_key_press()
  import static attribute bool HandlesReturn;                                                               // $AUTOCOMPLETESTATICONLY$

  /// Passes a mouse click on to the relevant TextField, and performs default behavior (give focus and set cursor position). Returns whether the click was handled. 
  import static bool HandleMouseClickAny(GUIControl *control, MouseButton button);                          // $AUTOCOMPLETESTATICONLY$
  
  /// Find the TextField associated with the provided button. Null if none.
  import static TextField* FindByDisplayButton(Button* textDisplayButton);                                  // $AUTOCOMPLETESTATICONLY$
  /// Find the TextField with the given ID. Null if none.
  import static TextField* FindByID(int id);                                                                // $AUTOCOMPLETESTATICONLY$
  
  // INSTANCE METHODS AND PROPERTIES
  
  /// Get the ID of this TextField
  import readonly attribute int ID;
  /// Get the Button that displays this text field
  import readonly attribute Button* TextDisplayButton;
  
  /// Get or set the text content of this TextField
  import attribute String Text;
  /// Get or set the font of this TextField
  import attribute FontType Font;
  /// Get or set the text color of this TextField (also used for the text cursor and border)
  import attribute int TextColor;
  /// Get or set the max String length of this TextField, 0 for unlimited (content will be truncated to MaxLength)
  import attribute int MaxLength;
  
  /// Get or set whether this TextField is currently enabled (can receive focus)
  import attribute bool Enabled;
  /// Get whether this TextField currently has focus
  import readonly attribute bool HasFocus;
  /// Get or set the current text cursor position, as a String index.
  import attribute int CaretIndex;
  
  /// Set whether this TextField should have focus. Returns whether focus was set.
  import bool SetFocus(bool giveFocus=true);
  /// Position the text cursor to the x,y position. Returns whether the cursor was positioned.
  import bool PositionCaret(int x, int y);
   
  /// Handle a keypress (default behavior: add/delete text input or move text cursor). Returns whether keypress was handled.
  import bool HandleKeyPress(eKeyCode keycode);
  /// Handle a mouse click (default behavior: give focus and set text cursor position). Returns whether mouse click was handled.
  import bool HandleMouseClick(MouseButton button);
  
  /// Whether the control was activated (Return pressed) since the last check. Will only return true once (until activated again).
  import bool Activated();
  /// The transparency the border is drawn with.
  import attribute int BorderTransparency;
  
  // Internal values
  protected int _id;
  protected int _paddingLeft;
  protected int _paddingTop;
  protected int _caretIndex;
  protected int _caretX;
  protected int _caretY;
  protected int _maxLength;
  protected bool _enabled;
  protected int _borderTransparency;
  protected bool _activated;
  
  
  // Input type as bit field (Numeric, Alphabetic, Alphanumeric, Text)
  
  // SelectionStart index
  // SelectionStart x
};
 �Ǎx        ej��