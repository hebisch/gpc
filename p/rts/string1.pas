{ String handling routines (lower level)

  Copyright (C) 1997-2006 Free Software Foundation, Inc.

  Authors: Frank Heckenbach <frank@pascal.gnu.de>
           Jukka Virtanen <jtv@hut.fi>
           Mirsad Todorovac <mtodorov_69@yahoo.com>

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

unit String1; attribute (name = '_p__rts_String1');

interface

uses RTSC;

{ TString is a string type that is used for function results and
  local variables, as long as undiscriminated strings are not
  allowed there. The default size of 2048 characters should be
  enough for file names on any system, but can be changed when
  necessary. It should be at least as big as MAXPATHLEN. }

const
  MaxLongInt = High (LongInt);

  TStringSize = 2048;
  SpaceCharacters = [' ', #9];
  NewLine = "\n";  { the separator of lines within a string }
  LineBreak = {$if defined (__OS_DOS__) and not defined (__CYGWIN__) and not defined (__MSYS__)}
              "\r\n"
              {$else}
              "\n"
              {$endif};  { the separator of lines within a file }

type
  TString    = String (TStringSize);
  TStringBuf = packed array [0 .. TStringSize] of Char;
  CharSet    = set of Char;
  Str64      = String (64);
  TInteger2StringBase = Cardinal(2) .. Cardinal(36);
  TInteger2StringWidth = 0 .. High (TString);

var
  NumericBaseDigits: array [0 .. 35] of Char = '0123456789abcdefghijklmnopqrstuvwxyz'; attribute (const, name = '_p_NumericBaseDigits');
  NumericBaseDigitsUpper: array [0 .. 35] of Char = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'; attribute (const, name = '_p_NumericBaseDigitsUpper');

  CParamCount: Integer = 1; attribute (name = '_p_CParamCount');
  {@internal}
  CParametersDummy: array [0 .. 1] of CString = ('GPC program', nil); attribute (name = '_p_CParametersDummy');
  {@endinternal}
  CParameters: PCStrings = PCStrings (@CParametersDummy); attribute (name = '_p_CParameters');

function  MemCmp      (const s1, s2; Size: SizeType): CInteger; external name 'memcmp';
function  MemComp     (const s1, s2; Size: SizeType): CInteger; external name 'memcmp';
function  MemCompCase (const s1, s2; Size: SizeType): Boolean; attribute (name = '_p_MemCompCase');

procedure UpCaseString    (var s: String);                                        attribute (name = '_p_UpCaseString');
procedure LoCaseString    (var s: String);                                        attribute (name = '_p_LoCaseString');
function  UpCaseStr       (const s: String) = Result: TString;                    attribute (name = '_p_UpCaseStr');
function  LoCaseStr       (const s: String) = Result: TString;                    attribute (name = '_p_LoCaseStr');

function  StrEqualCase    (const s1: String; const s2: String): Boolean;                        attribute (name = '_p_StrEqualCase');

function  Pos             (const SubString: String; const s: String): Integer;                  attribute (name = '_p_Pos');
function  PosChar         (const ch: Char; const s: String): Integer;             attribute (name = '_p_PosChar');
function  LastPos         (const SubString: String; const s: String): Integer;                  attribute (name = '_p_LastPos');
function  PosCase         (const SubString: String; const s: String): Integer;                  attribute (name = '_p_PosCase');
function  LastPosCase     (const SubString: String; const s: String): Integer;                  attribute (name = '_p_LastPosCase');
function  CharPos         (const Chars: CharSet; const s: String): Integer;       attribute (name = '_p_CharPos');
function  LastCharPos     (const Chars: CharSet; const s: String): Integer;       attribute (name = '_p_LastCharPos');

function  PosFrom         (const SubString: String; const s: String; From: Integer): Integer;            attribute (name = '_p_PosFrom');
function  LastPosTill     (const SubString: String; const s: String; Till: Integer): Integer;            attribute (name = '_p_LastPosTill');
function  PosFromCase     (const SubString: String; const s: String; From: Integer): Integer;            attribute (name = '_p_PosFromCase');
function  LastPosTillCase (const SubString: String; const s: String; Till: Integer): Integer;            attribute (name = '_p_LastPosTillCase');
function  CharPosFrom     (const Chars: CharSet; const s: String; From: Integer): Integer; attribute (name = '_p_CharPosFrom');
function  LastCharPosTill (const Chars: CharSet; const s: String; Till: Integer): Integer; attribute (name = '_p_LastCharPosTill');

function  IsPrefix        (const Prefix: String; const s: String): Boolean;                    attribute (name = '_p_IsPrefix');
function  IsSuffix        (const Suffix: String; const s: String): Boolean;                    attribute (name = '_p_IsSuffix');
function  IsPrefixCase    (const Prefix: String; const s: String): Boolean;                    attribute (name = '_p_IsPrefixCase');
function  IsSuffixCase    (const Suffix: String; const s: String): Boolean;                    attribute (name = '_p_IsSuffixCase');

function  CStringLength      (Src: CString): SizeType;                           attribute (inline, name = '_p_CStringLength');
function  CStringEnd         (Src: CString): CString;                            attribute (inline, name = '_p_CStringEnd');
function  CStringNew         (Src: CString): CString;                            attribute (name = '_p_CStringNew');
function  CStringComp        (s1, s2: CString): Integer;                         attribute (name = '_p_CStringComp');
function  CStringCaseComp    (s1, s2: CString): Integer;                         attribute (name = '_p_CStringCaseComp');
function  CStringLComp       (s1, s2: CString; MaxLen: SizeType): Integer;       attribute (name = '_p_CStringLComp');
function  CStringLCaseComp   (s1, s2: CString; MaxLen: SizeType): Integer;       attribute (name = '_p_CStringLCaseComp');
function  CStringCopy        (Dest, Source: CString): CString;                   attribute (ignorable, name = '_p_CStringCopy');
function  CStringCopyEnd     (Dest, Source: CString): CString;                   attribute (ignorable, name = '_p_CStringCopyEnd');
function  CStringLCopy       (Dest, Source: CString; MaxLen: SizeType): CString; attribute (ignorable, name = '_p_CStringLCopy');
function  CStringMove        (Dest, Source: CString; Count: SizeType): CString;  attribute (ignorable, name = '_p_CStringMove');
function  CStringCat         (Dest, Source: CString): CString;                   attribute (ignorable, name = '_p_CStringCat');
function  CStringLCat        (Dest, Source: CString; MaxLen: SizeType): CString; attribute (ignorable, name = '_p_CStringLCat');
function  CStringChPos       (Src: CString; ch: Char): CString;                  attribute (inline, name = '_p_CStringChPos');
function  CStringLastChPos   (Src: CString; ch: Char): CString;                  attribute (inline, name = '_p_CStringLastChPos');
function  CStringPos         (s, SubString: CString): CString;                   attribute (name = '_p_CStringPos');
function  CStringLastPos     (s, SubString: CString): CString;                   attribute (name = '_p_CStringLastPos');
function  CStringCasePos     (s, SubString: CString): CString;                   attribute (name = '_p_CStringCasePos');
function  CStringLastCasePos (s, SubString: CString): CString;                   attribute (name = '_p_CStringLastCasePos');
function  CStringUpCase      (s: CString): CString;                              attribute (name = '_p_CStringUpCase');
function  CStringLoCase      (s: CString): CString;                              attribute (name = '_p_CStringLoCase');
function  CStringIsEmpty     (s: CString): Boolean;                              attribute (name = '_p_CStringIsEmpty');
function  NewCString         (const Source: String): CString;                    attribute (name = '_p_NewCString');
function  CStringCopyString  (Dest: CString; const Source: String): CString;     attribute (name = '_p_CStringCopyString');
procedure CopyCString        (Source: CString; var Dest: String);                attribute (name = '_p_CopyCString');

function  NewString       (const s: String) = Result: PString;                   attribute (name = '_p_NewString');
procedure DisposeString   (p: PString);                                          external name '_p_Dispose';

procedure SetString       (var s: String; Buffer: PChar; Count: Integer);        attribute (name = '_p_SetString');
function  StringOfChar    (ch: Char; Count: Integer) = s: TString;               attribute (name = '_p_StringOfChar');

procedure TrimLeft        (var s: String);                                       attribute (name = '_p_TrimLeft');
procedure TrimRight       (var s: String);                                       attribute (name = '_p_TrimRight');
procedure TrimBoth        (var s: String);                                       attribute (name = '_p_TrimBoth');
function  TrimLeftStr     (const s: String) = Result: TString;                   attribute (name = '_p_TrimLeftStr');
function  TrimRightStr    (const s: String) = Result: TString;                   attribute (name = '_p_TrimRightStr');
function  TrimBothStr     (const s: String) = Result: TString;                   attribute (name = '_p_TrimBothStr');
function  LTrim           (const s: String) = Result: TString;                   external name '_p_TrimLeftStr';

function  GetStringCapacity (const s: String): Integer;                          attribute (name = '_p_GetStringCapacity');

{ A shortcut for a common use of WriteStr as a function }
function  Integer2String (i: Integer) = s: Str64;                                attribute (name = '_p_Integer2String');

{ Convert integer n to string in base Base. }
function  Integer2StringBase (n: LongestInt; Base: TInteger2StringBase): TString;    attribute (name = '_p_Integer2StringBase');

{ Convert integer n to string in base Base, with sign, optionally in
  uppercase representation and with printed base, padded with
  leading zeroes between `[<Sign>]<Base>#' and the actual digits to
  specified Width. }
function  Integer2StringBaseExt (n: LongestInt; Base: TInteger2StringBase; Width: TInteger2StringWidth; Upper: Boolean; PrintBase: Boolean): TString; attribute (name = '_p_Integer2StringBaseExt');

{@internal}
function  BP_UpCase       (ch: Char): Char;                                      attribute (const, inline, name = '_p_BP_UpCase');

{ Compare strings for equality without padding }
function  StrEQ (const s1, s2: String): Boolean; attribute (name = '_p_EQ');

{ Compare strings for `less-than' without padding }
function  StrLT (const s1, s2: String): Boolean; attribute (name = '_p_LT');

{ Compare strings for equality, padding the shorter string with spaces }
function  StrEQPad (const s1, s2: String) = Result: Boolean; attribute (name = '_p_StrEQ');

{ Compare strings for `less-than', padding the shorter string with spaces }
function  StrLTPad (const s1, s2: String): Boolean; attribute (name = '_p_StrLT');
{@endinternal}

implementation

{$pointer-arithmetic,cstrings-as-strings}

{ @@@@@@ from error.pas }
procedure SetReturnAddress (Address: Pointer); external name '_p_SetReturnAddress';
procedure RestoreReturnAddress; external name '_p_RestoreReturnAddress';

function BP_UpCase (ch: Char): Char;
begin
  if ch in ['a' .. 'z'] then
    BP_UpCase := Pred (ch, Ord ('a') - Ord ('A'))
  else
    BP_UpCase := ch
end;

procedure UpCaseString (var s: String);
var i: Integer;
begin
  for i := 1 to Length (s) do s[i] := UpCase (s[i])
end;

procedure LoCaseString (var s: String);
var i: Integer;
begin
  for i := 1 to Length (s) do s[i] := LoCase (s[i])
end;

function UpCaseStr (const s: String) = Result: TString;
begin
  Result := s;
  UpCaseString (Result)
end;

function LoCaseStr (const s: String) = Result: TString;
begin
  Result := s;
  LoCaseString (Result)
end;

function MemCompCase (const s1, s2; Size: SizeType): Boolean;
var
  i: Integer;
  a1: array [1 .. Size + 1] of Char absolute s1;  { `+ 1' to avoid subrange error if Size = 0 }
  a2: array [1 .. Size + 1] of Char absolute s2;
begin
  for i := 1 to Size do
    if (a1[i] <> a2[i]) and (LoCase (a1[i]) <> LoCase (a2[i])) then Return False;
  MemCompCase := True
end;

function StrEqualCase (const s1: String; const s2: String): Boolean;
begin
  StrEqualCase := (Length (s1) = Length (s2)) and ((s1 = '') or MemCompCase (s1[1], s2[1], Length (s1)))
end;

function Pos (const SubString: String; const s: String): Integer;
begin
  Pos := PosFrom (SubString, s, 1)
end;

function PosChar (const ch: Char; const s: String): Integer;
var i: Integer;
begin
  i := 1;
  while (i <= Length (s)) and (s[i] <> ch) do Inc (i);
  if i > Length (s) then PosChar := 0 else PosChar := i
end;

function LastPos (const SubString: String; const s: String): Integer;
begin
  LastPos := LastPosTill (SubString, s, Length (s))
end;

function PosCase (const SubString: String; const s: String): Integer;
begin
  PosCase := PosFromCase (SubString, s, 1)
end;

function LastPosCase (const SubString: String; const s: String): Integer;
begin
  LastPosCase := LastPosTillCase (SubString, s, Length (s))
end;

function CharPos (const Chars: CharSet; const s: String): Integer;
var i: Integer;
begin
  i := 1;
  while (i <= Length (s)) and not (s[i] in Chars) do Inc (i);
  if i > Length (s) then CharPos := 0 else CharPos := i
end;

function LastCharPos (const Chars: CharSet; const s: String): Integer;
var i: Integer;
begin
  i := Length (s);
  while (i > 0) and not (s[i] in Chars) do Dec (i);
  LastCharPos := i
end;

function PosFrom (const SubString: String; const s: String; From: Integer): Integer;
var m, i, n: Integer;
begin
  m := Max (1, From);
  if Length (SubString) = 0 then
    PosFrom := m
  else if Length (s) = 0 then
    PosFrom := 0
  else if Length (SubString) = 1 then
    begin
      i := m;
      while (i <= Length (s)) and (s[i] <> SubString[1]) do Inc (i);
      if i > Length (s) then PosFrom := 0 else PosFrom := i
    end
  else
    begin
      n := Length (s) - Length (SubString) + 1;
      i := m;
      while (i <= n) and
            ((s[i] <> SubString[1]) or (MemComp (s[i], SubString[1], Length (SubString)) <> 0)) do Inc (i);
      if i > n then PosFrom := 0 else PosFrom := i
    end
end;

function LastPosTill (const SubString: String; const s: String; Till: Integer): Integer;
var m, i: Integer;
begin
  m := Max (0, Min (Length (s), Till));
  case Length (SubString) of
    0: LastPosTill := m + 1;
    1: begin
         i := m;
         while (i > 0) and (s[i] <> SubString[1]) do Dec (i);
         LastPosTill := i
       end;
    else
      i := m - Length (SubString) + 1;
      while (i > 0) and (MemComp (s[i], SubString[1], Length (SubString)) <> 0) do Dec (i);
      if i < 0 then LastPosTill := 0 else LastPosTill := i
  end
end;

function PosFromCase (const SubString: String; const s: String; From: Integer): Integer;
var m, i, n: Integer;
begin
  m := Max (1, From);
  case Length (SubString) of
    0: PosFromCase := From;
    1: begin
         i := m;
         while (i <= Length (s)) and (s[i] <> SubString[1]) and (LoCase (s[i]) <> LoCase (SubString[1])) do Inc (i);
         if i > Length (s) then PosFromCase := 0 else PosFromCase := i
       end;
    else
      n := Length (s) - Length (SubString) + 1;
      i := m;
      while (i <= n) and not MemCompCase (s[i], SubString[1], Length (SubString)) do Inc (i);
      if i > n then PosFromCase := 0 else PosFromCase := i
  end
end;

function LastPosTillCase (const SubString: String; const s: String; Till: Integer): Integer;
var m, i: Integer;
begin
  m := Max (0, Min (Length (s), Till));
  case Length (SubString) of
    0: LastPosTillCase := m + 1;
    1: begin
         i := m;
         while (i > 0) and (s[i] <> SubString[1]) and (LoCase (s[i]) <> LoCase (SubString[1])) do Dec (i);
         LastPosTillCase := i
       end;
    else
      i := m - Length (SubString) + 1;
      while (i > 0) and not MemCompCase (s[i], SubString[1], Length (SubString)) do Dec (i);
      if i < 0 then LastPosTillCase := 0 else LastPosTillCase := i
  end
end;

function CharPosFrom (const Chars: CharSet; const s: String; From: Integer): Integer;
var i: Integer;
begin
  i := Max (1, From);
  while (i <= Length (s)) and not (s[i] in Chars) do Inc (i);
  if i > Length (s) then CharPosFrom := 0 else CharPosFrom := i
end;

function LastCharPosTill (const Chars: CharSet; const s: String; Till: Integer): Integer;
var i: Integer;
begin
  i := Max (0, Min (Length (s), Till));
  while (i > 0) and not (s[i] in Chars) do Dec (i);
  LastCharPosTill := i
end;

function IsPrefix (const Prefix: String; const s: String): Boolean;
begin
  IsPrefix := (Prefix = '') or ((Length (s) >= Length (Prefix)) and EQ (s[1 .. Length (Prefix)], Prefix))
end;

function IsSuffix (const Suffix: String; const s: String): Boolean;
begin
  IsSuffix := (Suffix = '') or ((Length (s) >= Length (Suffix)) and EQ (s[Length (s) - Length (Suffix) + 1 .. Length (s)], Suffix))
end;

function IsPrefixCase (const Prefix: String; const s: String): Boolean;
begin
  IsPrefixCase := (Prefix = '') or ((Length (s) >= Length (Prefix)) and StrEqualCase (s[1 .. Length (Prefix)], Prefix))
end;

function IsSuffixCase (const Suffix: String; const s: String): Boolean;
begin
  IsSuffixCase := (Suffix = '') or ((Length (s) >= Length (Suffix)) and StrEqualCase (s[Length (s) - Length (Suffix) + 1 .. Length (s)], Suffix))
end;

function CStringLength (Src: CString): SizeType;
var Temp: CString;
begin
  if Src = nil then Return 0;
  Temp := Src;
  while Temp^ <> #0 do Inc (Temp);
  CStringLength := Temp - Src
end;

function CStringEnd (Src: CString): CString;
var Temp: CString;
begin
  if Src = nil then Return nil;
  Temp := Src;
  while Temp^ <> #0 do Inc (Temp);
  CStringEnd := Temp
end;

function CStringNew (Src: CString): CString;
var
  Size: SizeType;
  Dest: CString;
begin
  if Src = nil then Return nil;
  Size := CStringLength (Src) + 1;
  SetReturnAddress (ReturnAddress (0));
  GetMem (Dest, Size);
  RestoreReturnAddress;
  Move (Src^, Dest^, Size);
  CStringNew := Dest
end;

function CStringLComp (s1, s2: CString; MaxLen: SizeType): Integer;
var c1, c2: Char;
begin
  if s1 = nil then
    if (s2 = nil) or (s2^ = #0) then
      CStringLComp := 0
    else
      CStringLComp := -1
  else if s2 = nil then
    if s1^ = #0 then
      CStringLComp := 0
    else
      CStringLComp := 1
  else
    begin
      if MaxLen > 0 then
        repeat
          c1 := s1^;
          c2 := s2^;
          Inc (s1);
          Inc (s2);
          if c1 <> c2 then Return Ord (c1) - Ord (c2);
          Dec (MaxLen)
        until (c1 = #0) or (MaxLen = 0);
      CStringLComp := 0
    end
end;

function CStringComp (s1, s2: CString): Integer;
begin
  CStringComp := CStringLComp (s1, s2, MaxInt)
end;

function CStringLCaseComp (s1, s2: CString; MaxLen: SizeType): Integer;
var c1, c2: Char;
begin
  if s1 = nil then
    if (s2 = nil) or (s2^ = #0) then
      CStringLCaseComp := 0
    else
      CStringLCaseComp := -1
  else if s2 = nil then
    if s1^ = #0 then
      CStringLCaseComp := 0
    else
      CStringLCaseComp := 1
  else
    begin
      if MaxLen > 0 then
        repeat
          c1 := LoCase (s1^);
          c2 := LoCase (s2^);
          Inc (s1);
          Inc (s2);
          if c1 <> c2 then Return Ord (c1) - Ord (c2);
          Dec (MaxLen)
        until (c1 = #0) or (MaxLen = 0);
      CStringLCaseComp := 0
    end
end;

function CStringCaseComp (s1, s2: CString): Integer;
begin
  CStringCaseComp := CStringLCaseComp (s1, s2, MaxInt)
end;

function CStringCopy (Dest, Source: CString): CString;
var Size: SizeType;
begin
  if Source = nil then
    Size := 0
  else
    begin
      Size := CStringLength (Source);
      Move (Source^, Dest^, Size)
    end;
  Dest[Size] := #0;
  CStringCopy := Dest
end;

function CStringCopyEnd (Dest, Source: CString): CString;
var Size: SizeType;
begin
  if Source = nil then
    Size := 0
  else
    begin
      Size := CStringLength (Source);
      Move (Source^, Dest^, Size)
    end;
  Dest[Size] := #0;
  CStringCopyEnd := Dest + Size
end;

function CStringLCopy (Dest, Source: CString; MaxLen: SizeType): CString;
var Size: SizeType;
begin
  if Source = nil then
    Size := 0
  else
    begin
      Size := Min (CStringLength (Source), MaxLen);
      Move (Source^, Dest^, Size)
    end;
  Dest[Size] := #0;
  CStringLCopy := Dest
end;

function CStringMove (Dest, Source: CString; Count: SizeType): CString;
begin
  if Source = nil then
    FillChar (Dest^, Count, 0)
  else
    Move (Source^, Dest^, Count);
  CStringMove := Dest
end;

function CStringCat (Dest, Source: CString): CString;
begin
  CStringCopy (CStringEnd (Dest), Source);
  CStringCat := Dest
end;

function CStringLCat (Dest, Source: CString; MaxLen: SizeType): CString;
var s: SizeType;
begin
  s := CStringLength (Dest);
  CStringLCopy (Dest + s, Source, Max (MaxLen, s) - s);
  CStringLCat := Dest
end;

function CStringChPos (Src: CString; ch: Char): CString;
var Temp: CString;
begin
  if Src = nil then Return nil;
  Temp := Src;
  while (Temp^ <> #0) and (Temp^ <> ch) do Inc (Temp);
  if Temp^ = ch then CStringChPos := Temp else CStringChPos := nil
end;

function CStringLastChPos (Src: CString; ch: Char): CString;
var Temp: CString;
begin
  if Src = nil then Return nil;
  Temp := CStringEnd (Src);
  while (Temp <> Src) and (Temp^ <> ch) do Dec (Temp);
  if Temp^ = ch then CStringLastChPos := Temp else CStringLastChPos := nil
end;

function CStringPos (s, SubString: CString): CString;
var
  Temp: CString;
  l: SizeType;
begin
  if (s = nil) or (SubString = nil) then Return s;
  l := CStringLength (SubString);
  Temp := s;
  while Temp^ <> #0 do
    begin
      if CStringLComp (Temp, SubString, l) = 0 then Return Temp;
      Inc (Temp)
    end;
  CStringPos := nil
end;

function CStringLastPos (s, SubString: CString): CString;
var
  Temp: CString;
  l: SizeType;
begin
  if (s = nil) or (SubString = nil) then Return s;
  l := CStringLength (SubString);
  Temp := CStringEnd (s);
  while Temp >= s do
    begin
      if CStringLComp (Temp, SubString, l) = 0 then Return Temp;
      Dec (Temp)
    end;
  CStringLastPos := nil
end;

function CStringCasePos (s, SubString: CString): CString;
var
  Temp: CString;
  l: SizeType;
begin
  if (s = nil) or (SubString = nil) then Return s;
  l := CStringLength (SubString);
  Temp := s;
  while Temp^ <> #0 do
    begin
      if CStringLCaseComp (Temp, SubString, l) = 0 then Return Temp;
      Inc (Temp)
    end;
  CStringCasePos := nil
end;

function CStringLastCasePos (s, SubString: CString): CString;
var
  Temp: CString;
  l: SizeType;
begin
  if (s = nil) or (SubString = nil) then Return s;
  l := CStringLength (SubString);
  Temp := CStringEnd (s);
  while Temp >= s do
    begin
      if CStringLCaseComp (Temp, SubString, l) = 0 then Return Temp;
      Dec (Temp)
    end;
  CStringLastCasePos := nil
end;

function CStringUpCase (s: CString): CString;
var Temp: CString;
begin
  Temp := s;
  if Temp <> nil then
    while Temp^ <> #0 do
      begin
        Temp^ := UpCase (Temp^);
        Inc (Temp)
      end;
  CStringUpCase := s
end;

function CStringLoCase (s: CString): CString;
var Temp: CString;
begin
  Temp := s;
  if Temp <> nil then
    while Temp^ <> #0 do
      begin
        Temp^ := LoCase (Temp^);
        Inc (Temp)
      end;
  CStringLoCase := s
end;

function CStringIsEmpty (s: CString): Boolean;
begin
  CStringIsEmpty := (s = nil) or (s^ = #0)
end;

function NewCString (const Source: String): CString;
var Dest: CString;
begin
  SetReturnAddress (ReturnAddress (0));
  GetMem (Dest, Length (Source) + 1);
  RestoreReturnAddress;
  if Source <> '' then MoveLeft (Source[1], Dest[0], Length (Source));
  Dest[Length (Source)] := #0;
  NewCString := Dest
end;

function CStringCopyString (Dest: CString; const Source: String): CString;
begin
  if Source <> '' then MoveLeft (Source[1], Dest[0], Length (Source));
  Dest[Length (Source)] := #0;
  CStringCopyString := Dest
end;

procedure CopyCString (Source: CString; var Dest: String);
var Source_Length: SizeType;
begin
  if Source = nil then
    SetLength (Dest, 0)
  else
    begin
      Source_Length := Min (CStringLength (Source), Dest.Capacity);
      SetLength (Dest, Source_Length);
      if Source_Length <> 0 then MoveLeft (Source[0], Dest[1], Source_Length)
    end
end;

function NewString (const s: String) = Result: PString;
begin
  SetReturnAddress (ReturnAddress (0));
  New (Result, Max (1, Length (s)));
  RestoreReturnAddress;
  Result^ := s
end;

procedure SetString (var s: String; Buffer: PChar; Count: Integer);
var i: Integer;
begin
  SetLength (s, Min (s.Capacity, Max (0, Min (Count, CStringLength (Buffer)))));
  if Buffer <> nil then
    for i := 1 to { @@ result of SetLength } Length (s) do s[i] := Buffer[i - 1]
end;

function StringOfChar (ch: Char; Count: Integer) = s: TString;
var i: Integer;
begin
  SetLength (s, Min (s.Capacity, Max (0, Count)));
  for i := 1 to { @@ result of SetLength } Length (s) do s[i] := ch
end;

procedure TrimLeft (var s: String);
var i: Integer;
begin
  i := 1;
  while (i <= Length (s)) and (s[i] in SpaceCharacters) do Inc (i);
  Delete (s, 1, i - 1)
end;

procedure TrimRight (var s: String);
var i: Integer;
begin
  i := Length (s);
  while (i > 0) and (s[i] in SpaceCharacters) do Dec (i);
  Delete (s, i + 1)
end;

procedure TrimBoth (var s: String);
begin
  TrimLeft (s);
  TrimRight (s)
end;

function TrimLeftStr (const s: String) = Result: TString;
begin
  Result := s;
  TrimLeft (Result)
end;

function TrimRightStr (const s: String) = Result: TString;
begin
  Result := s;
  TrimRight (Result)
end;

function TrimBothStr (const s: String) = Result: TString;
begin
  Result := s;
  TrimBoth (Result)
end;

function GetStringCapacity (const s: String): Integer;
begin
  GetStringCapacity := s.Capacity
end;

function Integer2String (i: Integer) = s: Str64;
begin
  WriteStr (s, i)
end;

function Integer2StringBase (n: LongestInt; Base: TInteger2StringBase): TString;
begin
  Integer2StringBase := Integer2StringBaseExt (n, Base, 0, False, False)
end;

function Integer2StringBaseExt (n: LongestInt; Base: TInteger2StringBase; Width: TInteger2StringWidth; Upper: Boolean; PrintBase: Boolean): TString;
var
  l, i, Start, Final, AuxWidth: Integer;
  AbsN: LongestCard;
  Neg: Boolean;
  s: array [1 .. TStringSize] of Char;
begin
  AuxWidth := 0;
  if PrintBase then
    begin
      Inc (AuxWidth);
      i := Base;
      repeat
        Inc (AuxWidth);
        i := i div 10
      until i = 0
    end;
  Neg := n < 0;
  if Neg then
    begin
      AbsN := {$local R-} -n {$endlocal};
      Inc (AuxWidth)
    end
  else
    AbsN := n;
  l := Max (BitSizeOf (LongestInt) + AuxWidth, Width);
  Final := l;
  FillChar (s, l, '0');
  case Base of
     2:  repeat
           s[l] := Succ ('0', AbsN mod 2);
           AbsN := AbsN div 2;
           Dec (l)
         until (AbsN = 0) or (l = 0);
     8:  repeat
           s[l] := Succ ('0', AbsN mod 8);
           AbsN := AbsN div 8;
           Dec (l)
         until (AbsN = 0) or (l = 0);
    16:  repeat
           if Upper then
             s[l] := NumericBaseDigitsUpper[AbsN mod 16]
           else
             s[l] := NumericBaseDigits[AbsN mod 16];
           AbsN := AbsN div 16;
           Dec (l)
         until (AbsN = 0) or (l = 0);
    else repeat
           if Upper then
             s[l] := NumericBaseDigitsUpper[AbsN mod Base]
           else
             s[l] := NumericBaseDigits[AbsN mod Base];
           AbsN := AbsN div Base;
           Dec (l)
         until (AbsN = 0) or (l = 0)
  end;
  Assert (AbsN = 0);
  Assert (l >= AuxWidth);
  Start := Min (Final - (Width - AuxWidth), l);
  if PrintBase then
    begin
      s[Start] := '#';
      Dec (Start);
      i := Base;
      repeat
        s[Start] := Succ ('0', i mod 10);
        Dec (Start);
        i := i div 10
      until i = 0
    end;
  if Neg then
    begin
      s[Start] := '-';
      Dec (Start)
    end;
  Assert (Start >= 0);
  Return s[Start + 1 .. Final]
end;

function StrEQ (const s1, s2: String): Boolean;
begin
  StrEQ := (Length (s1) = Length (s2)) and ((s1 = '') or (MemComp (s1[1], s2[1], Length (s1)) = 0))
end;

function StrLT (const s1, s2: String): Boolean;
begin
  if Length (s1) < Length (s2) then
    StrLT := (s1 = '') or (MemComp (s1[1], s2[1], Length (s1)) <= 0)
  else
    StrLT := (s2 <> '') and (MemComp (s1[1], s2[1], Length (s2)) < 0)
end;

function StrEQPad (const s1, s2: String) = Result: Boolean;
var
  c: Integer;
  pLong, pShort: ^const String;
begin
  if Length (s1) > Length (s2) then
    begin
      pLong  := @s1;
      pShort := @s2
    end
  else
    begin
      pLong  := @s2;
      pShort := @s1
    end;
  Result := (Length (pShort^) = 0) or (MemComp (s1[1], s2[1], Length (pShort^)) = 0);
  if Result and (Length (s1) <> Length (s2)) then
    for c := Length (pShort^) + 1 to Length (pLong^) do
      if pLong^[c] <> ' ' then Return False
end;

function StrLTPad (const s1, s2: String): Boolean;
var
  s1IsLonger: Boolean;
  c, r: Integer;
  pLong, pShort: ^const String;
begin
  s1IsLonger := Length (s1) > Length (s2);
  if s1IsLonger then
    begin
      pLong  := @s1;
      pShort := @s2
    end
  else
    begin
      pLong  := @s2;
      pShort := @s1
    end;
  if Length (pShort^) = 0 then
    r := 0
  else
    r := MemComp (s1[1], s2[1], Length (pShort^));
  if (r <> 0) or (Length (s1) = Length (s2)) then Return r < 0;
  for c := Length (pShort^) + 1 to Length (pLong^) do
    if pLong^[c] <> ' ' then Return (pLong^[c] > ' ') xor s1IsLonger;
  StrLTPad := False
end;

end.
