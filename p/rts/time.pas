{ Time and date routines

  Copyright (C) 1991-2006 Free Software Foundation, Inc.

  Authors: Frank Heckenbach <frank@pascal.gnu.de>
           Jukka Virtanen <jtv@hut.fi>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. }

{$gnu-pascal,I-}

unit Time; attribute (name = '_p__rts_Time');

interface

uses RTSC, Error, String1;

const
  InvalidYear = -MaxInt;

{@internal}
type
  DateTimeString = String (11);  { MUST match predef.c }

  GPC_TimeStamp = packed record
    DateValid,
    TimeValid  : Boolean;
    Year       : Integer;
    Month      : 1 .. 12;
    Day        : 1 .. 31;
    DayOfWeek  : 0 .. 6;   { 0 means Sunday }
    Hour       : 0 .. 23;
    Minute     : 0 .. 59;
    Second     : 0 .. 61;  { to allow for leap seconds }
    MicroSecond: 0 .. 999999;
    TimeZone   : Integer;  { in seconds east of UTC }
    DST        : Boolean;
    TZName1,
    TZName2    : String (32);
  end;

procedure GPC_GetTimeStamp   (var aTimeStamp: TimeStamp);                 attribute (name = '_p_GetTimeStamp');
function  GPC_Date (protected var aTimeStamp: TimeStamp) = Result: DateTimeString; attribute (name = '_p_Date');
function  GPC_Time (protected var aTimeStamp: TimeStamp) = Result: DateTimeString; attribute (name = '_p_Time');

{@endinternal}
var
  { DayOfWeekName is a constant and therefore does not respect the
    locale. Therefore, it's recommended to use FormatTime instead. }
  DayOfWeekName: array [0 .. 6] of String [9] =
    ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'); attribute (const, name = '_p_DayOfWeekName');

  { MonthName is a constant and therefore does not respect the
    locale. Therefore, it's recommended to use FormatTime instead. }
  MonthName: array [1 .. 12] of String [9] =
    ('January', 'February', 'March', 'April', 'May', 'June',
     'July', 'August', 'September', 'October', 'November', 'December'); attribute (const, name = '_p_MonthName');

function  GetDayOfWeek (Day, Month, Year: Integer): Integer;                                            attribute (name = '_p_GetDayOfWeek');
function  GetDayOfYear (Day, Month, Year: Integer): Integer;                                            attribute (name = '_p_GetDayOfYear');
function  GetSundayWeekOfYear (Day, Month, Year: Integer): Integer;                                     attribute (name = '_p_GetSundayWeekOfYear');
function  GetMondayWeekOfYear (Day, Month, Year: Integer): Integer;                                     attribute (name = '_p_GetMondayWeekOfYear');
procedure GetISOWeekOfYear (Day, Month, Year: Integer; var ISOWeek, ISOWeekYear: Integer);              attribute (name = '_p_GetISOWeekOfYear');
procedure UnixTimeToTimeStamp (UnixTime: UnixTimeType; var aTimeStamp: TimeStamp);                      attribute (name = '_p_UnixTimeToTimeStamp');
function  TimeStampToUnixTime (protected var aTimeStamp: TimeStamp): UnixTimeType;                      attribute (name = '_p_TimeStampToUnixTime');
function  GetMicroSecondTime: MicroSecondTimeType;                                                      attribute (name = '_p_GetMicroSecondTime');

{ Is the year a leap year? }
function  IsLeapYear (Year: Integer): Boolean;                                                          attribute (name = '_p_IsLeapYear');

{ Returns the length of the month, taking leap years into account. }
function  MonthLength (Month, Year: Integer): Integer;                                                  attribute (name = '_p_MonthLength');

{ Formats a TimeStamp value according to a Format string. The format
  string can contain date/time items consisting of `%', followed by
  the specifiers listed below. All characters outside of these items
  are copied to the result unmodified. The specifiers correspond to
  those of the C function strftime(), including POSIX.2 and glibc
  extensions and some more extensions. The extensions are also
  available on systems whose strftime() doesn't support them.

  The following modifiers may appear after the `%':

  `_'  The item is left padded with spaces to the given or default
       width.

  `-'  The item is not padded at all.

  `0'  The item is left padded with zeros to the given or default
       width.

  `/'  The item is right trimmed if it is longer than the given
       width.

  `^'  The item is converted to upper case.

  `~'  The item is converted to lower case.

  After zero or more of these flags, an optional width may be
  specified for padding and trimming. It must be given as a decimal
  number (not starting with `0' since `0' has a meaning of its own,
  see above).

  Afterwards, the following optional modifiers may follow. Their
  meaning is locale-dependent, and many systems and locales just
  ignore them.

  `E'  Use the locale's alternate representation for date and time.
       In a Japanese locale, for example, `%Ex' might yield a date
       format based on the Japanese Emperors' reigns.

  `O'  Use the locale's alternate numeric symbols for numbers. This
       modifier applies only to numeric format specifiers.

  Finally, exactly one of the following specifiers must appear. The
  padding rules listed here are the defaults that can be overriden
  with the modifiers listed above.

  `a'  The abbreviated weekday name according to the current locale.

  `A'  The full weekday name according to the current locale.

  `b'  The abbreviated month name according to the current locale.

  `B'  The full month name according to the current locale.

  `c'  The preferred date and time representation for the current
       locale.

  `C'  The century of the year. This is equivalent to the greatest
       integer not greater than the year divided by 100.

  `d'  The day of the month as a decimal number (`01' .. `31').

  `D'  The date using the format `%m/%d/%y'. NOTE: Don't use this
       format if it can be avoided. Things like this caused Y2K
       bugs!

  `e'  The day of the month like with `%d', but padded with blanks
       (` 1' .. `31').

  `F'  The date using the format `%Y-%m-%d'. This is the form
       specified in the ISO 8601 standard and is the preferred form
       for all uses.

  `g'  The year corresponding to the ISO week number, but without
       the century (`00' .. `99'). This has the same format and
       value as `y', except that if the ISO week number (see `V')
       belongs to the previous or next year, that year is used
       instead. NOTE: Don't use this format if it can be avoided.
       Things like this caused Y2K bugs!

  `G'  The year corresponding to the ISO week number. This has the
       same format and value as `Y', except that if the ISO week
       number (see `V') belongs to the previous or next year, that
       year is used instead.

  `h'  The abbreviated month name according to the current locale.
       This is the same as `b'.

  `H'  The hour as a decimal number, using a 24-hour clock
       (`00' .. `23').

  `I'  The hour as a decimal number, using a 12-hour clock
       (`01' .. `12').

  `j'  The day of the year as a decimal number (`001' .. `366').

  `k'  The hour as a decimal number, using a 24-hour clock like `H',
       but padded with blanks (` 0' .. `23').

  `l'  The hour as a decimal number, using a 12-hour clock like `I',
       but padded with blanks (` 1' .. `12').

  `m'  The month as a decimal number (`01' .. `12').

  `M'  The minute as a decimal number (`00' .. `59').

  `n'  A single newline character.

  `p'  Either `AM' or `PM', according to the given time value; or
       the corresponding strings for the current locale. Noon is
       treated as `PM' and midnight as `AM'.

  `P'  Either `am' or `pm', according to the given time value; or
       the corresponding strings for the current locale, printed in
       lowercase characters. Noon is treated as `pm' and midnight as
       `am'.

  `Q'  The fractional part of the second. This format has special
       effects on the modifiers. The width, if given, determines the
       number of digits to output. Therefore, no actual clipping or
       trimming is done. However, if padding with spaces is
       specified, any trailing (i.e., right!) zeros are converted to
       spaces, and if "no padding" is specified, they are removed.
       The default is "padding with zeros", i.e. trailing zeros are
       left unchanged. The digits are cut when necessary without
       rounding (otherwise, the value would not be consistent with
       the seconds given by `S' and `s'). Note that GPC's TimeStamp
       currently provides for microsecond resolution, so there are
       at most 6 valid digits (which is also the default width), any
       further digits will be 0 (but if TimeStamp will ever change,
       this format will be adjusted). However, the actual resolution
       provided by the operating system via GetTimeStamp etc. may be
       far lower (e.g., ~1/18s under Dos).

  `r'  The complete time using the AM/PM format of the current
       locale.

  `R'  The hour and minute in decimal numbers using the format
       `%H:%M'.

  `s'  Unix time, i.e. the number of seconds since the epoch, i.e.,
       since 1970-01-01 00:00:00 UTC. Leap seconds are not counted
       unless leap second support is available.

  `S'  The seconds as a decimal number (`00' .. `60').

  `t'  A single tab character.

  `T'  The time using decimal numbers using the format `%H:%M:%S'.

  `u'  The day of the week as a decimal number (`1' .. `7'), Monday
       being `1'.

  `U'  The week number of the current year as a decimal number
       (`00' .. `53'), starting with the first Sunday as the first
       day of the first week. Days preceding the first Sunday in the
       year are considered to be in week `00'.

  `V'  The ISO 8601:1988 week number as a decimal number
       (`01' .. `53'). ISO weeks start with Monday and end with
       Sunday. Week `01' of a year is the first week which has the
       majority of its days in that year; this is equivalent to the
       week containing the year's first Thursday, and it is also
       equivalent to the week containing January 4. Week `01' of a
       year can contain days from the previous year. The week before
       week `01' of a year is the last week (`52' or `53') of the
       previous year even if it contains days from the new year.

  `w'  The day of the week as a decimal number (`0' .. `6'), Sunday
       being `0'.

  `W'  The week number of the current year as a decimal number
       (`00' .. `53'), starting with the first Monday as the first
       day of the first week. All days preceding the first Monday in
       the year are considered to be in week `00'.

  `x'  The preferred date representation for the current locale, but
       without the time.

  `X'  The preferred time representation for the current locale, but
       with no date.

  `y'  The year without a century as a decimal number
       (`00' .. `99'). This is equivalent to the year modulo 100.
       NOTE: Don't use this format if it can be avoided. Things like
       this caused Y2K bugs!

  `Y'  The year as a decimal number, using the Gregorian calendar.
       Years before the year `1' are numbered `0', `-1', and so on.

  `z'  RFC 822/ISO 8601:1988 style numeric time zone (e.g., `-0600'
       or `+0100'), or nothing if no time zone is determinable.

  `Z'  The time zone abbreviation (empty if the time zone can't be
       determined).

  `%'  (i.e., an item `%%') A literal `%' character. }
function  FormatTime (const Time: TimeStamp; const Format: String) = Res: TString; attribute (name = '_p_FormatTime');

implementation

function GetDayOfWeek (Day, Month, Year: Integer): Integer;
const MonthWeekOffset: array [1 .. 12] of Integer = (0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4);
begin
  if Month <= 2 then Dec (Year);
  GetDayOfWeek := (Day + MonthWeekOffset[Month] + Year + Year div 4 - Year div 100 + Year div 400) mod 7
end;

function GetDayOfYear (Day, Month, Year: Integer): Integer;
const MonthOffset: array [1 .. 12] of Integer = (0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);
begin
  GetDayOfYear := MonthOffset[Month] + Ord ((Month >= 3) and IsLeapYear (Year)) + Day
end;

function GetSundayWeekOfYear (Day, Month, Year: Integer): Integer;
var DOY: Integer;
begin
  DOY := GetDayOfYear (Day, Month, Year);
  GetSundayWeekOfYear := (DOY - 1) div 7 + Ord ((DOY - 1) mod 7 >= GetDayOfWeek (Day, Month, Year))
end;

function GetMondayWeekOfYear (Day, Month, Year: Integer): Integer;
var DOY: Integer;
begin
  DOY := GetDayOfYear (Day, Month, Year);
  GetMondayWeekOfYear := (DOY - 1) div 7 + Ord ((DOY - 1) mod 7 >= (GetDayOfWeek (Day, Month, Year) + 6) mod 7)
end;

procedure GetISOWeekOfYear (Day, Month, Year: Integer; var ISOWeek, ISOWeekYear: Integer);
var
  DOW, DOY,YearLength, TmpDOY, TmpISOWeek: Integer;
  WF: Boolean;
begin
  DOW := GetDayOfWeek (Day, Month, Year);
  DOY := GetDayOfYear (Day, Month, Year);
  YearLength := 365 + Ord (IsLeapYear (Year));
  WF := (DOY + 2) mod 7 >= (DOW + 6) mod 7;
  TmpISOWeek := (DOY + 2) div 7 + Ord (WF);
  if TmpISOWeek = 0 then
    begin
      TmpDOY := DOY + 365 + Ord (IsLeapYear (Year - 1));
      ISOWeek := (TmpDOY + 2) div 7 + Ord ((TmpDOY + 2) mod 7 >= (DOW + 6) mod 7)
    end
  else if DOY + 2 - YearLength >= (DOW + 6) mod 7 then
    ISOWeek := 1
  else
    ISOWeek := TmpISOWeek;
  ISOWeekYear :=Year + Ord (ISOWeek < TmpISOWeek) - Ord (ISOWeek > TmpISOWeek)
end;

function IsLeapYear (Year: Integer): Boolean;
begin
  IsLeapYear := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0))
end;

function MonthLength (Month, Year: Integer): Integer;
const MonthLengths: array [1 .. 12] of Integer =
        (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  if (Month < 1) or (Month > 12) then
    MonthLength := 0
  else
    MonthLength := MonthLengths[Month] + Ord ((Month = 2) and IsLeapYear (Year))
end;

function GPC_Date (protected var aTimeStamp: TimeStamp) = Result: DateTimeString;
begin
  with aTimeStamp do
    if not DateValid
       or (Month < Low (Month)) or (Month > High (Month))
       or (Day < Low (Day)) or (Day > MonthLength (Month, Year)) then
      begin
        SetReturnAddress (ReturnAddress (0));
        RuntimeError (750);  { Invalid date supplied to library function `Date' }
        RestoreReturnAddress;
        Result := ''
      end
    else
      WriteStr (Result, Day : 2, ' ', Copy (MonthName[Month], 1, 3), ' ', Year : 4)
end;

function GPC_Time (protected var aTimeStamp: TimeStamp) = Result: DateTimeString;
const Zero: array [Boolean] of String (1) = ('', '0');
begin
  with aTimeStamp do
    if not TimeValid
       or (Hour < Low (Hour)) or (Hour > High (Hour))
       or (Minute < Low (Minute)) or (Minute > High (Minute))
       or (Second < Low (Second)) or (Second > High (Second)) then
      begin
        SetReturnAddress (ReturnAddress (0));
        RuntimeError (751);  { Invalid time supplied to library function `Time' }
        RestoreReturnAddress;
        Result := ''
      end
    else
      WriteStr (Result, Zero[Hour   < 10], Hour,   ':',
                        Zero[Minute < 10], Minute, ':',
                        Zero[Second < 10], Second)
end;

procedure UnixTimeToTimeStamp (UnixTime: UnixTimeType; var aTimeStamp: TimeStamp);
var
  aYear, aMonth, aDay, aHour, aMinute, aSecond, aTimeZone: CInteger;
  aDST: Boolean;
  aTZName1, aTZName2: CString;
begin
  with aTimeStamp do
    if UnixTime >= 0 then
      begin
        UnixTimeToTime (UnixTime, aYear, aMonth, aDay, aHour, aMinute, aSecond, aTimeZone, aDST, aTZName1, aTZName2);
        Year        := aYear;
        Month       := aMonth;
        Day         := aDay;
        DayOfWeek   := GetDayOfWeek (aDay, aMonth, aYear);
        DateValid   := True;
        Hour        := aHour;
        Minute      := aMinute;
        Second      := aSecond;
        MicroSecond := 0;
        TimeValid   := True;
        TimeZone    := aTimeZone;
        DST         := aDST;
        TZName1     := CString2String (aTZName1);
        TZName2     := CString2String (aTZName2)
      end
    else
      begin
        { The values are specified in the standard, even if the Valid fields are False }
        Year        := 1;
        Month       := 1;
        Day         := 1;
        DayOfWeek   := 0;
        DateValid   := False;
        Hour        := 0;
        Minute      := 0;
        Second      := 0;
        MicroSecond := 0;
        TimeValid   := False;
        TimeZone    := 0;
        DST         := False;
        TZName1     := '';
        TZName2     := ''
      end
end;

function TimeStampToUnixTime (protected var aTimeStamp: TimeStamp): UnixTimeType;
begin
  with aTimeStamp do
    if not DateValid or not TimeValid then
      TimeStampToUnixTime := -1
    else
      TimeStampToUnixTime := TimeToUnixTime (Year, Month, Day, Hour, Minute, Second)
end;

procedure GPC_GetTimeStamp (var aTimeStamp: TimeStamp);
var MicroSecond: CInteger;
begin
  UnixTimeToTimeStamp (GetUnixTime (MicroSecond), aTimeStamp);
  aTimeStamp.MicroSecond := MicroSecond
end;

function GetMicroSecondTime: MicroSecondTimeType;
var
  MicroSecond: CInteger;
  UnixTime: UnixTimeType;
begin
  UnixTime := GetUnixTime (MicroSecond);
  GetMicroSecondTime := 1000000 * UnixTime + MicroSecond
end;

function FormatTime (const Time: TimeStamp; const Format: String) = Res: TString;
const
  FillNone = #0;
  FillDefault = #1;
  WidthDefault = -MaxInt;
var
  DOW, DOY, ISOWeek, ISOWeekYear: Integer;
  InvalidFormat: Boolean;
  s: TString;
  UnixTime: UnixTimeType;
  TmpTime: TimeStamp;
  StrFTimeInvalid: set of 'A' .. 'z' = []; attribute (static);

  function FormatItem (Item: Char; const Alternative: String; Width: Integer; Fill: Char; Clip: Boolean) = Res: TString;
  var
    CurrentWidth, Tmp: Integer;
    CurrentFill: Char;
    Buffer: TStringBuf;
    Done: Boolean;

    procedure ZeroFill (Number: Integer); attribute (inline);
    begin
      WriteStr (Res, Number);
      CurrentFill := '0'
    end;

    procedure NoFill (const s: String); attribute (inline);
    begin
      Res := s;
      CurrentWidth := 0
    end;

  begin
    Res := '';
    Done := False;
    CurrentWidth := 2;
    CurrentFill := ' ';
    if Item = 'h' then Item := 'b';
    { Locale dependent. Try to use strftime(). But not all implementations
      of strftime support all formats, so check if the format is available. }
    if ((Alternative <> '') and (Time.Year <> InvalidYear)) or
       ((Item in ['a', 'A', 'b', 'B', 'c', 'p', 'P', 'r', 'x', 'X', 'z', 'Z'])
        and not (Item in StrFTimeInvalid)
        and ((Time.Year <> InvalidYear) or not (Item in ['a', 'A', 'c', 'x']))) then
      begin
        Tmp := CFormatTime (UnixTime, '%' + Alternative + Item, Buffer, SizeOf (Buffer));
        if (Tmp > 0) and ((Alternative = '') or not IsSuffix (Buffer[0 .. Tmp - 1], Alternative + Item)) then
          begin
            if Tmp > 0 then Res := Buffer[0 .. Tmp - 1];
            Done := True
          end
        else if Alternative = '' then
          Include (StrFTimeInvalid, Item)
      end;
    if not Done then
      with Time do
        { No locale information necessary or available (use sane defaults). }
        {$define DefaultFormatItem(Item) FormatItem (Item, '', WidthDefault, FillDefault, False)}
        case Item of
          'a': if Year <> InvalidYear then NoFill (Copy (DayOfWeekName[DOW], 1, 3));
          'A': if Year <> InvalidYear then NoFill (DayOfWeekName[DOW]);
          'b': NoFill (Copy (MonthName[Month], 1, 3));
          'B': NoFill (MonthName[Month]);
          'c': NoFill (DefaultFormatItem ('x') + ' ' + DefaultFormatItem ('X'));
          'C': if Year <> InvalidYear then ZeroFill (Year div 100);
          'd': ZeroFill (Day);
          'D': if Year = InvalidYear then
                 NoFill (DefaultFormatItem ('m') + '/' + DefaultFormatItem ('d'))
               else
                 NoFill (DefaultFormatItem ('m') + '/' + DefaultFormatItem ('d') + '/' + DefaultFormatItem ('y'));
          'e': WriteStr (Res, Day);
          'F': if Year = InvalidYear then
                 NoFill (DefaultFormatItem ('m') + '-' + DefaultFormatItem ('d'))
               else
                 NoFill (DefaultFormatItem ('Y') + '-' + DefaultFormatItem ('m') + '-' + DefaultFormatItem ('d'));
          'g': if Year <> InvalidYear then ZeroFill (ISOWeekYear mod 100);
          'G': if Year <> InvalidYear then
                 begin
                   WriteStr (Res, ISOWeekYear);
                   CurrentWidth := 4
                 end;
          'H': ZeroFill (Hour);
          'I': ZeroFill (Hour + 12 * Ord (Hour = 0) - 12 * Ord (Hour > 12));
          'j': if Year <> InvalidYear then
                 begin
                   ZeroFill (DOY);
                   CurrentWidth := 3
                 end;
          'k': WriteStr (Res, Hour);
          'l': WriteStr (Res, Hour + 12 * Ord (Hour = 0) - 12 * Ord (Hour > 12));
          'm': ZeroFill (Month);
          'M': ZeroFill (Minute);
          'n': NoFill (NewLine);
          'p': if Hour <= 11 then NoFill ('AM') else NoFill ('PM');
          'P': if Hour <= 11 then NoFill ('am') else NoFill ('pm');
          'Q': begin
                 WriteStr (Res, MicroSecond : 6);
                 for Tmp := 1 to Length (Res) do
                   if Res[Tmp] = ' ' then Res[Tmp] := '0';
                 if Width <> WidthDefault then
                   if Width < 6 then
                     Delete (Res, Width + 1)
                   else if Width > 6 then
                     Insert (StringOfChar ('0', Width - Length (Res)), Res, Length (Res) + 1);
                 case Fill of
                   '0', FillDefault: ;
                   FillNone: begin
                               Tmp := Length (Res);
                               while (Tmp > 0) and (Res[Tmp] = '0') do Dec (Tmp);
                               Delete (Res, Tmp + 1)
                             end;
                   else      begin
                               Tmp := Length (Res);
                               while (Tmp > 0) and (Res[Tmp] = '0') do
                                 begin
                                   Res[Tmp] := Fill;
                                   Dec (Tmp)
                                 end
                             end;
                 end;
                 Exit  { don't do normal filling/clipping }
               end;
          'r': NoFill (DefaultFormatItem ('I') + ':' + DefaultFormatItem ('M') + ':' + DefaultFormatItem ('S') + ' ' + DefaultFormatItem ('p'));
          'R': NoFill (DefaultFormatItem ('H') + ':' + DefaultFormatItem ('M'));
          's': if Year <> InvalidYear then WriteStr (Res, UnixTime);
          'S': ZeroFill (Second);
          't': NoFill ("\t");
          'T': NoFill (DefaultFormatItem ('H') + ':' + DefaultFormatItem ('M') + ':' + DefaultFormatItem ('S'));
          'u': if Year <> InvalidYear then
                 begin
                   WriteStr (Res, DOW + 7 * Ord (DOW = 0));
                   CurrentWidth := 1
                 end;
          'U': if Year <> InvalidYear then ZeroFill (GetSundayWeekOfYear (Day, Month, Year));
          'V': if Year <> InvalidYear then ZeroFill (ISOWeek);
          'w': if Year <> InvalidYear then
                 begin
                   WriteStr (Res, DOW);
                   CurrentWidth := 1
                 end;
          'W': if Year <> InvalidYear then ZeroFill (GetMondayWeekOfYear (Day, Month, Year));
          'x': NoFill (DefaultFormatItem ('F'));
          'X': NoFill (DefaultFormatItem ('T'));
          'y': ZeroFill (Year mod 100);
          'Y': if Year <> InvalidYear then
                 begin
                   WriteStr (Res, Year);
                   CurrentWidth := 4
                 end;
          'z': begin
                 Tmp := (Time.Hour * 60 + Time.Minute - UnixTime div 60 + 720) mod 1440 - 720;
                 WriteStr (Res, '+', Abs (Tmp) div 60 : 2, Abs (Tmp) mod 60 : 2);
                 if Tmp < 0 then Res[1] := '-';
                 if Res[2] = ' ' then Res[2] := '0';
                 if Res[4] = ' ' then Res[4] := '0';
                 CurrentWidth := 0
               end;
          'Z': begin
                 Tmp := (Time.Hour * 60 + Time.Minute - UnixTime div 60 + 720) mod 1440 - 720;
                 WriteStr (Res, 'GMT -', Abs (Tmp) div 60, ':', Abs (Tmp) mod 60 : 2);
                 if Tmp < 0 then Res[5] := '+';
                 if Res[8] = ' ' then Res[8] := '0';
                 if Res[9] = ' ' then Res[9] := '0';
                 CurrentWidth := 0
               end;
          '%': NoFill ('%');
          else NoFill ('%' + Item);
               InvalidFormat := True
        end;
    if Fill <> FillDefault then CurrentFill := Fill;
    if Width <> WidthDefault then CurrentWidth := Width;
    if (CurrentFill <> FillNone) and ((Width <> WidthDefault) or (Res <> ''))
       and (Length (Res) < CurrentWidth) then
      Insert (StringOfChar (CurrentFill, CurrentWidth - Length (Res)), Res, 1);
    if Clip and (Width <> WidthDefault) and (Length (Res) > CurrentWidth) then
      Delete (Res, CurrentWidth + 1)
  end;

var
  Width, k, e: Integer;
  i, j: Integer { @@false warning } = 0;
  Alternative: TString;
  Fill: Char { @@false warning } = FillDefault;
  Clip: Boolean { @@false warning } = False;
  Convert: (c_None, c_LoCase, c_UpCase) { @@ false warning } =c_None;
begin
  Res := '';
  if not (Time.TimeValid and Time.DateValid) then Exit;
  with Time do
    if Year <> InvalidYear then
      begin
        DOW := GetDayOfWeek (Day, Month, Year);  { Do not rely upon the DayOfWeek field }
        DOY := GetDayOfYear (Day, Month, Year);
        GetISOWeekOfYear (Day, Month, Year, ISOWeek, ISOWeekYear);
        UnixTime := TimeStampToUnixTime (Time)
      end
    else
      begin
        TmpTime := Time;
        TmpTime.Year := 1970;  { Dummy }
        UnixTime := TimeStampToUnixTime (TmpTime)
      end;
  i := 1;
  while i <= Length (Format) do
    begin
      InvalidFormat := True;
      j := i;
      if Format[i] = '%' then
        begin
          Alternative := '';
          Width := WidthDefault;
          Fill := FillDefault;
          Clip := False;
          Convert := c_None;
          Inc (j);
          while (j <= Length (Format)) do
            begin
              case Format[j] of
                '_': Fill := ' ';
                '-': Fill := FillNone;
                '0': Fill := '0';
                '/': Clip := True;
                '~': Convert := c_LoCase;
                '^': Convert := c_UpCase;
                else Break
              end;
              Inc (j)
            end;
          if (j <= Length (Format)) and (Format[j] in ['0' .. '9']) then
            begin
              k := j;
              while (j <= Length (Format)) and (Format[j] in ['0' .. '9']) do Inc (j);
              Val (Copy (Format, k, j - k), Width, e);
              if e <> 0 then Width := WidthDefault  { should not happen }
            end;
          k := j;
          while (j <= Length (Format)) and (Format[j] in ['E', 'O']) do Inc (j);
          if j > k then Alternative := Format[k .. j - 1];
          if j <= Length (Format) then
            begin
              InvalidFormat := False;
              s := FormatItem (Format[j], Alternative, Width, Fill, Clip);
              if not InvalidFormat then
                begin
                  case Convert of
                    c_LoCase: LoCaseString (s);
                    c_UpCase: UpCaseString (s);
                  end;
                  Insert (s, Res, Length (Res) + 1)
                end
            end
        end;
      if InvalidFormat then
        Insert (Format[i .. j], Res, Length (Res) + 1);
      i := j + 1
    end
end;

end.
