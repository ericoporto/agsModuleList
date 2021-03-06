AGSScriptModule    Khris Display WhatsApp-like Chat ChatDisplay 0.2 \/  // ChatDisplay script

DynamicSprite *CustomMessage(int chatWidth, Alignment align, String author, int hour, int minute, String text, FontType font) {
  
  // colors
  int leftColor = 2; // green
  int rightColor = 9; // blue
  int personColor = 29; // light grey
  int messageColor = 15; // white
  int messageShadowColor = 21; // dark grey
    
  // margin
  int margin = 2;
  // bubble padding
  int padding = 3;
  int tr = 2; // corner triangle size
  int str = 4; // speech triangle size
  
  // text
  int textWidth = (chatWidth * 70) / 100;
  int bubbleTextWidth = textWidth;
  int textHeight = GetTextHeight(text, font, textWidth);
  int lineHeight = GetTextHeight("M", font, 100);
  if (lineHeight == textHeight) bubbleTextWidth = GetTextWidth(text, font) + 2;
  int x = margin + padding + str;
  int bgColor = leftColor;
  if (align == eAlignRight) {
    x = chatWidth - bubbleTextWidth - (margin + padding + str) - 1;
    bgColor = rightColor;
  }
  int y = margin;
  // y of lower end of message text

  DynamicSprite *messageSprite = DynamicSprite.Create(chatWidth, lineHeight + textHeight + padding * 2 + margin * 3 + 1);
  DrawingSurface *ds = messageSprite.GetDrawingSurface();
  
  // author
  ds.DrawingColor = personColor;
  ds.DrawStringWrapped(margin + str, y, chatWidth - (margin + str) * 2, font, align, String.Format("//%s %02d:%02d", author, hour, minute));
  
  y += lineHeight + margin + padding;
  
  // bubble
  // outer box
  int x1 = x - padding, x2 = x + bubbleTextWidth + padding;
  int y1 = y - padding, y2 = y + textHeight + padding;
  ds.DrawingColor = bgColor;
  ds.DrawRectangle(x1, y1, x2, y2);
  // add speech triangle
  if (align == eAlignLeft) ds.DrawTriangle(x1 - str, y2, x1, y2, x1, y2 - str);
  else ds.DrawTriangle(x2, y2, x2 + str, y2, x2, y2 - str); 
  
  // cut corners
  ds.DrawingColor = COLOR_TRANSPARENT;
  // top left
  ds.DrawTriangle(x1, y1, x1 + tr, y1, x1, y1 + tr);
  // top right
  ds.DrawTriangle(x2, y1, x2 - tr, y1, x2, y1 + tr);
  // bottom corner
  if (align == eAlignRight) ds.DrawTriangle(x1, y2, x1 + tr, y2, x1, y2 - tr);
  else ds.DrawTriangle(x2,  y2,  x2 - tr, y2, x2, y2 - tr); 
  
  // text
  ds.DrawingColor = messageShadowColor;
  ds.DrawStringWrapped(x, y + 1, bubbleTextWidth, font, align, text);
  ds.DrawingColor = messageColor;
  ds.DrawStringWrapped(x, y, bubbleTextWidth, font, align, text);
  ds.Release();
  return messageSprite;
}

struct Message {
  int chatID;
  String text;
  String author;
  int hour,  minute;
  DynamicSprite *ms;
};

struct ChatWindow {
  Button *button;
  int width, height;
  FontType font;
  int bgSlot;
  int messages;
  int messagesPosted;
  DynamicSprite *allSprites;
  // number of pixels hidden at the top
  float scrollY, targetScrollY;
  float scrollMin, scrollMax;
  DynamicSprite *currentView;
  AudioClip *sound;
  import void Update();
};

Message message[MAX_CHAT_MESSAGES];
ChatWindow chatWindow[MAX_CHATS];

int chatWindows = 0;
int messages = 0;

int chat_messages_displayed[MAX_CHATS];
int chat_used_height[MAX_CHATS];
DynamicSprite *chatSprite[MAX_CHATS];

void game_start() {
  for (int i = 0; i < MAX_CHAT_MESSAGES; i++) message[i].chatID = -1; // mark all messages as unused
}

DynamicSprite *DrawMessage(int messageID) {
  int m = messageID;
  int c = message[m].chatID;
  Alignment align = eAlignLeft;
  String author = message[m].author;
  if (message[m].author.Chars[0] == '*') {
    align = eAlignRight;
    author = message[m].author.Substring(1, author.Length - 1);
  }  
  return CustomMessage(chatWindow[c].width, align, author, message[m].hour, message[m].minute, message[m].text, chatWindow[c].font);
}

DynamicSprite *DrawChat(int chatID) {
  int postedHeight = 0; // chatWindow[chatID].height; // start out with blank window
  int messageCount = 0;
  for (int i = 0; i < messages; i++) {
    if (message[i].chatID == chatID) {
      if (messageCount < chatWindow[chatID].messagesPosted) {
        if (message[i].ms == null) message[i].ms = DrawMessage(i);
        postedHeight += message[i].ms.Height;
        messageCount++;
      }
    }
  }  
  chatSprite[chatID] = DynamicSprite.Create(chatWindow[chatID].width, postedHeight, false);
  DrawingSurface *ds = chatSprite[chatID].GetDrawingSurface();
  int mY = 0;
  if (mY < 0) mY = 0;
  messageCount = 0;
  for (int i = 0; i < messages; i++) {
    if (message[i].chatID == chatID) {
      if (messageCount < chatWindow[chatID].messagesPosted) {
        ds.DrawImage(0, mY, message[i].ms.Graphic);
        mY += message[i].ms.Height;
        messageCount++;
      }
    }
  }
  ds.Release();
  return chatSprite[chatID];
}

static int Chat::Create(Button *button, FontType font, int bgSlot, int width, int height) {
  chatWindow[chatWindows].button = button;
  if (width == 0) width = button.Width;
  if (height == 0) height = button.Height;
  chatWindow[chatWindows].width = width;
  chatWindow[chatWindows].height = height;
  chatWindow[chatWindows].font = font;
  chatWindow[chatWindows].bgSlot = bgSlot;
  chatWindow[chatWindows].allSprites = DrawChat(chatWindows);
  float scrollY = IntToFloat(-height);
  chatWindow[chatWindows].scrollY = scrollY;
  chatWindow[chatWindows].targetScrollY = scrollY;
  chatWindow[chatWindows].scrollMin = scrollY;
  chatWindow[chatWindows].scrollMax = scrollY;
  chatWindows++;
  return chatWindows - 1;
}

static void Chat::SetSound(int c, AudioClip *sound) {
  chatWindow[c].sound = sound;
}

void SetScrollTarget(int c, float newY) {
  int msH = chatWindow[c].allSprites.Height;
  int cwH = chatWindow[c].height;
  // if scrolling isn't possible yet
  if (msH <= cwH) {
    chatWindow[c].targetScrollY = IntToFloat(msH - cwH);
    return;
  }
  // scrolling is possible
  chatWindow[c].scrollMin = 0.0;
  chatWindow[c].scrollMax = IntToFloat(msH - cwH);
  if (newY < chatWindow[c].scrollMin) newY = chatWindow[c].scrollMin;
  if (newY > chatWindow[c].scrollMax) newY = chatWindow[c].scrollMax;
  chatWindow[c].targetScrollY = newY;
}

static String Chat::GetLastMessage(int c) {
  int messageCount = 0;
  for (int i = 0; i < messages; i++) {
    if (message[i].chatID == c) {
      if (messageCount + 1 == chatWindow[c].messagesPosted) {
        return message[i].text;
      }
      messageCount++;
    }
  }
  return null;
}

static String Chat::GetNextMessage(int c) {
  int messageCount = 0;
  for (int i = 0; i < messages; i++) {
    if (message[i].chatID == c) {
      if (messageCount == chatWindow[c].messagesPosted) {
        return message[i].text;
      }
      messageCount++;
    }
  }
  return null;
}

static bool Chat::Prepare(int c, String text, String author, int hour, int minute) {
  int free = messages;
  for (int i = 0; i < messages; i++) {
    if (message[i].chatID == -1) {
      free = i;
      i = messages;
    }
  }
  if (free == MAX_CHAT_MESSAGES) return false;
  
  if (hour == -1) {
    DateTime *dt = DateTime.Now;
    hour = dt.Hour;
    minute = dt.Minute;
  }
  
  message[messages].chatID = c;
  message[messages].text = GetTranslation(text);
  message[messages].author = author;
  message[messages].hour = hour;
  message[messages].minute = minute;
  message[messages].ms = null;
  chatWindow[c].messages++;
  messages++;
  return true;
}

static bool Chat::Advance(int c) {
  if (chatWindow[c].messagesPosted == chatWindow[c].messages) return false;
  chatWindow[c].messagesPosted++;
  // update sprite containing all messages
  chatWindow[c].allSprites = DrawChat(c);
  SetScrollTarget(c, IntToFloat(chatWindow[c].allSprites.Height - chatWindow[c].height));
  if (chatWindow[c].sound != null) chatWindow[c].sound.Play(eAudioPriorityLow);
  return true;
}

static bool Chat::ShowAllPrepared(int c) {
  AudioClip *sound = chatWindow[c].sound;
  chatWindow[c].sound = null;
  while (Chat.GetNextMessage(c) != null) Chat.Advance(c);
  chatWindow[c].sound = sound;
}

static bool Chat::Add(int c, String text, String author, int hour, int minute) {
  Chat.Prepare(c, text, author, hour, minute);
  Chat.Advance(c);
}

DynamicSprite *scrollBar;

void UpdateChatWindow(int c) {
  chatWindow[c].allSprites = DrawChat(c);
  if (chatWindow[c].currentView == null) chatWindow[c].currentView = DynamicSprite.Create(chatWindow[c].width, chatWindow[c].height);
  DrawingSurface *ds = chatWindow[c].currentView.GetDrawingSurface();
  // draw background
  int bgSlot = chatWindow[c].bgSlot;
  if (bgSlot == 0) ds.Clear(0);
  else {
    for (int x = 0; x < chatWindow[c].width; x += Game.SpriteWidth[bgSlot])
      for (int y = 0; y < chatWindow[c].height; y += Game.SpriteHeight[bgSlot])
        ds.DrawImage(x, y, bgSlot);
  }
  // scroll view
  float distance = chatWindow[c].targetScrollY - chatWindow[c].scrollY;
  bool showScrollBar = true;
  if (-1.5 < distance && distance < 1.5) {
    chatWindow[c].scrollY = chatWindow[c].targetScrollY;
    showScrollBar = false;
  }
  else chatWindow[c].scrollY += distance * 0.2;
  int cropY = FloatToInt(chatWindow[c].scrollY, eRoundNearest);
  ds.DrawImage(0, -cropY, chatWindow[c].allSprites.Graphic);
  
  // draw scroll bar?
  float winHeight = IntToFloat(chatWindow[c].height);
  float fraction = winHeight / (IntToFloat(chatWindow[c].allSprites.Height) + 0.1);
  if (showScrollBar && fraction < 1.0) {
    float barHeight = winHeight * fraction;
    float barY = winHeight - fraction * (chatWindow[c].scrollMax - chatWindow[c].scrollY);
    ds.DrawingColor = 15;
    int x1 = chatWindow[c].width - 5;
    int y1 = FloatToInt(barY - barHeight, eRoundNearest) + 1;
    int x2 = chatWindow[c].width - 2;
    int y2 = FloatToInt(barY, eRoundNearest) - 1;
    
    if (scrollBar == null) scrollBar = DynamicSprite.Create(x2 - x1 + 1, y2 - y1 + 1);
    else scrollBar.Resize(x2 - x1 + 1, y2 - y1 + 1);
    DrawingSurface *sds = scrollBar.GetDrawingSurface();
    sds.Clear(15);
    sds.DrawingColor = COLOR_TRANSPARENT;
    sds.DrawPixel(0, 0); sds.DrawPixel(sds.Width - 1, 0); sds.DrawPixel(0, sds.Height - 1); sds.DrawPixel(sds.Width - 1, sds.Height - 1);
    sds.Release();
    ds.DrawImage(x1, y1, scrollBar.Graphic, 50);
  }
    
  ds.Release();
  chatWindow[c].button.NormalGraphic = chatWindow[c].currentView.Graphic;
}

static void Chat::Clear(int c) {
  for (int i = 0; i < messages; i++) {
    if (message[i].chatID == c) {
      if (message[i].ms != null)  message[i].ms.Delete();
      message[i].chatID = -1;
    }
  }
  if (chatWindow[c].allSprites != null) {
    chatWindow[c].allSprites.Delete();
    chatWindow[c].allSprites = null;
  }
  if (chatWindow[c].currentView != null) {
    chatWindow[c].currentView.Delete();
    chatWindow[c].currentView = null;
  }
  chatWindow[c].messages = 0;
  chatWindow[c].messagesPosted = 0;
}

static void Chat::CleanUp() {
  for (int i = 0; i < messages; i++) {
    if (message[i].ms != null) message[i].ms.Delete();
  }
  for (int i = 0; i < MAX_CHATS; i++) {
    Chat.Clear(i);
  }
  if (scrollBar != null) scrollBar.Delete();
}

void repeatedly_execute_always() {
  Button *b;
  for (int i = 0; i < MAX_CHATS; i++) {
    b = chatWindow[i].button;
    if (b != null && b.OwningGUI.Visible && b.Visible) UpdateChatWindow(i);
  }
}

void on_mouse_click(MouseButton button) {
  if (button != eMouseWheelNorth && button != eMouseWheelSouth) return;
  GUIControl *control = GUIControl.GetAtScreenXY(mouse.x, mouse.y);
  if (control == null) return;
  Button *btn = control.AsButton;
  if (btn == null) return;
  int scrolledChatID = -1;
  for (int i = 0; i < MAX_CHATS; i++) {
    if (chatWindow[i].button == btn) scrolledChatID = i;
  }
  if (scrolledChatID == -1) return;
  ClaimEvent();
  float currentScrollY = chatWindow[scrolledChatID].scrollY;
  if (button == eMouseWheelNorth) currentScrollY -= 50.0;
  else currentScrollY += 50.0;
  SetScrollTarget(scrolledChatID, currentScrollY); 
}
 >  // ChatDisplay header

#define MAX_CHAT_MESSAGES 100 // total messages added to chats
#define MAX_CHATS 10 // maximum simultaneous chats

struct Chat {
  import static int Create(Button *button, FontType font, int bgSlot = 0, int width = 0, int height = 0);
  import static void SetSound(int chatID, AudioClip *sound);
  import static bool Prepare(int chatID, String text, String author, int hour = -1, int minute = 0);
  import static String GetLastMessage(int chatID);
  import static String GetNextMessage(int chatID);
  import static bool Advance(int chatID);
  import static bool ShowAllPrepared(int chatID);
  import static bool Add(int chatID, String text, String author, int hour = -1, int minute = 0);
  import static void Clear(int chatID);
  import static void CleanUp();
  import Character *ac();
};
 y��        ej��