{ Set operations

  Sets are stored as bitmaps consisting of TSetElement's. They
  contain bits for the set's range plus possibly padding at either
  or both ends Thus, there may be unused bits in front and after the
  end of otherwise contiquous bit vector that represents all the
  elements of the set.

  No type checking is done here. It's left to the compiler.
  Results are silently truncated.

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

unit Sets; attribute (name = '_p__rts_Sets');

interface

uses RTSC, Error;

{ All set operations are built-in identifiers and not declared in
  gpc.pas. }

{@internal}
type
  TSetElement = MedCard;  { must be an unsigned type }
  PSet = ^TSet;
  TSet = array [0 .. MaxVarSize div SizeOf (TSetElement) - 1] of TSetElement;

function  SetCard                (SetA: PSet; LowA, HighA: Integer) = Count: Integer;                                                    attribute (name = '_p_Card');
function  SetIsEmpty             (SetA: PSet; LowA, HighA: Integer): Boolean;                                                            attribute (name = '_p_Set_IsEmpty');
function  SetEqual               (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer): Boolean;                          attribute (name = '_p_Set_Equal');
function  SetLessEqual           (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer): Boolean;                          attribute (name = '_p_Set_LE');
function  SetLess                (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer): Boolean;                          attribute (name = '_p_Set_Less');
function  SetIn                  (SetA: PSet; LowA, HighA, Element: Integer): Boolean;                                                   attribute (name = '_p_Set_In');
procedure SetClear               (SetR: PSet; LowR, HighR: Integer);                                                                     attribute (name = '_p_Set_Clear');
procedure SetInclude             (SetR: PSet; LowR, HighR, Element: Integer);                                                            attribute (name = '_p_Include');
procedure SetExclude             (SetR: PSet; LowR, HighR, Element: Integer);                                                            attribute (name = '_p_Exclude');
function  SetIncludeRange        (SetR: PSet; LowR, HighR, RangeFirst, RangeLast: Integer): Boolean;                                     attribute (name = '_p_Set_IncludeRange');
procedure SetCopy                (SetA: PSet; LowA, HighA: Integer; SetR: PSet; LowR, HighR: Integer);                                   attribute (name = '_p_Set_Copy');
procedure SetIntersection        (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer; SetR: PSet; LowR, HighR: Integer); attribute (name = '_p_Set_Intersection');
procedure SetUnion               (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer; SetR: PSet; LowR, HighR: Integer); attribute (name = '_p_Set_Union');
procedure SetDifference          (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer; SetR: PSet; LowR, HighR: Integer); attribute (name = '_p_Set_Diff');
procedure SetSymmetricDifference (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer; SetR: PSet; LowR, HighR: Integer); attribute (name = '_p_Set_SymDiff');
procedure SetRangeCheck          (SetA: PSet; LowA, HighA: Integer; LowB, HighB: Integer);                                               attribute (name = '_p_Set_RangeCheck');
procedure SetIncludeBits         (SetA: PSet; BitLength: MedCard; RangeFirst, RangeLast: MedInt);                                        attribute (name = '__setbits');
{@endinternal}

implementation

{$R-}

const
  BitsPerElement = BitSizeOf (TSetElement);
  AllBitsSet = not TSetElement (0);
  TempTypeCount = BitSizeOf (LongestInt);

type
  TempType = packed array [1 .. TempTypeCount] of 0 .. BitsPerElement - 1;

const
  Log2BitsPerElement = BitSizeOf (TempType) div TempTypeCount;  {:-}
  Dummy = CompilerAssert (2 pow Log2BitsPerElement = BitsPerElement);

{ Returns the word number in which the n'th member is in when starting from 0 }
function WordNumberAbs (n: Integer): Integer; attribute (inline);
begin
  { Note: `shr Log2BitsPerElement' does not do the same as
    `div BitsPerElement'! For negative numbers, `shr' round towards minus
    infinity (which we want here) while `div' would round towards 0. }
  WordNumberAbs := n shr Log2BitsPerElement
end;

{ Returns the bit number in WordNumber in which the n'th member is }
function BitNumber (n: Integer): Integer; attribute (inline);
begin
  BitNumber := n and (BitsPerElement - 1)
end;

{ Returns the word number from start of set in which the n'th member is.
  If n is the high limit of the set, this is the last word of the set. }
function WordNumber (n, LowA: Integer): Integer; attribute (inline);
begin
  WordNumber := WordNumberAbs (n) - WordNumberAbs (LowA)
end;

{ Returns the number of words needed to adjust set A to B }
function VectorAdjust (LowA, LowB: Integer): Integer; attribute (inline);
begin
  VectorAdjust := WordNumberAbs (LowB) - WordNumberAbs (LowA)
end;

procedure ClearOutside (SetA: PSet; LowA, HighA, LeaveFirst, LeaveLast: Integer);
var LeaveFirstWord, LeaveLastWord, i: Integer;
begin
  LeaveFirstWord := WordNumber (LeaveFirst, LowA);
  LeaveLastWord := WordNumber (LeaveLast + 1, LowA);
  for i := 0 to LeaveFirstWord - 1 do SetA^[i] := 0;
  if LeaveFirstWord >= 0 then
    and (SetA^[LeaveFirstWord], AllBitsSet shl BitNumber (LeaveFirst));
  for i := LeaveLastWord + 1 to WordNumber (HighA, LowA) do SetA^[i] := 0;
  if LeaveLastWord <= WordNumber (HighA, LowA) then
    and (SetA^[LeaveLastWord], not (AllBitsSet shl BitNumber (LeaveLast + 1)))
end;

function SetIncludeRange (SetR: PSet; LowR, HighR, RangeFirst, RangeLast: Integer): Boolean;
var RangeFirstWord, RangeLastWord, i: Integer;
begin
  if RangeFirst > RangeLast then
    begin
      SetIncludeRange := True;
      Exit
    end;
  SetIncludeRange := (RangeFirst >= LowR) and (RangeFirst <= HighR) and
                     (RangeLast  >= LowR) and (RangeLast  <= HighR);
  RangeFirstWord := WordNumber (RangeFirst, LowR);
  RangeLastWord := WordNumber (RangeLast + 1, LowR);
  if RangeFirstWord = RangeLastWord then
    or (SetR^[RangeFirstWord], (AllBitsSet shl BitNumber (RangeFirst)) and not (AllBitsSet shl BitNumber (RangeLast + 1)))
  else
    begin
      if RangeFirstWord >= 0 then
        or (SetR^[RangeFirstWord], AllBitsSet shl BitNumber (RangeFirst));
      for i := Max (0, RangeFirstWord + 1) to Min (RangeLastWord - 1, WordNumber (HighR, LowR)) do SetR^[i] := AllBitsSet;
      if RangeLastWord <= WordNumber (HighR, LowR) then
        or (SetR^[RangeLastWord], not (AllBitsSet shl BitNumber (RangeLast + 1)))
    end
end;

function SetCard (SetA: PSet; LowA, HighA: Integer) = Count: Integer;
const
  BitsSet: array [0 .. 255] of ByteInt =
    (0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
     1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
     1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
     2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
     3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8);
var
  i: Integer;
  Element: TSetElement;
begin
  Count := 0;
  for i := 0 to WordNumber (HighA, LowA) do
    begin
      Element := SetA^[i];
      while Element <> 0 do
        begin
          Inc (Count, BitsSet[Element and $ff]);
          Element := Element shr 8
        end
    end
end;

function SetIsEmpty (SetA: PSet; LowA, HighA: Integer): Boolean;
var i: Integer;
begin
  for i := 0 to WordNumber (HighA, LowA) do
    if SetA^[i] <> 0 then Return False;
  SetIsEmpty := True
end;

function SetEqual (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer): Boolean;
var
  SetT: PSet;
  Temp, a, i, wa, wb: Integer;
begin
  if (LowA > HighB) or (LowB > HighA) then
    SetEqual := SetIsEmpty (SetA, LowA, HighA) and SetIsEmpty (SetB, LowB, HighB)
  else
    begin
      SetEqual := False;
      if WordNumberAbs (LowA) > WordNumberAbs (LowB) then
        begin
          Temp := LowA;  LowA  := LowB;  LowB  := Temp;
          Temp := HighA; HighA := HighB; HighB := Temp;
          SetT := SetA;  SetA  := SetB;  SetB  := SetT
        end;
      a := VectorAdjust (LowA, LowB);
      wa := WordNumber (HighA, LowA);
      wb := WordNumber (HighB, LowB);
      for i := 0 to a - 1 do
        if SetA^[i] <> 0 then Exit;
      for i := 0 to Min (wa - a, wb) do
        if SetA^[i + a] <> SetB^[i] then Exit;
      for i := wa - a + 1 to wb do
        if SetB^[i] <> 0 then Exit;
      for i := wb + a + 1 to wa do
        if SetA^[i] <> 0 then Exit;
      SetEqual := True
    end
end;

function SetLessEqual (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer): Boolean;
var a, i, wa, wb: Integer;
begin
  if (LowA > HighB) or (LowB > HighA) then
    SetLessEqual := SetIsEmpty (SetA, LowA, HighA)
  else
    begin
      SetLessEqual := False;
      wa := WordNumber (HighA, LowA);
      wb := WordNumber (HighB, LowB);
      if WordNumberAbs (LowA) > WordNumberAbs (LowB) then
        begin
          a := VectorAdjust (LowB, LowA);
          for i := wb - a + 1 to wa do
            if SetA^[i] <> 0 then Exit;
          for i := 0 to Min (wb - a, wa) do
            if (SetA^[i] and not SetB^[i + a]) <> 0 then Exit
        end
      else
        begin
          a := VectorAdjust (LowA, LowB);
          for i := 0 to a - 1 do
            if SetA^[i] <> 0 then Exit;
          for i := 0 to Min (wa - a, wb) do
            if (SetA^[i + a] and not SetB^[i]) <> 0 then Exit;
          for i := wb + a + 1 to wa do
            if SetA^[i] <> 0 then Exit;
        end;
      SetLessEqual := True
    end
end;

function SetLess (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer): Boolean;
begin
  SetLess := SetLessEqual (SetA, LowA, HighA, SetB, LowB, HighB) and
             not SetEqual (SetA, LowA, HighA, SetB, LowB, HighB)
end;

function SetIn (SetA: PSet; LowA, HighA, Element: Integer): Boolean;
begin
  SetIn := (Element >= LowA) and (Element <= HighA) and
    ((SetA^[WordNumber (Element, LowA)] and (1 shl BitNumber (Element))) <> 0)
end;

procedure SetClear (SetR: PSet; LowR, HighR: Integer);
var i: Integer;
begin
  for i := 0 to WordNumber (HighR, LowR) do SetR^[i] := 0
end;

procedure SetInclude (SetR: PSet; LowR, HighR, Element: Integer);
begin
  if (Element >= LowR) and (Element <= HighR) then
    or (SetR^[WordNumber (Element, LowR)], 1 shl BitNumber (Element))
end;

procedure SetExclude (SetR: PSet; LowR, HighR, Element: Integer);
begin
  if (Element >= LowR) and (Element <= HighR) then
    and (SetR^[WordNumber (Element, LowR)], not (1 shl BitNumber (Element)))
end;

procedure SetCopy (SetA: PSet; LowA, HighA: Integer; SetR: PSet; LowR, HighR: Integer);
var a, i: Integer;
begin
  a := VectorAdjust (LowA, LowR);
  for i := Max (0, -a) to Min (WordNumber (HighR, LowR), WordNumber (HighA, LowA) - a) do SetR^[i] := SetA^[i + a];
  ClearOutside (SetR, LowR, HighR, LowA, HighA)
end;

procedure SetIntersection (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer; SetR: PSet; LowR, HighR: Integer);
var a, i: Integer;
begin
  if (LowA > HighB) or (HighA < LowB) then
    SetClear (SetR, LowR, HighR)
  else
    begin
      SetCopy (SetA, LowA, HighA, SetR, LowR, HighR);
      a := VectorAdjust (LowB, LowR);
      for i := Max (0, -a) to Min (WordNumber (HighR, LowR), WordNumber (HighB, LowB) - a) do
        and (SetR^[i], SetB^[i + a]);
      ClearOutside (SetR, LowR, HighR, LowB, HighB)
    end
end;

procedure SetUnion (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer; SetR: PSet; LowR, HighR: Integer);
var a, i: Integer;
begin
  SetCopy (SetA, LowA, HighA, SetR, LowR, HighR);
  a := VectorAdjust (LowB, LowR);
  for i := Max (0, -a) to Min (WordNumber (HighR, LowR), WordNumber (HighB, LowB) - a) do
    or (SetR^[i], SetB^[i + a])
end;

procedure SetDifference (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer; SetR: PSet; LowR, HighR: Integer);
var a, i: Integer;
begin
  SetCopy (SetA, LowA, HighA, SetR, LowR, HighR);
  a := VectorAdjust (LowB, LowR);
  for i := Max (0, -a) to Min (WordNumber (HighR, LowR), WordNumber (HighB, LowB) - a) do
    and (SetR^[i], not SetB^[i + a])
end;

procedure SetSymmetricDifference (SetA: PSet; LowA, HighA: Integer; SetB: PSet; LowB, HighB: Integer; SetR: PSet; LowR, HighR: Integer);
var a, i: Integer;
begin
  SetCopy (SetA, LowA, HighA, SetR, LowR, HighR);
  a := VectorAdjust (LowB, LowR);
  for i := Max (0, -a) to Min (WordNumber (HighR, LowR), WordNumber (HighB, LowB) - a) do
    xor (SetR^[i], SetB^[i + a])
end;

procedure SetRangeCheck (SetA: PSet; LowA, HighA: Integer; LowB, HighB: Integer);
var
  LowBWord, HighBWord, i: Integer;
  Flag: Boolean;
begin
  LowBWord := WordNumber (LowB, LowA);
  HighBWord := WordNumber (HighB + 1, LowA);
  Flag := False;
  for i := 0 to LowBWord - 1 do
    if SetA^[i] <> 0 then
      begin
        Flag := True;
        Break
      end;
  if not Flag then
    for i := HighBWord + 1 to WordNumber (HighA, LowA) do
      if SetA^[i] <> 0 then
        begin
          Flag := True;
          Break
        end;
  if Flag
     or ((LowBWord >= 0) and ((SetA^[LowBWord] and not (AllBitsSet shl BitNumber (LowB))) <> 0))
     or ((HighBWord <= WordNumber (HighA, LowA)) and ((SetA^[HighBWord] and (AllBitsSet shl BitNumber (HighB + 1))) <> 0)) then
    begin
      SetReturnAddress (ReturnAddress (0));
      RuntimeError (302);  { set element out of range }
      RestoreReturnAddress
    end
end;

procedure SetIncludeBits (SetA: PSet; BitLength: MedCard; RangeFirst, RangeLast: MedInt);
begin
  if not SetIncludeRange (SetA, 0, BitLength - 1, RangeFirst, RangeLast) then
    begin
      SetReturnAddress (ReturnAddress (0));
      RuntimeError (303);  { range error in set constructor }
      RestoreReturnAddress
    end
end;

end.
