AGSScriptModule    monkey0506 The Stack module introduces a vectorized stack type into which you can place any type of data. Great if you need to store data of various different types, or all of one type; this module can handle all of your data storage needs! Stack v2.0 ,  
// currently (AGS 3.4.0.3), managed structs cannot hold any pointer types
// (including String), so frustratingly we must attempt to pool them here
struct StringCache_t
{
  String Pool[];
  int Count;
  int Capacity;
};

StringCache_t StringCache;

// Grows the String cache by a factor of 2 until it matches or exceeds minCapacity.
void noloopcheck Grow(this StringCache_t*, int minCapacity)
{
  if (this.Capacity >= minCapacity) return;
  if ((this.Capacity == 1000000) || (minCapacity > 1000000))
  {
    AbortGame("Stack module error!: Attempted to grow cache capacity beyond 1000000 items.");
  }
  int copy = this.Capacity;
  do
  {
    if (this.Capacity == 0) this.Capacity = 1;
    else if (this.Capacity >= 500000) this.Capacity = 1000000;
    else this.Capacity *= 2;
  } while (this.Capacity < minCapacity);
  String pool[] = new String[this.Capacity];
  int i;
  for (i = 0; i < copy; i++)
  {
    pool[i] = this.Pool[i];
  }
  this.Pool = pool;
}

function game_start()
{
  // reserve StringCache slot 0, because int is default 0
  // and with no ctor we can't control the value of _scacheID
  // for StackData instances, so StringCache.Pool[0] == null
  StringCache.Count = 1;
  StringCache.Grow(1);
}

// Checks if the String exists in the pool. If not, it is added.
// Returns the cached index of this String.
int Cache(this String*)
{
  int i;
  for (i = 0; i < StringCache.Count; i++)
  {
    if (StringCache.Pool[i] == this) return i;
  }
  StringCache.Count++;
  StringCache.Grow(StringCache.Count);
  StringCache.Pool[i] = this;
  return i;
}

// StackData property definitions

int get_AsInt(this StackData*)
{
  if (this.Type != eStackDataInt)
  {
    return 0;
  }
  return this._idata;
}

float get_AsFloat(this StackData*)
{
  if (this.Type != eStackDataFloat)
  {
    return 0.0;
  }
  return this._fdata;
}

String get_AsString(this StackData*)
{
  if ((this.Type != eStackDataString) || (this._scacheID < 0) ||
      (this._scacheID >= StringCache.Count))
  {
    return null;
  }
  return StringCache.Pool[this._scacheID];
}

Character* get_AsCharacter(this StackData*)
{
  if ((this.Type != eStackDataCharacter) || (this._idata == -1))
  {
    return null;
  }
  return character[this._idata];
}

InventoryItem* get_AsInventoryItem(this StackData*)
{
  if ((this.Type != eStackDataInventoryItem) || (this._idata == -1))
  {
    return null;
  }
  return inventory[this._idata];
}

GUI* get_AsGUI(this StackData*)
{
  if ((this.Type != eStackDataGUI) || (this._idata == -1))
  {
    return null;
  }
  return gui[this._idata];
}

GUIControl* get_AsGUIControl(this StackData*)
{
  if ((this.Type != eStackDataGUIControl) || (this._idata == -1))
  {
    return null;
  }
  int owner = this._idata / AGS_MAX_CONTROLS_PER_GUI;
  int ctrl = this._idata % AGS_MAX_CONTROLS_PER_GUI;
  if ((owner < 0) || (owner >= Game.GUICount) ||
      (ctrl >= gui[owner].ControlCount))
  {
    return null;
  }
  return gui[owner].Controls[ctrl];
}

// end StackData property definitions

// StackData helpers (for internal access to private members)

int GetIData(this StackData*)
{
  return this._idata;
}

void SetIData(this StackData*, int value)
{
  this._idata = value;
}

float GetFData(this StackData*)
{
  return this._fdata;
}

void SetFData(this StackData*, float value)
{
  this._fdata = value;
}

int GetSCacheID(this StackData*)
{
  return this._scacheID;
}

void SetSCacheID(this StackData*, int value)
{
  this._scacheID = value;
}

void SetType(this StackData*, StackDataType value)
{
  this.Type = value;
}

// end StackData helpers

static bool StackData::IsNullOrInvalid(StackData value)
{
  return ((value == null) || (value.Type == eStackDataInvalid));
}

StackData IDataToData(static StackData, int idata, StackDataType type)
{
  StackData result = new StackData;
  result.SetIData(idata);
  result.SetType(type);
  return result;
}

static StackData StackData::IntToData(int value)
{
  return StackData.IDataToData(value, eStackDataInt);
}

static StackData StackData::FloatToData(float value)
{
  StackData result = new StackData;
  result.SetFData(value);
  result.SetType(eStackDataFloat);
  return result;
}

static StackData StackData::StringToData(String value)
{
  StackData result = new StackData;
  if (value != null)
  {
    result.SetSCacheID(value.Cache());
  }
  result.SetType(eStackDataString);
  return result;
}

static StackData StackData::StringCachedToData(int cachedID)
{
  StackData result = new StackData;
  if ((cachedID > 0) && (cachedID < StringCache.Count))
  {
    result.SetSCacheID(cachedID);
  }
  result.SetType(eStackDataString);
  return result;
}

static StackData StackData::CharacterToData(Character *value)
{
  int id = -1;
  if (value != null) id = value.ID;
  return StackData.IDataToData(id, eStackDataCharacter);
}

static StackData StackData::InventoryItemToData(InventoryItem *value)
{
  int id = -1;
  if (value != null) id = value.ID;
  return StackData.IDataToData(id, eStackDataInventoryItem);
}

static StackData StackData::GUIToData(GUI *value)
{
  int id = -1;
  if (value != null) id = value.ID;
  return StackData.IDataToData(id, eStackDataGUI);
}

static StackData StackData::GUIControlToData(GUIControl *value)
{
  int id = -1;
  if (value != null) id = ((value.OwningGUI.ID * AGS_MAX_CONTROLS_PER_GUI) + value.ID);
  return StackData.IDataToData(id, eStackDataGUIControl);
}

// Returns the cached index of a String
static int Stack::GetStringCachedID(String value)
{
  if (value == null) return -1;
  return value.Cache();
}

// Stack property definitions

int get_StringCacheCapacity(this Stack*)
{
  return StringCache.Capacity;
}

void set_StringCacheCapacity(this Stack*, int value)
{
  StringCache.Grow(value);
}

// Grows this Stack's item array until it matches or exceeds minCapacity.
void noloopcheck Grow(this Stack*, int minCapacity)
{
  if (minCapacity <= this._capacity) return;
  if ((this._capacity == 1000000) || (minCapacity > 1000000))
  {
    AbortGame("Stack module error!: Attempted to grow capacity beyond 1000000 items.");
  }
  int copy = this._capacity;
  do
  {
    if (this._capacity == 0) this._capacity = 1;
    else if (this._capacity >= 500000) this._capacity = 1000000;
    else this._capacity *= 2;
  } while (this._capacity < minCapacity);
  StackData items[] = new StackData[this._capacity];
  int i;
  for (i = 0; i < copy; i++)
  {
    items[i] = this._items[i];
  }
  this._items = items;
}

int get_Capacity(this Stack*)
{
  return this._capacity;
}

void set_Capacity(this Stack*, int value)
{
  this.Grow(value);
}

// Safely overwrites an existing item in the Stack.
bool OverwriteItem(this Stack*, int index, StackData value)
{
  if ((index < 0) || (index >= this.ItemCount) || (value == null) ||
      (value.Type == eStackDataInvalid))
  {
    return false;
  }
  this._items[index] = value;
  return true;
}

StackData geti_Items(this Stack*, int index)
{
  if ((index < 0) || (index >= this.ItemCount)) return new StackData;
  return this._items[index];
}

void seti_Items(this Stack*, int index, StackData value)
{
  this.OverwriteItem(index, value);
}

// end Stack property definitions

void Stack::Clear()
{
  int i;
  for (i = 0; i < this.ItemCount; i++)
  {
    this._items = null;
  }
}

// Push a generic item onto the Stack.
bool noloopcheck Stack::Push(StackData item, int index, bool insert)
{
  if ((item == null) || (item.Type == eStackDataInvalid))
  {
    // item was not valid, abort
    return false;
  }
  if ((index < 0) || (index > this.ItemCount) || (index == SCR_NO_VALUE))
  {
    // invalid index, force append
    index = this.ItemCount;
  }
  else if (index != this.ItemCount)
  {
    // valid index for existing item
    if (!insert)
    {
      // not inserting, overwrite item
      return this.OverwriteItem(index, item);
    }
  }
  // insert or append item
  this.ItemCount++;
  this.Grow(this.ItemCount);
  // shift items, as needed
  int i;
  for (i = this.ItemCount - 1; i > index; i--)
  {
    this._items[i] = this._items[i - 1];
  }
  // and insert our new item
  this._items[index] = item;
}

bool Stack::PushInt(int value, int index, bool insert)
{
  return this.Push(StackData.IntToData(value), index, insert);
}

bool Stack::PushFloat(float value, int index, bool insert)
{
  return this.Push(StackData.FloatToData(value), index, insert);
}

bool Stack::PushString(String value, int index, bool insert)
{
  return this.Push(StackData.StringToData(value), index, insert);
}

bool Stack::PushStringCached(int cachedID, int index, bool insert)
{
  return this.Push(StackData.StringCachedToData(cachedID), index, insert);
}

bool Stack::PushCharacter(Character *value, int index, bool insert)
{
  return this.Push(StackData.CharacterToData(value), index, insert);
}

bool Stack::PushInventoryItem(InventoryItem *value, int index, bool insert)
{
  return this.Push(StackData.InventoryItemToData(value), index, insert);
}

bool Stack::PushGUI(GUI *value, int index, bool insert)
{
  return this.Push(StackData.GUIToData(value), index, insert);
}

bool Stack::PushGUIControl(GUIControl *value, int index, bool insert)
{
  return this.Push(StackData.GUIControlToData(value), index, insert);
}

// Pops a StackData object.
StackData noloopcheck Pop(this Stack*, int index, bool remove)
{
  // determine index based on Stack's pop style
  if (index == SCR_NO_VALUE)
  {
    if (this.PopStyle == eStackPopFirstInFirstOut)
    {
      index = 0;
    }
    else if (this.PopStyle == eStackPopFirstInLastOut)
    {
      index = this.ItemCount - 1;
    }
    else
    {
      index = Random(this.ItemCount - 1);
    }
  }
  if ((index < 0) || (index >= this.ItemCount))
  {
    // invalid index
    return null;
  }
  StackData item = this._items[index];
  if (!remove)
  {
    // if not removing the item, just return it
    return item;
  }
  this.ItemCount--;
  // shift the remaining items, to remove this one
  int i;
  for (i = index; i < this.ItemCount; i++)
  {
    this._items[i] = this._items[i + 1];
  }
  // clear the newly emptied slot
  this._items[i] = null;
  return item;
}

// Helper to ensure that the popped StackData is non-null.
// This prevents duplicating the defaults for invalid data casts.
StackData SafePop(this Stack*, int index, bool remove)
{
  StackData result = this.Pop(index, remove);
  if (result == null) return new StackData;
  return result;
}

int Stack::PopInt(int index, bool remove)
{
  StackData item = this.SafePop(index, remove);
  return item.get_AsInt();
}

float Stack::PopFloat(int index, bool remove)
{
  StackData item = this.SafePop(index, remove);
  return item.get_AsFloat();
}

String Stack::PopString(int index, bool remove)
{
  StackData item = this.SafePop(index, remove);
  return item.get_AsString();
}

Character* Stack::PopCharacter(int index, bool remove)
{
  StackData item = this.SafePop(index, remove);
  return item.get_AsCharacter();
}

InventoryItem* Stack::PopInventoryItem(int index, bool remove)
{
  StackData item = this.SafePop(index, remove);
  return item.get_AsInventoryItem();
}

GUI* Stack::PopGUI(int index, bool remove)
{
  StackData item = this.SafePop(index, remove);
  return item.get_AsGUI();
}

GUIControl* Stack::PopGUIControl(int index, bool remove)
{
  StackData item = this.SafePop(index, remove);
  return item.get_AsGUIControl();
}
 3S  /*******************************************\
# Stack Script Module for AGS
by monkey0506

## Description

The Stack module introduces a vectorized stack type into which you can place any type of data.
Great if you need to store data of various different types, or all of one type; this module can
handle all of your data storage needs!

## Dependencies

AGS 3.4.0.3 (Alpha) or higher

## What's New

The Stack module v2.0 introduces some breaking API changes, so it can't be used to directly replace
v1.3, but there are some major improvements, and updating to the new version shouldn't be too much
of a hassle.

Previous versions of the Stack module relied on serializing all of your data into a `String` before
it could be stored in a `Stack`. This made the stacks extremely inefficient. Improvements to the
AGS engine have made it possible to keep track of your data with no added penalty to size in memory
while seeing huge boosts in speed.

With the new version there is no longer a requirement to use messy conversion operators before your
data can be added to a `Stack`. Special functions have been added to make this easier. You can also
now access items in the `Stack` directly (with no speed penalty), and convert them back into their
basic data type with a simpler interface. See the changelog for full list of changes.

## Macros (#define-s)

#### Stack_VERSION

Defines the current version of the module, formatted as a `float`.

#### Stack_VERSION_200

Defines version 2.0 of the module.

## Enumerated types

#### StackDataType

- `eStackDataInt`: The stored data is an int
- `eStackDataFloat`: The stored data is a float
- `eStackDataString`: The stored data is a String
- `eStackDataCharacter`: The stored data is a Character
- `eStackDataInventoryItem`: The stored data is an InventoryItem
- `eStackDataGUI`: The stored data is a GUI
- `eStackDataGUIControl`: The stored data is a GUIControl
- `eStackDataInvalid`: The object does not contain any valid StackData

#### StackPopStyle

- `eStackPopFirstInLastOut`: The first item pushed onto the stack will be the last item popped back
  out. This is the default setting for all stacks.
- `eStackPopFirstInFirstOut`: The first item pushed onto the stack will be the first item popped
  back out.
- `eStackPopRandom`: All items on the stack are popped out in random order.

## Functions and Properties

### StackData

#### StackData.AsType properties

##### StackData.AsCharacter

##### StackData.AsFloat

##### StackData.AsGUIControl

##### StackData.AsGUI

##### StackData.AsInt

##### StackData.AsInventoryItem

`Character* StackData.AsCharacter`  
`float StackData.AsFloat`  
`GUIControl* StackData.AsGUIControl`  
`GUI* StackData.AsGUI`  
`int StackData.AsInt`  
`InventoryItem* StackData.AsInventoryItem`  
`String StackData.AsString`

Returns the value represented by this `StackData`, or `null` (0 for `int` and `float`) if the [Type](#stackdatatype-2) does not match.

#### StackData.IsNullOrInvalid

`static bool StackData.IsNullOrInvalid(StackData)`

Returns whether the `StackData` object is `null` or invalid (type is `eStackDataInvalid`).

#### StackData.TypeToData functions

#### StackData.CharacterToData

##### StackData.FloatToData

##### StackData.GUIControlToData

##### StackData.GUIToData

##### StackData.IntToData

##### StackData.InventoryItemToData

##### StackData.StringToData

##### StackData.StringCachedToData

`static StackData StackData.CharacterToData(Character*)`  
`static StackData StackData.FloatToData(float)`  
`static StackData StackData.GUIControlToData(GUIControl*)`  
`static StackData StackData.GUIToData(GUI*)`  
`static StackData StackData.IntToData(int)`  
`static StackData StackData.InventoryItemToData(InventoryItem*)`  
`static StackData StackData.StringToData(String)`  
`static StackData StackData.StringCachedToData(int cacheID)`

Returns a StackData object holding the specified value.

#### StackData.Type

`StackDataType StackData.Type`

Returns the [type](#stackdatatype) of this data.

---------

### Stack

#### Stack.Capacity

`int Stack.Capacity`

Gets or sets the capacity of the `Stack`. May only be increased; maximum is 1000000. Setting the
capacity can prevent unnecessary copying at the cost of consuming more memory. For huge `Stack`s
this can make your code faster by a factor of as much as *six or seven times*, so you should
especially set this before adding several items at once.

*Example:*

    Stack stack;
    stack.Capacity = 512; // set the capacity first
    int i;
    for (i = 0; i < 500; i++)
    {
      stack.PushInt(i * 5); // add a bunch of integers
    }

#### Stack.Clear

`void Stack.Clear()`

Removes all items from a Stack.

#### Stack.GetStringCachedID

`static int Stack.GetStringCachedID(String)`

Returns a unique ID that matches the specified `String` in the internal cache. See
[Stack.StringCacheCapacity](#stackstringcachecapacity) for more details; you should use this when
using repeated `String` operations on Stacks.

*Example:*

    String text = "Hello World!";
    int textID = Stack.GetStringCachedID(text);
    // push 5 copies of TEXT onto a Stack
    Stack stack;
    int i;
    for (i = 0; i < 5; i++)
    {
      stack.PushStringCached(textID);
    }

#### Stack.Items

`StackData Stack.Items[int index]`

Gets or sets the item at `index` in the `Stack`. If reading an invalid `index`, an invalid
`StackData` object is returned; if setting an invalid `index`, nothing happens. This is used to
read or overwrite existing items only, it cannot append new items to the Stack; instead use
[Stack.Push](#stackpush) for that. Items are indexed from zero, up to
[Stack.ItemCount](#stackitemcount) - 1.

*Example:*

    Stack stack;
    stack.PushInt(5);
    stack.PushInt(10);
    stack.PushInt(15);
    Display("The second item is: %d", stack.Items[1].AsInt); // Displays 10
    stack.Items[1] = StackData.IntToData(42);
    Display("It is now: %d", stack.Items[i].AsInt); // Displays 42

#### Stack.ItemCount

readonly int Stack.ItemCount

Returns the number of items the `Stack` currently holds. This is one higher than the maximum valid
index for [Stack.Items](#stackitems).

*Example:*

    Stack stack;
    stack.PushInt(5);
    stack.PushInt(10);
    stack.PushInt(15);
    Display("The stack is holding %d items.", stack.ItemCount); // Displays 3

#### Stack.Pop

`StackData Stack.Pop(optional int index, optional bool remove)`

Pops a value from the `Stack`, or returns `null` on error. You may optionally specify an `index`,
or choose to leave the item on the `Stack`. Typically if you are not removing the item then you
would use the [Stack.Items](#stackitems) array instead. There are also specialized functions if you
know the type of data in the `Stack`.

*Example:*

    Stack stack;
    stack.PushInt(42);
    StackData item = stack.Pop();
    Display("Items in the stack: %d, popped item: %d", stack.ItemCount, item.AsInt); // Displays 0 and 42

#### Stack.PopStyle

`StackPopStyle Stack.PopStyle`

Gets or sets the order that items are popped from a `Stack` with the [Pop](#stackpop) functions.
The default is `eStackPopFirstInLastOut`.

*Example:*

    Stack stack;
    stack.PopStyle = eStackFirstInFirstOut; // sets the stack to FIFO mode

#### Stack.PopType functions

##### Stack.PopCharacter

##### Stack.PopFloat

##### Stack.PopGUI

##### Stack.PopGUIControl

##### Stack.PopInt

##### Stack.PopInventoryItem

##### Stack.PopString

`Character* Stack.PopCharacter(optional int index, optional bool remove)`  
`float Stack.PopFloat(optional int index, optional bool remove)`  
`GUI* Stack.PopGUI(optional int index, optional bool remove)`  
`GUIControl* Stack.PopGUIControl(optional int index, optional bool remove)`  
`int Stack.PopInt(optional int index, optional bool remove)`  
`InventoryItem* Stack.PopInventoryItem(optional int index, optional bool remove)`  
`String Stack.PopString(optional int index, optional bool remove)`

Specialized functions to pop an item off of a `Stack`, similar to [Stack.Pop](#stackpop).

*Note:* These functions do not leave the item on the `Stack` if the types do not match, so if you
are unsure of the type of data you are trying to retrieve, use `Stack.Pop` instead.

#### Stack.Push

`bool Stack.Push(StackData, optional int index, optional bool insert)`

Pushes the `StackData` object into the `Stack`, or returns `false` on error. You may *optionally*
specify the `index` for the item to be entered into the `Stack`, or overwrite an existing item.
You typically would only need this if you are moving an item from one `Stack` to another, and use
the specialized functions for general use.

*Example:*

    Stack stack;
    stack.Push(StackData.IntToData(5)); // UGLY! Use Stack.PushInt instead!
    Stack otherStack;
    otherStack.Push(stack.Pop()); // pop an item off one Stack and push it onto another

#### Stack.PushType functions

##### Stack.PushCharacter

##### Stack.PushFloat

##### Stack.PushGUI

##### Stack.PushGUIControl

##### Stack.PushInt

##### Stack.PushInventoryItem

##### Stack.PushString

`bool Stack.PushInt(int, optional int index, optional bool insert)`
`bool Stack.PushFloat(float, optional int index, optional bool insert)`
`bool Stack.PushString(String, optional int index, optional bool insert)`
`bool Stack.PushCharacter(Character*, optional int index, optional bool insert)`
`bool Stack.PushInventoryItem(InventoryItem*, optional int index, optional bool insert)`
`bool Stack.PushGUI(GUI*, optional int index, optional bool insert)`
`bool Stack.PushGUIControl(GUIControl, optional int index, optional bool insert)`

Specialized methods to make pushing items onto a `Stack` easier.

*Note:* If you are pushing the same `String` to a `Stack` more than once, you may consider using
[Stack.PushStringCached](#stackpushstringcached) instead. See that function for more info.

*Example:*

    Stack stack;
    stack.PushInt(42);
    stack.PushFloat(3.1415);
    stack.PushString("Hello World!");

#### Stack.PushStringCached

`bool Stack.PushStringCached(int cachedID, optional int index, optional bool insert)`

Pushes a cached `String` onto the `Stack`. Due to certain technical restrictions in AGS, `String`
operations on `Stack`s may be slow. If you are pushing the same `String` onto a `Stack` more than
once, consider using this function instead as it is faster. You can use `Stack.GetStringCachedID`
to obtain the unique ID that this function uses as its first parameter. Also be sure to set
[Stack.StringCacheCapacity](#stackstringcachecapacity) as needed to boost performance when working
with `String`s.

*Note:* There is no penalty when popping `String`s off of a `Stack`, so there is no matching
`PopStringCached` function. The performance penalty occurs when converting the `String` into
`StackData`.

*Example:*

    String text = "Hello World!";
    int textID = Stack.GetStringCachedID(text);
    // push 5 copies of TEXT onto a Stack
    Stack stack;
    int i;
    for (i = 0; i < 5; i++)
    {
      stack.PushStringCached(textID);
    }

#### Stack.StringCacheCapacity

`static int Stack.StringCacheCapacity`

Gets or sets the capacity of the internal `String` cache. May only be increased; maximum value is
1000000. Due to technical restrictions in AGS, `String`s are pooled/cached globally when converted
to `StackData`. This may make `String` operations on `Stack`s slower than other types of data.
Setting a high capacity may improve speeds if you are doing a lot of `String` operations. You
should also use the *cached ID* (see [Stack.GetStringCachedID](#stackgetstringcachedid)) whenever
possible for this reason. Increasing this value will consume more memory though, so use some
discretion. Note that this value *will* automatically increase if needed.

*Example:*

    // game_start
    Stack.StringCacheCapacity = 512;

# Licensing

Permission is hereby granted, free of charge, to any person obtaining a copy of this script module
and associated documentation files (the "Module"), to deal in the Module without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Module, and to permit persons to whom the Module is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Module.

THE MODULE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE MODULE OR THE USE OR OTHER DEALINGS IN THE MODULE.

# Changelog

## Version 2.0

Version:     2.0  
Author:      monkey0506  
Date:        25 January 2015  
Description: Total rewrite of the module to take advantage of new features in AGS such as dynamic
arrays in structs and pointers to managed types. Includes several breaking changes to the interface
from v1.3, which is no longer supported. `StackData` is no longer a masked `String`, and is a
formal data type; `StackDataType` no longer defines its members with character values; support
removed for adding `Stack` objects within other `Stack`s; `StackData` functions have been replaced
by member properties such as `AsInt`, `AsFloat`, `AsString`, etc.; the `eStackStrictTypes` setting
has been removed, all types are now strongly enforced; static conversion functions to `StackData`
have been moved from `Stack` type to static `StackData` functions; `StackPopType` has been renamed
to `StackPopStyle`; *optional* `insert` parameter added to `Stack.Push`; parameters to `Stack.Pop`
have now been reversed for improved interface and matching `Stack.Push`; `Stack.IsEmpty`,
`Stack.Copy`, `Stack.LoadFromStack`, `Stack.LoadFromFile`, `Stack.GetItemsArray`,
`File.WriteStack`, and `File.ReadStackBack` have all been removed; added ability to change `Stack`
capacity; added `String` caching methods; and added specialized functions (`Stack.PushInt`, etc.)
for a simpler interface.

## Version 1.3

Version:     1.3  
Author:      monkey0506  
Date:        21 August 2009  
Description: Fixed bug with `String.Format` and large `Stack`s (`String.Format` has a limit on the
size of the `String` it can return; replaced where applicable with `String.Append` instead). Also
added further support to prevent issues with `Stack.Copy`. Previously if you pushed the same stack
copy onto a single stack multiple times there would be problems with the internal data structure.
This should resolve that.

## Version 1.2a

Version:     1.2a  
Author:      monkey0506  
Date:        29 March 2009  
Description: Fixed bug where `Stack.GetItemsArray` may request a 0-sized array.

## Version 1.2

Version:     1.2  
Author:      monkey0506  
Date:        28 March 2009  
Description: Added `Stack.GetItemsArray`, `File.WriteStack`, `File.ReadStackBack`, and
`Stack.LoadFromFile` functions. The module now exports `StackDataFormat` so it can be used by other
scripts for extending the module. It is not imported, it must be locally imported to the script
requiring it. Modified the way `Stack.Copy` formats the data to better prevent collisions. Fixed a
bug with `Stack.Push` where if you were adding an item at a specific index `ItemCount` was still
getting increased. Added data type `eStackDataInvalid` to indicate that the object is not valid
`StackData`. Included module information in the Properties pane for the script.

## Version 1.0

Version:     1.0  
Author:      monkey0506  
Date:        20 March 2009  
Description: First public release.   

\*******************************************/

#ifdef AGS_SUPPORTS_IFVER
#ifver 3.4.0.3           
#define Stack_VERSION_200
#define Stack_VERSION 2.0
#endif                   
#endif                   
#ifndef Stack_VERSION_200
#error Stack module v2.0 requires AGS 3.4.0.3 or higher! Please upgrade to a newer version of AGS or use an older version of the module.
#endif                   

enum StackDataType
{
  eStackDataInt,
  eStackDataFloat,
  eStackDataString,
  eStackDataCharacter,
  eStackDataInventoryItem,
  eStackDataGUI,
  eStackDataGUIControl,
  eStackDataInvalid = 0
};

autoptr managed struct StackData
{
  ///Returns whether the StackData object is null or invalid.
  import static bool IsNullOrInvalid(StackData); // $AUTOCOMPLETESTATICONLY$
  ///Returns a new StackData object containing the int value.
  import static StackData IntToData(int); // $AUTOCOMPLETESTATICONLY$
  ///Returns a new StackData object containing the float value.
  import static StackData FloatToData(float); // $AUTOCOMPLETESTATICONLY$
  ///Returns a new StackData object containing the String value.
  import static StackData StringToData(String); // $AUTOCOMPLETESTATICONLY$
  ///Returns a new StackData object containing the cached String value.
  import static StackData StringCachedToData(int cachedID); // $AUTOCOMPLETESTATICONLY$
  ///Returns a new StackData object containing the Character.
  import static StackData CharacterToData(Character*); // $AUTOCOMPLETESTATICONLY$
  ///Returns a new StackData object containing the InventoryItem.
  import static StackData InventoryItemToData(InventoryItem*); // $AUTOCOMPLETESTATICONLY$
  ///Returns a new StackData object containing the GUI.
  import static StackData GUIToData(GUI*); // $AUTOCOMPLETESTATICONLY$
  ///Returns a new StackData object containing the GUIControl.
  import static StackData GUIControlToData(GUIControl*); // $AUTOCOMPLETESTATICONLY$
  protected int _idata;
  protected float _fdata;
  protected int _scacheID;
  readonly import attribute int AsInt;
  readonly import attribute float AsFloat;
  readonly import attribute String AsString;
  readonly import attribute Character* AsCharacter;
  readonly import attribute InventoryItem* AsInventoryItem;
  readonly import attribute GUI* AsGUI;
  readonly import attribute GUIControl *AsGUIControl;
  writeprotected StackDataType Type;
};

enum StackPopStyle
{
  eStackPopFirstInLastOut = 0,
  eStackPopFirstInFirstOut,
  eStackPopRandom
};

struct Stack
{
  ///Gets or sets the capacity of the internal String cache. May only be increased; maximum 1000000.
  import static attribute int StringCacheCapacity; // $AUTOCOMPLETESTATICONLY$
  ///Returns a unique ID that matches this String in the internal cache.
  import static int GetStringCachedID(String); // $AUTOCOMPLETESTATICONLY$
  protected StackData _items[];
  protected int _capacity;
  ///Gets or sets the capacity of this Stack. May only be increased; maximum 1000000.
  import attribute int Capacity;
  ///Gets or sets an item in this Stack.
  import attribute StackData Items[];
  ///Returns the number of items currently stored in this Stack.
  writeprotected int ItemCount;
  ///Gets or sets the order that items are popped from this Stack with the Pop functions.
  StackPopStyle PopStyle;
  ///Removes all items from the Stack.
  import void Clear();
  ///Pushes an item into this Stack with optional index. By default, inserts items; can be used for overwriting them.
  import bool Push(StackData, int index=SCR_NO_VALUE, bool insert=true);
  ///Pushes an int value into this Stack.
  import bool PushInt(int, int index=SCR_NO_VALUE, bool insert=true);
  ///Pushes a float value into this Stack.
  import bool PushFloat(float, int index=SCR_NO_VALUE, bool insert=true);
  ///Pushes a String value into this Stack. May be slow; see documentation for more details.
  import bool PushString(String, int index=SCR_NO_VALUE, bool insert=true);
  ///Pushes a cached String value into this Stack. Use Stack.GetStringCachedID to obtain the ID.
  import bool PushStringCached(int cachedID, int index=SCR_NO_VALUE, bool insert=true);
  ///Pushes a Character into this Stack.
  import bool PushCharacter(Character*, int index=SCR_NO_VALUE, bool insert=true);
  ///Pushes an InventoryItem into this Stack.
  import bool PushInventoryItem(InventoryItem*, int index=SCR_NO_VALUE, bool insert=true);
  ///Pushes a GUI into this Stack.
  import bool PushGUI(GUI*, int index=SCR_NO_VALUE, bool insert=true);
  ///Pushes a GUIControl into this Stack.
  import bool PushGUIControl(GUIControl*, int index=SCR_NO_VALUE, bool insert=true);
  ///Pops a value from this Stack. Returns null on error.
  import StackData Pop(int index=SCR_NO_VALUE, bool remove=true);
  ///Pops an int value from this Stack.
  import int PopInt(int index=SCR_NO_VALUE, bool remove=true);
  ///Pops a float value from this Stack.
  import float PopFloat(int index=SCR_NO_VALUE, bool remove=true);
  ///Pops a String value from this Stack.
  import String PopString(int index=SCR_NO_VALUE, bool remove=true);
  ///Pops a Character from this Stack.
  import Character* PopCharacter(int index=SCR_NO_VALUE, bool remove=true);
  ///Pops an InventoryItem from this Stack.
  import InventoryItem* PopInventoryItem(int index=SCR_NO_VALUE, bool remove=true);
  ///Pops a GUI from this Stack.
  import GUI* PopGUI(int index=SCR_NO_VALUE, bool remove=true);
  ///Pops a GUIControl from this Stack.
  import GUIControl* PopGUIControl(int index=SCR_NO_VALUE, bool remove=true);
};
 ���6        ej��