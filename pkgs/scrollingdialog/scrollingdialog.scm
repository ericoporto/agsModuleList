AGSScriptModule    monkey0506 Custom dialog rendering and stuff, including scrolling dialogs. ScrollingDialog 3.0 |�  
struct ScrollingDialogDefs_t // local definitions (hidden/protected things, nested pointers, and internal properties)
{
  DynamicSprite *Background; // dialog background sprite (background graphics and border decos) (created in dialog_options_get_dimensions)
  DialogBorderDecoration BackgroundBorderDecoration; // border decoration graphics for background
  Padding_t BulletPadding; // padding for dialog bullet
  DialogOption DialogOptions[]; // all instances of DialogOption (see "optionIndex" for owning dialogs)
  bool DidMouseClick; // listening for a mouse-up event in dialog_rep_exec
  DialogArrow DownArrow; // scroll down arrow
  Padding_t DownArrowPadding; // padding for down arrow
  int DrawnOptionCount; // options that are actually drawn at time of rendering
  int FirstDrawnOption; // first option (index to ShownOptions) that is drawn
  DynamicSprite *Foreground; // dialog foreground sprite (text, bullets, and scroll arrows) (created in dialog_options_get_dimensions)
  int OptionY[]; // Y position of options, indexed by option ID (should be -1 for non-drawn options)
  int OptionsX; // X position of drawn options (visual output of course depends on alignment as well)
  int OptionsWidth; // the available width for drawing dialog options
  int OptionsYMax; // the max Y position of drawn dialog options
  int OptionsMaxWidth; // the maximum amount of width required for drawing options (used by autosize)
  DialogOptionsRenderingInfo *RunningDialog; // currently running dialog info
  int ShownOptionCount; // number of options that are eOptionOn at time of rendering
  int ShownOptions[]; // actual options that are eOptionOn at rendering, zero-indexed array of option IDs
  int TagCapacity; // capacity for dialog tags
  int TagCount; // used dialog tags
  String Tags[]; // dialog tags
  String TagResult[]; // result of dialog tag replacement
  DialogArrow UpArrow; // scroll up arrow
  Padding_t UpArrowPadding; // padding for up arrow
};

ScrollingDialog_t ScrollingDialog;
export ScrollingDialog;
ScrollingDialogDefs_t ScrollingDialogDefs;

// ScrollingDialog_t accessors

int get_Height(this ScrollingDialog_t*)
{
  return this.height;
}

void set_Height(this ScrollingDialog_t*, int value)
{
  value = Maths.MaxInt(1, value);
  this.height = value;
  if (value < this.minHeight)
  {
    this.minHeight = value;
  }
}

int get_LineSpacing(this ScrollingDialog_t*)
{
  return GetGameOption(OPT_DIALOGOPTIONSGAP);
}

void set_LineSpacing(this ScrollingDialog_t*, int value)
{
  SetGameOption(OPT_DIALOGOPTIONSGAP, value);
}

int get_MinHeight(this ScrollingDialog_t*)
{
  return this.minHeight;
}

void set_MinHeight(this ScrollingDialog_t*, int value)
{
  value = Maths.MaxInt(1, value);
  this.minHeight = value;
  if (value > this.height)
  {
    this.height = value;
  }
}

int get_MinWidth(this ScrollingDialog_t*)
{
  return this.minWidth;
}

void set_MinWidth(this ScrollingDialog_t*, int value)
{
  value = Maths.MaxInt(1, value);
  this.minWidth = value;
  if (value > this.width)
  {
    this.width = value;
  }
}

bool get_OptionsGoUpwards(this ScrollingDialog_t*)
{
  return (GetGameOption(OPT_DIALOGUPWARDS) != 0);
}

void set_OptionsGoUpwards(this ScrollingDialog_t*, bool value)
{
  SetGameOption(OPT_DIALOGUPWARDS, value != false);
}

DialogOptionNumberStyle get_OptionsNumberStyle(this ScrollingDialog_t*)
{
  return (GetGameOption(OPT_DIALOGNUMBERED) + 1);
}

void set_OptionsNumberStyle(this ScrollingDialog_t*, DialogOptionNumberStyle value)
{
  SetGameOption(OPT_DIALOGNUMBERED, value - 1);
}

String get_PlayerNameTag(this ScrollingDialog_t*)
{
  return this.playerNameTag;
}

void set_PlayerNameTag(this ScrollingDialog_t*, String value)
{
  this.playerNameTag = value;
}

void set_SelectedOption(this ScrollingDialog_t*, DialogOption value)
{
  this.SelectedOption = value;
}

int get_TextColorActive(this ScrollingDialog_t*)
{
  return game.dialog_options_highlight_color;
}

void set_TextColorActive(this ScrollingDialog_t*, int value)
{
  game.dialog_options_highlight_color = value;
}

int get_TextColorChosen(this ScrollingDialog_t*)
{
  return game.read_dialog_option_color;
}

void set_TextColorChosen(this ScrollingDialog_t*, int value)
{
  game.read_dialog_option_color = value;
}

int get_TopOption(this __ScrollableDialog_t*)
{
  return this.topOption;
}

void set_TopOption(this __ScrollableDialog_t*, int value)
{
  this.topOption = Maths.MaxInt(1, Maths.MinInt(dialog[this.id].OptionCount, value));
}

int get_TopOption(this ScrollingDialog_t*)
{
  if (ScrollingDialogDefs.RunningDialog == null)
  {
    return 0;
  }
  return this.Dialogs[ScrollingDialogDefs.RunningDialog.DialogToRender.ID].get_TopOption();
}

void set_TopOption(this ScrollingDialog_t*, int value)
{
  if (ScrollingDialogDefs.RunningDialog == null)
  {
    return;
  }
  this.Dialogs[ScrollingDialogDefs.RunningDialog.DialogToRender.ID].set_TopOption(value);
}

int get_Width(this ScrollingDialog_t*)
{
  return this.width;
}

void set_Width(this ScrollingDialog_t*, int value)
{
  value = Maths.MaxInt(1, value);
  this.width = value;
  if (value < this.minWidth)
  {
    this.minWidth = value;
  }
}

// __ScrollableDialog_t Options accessor is required for ScrollingDialog.RunOption

DialogOption geti_Options(this __ScrollableDialog_t*, int index)
{
  if ((index <= 0) || (index > dialog[this.id].OptionCount))
  {
    return null;
  }
  return ScrollingDialogDefs.DialogOptions[this.optionIndex + (index - 1)];
}

// ScrollingDialog.RunOption invokes the dialog option script for the specified option
// ScrollingDialog.SelectedOption is set here to allow using "player.Say(ScrollingDialog.SelectedOption.Text);"
// from the dialog script

void RunOption(this ScrollingDialog_t*, int option)
{
  if (ScrollingDialogDefs.RunningDialog == null)
  {
    return;
  }
  this.SelectedOption = this.Dialogs[ScrollingDialogDefs.RunningDialog.DialogToRender.ID].geti_Options(option);
  ScrollingDialogDefs.RunningDialog.ActiveOptionID = option;
  ScrollingDialogDefs.RunningDialog.RunActiveOption();
}

// Helper for ScrollingDialog.ScrollUp and ScrollingDialog.ScrollDown
// "up" and "down" are inverted if dialog options are drawn upwards

void Scroll(this ScrollingDialog_t*, Dialog *dlg, bool up)
{
  if (up)
  {
    if (ScrollingDialogDefs.FirstDrawnOption > 0) // first drawn option isn't first that is turned on
    {
      // set the TopOption to the previous option that is turned on
      // GUI is updated the next time it is rendered
      this.Dialogs[dlg.ID].set_TopOption(
        ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption - 1]);
    }
  }
  else
  {
    // the last drawn option isn't the last that is turned on
    if ((ScrollingDialogDefs.FirstDrawnOption + ScrollingDialogDefs.DrawnOptionCount) <
      ScrollingDialogDefs.ShownOptionCount)
    {
      // set the TopOption to the next option that is turned on
      // GUI is updated the next time it is rendered
      this.Dialogs[dlg.ID].set_TopOption(
        ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + 1]);
    }
  }
}

// ScrollingDialog scroll functions

void ScrollDown(this ScrollingDialog_t*, Dialog *dlg)
{
  if (dlg == null)
  {
    return;
  }
  this.Scroll(dlg, ScrollingDialog.get_OptionsGoUpwards());
}

void ScrollUp(this ScrollingDialog_t*, Dialog *dlg)
{
  if (dlg == null)
  {
    return;
  }
  this.Scroll(dlg, !ScrollingDialog.get_OptionsGoUpwards());
}

// Helper to find or add a dialog tag

int FindOrAddTag(this ScrollingDialogDefs_t*, String tag)
{
  if (String.IsNullOrEmpty(tag) || (tag == ScrollingDialog.get_PlayerNameTag()))
  {
    // don't allow adding null or empty tags, or duplicating the PlayerNameTag
    return -1;
  }
  for (int i = 0; i < this.TagCount; i++)
  {
    if (this.Tags[i] == tag) // if the tag is already registered, return its ID
    {
      return i;
    }
  }
  // otherwise, we need to add a new tag
  int result = this.TagCount; // ID of the new tag
  this.TagCount++; // update tag count
  if (this.TagCount > this.TagCapacity) // if we've exceeded the current capacity, grow the capacity
  {
    if (this.TagCapacity == 0) // grow to 1 if none
    {
      this.TagCapacity = 1;
    }
    else // grow to double on resize
    {
      this.TagCapacity *= 2;
    }
    String tags[] = new String[this.TagCapacity];
    String tagResult[] = new String[this.TagCapacity];
    for (int i = 0; i < result; i++)
    {
      tags[i] = this.Tags[i];
      tagResult[i] = this.TagResult[i];
    }
    tags[result] = tag;
    this.Tags = tags;
    this.TagResult = tagResult;
  }
  // return the newly added tag's ID
  return result;
}

// ScrollingDialog, Set or add a dialog tag

void ScrollingDialog_t::SetTag(String tag, String value)
{
  int tagID = ScrollingDialogDefs.FindOrAddTag(tag);
  if (tagID == -1) // invalid tag name
  {
    return;
  }
  if (value == null) // don't try to replace the tag with null, assume empty String
  {
    value = "";
  }
  ScrollingDialogDefs.TagResult[tagID] = value;
}

// ScrollingDialogDefs helper function to get the modified dialog text for the specified option
// May include option numbering, and dialog tags are replaced

import String GetText(this ScrollingDialogDefs_t*, Dialog *dlg, int option, bool includeNumber, int shownOptionID=SCR_NO_VALUE);

String GetText(this ScrollingDialogDefs_t*, Dialog *dlg, int option, bool includeNumber, int shownOptionID)
{
  if ((dlg == null) || (option < 1) || (option > dlg.OptionCount))
  {
    // invalid parameters
    return null;
  }
  String text = dlg.GetOptionText(option); // get the raw text as set up in the editor
  for (int i = 0; i < this.TagCount; i++)
  {
    text = text.Replace(this.Tags[i], this.TagResult[i]); // replace all dialog tags with their result
  }
  String playerNameTag = ScrollingDialog.get_PlayerNameTag();
  if (!String.IsNullOrEmpty(playerNameTag)) // if PlayerNameTag exists
  {
    text = text.Replace(playerNameTag, player.Name); // replace PlayerNameTag with CURRENT player name
  }
  if ((includeNumber) && (ScrollingDialog.get_OptionsNumberStyle() == eDialogOptionNumbersDrawn)) // if need numbering
  {
    if ((shownOptionID == SCR_NO_VALUE) || (shownOptionID < 0) || (shownOptionID >= this.ShownOptionCount))
    {
      // find number if not known (based on options that are eOptionOn in this dialog)
      for (int i = 0; i < this.ShownOptionCount; i++)
      {
        if (this.ShownOptions[i] == option)
        {
          text = String.Format("%d. %s", i + 1, text);
        }
      }
    }
    else // option number is known
    {
      text = String.Format("%d. %s", shownOptionID + 1, text);
    }
  }
  // return modified text
  return text;
}

// ScrollingDialogDefs helper to fit as many dialog options on the GUI as possible
// If scrolled down to the point more options can fit, add as many as possible

void AutoScrollUp(this ScrollingDialogDefs_t*, Dialog *dlg, int height, int arrowWidth)
{
  // can scroll up, but may be able to fit more options
  // attempt auto-scroll up
  if (!this.FirstDrawnOption)
  {
    // already at the top, we're done
    return;
  }
  int yOffset = 0; // total height of options that are added by autoscrolling
  int i = this.FirstDrawnOption - 1;
  int option;
  for (int optionHeight, yy; i >= 0; i--) // start at previous option that is turned on
  {
    option = this.ShownOptions[i]; // get the current option's ID
    // get the height + line spacing for adding another option
    optionHeight = GetTextHeight(this.GetText(dlg, option, true, i), ScrollingDialog.Font, this.OptionsWidth) +
      ScrollingDialog.get_LineSpacing();
    yy = this.OptionsYMax + yOffset + optionHeight; // new y max when option is added
    if (yy <= height) // if new y max fits on the GUI
    {
      this.OptionsYMax = yy; // store new y max
      yOffset += optionHeight; // update total height of added options
      this.FirstDrawnOption--; // update first drawn option
      this.DrawnOptionCount++; // update number of options that are drawn
      this.OptionY[option] = ScrollingDialog.Padding.Top - yOffset; // the option Ys will be updated later. Because yOffset includes the total
      // added height SO FAR, then when we add the total height back to the option Ys later, this will ensure proper positioning of the newly
      // added options (the last added option will end up at Padding.Top, the option prior to that will be at Padding.Top + yy, etc.)
    }
    else break; // new y max was too much, don't add the option and break out of the loop
  }
  for (i = 0; i < this.DrawnOptionCount; i++) // for every drawn option, update the Y position by the total height of added options
  {
    option = this.ShownOptions[this.FirstDrawnOption + i];
    this.OptionY[option] += yOffset;
  }
  ScrollingDialog.Dialogs[dlg.ID].set_TopOption(this.ShownOptions[this.FirstDrawnOption]); // make sure to update TopOption to reflect the change
  if ((!this.FirstDrawnOption) && (arrowWidth)) // arrowWidth will be zero if disabled arrow graphics are used
  {
    // auto-scrolled all the way to the top, meaning scroll arrows are disabled!
    this.OptionsWidth += arrowWidth;
    this.OptionsYMax = ScrollingDialog.Padding.Top - ScrollingDialog.get_LineSpacing();
    for (i = 0; i < this.DrawnOptionCount; i++) // first drawn option is known to be zero here
    {
      option = this.ShownOptions[i];
      // reposition all options to reflect adjusted width
      this.OptionsYMax += ScrollingDialog.get_LineSpacing();
      this.OptionY[option] = this.OptionsYMax;
      this.OptionsYMax += GetTextHeight(this.GetText(dlg, option, true, i), ScrollingDialog.Font,
        this.OptionsWidth);
      // all options are shown, so no need to worry about "extra" options needing to be drawn here or
      // overflowing the height because we've already verified that in auto-scrolling up
    }
  }
}

// ScrollingDialogDefs helper to get the width of ONLY the first line of text when wrapped

int GetFirstLineTextWidth(this ScrollingDialogDefs_t*, String text, FontType font)
{
  int width = GetTextWidth(text, font); // total text width when drawn on one line
  if (width <= this.OptionsWidth)
  {
    return width; // if less than available width, we're done because there is no wrapping
  }
  int estCharWidth = GetTextWidth("ABCDEFGHIJKLMNOPQRSTUVWXYZ", font) / 26; // estimate width of a single character
  int estOverflowCharCount = (width - this.OptionsWidth) / estCharWidth; // estimate number of characters we need to remove to make the text fit
  if (estOverflowCharCount < 1)
  {
    // remove at least one character, because we know the width is already too wide
    estOverflowCharCount = 1;
  }
  int i = text.Length - estOverflowCharCount;
  String buffer = text.Substring(0, i);
  // assume we've cropped enough off, try adding characters back
  for (String tmp = buffer.AppendChar(text.Chars[i + 1]); GetTextWidth(tmp, font) < this.OptionsWidth;
    tmp = buffer.AppendChar(text.Chars[i + 1]))
  {
    buffer = tmp;
    i++;
    if (i == (text.Length - 2)) // if we've reached the last character, break out, we already know that doesn't fit
    {
      break;
    }
  }
  // assume we didn't crop enough off, remove more characters
  if ((buffer.Length) && (GetTextWidth(buffer, font) >= this.OptionsWidth))
  {
    for (String tmp = buffer.Truncate(buffer.Length - 1); (buffer.Length > 1) &&
      (GetTextWidth(tmp, font) > this.OptionsWidth); tmp = buffer.Truncate(buffer.Length - 1))
    {
      buffer = tmp;
    }
  }
  // buffer now fits the width, but check for a whitespace to delimit the line (this is what the engine does in wrapping)
  for (i = buffer.Length - 1; i > 1; i--)
  {
    if (buffer.Chars[i] == ' ') // found a whitespace, break out of the loop
    {
      break;
    }
  }
  if (i > 0) // if found a whitespace, crop buffer to that length
  {
    buffer = buffer.Substring(0, i);
  }
  // finally, return the width of the first line of text
  return GetTextWidth(buffer, font);
}

// ScrollingDialogDefs helper to invert all option Y positions (dialog options go upwards)

void InvertOptionYs(this ScrollingDialogDefs_t*)
{
  int optionHeight[] = new int[ScrollingDialogDefs.DrawnOptionCount]; // height of each drawn option
  int i;
  int option;
  // first, store the height of each drawn option
  for (int nextOption = 0; i < (ScrollingDialogDefs.DrawnOptionCount - 1); i++)
  {
    option = ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + i];
    nextOption = ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + i + 1];
    // we already know every Y pos, so it's faster to calculate it from that than to use GetTextHeight
    optionHeight[i] = ScrollingDialogDefs.OptionY[nextOption] - ScrollingDialog.get_LineSpacing() -
      ScrollingDialogDefs.OptionY[option];
  }
  // update the height of the last drawn option
  optionHeight[ScrollingDialogDefs.DrawnOptionCount - 1] = ScrollingDialogDefs.OptionsYMax -
    ScrollingDialogDefs.OptionY[ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption +
    (ScrollingDialogDefs.DrawnOptionCount - 1)]];
  int yy = ScrollingDialog.Padding.Top; // keep options aligned to the top of the GUI to allow autosize later
  for (i = (ScrollingDialogDefs.DrawnOptionCount - 1); i >= 0; i--)
  {
    // iterating the drawn options in reverse, update each one's y position and update with its height
    option = ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + i];
    ScrollingDialogDefs.OptionY[option] = yy;
    yy += optionHeight[i] + ScrollingDialog.get_LineSpacing();
  }
}

// ScrollingDialogDefs, reset (dialog ended)

void Reset(this ScrollingDialogDefs_t*)
{
  if ((this.RunningDialog != null) && (ScrollingDialog.ResetTopOptionOnExit))
  {
    // reset TopOption on request
    ScrollingDialog.Dialogs[this.RunningDialog.DialogToRender.ID].set_TopOption(1);
  }
  this.RunningDialog = null;
  this.ShownOptions = null;
  this.ShownOptionCount = 0;
  this.DrawnOptionCount = 0;
  this.FirstDrawnOption = -1;
  this.OptionY = null;
  this.OptionsX = 0;
  this.OptionsWidth = ScrollingDialog.get_Width();
  this.OptionsYMax = ScrollingDialog.get_Height();
  this.OptionsMaxWidth = ScrollingDialog.get_Width();
  // delete DynamicSprites on dialog exit
  if (this.Background != null)
  {
    this.Background.Delete();
    this.Background = null;
  }
  if (this.Foreground != null)
  {
    this.Foreground.Delete();
    this.Foreground = null;
  }
  ScrollingDialog.set_SelectedOption(null);
}

// ScrollingDialogDefs, update which options are shown (eOptionOn) and which are drawn, and their Y positions

void UpdateOptions(this ScrollingDialogDefs_t*, Dialog *dlg, int height, int arrowWidth)
{
  int lineSpacing = ScrollingDialog.get_LineSpacing();
  bool optionOn = false;
  this.OptionsMaxWidth = 0;
  this.OptionsYMax = ScrollingDialog.Padding.Top - lineSpacing;
  this.ShownOptions = new int[dlg.OptionCount]; // options that are eOptionOn (zero-indexed array, up to maximum of Dialog.OptionCount)
  this.ShownOptionCount = 0;
  this.FirstDrawnOption = -1;
  this.DrawnOptionCount = 0;
  this.OptionY = new int[dlg.OptionCount + 1]; // +1 to allow indexing by option ID
  // iterate all dialog options
  for (int i = 1, first = ScrollingDialog.Dialogs[dlg.ID].get_TopOption(); i <= dlg.OptionCount; i++)
  {
    optionOn = (dlg.GetOptionState(i) == eOptionOn);
    if (optionOn)
    {
      // keep track of all options that are turned on
      this.ShownOptions[this.ShownOptionCount] = i;
      this.ShownOptionCount++;
    }
    if ((i < first) || (!optionOn))
    {
      // if this option is less than TopOption OR is not turned on, then set Y pos to -1 and we're done with this option
      this.OptionY[i] = -1;
      continue;
    }
    // otherwise, we have a drawn option!
    String text = this.GetText(dlg, i, true, this.ShownOptionCount - 1); // ShownOptionCount has already been updated, this option is one less than that
    if ((ScrollingDialog.AutosizeWidth) && (this.OptionsMaxWidth < this.OptionsWidth))
    {
      // if autosizing the width, check width of this option
      int width = GetTextWidth(text, ScrollingDialog.Font) + 1; // width == OptionsWidth will force wrapping, +1 to prevent that
      if (width > this.OptionsWidth) // disallow autosize if the options had to wrap to fit
      {
        this.OptionsMaxWidth = this.OptionsWidth;
      }
      else if (width > this.OptionsMaxWidth) // otherwise, update the max width needed
      {
        this.OptionsMaxWidth = width;
      }
    }
    int yy = this.OptionsYMax + GetTextHeight(text, ScrollingDialog.Font, this.OptionsWidth) + lineSpacing;
    if (yy <= height) // option fits in available space
    {
      if (this.FirstDrawnOption == -1) // first drawn option not yet set
      {
        this.FirstDrawnOption = (this.ShownOptionCount - 1); // set this option as first drawn (index to ShownOptions)
        if ((this.FirstDrawnOption) && (arrowWidth))
        {
          // need scroll up arrow, and did not previously account for scroll arrows
          // recalculate with adjusted width
          this.OptionsWidth -= arrowWidth;
          this.UpdateOptions(dlg, height, 0);
          return;
        }
        ScrollingDialog.Dialogs[dlg.ID].set_TopOption(this.ShownOptions[this.FirstDrawnOption]); // update TopOption to reflect shown options
      }
      this.DrawnOptionCount++; // this option is drawn
      this.OptionY[i] = this.OptionsYMax + lineSpacing; // set this option Y pos
      this.OptionsYMax = yy; // update y max for this option
      continue; // and we're done with this option
    }
    else // option doesn't fit, set Y pos to -1
    {
      this.OptionY[i] = -1;
    }
    if (arrowWidth)
    {
      // need scroll down arrow, and did not previously account for scroll arrows
      // recalculate with adjusted width
      this.OptionsWidth -= arrowWidth;
      this.UpdateOptions(dlg, height, 0);
      return;
    }
  }
  this.AutoScrollUp(dlg, height, arrowWidth); // attempt to scroll back up
  if (ScrollingDialog.get_OptionsGoUpwards())
  {
    this.InvertOptionYs(); // options go upwards, invert Ys
  }
}

// ScrollingDialogDefs helper to draw GUI background border decorations

void DrawBackgroundBorderDecorations(this ScrollingDialogDefs_t*, DrawingSurface *surface, int width, int height)
{
  if (surface == null) // no surface, do nothing
  {
    return;
  }
  // grab the graphics for shorthand
  int bkgTop = this.BackgroundBorderDecoration.Top;
  int bkgTopLeft = this.BackgroundBorderDecoration.TopLeftCorner;
  int bkgTopRight = this.BackgroundBorderDecoration.TopRightCorner;
  int bkgLeft = this.BackgroundBorderDecoration.Left;
  int bkgBottom = this.BackgroundBorderDecoration.Bottom;
  int bkgBottomLeft = this.BackgroundBorderDecoration.BottomLeftCorner;
  int bkgBottomRight = this.BackgroundBorderDecoration.BottomRightCorner;
  int bkgRight = this.BackgroundBorderDecoration.Right;
  // get the WIDTH of the border decos
  int bkgLeftWidth = Game.SpriteWidth[bkgLeft];
  int bkgTopLeftWidth = Game.SpriteWidth[bkgTopLeft];
  if (!bkgTopLeftWidth)
  {
    // no top-left border deco, default to width of left border deco (if any)
    bkgTopLeftWidth = bkgLeftWidth;
  }
  int bkgBottomLeftWidth = Game.SpriteWidth[bkgBottomLeft];
  if (!bkgBottomLeftWidth)
  {
    // no bottom-right border deco, default to width of left border deco (if any)
    bkgBottomLeftWidth = bkgLeftWidth;
  }
  int bkgRightWidth = Game.SpriteWidth[bkgRight];
  int bkgTopRightWidth = Game.SpriteWidth[bkgTopRight];
  if (!bkgTopRightWidth)
  {
    // no top-right border deco, default to width of right border deco (if any)
    bkgTopRightWidth = bkgRightWidth;
  }
  int bkgBottomRightWidth = Game.SpriteWidth[bkgBottomRight];
  if (!bkgBottomRightWidth)
  {
    // no bottom-right border deco, default to width of right border deco (if any)
    bkgBottomRightWidth = bkgRightWidth;
  }
  int bkgTopWidth = width - bkgTopLeftWidth - bkgTopRightWidth; // top width is total width less top-left and top-right decos
  int bkgBottomWidth = width - bkgBottomLeftWidth - bkgBottomRightWidth; // bottom width is total width less bottom-left and bottom-right decos
  // get the HEIGHT of the border decos
  int bkgTopHeight = Game.SpriteHeight[bkgTop];
  int bkgTopLeftHeight = Game.SpriteHeight[bkgTopLeft];
  if (!bkgTopLeftHeight)
  {
    // no top-left border deco, default to height of top border deco (if any)
    bkgTopLeftHeight = bkgTopHeight;
  }
  int bkgTopRightHeight = Game.SpriteHeight[bkgTopRight];
  if (!bkgTopRightHeight)
  {
    // no top-right border deco, default to height of top border deco (if any)
    bkgTopRightHeight = bkgTopHeight;
  }
  int bkgBottomHeight = Game.SpriteHeight[bkgBottom];
  int bkgBottomLeftHeight = Game.SpriteHeight[bkgBottomLeft];
  if (!bkgBottomLeftHeight)
  {
    // no bottom-left border deco, default to height of bottom border deco (if any)
    bkgBottomLeftHeight = bkgBottomHeight;
  }
  int bkgBottomRightHeight = Game.SpriteHeight[bkgBottomRight];
  if (!bkgBottomRightHeight)
  {
    // no bottom-right border deco, default to height of bottom border deco (if any)
    bkgBottomRightHeight = bkgBottomHeight;
  }
  int bkgLeftHeight = height - bkgTopLeftHeight - bkgBottomLeftHeight; // left height is total height less top-left and bottom-left decos
  int bkgRightHeight = height - bkgTopRightHeight - bkgBottomRightHeight; // right height is total height less top-right and bottom-right decos
  // finally, draw the decos
  if (bkgTop)
  {
    surface.DrawImage(bkgTopLeftWidth, 0, bkgTop, 0, bkgTopWidth, bkgTopHeight);
  }
  if (bkgBottom)
  {
    surface.DrawImage(bkgBottomLeftWidth, height - bkgBottomHeight, bkgBottom, 0, bkgBottomWidth, bkgBottomHeight);
  }
  if (bkgLeft)
  {
    surface.DrawImage(0, bkgTopLeftHeight, bkgLeft, 0, bkgLeftWidth, bkgLeftHeight);
  }
  if (bkgRight)
  {
    surface.DrawImage(width - bkgRightWidth, bkgTopRightHeight, bkgRight, 0, bkgRightWidth, bkgRightHeight);
  }
  if (bkgTopLeft)
  {
    surface.DrawImage(0, 0, bkgTopLeft, 0, bkgTopLeftWidth, bkgTopLeftHeight);
  }
  if (bkgTopRight)
  {
    surface.DrawImage(width - bkgTopRightWidth, 0, bkgTopRight, 0, bkgTopRightWidth, bkgTopRightHeight);
  }
  if (bkgBottomLeft)
  {
    surface.DrawImage(0, height - bkgBottomLeftHeight, bkgBottomLeft, 0, bkgBottomLeftWidth, bkgBottomLeftHeight);
  }
  if (bkgBottomRight)
  {
    surface.DrawImage(width - bkgBottomRightWidth, height - bkgBottomRightHeight, bkgBottomRight, 0,
      bkgBottomRightWidth, bkgBottomRightHeight);
  }
}

// ScrollingDialogDefs helper to draw GUI background

void DrawBackground(this ScrollingDialogDefs_t*, DrawingSurface *surface, int width, int height)
{
  if (surface == null) // no surface, do nothing
  {
    return;
  }// draw the background
  surface.DrawingColor = ScrollingDialog.Background.Color;
  surface.DrawRectangle(0, 0, width, height); // can't flood-fill with Clear because we may be using modified width/height
  if (ScrollingDialog.Background.Graphic) // has a background graphic
  {
    DynamicSprite *tmpGraphic;
    int backgroundGraphic = ScrollingDialog.Background.Graphic;
    int backgroundX = 0;
    int backgroundY = 0;
    int backgroundWidth = Game.SpriteWidth[backgroundGraphic];
    int backgroundHeight = Game.SpriteHeight[backgroundGraphic];
    if (ScrollingDialog.Background.Style == eDialogBackgroundStretchedToFit) // stretch background graphic
    {
      backgroundWidth = width;
      backgroundHeight = height;
    }
    else if (ScrollingDialog.Background.Style == eDialogBackgroundTiled) // tiled background graphic
    {
      tmpGraphic = DynamicSprite.Create(width, height, true);
      DrawingSurface *tmpSurface = tmpGraphic.GetDrawingSurface();
      for (int widthSoFar = 0; widthSoFar < width; widthSoFar += backgroundWidth)
      {
        for (int heightSoFar = 0; heightSoFar < height; heightSoFar += backgroundHeight)
        {
          tmpSurface.DrawImage(widthSoFar, heightSoFar, backgroundGraphic);
        }
      }
      tmpSurface.Release();
      backgroundGraphic = tmpGraphic.Graphic;
      backgroundWidth = width;
      backgroundHeight = height;
    }
    else // anchored background graphic
    {
      AnchorPoint_t backgroundAnchor = ScrollingDialog.Background.AnchorPoint; // 3.4.0.6 switch bug
      switch (backgroundAnchor)
      {
      case eAnchorTopCenter:
        backgroundX = (width - backgroundWidth) / 2;
        break;
      case eAnchorTopRight:
        backgroundX = (width - backgroundWidth);
        break;
      case eAnchorCenterLeft:
        backgroundY = (height - backgroundHeight) / 2;
        break;
      case eAnchorCenter:
        backgroundX = (width - backgroundWidth) / 2;
        backgroundY = (height - backgroundHeight) / 2;
        break;
      case eAnchorCenterRight:
        backgroundX = (width - backgroundWidth);
        backgroundY = (height - backgroundHeight) / 2;
        break;
      case eAnchorBottomLeft:
        backgroundY = (height - backgroundHeight);
        break;
      case eAnchorBottomCenter:
        backgroundX = (width - backgroundWidth) / 2;
        backgroundY = (height - backgroundHeight);
        break;
      case eAnchorBottomRight:
        backgroundX = (width - backgroundWidth);
        backgroundY = (height - backgroundHeight);
        break;
      default:
        break;
      }
      if (((backgroundX + backgroundWidth) > width) || ((backgroundY + backgroundHeight) > height))
      {
        // background graphic overflows available background area, crop the sprite
        tmpGraphic = DynamicSprite.CreateFromExistingSprite(backgroundGraphic, true); // make a copy
        backgroundWidth = width - backgroundX; // adjust width/height
        backgroundHeight = height - backgroundY;
        tmpGraphic.Crop(0, 0, backgroundWidth, backgroundHeight); // crop
        backgroundGraphic = tmpGraphic.Graphic;
      }
    }
    // draw the background graphic
    surface.DrawImage(backgroundX, backgroundY, backgroundGraphic, 0, backgroundWidth, backgroundHeight);
    if (tmpGraphic != null) // if we tiled or had to crop the sprite, delete the sprite
    {
      tmpGraphic.Delete();
    }
  }
  this.DrawBackgroundBorderDecorations(surface, width, height); // draw border decorations
}

// __ScrollableDialog_t accessors

Dialog* get_AsDialog(this __ScrollableDialog_t*)
{
  return dialog[this.id];
}

int get_ID(this __ScrollableDialog_t*)
{
  return this.id;
}

void set_ID(this __ScrollableDialog_t*, int value)
{
  this.id = value;
}

int get_OptionCount(this __ScrollableDialog_t*)
{
  return dialog[this.id].OptionCount;
}

void set_OptionIndex(this __ScrollableDialog_t*, int value)
{
  this.optionIndex = value;
}

// DialogArrow accessors

bool get_Enabled(this DialogArrow*)
{
  if ((this != ScrollingDialogDefs.UpArrow) &&
      (this != ScrollingDialogDefs.DownArrow))
  {
    AbortGame("Unexpected DialogArrow used. Enabled can only be used with the built-in dialog arrows at this time.");
    // NOTE: advanced users can replace this error with whatever method
    // you deem appropriate to return an enabled state that correlates
    // to this DialogArrow, however, this state specifically relates to
    // the layout of the GUI. The built-in system only permits using the
    // built-in up and down scroll arrows, and a pointer may not be stored
    // to the non-managed ScrollingDialog_t struct.
  }
  if (ScrollingDialogDefs.ShownOptions == null) // no options are shown means no scroll arrows
  {
    return false;
  }
  bool up = (this == ScrollingDialogDefs.UpArrow); // if this is the Up arrow
  if (ScrollingDialog.get_OptionsGoUpwards()) // invert meaning of "up" if options are drawn upwards
  {
    up = !up;
  }
  if (up)
  {
    return (ScrollingDialogDefs.FirstDrawnOption > 0); // if first drawn option isn't first shown (eOptionOn), then we can scroll up
  }
  else
  {
    // if last drawn option isn't last shown (eOptionOn), then we can scroll down
    return ((ScrollingDialogDefs.FirstDrawnOption + ScrollingDialogDefs.DrawnOptionCount) < ScrollingDialogDefs.ShownOptionCount);
  }
}

int get_graphic(this DialogArrow*)
{
  return this.graphic;
}

void set_graphic(this DialogArrow*, int value)
{
  if (value == -1)
  {
    value = this.NormalGraphic;
  }
  else
  {
    this.graphic = value;
  }
}

Padding_t get_Padding(this DialogArrow*)
{
  if ((this != ScrollingDialogDefs.UpArrow) &&
      (this != ScrollingDialogDefs.DownArrow))
  {
    AbortGame("Unexpected DialogArrow used. Padding can only be used with the built-in dialog arrows at this time.");
    // NOTE: advanced users can replace this error with whatever method
    // you deem appropriate to return a Padding_t object that correlates
    // to this DialogArrow, but as of this writing pointers cannot be
    // stored in managed structs, so there is no generic way of doing so
  }
  if (this == ScrollingDialogDefs.UpArrow)
  {
    return ScrollingDialogDefs.UpArrowPadding;
  }
  return ScrollingDialogDefs.DownArrowPadding;
}

int get_x(this DialogArrow*)
{
  return this.x;
}

void set_x(this DialogArrow*, int value)
{
  this.x = value;
}

int get_xOffset(this DialogArrow*)
{
  return this.xOffset;
}

void set_xOffset(this DialogArrow*, int value)
{
  this.xOffset = value;
}

int get_y(this DialogArrow*)
{
  return this.y;
}

void set_y(this DialogArrow*, int value)
{
  this.y = value;
}

int get_yOffset(this DialogArrow*)
{
  return this.yOffset;
}

void set_yOffset(this DialogArrow*, int value)
{
  this.yOffset = value;
}

// DialogArrow helper to check if mouse is over arrow graphic

bool IsMouseOver(this DialogArrow*)
{
  int x = this.x + this.xOffset; // get adjusted coords (offset accounts for actual SCREEN coordinate)
  int y = this.y + this.yOffset;
  int graphic = this.NormalGraphic;
  if ((mouse.x >= x) && (mouse.y >= y)) // mouse is potentially over arrow (meets min (X, Y) requirement)
  {
    if (mouse.IsButtonDown(eMouseLeft)) // should be pushed graphic
    {
      graphic = this.PushedGraphic;
      if (graphic == -1) // pushed graphic was -1, default to mouse-over
      {
        graphic = this.MouseOverGraphic;
        if (graphic == -1) // mouse-over graphic was -1, default to normal
        {
          graphic = this.NormalGraphic;
        }
      }
    }
    else // not pushed graphic
    {
      graphic = this.MouseOverGraphic;
      if (graphic == -1) // mouse-over graphic was -1, default to normal
      {
        graphic = this.NormalGraphic;
      }
    }
    int x2 = x + Game.SpriteWidth[graphic]; // get width/height of selected graphic
    int y2 = y + Game.SpriteHeight[graphic];
    return ((mouse.x <= x2) && (mouse.y <= y2)); // return whether mouse meets max (X, Y) requirement
  }
  return false; // otherwise, mouse didn't meet min (X, Y) requirement, so mouse is not over arrow
}

// DialogArrow helper to select the correct graphic for drawing (ignores disabled graphic)

int UpdateGraphic(this DialogArrow*)
{
  this.graphic = this.NormalGraphic;
  if (this.IsMouseOver()) // mouse is over arrow
  {
    if (mouse.IsButtonDown(eMouseLeft)) // mouse is pushed
    {
      if (this.PushedGraphic == -1) // pushed graphic is -1, default to mouse-over or normal
      {
        this.set_graphic(this.MouseOverGraphic);
      }
      else // pushed graphic is not -1, graphic is pushed graphic
      {
        this.graphic = this.PushedGraphic;
      }
    }
    else // mouse is not pushed
    {
      this.set_graphic(this.MouseOverGraphic); // graphic is mouse-over or normal
    }
  }
  return this.graphic;
}

// DialogArrow helper to draw the arrow on a surface

void Draw(this DialogArrow*, DrawingSurface *surface)
{
  if (surface == null) // no surface, do nothing
  {
    return;
  }
  this.UpdateGraphic(); // update graphic
  if (this.get_Enabled() && (this.graphic != 0)) // arrow enabled and has a graphic, draw it
  {
    surface.DrawImage(this.x, this.y, this.graphic);
  }
  else if ((this.DisabledGraphic == -1) && (this.NormalGraphic != 0)) // else, disabled graphic is -1, draw normal graphic instead
  {
    surface.DrawImage(this.x, this.y, this.NormalGraphic);
  }
  else if (this.DisabledGraphic > 0) // else, draw disabled graphic
  {
    surface.DrawImage(this.x, this.y, this.DisabledGraphic);
  }
}

// DialogArrow helpers to get max dimensions of this arrow (excludes padding) (used for positioning and autosizing)

int GetMaxHeight(this DialogArrow*)
{
  return Maths.MaxInt(Maths.MaxInt(Game.SpriteHeight[this.NormalGraphic], Game.SpriteHeight[this.PushedGraphic]),
    Maths.MaxInt(Game.SpriteHeight[this.MouseOverGraphic], Game.SpriteHeight[this.DisabledGraphic]));
}

int GetMaxWidth(this DialogArrow*)
{
  return Maths.MaxInt(Maths.MaxInt(Game.SpriteWidth[this.NormalGraphic], Game.SpriteWidth[this.PushedGraphic]),
    Maths.MaxInt(Game.SpriteWidth[this.MouseOverGraphic], Game.SpriteWidth[this.DisabledGraphic]));
}

// DialogArrows accessors

DialogArrow get_Down(this DialogArrows*)
{
  if (this != ScrollingDialog.ScrollArrows)
  {
    AbortGame("Unexpected DialogArrows used. ScrollArrows can only be used with the built-in dialog arrows at this time.");
    // NOTE: advanced users can replace this error with whatever method
    // you deem appropriate to return a DialogArrow object that correlates
    // to this DialogArrows, but as of this writing pointers cannot be
    // stored in managed structs, so there is no generic way of doing so
  }
  return ScrollingDialogDefs.DownArrow;
}

DialogArrow get_Up(this DialogArrows*)
{
  if (this != ScrollingDialog.ScrollArrows)
  {
    AbortGame("Unexpected DialogArrows used. ScrollArrows can only be used with the built-in dialog arrows at this time.");
    // NOTE: advanced users can replace this error with whatever method
    // you deem appropriate to return a DialogArrow object that correlates
    // to this DialogArrows, but as of this writing pointers cannot be
    // stored in managed structs, so there is no generic way of doing so
  }
  return ScrollingDialogDefs.UpArrow;
}

// DialogArrows helper to get max arrow dimensions (including padding) (used for positioning and autosizing)

int GetMaxHeight(this DialogArrows*)
{
  DialogArrow up = this.get_Up(); // do this generically instead of assuming, class may be generically reusable when managed structs can contain pointers
  Padding_t upPad = up.get_Padding();
  int upHeight = up.GetMaxHeight();
  if (upHeight != 0) // if arrow height is non-zero, add padding
  {
    upHeight += upPad.Top + upPad.Bottom;
  }
  DialogArrow down = this.get_Down();
  Padding_t downPad = down.get_Padding();
  int downHeight = down.GetMaxHeight();
  if (downHeight != 0)
  {
    downHeight += downPad.Top + downPad.Bottom;
  }
  return Maths.MaxInt(upHeight, downHeight); // return max of two arrow heights
}

int GetMaxWidth(this DialogArrows*)
{
  DialogArrow up = this.get_Up();
  Padding_t upPad = up.get_Padding();
  int upWidth = up.GetMaxWidth();
  if (upWidth != 0) // arrow width is non-zero, add padding
  {
    upWidth += upPad.Left + upPad.Right;
  }
  DialogArrow down = this.get_Down();
  Padding_t downPad = down.get_Padding();
  int downWidth = down.GetMaxWidth();
  if (downWidth != 0)
  {
    downWidth += downPad.Left + downPad.Right;
  }
  return Maths.MaxInt(upWidth, downWidth); // return max of two arrow widths
}

// DialogBackground accessors

DialogBorderDecoration get_BorderDecoration(this DialogBackground*)
{
  if (this != ScrollingDialog.Background)
  {
    AbortGame("Unexpected DialogBackground used. BorderDecoration can only be used with the built-in dialog background at this time.");
    // NOTE: advanced users can replace this error with whatever method
    // you deem appropriate to return a DialogBorderDecoration object that correlates
    // to this DialogBackground, but as of this writing pointers cannot be
    // stored in managed structs, so there is no generic way of doing so
  }
  return ScrollingDialogDefs.BackgroundBorderDecoration;
}

// DialogBullet accessors

Padding_t get_Padding(this DialogBullet*)
{
  if (this != ScrollingDialog.Bullet)
  {
    AbortGame("Unexpected DialogBullet used. Padding can only be used with the built-in dialog bullet at this time.");
    // NOTE: advanced users can replace this error with whatever method
    // you deem appropriate to return a Padding_t object that correlates
    // to this DialogBullet, but as of this writing pointers cannot be
    // stored in managed structs, so there is no generic way of doing so
  }
  return ScrollingDialogDefs.BulletPadding;
}

// DialogBullet helper to get max width (height is not used by dialog bullet for positioning/sizing)

int GetMaxWidth(this DialogBullet*)
{
  return Maths.MaxInt(Maths.MaxInt(Game.SpriteWidth[this.NormalGraphic], Game.SpriteWidth[this.ActiveGraphic]), Game.SpriteWidth[this.ChosenGraphic]);
}

// DialogOption accessors

bool get_HasBeenChosen(this DialogOption*)
{
  return dialog[this.owningDialogID].HasOptionBeenChosen(this.id);
}

void set_HasBeenChosen(this DialogOption*, bool value)
{
  dialog[this.owningDialogID].SetHasOptionBeenChosen(this.id, value);
}

void set_ID(this DialogOption*, int value)
{
  this.id = value;
}

__ScrollableDialog_t get_OwningDialog(this DialogOption*)
{
  return ScrollingDialog.Dialogs[this.owningDialogID];
}

void set_OwningDialog(this DialogOption*, Dialog *value)
{
  this.owningDialogID = value.ID;
}

DialogOptionState get_State(this DialogOption*)
{
  return dialog[this.owningDialogID].GetOptionState(this.id);
}

void set_State(this DialogOption*, DialogOptionState value)
{
  dialog[this.owningDialogID].SetOptionState(this.id, value);
}

String get_Text(this DialogOption*)
{
  // do not return raw option text, use helper instead to ensure dialog tags are replaced
  return ScrollingDialogDefs.GetText(dialog[this.owningDialogID], this.id, false);
}

// Initialization functions

void InitializeDialogOptions(this ScrollingDialogDefs_t*, int optionCount)
{
  // optionCount is total dialog options in game
  // since we can't store this array in __ScrollableDialog_t, we keep a global collection instead
  this.DialogOptions = new DialogOption[optionCount];
  for (int dlg = 0, option = 1, i = 0; i < optionCount; i++)
  {
    this.DialogOptions[i] = new DialogOption; // construct the object
    this.DialogOptions[i].set_ID(option); // set the ID for the option
    this.DialogOptions[i].set_OwningDialog(dialog[dlg]); // set the owning dialog
    if (option == dialog[dlg].OptionCount)
    {
      option = 0; // option is updated below
      dlg++;
    }
    option++;
  }
}

void InitializeDialogs(this ScrollingDialog_t*)
{
  this.Dialogs = new __ScrollableDialog_t[Game.DialogCount];
  int optionCount = 0;
  for (int i = 0; i < Game.DialogCount; i++)
  {
    this.Dialogs[i] = new __ScrollableDialog_t; // construct the object
    this.Dialogs[i].set_ID(i); // set the ID for the dialog
    this.Dialogs[i].set_OptionIndex(optionCount); // set the option index (used for global DialogOption array)
    this.Dialogs[i].set_TopOption(1); // set the TopOption
    optionCount += dialog[i].OptionCount; // accumulate total dialog option count
  }
  ScrollingDialogDefs.InitializeDialogOptions(optionCount); // initialize dialog options
}

void Initialize(this ScrollingDialogDefs_t*)
{
  // construct the needed objects
  this.BulletPadding = new Padding_t;
  this.UpArrow = new DialogArrow;
  this.UpArrowPadding = new Padding_t;
  this.DownArrow = new DialogArrow;
  this.DownArrowPadding = new Padding_t;
  this.BackgroundBorderDecoration = new DialogBorderDecoration;
}

void Initialize(this ScrollingDialog_t*)
{
  this.Background = new DialogBackground;
  this.Background.Color = 0; // default background color
  this.Bullet = new DialogBullet;
  this.height = (System.ViewportHeight / 5); // default height set to 1/5th screen height
  this.Padding = new Padding_t;
  this.playerNameTag = "%PLAYERNAME%"; // default PlayerNameTag
  this.ScrollArrows = new DialogArrows;
  this.width = System.ViewportWidth; // default width set to screen width
  this.TextAlignment = eAlignLeft; // left-align text by default
  this.Y = System.ViewportHeight - this.height; // Y defaults to show GUI at bottom of screen
  this.InitializeDialogs(); // initialize dialogs
  ScrollingDialogDefs.Initialize(); // initialize local definitions
}

function game_start()
{
  ScrollingDialog.Initialize(); // initialize the module
}

function repeatedly_execute() // since this runs on non-blocking thread, we can guarantee that if it runs there is no dialog running
{
  if (ScrollingDialogDefs.RunningDialog != null)
  {
    ScrollingDialogDefs.Reset(); // reset any dialog related info
  }
}

// built-in custom dialog rendering functions

function dialog_options_get_dimensions(DialogOptionsRenderingInfo *info)
{
  info.X = ScrollingDialog.X;
  info.Y = ScrollingDialog.Y;
  info.Width = ScrollingDialog.get_Width();
  info.Height = ScrollingDialog.get_Height();
  info.HasAlphaChannel = true;
  // TODO: add parser
  //info.ParserTextBoxX = 10;
  //info.ParserTextBoxY = 160;
  //info.ParserTextBoxWidth = 180;
  // always reset before doing anything
  ScrollingDialogDefs.Reset();
  ScrollingDialogDefs.RunningDialog = info;
  // create sprites for drawing onto
  ScrollingDialogDefs.Background = DynamicSprite.Create(info.Width, info.Height, true);
  ScrollingDialogDefs.Foreground = DynamicSprite.Create(info.Width, info.Height, true);
}

function dialog_options_render(DialogOptionsRenderingInfo *info)
{
  ScrollingDialog.set_SelectedOption(null); // clear this every time the GUI is rendered, it should only be used in dialog scripts
  // create drawing surfaces and clear them
  DrawingSurface *backgroundSurface = ScrollingDialogDefs.Background.GetDrawingSurface();
  backgroundSurface.Clear();
  DrawingSurface *foregroundSurface = ScrollingDialogDefs.Foreground.GetDrawingSurface();
  foregroundSurface.Clear();
  // initial info about where options are drawn, etc.
  Dialog *dlg = info.DialogToRender;
  int bulletWidth = ScrollingDialog.Bullet.GetMaxWidth();
  if (bulletWidth != 0)
  {
    bulletWidth += ScrollingDialogDefs.BulletPadding.Left + ScrollingDialogDefs.BulletPadding.Right;
  }
  ScrollingDialogDefs.OptionsWidth = ScrollingDialog.get_Width() - ScrollingDialog.Padding.Left -
    ScrollingDialog.Padding.Right - bulletWidth; // option width always accounts for dialog bullet
  int arrowWidth = ScrollingDialog.ScrollArrows.GetMaxWidth();
  bool hasDisabledArrows = ((ScrollingDialogDefs.UpArrow.DisabledGraphic != 0) ||
    (ScrollingDialogDefs.DownArrow.DisabledGraphic != 0));
  if ((arrowWidth != 0) && (hasDisabledArrows))
  {
    ScrollingDialogDefs.OptionsWidth -= arrowWidth; // if there are disabled arrows, update the available width
  }
  int height = ScrollingDialog.get_Height() - ScrollingDialog.Padding.Top - ScrollingDialog.Padding.Bottom;
  // if we have disabled arrows, pass "arrowWidth" as zero
  // otherwise, pass the actual arrowWidth to readjust if they are turned on
  ScrollingDialogDefs.UpdateOptions(dlg, height, arrowWidth * !hasDisabledArrows);
  ScrollingDialogDefs.OptionsX = ScrollingDialog.Padding.Left;
  // now that options are updated, we can check if scroll arrows are enabled
  bool hasScrollArrows = ((hasDisabledArrows) || ScrollingDialogDefs.UpArrow.get_Enabled() ||
    ScrollingDialogDefs.DownArrow.get_Enabled());
  if (ScrollingDialog.ScrollArrows.Float == eFloatLeft) // scroll arrows to left of dialog options
  {
    ScrollingDialogDefs.UpArrow.set_x(ScrollingDialog.Padding.Left + ScrollingDialogDefs.UpArrowPadding.Left);
    ScrollingDialogDefs.DownArrow.set_x(ScrollingDialog.Padding.Left + ScrollingDialogDefs.DownArrowPadding.Left);
    if (hasScrollArrows)
    {
      ScrollingDialogDefs.OptionsX += arrowWidth;
    }
  }
  else // scroll arrows to right of dialog options
  {
    ScrollingDialogDefs.UpArrow.set_x((ScrollingDialog.get_Width() - ScrollingDialog.Padding.Right -
      arrowWidth) + ScrollingDialogDefs.UpArrowPadding.Left);
    ScrollingDialogDefs.DownArrow.set_x((ScrollingDialog.get_Width() - ScrollingDialog.Padding.Right -
      arrowWidth) + ScrollingDialogDefs.DownArrowPadding.Left);
  }
  // set scroll arrow Y positions
  ScrollingDialogDefs.UpArrow.set_y(ScrollingDialog.Padding.Top + ScrollingDialogDefs.UpArrowPadding.Top);
  ScrollingDialogDefs.DownArrow.set_y(ScrollingDialogDefs.UpArrow.get_y() +
    ScrollingDialogDefs.UpArrow.GetMaxHeight() + ScrollingDialogDefs.UpArrowPadding.Bottom +
    ScrollingDialogDefs.DownArrowPadding.Top);
  // scroll arrow offsets default to GUI location
  ScrollingDialogDefs.UpArrow.set_xOffset(ScrollingDialog.X);
  ScrollingDialogDefs.UpArrow.set_yOffset(ScrollingDialog.Y);
  ScrollingDialogDefs.DownArrow.set_xOffset(ScrollingDialog.X);
  ScrollingDialogDefs.DownArrow.set_yOffset(ScrollingDialog.Y);
  int xx = 0;
  int adjustedWidth = ScrollingDialog.get_Width();
  if (ScrollingDialog.AutosizeWidth) // autosizing the width, shrink if possible
  {
    // we need at least enough room to draw the options and right-side padding
    xx = ScrollingDialogDefs.OptionsX + ScrollingDialogDefs.OptionsMaxWidth + ScrollingDialog.Padding.Right;
    if ((hasScrollArrows) && (ScrollingDialog.ScrollArrows.Float == eFloatRight)) // scroll arrows to the right
    {
      xx += arrowWidth;
    }
    if (ScrollingDialog.Bullet.Float == eFloatRight) // bullet to the right
    {
      xx += bulletWidth;
    }
    xx = ScrollingDialog.get_Width() - Maths.MaxInt(xx, ScrollingDialog.get_MinWidth()); // get adjusted max x pos and potential crop area
    if (xx > 0) // we can crop
    {
      adjustedWidth -= xx; // adjust width
      ScrollingDialogDefs.OptionsWidth -= xx; // adjust space available for drawing options
      // options that are drawn are always based on left-aligned text, so this adjustment won't impact scroll state
      AnchorPoint_t anchor = ScrollingDialog.AnchorPoint; // copy global (3.4.0.6 switch bug)
      switch (anchor)
      {
      case eAnchorTopLeft:
      case eAnchorCenterLeft:
      case eAnchorBottomLeft:
        xx = 0; // draw left-aligned width
        break;
      case eAnchorTopCenter:
      case eAnchorCenter:
      case eAnchorBottomCenter:
        xx /= 2; // draw center-aligned width
        break;
      default:
        break;
      }
    }
    else // we can't crop
    {
      xx = 0; // draw full-size width left-aligned
    }
  }
  int yy = 0;
  int adjustedHeight = ScrollingDialog.get_Height();
  if (ScrollingDialog.AutosizeHeight) // autosize height, shrink if possible
  {
    // with no scroll arrows, we still need at least enough space for GUI padding
    int scrollArrowsMinHeight = ScrollingDialog.Padding.Top + ScrollingDialog.Padding.Bottom;
    if (hasScrollArrows)
    {
      // if we have scroll arrows, ensure that we have enough space to draw the down arrow
      // beneath the up arrow
      scrollArrowsMinHeight += ScrollingDialogDefs.UpArrowPadding.Top +
        ScrollingDialogDefs.UpArrow.GetMaxHeight() + ScrollingDialogDefs.UpArrowPadding.Bottom +
        ScrollingDialogDefs.DownArrowPadding.Top + ScrollingDialogDefs.DownArrow.GetMaxHeight() +
        ScrollingDialogDefs.DownArrowPadding.Bottom;
    }
    // assumed y max based on options
    yy = (ScrollingDialogDefs.OptionsYMax + ScrollingDialog.Padding.Bottom);
    yy = Maths.MaxInt(yy, scrollArrowsMinHeight); // update y max based on scroll arrows positioning
    yy = ScrollingDialog.get_Height() - Maths.MaxInt(yy, ScrollingDialog.get_MinHeight()); // get adjusted max y pos and potential crop area
    if (yy > 0) // we can crop
    {
      adjustedHeight -= yy; // update height
      AnchorPoint_t anchor = ScrollingDialog.AnchorPoint; // 3.4.0.6 switch bug
      switch (anchor)
      {
      case eAnchorTopLeft:
      case eAnchorTopCenter:
      case eAnchorTopRight:
        yy = 0; // draw top-aligned height
        break;
      case eAnchorCenterLeft:
      case eAnchorCenter:
      case eAnchorCenterRight:
        yy /= 2; // draw center-aligned height
        break;
      default:
        break;
      }
    }
    else // we can't crop
    {
      yy = 0; // draw full-sized height top-aligned
    }
  }
  int bulletX; // figure out default bullet x position
  if (ScrollingDialog.Bullet.Float == eFloatLeft) // dialog bullet to left of options
  {
    bulletX = ScrollingDialog.Padding.Left + ScrollingDialogDefs.BulletPadding.Left;
    if ((ScrollingDialog.ScrollArrows.Float == eFloatLeft) && (hasScrollArrows)) // arrows also to the left, bullet to right of arrows
    {
      bulletX += arrowWidth;
    }
    ScrollingDialogDefs.OptionsX += bulletWidth;
  }
  else // dialog bullet to right of options
  {
    bulletX = (adjustedWidth - ScrollingDialog.Padding.Right - bulletWidth) + ScrollingDialogDefs.BulletPadding.Left;
    if (ScrollingDialog.ScrollArrows.Float == eFloatRight) // arrows also to the right, bullet to the left of arrows
    {
      bulletX -= arrowWidth;
    }
  }
  // FINALLY! actually DRAW the options!
  for (int i = 0, option = 0, y = 0, bulletGraphic = 0; i < ScrollingDialogDefs.DrawnOptionCount; i++)
  {
    option = ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + i];
    y = ScrollingDialogDefs.OptionY[option];
    if (option == info.ActiveOptionID) // option is active
    {
      foregroundSurface.DrawingColor = ScrollingDialog.get_TextColorActive();
      bulletGraphic = ScrollingDialog.Bullet.ActiveGraphic;
    }
    else if (dlg.HasOptionBeenChosen(option)) // option has been chosen
    {
      foregroundSurface.DrawingColor = ScrollingDialog.get_TextColorChosen();
      bulletGraphic = ScrollingDialog.Bullet.ChosenGraphic;
    }
    else // option is normal option
    {
      foregroundSurface.DrawingColor = ScrollingDialog.TextColorNormal;
      bulletGraphic = ScrollingDialog.Bullet.NormalGraphic;
    }
    // get and draw the text
    String text = ScrollingDialogDefs.GetText(dlg, option, true, ScrollingDialogDefs.FirstDrawnOption + i);
    foregroundSurface.DrawStringWrapped(ScrollingDialogDefs.OptionsX, y, ScrollingDialogDefs.OptionsWidth,
      ScrollingDialog.Font, ScrollingDialog.TextAlignment, text);
    if (bulletGraphic != 0) // need to draw a bullet
    {
      if (!ScrollingDialog.Bullet.StaticPosition)
      {
        // update bullet X pos to align next to option text
        int textWidth = ScrollingDialogDefs.GetFirstLineTextWidth(text, ScrollingDialog.Font);
        if (ScrollingDialog.TextAlignment == eAlignCentre)
        {
          bulletX = ((ScrollingDialogDefs.OptionsWidth - textWidth) / 2);
          if (ScrollingDialog.Bullet.Float == eFloatLeft)
          {
            bulletX += ScrollingDialogDefs.OptionsX - ScrollingDialogDefs.BulletPadding.Right -
              ScrollingDialog.Bullet.GetMaxWidth();
          }
          else
          {
            bulletX = ScrollingDialogDefs.OptionsX + ScrollingDialogDefs.OptionsWidth - bulletX +
              ScrollingDialogDefs.BulletPadding.Left;
          }
        }
        else if ((ScrollingDialog.TextAlignment == eAlignRight) && (ScrollingDialog.Bullet.Float == eFloatLeft))
        {
          bulletX = ScrollingDialogDefs.OptionsX + ScrollingDialogDefs.OptionsWidth - textWidth -
            ScrollingDialog.Bullet.GetMaxWidth() + ScrollingDialogDefs.BulletPadding.Left -
            ScrollingDialogDefs.BulletPadding.Right;
        }
        else if ((ScrollingDialog.TextAlignment == eAlignLeft) && (ScrollingDialog.Bullet.Float == eFloatRight))
        {
          bulletX = ScrollingDialogDefs.OptionsX + textWidth + ScrollingDialogDefs.BulletPadding.Left;
        }
      }
      // draw the bullet image for this option
      foregroundSurface.DrawImage(bulletX, y + ScrollingDialogDefs.BulletPadding.Top, bulletGraphic);
    }
  }
  // if the GUI has been anchored somewhere other than top-left, we'll need to update some positioning info
  if (xx > 0)
  {
    // update options X position and arrows X offset
    ScrollingDialogDefs.OptionsX += xx;
    ScrollingDialogDefs.UpArrow.set_xOffset(ScrollingDialogDefs.UpArrow.get_xOffset() + xx);
    ScrollingDialogDefs.DownArrow.set_xOffset(ScrollingDialogDefs.DownArrow.get_xOffset() + xx);
  }
  if (yy > 0)
  {
    // update every option Y pos, Y max, and arrows Y offset
    for (int i = 0, option = 0; i < ScrollingDialogDefs.DrawnOptionCount; i++)
    {
      option = ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + i];
      ScrollingDialogDefs.OptionY[option] += yy;
    }
    ScrollingDialogDefs.OptionsYMax += yy;
    ScrollingDialogDefs.UpArrow.set_yOffset(ScrollingDialogDefs.UpArrow.get_yOffset() + yy);
    ScrollingDialogDefs.DownArrow.set_yOffset(ScrollingDialogDefs.DownArrow.get_yOffset() + yy);
  }
  // with everything properly positioned, draw the arrows
  ScrollingDialogDefs.UpArrow.Draw(foregroundSurface);
  ScrollingDialogDefs.DownArrow.Draw(foregroundSurface);
  // draw the background
  ScrollingDialogDefs.DrawBackground(backgroundSurface, adjustedWidth, adjustedHeight);
  // release our drawing surfaces
  backgroundSurface.Release();
  foregroundSurface.Release();
  // clear the actual GUI drawing surface, and draw the background and foreground images
  info.Surface.Clear();
  info.Surface.DrawImage(xx, yy, ScrollingDialogDefs.Background.Graphic, ScrollingDialog.Background.Transparency);
  info.Surface.DrawImage(xx, yy, ScrollingDialogDefs.Foreground.Graphic);
}

function dialog_options_repexec(DialogOptionsRenderingInfo *info)
{
  // get the active option, if any, and check arrow graphics
  info.ActiveOptionID = 0;
  if (ScrollingDialogDefs.ShownOptions == null) // no shown options, nothing to do?
  {
    info.Update();
    return;
  }
  if (ScrollingDialogDefs.UpArrow.IsMouseOver() || ScrollingDialogDefs.DownArrow.IsMouseOver())
  {
    // mouse is over one of the arrows, update to clear any prior active option and refresh arrow graphics
    if ((ScrollingDialogDefs.DidMouseClick) && (!mouse.IsButtonDown(eMouseLeft)))
    {
      // if we were listening for a mouse-up, then we have clicked on one of the scroll arrows
      if (ScrollingDialogDefs.UpArrow.IsMouseOver())
      {
        ScrollingDialog.ScrollUp(info.DialogToRender);
      }
      if (ScrollingDialogDefs.DownArrow.IsMouseOver())
      {
        ScrollingDialog.ScrollDown(info.DialogToRender);
      }
      ScrollingDialogDefs.DidMouseClick = false;
    }
    info.Update();
    return;
  }
  int yy = (mouse.y - ScrollingDialog.Y); // adjusted mouse y (relative to GUI)
  if ((mouse.x < ScrollingDialogDefs.OptionsX) || (mouse.x > (ScrollingDialogDefs.OptionsX + ScrollingDialogDefs.OptionsWidth)) ||
    (yy < 0) || (yy >= ScrollingDialogDefs.OptionsYMax))
  {
    // if mouse is not over an option, then update to clear any prior active option and we're done
    info.Update();
    return;
  }
  // loop through the drawn options in reverse order to check against each option's Y pos
  for (int i = ScrollingDialogDefs.DrawnOptionCount - 1, option = 0; i >= 0; i--)
  {
    option = ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + i];
    if (ScrollingDialog.get_OptionsGoUpwards())
    {
      // ShownOptions is not inverted if options go upwards
      // so, if options go upwards we need to check the option with the LOWEST ID first,
      // rather than the option with the highest ID, as that will be the option drawn lowest on the GUI
      option = ((ScrollingDialogDefs.DrawnOptionCount - 1) - i); // invert the index to ShownOptions
      option = ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + option]; // get the actual option at the inverted index
    }
    if (yy >= ScrollingDialogDefs.OptionY[option]) // the mouse is over an option, we're done
    {
      info.ActiveOptionID = option;
      return;
    }
  }
}

function dialog_options_mouse_click(DialogOptionsRenderingInfo *info, MouseButton button)
{
  Dialog *dlg = info.DialogToRender;
  ScrollingDialogDefs.DidMouseClick = false;
  if (button == eMouseLeft) // left mouse click
  {
    if (info.ActiveOptionID != 0) // if there is an active option, run its script
    {
      ScrollingDialog.RunOption(info.ActiveOptionID);
      return;
    }
    ScrollingDialogDefs.DidMouseClick = true; // check for mouse-up on the arrows in dialog_options_repexec
  }
  else if (button == eMouseWheelNorth) // mouse wheel up, scroll up
  {
    ScrollingDialog.ScrollUp(dlg);
  }
  else if (button == eMouseWheelSouth) // mouse wheel down, scroll down
  {
    ScrollingDialog.ScrollDown(dlg);
  }
}

function dialog_options_key_press(DialogOptionsRenderingInfo *info, eKeyCode keycode)
{
  // check for keyboard shortcuts (relative to DRAWN options, not just options that are eOptionOn)
  if (((ScrollingDialog.get_OptionsNumberStyle() == eDialogOptionNumbersShortcutsOnly) ||
    (ScrollingDialog.get_OptionsNumberStyle() == eDialogOptionNumbersDrawn)) && (keycode >= '0') && (keycode <= '9'))
  {
    int option = keycode - '0' - 1; // get shortcut offset
    if (option == -1) // -1 means the 10th option, so offset 9
    {
      option = 9;
    }
    if (ScrollingDialog.OptionsShortcutStyle == eDialogOptionShortcutDrawnOptionsOnly)
    {
      // shortcuts are relative to drawn options only
      if (option < ScrollingDialogDefs.DrawnOptionCount)
      {
        // run the script for the Nth option from the first drawn
        ScrollingDialog.RunOption(ScrollingDialogDefs.ShownOptions[ScrollingDialogDefs.FirstDrawnOption + option]);
      }
    }
    else if (option < ScrollingDialogDefs.ShownOptionCount)
    {
      // shortcuts are relative to all shown (eOptionOn) options
      // run the script for the Nth option that is turned on
      ScrollingDialog.RunOption(ScrollingDialogDefs.ShownOptions[option]);
    }
  }
}
 L$  
#ifdef AGS_SUPPORTS_IFVER
#ifver 3.4.0.6
#define ScrollingDialog_VERSION 3.0
#define ScrollingDialog_VERSION_300
#endif // 3.4.0.6
#endif // AGS_SUPPORTS_IFVER

#ifndef ScrollingDialog_VERSION
#error The ScrollingDialog module requires AGS version 3.4.0.6 or higher. Please use a newer version of AGS to use this module.
#endif // ScrollingDialog_VERSION

#ifndef MathsPlus_VERSION
#error The ScrollingDialog module depends on the MathsPlus module which was not found. Please include the MathsPlus module to use the ScrollingDialog module.
#endif // MathsPlus_VERSION

enum AnchorPoint_t
{
  eAnchorTopLeft = 0,
  eAnchorTopCenter,
  eAnchorTopRight,
  eAnchorCenterLeft,
  eAnchorCenter,
  eAnchorCenterRight,
  eAnchorBottomLeft,
  eAnchorBottomCenter,
  eAnchorBottomRight
};

enum DialogBackgroundStyle
{
  eDialogBackgroundAnchored = 0,
  eDialogBackgroundStretchedToFit,
  eDialogBackgroundTiled
};

enum DialogOptionNumberStyle
{
  eDialogOptionNumbersDisabled = 0,
  eDialogOptionNumbersShortcutsOnly = 1,
  eDialogOptionNumbersDrawn = 2
};

enum DialogOptionShortcutStyle
{
  eDialogOptionShortcutDrawnOptionsOnly = 0,
  eDialogOptionShortcutAllAvailableOptions
};

enum FloatStyle
{
  eFloatLeft = 0,
  eFloatRight
};

managed struct DialogOption;

autoptr managed struct __ScrollableDialog_t
{
  /// Returns the specified option from this dialog.
  readonly import attribute DialogOption *Options[];
  /// Returns the number of options in this dialog.
  readonly import attribute int OptionCount;
  /// Returns the built-in Dialog* for this dialog.
  readonly import attribute Dialog *AsDialog;
  /// Returns the ID of this dialog.
  readonly import attribute int ID;
  /// Gets/sets the top shown option when this dialog is run.
  import attribute int TopOption;
  protected int id;
  protected int topOption;
  protected int optionIndex;
};

managed struct Padding_t;

autoptr managed struct DialogArrow
{
  /// Gets/sets the graphic to use when this dialog arrow is disabled.
  int DisabledGraphic;
  /// Gets whether this dialog arrow is currently enabled, based on whether the dialog can scroll up or down.
  readonly import attribute bool Enabled;
  /// Gets/sets the graphic to use when the mouse is over this dialog arrow.
  int MouseOverGraphic;
  /// Gets/sets the normal graphic to use for this dialog arrow when enabled.
  int NormalGraphic;
  /// Gets the padding info for this dialog arrow.
  readonly import attribute Padding_t *Padding;
  /// Gets/sets the graphic to use when the mouse is over this dialog arrow and the left mouse button is held down.
  int PushedGraphic;
  protected int graphic;
  protected int x;
  protected int xOffset;
  protected int y;
  protected int yOffset;
};

autoptr managed struct DialogArrows
{
  /// Gets the dialog arrow used for scrolling down.
  readonly import attribute DialogArrow Down;
  /// Gets/sets which side of the dialog the scroll arrows should align to (left/right).
  FloatStyle Float;
  /// Gets the dialog arrow used for scrolling up.
  readonly import attribute DialogArrow Up;
};

managed struct DialogBorderDecoration;

autoptr managed struct DialogBackground
{
  /// Gets/sets the anchor point for the dialog's background graphic (ignored if graphic is stretched to fit).
  AnchorPoint_t AnchorPoint;
  /// Gets the border decoration info for the dialog background.
  readonly import attribute DialogBorderDecoration *BorderDecoration;
  /// Gets/sets the dialog background color.
  int Color;
  /// Gets/sets the dialog background graphic.
  int Graphic;
  /// Gets/sets how the background graphic is drawn.
  DialogBackgroundStyle Style;
  /// Gets/sets the transparency of the dialog background.
  int Transparency;
};

autoptr managed struct DialogBorderDecoration
{
  /// Gets/sets the graphic for the top border decoration.
  int Top;
  /// Gets/sets the graphic for the top-left corner decoration.
  int TopLeftCorner;
  /// Gets/sets the graphic for the top-right corner decoration.
  int TopRightCorner;
  /// Gets/sets the graphic for the left border decoration.
  int Left;
  /// Gets/sets the graphic for the bottom border decoration.
  int Bottom;
  /// Gets/sets the graphic for the bottom-left corner decoration.
  int BottomLeftCorner;
  /// Gets/sets the graphic for the bottom-right corner decoration.
  int BottomRightCorner;
  /// Gets/sets the graphic for the right border decoration.
  int Right;
};

autoptr managed struct DialogBullet
{
  /// Gets/sets the dialog bullet graphic used for the active dialog option (that the mouse is over).
  int ActiveGraphic;
  /// Gets/sets the dialog bullet graphic used for a dialog option that has been previously chosen.
  int ChosenGraphic;
  /// Gets/sets which side of the dialog option text that the bullet appears on.
  FloatStyle Float;
  /// Gets/sets the dialog bullet graphic used for normal dialog options (not chosen or active).
  int NormalGraphic;
  /// Gets the padding info for the dialog bullet.
  readonly import attribute Padding_t *Padding;
  /// Gets/sets whether the bullet should realign itself to the text (false) or maintain a static position (true).
  bool StaticPosition;
};

autoptr managed struct DialogOption
{
  /// Gets/sets whether this dialog option has been chosen.
  import attribute bool HasBeenChosen;
  /// Gets the dialog that this option belongs to.
  readonly import attribute __ScrollableDialog_t OwningDialog;
  /// Gets/sets the state of this dialog option.
  import attribute DialogOptionState State;
  /// Gets the text for this dialog option. For tagged options, this returns the modified text.
  readonly import attribute String Text;
  protected int id;
  protected int owningDialogID;
};

autoptr managed struct Padding_t
{
  /// Gets/sets the padding at the top of this item.
  int Top;
  /// Gets/sets the padding to the left of this item.
  int Left;
  /// Gets/sets the padding at the bottom of this item.
  int Bottom;
  /// Gets/sets the padding to the right of this item.
  int Right;
};

struct ScrollingDialog_t
{
  /// Sets the RESULT of the specified TAG in a dialog option. Adds TAG if it does not exist.
  import void SetTag(String tag, String result);
  /// Gets/sets the anchor point for the dialog if autosize changes its size.
  AnchorPoint_t AnchorPoint;
  /// Gets/sets whether the dialog should automatically shrink its width.
  bool AutosizeWidth;
  /// Gets/sets whether the dialog should automatically shrink its height.
  bool AutosizeHeight;
  /// Gets the background info for the dialog.
  writeprotected DialogBackground Background;
  /// Gets the dialog bullet info.
  writeprotected DialogBullet Bullet;
  /// Gets the info for the specified dialog.
  writeprotected __ScrollableDialog_t Dialogs[];
  /// Gets/sets the font to use for the dialog.
  FontType Font;
  /// Gets/sets the maximum height to use for the dialog.
  import attribute int Height;
  /// Gets/sets the amount of space between dialog options.
  import attribute int LineSpacing;
  /// Gets/sets the minimum height for the dialog.
  import attribute int MinHeight;
  /// Gets/sets the minimum width for the dialog.
  import attribute int MinWidth;
  /// Gets/sets whether dialog options go upwards when drawn.
  import attribute bool OptionsGoUpwards;
  /// Gets/sets the option numbering style (drawn or keyboard shortcuts only) for the dialog.
  import attribute DialogOptionNumberStyle OptionsNumberStyle;
  /// Gets/sets the option shortcut style (for keyboard shortcuts) for the dialog.
  DialogOptionShortcutStyle OptionsShortcutStyle;
  /// Gets the padding info for the dialog.
  writeprotected Padding_t Padding;
  /// Gets/sets the TAG to use for the player name. This tag will always be replaced with the CURRENT player's name.
  import attribute String PlayerNameTag;
  /// Gets/sets whether the dialog should reset the top option when it exits.
  bool ResetTopOptionOnExit;
  /// Gets the scroll arrow info for the dialog.
  writeprotected DialogArrows ScrollArrows;
  /// Gets the last selected dialog option. This is ONLY useful in the dialog scripts, where it can be used with tagged options.
  writeprotected DialogOption SelectedOption;
  /// Gets/sets the text color for the active dialog option.
  import attribute int TextColorActive;
  /// Gets/sets the text alignment for the dialog.
  Alignment TextAlignment;
  /// Gets/sets the text color for previously chosen dialog options.
  import attribute int TextColorChosen;
  /// Gets/sets the text color for normal dialog options (not active or chosen).
  int TextColorNormal;
  /// Gets/sets the top option for the currently running dialog.
  import attribute int TopOption;
  /// Gets/sets the maximum width to use for the dialog.
  import attribute int Width;
  /// Gets/sets the initial X coordinate of the dialog.
  int X;
  /// Gets/sets the initial Y coordinate of the dialog.
  int Y;
  protected int height;
  protected int minHeight;
  protected int minWidth;
  protected String playerNameTag;
  protected int width;
};

import ScrollingDialog_t ScrollingDialog;
 z�m        ej��