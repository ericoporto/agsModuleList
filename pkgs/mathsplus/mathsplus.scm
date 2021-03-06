AGSScriptModule    monkey0506 Extra Maths functions. MathsPlus 1.0 l  
float Max(static Maths, float a, float b)
{
  if (a > b)
  {
    return a;
  }
  return b;
}

float Min(static Maths, float a, float b)
{
  if (a < b)
  {
    return a;
  }
  return b;
}

float Abs(static Maths, float f)
{
  if (f < 0.0)
  {
    return -f;
  }
  return f;
}

float Ceil(static Maths, float f)
{
  return IntToFloat(FloatToInt(f, eRoundUp));
}

float Floor(static Maths, float f)
{
  return IntToFloat(FloatToInt(f, eRoundDown));
}

float Round(static Maths, float f)
{
  return IntToFloat(FloatToInt(f, eRoundNearest));
}

int MaxInt(static Maths, int a, int b)
{
  if (a > b)
  {
    return a;
  }
  return b;
}

int MinInt(static Maths, int a, int b)
{
  if (a < b)
  {
    return a;
  }
  return b;
}

int AbsInt(static Maths, int i)
{
  if (i < 0)
  {
    return -i;
  }
  return i;
}
 �  
import float Max(static Maths, float a, float b);
import float Min(static Maths, float a, float b);
import float Abs(static Maths, float f);
import float Ceil(static Maths, float f);
import float Floor(static Maths, float f);
import float Round(static Maths, float f);
import int MaxInt(static Maths, int a, int b);
import int MinInt(static Maths, int a, int b);
import int AbsInt(static Maths, int i);

#ifdef AGS_SUPPORTS_IFVER
#ifver 3.4.0.6
#define MathsPlus_VERSION 1.0
#define MathsPlus_VERSION_100
#endif // 3.4.0.6
#endif // AGS_SUPPORTS_IFVER

#ifndef MathsPlus_VERSION
#error The MathsPlus module requires AGS version 3.4.0.6 or higher. Please use a newer version of AGS to use this module.
#endif // MathsPlus_VERSION
 �L        ej��