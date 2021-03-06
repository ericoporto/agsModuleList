AGSScriptModule    Ferry "Wyz" Timmers Loads, saves and alters ini configuation files. Ini file module 1.0.0 �+  /******************************************************************************
 * Ini module source file -- see header file for more information.            *
 ******************************************************************************/

// Invariant 1: length <= INIFILE_BUFFER_SIZE
// Invariant 2: for all i: length <= i < INIFILE_BUFFER_SIZE: lines[i] == null

//------------------------------------------------------------------------------
// Trim: Returns a string with the left and right whitespace removed.

String Trim(this String *)
{
  int left = 0;
  int right = this.Length - 1;
  
  while ((left < right) && ((this.Chars[left] == ' ') || (this.Chars[left] == 9)))
    left++;
  
  while ((right > left) && ((this.Chars[right] == ' ') || (this.Chars[right] == 9)))
    right--;
  
  if (left > right)
    return "";
  
  return this.Substring(left, right - left + 1);
}

//==============================================================================
// InsertLine:
//   Inserts a new line in the ini file at specified index, returns success.

bool InsertLine(this IniFile *, int index)
{
  if ((this.length == INIFILE_BUFFER_SIZE) || (index < 0) || (index > this.length))
    return false;
  
  this.length++;
  int i = this.length;
  while (i > index)
  {
    i--;
    this.lines[i + 1] = this.lines[i];
  }
  
  return true;
}

//------------------------------------------------------------------------------
// DeleteLine:
//   Deletes a new line in the ini file at specified index, returns success.

bool DeleteLine(this IniFile *, int index)
{
  if ((index < 0) || (index >= this.length))
    return false;
  
  this.length--;
  while (index < this.length)
  {
    this.lines[index] = this.lines[index + 1];
    index++;
  }
  
  this.lines[this.length + 1] = null;
  return true;
}

//------------------------------------------------------------------------------
// FindSection: Returns the line that contains the requested section header
//   or `length` when not found.

int FindSection(this IniFile *, String section)
{
  int i = 0, j;
  String str;
  
  section = section.LowerCase();
  while (i < this.length)
  {
    str = this.lines[i];
    if (!String.IsNullOrEmpty(str) && (str.Chars[0] == '['))
    {
      j = str.IndexOf("]");
      if (j > 1)
      {
        str = str.Substring(1, j - 1);
        if (str.LowerCase() == section)
          return i;
      }
    }
    i++;
  }
  return i;
}

//------------------------------------------------------------------------------
// FindSection: Returns the line that contains the requested key in section
//   or `length` when not found.

int FindKey(this IniFile *, String section, String key)
{
  int i = this.FindSection(section) + 1, j;
  String str;
  
  key = key.LowerCase();
  while (i < this.length)
  {
    str = this.lines[i];
    if (!String.IsNullOrEmpty(str))
    {
      if (str.Chars[0] == '[')
        return this.length;
      
      j = str.IndexOf(";");
      if (j >= 0)
        str = str.Truncate(j);
      
      j = str.IndexOf("=");
      if (j > 0)
      {
        str = str.Truncate(j);
        str = str.Trim();
        if (str.LowerCase() == key)
          return i;
      }
    }
    i++;
  }
  return this.length;
}


//------------------------------------------------------------------------------
// FindLastKey: Returns the line that contains the last key of the requested
//   section or the section header when empty; when the section does not exists
//   it tries to create it. When this fails it will return `length`.

int FindLastKey(this IniFile *, String section)
{
  int i = this.FindSection(section);
  int last = i, j;
  String str;
  
  if (i == this.length)
  {
    if (i + 2 > INIFILE_BUFFER_SIZE)
      return this.length;
    
    this.length += 2;
    this.lines[i] = "";
    this.lines[i + 1] = String.Format("[%s]", section);
    return i + 1;
  }

  i++;
  while (i < this.length)
  {
    str = this.lines[i];
    if (!String.IsNullOrEmpty(str))
    {
      if (str.Chars[0] == '[')
        return last;
      
      j = str.IndexOf(";");
      if (j >= 0)
        str = str.Truncate(j);
      
      j = str.IndexOf("=");
      if (j > 0)
        last = i;
    }
    i++;
  }
  return last;
}

//==============================================================================

void IniFile::Clear()
{
  while (this.length)
  {
    this.length--;
    this.lines[this.length] = null;
  }
}

//------------------------------------------------------------------------------

bool IniFile::Load(String filename)
{
  File *file = File.Open(filename, eFileRead);
  if ((file == null) || (file.Error))
    return false;
  
  this.Clear();
  while (!file.EOF && (this.length < INIFILE_BUFFER_SIZE))
  {
    this.lines[this.length] = file.ReadRawLineBack();
    this.length++;
  }
  
  file.Close();
  return true;
}

//------------------------------------------------------------------------------

bool IniFile::Save(String filename)
{
  File *file = File.Open(filename, eFileWrite);
  if ((file == null) || (file.Error))
    return false;
  
  int i = 0;
  while (i < this.length)
  {
    file.WriteRawLine(this.lines[i]);
    i++;
  }
  
  file.Close();
  return true;
}

//------------------------------------------------------------------------------

int IniFile::ListSections(String list[], int size)
{
  int count = 0, i = 0, j;
  String str;
  
  while (i < this.length)
  {
    str = this.lines[i];
    if (!String.IsNullOrEmpty(str) && (str.Chars[0] == '['))
    {
      j = str.IndexOf("]");
      if (j > 1)
      {
        if (count < size)
          list[count] = str.Substring(1, j - 1);
        
        count++;
      }
    }
    i++;
  }
  
  return count;
}

//------------------------------------------------------------------------------

int IniFile::ListKeys(String section, String list[], int size)
{
  int count = 0, i = this.FindSection(section) + 1, j;
  String str;
  
  while (i < this.length)
  {
    str = this.lines[i];
    if (!String.IsNullOrEmpty(str))
    {
      if (str.Chars[0] == '[')
        return count;
      
      j = str.IndexOf(";");
      if (j >= 0)
        str = str.Truncate(j);
      
      j = str.IndexOf("=");
      if (j > 0)
      {
        if (count < size)
        {
          str = str.Truncate(j);
          list[count] = str.Trim();
        }
        count++;
      }
    }
    i++;
  }
  return count;
}

//------------------------------------------------------------------------------

bool IniFile::SectionExists(String section)
{
  return (this.FindSection(section) != this.length);
}

//------------------------------------------------------------------------------

void IniFile::DeleteSection(String section)
{
  int i = this.FindSection(section);
  if (i == this.length)
    return;
  
  int last = this.FindLastKey(section) + 1;
  while (last < this.length)
  {
    this.lines[i] = this.lines[last];
    i++;
    last++;
  }
  
  while (this.length > i)
  {
    this.length--;
    this.lines[this.length] = null;
  }
}

//------------------------------------------------------------------------------

bool IniFile::KeyExists(String section, String key)
{
  return (this.FindKey(section, key) != this.length);
}

//------------------------------------------------------------------------------

void IniFile::DeleteKey(String section, String key)
{
  int i = this.FindKey(section, key);
  if (i != this.length)
    this.DeleteLine(i);
}

//------------------------------------------------------------------------------

String IniFile::Read(String section, String key, String value)
{
  int i = this.FindKey(section, key);
  if (i == this.length)
    return value;
  
  key = this.lines[i];
  i = key.IndexOf("=") + 1;
  
  if (i == key.Length)
    return value;
  
  key = key.Substring(i, key.Length - i);
  key = key.Trim();
  return key;
}

//------------------------------------------------------------------------------

int IniFile::ReadInt(String section, String key, int value)
{
  int i = this.FindKey(section, key);
  if (i == this.length)
    return value;
  
  key = this.lines[i];
  i = key.IndexOf("=") + 1;
  
  if (i == key.Length)
    return value;
  
  key = key.Substring(i, key.Length - i);
  key = key.Trim();
  return key.AsInt;
}

//------------------------------------------------------------------------------

float IniFile::ReadFloat(String section, String key, float value)
{
  int i = this.FindKey(section, key);
  if (i == this.length)
    return value;
  
  key = this.lines[i];
  i = key.IndexOf("=") + 1;
  
  if (i == key.Length)
    return value;
  
  key = key.Substring(i, key.Length - i);
  key = key.Trim();
  return key.AsFloat;
}

//------------------------------------------------------------------------------

bool IniFile::ReadBool(String section, String key, bool value)
{
  int i = this.FindKey(section, key);
  if (i == this.length)
    return value;
  
  key = this.lines[i];
  i = key.IndexOf("=") + 1;
  
  if (i == key.Length)
    return value;
  
  key = key.Substring(i, key.Length - i);
  key = key.Trim();
  key = key.LowerCase();
  return ((key == "1") || (key == "true") || (key == "on") || (key == "yes"));
}

//------------------------------------------------------------------------------

bool IniFile::Write(String section, String key, String value)
{
  int i = this.FindKey(section, key);
  if (i == this.length)
  {
    i = this.FindLastKey(section) + 1;
    if (!this.InsertLine(i))
      return false;
  }
  this.lines[i] = String.Format("%s=%s", key, value);
  return true;
}

//------------------------------------------------------------------------------

bool IniFile::WriteInt(String section, String key, int value)
{
  int i = this.FindKey(section, key);
  if (i == this.length)
  {
    i = this.FindLastKey(section) + 1;
    if (!this.InsertLine(i))
      return false;
  }
  this.lines[i] = String.Format("%s=%d", key, value);
  return true;
}

//------------------------------------------------------------------------------

bool IniFile::WriteFloat(String section, String key, float value)
{
  int i = this.FindKey(section, key);
  if (i == this.length)
  {
    i = this.FindLastKey(section) + 1;
    if (!this.InsertLine(i))
      return false;
  }
  this.lines[i] = String.Format("%s=%f", key, value);
  return true;
}

//------------------------------------------------------------------------------

bool IniFile::WriteBool(String section, String key, bool value)
{
  int i = this.FindKey(section, key);
  if (i == this.length)
  {
    i = this.FindLastKey(section) + 1;
    if (!this.InsertLine(i))
      return false;
  }
  this.lines[i] = String.Format("%s=%d", key, value);
  return true;
}

//.............................................................................. [  /****************************************************************
 * Ini file module                                              *
 *                                                              *
 * Author: Ferry "Wyz" Timmers                                  *
 * Date: 31-7-2012                                              *
 * Description: Loads, saves and alters ini configuation files. *
 * Requirements: None                                           *
 * License: zlib license, see below.                             *
 *                                                              *
 ****************************************************************/

/*
 * NOTE: The configuration is not saved automatically!
 *       Please call 'Save' after you're done changing the configuration.
 *
 * Notes:
 * - Supports basic windows ini files
 * - All section and key names are case insensitive
 * - section names may contain any character but ]
 * - key names may contain any character but [ and = and ;
 * - values can not contain leading/trailing whitespace
 *
 * Reading:
 * - Section names should not be prefixed by spaces
 * - Comments are supported and start with a semicolon
 * - Comments after values are not supported
 * - Escaped and quoted values unsupported (though support can be added)
 * - Boolean values supported: true/false, on/off, yes/no, 1/0 (case insensitive)
 *
 * Writing:
 * - section and key names should be valid, this is not checked
 * - values should be serialized when containing special characters
 * - boolean values are stored as 1 and 0
 *
 * The buffer size should be big enough to store the complete configuration,
 * when this is not the case the module will fail silently and overflowing settings will not be stored.
 * A typical ini file does not exceed 50 lines;
 * when your usage does please change the constant below accordantly.
 *
 */

/// Sets the size of the internal line buffer
#define INIFILE_BUFFER_SIZE 250

struct IniFile
{
  /// Loads an ini file from disk; returns success.
  import bool Load(String filename);
  /// Saves the current configuration to disk; returns success.
  import bool Save(String filename);
  /// Clears the current configuration
  import void Clear();
  
  /// Stores the section names in a list with specified size. Returns the number of sections (regardless the list size).
  import int ListSections(String list[], int size);
  /// Stores the key names of the requested section in a list with specified size. Returns the number of keys (regardless the list size).
  import int ListKeys(String section, String list[], int size);
  
  /// Returns whether the given section exists in the current configuration.
  import bool SectionExists(String section);
  /// Deletes the given section from the current configuration (when it exists).
  import void DeleteSection(String section);
  /// Returns whether the given key exists in the given section of the current configuration.
  import bool KeyExists(String section, String key);
  /// Deletes the given key from the given section in the current configuration (when it exists).
  import void DeleteKey(String section, String key);
  
  /// Reads a value from the current configuration and returns it when it exists; returns the supplied default value when it does not.
  import String Read(String section, String key, String value = 0);
  /// Reads an integer from the current configuration and returns it when it exists; returns the supplied default integer when it does not.
  import int ReadInt(String section, String key, int value = 0);
  /// Reads a float from the current configuration and returns it when it exists; returns the supplied default float when it does not.
  import float ReadFloat(String section, String key, float value = 0);
  /// Reads a boolean from the current configuration and returns it when it exists; returns the supplied default value when it does not.
  import bool ReadBool(String section, String key, bool value = false);
  
  /// Writes a value to the current configuration and returns success. It tries to make a new section when the given one does not exist.
  import bool Write(String section, String key, String value);
  /// Writes an integer to the current configuration and returns success. It tries to make a new section when the given one does not exist.
  import bool WriteInt(String section, String key, int value);
  /// Writes a float to the current configuration and returns success. It tries to make a new section when the given one does not exist.
  import bool WriteFloat(String section, String key, float value);
  /// Writes a boolean to the current configuration and returns success. It tries to make a new section when the given one does not exist.
  import bool WriteBool(String section, String key, bool value);
  
  // Private variables
  String lines[INIFILE_BUFFER_SIZE]; // $AUTOCOMPLETEIGNORE$
  int length; // $AUTOCOMPLETEIGNORE$
};

/*
 * Copyright (c) 2012 Ferry "Wyz" Timmers
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 *    1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 
 *    2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 
 *    3. This notice may not be removed or altered from any source
 *    distribution.
 */
 gr        ej��