AGSScriptModule    SSH Give multiple responses to the same event, easily MultiResponse 1.2 i  // Main script for module 'MultiResponse'

MultiResponse Multi;
export Multi;


protected function MultiResponse::hash(String rar) {
  int l=rar.Length;
  return ((l + rar.Chars[l/2]) % MULTIR_HASHSIZE);
}

protected function MultiResponse::Find(String r) {
	if (this.cache==null || r!=this.cache) {
	  if (this.cache!=null) {
			int hashedc=this.hash(this.cache);
	    // Writeback cache into responses
			String rep=String.Format("%c%s", this.count, this.cache);
			if (this.pos<0) {
			  // Cached item not in responses, so append it
				if (this.responses[hashedc]==null) this.responses[hashedc]=rep;
				else this.responses[hashedc]=this.responses[hashedc].Append(rep);
			} else {
			  // Update count of cached item
			  this.responses[hashedc]=this.responses[hashedc].ReplaceCharAt(this.pos, this.count);
			}
		}
    // Search
		int hashedr=this.hash(r);
		this.cache=r;
    if (this.responses[hashedr]!=null) {
		  // If there are responses, search them
			this.pos=this.responses[hashedr].Contains(r)-1;
			if (this.pos>=0) {
			  this.count=this.responses[hashedr].Chars[this.pos];
			} else {
			  this.count=1;
			}
	  } else {
	    // First response ever
	    this.count=1;
	    this.pos=-1;
		}
	}
	// else cache already holds the right numbers anyway
}

protected String MultiResponse::Nth(String rr) {
	int count=1; // 1==never used, 2==done first, etc. so..
  int pos=rr.Contains(MULTIR_DELIMITER);
	while (count<this.count) {
		if (pos<0) return rr;
		pos++;
		rr=rr.Substring(pos, rr.Length-pos);
		count++;
		pos=rr.Contains(MULTIR_DELIMITER);
  }
	this.count++; // increment the count
	if (pos>=0) { 
	  this.last=0;
		return rr.Substring(0, pos);
	}
	else {
	  this.last=1;
		return rr;
	}
}

String MultiResponse::SRespond(String r) {
	this.Find(r); // Find the string
	String reply=this.Nth(r);
	this.response=this.count-1;
	return reply;
}  

function MultiResponse::Disp(String r) {
	Display(this.SRespond(r));
  return this.response;
}

function MultiResponse::Respond(String r) {
	// Now just an alias for Disp
	this.Disp(r);
}    

function MultiResponse::Say(String r) {
  player.Say(this.SRespond(r));
  return this.response;
}

function MultiResponse::Reset(String r) {
  this.Find(r);
  this.count=1;
}

String MultiResponse::SLoop(String r) {
	this.Find(r); // Find the string
	String reply=this.Nth(r);
	this.response=this.count-1;
	if (this.last) this.count=1;
	return reply;
}

String MultiResponse::SRandom(String r) {
	int rnd=Random(5);
	int i=0;
	String reply=this.SRespond(r);
	while (i<rnd) {
	  i++;
	  reply=this.SLoop(r);
	}
	return reply;
}

function MultiSay(this Character *, String what) {
  this.Say(Multi.SRespond(what));
  return Multi.response;
}

String SMultiSay(this Character *, String what) {
  String tmp=Multi.SRespond(what);
  this.Say(tmp);
  return tmp;
}

function RandomSay(this Character *, String what) {
  this.Say(Multi.SRandom(what));
  return Multi.response;
}

function LoopSay(this Character *, String what) {
  this.Say(Multi.SLoop(what));
  return Multi.response;
}
 �  // Script header for module 'MultiResponse'
//
// Author: Andrew MacCormack (SSH)
//   Please use the messaging function on the AGS forums to contact
//   me about problems with this module
// 
// Abstract: Makes multiple responses to an interaction easy to script
//
// Dependencies:
//
//   AGS 2.71 or later
//
// Functions:
//
//  Multi.Disp(String responses)
//		Does a Display of the next response in the seuqence given. Responses are
//    separated by the ">" character. On reaching the last response, will 
//    repeat it indefinately. Returns the position of the response given (starts
//    from 1)
//
//  Multi.Response(String responses)
// 		An alias for Multi.Disp, for backwards compatibility with v1.0
//
//  Multi.Say(String responses)
//	  As for Multi.Disp, but uses player.Say to show the message
//
//  Multi.SRespond(String responses)
//    Returns the string that would be Display-ed by Multi.Disp, so that
//    the user can do what they like with it. The position that would
//    normally be returned in Multi.Disp is instead set in Multi.response
//
//  Multi.SLoop(String responses)
//		As with Multi.SRespond, but automatically loops back to the first
//    response after the last one is said
//
//  Multi.SRandom(String responses)
//		As with Multi.SRespond, but chooses a response at Random
//
//  Multi.Reset(String responses)
//    Resets the count of the given responses string to the beginning
//
// Configuration:
//
//  The MULTIR_DELIMITER #define below sets which character is used as a
//  response delimiter, usually ">".
//
//  MULTIR_HASHSIZE sets the number of strings used to keep responses in
//  there is probably little point in changing this, as the hashing
//  function is pretty simple and will not benefit greatly froma  larger table than
//  the default 100
//
// Example:
//
//  // Display each response in turn until the last one, which repeats:
//  Multi.Respond("I can count>1>2>3>Done!");
//
//  // Display each response in turn, starting again once all responses used
//  Display(Multi.SLoop("Ready>Steady>Go"));
//
// Caveats:
//
//   Could get reallly slow when you have a lot, maybe
//
// Revision History:
//
// 21 Aug 06: v1.0  First release of MultiResponse module
// 25 Aug 06: v1.1  Added more options and hashtable
// 12 May 08: v1.2  Added extender functions
//
// Licence:
//
//   MultiResponse AGS script module
//   Copyright (C) 2006 Andrew MacCormack
//
// This module is licenced under the Creative Commons Attribution Share-alike
// licence, (see http://creativecommons.org/licenses/by-sa/2.5/scotland/ )
// which basically means do what you like as long as you credit me and don't
// start selling modified copies of this module.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.


#define MULTIR_DELIMITER ">"
#define MULTIR_HASHSIZE 100

struct MultiResponse {
  import function Respond(String r);
  import function Reset(String r);
  import function Disp(String r);
  import function Say(String r);
  import String SRespond(String r);
  import String SRandom(String r);
  import String SLoop(String r);
  writeprotected int response;
  writeprotected bool last;
  protected import function hash(String rar);
  protected String responses[MULTIR_HASHSIZE];
  protected String cache;
  protected int count;
  protected int pos;
	protected import function Find(String r);
  protected import String Nth(String rr);
};

import MultiResponse Multi;

#ifdef AGS_SUPPORTS_IFVER
#ifver 3.0
import function MultiSay(this Character *, String what);
import String SMultiSay(this Character *, String what);
import function RandomSay(this Character *, String what);
import function LoopSay(this Character *, String what);
#endif
#endif �{�        ej��