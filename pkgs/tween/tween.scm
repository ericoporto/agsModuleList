AGSScriptModule    Edmundo Ruiz et al. In-betweening functions for AGS. Tween 2.2.2 ~. // ags-tween is open source under the MIT License.
// Uses Robert Penner's easing equestions which are under the BSD License.
//
// TERMS OF USE - AGS TWEEN MODULE (ags-tween)
//
// Copyright (c) 2009-present Edmundo Ruiz Ghanem
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#region Declarations

#define NULL_TWEEN_DURATION -1.0
#define HALF_PI 1.570796327
#define DOUBLE_PI 6.283185307
#ifndef STRICT_AUDIO
  #define MUSIC_MASTER_VOLUME_MIN -210
#endif

enum _TweenReferenceType {
  _eTweenReferenceGUI,
  _eTweenReferenceObject,
  _eTweenReferenceCharacter,
  _eTweenReferenceRegion,
  _eTweenReferenceGUIControl,
  _eTweenReferenceMisc,
  #ifdef STRICT_AUDIO
  _eTweenReferenceAudioChannel,
  #endif
  _eTweenReferenceInventoryItem,
  #ifdef SCRIPT_API_v3507
  _eTweenReferenceViewport,
  _eTweenReferenceCamera,
  #endif
};

enum _TweenType {
  _eTweenGUIPosition,
  _eTweenGUITransparency,
  _eTweenGUISize,
  _eTweenGUIZOrder,
  #ifdef SCRIPT_API_v350
  _eTweenGUIBackgroundColorRed,
  _eTweenGUIBackgroundColorGreen,
  _eTweenGUIBackgroundColorBlue,
  _eTweenGUIBorderColorRed,
  _eTweenGUIBorderColorGreen,
  _eTweenGUIBorderColorBlue,
  #endif
  _eTweenObjectPosition,
  _eTweenObjectTransparency,
  _eTweenCharacterPosition,
  _eTweenCharacterScaling,
  _eTweenCharacterTransparency,
  _eTweenCharacterAnimationSpeed,
  _eTweenCharacterZ,
  _eTweenRegionLightLevel,
  _eTweenRegionTintRed,
  _eTweenRegionTintGreen,
  _eTweenRegionTintBlue,
  _eTweenRegionTintSaturation,
  _eTweenLabelTextColorRed,
  _eTweenLabelTextColorGreen,
  _eTweenLabelTextColorBlue,
  _eTweenGUIControlPosition,
  _eTweenGUIControlSize,
  _eTweenButtonTextColorRed,
  _eTweenButtonTextColorGreen,
  _eTweenButtonTextColorBlue,
  _eTweenSliderValue,
  _eTweenListBoxSelectedIndex,
  _eTweenListBoxTopItem,
  #ifdef SCRIPT_API_v350
  _eTweenListBoxSelectedBackColorRed,
  _eTweenListBoxSelectedBackColorGreen,
  _eTweenListBoxSelectedBackColorBlue,
  _eTweenListBoxSelectedTextColorRed,
  _eTweenListBoxSelectedTextColorGreen,
  _eTweenListBoxSelectedTextColorBlue,
  _eTweenListBoxTextColorRed,
  _eTweenListBoxTextColorGreen,
  _eTweenListBoxTextColorBlue,
  #endif
  _eTweenInvWindowTopItem,
  #ifdef SCRIPT_API_v3507
  _eTweenViewportPosition,
  _eTweenViewportSize,
  _eTweenCameraPosition,
  _eTweenCameraSize,
  #endif
  #ifndef SCRIPT_API_v3507
  _eTweenViewport,
  #endif
  _eTweenSystemGamma,
  _eTweenShakeScreen,
  _eTweenAreaScaling,
  _eTweenSpeechVolume,
  _eTweenTextBoxTextColorRed,
  _eTweenTextBoxTextColorGreen,
  _eTweenTextBoxTextColorBlue,
  _eTweenSliderHandleOffset,
  _eTweenAmbientLightLevel,
  _eTweenCharacterLightLevel,
  _eTweenCharacterProperty,
  _eTweenHotspotProperty,
  _eTweenInventoryItemProperty,
  _eTweenObjectLightLevel,
  _eTweenObjectProperty,
  _eTweenRegionTintLuminance,
  _eTweenRoomProperty,
  #ifndef STRICT_AUDIO
  _eTweenMusicMasterVolume,
  _eTweenDigitalMasterVolume,
  _eTweenSoundVolume,
  _eTweenChannelVolume,
  _eTweenMusicVolume,
  #endif
  #ifdef STRICT_AUDIO
  _eTweenSystemVolume,
  _eTweenAudioChannelVolume,
  _eTweenAudioChannelRoomLocation,
  _eTweenAudioChannelPanning,
  _eTweenAudioChannelPosition,
  _eTweenAudioChannelSpeed,
  #endif
  #ifdef SCRIPT_API_v341
  _eTweenCharacterTintRed,
  _eTweenCharacterTintGreen,
  _eTweenCharacterTintBlue,
  _eTweenCharacterTintSaturation,
  _eTweenCharacterTintLuminance,
  _eTweenObjectTintRed,
  _eTweenObjectTintGreen,
  _eTweenObjectTintBlue,
  _eTweenObjectTintSaturation,
  _eTweenObjectTintLuminance,
  #endif
};

struct _TweenObject extends TweenBase {
  writeprotected _TweenType Type;
  writeprotected _TweenReferenceType RefType;
  writeprotected GUIControl* GUIControlRef;
  writeprotected int RefID;
  writeprotected float FromValue2;
  writeprotected float ToValue2;
  writeprotected String StringRef;

  import function InitTweenObject(int fromValue2, int toValue2, _TweenType type,
  _TweenReferenceType refType, int refID, GUIControl* guiControlRef, String stringRef);
  import function Release();
  import bool Update();
  import function Step(float amount);
  import function ReverseTweenObject();
};

_TweenObject _tweens[Tween_MAX_INSTANCES];
float _longestTweenDuration = 0.0;
bool _increaseGameSpeedOnBlockingTweens = false;
int _gameSpeed = -1;

#endregion

#region Internal utility functions

#ifdef DEBUG
function _AssertTrue(bool statement, String errorMessage) {
  if (!statement) {
    AbortGame(errorMessage);
  }
}
#endif

#ifdef STRICT_AUDIO
/*
 * Workaround for the following AGS issues with the new audio system:
 * 1. http://www.adventuregamestudio.co.uk/forums/index.php?topic=42186.0
 * 2. http://www.adventuregamestudio.co.uk/forums/index.php?topic=45071.0
 */
bool _ShouldLeaveAudioAlone(AudioChannel *channel) {
  return (channel == null || Game.SkippingCutscene);
}
#endif

float _GetTweenRemainingDuration(int index) {
  return _tweens[index].Duration - _tweens[index].Elapsed;
}

float _remainingDuration;

function _CheckIfIsLongestTween(int index) {
  _remainingDuration = _GetTweenRemainingDuration(index);

  if (_tweens[index].Style != eReverseRepeatTween &&
      _tweens[index].Style != eRepeatTween &&
      _remainingDuration > _longestTweenDuration
  ) {
    _longestTweenDuration = _remainingDuration;
  }
}

#endregion

#region TweenGame

static int TweenGame::GetRFromColor(int color) {
  float floatColor = IntToFloat(color);
  return FloatToInt(floatColor / 2048.0) * 8;
}

static int TweenGame::GetGFromColor(int color) {
  float floatColor = IntToFloat(color);
  return FloatToInt((floatColor - IntToFloat(FloatToInt(floatColor / 2048.0) * 2048)) / 64.0) * 8;
}

static int TweenGame::GetBFromColor(int color) {
  float floatColor = IntToFloat(color);

  float withoutR = floatColor - IntToFloat(FloatToInt(floatColor / 2048.0) * 2048);
  int withoutRInt = FloatToInt(withoutR);

  float withoutG = withoutR - IntToFloat(FloatToInt(withoutR / 64.0) * 64);
  int withoutGInt = FloatToInt(withoutG);

  int result = withoutGInt * 8;

  if (result > 255) {
    result = (withoutGInt - 31) * 8 - 1;
  }

  return result;
}

#endregion

#region TweenMaths

static float TweenMaths::Abs(float value) {
  if (value < 0.0) {
    return -value;
  }
  return value;
}

static float TweenMaths::GetDistance(int fromX, int fromY, int toX, int toY) {
  return Maths.Sqrt(
    Maths.RaiseToPower(IntToFloat(toX - fromX), 2.0) +
    Maths.RaiseToPower(IntToFloat(toY - fromY), 2.0)
  );
}

static int TweenMaths::Lerp(float from, float to, float t) {
  return FloatToInt(from + (to - from) * t, eRoundNearest);
}

static int TweenMaths::ClampInt(int value, int min, int max) {
  if (value > max) return max;
  else if (value < min) return min;
  return value;
}

static int TweenMaths::MaxInt(int a, int b) {
  if (a > b) return a;
  return b;
}

static int TweenMaths::MinInt(int a, int b) {
  if (a < b) return a;
  return b;
}

static float TweenMaths::ClampFloat(float value, float min, float max) {
  if (value > max) return max;
  else if (value < min) return min;
  return value;
}

static float TweenMaths::MaxFloat(float a, float b) {
  if (a > b) return a;
  return b;
}

static float TweenMaths::MinFloat(float a,float b) {
  if (a < b) return a;
  return b;
}

#endregion

#region Utility functions

int SecondsToLoops(float seconds) {
  return FloatToInt(IntToFloat(GetGameSpeed()) * seconds, eRoundNearest);
}

float LoopsToSeconds(int loops) {
  return IntToFloat(loops) / IntToFloat(GetGameSpeed());
}

function WaitSeconds(float seconds) {
  Wait(SecondsToLoops(seconds));
}

function WaitForLongest(int duration1, int duration2, int duration3, int duration4, int duration5, int duration6) {
  #ifdef DEBUG
  _AssertTrue(duration1 >= 0, "WaitForLongest: duration1 cannot be negative!");
  _AssertTrue(duration2 >= 0, "WaitForLongest: duration2 cannot be negative!");
  _AssertTrue(duration3 >= 0, "WaitForLongest: duration3 cannot be negative!");
  _AssertTrue(duration4 >= 0, "WaitForLongest: duration4 cannot be negative!");
  _AssertTrue(duration5 >= 0, "WaitForLongest: duration5 cannot be negative!");
  _AssertTrue(duration6 >= 0, "WaitForLongest: duration6 cannot be negative!");
  #endif
  if (duration2 > duration1) {
    duration1 = duration2;
  }
  if (duration3 > duration1) {
    duration1 = duration3;
  }
  if (duration4 > duration1) {
    duration1 = duration4;
  }
  if (duration5 > duration1) {
    duration1 = duration5;
  }
  if (duration6 > duration1) {
    duration1 = duration6;
  }
  Wait(duration1);
}

function SetTimerWithSeconds(int timerID, float secondsTimeout) {
  SetTimer(timerID, SecondsToLoops(secondsTimeout));
}

function SetTimerForLongest(int timerID, int timeout1, int timeout2, int timeout3, int timeout4, int timeout5, int timeout6) {
  #ifdef DEBUG
  _AssertTrue(timeout1 >= 0, "SetTimerForLongest: timeout1 cannot be negative!");
  _AssertTrue(timeout2 >= 0, "SetTimerForLongest: timeout2 cannot be negative!");
  _AssertTrue(timeout3 >= 0, "SetTimerForLongest: timeout3 cannot be negative!");
  _AssertTrue(timeout4 >= 0, "SetTimerForLongest: timeout4 cannot be negative!");
  _AssertTrue(timeout5 >= 0, "SetTimerForLongest: timeout5 cannot be negative!");
  _AssertTrue(timeout6 >= 0, "SetTimerForLongest: timeout6 cannot be negative!");
  #endif
  if (timeout2 > timeout1) {
    timeout1 = timeout2;
  }
  if (timeout3 > timeout1) {
    timeout1 = timeout3;
  }
  if (timeout4 > timeout1) {
    timeout1 = timeout4;
  }
  if (timeout5 > timeout1) {
    timeout1 = timeout5;
  }
  if (timeout6 > timeout1) {
    timeout1 = timeout6;
  }
  SetTimer(timerID, timeout1);
}

float SpeedToSeconds(float speed, int fromX, int fromY, int toX, int toY) {
  return TweenMaths.GetDistance(fromX, fromY, toX, toY) / speed;
}

#endregion

#region TweenEasing

// TERMS OF USE - EASING EQUATIONS
//
// Open source under the BSD License.
//
// Copyright (c) 2001 Robert Penner
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  * Neither the name of the author nor the names of contributors may be used to
//    endorse or promote products derived from this software without
//    specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
float _p, _s;

static float TweenEasing::EaseLinear(float t, float d) {
  return t / d;
}

static float TweenEasing::EaseInSine(float t, float b, float c, float d) {
  return -c * Maths.Cos((t/d) * HALF_PI) + c + b;
}
static float TweenEasing::EaseOutSine(float t, float b, float c, float d) {
  return c * Maths.Sin((t/d) * HALF_PI) + b;
}
static float TweenEasing::EaseInOutSine(float t, float b, float c, float d) {
  return (-c*0.5) * (Maths.Cos(Maths.Pi*(t/d)) -1.0) + b;
}

static float TweenEasing::EaseInPower(float t, float b, float c, float d, float exponent) {
  t = t / d;
  return c*Maths.RaiseToPower(t, exponent) + b;
}
static float TweenEasing::EaseOutPower(float t, float b, float c, float d, float exponent) {
  _s = 1.0;
  if (FloatToInt(exponent, eRoundDown) % 2 == 0) {
    c = -c;
    _s = -_s;
  }
  t = (t / d) - 1.0;
  return c*(Maths.RaiseToPower(t, exponent) + _s) + b;
}
static float TweenEasing::EaseInOutPower(float t, float b, float c, float d, float exponent) {
  t = t / (d*0.5);
  if (t < 1.0) return (c*0.5)*Maths.RaiseToPower(t, exponent) + b;
  _s = 2.0;
  if (FloatToInt(exponent, eRoundDown) % 2 == 0) {
    c = -c;
    _s = -2.0;
  }
  return (c*0.5)*(Maths.RaiseToPower(t - 2.0, exponent) + _s) + b;
}

static float TweenEasing::EaseInQuad(float t, float b, float c, float d) {
  t = (t / d);
  return c*t*t + b;
}
static float TweenEasing::EaseOutQuad(float t, float b, float c, float d) {
  t = (t / d);
  return -c*t*(t-2.0) + b;
}
static float TweenEasing::EaseInOutQuad(float t, float b, float c, float d) {
  t = t / (d*0.5);
  if (t < 1.0) return (c*0.5)*t*t + b;
  t = t - 1.0;
  return -(c*0.5)*(t*(t-2.0) - 1.0) + b;
}

static float TweenEasing::EaseInExpo(float t, float b, float c, float d) {
  if (t == 0.0) return b;
  return c * Maths.RaiseToPower(2.0, 10.0 * (t/d - 1.0)) + b;
}
static float TweenEasing::EaseOutExpo(float t, float b, float c, float d) {
  if (t == d) return b + c;
  return c * (-Maths.RaiseToPower(2.0, -10.0 * (t/d)) + 1.0) + b;
}
static float TweenEasing::EaseInOutExpo(float t, float b, float c, float d) {
  if (t == 0.0) return b;
  if (t == d) return b + c;
  t = t / (d*0.5);
  if (t < 1.0) return (c*0.5) * Maths.RaiseToPower(2.0, 10.0 * (t - 1.0)) + b;
  t = t - 1.0;
  return (c*0.5) * (-Maths.RaiseToPower(2.0, -10.0 * t) + 2.0) + b;
}

static float TweenEasing::EaseInCirc(float t, float b, float c, float d) {
  t = t / d;
  return -c * (Maths.Sqrt(1.0 - t*t) - 1.0) + b;
}
static float TweenEasing::EaseOutCirc(float t, float b, float c, float d) {
  t = t / d - 1.0;
  return c * Maths.Sqrt(1.0 - t*t) + b;
}
static float TweenEasing::EaseInOutCirc(float t, float b, float c, float d) {
  t = t / (d*0.5);
  if (t < 1.0) return -(c*0.5) * (Maths.Sqrt(1.0 - t*t) - 1.0) + b;
  t = t - 2.0;
  return (c*0.5) * (Maths.Sqrt(1.0 - t*t) + 1.0) + b;
}

static float TweenEasing::EaseInBack(float t, float b, float c, float d) {
  _s = 1.70158;
  t = (t / d);
  return c*t*t*((_s+1.0)*t - _s) + b;
}
static float TweenEasing::EaseOutBack(float t, float b, float c, float d) {
  _s = 1.70158;
  t = (t / d) - 1.0;
  return c*(t*t*((_s+1.0)*t + _s) + 1.0) + b;
}
static float TweenEasing::EaseInOutBack(float t, float b, float c, float d) {
  _s = 1.70158;
  t = t / (d / 2.0);
  _s = _s * 1.525;
  if (t < 1.0) return (c/2.0)*(t*t*((_s+1.0)*t - _s)) + b;
  t = t - 2.0;
  return (c/2.0)*(t*t*((_s+1.0)*t + _s) + 2.0) + b;
}

static float TweenEasing::EaseOutBounce(float t, float b, float c, float d) {
  t = t / d;
  if (t < (1.0 / 2.75)) return c*(7.5625*t*t) + b;
  else if (t < (2.0 / 2.75)) {
    t = t - (1.5 / 2.75);
    return c*(7.5625*t*t + 0.75) + b;
  }
  else if (t < (2.5 / 2.75)) {
    t = t - (2.25 / 2.75);
    return c*(7.5625*t*t + 0.9375) + b;
  }
  t = t - (2.625 / 2.75);
  return c*(7.5625*t*t + 0.984375) + b;
}
static float TweenEasing::EaseInBounce(float t, float b, float c, float d) {
  return c - TweenEasing.EaseOutBounce(d - t, 0.0, c, d) + b;
}
static float TweenEasing::EaseInOutBounce(float t, float b, float c, float d) {
  if (t < (d / 2.0)) return TweenEasing.EaseInBounce(t * 2.0, 0.0, c, d) * 0.5 + b;
  return (TweenEasing.EaseOutBounce((t * 2.0) - d, 0.0, c, d) * 0.5) + (c*0.5) + b;
}

static float TweenEasing::EaseInElastic(float t, float b, float c, float d) {
  if (t == 0.0) return b;
  t = t / d;
  if (t == 1.0) return b + c;
  _p = d * 0.3;
  _s = _p / 4.0;
  t = t - 1.0;
  return -(c*Maths.RaiseToPower(2.0, 10.0*t) * Maths.Sin(((t*d - _s)*DOUBLE_PI) / _p)) + b;
}
static float TweenEasing::EaseOutElastic(float t, float b, float c, float d) {
  if (t == 0.0) return b;
  t = t / d;
  if (t == 1.0) return b + c;
  _p = d * 0.3;
  _s = _p / 4.0;
  return ((c*Maths.RaiseToPower(2.0, -10.0*t)) * Maths.Sin(((t*d - _s)*DOUBLE_PI / _p)) + c + b);
}
static float TweenEasing::EaseInOutElastic(float t, float b, float c, float d) {
  if (t == 0.0) return b;
  t = t / (d * 0.5);
  if (t == 2.0) return b + c;
  _p = d * (0.3 * 1.5);
  _s = _p / 4.0;
  if (t < 1.0) {
    t = t - 1.0;
    return -0.5*(c*Maths.RaiseToPower(2.0, 10.0*t) * Maths.Sin(((t*d - _s)*DOUBLE_PI) / _p)) + b;
  }
  t = t - 1.0;
  return c*Maths.RaiseToPower(2.0, -10.0*t) * Maths.Sin(((t*d - _s)*DOUBLE_PI) / _p)*0.5 + c + b;
}

static float TweenEasing::GetValue(float elapsed, float duration, TweenEasingType easingType) {
  if (easingType == eEaseLinearTween) return TweenEasing.EaseLinear(elapsed, duration);
  if (easingType == eEaseInSineTween) return TweenEasing.EaseInSine(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseOutSineTween) return TweenEasing.EaseOutSine(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInOutSineTween) return TweenEasing.EaseInOutSine(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInCubicTween) return TweenEasing.EaseInPower(elapsed, 0.0, 1.0, duration, 3.0);
  if (easingType == eEaseOutCubicTween) return TweenEasing.EaseOutPower(elapsed, 0.0, 1.0, duration, 3.0);
  if (easingType == eEaseInOutCubicTween) return TweenEasing.EaseInOutPower(elapsed, 0.0, 1.0, duration, 3.0);
  if (easingType == eEaseInQuartTween) return TweenEasing.EaseInPower(elapsed, 0.0, 1.0, duration, 4.0);
  if (easingType == eEaseOutQuartTween) return TweenEasing.EaseOutPower(elapsed, 0.0, 1.0, duration, 4.0);
  if (easingType == eEaseInOutQuartTween) return TweenEasing.EaseInOutPower(elapsed, 0.0, 1.0, duration, 4.0);
  if (easingType == eEaseInQuintTween) return TweenEasing.EaseInPower(elapsed, 0.0, 1.0, duration, 5.0);
  if (easingType == eEaseOutQuintTween) return TweenEasing.EaseOutPower(elapsed, 0.0, 1.0, duration, 5.0);
  if (easingType == eEaseInOutQuintTween) return TweenEasing.EaseInOutPower(elapsed, 0.0, 1.0, duration, 5.0);
  if (easingType == eEaseInQuadTween) return TweenEasing.EaseInQuad(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseOutQuadTween) return TweenEasing.EaseOutQuad(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInOutQuadTween) return TweenEasing.EaseInOutQuad(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInExpoTween) return TweenEasing.EaseInExpo(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseOutExpoTween) return TweenEasing.EaseOutExpo(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInOutExpoTween) return TweenEasing.EaseInOutExpo(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInCircTween) return TweenEasing.EaseInCirc(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseOutCircTween) return TweenEasing.EaseOutCirc(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInOutCircTween) return TweenEasing.EaseInOutCirc(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInBackTween) return TweenEasing.EaseInBack(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseOutBackTween) return TweenEasing.EaseOutBack(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInOutBackTween) return TweenEasing.EaseInOutBack(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInElasticTween) return TweenEasing.EaseInElastic(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseOutElasticTween) return TweenEasing.EaseOutElastic(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInOutElasticTween) return TweenEasing.EaseInOutElastic(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInBounceTween) return TweenEasing.EaseInBounce(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseOutBounceTween) return TweenEasing.EaseOutBounce(elapsed, 0.0, 1.0, duration);
  if (easingType == eEaseInOutBounceTween) return TweenEasing.EaseInOutBounce(elapsed, 0.0, 1.0, duration);
  return TweenEasing.EaseLinear(elapsed, duration);
}
// END BSD LICENSE

#endregion

#region TweenBase

function TweenBase::Restart() {
  this.Elapsed = -this.StartDelay;
}

function TweenBase::Reverse() {
  float fromValue = this.ToValue;
  this.ToValue = this.FromValue;
  this.FromValue = fromValue;

  TweenEasingType easingType = this.EasingType;
  if (easingType == eEaseOutSineTween) easingType = eEaseInSineTween;
  else if (easingType == eEaseInSineTween) easingType = eEaseOutSineTween;
  else if (easingType == eEaseOutCubicTween) easingType = eEaseInCubicTween;
  else if (easingType == eEaseInCubicTween) easingType = eEaseOutCubicTween;
  else if (easingType == eEaseOutQuadTween) easingType = eEaseInQuadTween;
  else if (easingType == eEaseInQuadTween) easingType = eEaseOutQuadTween;
  else if (easingType == eEaseOutQuintTween) easingType = eEaseInQuintTween;
  else if (easingType == eEaseInQuintTween) easingType = eEaseOutQuintTween;
  else if (easingType == eEaseOutQuartTween) easingType = eEaseInQuartTween;
  else if (easingType == eEaseInQuartTween) easingType = eEaseOutQuartTween;
  else if (easingType == eEaseOutExpoTween) easingType = eEaseInExpoTween;
  else if (easingType == eEaseInExpoTween) easingType = eEaseOutExpoTween;
  else if (easingType == eEaseOutCircTween) easingType = eEaseInCircTween;
  else if (easingType == eEaseInCircTween) easingType = eEaseOutCircTween;
  else if (easingType == eEaseOutElasticTween) easingType = eEaseInElasticTween;
  else if (easingType == eEaseInElasticTween) easingType = eEaseOutElasticTween;
  else if (easingType == eEaseOutBounceTween) easingType = eEaseInBounceTween;
  else if (easingType == eEaseInBounceTween) easingType = eEaseOutBounceTween;
  else if (easingType == eEaseOutBackTween) easingType = eEaseInBackTween;
  else if (easingType == eEaseInBackTween) easingType = eEaseOutBackTween;
  this.EasingType = easingType;
}

bool TweenBase::IsPlaying() {
  return this.Duration != NULL_TWEEN_DURATION && this.Elapsed <= this.Duration;
}

int TweenBase::Init(float timing, int fromValue, int toValue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  if (timingType == eTweenSpeed) {
    timing = TweenMaths.MaxFloat(1.0 / IntToFloat(GetGameSpeed()), SpeedToSeconds(timing, fromValue, 0, toValue, 0));
  }
  this.FromValue = IntToFloat(fromValue);
  this.ToValue = IntToFloat(toValue);
  this.Duration = IntToFloat(SecondsToLoops(timing));
  this.StartDelay = IntToFloat(SecondsToLoops(TweenMaths.Abs(startDelay)));
  this.Elapsed = -this.StartDelay;
  this.EasingType = easingType;
  this.Style = style;

  return FloatToInt(this.Duration - this.Elapsed, eRoundUp) + 1;
}

#endregion

#region _TweenObject

function _TweenObject::InitTweenObject(
  int fromValue2, int toValue2, _TweenType type, _TweenReferenceType refType,
  int refID, GUIControl* guiControlRef, String stringRef
) {
  this.FromValue2 = IntToFloat(fromValue2);
  this.ToValue2 = IntToFloat(toValue2);
  this.Type = type;
  this.RefType = refType;
  this.RefID = refID;
  this.GUIControlRef = guiControlRef;
  this.StringRef = stringRef;
}

function _TweenObject::Release() {
  this.Duration = NULL_TWEEN_DURATION;
}

function _TweenObject::ReverseTweenObject() {
  float fromValue2 = this.ToValue2;
  this.ToValue2 = this.FromValue2;
  this.FromValue2 = fromValue2;

  this.Reverse();
}

int _value, _value2;
Region* _region;
Character* _character;
Object* _object;

function _TweenObject::Step(float amount) {
  switch (this.Type) {
    // GUI step
    case _eTweenGUIPosition:
      if (this.FromValue == this.ToValue) {
        _value = gui[this.RefID].X;
      }
      else {
        _value = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
        #ifndef SCRIPT_API_v3507
        _value = TweenMaths.MinInt(_value, System.ScreenWidth - 1);
        #endif
      }
      if (this.FromValue2 == this.ToValue2) {
        _value2 = gui[this.RefID].Y;
      }
      else {
        _value2 = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
        #ifndef SCRIPT_API_v3507
        _value2 = TweenMaths.MinInt(_value2, System.ScreenHeight - 1);
        #endif
      }
      gui[this.RefID].SetPosition(_value, _value2);
      break;
    case _eTweenGUISize:
      if (this.FromValue == this.ToValue) {
        _value = gui[this.RefID].Width;
      }
      else {
        _value = TweenMaths.MaxInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount),  1);
        #ifndef SCRIPT_API_v3507
        _value = TweenMaths.MinInt(_value, System.ScreenWidth);
        #endif
      }
      if (this.FromValue2 == this.ToValue2) {
        _value2 = gui[this.RefID].Height;
      }
      else {
        _value2 = TweenMaths.MaxInt(TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount), 1);
        #ifndef SCRIPT_API_v3507
        _value2 = TweenMaths.MinInt(_value2, System.ScreenHeight);
        #endif
      }
      gui[this.RefID].SetSize(_value, _value2);
      break;
    case _eTweenGUITransparency: {
      // Workaround for Popup Modal GUIs. If the scripter is fading this in, then make it vsible.
      GUI* refGUI = gui[this.RefID];
      if (this.Elapsed == 0.0 && refGUI.Visible == false && refGUI.Transparency == 100) {
        refGUI.Visible = true;
      }
      refGUI.Transparency = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      // Workaround for Popup Modal GUIs. If the scripter is fading this out, then make it invisble.
      if (this.Elapsed == this.Duration && refGUI.Visible == true && refGUI.Transparency == 100) {
        refGUI.Visible = false;
      }
      break;
    }
    case _eTweenGUIZOrder:
      gui[this.RefID].ZOrder = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      break;
    #ifdef SCRIPT_API_v350
    case _eTweenGUIBackgroundColorRed:
      gui[this.RefID].BackgroundColor = Game.GetColorFromRGB(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetGFromColor(gui[this.RefID].BackgroundColor),
        TweenGame.GetBFromColor(gui[this.RefID].BackgroundColor)
      );
      break;
    case _eTweenGUIBackgroundColorGreen:
      gui[this.RefID].BackgroundColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(gui[this.RefID].BackgroundColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetBFromColor(gui[this.RefID].BackgroundColor)
      );
      break;
    case _eTweenGUIBackgroundColorBlue:
      gui[this.RefID].BackgroundColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(gui[this.RefID].BackgroundColor),
        TweenGame.GetGFromColor(gui[this.RefID].BackgroundColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255)
      );
      break;
    case _eTweenGUIBorderColorRed:
      gui[this.RefID].BorderColor = Game.GetColorFromRGB(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetGFromColor(gui[this.RefID].BorderColor),
        TweenGame.GetBFromColor(gui[this.RefID].BorderColor)
      );
      break;
    case _eTweenGUIBorderColorGreen:
      gui[this.RefID].BorderColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(gui[this.RefID].BorderColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetBFromColor(gui[this.RefID].BorderColor)
      );
      break;
    case _eTweenGUIBorderColorBlue:
      gui[this.RefID].BorderColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(gui[this.RefID].BorderColor),
        TweenGame.GetGFromColor(gui[this.RefID].BorderColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255)
      );
      break;
    #endif
    // OBJECT step
    case _eTweenObjectPosition:
      if (this.FromValue != this.ToValue) {
        object[this.RefID].X = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      }
      if (this.FromValue2 != this.ToValue2) {
        object[this.RefID].Y = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
      }
      break;
    case _eTweenObjectTransparency: {
      Object *objectRef = object[this.RefID];
      if (this.Elapsed == 0.0 && objectRef.Visible == false && objectRef.Transparency == 100) {
        objectRef.Visible = true;
      }
      objectRef.Transparency = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      if (this.Elapsed == this.Duration && objectRef.Visible == true && objectRef.Transparency == 100) {
        objectRef.Visible = false;
      }
      break;
    }
    #ifdef SCRIPT_API_v341
    case _eTweenObjectTintRed:
      _object = object[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _value2 = TweenMaths.MaxInt(0, _object.TintSaturation);
      _object.Tint(_value, _object.TintGreen, _object.TintBlue, _value2, _object.TintLuminance);
      break;
    case _eTweenObjectTintGreen:
      _object = object[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _value2 = TweenMaths.MaxInt(0, _object.TintSaturation);
      _object.Tint(_object.TintRed, _value, _object.TintBlue, _value2, _object.TintLuminance);
      break;
    case _eTweenObjectTintBlue:
      _object = object[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _value2 = TweenMaths.MaxInt(0, _object.TintSaturation);
      _object.Tint(_object.TintRed, _object.TintGreen, _value, _value2, _object.TintLuminance);
      break;
    case _eTweenObjectTintSaturation:
      _object = object[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      _object.Tint(_object.TintRed, _object.TintGreen, _object.TintBlue, _value, _object.TintLuminance);
      break;
    case _eTweenObjectTintLuminance:
      _object = object[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      _value2 = TweenMaths.MaxInt(0, _object.TintSaturation);
      _object.Tint(_object.TintRed, _object.TintGreen, _object.TintBlue, _value2, _value);
      break;
    #endif
    // CHARACTER step
    case _eTweenCharacterPosition:
      if (this.FromValue != this.ToValue) {
        character[this.RefID].x = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      }
      if (this.FromValue2 != this.ToValue2) {
        character[this.RefID].y = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
      }
      break;
    case _eTweenCharacterScaling:
      character[this.RefID].Scaling = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 5, 200);
      break;
    case _eTweenCharacterTransparency:
      character[this.RefID].Transparency = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      break;
    case _eTweenCharacterAnimationSpeed:
      character[this.RefID].AnimationSpeed = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      break;
    case _eTweenCharacterZ:
      character[this.RefID].z = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      break;
    #ifdef SCRIPT_API_v341
    case _eTweenCharacterTintRed:
      _character = character[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _value2 = TweenMaths.MaxInt(0, _character.TintSaturation);
      _character.Tint(_value, _character.TintGreen, _character.TintBlue, _value2, _character.TintLuminance);
      break;
    case _eTweenCharacterTintGreen:
      _character = character[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _value2 = TweenMaths.MaxInt(0, _character.TintSaturation);
      _character.Tint(_character.TintRed, _value, _character.TintBlue, _value2, _character.TintLuminance);
      break;
    case _eTweenCharacterTintBlue:
      _character = character[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _value2 = TweenMaths.MaxInt(0, _character.TintSaturation);
      _character.Tint(_character.TintRed, _character.TintGreen, _value, _value2, _character.TintLuminance);
      break;
    case _eTweenCharacterTintSaturation:
      _character = character[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      _character.Tint(_character.TintRed, _character.TintGreen, _character.TintBlue, _value, _character.TintLuminance);
      break;
    case _eTweenCharacterTintLuminance:
      _character = character[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      _value2 = TweenMaths.MaxInt(0, _character.TintSaturation);
      _character.Tint(_character.TintRed, _character.TintGreen, _character.TintBlue, _value2, _value);
      break;
    #endif
    // REGION step
    case _eTweenRegionLightLevel:
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), -100, 100);
      region[this.RefID].LightLevel = _value;
      break;
    case _eTweenRegionTintRed:
      _region = region[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _region.Tint(_value, _region.TintGreen, _region.TintBlue, _region.TintSaturation, _region.TintLuminance);
      break;
    case _eTweenRegionTintGreen:
      _region = region[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _region.Tint(_region.TintRed, _value, _region.TintBlue, _region.TintSaturation, _region.TintLuminance);
      break;
    case _eTweenRegionTintBlue:
      _region = region[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255);
      _region.Tint(_region.TintRed, _region.TintGreen, _value, _region.TintSaturation, _region.TintLuminance);
      break;
    case _eTweenRegionTintSaturation:
      _region = region[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 1, 100);
      _region.Tint(_region.TintRed, _region.TintGreen, _region.TintBlue, _value, _region.TintLuminance);
      break;
    case _eTweenRegionTintLuminance:
      _region = region[this.RefID];
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      _region.Tint(_region.TintRed, _region.TintGreen, _region.TintBlue, _region.TintSaturation, _value);
      break;
    // GUICONTROL step
    case _eTweenGUIControlPosition:
      if (this.FromValue == this.ToValue) _value = this.GUIControlRef.X; else _value = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      if (this.FromValue2 == this.ToValue2) _value2 = this.GUIControlRef.Y; else _value2 = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
      this.GUIControlRef.SetPosition(_value, _value2);
      break;
    case _eTweenGUIControlSize:
      if (this.FromValue == this.ToValue) _value = this.GUIControlRef.Width; else _value = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      if (this.FromValue2 == this.ToValue2) _value2 = this.GUIControlRef.Height; else _value2 = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
      this.GUIControlRef.SetSize(_value, _value2);
      break;
    // LABEL step
    case _eTweenLabelTextColorRed:
      this.GUIControlRef.AsLabel.TextColor = Game.GetColorFromRGB(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetGFromColor(this.GUIControlRef.AsLabel.TextColor),
        TweenGame.GetBFromColor(this.GUIControlRef.AsLabel.TextColor)
      );
      break;
    case _eTweenLabelTextColorGreen:
      this.GUIControlRef.AsLabel.TextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsLabel.TextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetBFromColor(this.GUIControlRef.AsLabel.TextColor)
      );
      break;
    case _eTweenLabelTextColorBlue:
      this.GUIControlRef.AsLabel.TextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsLabel.TextColor),
        TweenGame.GetGFromColor(this.GUIControlRef.AsLabel.TextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255)
      );
      break;
    // BUTTON step
    case _eTweenButtonTextColorRed:
      this.GUIControlRef.AsButton.TextColor = Game.GetColorFromRGB(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetGFromColor(this.GUIControlRef.AsButton.TextColor),
        TweenGame.GetBFromColor(this.GUIControlRef.AsButton.TextColor));
      break;
    case _eTweenButtonTextColorGreen:
      this.GUIControlRef.AsButton.TextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsButton.TextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetBFromColor(this.GUIControlRef.AsButton.TextColor)
      );
      break;
    case _eTweenButtonTextColorBlue:
      this.GUIControlRef.AsButton.TextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsButton.TextColor),
        TweenGame.GetGFromColor(this.GUIControlRef.AsButton.TextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255)
      );
      break;
    // TEXTBOX step
    case _eTweenTextBoxTextColorRed:
      this.GUIControlRef.AsTextBox.TextColor = Game.GetColorFromRGB(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetGFromColor(this.GUIControlRef.AsTextBox.TextColor),
        TweenGame.GetBFromColor(this.GUIControlRef.AsTextBox.TextColor)
      );
      break;
    case _eTweenTextBoxTextColorGreen:
      this.GUIControlRef.AsTextBox.TextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsTextBox.TextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetBFromColor(this.GUIControlRef.AsTextBox.TextColor)
      );
      break;
    case _eTweenTextBoxTextColorBlue:
      this.GUIControlRef.AsTextBox.TextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsTextBox.TextColor),
        TweenGame.GetGFromColor(this.GUIControlRef.AsTextBox.TextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255)
      );
      break;
    // LISTBOX step
    case _eTweenListBoxSelectedIndex:
      this.GUIControlRef.AsListBox.SelectedIndex = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), -1, this.GUIControlRef.AsListBox.ItemCount - 1);
      break;
    case _eTweenListBoxTopItem:
      this.GUIControlRef.AsListBox.TopItem = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, this.GUIControlRef.AsListBox.ItemCount - 1);
      break;
    #ifdef SCRIPT_API_v350
    // ListBox (3.5.0) step
    case _eTweenListBoxSelectedBackColorRed:
      this.GUIControlRef.AsListBox.SelectedBackColor = Game.GetColorFromRGB(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetGFromColor(this.GUIControlRef.AsListBox.SelectedBackColor),
        TweenGame.GetBFromColor(this.GUIControlRef.AsListBox.SelectedBackColor)
      );
      break;
    case _eTweenListBoxSelectedBackColorGreen:
      this.GUIControlRef.AsListBox.SelectedBackColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsListBox.SelectedBackColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetBFromColor(this.GUIControlRef.AsListBox.SelectedBackColor)
      );
      break;
    case _eTweenListBoxSelectedBackColorBlue:
      this.GUIControlRef.AsListBox.SelectedBackColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsListBox.SelectedBackColor),
        TweenGame.GetGFromColor(this.GUIControlRef.AsListBox.SelectedBackColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255)
      );
      break;
    case _eTweenListBoxSelectedTextColorRed:
      this.GUIControlRef.AsListBox.SelectedTextColor = Game.GetColorFromRGB(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetGFromColor(this.GUIControlRef.AsListBox.SelectedTextColor),
        TweenGame.GetBFromColor(this.GUIControlRef.AsListBox.SelectedTextColor)
      );
      break;
    case _eTweenListBoxSelectedTextColorGreen:
      this.GUIControlRef.AsListBox.SelectedTextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsListBox.SelectedTextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetBFromColor(this.GUIControlRef.AsListBox.SelectedTextColor)
      );
      break;
    case _eTweenListBoxSelectedTextColorBlue:
      this.GUIControlRef.AsListBox.SelectedTextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsListBox.SelectedTextColor),
        TweenGame.GetGFromColor(this.GUIControlRef.AsListBox.SelectedTextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255)
      );
      break;
    case _eTweenListBoxTextColorRed:
      this.GUIControlRef.AsListBox.TextColor = Game.GetColorFromRGB(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetGFromColor(this.GUIControlRef.AsListBox.TextColor),
        TweenGame.GetBFromColor(this.GUIControlRef.AsListBox.TextColor)
      );
      break;
    case _eTweenListBoxTextColorGreen:
      this.GUIControlRef.AsListBox.TextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsListBox.TextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255),
        TweenGame.GetBFromColor(this.GUIControlRef.AsListBox.TextColor)
      );
      break;
    case _eTweenListBoxTextColorBlue:
      this.GUIControlRef.AsListBox.TextColor = Game.GetColorFromRGB(
        TweenGame.GetRFromColor(this.GUIControlRef.AsListBox.TextColor),
        TweenGame.GetGFromColor(this.GUIControlRef.AsListBox.TextColor),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255)
      );
      break;
    #endif
    // SLIDER step
    case _eTweenSliderValue:
      this.GUIControlRef.AsSlider.Value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), this.GUIControlRef.AsSlider.Min, this.GUIControlRef.AsSlider.Max);
      break;
    case _eTweenSliderHandleOffset:
      this.GUIControlRef.AsSlider.HandleOffset = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      break;
    // INVWINDOW step
    case _eTweenInvWindowTopItem:
      this.GUIControlRef.AsInvWindow.TopItem = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, this.GUIControlRef.AsInvWindow.ItemCount - 1);
      break;
    #ifdef SCRIPT_API_v3507
    // Camera Step
    case _eTweenCameraPosition:
      if (this.FromValue != this.ToValue) {
        Game.Cameras[this.RefID].X = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      }
      if (this.FromValue2 != this.ToValue2) {
        Game.Cameras[this.RefID].Y = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
      }
      break;
    case _eTweenCameraSize:
      if (this.FromValue != this.ToValue) {
        Game.Cameras[this.RefID].Width = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      }
      if (this.FromValue2 != this.ToValue2) {
        Game.Cameras[this.RefID].Height = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
      }
      break;

    // Viewport step
    case _eTweenViewportPosition:
      if (this.FromValue != this.ToValue) {
        Screen.Viewports[this.RefID].X = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      }
      if (this.FromValue2 != this.ToValue2) {
        Screen.Viewports[this.RefID].Y = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
      }
      break;
    case _eTweenViewportSize:
    if (this.FromValue != this.ToValue) {
        Screen.Viewports[this.RefID].Width = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      }
      if (this.FromValue2 != this.ToValue2) {
        Screen.Viewports[this.RefID].Height = TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount);
      }
      break;
    #endif
    // MISC step
    #ifndef SCRIPT_API_v3507
    case _eTweenViewport:
      if (this.FromValue == this.ToValue) _value = GetViewportX(); else _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, Room.Width);
      if (this.FromValue2 == this.ToValue2) _value2 = GetViewportY(); else _value2 = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount), 0, Room.Height);
      SetViewport(_value, _value2);
      break;
    #endif
    case _eTweenSystemGamma:
      System.Gamma = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 200);
      break;
    case _eTweenShakeScreen:
      ShakeScreenBackground(TweenMaths.MaxInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 2), TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount), 1);
      break;
    case _eTweenAreaScaling:
      SetAreaScaling(this.RefID, TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 5, 200), TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount), 5, 200));
      break;
    // AUDIO step
    case _eTweenSpeechVolume:
      SetSpeechVolume(TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 255));
      break;
    case _eTweenAmbientLightLevel:
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), -100, 100);
      SetAmbientLightLevel(_value);
      break;
    case _eTweenCharacterLightLevel:
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), -100, 100);
      character[this.RefID].SetLightLevel(_value);
      break;
    case _eTweenCharacterProperty:
      _value = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      character[this.RefID].SetProperty(this.StringRef, _value);
      break;
    case _eTweenHotspotProperty:
      _value = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      hotspot[this.RefID].SetProperty(this.StringRef, _value);
      break;
    case _eTweenInventoryItemProperty:
      _value = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      inventory[this.RefID].SetProperty(this.StringRef, _value);
      break;
    case _eTweenObjectLightLevel:
      _value = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), -100, 100);
      object[this.RefID].SetLightLevel(_value);
      break;
    case _eTweenObjectProperty:
      _value = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      object[this.RefID].SetProperty(this.StringRef, _value);
      break;
    case _eTweenRoomProperty:
      _value = TweenMaths.Lerp(this.FromValue, this.ToValue, amount);
      Room.SetProperty(this.StringRef, _value);
      break;
    // Pre AGS 3.2 strict audio
    #ifndef STRICT_AUDIO
    case _eTweenMusicMasterVolume:
      SetMusicMasterVolume(TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), MUSIC_MASTER_VOLUME_MIN, 100));
      break;
    case _eTweenDigitalMasterVolume:
      SetDigitalMasterVolume(TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100));
      break;
    case _eTweenSoundVolume:
      SetSoundVolume(TweenMaths.MaxInt(0, TweenMaths.Lerp(this.FromValue, this.ToValue, amount)));
      break;
    case _eTweenChannelVolume:
      SetChannelVolume(this.RefID, TweenMaths.MaxInt(0, TweenMaths.Lerp(this.FromValue, this.ToValue, amount)));
      break;
    case _eTweenMusicVolume:
      SetMusicVolume(TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100));
      break;
    #endif
    // AGS 3.2+ strict audio
    #ifdef STRICT_AUDIO
    case _eTweenSystemVolume:
      System.Volume = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, 100);
      break;
    case _eTweenAudioChannelPosition: {
      AudioChannel* channel = System.AudioChannels[this.RefID];
      if (_ShouldLeaveAudioAlone(channel)) return;
      channel.Seek(TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, channel.LengthMs));
      break;
    }
    case _eTweenAudioChannelVolume: {
      AudioChannel* channel = System.AudioChannels[this.RefID];
      if (_ShouldLeaveAudioAlone(channel)) return;
      channel.Volume = TweenMaths.MaxInt(0, TweenMaths.Lerp(this.FromValue, this.ToValue, amount));
      break;
    }
    case _eTweenAudioChannelRoomLocation: {
      AudioChannel* channel = System.AudioChannels[this.RefID];
      if (_ShouldLeaveAudioAlone(channel)) return;
      channel.SetRoomLocation(
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0, Room.Width),
        TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue2, this.ToValue2, amount), 0, Room.Height)
        );
      break;
    }
    case _eTweenAudioChannelPanning: {
      AudioChannel* channel = System.AudioChannels[this.RefID];
      if (_ShouldLeaveAudioAlone(channel)) return;
      channel.Panning = TweenMaths.ClampInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), -100, 100);
      break;
    }
    case _eTweenAudioChannelSpeed: {
      AudioChannel* channel = System.AudioChannels[this.RefID];
      if (_ShouldLeaveAudioAlone(channel)) return;
      channel.Speed = TweenMaths.MaxInt(TweenMaths.Lerp(this.FromValue, this.ToValue, amount), 0);
      break;
    }
    #endif
  }
}

float _t;

bool _TweenObject::Update() {
  if (this.Duration < 0.0) {
    return false;
  }

  if (this.Elapsed < 0.0) {
    // Handle delays.
    this.Elapsed = this.Elapsed + 1.0;
  }
  else {
    // Compute the amount based on the easingType
    _t = TweenEasing.GetValue(this.Elapsed, this.Duration, this.EasingType);

    // Step
    this.Step(_t);
    this.Elapsed = this.Elapsed + 1.0;

    // Repeat if needed or Release
    if (this.Elapsed > this.Duration) {
      if (this.Style == eRepeatTween) {
        this.Restart();
      }
      else if (this.Style == eReverseRepeatTween) {
        this.ReverseTweenObject();
        this.Restart();
      }
      else {
        this.Release();
      }
    }
  }

  return true;
}

#endregion

#region Internal Tween stoppers

bool _ShouldCleanUpTweenAtIndex(int index) {
  if (_tweens[index].Duration != NULL_TWEEN_DURATION) {
    if (Tween_STOP_ALL_ON_LEAVE_ROOM) {
      return true;
    }

    _TweenReferenceType refType = _tweens[index].RefType;
    _TweenType type = _tweens[index].Type;
    #ifdef STRICT_AUDIO
    if (refType == _eTweenReferenceAudioChannel) {
      return false;
    }
    #endif
    return (
      refType != _eTweenReferenceGUI
      && refType != _eTweenReferenceGUIControl
      && (
        refType != _eTweenReferenceMisc
        || type == _eTweenRoomProperty
        || type == _eTweenHotspotProperty
        #ifdef SCRIPT_API_v3507
        || refType == _eTweenReferenceCamera
        || refType == _eTweenReferenceViewport
        #endif
        #ifndef SCRIPT_API_v3507
        || type == _eTweenViewport
        #endif
        || type == _eTweenAreaScaling
      )
      && refType != _eTweenReferenceInventoryItem
    );
  }
  return false;
}

function _CleanupTweens() {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    if (_ShouldCleanUpTweenAtIndex(i)) {
      _tweens[i].Step(0.0);
      _tweens[i].Release();
    }
  }
}

function _StopTween(int index, TweenStopResult result) {
  if (_tweens[index].Duration != NULL_TWEEN_DURATION) {
    if (result == eFinishTween) {
      _tweens[index].Step(1.0);
    }
    else if (result == eResetTween) {
      _tweens[index].Step(0.0);
    }

    _tweens[index].Release();
  }
}

function _StopTweens(_TweenReferenceType refType, int refID, TweenStopResult result) {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    if (_tweens[i].RefType == refType && _tweens[i].RefID == refID) {
      _StopTween(i, result);
    }
  }
}

function _StopTweensOfType(_TweenType type, TweenStopResult result) {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    if (_tweens[i].Type == type) {
      _StopTween(i, result);
    }
  }
}

function _StopTweensOfTypeWithReference(_TweenType type, int refID, TweenStopResult result) {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    if (_tweens[i].Type == type && _tweens[i].RefID == refID) {
      _StopTween(i, result);
    }
  }
}

function _StopTweensOfTypeWithStringReference(_TweenType type, int refID, String stringRef, TweenStopResult result) {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    if (_tweens[i].Type == type && _tweens[i].RefID == refID && _tweens[i].StringRef == stringRef) {
      _StopTween(i, result);
    }
  }
}

function _StopTweensForGUIControl(GUIControl* guiControlRef, TweenStopResult result) {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    if (_tweens[i].GUIControlRef == guiControlRef) {
      _StopTween(i, result);
    }
  }
}

function _StopTweensForGUIControlOfType(GUIControl* guiControlRef, _TweenType type, TweenStopResult result) {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    if (_tweens[i].GUIControlRef == guiControlRef && _tweens[i].Type == type) {
      _StopTween(i, result);
    }
  }
}

#endregion

#region AGS events

function game_start() {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    _tweens[i].Release();
  }
}

int _i;

function repeatedly_execute_always() {
  // Steps through every active tween
  _i = 0;
  _longestTweenDuration = 0.0;

  for (; _i < Tween_MAX_INSTANCES; _i++) {
    if (_tweens[_i].Update()) {
      if(_tweens[_i].IsPlaying()) {
        _CheckIfIsLongestTween(_i);
      }
    }
  }
}

function on_event(EventType event, int data) {
  if (event == eEventLeaveRoom) {
    // If the player leaves the room, reset and stop tweens
    _CleanupTweens();
  }
}

#endregion

#region Tween

static function Tween::IncreaseGameSpeed() {
  if (GetGameSpeed() < 60) {
    _gameSpeed = GetGameSpeed();
    SetGameSpeed(60);
  }
}

static function Tween::RestoreGameSpeed() {
  if (_gameSpeed > -1) {
    SetGameSpeed(_gameSpeed);
    _gameSpeed = -1;
  }
}

static function Tween::IncreaseGameSpeedOnBlock(bool value) {
  _increaseGameSpeedOnBlockingTweens = value;
}

static function Tween::StopAll(TweenStopResult result) {
  for (int i = 0; i < Tween_MAX_INSTANCES; i++) {
    _StopTween(i, result);
  }
}

static function Tween::WaitForAllToFinish() {
  if (_longestTweenDuration > 0.0) {
    Wait(FloatToInt(_longestTweenDuration, eRoundUp));
  }
}

bool Tween::Update() {
  if (this.Duration > 0.0) {
    if (this.Elapsed < 0.0) {
      // Handle delays.
      this.Elapsed = this.Elapsed + 1.0;
    }
    else {
      // Compute the amount based on the easingType
      float t = TweenEasing.GetValue(
        this.Elapsed,
        this.Duration,
        this.EasingType
        );

      // Update the tween
      if (this.FromValue == this.ToValue) {
        this.Value = FloatToInt(this.ToValue);
      }
      else {
        this.Value = TweenMaths.Lerp(this.FromValue, this.ToValue, t);
      }

      this.Elapsed = this.Elapsed + 1.0;

      // Repeat tween if needed
      if (this.Elapsed > this.Duration) {
        if (this.Style == eRepeatTween) {
          this.Restart();
        }
        else if (this.Style == eReverseRepeatTween) {
          this.Reverse();
          this.Restart();
        }
        else {
          this.Duration = NULL_TWEEN_DURATION;
        }
      }
    }
    return true;
  }

  return false;
}

function Tween::Stop(TweenStopResult result) {
  if (this.Duration != NULL_TWEEN_DURATION) {
    if (result == eFinishTween) {
      this.Value = FloatToInt(this.ToValue);
    }
    else if (result == eResetTween) {
      this.Value = FloatToInt(this.FromValue);
    }

    this.Duration = NULL_TWEEN_DURATION;
  }
}

float Tween::GetProgress() {
  if (this.Elapsed <= 0.0 || this.Duration == 0.0) return 0.0;
  if (this.IsPlaying()) return (this.Elapsed / this.Duration);
  return 1.0;
}

#endregion

#region Tween construction

int _GetAvailableIndexFromTweenObjectArray() {
  int index = -1;
  for (int i = 0; i < Tween_MAX_INSTANCES && index == -1; i++) {
    if (_tweens[i].Duration == NULL_TWEEN_DURATION) {
      index = i;
    }
  }

#ifdef DEBUG
  // Let the scripter know that tweens are maxed out, but ignore it completely in the non-debug version.
  _AssertTrue(index >= 0, String.Format("Cannot create new tween because the Tween module is currently playing %d tween(s), which is the maximum. You can increase this max number on the Tween module script header.", Tween_MAX_INSTANCES));
#endif

  return index;
}

int _StartTween(
  _TweenType type, float timing, int toValue, int toValue2, int fromValue, int fromValue2,
  _TweenReferenceType refType, int refID, GUIControl* guiControlRef, String stringRef, TweenEasingType easingType,
  TweenStyle style, float startDelay, TweenTimingType timingType
) {

  int index = _GetAvailableIndexFromTweenObjectArray();
#ifdef DEBUG
  // Make sure the index is good. This should not happen to scripters ever.
  _AssertTrue(index >= 0 && index < Tween_MAX_INSTANCES, "Cannot create Tween. Invalid index!");
#endif

  if (_increaseGameSpeedOnBlockingTweens && style == eNoBlockTween) {
    Tween.IncreaseGameSpeed();
  }

  if (timingType == eTweenSpeed) {
    timing = TweenMaths.MaxFloat(1.0 / IntToFloat(GetGameSpeed()), SpeedToSeconds(timing, fromValue, fromValue2, toValue, toValue2));
  }
  int loops = _tweens[index].Init(timing, fromValue, toValue, easingType, style, startDelay, eTweenSeconds);
  _tweens[index].InitTweenObject(fromValue2, toValue2, type, refType, refID, guiControlRef, stringRef);

  _CheckIfIsLongestTween(index);

  if (_tweens[index].Style == eBlockTween) {
    Wait(loops);
    if (_increaseGameSpeedOnBlockingTweens) {
      Tween.RestoreGameSpeed();
    }
    return 1;
  }

  return loops;
}

#endregion

#region Internal Tween start functions

int _StartGUITween(_TweenType type, float timing, int toX, int toY, int fromX, int fromY,
    GUI* guiRef, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartTween(type, timing, toX, toY, fromX, fromY, _eTweenReferenceGUI, guiRef.ID, null, null, easingType, style, startDelay, timingType);
}

int _StartObjectTween(_TweenType type, float timing, int toX, int toY, int fromX, int fromY,
    Object* objectRef, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartTween(type, timing, toX, toY, fromX, fromY, _eTweenReferenceObject, objectRef.ID, null, null, easingType, style, startDelay, timingType);
}

int _StartCharacterTween(_TweenType type, float timing, int toX, int toY, int fromX, int fromY,
    Character* characterRef, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartTween(type, timing, toX, toY, fromX, fromY, _eTweenReferenceCharacter, characterRef.ID, null, null, easingType, style, startDelay, timingType);
}

int _StartRegionTween(_TweenType type, float timing, int toX, int toY, int fromX, int fromY,
    Region* regionRef, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartTween(type, timing, toX, toY, fromX, fromY, _eTweenReferenceRegion, regionRef.ID, null, null, easingType, style, startDelay, timingType);
}

int _StartGUIControlTween(_TweenType type, float timing, int toX, int toY, int fromX, int fromY,
    GUIControl* guiControlRef, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartTween(type, timing, toX, toY, fromX, fromY, _eTweenReferenceGUIControl, 0, guiControlRef, null, easingType, style, startDelay, timingType);
}

int _StartMiscTween(_TweenType type, float timing, int toX, int toY, int fromX, int fromY, int id,
    TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartTween(type, timing, toX, toY, fromX, fromY, _eTweenReferenceMisc, id, null, null, easingType, style, startDelay, timingType);
}

int _StartPropertyTween(
  _TweenType type, float timing, String property, int toValue, int fromValue, _TweenReferenceType refType,
  int id, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType
) {
  return _StartTween(type, timing, toValue, 0, fromValue, 0, refType, id, null, property, easingType, style, startDelay, timingType);
}

#endregion

#region Viewport
#ifdef SCRIPT_API_v3507
int _GetScreenViewportIndex(Viewport* viewport) {
  for (int i = 0; i < Screen.ViewportCount; i++) {
    if (viewport == Screen.Viewports[i]) {
      return i;
    }
  }
}
int _StartScreenViewportTween(Viewport* viewport, _TweenType type, float timing, int toValue, int toValue2, int fromValue, int fromValue2,
    TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  int index = _GetScreenViewportIndex(viewport);
  return _StartTween(type, timing, toValue, toValue2, fromValue, fromValue2, _eTweenReferenceViewport, index, null, null, easingType, style, startDelay, timingType);
}

int TweenX(this Viewport*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartScreenViewportTween(this, _eTweenViewportPosition, timing, toX, this.Y, this.X, this.Y, easingType, style, startDelay, timingType);
}
int TweenY(this Viewport*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartScreenViewportTween(this, _eTweenViewportPosition, timing, this.X, toY, this.X, this.Y, easingType, style, startDelay, timingType);
}
int TweenWidth(this Viewport*, float timing, int toWidth, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartScreenViewportTween(this, _eTweenViewportSize, timing, toWidth, this.Height, this.Width, this.Height, easingType, style, startDelay, timingType);
}
int TweenHeight(this Viewport*, float timing, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartScreenViewportTween(this, _eTweenViewportSize, timing, this.Width, toHeight, this.Width, this.Height, easingType, style, startDelay, timingType);
}
int TweenPosition(this Viewport*, float timing, int toX, int toY, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenX(timing, toX, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenY(timing, toY, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenWidth(timing, toWidth, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenHeight(timing, toHeight, easingType, style, startDelay, timingType);
}

function StopTweenPosition(this Viewport*, TweenStopResult result) {
  int index = _GetScreenViewportIndex(this);
 _StopTweensOfTypeWithReference(_eTweenViewportPosition, index, result);
}
function StopAllTweens(this Viewport*, TweenStopResult result) {
  int index = _GetScreenViewportIndex(this);
  _StopTweens(_eTweenReferenceViewport, index, result);
}

int _GetCameraIndex(Camera* camera) {
  for (int i = 0; i < Game.CameraCount; i++) {
    if (camera == Game.Cameras[i]) {
      return i;
    }
  }
}
int _StartCameraTween(Camera* camera, _TweenType type, float timing, int toValue, int toValue2, int fromValue, int fromValue2,
    TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  int index = _GetCameraIndex(camera);
  return _StartTween(type, timing, toValue, toValue2, fromValue, fromValue2, _eTweenReferenceCamera, index, null, null, easingType, style, startDelay, timingType);
}

int TweenX(this Camera*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toX = TweenMaths.ClampInt(toX, 0, Room.Width - this.Width);
  return _StartCameraTween(this, _eTweenCameraPosition, timing, toX, this.Y, this.X, this.Y, easingType, style, startDelay, timingType);
}
int TweenY(this Camera*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toY = TweenMaths.ClampInt(toY, 0, Room.Height - this.Height);
  return _StartCameraTween(this, _eTweenCameraPosition, timing, this.X, toY, this.X, this.Y, easingType, style, startDelay, timingType);
}
int TweenWidth(this Camera*, float timing, int toWidth, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartCameraTween(this, _eTweenCameraSize, timing, toWidth, this.Height, this.Width, this.Height, easingType, style, startDelay, timingType);
}
int TweenHeight(this Camera*, float timing, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartCameraTween(this, _eTweenCameraSize, timing, this.Width, toHeight, this.Width, this.Height, easingType, style, startDelay, timingType);
}
int TweenPosition(this Camera*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenX(timing, toX, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenY(timing, toY, easingType, style, startDelay, timingType);
}
int TweenSize(this Camera*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenWidth(timing, toWidth, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenHeight(timing, toHeight, easingType, style, startDelay, timingType);
}

function StopTweenPosition(this Camera*, TweenStopResult result) {
  int index = _GetCameraIndex(this);
 _StopTweensOfTypeWithReference(_eTweenCameraPosition, index, result);
}
function StopTweenSize(this Camera*, TweenStopResult result) {
  int index = _GetCameraIndex(this);
 _StopTweensOfTypeWithReference(_eTweenCameraSize, index, result);
}
function StopAllTweens(this Camera*, TweenStopResult result) {
  int index = _GetCameraIndex(this);
  _StopTweens(_eTweenReferenceCamera, index, result);
}
#endif
#endregion

#region Tween Extender functions

// MISC Tweens
#ifndef SCRIPT_API_v3507
int TweenViewportX(float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenViewport, timing, toX, GetViewportY(), GetViewportX(), GetViewportY(), 0, easingType, style, startDelay, timingType);
}
int TweenViewportY(float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenViewport, timing, GetViewportX(), toY, GetViewportX(), GetViewportY(), 0, easingType, style, startDelay, timingType);
}
int TweenViewport(float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenViewport, timing, toX, toY, GetViewportX(), GetViewportY(), 0, easingType, style, startDelay, timingType);
}
#endif

int TweenShakeScreen(float timing, int fromDelay, int toDelay, int fromtiming, int totiming, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenShakeScreen, timing, toDelay, totiming, fromDelay, fromtiming, 0, easingType, style, startDelay, timingType);
}
int TweenAreaScaling(float timing, int area, int fromMin, int toMin, int fromMax, int toMax, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenAreaScaling, timing, toMin, toMax, fromMin, fromMax, area, easingType, style, startDelay, timingType);
}

// AUDIO Tweens
int TweenSpeechVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenSpeechVolume, timing, toVolume, 0, fromVolume, 0, 0, easingType, style, startDelay, timingType);
}
#ifndef STRICT_AUDIO
// Pre 3.2 Strict Audio Tweens
int TweenMusicMasterVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenMusicMasterVolume, timing, toVolume, 0, fromVolume, 0, 0, easingType, style, startDelay, timingType);
}
int TweenDigitalMasterVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenDigitalMasterVolume, timing, toVolume, 0, fromVolume, 0, 0, easingType, style, startDelay, timingType);
}
int TweenSoundVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenSoundVolume, timing, toVolume, 0, fromVolume, 0, 0, easingType, style, startDelay, timingType);
}
int TweenChannelVolume(float timing, int channel, int fromVolume, int toVolume, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenChannelVolume, timing, toVolume, 0, fromVolume, 0, channel, easingType, style, startDelay, timingType);
}
int TweenChannelFadeOut(float timing, int channel, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return TweenChannelVolume(timing, channel, 100, 0, easingType, style, startDelay, timingType);
}
int TweenChannelFadeIn(float timing, int channel, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return TweenChannelVolume(timing, channel, 0, 100, easingType, style, startDelay, timingType);
}
int TweenMusicVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenMusicVolume, timing, toVolume, 0,  fromVolume, 0, 0, easingType, style, startDelay, timingType);
}
int TweenMusicFadeOut(float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return TweenMusicVolume(timing, 100, 0, easingType, style, startDelay, timingType);
}
int TweenMusicFadeIn(float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return TweenMusicVolume(timing, 0, 100, easingType, style, startDelay, timingType);
}
#endif

// X, Y, Z
int TweenX(this GUI*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUITween(_eTweenGUIPosition, timing, toX, 0, this.X, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this GUI*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUITween(_eTweenGUIPosition, timing, 0, toY, 0, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenX(this Object*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartObjectTween(_eTweenObjectPosition, timing, toX, 0, this.X, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this Object*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartObjectTween(_eTweenObjectPosition, timing, 0, toY, 0, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenX(this Character*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartCharacterTween(_eTweenCharacterPosition, timing, toX, 0, this.x, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this Character*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartCharacterTween(_eTweenCharacterPosition, timing, 0, toY, 0, this.y, this, easingType, style, startDelay, timingType);
}
int TweenZ(this Character*, float timing, int toZ, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartCharacterTween(_eTweenCharacterZ, timing, toZ, 0, this.z, 0, this, easingType, style, startDelay, timingType);
}
int TweenX(this GUIControl*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, 0, this.X, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this GUIControl*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, 0, toY, 0, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenX(this Label*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, 0, this.X, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this Label*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, 0, toY, 0, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenX(this Button*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, 0, this.X, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this Button*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, 0, toY, 0, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenX(this Slider*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, 0, this.X, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this Slider*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, 0, toY, 0, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenX(this ListBox*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, 0, this.X, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this ListBox*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, 0, toY, 0, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenX(this InvWindow*, float timing, int toX, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, 0, this.X, 0, this, easingType, style, startDelay, timingType);
}
int TweenY(this InvWindow*, float timing, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, 0, toY, 0, this.Y, this, easingType, style, startDelay, timingType);
}

// Position
int TweenPosition(this GUI*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUITween(_eTweenGUIPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this Object*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartObjectTween(_eTweenObjectPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this Character*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartCharacterTween(_eTweenCharacterPosition, timing, toX, toY, this.x, this.y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this GUIControl*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this Label*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this Button*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this TextBox*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this ListBox*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
 return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this Slider*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}
int TweenPosition(this InvWindow*, float timing, int toX, int toY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, timing, toX, toY, this.X, this.Y, this, easingType, style, startDelay, timingType);
}

// Transparency
int TweenTransparency(this GUI*, float timing, int toTransparency, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUITween(_eTweenGUITransparency, timing, toTransparency, 0, this.Transparency, 0, this, easingType, style, startDelay, timingType);
}
int TweenTransparency(this Object*, float timing, int toTransparency, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartObjectTween(_eTweenObjectTransparency, timing, toTransparency, 0, this.Transparency, 0, this, easingType, style, startDelay, timingType);
}
int TweenTransparency(this Character*, float timing, int toTransparency, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartCharacterTween(_eTweenCharacterTransparency, timing, toTransparency, 0, this.Transparency, 0, this, easingType, style, startDelay, timingType);
}

// Fade Out/Fade In

int TweenFadeOut(this GUI*, float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return this.TweenTransparency(timing, 100, easingType, style, startDelay, timingType);
}
int TweenFadeIn(this GUI*, float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return this.TweenTransparency(timing, 0, easingType, style, startDelay, timingType);
}
int TweenFadeOut(this Object*, float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return this.TweenTransparency(timing, 100, easingType, style, startDelay, timingType);
}
int TweenFadeIn(this Object*, float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return this.TweenTransparency(timing, 0, easingType, style, startDelay, timingType);
}
int TweenFadeOut(this Character*, float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return this.TweenTransparency(timing, 100, easingType, style, startDelay, timingType);
}
int TweenFadeIn(this Character*, float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return this.TweenTransparency(timing, 0, easingType, style, startDelay, timingType);
}

// Size
int TweenSize(this GUI*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUITween(_eTweenGUISize, timing, toWidth, toHeight, this.Width, this.Height, this, easingType, style, startDelay, timingType);
}
int TweenSize(this GUIControl*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlSize, timing, toWidth, toHeight, this.Width, this.Height, this, easingType, style, startDelay, timingType);
}
int TweenSize(this Label*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlSize, timing, toWidth, toHeight, this.Width, this.Height, this, easingType, style, startDelay, timingType);
}
int TweenSize(this Button*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlSize, timing, toWidth, toHeight, this.Width, this.Height, this, easingType, style, startDelay, timingType);
}
int TweenSize(this TextBox*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlSize, timing, toWidth, toHeight, this.Width, this.Height, this, easingType, style, startDelay, timingType);
}
int TweenSize(this ListBox*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlSize, timing, toWidth, toHeight, this.Width, this.Height, this, easingType, style, startDelay, timingType);
}
int TweenSize(this Slider*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlSize, timing, toWidth, toHeight, this.Width, this.Height, this, easingType, style, startDelay, timingType);
}
int TweenSize(this InvWindow*, float timing, int toWidth, int toHeight, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenGUIControlSize, timing, toWidth, toHeight, this.Width, this.Height, this, easingType, style, startDelay, timingType);
}

// GUI Specific
int TweenZOrder(this GUI*, float timing, int toZOrder, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUITween(_eTweenGUIZOrder, timing, toZOrder, 0, this.ZOrder, 0, this, easingType, style, startDelay, timingType);
}

#ifdef SCRIPT_API_v350
int TweenBackgroundColorRed(this GUI*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromRed = TweenGame.GetRFromColor(this.BackgroundColor);
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartGUITween(_eTweenGUIBackgroundColorRed, timing, toRed, 0, fromRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenBackgroundColorGreen(this GUI*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromGreen = TweenGame.GetGFromColor(this.BackgroundColor);
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartGUITween(_eTweenGUIBackgroundColorGreen, timing, toGreen, 0, fromGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenBackgroundColorBlue(this GUI*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromBlue = TweenGame.GetBFromColor(this.BackgroundColor);
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartGUITween(_eTweenGUIBackgroundColorBlue, timing, toBlue, 0, fromBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenBackgroundColorRGB(this GUI*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenBackgroundColorRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenBackgroundColorGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenBackgroundColorBlue(timing, toBlue, easingType, style, startDelay, timingType);
}
int TweenBackgroundColor(this GUI*, float timing, int toBackgroundColor, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toBackgroundColor = TweenMaths.MaxInt(0, toBackgroundColor);
  readonly int toRed = TweenGame.GetRFromColor(toBackgroundColor);
  readonly int toGreen = TweenGame.GetGFromColor(toBackgroundColor);
  readonly int toBlue = TweenGame.GetBFromColor(toBackgroundColor);
  return this.TweenBackgroundColorRGB(timing, toRed, toGreen, toBlue, easingType, style, startDelay, timingType);
}
function StopTweenBackgroundColorRed(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUIBackgroundColorRed, this.ID, result);
}
function StopTweenBackgroundColorGreen(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUIBackgroundColorGreen, this.ID, result);
}
function StopTweenBackgroundColorBlue(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUIBackgroundColorBlue, this.ID, result);
}
function StopTweenBackgroundColorRGB(this GUI*, TweenStopResult result) {
  this.StopTweenBackgroundColorRed(result);
  this.StopTweenBackgroundColorGreen(result);
  this.StopTweenBackgroundColorBlue(result);
}
function StopTweenBackgroundColor(this GUI*, TweenStopResult result) {
  this.StopTweenBackgroundColorRGB(result);
}

int TweenBorderColorRed(this GUI*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromRed = TweenGame.GetRFromColor(this.BorderColor);
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartGUITween(_eTweenGUIBorderColorRed, timing, toRed, 0, fromRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenBorderColorGreen(this GUI*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromGreen = TweenGame.GetGFromColor(this.BorderColor);
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartGUITween(_eTweenGUIBorderColorGreen, timing, toGreen, 0, fromGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenBorderColorBlue(this GUI*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromBlue = TweenGame.GetBFromColor(this.BorderColor);
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartGUITween(_eTweenGUIBorderColorBlue, timing, toBlue, 0, fromBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenBorderColorRGB(this GUI*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenBorderColorRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenBorderColorGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenBorderColorBlue(timing, toBlue, easingType, style, startDelay, timingType);
}
int TweenBorderColor(this GUI*, float timing, int toBorderColor, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toBorderColor = TweenMaths.MaxInt(0, toBorderColor);
  readonly int toRed = TweenGame.GetRFromColor(toBorderColor);
  readonly int toGreen = TweenGame.GetGFromColor(toBorderColor);
  readonly int toBlue = TweenGame.GetBFromColor(toBorderColor);
  return this.TweenBorderColorRGB(timing, toRed, toGreen, toBlue, easingType, style, startDelay, timingType);
}
function StopTweenBorderColorRed(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUIBorderColorRed, this.ID, result);
}
function StopTweenBorderColorGreen(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUIBorderColorGreen, this.ID, result);
}
function StopTweenBorderColorBlue(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUIBorderColorBlue, this.ID, result);
}
function StopTweenBorderColorRGB(this GUI*, TweenStopResult result) {
  this.StopTweenBorderColorRed(result);
  this.StopTweenBorderColorGreen(result);
  this.StopTweenBorderColorBlue(result);
}
function StopTweenBorderColor(this GUI*, TweenStopResult result) {
  this.StopTweenBorderColorRGB(result);
}
#endif

// Object Specific
int TweenImage(this Object*, Object* tmpObjectRef, float timing, int toSprite, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  tmpObjectRef.Graphic = this.Graphic;
  tmpObjectRef.SetPosition(this.X, this.Y);
  tmpObjectRef.Transparency = 0;
  tmpObjectRef.Visible = true;

  this.Transparency = 100;
  this.Graphic = toSprite;

  if (style == eBlockTween) {
    tmpObjectRef.TweenTransparency(timing, 100, easingType, eNoBlockTween, startDelay, timingType);
  }
  else {
    tmpObjectRef.TweenTransparency(timing, 100, easingType, style, startDelay, timingType);
  }

  return this.TweenTransparency(timing, 0, easingType, style, startDelay, timingType);
}

// Character Specific
int TweenAnimationSpeed(this Character*, float timing, int toAnimationSpeed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartCharacterTween(_eTweenCharacterAnimationSpeed, timing, toAnimationSpeed, 0, this.AnimationSpeed, 0, this, easingType, style, startDelay, timingType);
}
int TweenScaling(this Character*, float timing, int toScaling, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.ManualScaling = true;
  return _StartCharacterTween(_eTweenCharacterScaling, timing, toScaling, 0, this.Scaling, 0, this, easingType, style, startDelay, timingType);
}

#ifdef SCRIPT_API_v341
int TweenTintRed(this Character*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartCharacterTween(_eTweenCharacterTintRed, timing, toRed, 0, this.TintRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintGreen(this Character*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartCharacterTween(_eTweenCharacterTintGreen, timing, toGreen, 0, this.TintGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintBlue(this Character*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartCharacterTween(_eTweenCharacterTintBlue, timing, toBlue, 0, this.TintBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintSaturation(this Character*, float timing, int toSaturation, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toSaturation = TweenMaths.ClampInt(toSaturation, 0, 100);
  return _StartCharacterTween(_eTweenCharacterTintSaturation, timing, toSaturation, 0, this.TintSaturation, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintLuminance(this Character*, float timing, int toLuminance, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toLuminance = TweenMaths.ClampInt(toLuminance, 1, 100);
  return _StartCharacterTween(_eTweenCharacterTintLuminance, timing, toLuminance, 0, this.TintLuminance, 0, this, easingType, style, startDelay, timingType);
}
int TweenTint(this Character*, float timing, int toRed, int toGreen, int toBlue, int toSaturation, int toLuminance, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenTintRed(timing, toRed, easingType, style, startDelay, timingType);
  this.TweenTintGreen(timing, toGreen, easingType, style, startDelay, timingType);
  this.TweenTintBlue(timing, toBlue, easingType, style, startDelay, timingType);
  this.TweenTintSaturation(timing, toSaturation, easingType, style, startDelay, timingType);

  return this.TweenTintLuminance(timing, toLuminance, easingType, style, startDelay, timingType);
}
function StopTweenTintRed(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterTintRed, this.ID, result);
}
function StopTweenTintGreen(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterTintGreen, this.ID, result);
}
function StopTweenTintBlue(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterTintBlue, this.ID, result);
}
function StopTweenTintSaturation(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterTintSaturation, this.ID, result);
}
function StopTweenTintLuminance(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterTintLuminance, this.ID, result);
}
function StopTweenTint(this Character*, TweenStopResult result) {
  this.StopTweenTintRed(result);
  this.StopTweenTintGreen(result);
  this.StopTweenTintBlue(result);
  this.StopTweenTintSaturation(result);
  this.StopTweenTintLuminance(result);
}

int TweenTintRed(this Object*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartObjectTween(_eTweenObjectTintRed, timing, toRed, 0, this.TintRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintGreen(this Object*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartObjectTween(_eTweenObjectTintGreen, timing, toGreen, 0, this.TintGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintBlue(this Object*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartObjectTween(_eTweenObjectTintBlue, timing, toBlue, 0, this.TintBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintSaturation(this Object*, float timing, int toSaturation, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toSaturation = TweenMaths.ClampInt(toSaturation, 0, 100);
  return _StartObjectTween(_eTweenObjectTintSaturation, timing, toSaturation, 0, this.TintSaturation, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintLuminance(this Object*, float timing, int toLuminance, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toLuminance = TweenMaths.ClampInt(toLuminance, 0, 100);
  return _StartObjectTween(_eTweenObjectTintLuminance, timing, toLuminance, 0, this.TintLuminance, 0, this, easingType, style, startDelay, timingType);
}
int TweenTint(this Object*, float timing, int toRed, int toGreen, int toBlue, int toSaturation, int toLuminance, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenTintRed(timing, toRed, easingType, style, startDelay, timingType);
  this.TweenTintGreen(timing, toGreen, easingType, style, startDelay, timingType);
  this.TweenTintBlue(timing, toBlue, easingType, style, startDelay, timingType);
  this.TweenTintSaturation(timing, toSaturation, easingType, style, startDelay, timingType);

  return this.TweenTintLuminance(timing, toLuminance, easingType, style, startDelay, timingType);
}
function StopTweenTintRed(this Object*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenObjectTintRed, this.ID, result);
}
function StopTweenTintGreen(this Object*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenObjectTintGreen, this.ID, result);
}
function StopTweenTintBlue(this Object*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenObjectTintBlue, this.ID, result);
}
function StopTweenTintSaturation(this Object*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenObjectTintSaturation, this.ID, result);
}
function StopTweenTintLuminance(this Object*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenObjectTintLuminance, this.ID, result);
}
function StopTweenTint(this Object*, TweenStopResult result) {
  this.StopTweenTintRed(result);
  this.StopTweenTintGreen(result);
  this.StopTweenTintBlue(result);
  this.StopTweenTintSaturation(result);
  this.StopTweenTintLuminance(result);
}
#endif

// Region Specific
int TweenLightLevel(this Region*, float timing, int toLightLevel, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toLightLevel = TweenMaths.ClampInt(toLightLevel, -100, 100);
  return _StartRegionTween(_eTweenRegionLightLevel, timing, toLightLevel, 0, this.LightLevel, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintRed(this Region*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartRegionTween(_eTweenRegionTintRed, timing, toRed, 0, this.TintRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintGreen(this Region*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartRegionTween(_eTweenRegionTintGreen, timing, toGreen, 0, this.TintGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintBlue(this Region*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartRegionTween(_eTweenRegionTintBlue, timing, toBlue, 0, this.TintBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintSaturation(this Region*, float timing, int toSaturation, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toSaturation = TweenMaths.ClampInt(toSaturation, 1, 100);
  return _StartRegionTween(_eTweenRegionTintSaturation, timing, toSaturation, 0, this.TintSaturation, 0, this, easingType, style, startDelay, timingType);
}
int TweenTintLuminance(this Region*, float timing, int toLuminance, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toLuminance = TweenMaths.ClampInt(toLuminance, 0, 100);
  return _StartRegionTween(_eTweenRegionTintLuminance, timing, toLuminance, 0, this.TintLuminance, 0, this, easingType, style, startDelay, timingType);
}
int TweenTint(this Region*, float timing, int toRed, int toGreen, int toBlue, int toSaturation, int toLuminance, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenTintRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenTintGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenTintBlue(timing, toBlue, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenTintSaturation(timing, toSaturation, easingType, style, startDelay, timingType);

  return this.TweenTintLuminance(timing, toLuminance, easingType, style, startDelay, timingType);
}

// Label Specific
int TweenTextColorRed(this Label*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromRed = TweenGame.GetRFromColor(this.TextColor);
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartGUIControlTween(_eTweenLabelTextColorRed, timing, toRed, 0, fromRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorGreen(this Label*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromGreen = TweenGame.GetGFromColor(this.TextColor);
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartGUIControlTween(_eTweenLabelTextColorGreen, timing, toGreen, 0, fromGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorBlue(this Label*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromBlue = TweenGame.GetBFromColor(this.TextColor);
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartGUIControlTween(_eTweenLabelTextColorBlue, timing, toBlue, 0, fromBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorRGB(this Label*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenTextColorRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenTextColorGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenTextColorBlue(timing, toBlue, easingType, style, startDelay, timingType);
}
int TweenTextColor(this Label*, float timing, int toColor, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toColor = TweenMaths.MaxInt(0, toColor);
  readonly int toRed = TweenGame.GetRFromColor(toColor);
  readonly int toGreen = TweenGame.GetGFromColor(toColor);
  readonly int toBlue = TweenGame.GetBFromColor(toColor);
  return this.TweenTextColorRGB(timing, toRed, toGreen, toBlue, easingType, style, startDelay, timingType);
}

// Button Specific
int TweenTextColorRed(this Button*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromRed = TweenGame.GetRFromColor(this.TextColor);
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartGUIControlTween(_eTweenButtonTextColorRed, timing, toRed, 0, fromRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorGreen(this Button*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromGreen = TweenGame.GetGFromColor(this.TextColor);
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartGUIControlTween(_eTweenButtonTextColorGreen, timing, toGreen, 0, fromGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorBlue(this Button*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromBlue = TweenGame.GetBFromColor(this.TextColor);
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartGUIControlTween(_eTweenButtonTextColorBlue, timing, toBlue, 0, fromBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorRGB(this Button*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenTextColorRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenTextColorGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenTextColorBlue(timing, toBlue, easingType, style, startDelay, timingType);
}
int TweenTextColor(this Button*, float timing, int toColor, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toColor = TweenMaths.MaxInt(0, toColor);
  readonly int toRed = TweenGame.GetRFromColor(toColor);
  readonly int toGreen = TweenGame.GetGFromColor(toColor);
  readonly int toBlue = TweenGame.GetBFromColor(toColor);
  return this.TweenTextColorRGB(timing, toRed, toGreen, toBlue, easingType, style, startDelay, timingType);
}

// ListBox Specific
int TweenSelectedIndex(this ListBox*, float timing, int toSelectedIndex, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenListBoxSelectedIndex, timing, toSelectedIndex, 0, this.SelectedIndex, 0, this, easingType, style, startDelay, timingType);
}
int TweenTopItem(this ListBox*, float timing, int toTopItem, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenListBoxTopItem, timing, toTopItem, 0, this.TopItem, 0, this, easingType, style, startDelay, timingType);
}
#ifdef SCRIPT_API_v350
int TweenSelectedBackColorRed(this ListBox*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromRed = TweenGame.GetRFromColor(this.SelectedBackColor);
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxSelectedBackColorRed, timing, toRed, 0, fromRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenSelectedBackColorGreen(this ListBox*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromGreen = TweenGame.GetGFromColor(this.SelectedBackColor);
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxSelectedBackColorGreen, timing, toGreen, 0, fromGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenSelectedBackColorBlue(this ListBox*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromBlue = TweenGame.GetBFromColor(this.SelectedBackColor);
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxSelectedBackColorBlue, timing, toBlue, 0, fromBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenSelectedBackColorRGB(this ListBox*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenSelectedBackColorRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenSelectedBackColorGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenSelectedBackColorBlue(timing, toBlue, easingType, style, startDelay, timingType);
}
int TweenSelectedBackColor(this ListBox*, float timing, int toSelectedBackColor, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toSelectedBackColor = TweenMaths.MaxInt(0, toSelectedBackColor);
  readonly int toRed = TweenGame.GetRFromColor(toSelectedBackColor);
  readonly int toGreen = TweenGame.GetGFromColor(toSelectedBackColor);
  readonly int toBlue = TweenGame.GetBFromColor(toSelectedBackColor);
  return this.TweenSelectedBackColorRGB(timing, toRed, toGreen, toBlue, easingType, style, startDelay, timingType);
}
function StopTweenSelectedBackColorRed(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxSelectedBackColorRed, this.ID, result);
}
function StopTweenSelectedBackColorGreen(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxSelectedBackColorGreen, this.ID, result);
}
function StopTweenSelectedBackColorBlue(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxSelectedBackColorBlue, this.ID, result);
}
function StopTweenSelectedBackColorRGB(this ListBox*, TweenStopResult result) {
  this.StopTweenSelectedBackColorRed(result);
  this.StopTweenSelectedBackColorGreen(result);
  this.StopTweenSelectedBackColorBlue(result);
}
function StopTweenSelectedBackColor(this ListBox*, TweenStopResult result) {
  this.StopTweenSelectedBackColorRGB(result);
}

int TweenSelectedTextColorRed(this ListBox*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromRed = TweenGame.GetRFromColor(this.SelectedTextColor);
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxSelectedTextColorRed, timing, toRed, 0, fromRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenSelectedTextColorGreen(this ListBox*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromGreen = TweenGame.GetGFromColor(this.SelectedTextColor);
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxSelectedTextColorGreen, timing, toGreen, 0, fromGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenSelectedTextColorBlue(this ListBox*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromBlue = TweenGame.GetBFromColor(this.SelectedTextColor);
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxSelectedTextColorBlue, timing, toBlue, 0, fromBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenSelectedTextColorRGB(this ListBox*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenSelectedTextColorRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenSelectedTextColorGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenSelectedTextColorBlue(timing, toBlue, easingType, style, startDelay, timingType);
}
int TweenSelectedTextColor(this ListBox*, float timing, int toSelectedTextColor, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toSelectedTextColor = TweenMaths.MaxInt(0, toSelectedTextColor);
  readonly int toRed = TweenGame.GetRFromColor(toSelectedTextColor);
  readonly int toGreen = TweenGame.GetGFromColor(toSelectedTextColor);
  readonly int toBlue = TweenGame.GetBFromColor(toSelectedTextColor);
  return this.TweenSelectedTextColorRGB(timing, toRed, toGreen, toBlue, easingType, style, startDelay, timingType);
}
function StopTweenSelectedTextColorRed(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxSelectedTextColorRed, this.ID, result);
}
function StopTweenSelectedTextColorGreen(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxSelectedTextColorGreen, this.ID, result);
}
function StopTweenSelectedTextColorBlue(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxSelectedTextColorBlue, this.ID, result);
}
function StopTweenSelectedTextColorRGB(this ListBox*, TweenStopResult result) {
  this.StopTweenSelectedTextColorRed(result);
  this.StopTweenSelectedTextColorGreen(result);
  this.StopTweenSelectedTextColorBlue(result);
}
function StopTweenSelectedTextColor(this ListBox*, TweenStopResult result) {
  this.StopTweenSelectedTextColorRGB(result);
}

int TweenTextColorRed(this ListBox*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromRed = TweenGame.GetRFromColor(this.TextColor);
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxTextColorRed, timing, toRed, 0, fromRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorGreen(this ListBox*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromGreen = TweenGame.GetGFromColor(this.TextColor);
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxTextColorGreen, timing, toGreen, 0, fromGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorBlue(this ListBox*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromBlue = TweenGame.GetBFromColor(this.TextColor);
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartGUIControlTween(_eTweenListBoxTextColorBlue, timing, toBlue, 0, fromBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorRGB(this ListBox*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenTextColorRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenTextColorGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenTextColorBlue(timing, toBlue, easingType, style, startDelay, timingType);
}
int TweenTextColor(this ListBox*, float timing, int toTextColor, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toTextColor = TweenMaths.MaxInt(0, toTextColor);
  readonly int toRed = TweenGame.GetRFromColor(toTextColor);
  readonly int toGreen = TweenGame.GetGFromColor(toTextColor);
  readonly int toBlue = TweenGame.GetBFromColor(toTextColor);
  return this.TweenTextColorRGB(timing, toRed, toGreen, toBlue, easingType, style, startDelay, timingType);
}
function StopTweenTextColorRed(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxTextColorRed, this.ID, result);
}
function StopTweenTextColorGreen(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxTextColorGreen, this.ID, result);
}
function StopTweenTextColorBlue(this ListBox*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenListBoxTextColorBlue, this.ID, result);
}
function StopTweenTextColorRGB(this ListBox*, TweenStopResult result) {
  this.StopTweenTextColorRed(result);
  this.StopTweenTextColorGreen(result);
  this.StopTweenTextColorBlue(result);
}
function StopTweenTextColor(this ListBox*, TweenStopResult result) {
  this.StopTweenTextColorRGB(result);
}
#endif

// InvWindow Specific
int TweenTopItem(this InvWindow*, float timing, int toTopItem, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenInvWindowTopItem, timing, toTopItem, 0, this.TopItem, 0, this, easingType, style, startDelay, timingType);
}

// Slider Specific
int TweenValue(this Slider*, float timing, int toValue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
 return _StartGUIControlTween(_eTweenSliderValue, timing, toValue, 0, this.Value, 0, this, easingType, style, startDelay, timingType);
}

// Stop
function StopAllTweens(this GUI*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceGUI, this.ID, result);
}
function StopAllTweens(this Object*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceObject, this.ID, result);
}
function StopAllTweens(this Character*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceCharacter, this.ID, result);
}
function StopAllTweens(this Region*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceRegion, this.ID, result);
}
function StopAllTweens(this GUIControl*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceGUIControl, this.ID, result);
}
function StopAllTweens(this Label*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceGUIControl, this.ID, result);
}
function StopAllTweens(this Button*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceGUIControl, this.ID, result);
}
function StopAllTweens(this TextBox*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceGUIControl, this.ID, result);
}
function StopAllTweens(this ListBox*, TweenStopResult result) {
  _StopTweensForGUIControl(this, result);
}
function StopAllTweens(this Slider*, TweenStopResult result) {
  _StopTweensForGUIControl(this, result);
}
function StopAllTweens(this InvWindow*, TweenStopResult result) {
  _StopTweensForGUIControl(this, result);
}
#ifndef SCRIPT_API_v3507
function StopTweenViewport(TweenStopResult result) {
  _StopTweensOfType(_eTweenViewport, result);
}
#endif
function StopTweenShakeScreen(TweenStopResult result) {
  _StopTweensOfType(_eTweenShakeScreen, result);
}
function StopTweenAreaScaling(int area, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenAreaScaling, area, result);
}
function StopTweenSpeechVolume(TweenStopResult result) {
  _StopTweensOfType(_eTweenSpeechVolume, result);
}
#ifndef STRICT_AUDIO
function StopTweenMusicMasterVolume(TweenStopResult result) {
  _StopTweensOfType(_eTweenMusicMasterVolume, result);
}
function StopTweenDigitalMasterVolume(TweenStopResult result) {
  _StopTweensOfType(_eTweenDigitalMasterVolume, result);
}
function StopTweenSoundVolume(TweenStopResult result) {
  _StopTweensOfType(_eTweenSoundVolume, result);
}
function StopTweenChannelVolume(int channel, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenChannelVolume, channel, result);
}
function StopTweenMusicVolume(TweenStopResult result) {
  _StopTweensOfType(_eTweenMusicVolume, result);
}
#endif
function StopTweenPosition(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterPosition, this.ID, result);
}
function StopTweenPosition(this Object*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenObjectPosition, this.ID, result);
}
function StopTweenPosition(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUIPosition, this.ID, result);
}
function StopTweenPosition(this GUIControl*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlPosition, result);
}
function StopTweenPosition(this Label*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlPosition, result);
}
function StopTweenPosition(this Button*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlPosition, result);
}
function StopTweenPosition(this TextBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlPosition, result);
}
function StopTweenPosition(this ListBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlPosition, result);
}
function StopTweenPosition(this Slider*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlPosition, result);
}
function StopTweenPosition(this InvWindow*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlPosition, result);
}
function StopTweenTransparency(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterTransparency, this.ID, result);
}
function StopTweenTransparency(this Object*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenObjectTransparency, this.ID, result);
}
function StopTweenTransparency(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUITransparency, this.ID, result);
}
function StopTweenZ(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterZ, this.ID, result);
}
function StopTweenZOrder(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUIZOrder, this.ID, result);
}
function StopTweenSize(this GUI*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenGUISize, this.ID, result);
}
function StopTweenSize(this GUIControl*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlSize, result);
}
function StopTweenSize(this Label*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlSize, result);
}
function StopTweenSize(this Button*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlSize, result);
}
function StopTweenSize(this TextBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlSize, result);
}
function StopTweenSize(this ListBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlSize, result);
}
function StopTweenSize(this Slider*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlSize, result);
}
function StopTweenSize(this InvWindow*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenGUIControlSize, result);
}
function StopTweenScaling(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterScaling, this.ID, result);
}
function StopTweenAnimationSpeed(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterAnimationSpeed, this.ID, result);
}
function StopTweenLightLevel(this Region*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenRegionLightLevel, this.ID, result);
}
function StopTweenTintRed(this Region*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenRegionTintRed, this.ID, result);
}
function StopTweenTintGreen(this Region*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenRegionTintGreen, this.ID, result);
}
function StopTweenTintBlue(this Region*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenRegionTintBlue, this.ID, result);
}
function StopTweenTintSaturation(this Region*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenRegionTintSaturation, this.ID, result);
}
function StopTweenTintLuminance(this Region*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenRegionTintLuminance, this.ID, result);
}
function StopTweenTint(this Region*, TweenStopResult result) {
  this.StopTweenTintRed(result);
  this.StopTweenTintGreen(result);
  this.StopTweenTintBlue(result);
  this.StopTweenTintSaturation(result);
  this.StopTweenTintLuminance(result);
}
function StopTweenTextColorRed(this Label*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenLabelTextColorRed, result);
}
function StopTweenTextColorGreen(this Label*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenLabelTextColorGreen, result);
}
function StopTweenTextColorBlue(this Label*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenLabelTextColorBlue, result);
}
function StopTweenTextColorRGB(this Label*, TweenStopResult result) {
  this.StopTweenTextColorRed(result);
  this.StopTweenTextColorGreen(result);
  this.StopTweenTextColorBlue(result);
}
function StopTweenTextColor(this Label*, TweenStopResult result) {
  this.StopTweenTextColorRGB(result);
}
function StopTweenTextColorRed(this Button*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenButtonTextColorRed, result);
}
function StopTweenTextColorGreen(this Button*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenButtonTextColorGreen, result);
}
function StopTweenTextColorBlue(this Button*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenButtonTextColorBlue, result);
}
function StopTweenTextColorRGB(this Button*, TweenStopResult result) {
  this.StopTweenTextColorRed(result);
  this.StopTweenTextColorGreen(result);
  this.StopTweenTextColorBlue(result);
}
function StopTweenTextColor(this Button*, TweenStopResult result) {
  this.StopTweenTextColorRGB(result);
}
function StopTweenValue(this Slider*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenSliderValue, result);
}
function StopTweenSelectedIndex(this ListBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenListBoxSelectedIndex, result);
}
function StopTweenTopItem(this ListBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenListBoxTopItem, result);
}
function StopTweenTopItem(this InvWindow*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenInvWindowTopItem, result);
}

// TextBox Specific
function StopTweenTextColorRed(this TextBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenTextBoxTextColorRed, result);
}
function StopTweenTextColorGreen(this TextBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenTextBoxTextColorGreen, result);
}
function StopTweenTextColorBlue(this TextBox*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenTextBoxTextColorBlue, result);
}
function StopTweenTextColorRGB(this TextBox*, TweenStopResult result) {
  this.StopTweenTextColorRed(result);
  this.StopTweenTextColorGreen(result);
  this.StopTweenTextColorBlue(result);
}
function StopTweenTextColor(this TextBox*, TweenStopResult result) {
  this.StopTweenTextColorRGB(result);
}
function StopTweenHandleOffset(this Slider*, TweenStopResult result) {
  _StopTweensForGUIControlOfType(this, _eTweenSliderHandleOffset, result);
}

int TweenTextColorRed(this TextBox*, float timing, int toRed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromRed = TweenGame.GetRFromColor(this.TextColor);
  toRed = TweenMaths.ClampInt(toRed, 0, 255);
  return _StartGUIControlTween(_eTweenTextBoxTextColorRed, timing, toRed, 0, fromRed, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorGreen(this TextBox*, float timing, int toGreen, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromGreen = TweenGame.GetGFromColor(this.TextColor);
  toGreen = TweenMaths.ClampInt(toGreen, 0, 255);
  return _StartGUIControlTween(_eTweenTextBoxTextColorGreen, timing, toGreen, 0, fromGreen, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorBlue(this TextBox*, float timing, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  readonly int fromBlue = TweenGame.GetBFromColor(this.TextColor);
  toBlue = TweenMaths.ClampInt(toBlue, 0, 255);
  return _StartGUIControlTween(_eTweenTextBoxTextColorBlue, timing, toBlue, 0, fromBlue, 0, this, easingType, style, startDelay, timingType);
}
int TweenTextColorRGB(this TextBox*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  this.TweenTextColorRed(timing, toRed, easingType, eNoBlockTween, startDelay, timingType);
  this.TweenTextColorGreen(timing, toGreen, easingType, eNoBlockTween, startDelay, timingType);
  return this.TweenTextColorBlue(timing, toBlue, easingType, style, startDelay, timingType);
}
int TweenTextColor(this TextBox*, float timing, int toColor, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  toColor = TweenMaths.MaxInt(0, toColor);
  readonly int toRed = TweenGame.GetRFromColor(toColor);
  readonly int toGreen = TweenGame.GetGFromColor(toColor);
  readonly int toBlue = TweenGame.GetBFromColor(toColor);
  return this.TweenTextColorRGB(timing, toRed, toGreen, toBlue, easingType, style, startDelay, timingType);
}

int TweenHandleOffset(this Slider*, float timing, int toHandleOffset, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartGUIControlTween(_eTweenSliderHandleOffset, timing, toHandleOffset, 0, this.HandleOffset, 0, this, easingType, style, startDelay, timingType);
}

#ifdef STRICT_AUDIO
// Strict Audio Specific
function StopTweenPosition(this AudioChannel*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenAudioChannelPosition, this.ID, result);
}
function StopTweenPanning(this AudioChannel*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenAudioChannelPanning, this.ID, result);
}
function StopTweenVolume(this AudioChannel*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenSystemVolume, this.ID, result);
}
function StopTweenRoomLocation(this AudioChannel*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenAudioChannelRoomLocation, this.ID, result);
}

int _StartAudioTween(_TweenType type, AudioChannel* audioChannelRef, float timing, int toX, int toY, int fromX, int fromY,
    TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartTween(type, timing, toX, toY, fromX, fromY, _eTweenReferenceAudioChannel, audioChannelRef.ID, null, null, easingType, style, startDelay, timingType);
}
int TweenPosition(this AudioChannel*,  float timing, int toPosition, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartAudioTween(_eTweenAudioChannelPosition, this, timing, TweenMaths.ClampInt(toPosition, 0, this.LengthMs), 0, this.PositionMs, 0, easingType, style, startDelay, timingType);
}
int TweenPanning(this AudioChannel*,  float timing, int toPanning, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartAudioTween(_eTweenAudioChannelPanning, this, timing, TweenMaths.ClampInt(toPanning, -100,  100), 0, this.Panning, 0, easingType, style, startDelay, timingType);
}
int TweenVolume(this AudioChannel*,  float timing, int toVolume, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartAudioTween(_eTweenAudioChannelVolume, this, timing, TweenMaths.ClampInt(toVolume, 0, 100), 0, this.Volume, 0, easingType, style, startDelay, timingType);
}
int TweenFadeOut(this AudioChannel*, float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return this.TweenVolume(timing, 0, easingType, style, startDelay, timingType);
}
int TweenFadeIn(this AudioChannel*, float timing, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return this.TweenVolume(timing, 100, easingType, style, startDelay, timingType);
}
int TweenRoomLocation(this AudioChannel*,  float timing, int toX, int toY, int fromX, int fromY, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartAudioTween(_eTweenAudioChannelRoomLocation, this, timing, toX, toY, fromX, fromY, easingType, style, startDelay, timingType);
}
function StopAllTweens(this AudioChannel*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceAudioChannel, this.ID, result);
}
#endif

#ifdef STRICT_AUDIO
// 3.4+ Strict Audio Specific
function StopTweenSpeed(this AudioChannel*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenAudioChannelSpeed, this.ID, result);
}
int TweenSpeed(this AudioChannel*, float timing, int toSpeed, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  _StartAudioTween(_eTweenAudioChannelSpeed, this, timing, TweenMaths.MaxInt(toSpeed, 0), 0, this.Speed, 0, easingType, style, startDelay, timingType);
}

int TweenVolume(static System, float timing, int toVolume, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenSystemVolume, timing, TweenMaths.ClampInt(toVolume, 0, 100), 0, System.Volume, 0, 0, easingType, style, startDelay, timingType);
}
function StopTweenVolume(static System, TweenStopResult result) {
  _StopTweensOfType(_eTweenSystemVolume, result);
}
#endif

int TweenAmbientLightLevel(float timing, int fromLightLevel, int toLightLevel, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  fromLightLevel = TweenMaths.ClampInt(fromLightLevel, -100, 100);
  toLightLevel = TweenMaths.ClampInt(toLightLevel, -100, 100);
  return _StartMiscTween(_eTweenAmbientLightLevel, timing, toLightLevel, 0, fromLightLevel, 0, 0, easingType, style, startDelay, timingType);
}
function StopTweenAmbientLightLevel(TweenStopResult result) {
  _StopTweensOfType(_eTweenAmbientLightLevel, result);
}

int TweenGamma(static System, float timing, int toGamma, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  return _StartMiscTween(_eTweenSystemGamma, timing, toGamma, 0, System.Gamma, 0, 0, easingType, style, startDelay, timingType);
}
function StopTweenGamma(static System, TweenStopResult result) {
  _StopTweensOfType(_eTweenSystemGamma, result);
}

int TweenLightLevel(this Character*, float timing, int fromLightLevel, int toLightLevel, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  fromLightLevel = TweenMaths.ClampInt(fromLightLevel, -100, 100);
  toLightLevel = TweenMaths.ClampInt(toLightLevel, -100, 100);
  return _StartCharacterTween(_eTweenCharacterLightLevel, timing, toLightLevel, 0, fromLightLevel, 0, this, easingType, style, startDelay, timingType);
}
int TweenLightLevel(this Object*, float timing, int fromLightLevel, int toLightLevel, TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType) {
  fromLightLevel = TweenMaths.ClampInt(fromLightLevel, -100, 100);
  toLightLevel = TweenMaths.ClampInt(toLightLevel, -100, 100);
  return _StartObjectTween(_eTweenObjectLightLevel, timing, toLightLevel, 0, fromLightLevel, 0, this, easingType, style, startDelay, timingType);
}
function StopTweenLightLevel(this Character*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenCharacterLightLevel, this.ID, result);
}
function StopTweenLightLevel(this Object*, TweenStopResult result) {
  _StopTweensOfTypeWithReference(_eTweenObjectLightLevel, this.ID, result);
}

int TweenProperty(this Character*, float timing, String property, int toValue,
  TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType
) {
  return _StartPropertyTween(
    _eTweenCharacterProperty, timing, property, toValue, this.GetProperty(property),
    _eTweenReferenceCharacter, this.ID, easingType, style, startDelay, timingType
  );
}
function StopTweenProperty(this Character*, String property, TweenStopResult result) {
  _StopTweensOfTypeWithStringReference(_eTweenCharacterProperty, this.ID, property, result);
}

int TweenProperty(this Hotspot*, float timing, String property, int toValue,
  TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType
) {
  return _StartPropertyTween(
    _eTweenHotspotProperty, timing, property, toValue, this.GetProperty(property),
    _eTweenReferenceMisc, this.ID, easingType, style, startDelay, timingType
  );
}
function StopTweenProperty(this Hotspot*, String property, TweenStopResult result) {
  _StopTweensOfTypeWithStringReference(_eTweenHotspotProperty, this.ID, property, result);
}

int TweenProperty(this InventoryItem*, float timing, String property, int toValue,
  TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType
) {
  return _StartPropertyTween(
    _eTweenInventoryItemProperty, timing, property, toValue, this.GetProperty(property),
    _eTweenReferenceInventoryItem, this.ID, easingType, style, startDelay, timingType
  );
}
function StopTweenProperty(this InventoryItem*, String property, TweenStopResult result) {
  _StopTweensOfTypeWithStringReference(_eTweenReferenceInventoryItem, this.ID, property, result);
}

int TweenProperty(this Object*, float timing, String property, int toValue,
  TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType
) {
  return _StartPropertyTween(
    _eTweenObjectProperty, timing, property, toValue, this.GetProperty(property),
    _eTweenReferenceObject, this.ID, easingType, style, startDelay, timingType
  );
}
function StopTweenProperty(this Object*, String property, TweenStopResult result) {
  _StopTweensOfTypeWithStringReference(_eTweenObjectProperty, this.ID, property, result);
}

int TweenProperty(static Room, float timing, String property, int toValue,
  TweenEasingType easingType, TweenStyle style, float startDelay, TweenTimingType timingType
) {
  return _StartPropertyTween(
    _eTweenRoomProperty, timing, property, toValue, Room.GetProperty(property),
    _eTweenReferenceMisc, player.Room, easingType, style, startDelay, timingType
  );
}
function StopTweenProperty(static Room, String property, TweenStopResult result) {
  _StopTweensOfTypeWithStringReference(_eTweenRoomProperty, player.Room, property, result);
}

#endregion
 ,�  // ags-tween is open source under the MIT License.
// Uses Robert Penner's easing equestions which are under the BSD License.
//
// TERMS OF USE - AGS TWEEN MODULE (ags-tween)
//
// Copyright (c) 2009-present Edmundo Ruiz Ghanem
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef __TWEEN_MODULE__
#define __TWEEN_MODULE__
#define Tween_020202

///////////////////////////////////////////////////////////////////////////////
// SETTINGS - Feel free to change this for your game!
///////////////////////////////////////////////////////////////////////////////

// Max number of simultaneous tweens that this module can play
// Feel free to change this number, but the higher it is, the slower it might be
// So just increase or decrease it to however many you need.
#define Tween_MAX_INSTANCES 64

// If true, it stops all tweens upon leaving the room
// If false, it stops most tweens except Audio, GUI, and some screen-related tweens.
#define Tween_STOP_ALL_ON_LEAVE_ROOM false

// Default TweenEasingType
#define Tween_EASING_TYPE eEaseLinearTween // All Tweens Except GUI and GUI element Tweens
#define Tween_EASING_TYPE_GUI eEaseLinearTween // For GUI and GUI element Tweens Only
#define Tween_EASING_TYPE_AUDIO eEaseLinearTween // For Audio Tweens Only

// Default TweenStyle
#define Tween_STYLE eBlockTween // All Tweens Except GUI and GUI element Tweens
#define Tween_STYLE_GUI eBlockTween // For GUI and GUI element Tweens Only
#define Tween_STYLE_AUDIO eNoBlockTween // For Audio Tweens only
#define Tween_STYLE_PROPERTY eNoBlockTween // For Property Tweening only

// Default TweenStopResult
#define Tween_STOP_RESULT ePauseTween // The expected behavior for stopping all tweens

// Default startDelay
#define Tween_START_DELAY 0
#define Tween_START_DELAY_GUI 0
#define Tween_START_DELAY_AUDIO 0

// Default TweenTimingType
#define Tween_TIMING eTweenSeconds
#define Tween_TIMING_GUI eTweenSeconds
#define Tween_TIMING_AUDIO eTweenSeconds

///////////////////////////////////////////////////////////////////////////////
// ENUMERATIONS
///////////////////////////////////////////////////////////////////////////////

enum TweenEasingType {
  eEaseLinearTween,
  eEaseInSineTween,
  eEaseOutSineTween,
  eEaseInOutSineTween,
  eEaseInQuadTween,
  eEaseOutQuadTween,
  eEaseInOutQuadTween,
  eEaseInCubicTween,
  eEaseOutCubicTween,
  eEaseInOutCubicTween,
  eEaseInQuartTween,
  eEaseOutQuartTween,
  eEaseInOutQuartTween,
  eEaseInQuintTween,
  eEaseOutQuintTween,
  eEaseInOutQuintTween,
  eEaseInCircTween,
  eEaseOutCircTween,
  eEaseInOutCircTween,
  eEaseInExpoTween,
  eEaseOutExpoTween,
  eEaseInOutExpoTween,
  eEaseInBackTween,
  eEaseOutBackTween,
  eEaseInOutBackTween,
  eEaseInElasticTween,
  eEaseOutElasticTween,
  eEaseInOutElasticTween,
  eEaseInBounceTween,
  eEaseOutBounceTween,
  eEaseInOutBounceTween
};

enum TweenStyle {
  eBlockTween = eBlock,
  eNoBlockTween = eNoBlock,
  eRepeatTween = eRepeat,
  eReverseRepeatTween = 7002
};

enum TweenTimingType {
  eTweenSeconds,
  eTweenSpeed,
};

enum TweenStopResult {
  ePauseTween,
  eResetTween,
  eFinishTween
};

///////////////////////////////////////////////////////////////////////////////
// TWEENS
///////////////////////////////////////////////////////////////////////////////

struct TweenBase {
  writeprotected TweenEasingType EasingType;
  writeprotected TweenStyle Style;
  writeprotected float Duration;
  writeprotected float Elapsed;
  writeprotected float FromValue;
  writeprotected float ToValue;
  writeprotected float StartDelay;

  /// Reverses the direction of the tween.
  import function Reverse();

  /// Restarts the tween.
  import function Restart();

  /// Returns true if the tween is playing.
  import bool IsPlaying();

  /// Initializes a tween.
  import int Init(float timing, int fromValue, int toValue, TweenEasingType easingType=eEaseLinearTween, TweenStyle style=eNoBlockTween, float startDelay=0, TweenTimingType timingType=eTweenSeconds);
};

struct Tween extends TweenBase {
  /// Tweened Value (read only)
  writeprotected int Value;

  /// Moves the tween forward in time.
  import bool Update();

  /// Stops the tween.
  import function Stop(TweenStopResult result=ePauseTween);

  /// Returns the progress from 0.0 to 1.0.
  import float GetProgress();

  // STATIC FUNCTIONS:

  /// Increases the game speed to at least 60 for better tweening quality.
  import static function IncreaseGameSpeed();

  /// Restores the game speed back to its original.
  import static function RestoreGameSpeed();

  /// Increases the game speed when a blocking tween is playing.
  import static function IncreaseGameSpeedOnBlock(bool value);

  /// Stops all Tweens that are currently running.
  import static function StopAll(TweenStopResult result=Tween_STOP_RESULT);

  /// Waits until all non-looping Tweens are finished playing.
  import static function WaitForAllToFinish();
};

#ifdef SCRIPT_API_v3507
import int TweenX(this Viewport*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenY(this Viewport*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenWidth(this Viewport*, float timing, int toWidth, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenHeight(this Viewport*, float timing, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenPosition(this Viewport*, float timing, int toX, int toY, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenPosition(this Viewport*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this Viewport*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenX(this Camera*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenY(this Camera*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenWidth(this Camera*, float timing, int toWidth, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenHeight(this Camera*, float timing, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenPosition(this Camera*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenSize(this Camera*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenPosition(this Camera*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSize(this Camera*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this Camera*, TweenStopResult result=Tween_STOP_RESULT);
#endif
#ifndef SCRIPT_API_v3507
import int TweenViewportX(float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenViewportY(float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenViewport(float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenViewport(TweenStopResult result=Tween_STOP_RESULT);
#endif

import int TweenShakeScreen(float timing, int fromDelay, int toDelay, int fromAmount, int toAmount, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenShakeScreen(TweenStopResult result=Tween_STOP_RESULT);

import int TweenAreaScaling(float timing, int area, int fromMin, int toMin, int fromMax, int toMax, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenAreaScaling(int area, TweenStopResult result=Tween_STOP_RESULT);

import int TweenSpeechVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import function StopTweenSpeechVolume(TweenStopResult result=Tween_STOP_RESULT);
#ifndef STRICT_AUDIO
// These apply to AGS 3.2 and above only if the Strict Audio setting is NOT enabled
import int TweenMusicMasterVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenDigitalMasterVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenSoundVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenChannelVolume(float timing, int channel, int fromVolume, int toVolume, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenChannelFadeOut(float timing, int channel, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenChannelFadeIn(float timing, int channel, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenMusicVolume(float timing, int fromVolume, int toVolume, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenMusicFadeOut(float timing, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenMusicFadeIn(float timing, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import function StopTweenMusicMasterVolume(TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenDigitalMasterVolume(TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSoundVolume(TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenChannelVolume(int channel, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenMusicVolume(TweenStopResult result=Tween_STOP_RESULT);
#endif

#ifdef STRICT_AUDIO
import int TweenSpeed(this AudioChannel*, float timing, int toSpeed, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import function StopTweenSpeed(this AudioChannel*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenVolume(static System, float timing, int toVolume, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import function StopTweenVolume(static System, TweenStopResult result=Tween_STOP_RESULT);

import int TweenPosition(this AudioChannel*, float timing, int toPosition, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenPanning(this AudioChannel*, float timing, int toPanning, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenVolume(this AudioChannel*, float timing, int toVolume, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenFadeOut(this AudioChannel*, float timing, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenFadeIn(this AudioChannel*, float timing, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import int TweenRoomLocation(this AudioChannel*, float timing, int toX, int toY, int fromX, int fromY, TweenEasingType easingType=Tween_EASING_TYPE_AUDIO, TweenStyle style=Tween_STYLE_AUDIO, float startDelay=Tween_START_DELAY_AUDIO, TweenTimingType timingType=Tween_TIMING_AUDIO);
import function StopTweenPosition(this AudioChannel*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPanning(this AudioChannel*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenVolume(this AudioChannel*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenRoomLocation(this AudioChannel*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this AudioChannel*, TweenStopResult result=Tween_STOP_RESULT);
#endif

import int TweenX(this Character*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenY(this Character*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenX(this Object*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenY(this Object*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenX(this GUI*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenY(this GUI*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenX(this GUIControl*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenY(this GUIControl*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenX(this Label*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenY(this Label*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenX(this Button*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenY(this Button*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenX(this TextBox*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenY(this TextBox*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenX(this ListBox*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenY(this ListBox*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenX(this Slider*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenY(this Slider*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenX(this InvWindow*, float timing, int toX, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenY(this InvWindow*, float timing, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenPosition(this Character*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenPosition(this Object*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenPosition(this GUI*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenPosition(this GUIControl*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenPosition(this Label*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenPosition(this Button*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenPosition(this TextBox*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenPosition(this ListBox*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenPosition(this Slider*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenPosition(this InvWindow*, float timing, int toX, int toY, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenPosition(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this Object*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this GUIControl*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this Label*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this Button*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this TextBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this Slider*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenPosition(this InvWindow*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenZ(this Character*, float timing, int toZ, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenZ(this Character*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenTransparency(this GUI*, float timing, int toTransparency, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTransparency(this Object*, float timing, int toTransparency, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTransparency(this Character*, float timing, int toTransparency, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenFadeOut(this GUI*, float timing, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenFadeIn(this GUI*, float timing, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenFadeOut(this Object*, float timing, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenFadeIn(this Object*, float timing, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenFadeOut(this Character*, float timing, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenFadeIn(this Character*, float timing, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenTransparency(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTransparency(this Object*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTransparency(this GUI*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenZOrder(this GUI*, float timing, int toZOrder, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenZOrder(this GUI*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenSize(this GUI*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSize(this GUIControl*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSize(this Label*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSize(this Button*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSize(this TextBox*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSize(this ListBox*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSize(this Slider*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSize(this InvWindow*, float timing, int toWidth, int toHeight, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenSize(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSize(this GUIControl*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSize(this Label*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSize(this Button*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSize(this TextBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSize(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSize(this Slider*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSize(this InvWindow*, TweenStopResult result=Tween_STOP_RESULT);
#ifdef SCRIPT_API_v350
import int TweenBackgroundColorRed(this GUI*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenBackgroundColorGreen(this GUI*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenBackgroundColorBlue(this GUI*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenBackgroundColorRGB(this GUI*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenBackgroundColor(this GUI*, float timing, int toBackgroundColor, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenBackgroundColorRed(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenBackgroundColorGreen(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenBackgroundColorBlue(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenBackgroundColorRGB(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenBackgroundColor(this GUI*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenBorderColorRed(this GUI*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenBorderColorGreen(this GUI*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenBorderColorBlue(this GUI*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenBorderColorRGB(this GUI*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenBorderColor(this GUI*, float timing, int toBorderColor, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenBorderColorRed(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenBorderColorGreen(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenBorderColorBlue(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenBorderColorRGB(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenBorderColor(this GUI*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenSelectedBackColorRed(this ListBox*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSelectedBackColorGreen(this ListBox*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSelectedBackColorBlue(this ListBox*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSelectedBackColorRGB(this ListBox*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSelectedBackColor(this ListBox*, float timing, int toSelectedBackColor, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenSelectedBackColorRed(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSelectedBackColorGreen(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSelectedBackColorBlue(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSelectedBackColorRGB(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSelectedBackColor(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenSelectedTextColorRed(this ListBox*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSelectedTextColorGreen(this ListBox*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSelectedTextColorBlue(this ListBox*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSelectedTextColorRGB(this ListBox*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenSelectedTextColor(this ListBox*, float timing, int toSelectedTextColor, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenSelectedTextColorRed(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSelectedTextColorGreen(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSelectedTextColorBlue(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSelectedTextColorRGB(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenSelectedTextColor(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenTextColorRed(this ListBox*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorGreen(this ListBox*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorBlue(this ListBox*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorRGB(this ListBox*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColor(this ListBox*, float timing, int toTextColor, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenTextColorRed(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorGreen(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorBlue(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorRGB(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColor(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
#endif

import int TweenScaling(this Character*, float timing, int toScaling, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenScaling(this Character*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenImage(this Object*, Object* objectRef, float timing, int toSprite, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);

import int TweenAnimationSpeed(this Character*, float timing, int toAnimationSpeed, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenAnimationSpeed(this Character*, TweenStopResult result=Tween_STOP_RESULT);

#ifdef SCRIPT_API_v341
import int TweenTintRed(this Character*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintGreen(this Character*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintBlue(this Character*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintSaturation(this Character*, float timing, int toSaturation, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintLuminance(this Character*, float timing, int toLuminance, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTint(this Character*, float timing, int toRed, int toGreen, int toBlue, int toSaturation, int toLuminance, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenTintRed(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintGreen(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintBlue(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintSaturation(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintLuminance(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTint(this Character*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenTintRed(this Object*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintGreen(this Object*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintBlue(this Object*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintSaturation(this Object*, float timing, int toSaturation, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintLuminance(this Object*, float timing, int toLuminance, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTint(this Object*, float timing, int toRed, int toGreen, int toBlue, int toSaturation, int toLuminance, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenTintRed(this Object*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintGreen(this Object*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintBlue(this Object*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintSaturation(this Object*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintLuminance(this Object*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTint(this Object*, TweenStopResult result=Tween_STOP_RESULT);
#endif

import int TweenLightLevel(this Region*, float timing, int toLightLevel, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintRed(this Region*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintGreen(this Region*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintBlue(this Region*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintSaturation(this Region*, float timing, int toSaturation, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTintLuminance(this Region*, float timing, int toLuminance, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenTint(this Region*, float timing, int toRed, int toGreen, int toBlue, int toSaturation, int toLuminance, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenLightLevel(this Region*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintRed(this Region*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintGreen(this Region*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintBlue(this Region*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintSaturation(this Region*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTintLuminance(this Region*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTint(this Region*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenTextColor(this Label*, float timing, int toColor, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorRGB(this Label*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorRed(this Label*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorGreen(this Label*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorBlue(this Label*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColor(this Button*, float timing, int toColor, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorRGB(this Button*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorRed(this Button*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorGreen(this Button*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorBlue(this Button*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenTextColor(this Label*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorRGB(this Label*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorRed(this Label*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorGreen(this Label*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorBlue(this Label*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColor(this Button*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorRGB(this Button*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorRed(this Button*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorGreen(this Button*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorBlue(this Button*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenValue(this Slider*, float timing, int toValue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenValue(this Slider*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenSelectedIndex(this ListBox*, float timing, int toSelectedIndex, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenSelectedIndex(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenTopItem(this ListBox*, float timing, int toTopItem, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTopItem(this InvWindow*, float timing, int toTopItem, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenTopItem(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTopItem(this InvWindow*, TweenStopResult result=Tween_STOP_RESULT);

import function StopAllTweens(this GUI*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this Object*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this Region*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this GUIControl*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this Label*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this Button*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this TextBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this ListBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this Slider*, TweenStopResult result=Tween_STOP_RESULT);
import function StopAllTweens(this InvWindow*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenTextColor(this TextBox*, float timing, int toColor, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorRGB(this TextBox*, float timing, int toRed, int toGreen, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorRed(this TextBox*, float timing, int toRed, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorGreen(this TextBox*, float timing, int toGreen, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import int TweenTextColorBlue(this TextBox*, float timing, int toBlue, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenTextColor(this TextBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorRGB(this TextBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorRed(this TextBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorGreen(this TextBox*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenTextColorBlue(this TextBox*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenHandleOffset(this Slider*, float timing, int toOffset, TweenEasingType easingType=Tween_EASING_TYPE_GUI, TweenStyle style=Tween_STYLE_GUI, float startDelay=Tween_START_DELAY_GUI, TweenTimingType timingType=Tween_TIMING_GUI);
import function StopTweenHandleOffset(this Slider*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenLightLevel(this Character*, float timing, int fromLightLevel, int toLightLevel, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenLightLevel(this Object*, float timing, int fromLightLevel, int toLightLevel, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenLightLevel(this Character*, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenLightLevel(this Object*, TweenStopResult result=Tween_STOP_RESULT);

import int TweenAmbientLightLevel(float timing, int fromLightLevel, int toLightLevel, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenAmbientLightLevel(TweenStopResult result=Tween_STOP_RESULT);

import int TweenGamma(static System, float timing, int toGamma, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenGamma(static System, TweenStopResult result=Tween_STOP_RESULT);

import int TweenProperty(this Character*, float timing, String property, int toValue, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE_PROPERTY, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenProperty(this Hotspot*, float timing, String property, int toValue, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE_PROPERTY, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenProperty(this InventoryItem*, float timing, String property, int toValue, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE_PROPERTY, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenProperty(this Object*, float timing, String property, int toValue, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE_PROPERTY, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import int TweenProperty(static Room, float timing, String property, int toValue, TweenEasingType easingType=Tween_EASING_TYPE, TweenStyle style=Tween_STYLE_PROPERTY, float startDelay=Tween_START_DELAY, TweenTimingType timingType=Tween_TIMING);
import function StopTweenProperty(this Character*, String property, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenProperty(this Hotspot*, String property, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenProperty(this InventoryItem*, String property, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenProperty(this Object*, String property, TweenStopResult result=Tween_STOP_RESULT);
import function StopTweenProperty(static Room, String property, TweenStopResult result=Tween_STOP_RESULT);


///////////////////////////////////////////////////////////////////////////////
// ADVANCED USERS: HANDY-DANDY UTILITY FUNCTIONS
///////////////////////////////////////////////////////////////////////////////

struct TweenGame {
  /// Returns the red value from a colour number.
  import static int GetRFromColor(int color);

  /// Returns the green value from a colour number.
  import static int GetGFromColor(int color);

  /// Returns the blue value from a colour number.
  import static int GetBFromColor(int color);
};

struct TweenMaths {
  /// Returns the absolute value.
  import static float Abs(float value);

  /// Returns the distance (as a float) between two points.
  import static float GetDistance(int fromX, int fromY, int toX, int toY);

  /// Interpolates from one float to another based on a decimal factor. Returns int.
  import static int Lerp(float from, float to, float t);

  /// Returns the smallest int value.
  import static int MinInt(int a, int b);

  /// Returns the largest int value.
  import static int MaxInt(int a, int b);

  /// Returns an int between a min and max values.
  import static int ClampInt(int value, int min, int max);

  /// Returns the largest float value.
  import static float MaxFloat(float a, float b);

  /// Returns the largest float value.
  import static float MinFloat(float a, float b);

  /// Returns a float between a min and max values.
  import static float ClampFloat(float value, float min, float max);
};

/// Converts number of seconds to number of game loops. (Part of the Tween module)
import int SecondsToLoops(float seconds);

/// Converts number of loops to number seconds. (Part of the Tween module)
import float LoopsToSeconds(int loops);

/// Waits a number of seconds. (Part of the Tween module)
import function WaitSeconds(float amount);

/// Waits for the longest duration (based on game loops). Supports up to 6 durations. (Part of the Tween module)
import function WaitForLongest(int duration1, int duration2, int duration3=0, int duration4=0, int duration5=0, int duration6=0);

/// Sets a Timer using seconds instead of game loops.  (Part of the Tween module)
import function SetTimerWithSeconds(int timerID, float amount);

/// Sets the timer for the longest timeout (based on game loops). Supports up to 6 timeouts. (Part of the Tween module)
import function SetTimerForLongest(int timerID, int timeout1, int timeout2, int timeout3=0, int timeout4=0, int timeout5=0, int timeout6=0);

///////////////////////////////////////////////////////////////////////////////
// ADVANCED USERS: TWEEN EASING EQUATIONS
///////////////////////////////////////////////////////////////////////////////

// TERMS OF USE - EASING EQUATIONS
//
// Open source under the BSD License.
//
// Copyright (c) 2001 Robert Penner
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  * Neither the name of the author nor the names of contributors may be used to
//    endorse or promote products derived from this software without
//    specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

struct TweenEasing {
  import static float EaseLinear(float t, float d);
  import static float EaseInSine(float t, float b, float c, float d);
  import static float EaseOutSine(float t, float b, float c, float d);
  import static float EaseInOutSine(float t, float b, float c, float d);
  import static float EaseInQuad(float t, float b, float c, float d);
  import static float EaseOutQuad(float t, float b, float c, float d);
  import static float EaseInOutQuad(float t, float b, float c, float d);
  import static float EaseInPower(float t, float b, float c, float d, float power);
  import static float EaseOutPower(float t, float b, float c, float d, float power);
  import static float EaseInOutPower(float t, float b, float c, float d, float power);
  import static float EaseInExpo(float t, float b, float c, float d);
  import static float EaseOutExpo(float t, float b, float c, float d);
  import static float EaseInOutExpo(float t, float b, float c, float d);
  import static float EaseInCirc(float t, float b, float c, float d);
  import static float EaseOutCirc(float t, float b, float c, float d);
  import static float EaseInOutCirc(float t, float b, float c, float d);
  import static float EaseInBack(float t, float b, float c, float d);
  import static float EaseOutBack(float t, float b, float c, float d);
  import static float EaseInOutBack(float t, float b, float c, float d);
  import static float EaseInElastic(float t, float b, float c, float d);
  import static float EaseOutElastic(float t, float b, float c, float d);
  import static float EaseInOutElastic(float t, float b, float c, float d);
  import static float EaseInBounce(float t, float b, float c, float d);
  import static float EaseOutBounce(float t, float b, float c, float d);
  import static float EaseInOutBounce(float t, float b, float c, float d);

  /// Returns the value at elapsed over duration based on the TweenEasingType
  import static float GetValue(float elapsed, float duration, TweenEasingType easingType);
};

// END BSD LICENSE

#endif
 C�}J        ej��