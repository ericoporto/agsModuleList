AGSScriptModule    SSH Credits script module, to replace the plugin Credits 1.19 �C  // Main script for module 'Credits'

int CreditShow; // which one are we showing now?

CreditSequence Credits[CREDIT_MAX_SEQUENCES];
export Credits;

// Make getting sprite sizes work across v2.71 and v2.72
function GetSpriteHeight(int slot) {
  DynamicSprite *tmp=DynamicSprite.CreateFromExistingSprite(slot);
  int height=tmp.Height;
  tmp.Delete();
  return height;
}

function GetSpriteWidth(int slot) {
  DynamicSprite *tmp=DynamicSprite.CreateFromExistingSprite(slot);
  int width=tmp.Width;
  tmp.Delete();
  return width;
}


protected function CreditSequence::find_free() {
  int i=0;
  while ((i<CREDIT_MAX_LINES) && (this.line[i] != null)) {
    i++;
  }
  if (i==CREDIT_MAX_LINES)
    Display("Credit Module has reached maximum %d lines, contact game author and tell them to increase CREDIT_MAX_LINES", 
							CREDIT_MAX_LINES);
	else return i;
}

// TODO in add functions: add linebreaks for word-wrapping typed text

protected String CreditSequence::wordwrap(String s, int font, int width) {
  String t=s;   // input
  String l="";  // line
  String wl=""; // wrapped line
  String w="";  // word
  String o="";  // output
  int i=0;
  while (i<t.Length) {
    char c=t.Chars[i];
    l=l.AppendChar(c);
    if (c=='[') {
      o=o.Append(l);
      w="";
      l="";
      wl="";
    } else {
			if (GetTextWidth(l, font)>=width) {
				o=o.Append(wl);
				o=o.AppendChar('[');
				wl="";
				if (c==' ') {
					wl=wl.Append(w);
  				l=w;
					w="";
				} else {
				  w=w.AppendChar(c);
					l=w;
				}
			} else {
				if (c==' ') {
					if (wl!="") wl=wl.AppendChar(' ');
					wl=wl.Append(w);
					w="";
				} else {
				  w=w.AppendChar(c);
				}
      }
      
    }
      
    i++;
  }
  o=o.Append(l);
  return o;
}

function CreditSequence::AddTitle(String t, int x, int font, int colour, int y, CreditTransition_t start, CreditTransition_t end) {
	int n=this.find_free();
  t=GetTranslation(t);
  this.line[n]=t;
	if (font<0) this.fontimage[n]=this.DefaultTitleFont;
	else this.fontimage[n]=font;
	if (x < -1) this.x_pos[n]=this.DefaultTitleX;
  else this.x_pos[n]=x;
	if (y < -1) this.y_pos[n]=this.DefaultTitleY;
  else this.y_pos[n]=y;
  if (start < 0) this.starttrans[n]=this.DefaultTitleStartTransition;
  else this.starttrans[n]=start;
  if (end < 0) this.endtrans[n]=this.DefaultTitleEndTransition;
  else this.endtrans[n]=end;
	if (colour < 0) this.colour[n]=this.DefaultTitleColour;
  else this.colour[n]=colour;
  if (this.starttrans[n]==eCreditTypewriter) {
    int width=system.viewport_width;
    if (this.x_pos[n]!=eCreditCentred) width=width-this.x_pos[n];
		this.line[n]=this.wordwrap(t, this.fontimage[n], width);
	}
}
 
function CreditSequence::AddCredit(String t, int x, int font, int colour, int y, CreditTransition_t start, CreditTransition_t end) {
	int n=this.find_free();
  t=GetTranslation(t);
 	this.line[n]=t;
	if (font<0) this.fontimage[n]=this.DefaultCreditFont;
	else this.fontimage[n]=font;
	if (x < -1) this.x_pos[n]=this.DefaultCreditX;
  else this.x_pos[n]=x;
	if (y < -1) this.y_pos[n]=this.DefaultCreditY;
  else this.y_pos[n]=y;
  if (start < 0) this.starttrans[n]=this.DefaultCreditStartTransition;
  else this.starttrans[n]=start;
  if (end < 0) this.endtrans[n]=this.DefaultCreditEndTransition;
  else this.endtrans[n]=end;
	if (colour < 0) this.colour[n]=this.DefaultCreditColour;
  else this.colour[n]=colour;
  if (this.starttrans[n]==eCreditTypewriter) {
    int width=system.viewport_width;
    if (this.x_pos[n]!=eCreditCentred) width=width-this.x_pos[n];
		this.line[n]=this.wordwrap(t, this.fontimage[n], width);
	}
}

function CreditSequence::AddImage(int sprite, int x, int valign, CreditTransition_t start, CreditTransition_t end) {
	int n=this.find_free();
	this.line[n]=CREDIT_IMAGE;
	this.fontimage[n]=-sprite;
  this.x_pos[n]=x;
  this.y_pos[n]=valign;
  if (start < 0) this.starttrans[n]=this.DefaultImageStartTransition;
  else this.starttrans[n]=start;
  if (end < 0) this.endtrans[n]=this.DefaultImageEndTransition;
  else this.endtrans[n]=end;
}

function CreditSequence::Pause() {
  if (CreditShow==this.ID) CreditShow=-1;
  else if ((CreditShow!=this.ID) && (this.Running == eCreditRunning))
		CreditShow=this.ID;
}

function CreditSequence::Reset(int id) {
  this.DefaultCreditColour=0;
  this.DefaultCreditFont=0;
  this.DefaultCreditX=eCreditCentred;
  this.DefaultCreditY=eCreditCentred;
  this.DefaultTitleColour=0;
  this.DefaultTitleFont=0;
  this.DefaultTitleX=eCreditCentred;
  this.DefaultTitleY=eCreditCentred;
  this.LineSeparation=8;
  if (id>=0) this.ID=id;
  this.line[0]=null;
  this.Running=eCreditWait;
  this.StartY=system.viewport_height;
  this.MinY=0;
  this.CreditStyle=eCreditScrolling;
  this.EOLSound=-1;
  this.SpaceSound=-1;
  this.TypeSound=-1;
  this.SlideSpeed=1;
  this.JumpToRoomAtEnd=-1;
  this.StaticSpecialChars=CREDIT_DEFAULTSTATICSPECIAL;
  // TBD: add more resets
  // Go through overlays and remove?
}

protected function CreditSequence::endprev(int n, char c) {
  int i=0;
  
  while (i<n) {
    char e=this.line[i].Chars[this.line[i].Length-1];
    String s=String.Format("%c", e);
    if (e==c || (this.StaticSpecialChars.Contains(s)<0)) {
			this.starttrans[i]=eCreditTransDefault;
		}
    i++;
  }
}

protected function CreditSequence::cleartrans(int inc) {
  int ln=this.nextline;
	String nl=this.line[ln];
	String s=nl.Substring(nl.Length-1, 1);
	char c=s.Chars[0];
	if (this.StaticSpecialChars.Contains(s)<0) {
		this.starttrans[ln]=eCreditTransDefault;
	  this.endprev(ln, '[');
	} else {
	  this.nextline+=inc;
	}
}

protected function CreditSequence::checkline() {
  int ln=this.nextline;
  int id=this.ID;
	String nl=this.line[ln];
	int x=this.x_pos[ln];
	int y=this.y_pos[ln];
	if (nl==null) {  return 0; }
	if (this.CreditStyle==eCreditStatic) {
	  if (this.ol[ln]==null) {
	    if (nl==CREDIT_IMAGE) {
				int spr=-this.fontimage[ln];
				this.oh[ln]=GetSpriteHeight(spr);
				this.ow[ln]=GetSpriteWidth(spr);
				if (x==eCreditCentred) x=(system.viewport_width-this.ow[ln])/2;
				if (y==eCreditCentred) y=(system.viewport_height-this.oh[ln])/2;
				this.x_pos[ln]=x;
				this.y_pos[ln]=y;
	      if (this.starttrans[ln]==eCreditSlideBottom) {
					this.ol[ln]=Overlay.CreateGraphical(x, system.viewport_height, spr, true);
					this.timer=0;
				} else if (this.starttrans[ln]==eCreditSlideTop) {
					this.ol[ln]=Overlay.CreateGraphical(x, 0, spr, true);
					this.ol[ln].Y=-this.oh[ln];
					this.timer=0;
				} else if (this.starttrans[ln]==eCreditSlideLeft) {
					this.ol[ln]=Overlay.CreateGraphical(0, y, spr, true);
					this.ol[ln].X=-this.ow[ln];
					this.timer=0;
				} else if (this.starttrans[ln]==eCreditSlideRight) {
					this.ol[ln]=Overlay.CreateGraphical(system.viewport_width, y, spr, true);
					this.timer=0;
				} else {
				  // Simple
 					this.ol[ln]=Overlay.CreateGraphical(x, y, spr, true);
					this.timer=this.ExitDelay;
					//this.starttrans[ln]=eCreditTransDefault;
					this.cleartrans(0);
				}
		  } else {
		    while (nl.Length>0 && this.StaticSpecialChars.Contains(nl.Substring(0, 1))>=0) {
					this.endprev(ln, nl.Chars[0]); // Clear all old lines that ended with that char
					this.line[ln]=this.line[ln].Substring(1, nl.Length-1); // Chop it off
					nl=this.line[ln];
				}
		    // Remove terminal [ or ] from that to be displayed (not from array, though)
		    if (nl.Length>0) {
					String lc=nl.Substring(nl.Length-1, 1);
					if (this.StaticSpecialChars.Contains(lc)>=0) nl=nl.Truncate(nl.Length-1);
				}
				this.oh[ln]=GetTextHeight(nl, this.fontimage[ln], system.viewport_width);
				this.ow[ln]=GetTextWidth(nl, this.fontimage[ln]);
				if (nl.Length!=0) {
					if (x==eCreditCentred) x=(system.viewport_width-this.ow[ln])/2;
				  if (y==eCreditCentred) y=(system.viewport_height-this.oh[ln])/2;
					this.x_pos[ln]=x;
					this.y_pos[ln]=y;
					if (this.starttrans[ln]==eCreditSlideBottom) {
						this.ol[ln]=Overlay.CreateTextual(x, system.viewport_height, system.viewport_width, this.fontimage[ln], this.colour[ln], nl);
						this.timer=0;
					} else if (this.starttrans[ln]==eCreditSlideTop) {
						this.ol[ln]=Overlay.CreateTextual(x, 0, system.viewport_width, this.fontimage[ln], this.colour[ln], nl);
						this.ol[ln].Y= -this.oh[ln];
						this.timer=0;
					} else if (this.starttrans[ln]==eCreditSlideLeft) {
						this.ol[ln]=Overlay.CreateTextual(0, y, system.viewport_width, this.fontimage[ln], this.colour[ln], nl);
						this.ol[ln].X= -this.ow[ln];
						this.timer=0;
					} else if (this.starttrans[ln]==eCreditSlideRight) {
						this.ol[ln]=Overlay.CreateTextual(system.viewport_width, y, system.viewport_width, this.fontimage[ln], this.colour[ln], nl);
						this.timer=0;
				  } else if (this.starttrans[ln]==eCreditTypewriter) {
				    this.typet=String.Format("%c", nl.Chars[0]);
						this.ol[ln]=Overlay.CreateTextual(x, y, system.viewport_width, this.fontimage[ln], this.colour[ln], this.typet);
						this.timer=this.TypeDelay+Random(this.TypeRandom);
					} else {
						// Simple
						this.ol[ln]=Overlay.CreateTextual(x, y, system.viewport_width, this.fontimage[ln], this.colour[ln], nl);
						this.timer+=(((nl.Length / game.text_speed) + 1) * GetGameSpeed())+this.ExitDelay;
						//this.starttrans[ln]=eCreditTransDefault;
						this.cleartrans(0);
					}
		    } else {
		      this.timer=this.InterDelay;
		      this.nextline++;
		    }
		  }
		}
  } else {
		if (this.maxy<=this.StartY) {
			if (nl==CREDIT_IMAGE) {
				// Add an image in
				int spr=-this.fontimage[ln];
				//this.oh[ln]=GetGameParameter(GP_SPRITEHEIGHT, spr, 0, 0);
				//this.ow[ln]=GetGameParameter(GP_SPRITEWIDTH, spr, 0, 0);
				this.oh[ln]=GetSpriteHeight(spr);
				this.ow[ln]=GetSpriteWidth(spr);
				if (x==eCreditCentred) x=(system.viewport_width-this.ow[ln])/2;
				this.ol[ln]=Overlay.CreateGraphical(x, this.maxy, spr, true);
				if (this.y_pos[ln]==eCreditAlignBelow) 
						this.maxy+=this.oh[ln];
				else
						this.maxy+=this.y_pos[ln];
			} else {
				this.oh[ln]=GetTextHeight(nl, this.fontimage[ln], system.viewport_width);
				this.ow[ln]=GetTextWidth(nl, this.fontimage[ln]);
				if (nl.Length!=0) {
					if (x==eCreditCentred) x=(system.viewport_width-this.ow[ln])/2;
					this.ol[ln]=Overlay.CreateTextual(x, this.maxy, system.viewport_width, this.fontimage[ln], this.colour[ln], nl);
					
				} else {
					// Skip overlay for blank line, and just increment y pos
					nl="A";
				}
				this.maxy+=(this.oh[ln]+this.LineSeparation);
			}
			this.nextline++;
		}
	}
  return 1;
}
  

protected function CreditSequence::scroll () {
  // move all overlays up
  int anyleft=0;
  int i=0;
  while (i<this.nextline) {
    if (this.ol[i]!=null) {
			this.ol[i].Y--;
			if ((this.ol[i].Y+this.oh[i])<this.MinY) {
				this.ol[i].Remove();
				this.ol[i]=null;
			}
			else anyleft=1;
		}
		i++;
  }
  this.maxy--;
  this.checkline();
  if (!anyleft) {
    this.Running=eCreditFinished;
		CreditShow=-1;
		if (this.JumpToRoomAtEnd>=0) player.ChangeRoom(this.JumpToRoomAtEnd);
	}
}

function CreditSequence::Run() {
	CreditShow=this.ID;
	this.Running=eCreditRunning;
	this.nextline=0;
  this.maxy=this.StartY;
  this.checkline();
}


function CreditSequence::Stop() {
  int i=0;
  while (i<CREDIT_MAX_LINES) {
    if (this.ol[i]!=null && this.ol[i].Valid) this.ol[i].Remove();
    this.ol[i]=null;
    i++;
  }
  this.timer=0;
	this.Running=eCreditFinished;
	CreditShow=-1;
}


function CreditSequence::IsRunning() {
  return this.Running;
}


protected function CreditSequence::type() {
  int ln=this.nextline;
	String nl=this.line[ln];
	String tl=this.typet;
	if (tl==nl) {
		this.timer=this.ExitDelay;
		if (this.EOLSound>=0) PlaySound(this.EOLSound);
		this.cleartrans(0);
		this.nextline++;
		this.typet="";
	} else {
	  char c=nl.Chars[tl.Length];

	  tl=tl.AppendChar(c);
	  this.typet=tl;
	  this.ol[ln].SetText(system.viewport_width, this.fontimage[ln], this.colour[ln], tl);
	  if (c == ' ') { 
			if (this.SpaceSound>=0) PlaySound(this.SpaceSound);
	  } else if (c == '[') { 
	    if ((tl.Length!=nl.Length) && (this.EOLSound>=0)) PlaySound(this.EOLSound);
	  } else { 
			if (this.TypeSound>=0) PlaySound(this.TypeSound);
	  }
		this.timer=this.TypeDelay+Random(this.TypeRandom);
	}
}

protected function CreditSequence::update() {
  // move all overlays up

  int anyleft=0;
  int nl=this.nextline;
  int i=0;
  //if (this.CreditStyle==eCreditStatic) nl++;
  while (i<=nl) {
    if (this.ol[i]!=null) {
      if (this.starttrans[i]==eCreditTransDefault) {
        // exit transition
        if (this.endtrans[i]==eCreditSlideBottom) {
          this.timer=0;
          this.ol[i].Y+=this.SlideSpeed;
          if ((this.ol[i].Y)>this.StartY) {
						this.ol[i].Remove();
						this.ol[i]=null;
						if (i==nl) {
							this.nextline++;
							if (!anyleft) this.timer=this.InterDelay;
					  }
					}
			  } else if (this.endtrans[i]==eCreditSlideTop) {
          this.timer=0;
          this.ol[i].Y-=this.SlideSpeed;
          if ((this.ol[i].Y+this.oh[i])<this.MinY) {
						this.ol[i].Remove();
						this.ol[i]=null;
						if (i==nl) {
							this.nextline++;
							if (!anyleft) this.timer=this.InterDelay;
					  }
					}
			  } else if (this.endtrans[i]==eCreditSlideLeft) {
          this.timer=0;
			    this.ol[i].X-=this.SlideSpeed;
          if ((this.ol[i].X+this.ow[i])<0) {
						this.ol[i].Remove();
						this.ol[i]=null;
						if (i==nl) {
							this.nextline++;
							if (!anyleft) this.timer=this.InterDelay;
					  }
					}
			  } else if (this.endtrans[i]==eCreditSlideRight) {
          this.timer=0;
			    this.ol[i].X+=this.SlideSpeed;
          if ((this.ol[i].X)>=system.viewport_width) {
						this.ol[i].Remove();
						this.ol[i]=null;
						if (i==nl) {
							this.nextline++;
							if (!anyleft) this.timer=this.InterDelay;
					  }
					}
			  } else {
          this.timer=this.InterDelay;
					this.ol[i].Remove();
					this.ol[i]=null;
					if (i==nl) this.nextline++;
				}
		  } // if starttrans==default
      anyleft=1;
		} // if overlay null
		i++;
  } //while
  i=nl;
  if (this.ol[i]!=null) {
		    // Incoming
        if (this.starttrans[i]==eCreditSlideBottom) {
          if (this.ol[i].Y<=this.y_pos[i]) {
						this.ol[i].Y=this.y_pos[i];
						this.cleartrans(1);
	          this.timer+=(((this.line[i].Length / game.text_speed) + 1) * GetGameSpeed())+this.ExitDelay;
					} else {
						this.ol[i].Y-=this.SlideSpeed;
						this.timer=0;
					}
 			  } else if (this.starttrans[i]==eCreditSlideTop) {
          if (this.ol[i].Y>=this.y_pos[i]) {
						this.ol[i].Y=this.y_pos[i];
						this.cleartrans(1);
	          this.timer+=(((this.line[i].Length / game.text_speed) + 1) * GetGameSpeed())+this.ExitDelay;
					} else {
						this.ol[i].Y+=this.SlideSpeed;
						this.timer=0;
					}
			  } else if (this.starttrans[i]==eCreditSlideLeft) {
          if (this.ol[i].X>=this.x_pos[i]) {
						this.ol[i].X=this.x_pos[i];
						this.cleartrans(1);
	          this.timer+=(((this.line[i].Length / game.text_speed) + 1) * GetGameSpeed())+this.ExitDelay;
					} else {
						this.ol[i].X+=this.SlideSpeed;
						this.timer=0;
					}
			  } else if (this.starttrans[i]==eCreditSlideRight) {
          if (this.ol[i].X<=this.x_pos[i]) {
						this.ol[i].X=this.x_pos[i];
						this.cleartrans(1);
	          this.timer+=(((this.line[i].Length / game.text_speed) + 1) * GetGameSpeed())+this.ExitDelay;
					} else {
						this.ol[i].X-=this.SlideSpeed;
						this.timer=0;
					}
			  } else if (this.starttrans[i]==eCreditSimple) {
			    this.cleartrans(1);
			  } else if (this.starttrans[i]==eCreditTypewriter) {
			    this.type();
		    }
  }
  if (this.nextline!=nl) {
      anyleft+=this.checkline();
  }
  if (!anyleft ) {
    this.Running=eCreditFinished;
		CreditShow=-1;
		if (this.JumpToRoomAtEnd>=0) player.ChangeRoom(this.JumpToRoomAtEnd);
	}
}

function CreditSequence::rep_ex () {
#ifdef CREDITDEBUG
  dbgLabel.Text=String.Format("%4d %4d %s",  this.nextline,  this.timer,  this.line[this.nextline]);
#endif  
  if (this.timer==0) {
    if (this.CreditStyle==eCreditScrolling ) {
			// Do scroll
			this.scroll();
			this.timer=this.Delay;
		} else if (this.CreditStyle==eCreditStatic ) {
		  this.update();
		}
  } else {
    this.timer--;
  }
}

function game_start () {
  int i=0;
  while (i<CREDIT_MAX_SEQUENCES) {
    Credits[i].Reset(i);
    i++;
  }
	CreditShow=-1;
}

function repeatedly_execute () {
	if (CreditShow >= 0) {
	  Credits[CreditShow].rep_ex();
  } 
}

int ee;

function on_key_press (int keycode) {
  if ((keycode=='S') && (ee<2)) ee++;
  else if ((keycode=='H') && (ee==2)) ee++;
  else if ((keycode=='?') && (ee==3)) {
		Overlay *cmee=Overlay.CreateTextual(2, 2, 300, 1, 60000, "Credits module 1.13 by SSH");
		Wait(40);
		cmee.Remove();
	}
} �-  // Script header for module 'Credits'
//
// Author: Andrew MacCormack (SSH)
//   Please use the PM function on the AGS forums to contact
//   me about problems with this module
// 
// Abstract: Provides scrolling credits of text or images
// Dependencies:
//
//   AGS 2.71RC2 or later
//
// Functions:
// 	 Credits[n].AddTitle(String t, optional int x, optional int font, optional int colour)
//      This adds a line to the credits in the "Title" style, with x position,
//      font and colour optional overrides.
//      Properties DefaultTitleX, DefaultTitleFont and DefaultTitleColour set the
//      charactersitics of the Title style.
//
//      eCreditCentred can be used as x for centered text
//      eCreditXDefault can be used as x to pick up the default x position for titles
//      eCreditFontDefault can be used for font to pick up the default font
//      eCreditColourDefault can be used for colour to pick up the default colour
//
//   Credits[n].AddCredit(String t, optional int x, optional int font, optional int colour);
//      This adds a line to the credits in the "Credit" style, with x position,
//      font and colour optional overrides.
//      Properties DefaultCreditX, DefaultCreditFont and DefaultCreditColour set the
//      charactersitics of the Credit style.
//
//      enumerated constants can be used as with AddTitle
//
//   Credits[n].AddImage(int sprite, optional int x, optional int valign)
//      This adds an image to the credits, with optional x position and alignment
//      specified. x defaults to Centred, valign defaults to "next credit comes at
//      bottom". Specifying a number for valign will make the next credit line appear
//      that many pixels below the top of the image.
//      
//   Credits[n].Run();
//      This starts the credit sequence off rolling. The credits will appear at Y
//      position Credit[n].StartY and scroll up until they pass Credit[n].MinY. These 
//      properties default to the top and bottom of the screen.
//
//   Credits[n].Pause();
//      This will pause a running credit scroller or restart a paused one.
//
//   Credits[n].IsRunning();
//      This function returns a value of type CreditRunning_t, which will be equal to
//      eCreditFinished when the sequence has finished.
//
//   Credits[n].Stop();
//      Terminate credit sequence early: e.g. skipping or abort, etc.
//
// Configuration:
//   The Credits module operates in one of two modes:
//     Credits[n].CreditStyle=eCreditScrolling; //  (Default)
//   or
//     Credits[n].CreditStyle=eCreditStatic; //  (Default)
//
//   Scrolling Mode:
//
//   The speed of scrolling can be configured with Credit[n].Delay. This determines
//   the number of cycles between each pixel moves by the scrolling credits.
//
//   The spacing between text lines can be changed by using Credits[n].LineSeparation
//   which sets the number of pixels after a text line before the next credit item.
//
//   Static Mode:
//
//   Static mode has a variety of transitions for the text or image entering and 
//   leaving the screen:
//     eCreditSimple       Instant appearing or disappearing
//     eCreditTypewriter   (text appear only) Typewriter simulation
//     eCreditSlideLeft    Slide text in from/out to the left of screen
//     eCreditSlideRight   Slide text in from/out to the right of screen
//     eCreditSlideTop     Slide text in from/out to the top of screen
//     eCreditSlideBottom  Slide text in from/out to the bottom of screen
//
//   In the middle of a credit, a '[' means a line break, but text will be left-aligned
//   within the same credit, so centering can be messed up by this.
//
//   Also in static mode, a '[' character at the end of a credit line means that the
//   line will not disappear before the next line arrives. All such lines will be cleared
//   by the next line with no special character at the end. You can manually clear any
//   such uncleared lines by putting a '[' as the first character of a line. If you wish
//   to have a linebreak at the beginning of text, preceed it with a space: e.g.
//   " [my text".
//
//   By default, the ']' character can also be used at the end of a line in a similar
//   way, except that such lines are not cleared by following lines with no special
//   characters: a manual clear by using an initial ']' must be done to clear the line.
//
//   By changing the Credits[n].StaticSpecialChars variable, you can add extra characters
//   with the same behaviour, each one only being cleared by the special character 
//   appearing at the start of a following line. Multiple special characters may appear
//   at the start of a line until the first non-special character. Only one special 
//   character at the end of the line applies, however.
//     
//   General:
//
//   Credits come in two "styles": titles and credits. The default settings for these
//   can be configured separately and the functions AddCredit and AddTitle use the
//   appropriate templates.
//
//   The DefaultCreditN and DefaultTitleN properties set those templates, where N can
//   be X, Colour, Font and in the case of static credits, Y, StartTransition and 
//   EndTransition.
//
//   More advanced configuration involves changing CREDIT_MAX_LINES to have more lines
//   per credit sequence, changing CREDIT_MAX_SEQUENCES to have more different 
//   sequences and if you for some reason want the string "<img>" as a credit, change
//   CREDIT_IMAGE to be some other string that you do not use.
//
//   The property Credits[n].JumpToRoomAtEnd can be set to a room number or -1 if no
//   room jump is required at the end of the credits.
//
// Example:
//   Credits[0].DefaultCreditFont=3;
//   Credits[0].DefaultTitleFont=3;
//   Credits[0].DefaultTitleColour=65000;
//   Credits[0].DefaultCreditColour=15;
//   Credits[0].Delay=1;
//
//   Credits[0].AddTitle("Scripting by");
//   Credits[0].AddCredit("SSH");
//   Credits[0].AddImage(12, eCreditCentred, eCreditAlignBelow);
//   Credits[0].AddTitle("Credit Module by");
//   Credits[0].AddCredit("SSH again!");
//   Credits[0].Run();
//
// Caveats:
//   If more lines of credit are onscreen than AGS allows overlays, then this module
//   will crash. Use a bigger font.
//   Not extensively tested: please report bugs on the AGS forums
//   
// Revision History:
//
// 22 Sep 05: v1.0  First release of Scrolling Credits module
// 26 Oct 05: v1.1  First release of full Credits module
// 26 Oct 05: v1.11 Added word wrap to typewriter mode
// 27 Oct 05: v1.12 Fixed debug code left in and 800x600 compatibility
// 28 Feb 06: v1.13 Added property to jump to new room at end of credits
// 18 Apr 06: v1.14 Added Stop function to allow credit termination
// 25 Jul 06: v1.15 Tried to fix the problems with simple start transitions
// 26 Jul 06: v1.16	Another attempt at fixing top, etc.
// 27 Jul 06: v1.17 Added extra, programmable, static special characters
// 16 Feb 07: v1.18 Added translation support and use new strings only
// 26 Oct 07: v1.19 Actually made translations work!
//
// Licence:
//
//   Credits AGS script module
//   Copyright (C) 2005-2007 Andrew MacCormack
//
//   This library is free software; you can redistribute it and/or
//   modify it under the terms of the GNU Lesser General Public
//   License as published by the Free Software Foundation; either
//   version 2.1 of the License, or (at your option) any later version.
//
//   This library is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//   Lesser General Public License for more details.
//
//   You should have received a copy of the GNU Lesser General Public
//   License along with this library; if not, write to the Free Software
//   Foundation, Inc, 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//=========================================================

#define CREDIT_MAX_LINES 100
#define CREDIT_MAX_SEQUENCES 4
#define CREDIT_IMAGE "<img>"
#define CREDIT_DEFAULTSTATICSPECIAL "[]"

// Fake enumerations and make them autocomplete
#define eCreditCentred -1  
// import int eCreditCentred;
#define eCreditXDefault -2  
#define eCreditYDefault -2  
// import int eCreditXDefault;
// import int eCreditYDefault;
#define eCreditFontDefault -1  
// import int eCreditFontDefault;
#define eCreditColourDefault -1 
// import int eCreditColourDefault;
#define eCreditAlignBelow -1 
// import int  eCreditAlignBelow;
#define eCreditTransDefault -1
// import int  eCreditTransDefault;

enum CreditRunning_t { eCreditWait, eCreditRunning, eCreditFinished};
enum CreditStyle_t { eCreditScrolling, eCreditStatic };
enum CreditTransition_t {eCreditSimple=0, eCreditTypewriter, 
				eCreditSlideLeft, eCreditSlideRight, eCreditSlideTop, eCreditSlideBottom };
// Fades not possible with overlays, because of lack of transparency
// However we could maybe take a colour to fade to and gradually morph the RGB values
// to the next colour?


struct CreditSequence {
  import function AddTitle(String t, int x=-2, int font=-1, int colour=-1, int y=-2, CreditTransition_t start=-1, CreditTransition_t end=-1);
  import function AddCredit(String t, int x=-2, int font=-1, int colour=-1, int y=-2, CreditTransition_t start=-1, CreditTransition_t end=-1);
  import function AddImage(int sprite, int x=-1, int valign=-1, CreditTransition_t start=-1, CreditTransition_t end=-1);
  
  import function Run();
	import function Pause();
	import function IsRunning();
	import function Stop();
	
  int LineSeparation;
  int Delay;
  int DefaultTitleX;
  int DefaultTitleY;
  int DefaultTitleFont;
  int DefaultTitleColour;
  CreditTransition_t DefaultTitleStartTransition;
  CreditTransition_t DefaultTitleEndTransition;
  int DefaultCreditX;
  int DefaultCreditY;
  int DefaultCreditFont;
  int DefaultCreditColour;
  CreditTransition_t DefaultCreditStartTransition;
  CreditTransition_t DefaultCreditEndTransition;
  CreditTransition_t DefaultImageStartTransition;
  CreditTransition_t DefaultImageEndTransition;
  int StartY;
  int MinY;
  CreditStyle_t CreditStyle;
  int SpaceSound;
  int TypeSound;
  int EOLSound;
  int TypeDelay;
  int TypeRandom;
  int SlideSpeed;
  int ExitDelay;
  int InterDelay;
  int JumpToRoomAtEnd;
  String StaticSpecialChars;

	// Not protected, but please don't touch or use
  import function rep_ex();
	import function Reset(int id=-1);

  // Internal stuff
  protected import function find_free();
  protected import function scroll();
  protected import function checkline();
  protected import function update();
  protected import function type();
  protected import function endprev(int n, char c='[');
  protected import function cleartrans(int inc);
  protected import String wordwrap(String s, int font, int width);
  protected String line[CREDIT_MAX_LINES];
  protected int x_pos[CREDIT_MAX_LINES];
  protected int fontimage[CREDIT_MAX_LINES];
  protected int colour[CREDIT_MAX_LINES];
  protected Overlay *ol[CREDIT_MAX_LINES];
  protected int oh[CREDIT_MAX_LINES];
  protected int ow[CREDIT_MAX_LINES];
  protected CreditTransition_t starttrans[CREDIT_MAX_LINES];
  protected CreditTransition_t endtrans[CREDIT_MAX_LINES];
  protected int y_pos[CREDIT_MAX_LINES];
	protected CreditRunning_t Running;
  protected int maxy;
  protected int nextline;
  protected int timer;
  protected int ID;
  protected String typet;
};

import CreditSequence Credits[CREDIT_MAX_SEQUENCES];
 �%�C        ej��