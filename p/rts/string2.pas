{ String handling routines (higher level)

  Copyright (C) 1997-2006 Free Software Foundation, Inc.

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

unit String2; attribute (name = '_p__rts_String2');

interface

uses RTSC, String1, Error, Heap;

type
  PChars0 = ^TChars0;
  TChars0 = array [0 .. MaxVarSize div SizeOf (Char) - 1] of Char;

  PPChars0 = ^TPChars0;
  TPChars0 = array [0 .. MaxVarSize div SizeOf (PChars0) - 1] of PChars0;

  PChars = ^TChars;
  TChars = packed array [1 .. MaxVarSize div SizeOf (Char)] of Char;

{@internal}
  GPC_PString = ^GPC_String;
  GPC_String (Capacity: Cardinal) = record
    Length: 0 .. Capacity;
    Chars : packed array [1 .. Capacity + 1] of Char
  end;

  {$if False}
  StringObject = abstract object
    function  GetCapacity: Integer;           abstract;
    procedure SetLength (NewLength: Integer); abstract;
    function  GetLength: Integer;             abstract;
    function  GetFirstChar: PChars;           abstract;
  end;
  {$endif}

  { @@ AnyString parameters are not yet implemented, the following is only a draft }
  AnyStringType = (AnyStringLong,
                   AnyStringUndiscriminated,
                   AnyStringShort,
                   AnyStringFixed,
                   AnyStringCString,
                   AnyStringObject);

  { @@ only formally for now } UndiscriminatedString = ^String;

  VarAnyString = record
    Capacity: Integer;
    Chars   : PChars;
    Truncate: Boolean;
  case StringType           : AnyStringType of
    AnyStringLong           : (PLongLength           : ^Cardinal);
    AnyStringUndiscriminated: (PUndiscriminatedString: ^UndiscriminatedString);
    AnyStringShort          : (PShortLength          : ^Byte);
    AnyStringFixed          : (CurrentLength         : Integer);
    {$if False}
    AnyStringObject         : (PStringObject         : ^StringObject)
    {$endif}
  end;
{@endinternal}

  { Under development. Interface subject to change.
    Use with caution. }
  { When a const or var AnyString parameter is passed, internally
    these records are passed as const parameters. Value AnyString
    parameters are passed like value string parameters. }
  ConstAnyString = record
    Length: Integer;
    Chars: PChars
  end;

  { Capacity is the allocated space (used internally). Count is the
    actual number of environment strings. The CStrings array
    contains the environment strings, terminated by a nil pointer,
    which is not counted in Count. @CStrings can be passed to libc
    routines like execve which expect an environment (see
    GetCEnvironment). }
  PEnvironment = ^TEnvironment;
  TEnvironment (Capacity: Integer) = record
    Count: Integer;
    CStrings: array [1 .. Capacity + 1] of CString
  end;

var
  Environment: PEnvironment = nil; attribute (name = '_p_Environment');

{ Get an environment variable. If it does not exist, GetEnv returns
  the empty string, which can't be distinguished from a variable
  with an empty value, while CStringGetEnv returns nil then. Note,
  Dos doesn't know empty environment variables, but treats them as
  non-existing, and does not distinguish case in the names of
  environment variables. However, even under Dos, empty environment
  variables and variable names with different case can now be set
  and used within GPC programs. }
function  GetEnv (const EnvVar: String): TString;                         attribute (name = '_p_GetEnv');
function  CStringGetEnv (EnvVar: CString): CString;                       attribute (name = '_p_CStringGetEnv');

{ Sets an environment variable with the name given in VarName to the
  value Value. A previous value, if any, is overwritten. }
procedure SetEnv (const VarName: String; const Value: String);                          attribute (name = '_p_SetEnv');

{ Un-sets an environment variable with the name given in VarName. }
procedure UnSetEnv (const VarName: String);                               attribute (name = '_p_UnSetEnv');

{ Returns @Environment^.CStrings, converted to PCStrings, to be
  passed to libc routines like execve which expect an environment. }
function  GetCEnvironment: PCStrings;                                     attribute (name = '_p_GetCEnvironment');

{@internal}
procedure GPC_Init_Environment (StartEnvironment: PCStrings); attribute (name = '_p_Init_Environment');

{ Internal routine for Trim }
procedure GPC_Trim (const Src: String; var Dest: String); attribute (name = '_p_Trim');

{ Internal routine for SubStr/Copy }
procedure GPC_SubStr (Src: PChars0; SrcLength: Integer; aPosition, Count: Integer; var Dest: String; Mode: Integer); attribute (name = '_p_SubStr');

{ Under development }
function VarAnyStringLength (var s: VarAnyString): Cardinal; attribute (name = '_p_VarAnyStringLength');
function VarAnyStringSetLength (var s: VarAnyString; NewLength: Cardinal): Cardinal; attribute (name = '_p_VarAnyStringSetLength');

procedure GPC_Insert      (const Source: String; var Dest: String;
                           aIndex: Integer; TruncateFlag: Boolean);            attribute (name = '_p_Insert');
procedure GPC_Delete      (var s: String; aIndex, Count: Integer);             attribute (name = '_p_Delete');

type
  PIntegers = ^TIntegers;
  TIntegers = array [0 .. MaxVarSize div SizeOf (Integer) - 1] of Integer;

function InternalFormatString (var Format: String; Count: Integer; Strings: PPChars0; Lengths: PIntegers): PString; attribute (name = '_p_InternalFormatString');
function InternalStringOf (Count: Integer; Strings: PPChars0; Lengths: PIntegers): PString; attribute (name = '_p_InternalStringOf');
{@endinternal}

type
  FormatStringTransformType = ^function (const Format: String): TString;

var
  FormatStringTransformPtr: FormatStringTransformType = nil; attribute (name = '_p_FormatStringTransformPtr');

implementation

{$pointer-arithmetic,cstrings-as-strings}

const
  EnvironmentSizeStep = 16;
  UndiscriminatedStringSizeStep = 64;

procedure GPC_Init_Environment (StartEnvironment: PCStrings);
var
  i, j: Integer;
  p: Pointer;
begin
  p := SuspendMark;
  if Environment <> nil then
    begin
      for i := 1 to Environment^.Count do Dispose (Environment^.CStrings[i]);
      Dispose (Environment)
    end;
  i := 0;
  if StartEnvironment <> nil then
    while StartEnvironment^[i] <> nil do Inc (i);
  New (Environment, i);
  Environment^.Count := i;
  for j := 1 to i do
    begin
      Environment^.CStrings[j] := CStringNew (StartEnvironment^[j - 1]);
      {$ifdef __OS_DOS__}
      var Temp: CString = Environment^.CStrings[j];
      while not (Temp^ in [#0, '=']) do
        begin
          Temp^ := UpCase (Temp^);
          Inc (Temp)
        end
      {$endif}
    end;
  Environment^.CStrings[i + 1] := nil;
  ResumeMark (p)
end;

function GetEnvIndex (EnvVar: CString): Integer;
var l, i: Integer;
begin
  if Environment = nil then Return 0;
  l := CStringLength (EnvVar);
  i := 1;
  while (i <= Environment^.Count) and ((MemComp (EnvVar^, Environment^.CStrings[i]^, l) <> 0) or (Environment^.CStrings[i, l] <> '=')) do Inc (i);
  if i > Environment^.Count then
    GetEnvIndex := 0
  else
    GetEnvIndex := i
end;

function CStringGetEnv (EnvVar: CString): CString;
var i: Integer;
begin
  i := GetEnvIndex (EnvVar);
  if i = 0 then
    CStringGetEnv := nil
  else
    CStringGetEnv := Environment^.CStrings[i] + CStringLength (EnvVar) + 1
end;

function GetEnv (const EnvVar: String): TString;
var Temp: CString;
begin
  Temp := CStringGetEnv (EnvVar);
  if Temp = nil then GetEnv := '' else GetEnv := CString2String (Temp)
end;

procedure SetEnv (const VarName: String; const Value: String);
var
  i: Integer;
  NewEnvironment: PEnvironment;
  NewEnvCString: CString;
  p: Pointer;
begin
  p := SuspendMark;
  i := GetEnvIndex (VarName);
  if i <> 0 then
    Dispose (Environment^.CStrings[i])
  else
    begin
      if Environment^.Count = Environment^.Capacity then
        begin
          New (NewEnvironment, Environment^.Count + EnvironmentSizeStep);
          for i := 1 to Environment^.Count do NewEnvironment^.CStrings[i] := Environment^.CStrings[i];
          NewEnvironment^.Count := Environment^.Count;
          Dispose (Environment);
          Environment := NewEnvironment
        end;
      Inc (Environment^.Count);
      i := Environment^.Count;
      Environment^.CStrings[i + 1] := nil
    end;
  NewEnvCString := NewCString (VarName + '=' + Value);
  Environment^.CStrings[i] := NewEnvCString;
  CStringSetEnv (VarName, Value, NewEnvCString, False);
  ResumeMark (p)
end;

procedure UnSetEnv (const VarName: String);
var i, j: Integer;
begin
  i := GetEnvIndex (VarName);
  if i <> 0 then
    with Environment^ do
      begin
        InternalDispose (CStrings[i]);
        for j := i to Count - 1 do CStrings[j] := CStrings[j + 1];
        CStrings[Count] := nil;
        Dec (Count)
      end;
  CStringSetEnv (VarName, '', VarName + '=', True)
end;

function GetCEnvironment: PCStrings;
begin
  GetCEnvironment := PCStrings (@Environment^.CStrings)
end;

procedure GPC_Trim (const Src: String; var Dest: String);
var i: Integer;
begin
  SetReturnAddress (ReturnAddress (0));
  i := Length (Src);
  while (i > 0) and (Src[i] = ' ') do Dec (i);
  Dest := Copy (Src, 1, i);
  RestoreReturnAddress
end;

{ Mode: 0: `Copy', 1: `SubStr' with 2 arguments, 2: `SubStr' with 3 arguments }
procedure GPC_SubStr (Src: PChars0; SrcLength: Integer; aPosition, Count: Integer; var Dest: String; Mode: Integer);
begin
  SetReturnAddress (ReturnAddress (0));
  if aPosition <= 0 then
    if Mode = 0 then
      begin
        aPosition := 1;
        Count := 0
      end
    else
      RuntimeError (801);  { Substring cannot start from positions less than 1 }
  if aPosition > SrcLength - Count + 1 then  { Note: aPosition can be MaxInt }
    if Mode < 2 then
      Count := SrcLength - aPosition + 1
    else
      RuntimeError (803);  { Substring must terminate before end of string }
  if Count < 0 then
    if Mode = 0 then
      Count := 0
    else
      RuntimeError (802);  { Substring length cannot be negative }
  SetLength (Dest, Count);
  if Count <> 0 then Move (Src^[aPosition - 1], Dest[1], Count);
  RestoreReturnAddress
end;

function InternalFormatString (var Format: String; Count: Integer; Strings: PPChars0; Lengths: PIntegers): PString;
var
  Size, c, i, j, k, n, e: Integer;
  TransformedFormat: TString;
  Fmt: PString;
  p: Pointer;
  Store: Boolean;
  Res: PString = nil; attribute (static);
begin
  { Transform format string (e.g., via GetText) if requested }
  if FormatStringTransformPtr = nil then
    Fmt := @Format
  else
    begin
      TransformedFormat := FormatStringTransformPtr^ (Format);
      Fmt := @TransformedFormat
    end;

  { In the first pass, only compute size of result.
    In the second pass, actually construct the result. }
  for Store := False to True do
    begin
      Size := 0;
      c := 0;
      i := 1;
      while i <= Length (Fmt^) do
        if (i = Length (Fmt^)) or (Fmt^[i] <> '%') then
          begin
            Inc (Size);
            if Store then Res^[Size] := Fmt^[i];
            Inc (i)
          end
        else
          begin
            n := -1;
            j := 0;
            if Fmt^[i + 1] = '@' then
              begin
                j := i + 2;
                while (j <= Length (Fmt^)) and (Fmt^[j] in ['0' .. '9']) do Inc (j);
                if (j > i + 2) and (j <= Length (Fmt^)) and (Fmt^[j] in ['a' .. 'z', 'A' .. 'Z']) then
                  begin
                    Val (Fmt^[i + 2 .. j - 1], n, e);
                    if e <> 0 then n := -1
                  end
              end;
            if (n = -1) and not (Fmt^[i + 1] in ['a' .. 'z', 'A' .. 'Z']) then
              begin
                Inc (Size);
                if Store then Res^[Size] := Fmt^[i + 1];
                Inc (i, 2)
              end
            else
              begin
                if n = -1 then
                  begin
                    Inc (c);
                    n := c;
                    Inc (i, 2)
                  end
                else
                  i := j + 1;
                if (n > 0) and (n <= Count) then
                  begin
                    k := Lengths^[n - 1];
                    if Store and (k > 0) then Res^[Size + 1 .. Size + k] := Strings^[n - 1]^[0 .. k - 1];
                    Inc (Size, k)
                  end
              end
          end;

      { At the end of the first pass allocate the result. (Dispose of it in the
        next invocation so we don't have to worry about this in the compiler.) }
      if not Store then
        begin
          p := SuspendMark;
          Dispose (Res);
          New (Res, Max (1, Size));
          ResumeMark (p);
          SetLength (Res^, Size)
        end
    end;

  { Clean up and return result }
  for i := 1 to Count do InternalDispose (Strings^[i - 1]);
  InternalFormatString := Res
end;

function InternalStringOf (Count: Integer; Strings: PPChars0; Lengths: PIntegers): PString;
var
  Size, k, n: Integer;
  p: Pointer;
  Res: PString = nil; attribute (static);
begin
  { Compute size of the result. }
  Size := 0;
  for n := 1 to Count do
    Inc (Size, Lengths^[n - 1]);

  { Allocate the result. (Dispose of it in the
    next invocation so we don't have to worry about this in the compiler.) }
  p := SuspendMark;
  Dispose (Res);
  New (Res, Max (1, Size));
  ResumeMark (p);
  SetLength (Res^, Size);

  { Copy to the result. }
  Size := 0;
  for n := 1 to Count do
    begin
      k := Lengths^[n - 1];
      if k > 0 then
        Res^[Size + 1 .. Size + k] := Strings^[n - 1]^[0 .. k - 1];
      Inc (Size, k)
    end;
  { Clean up and return result }
  for n := 1 to Count do InternalDispose (Strings^[n - 1]);
  InternalStringOf := Res
end;

function VarAnyStringLength (var s: VarAnyString): Cardinal;
begin
  VarAnyStringLength := 0;
  with s do
    case StringType of
      AnyStringLong           : VarAnyStringLength := PLongLength^;
      AnyStringUndiscriminated: VarAnyStringLength := Length (PUndiscriminatedString^^);
      AnyStringShort          : VarAnyStringLength := PShortLength^;
      AnyStringFixed          : VarAnyStringLength := CurrentLength;
      AnyStringCString        : VarAnyStringLength := CStringLength (CString (Chars));
      {$if False}
      AnyStringObject         : VarAnyStringLength := PStringObject^.GetLength;
      {$endif}
    end
end;

function VarAnyStringSetLength (var s: VarAnyString; NewLength: Cardinal): Cardinal;
begin
  with s do
    begin
      if NewLength > Capacity then
        if Truncate then
          NewLength := Capacity
        else
          RuntimeError (806);  { string too long }
      case StringType of
        AnyStringLong           : PLongLength^ := NewLength;
        AnyStringUndiscriminated: begin
                                    if NewLength > PUndiscriminatedString^^.Capacity then
                                      begin
                                        var Temp: PString;
                                        var p: Pointer;
                                        p := SuspendMark;
                                        Temp := PUndiscriminatedString^;
                                        New (PUndiscriminatedString^, (NewLength div UndiscriminatedStringSizeStep + 1) * UndiscriminatedStringSizeStep);
                                        GPC_PString (PUndiscriminatedString^)^.Length := NewLength;
                                        if Temp^ <> '' then Move (Temp^[1], PUndiscriminatedString^^[1], Length (Temp^));
                                        Dispose (Temp);
                                        ResumeMark (p)
                                      end
                                    else
                                      GPC_PString (PUndiscriminatedString^)^.Length := NewLength
                                  end;
        AnyStringShort          : PShortLength^ := NewLength;
        AnyStringFixed          : begin
                                    var i: Integer;
                                    for i := NewLength + 1 to CurrentLength do Chars^[i] := ' ';
                                    CurrentLength := NewLength
                                  end;
        AnyStringCString        : Chars^[NewLength + 1] := #0;
        {$if False}
        AnyStringObject         : PStringObject^.SetLength (NewLength);
        {$endif}
      end
    end;
  VarAnyStringSetLength := NewLength
end;

procedure GPC_Insert (const Source: String; var Dest: String; aIndex: Integer; TruncateFlag: Boolean);
var s, d: Integer;
begin
  s := Length (Source);
  d := Length (Dest);
  if (aIndex >= 1) and (aIndex <= d + 1) and (s > 0) then
    begin
      if s + d > Dest.Capacity then
        if TruncateFlag then
          begin
            s := Min (s, Dest.Capacity - aIndex + 1);
            d := Dest.Capacity - s
          end
        else
          begin
            SetReturnAddress (ReturnAddress (0));
            RuntimeError (800);  { string too long in `Insert' }
            RestoreReturnAddress
          end;
      SetLength (Dest, s + d);
      if d >= aIndex then MoveRight (Dest[aIndex], Dest[aIndex + s], d - aIndex + 1);
      if s > 0 then MoveLeft (Source[1], Dest[aIndex], s)
    end
end;

procedure GPC_Delete (var s: String; aIndex, Count: Integer);
begin
  if aIndex < 1 then
    begin
      Dec (Count, 1 - aIndex);
      aIndex := 1
    end;
  if (Count > 0) and (aIndex <= Length (s)) then
    if aIndex > Length (s) - Count then
      SetLength (s, aIndex - 1)
    else
      begin
        MoveLeft (s[aIndex + Count], s[aIndex], Length (s) - (aIndex + Count) + 1);
        SetLength (s, Length (s) - Count)
      end
end;

end.
