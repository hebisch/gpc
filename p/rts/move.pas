{ Memory transfer procedures

  Copyright (C) 1997-2006 Free Software Foundation, Inc.

  Authors: Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>

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

unit Move; attribute (name = '_p__rts_Move');

interface

uses Endian;

{ The move operations are built-in identifiers and not declared in
  gpc.pas. }

{@internal}
procedure MoveLeft  (const Source; var Dest; Count: SizeType); attribute (name = '_p_MoveLeft');
procedure MoveRight (const Source; var Dest; Count: SizeType); attribute (name = '_p_MoveRight');
procedure Move      (const Source; var Dest; Count: SizeType); attribute (name = '_p_Move');
{@endinternal}

implementation

type
  PByte = ^Byte;
  PConstByte = ^const Byte;
  TWord = MedWord;
  PWord = ^TWord;
  PConstWord = ^const TWord;
  TWords = array [0 .. 7] of TWord;
  PWords = ^TWords;
  PConstWords = ^const TWords;

{$R-}

function Merge (w1, w2: TWord; Shift1, Shift2: Integer): TWord; attribute (inline);
begin
  if BytesBigEndian then
    Merge := (w1 shl Shift1) or (w2 shr Shift2)
  else
    Merge := (w1 shr Shift1) or (w2 shl Shift2)
end;

{$pointer-arithmetic}

procedure MoveLeft (const Source; var Dest; Count: SizeType);
var
  pSrc: PConstByte;
  pDst: PByte;
  SrcWord: PConstWord absolute pSrc;
  DstWord: PWord absolute pDst;
  SrcWords: PConstWords absolute pSrc;
  DstWords: PWords absolute pDst;
  Align, SrcAlign, Words: SizeType;
  Shift1, Shift2: Integer;
  LastVal, ThisVal: TWord;
begin
  pSrc := @Source;
  pDst := @Dest;
  if (Count >= SizeOf (LongestCard)) and not (pDst - pSrc in [0 .. 2 * SizeOf (TWord) - 1]) then
    begin
      Align := PtrCard (-PtrInt (pDst)) mod SizeOf (TWord);
      Dec (Count, Align);
      while Align > 0 do
        begin
          pDst^ := pSrc^;
          Inc (pSrc);
          Inc (pDst);
          Dec (Align)
        end;
      SrcAlign := PtrCard (pSrc) mod SizeOf (TWord);
      if NeedAlignment and (SrcAlign <> 0) then
        begin
          Dec (pSrc, SrcAlign);
          Shift1 := SrcAlign * BitSizeOf (Byte);
          Shift2 := BitSizeOf (TWord) - Shift1;
          LastVal := SrcWord^;
          Inc (SrcWord);
          Words := Count div SizeOf (TWord);
          while Words > 0 do
            begin
              ThisVal := SrcWord^;
              DstWord^ := Merge (LastVal, ThisVal, Shift1, Shift2);
              LastVal := ThisVal;
              Inc (SrcWord);
              Inc (DstWord);
              Dec (Words)
            end;
          Dec (SrcWord);
          Inc (pSrc, SrcAlign);
          Count := Count mod SizeOf (TWord)
        end
      else
        begin
          Words := Count div SizeOf (TWords);
          while Words > 0 do
            begin
              DstWords^[0] := SrcWords^[0];
              DstWords^[1] := SrcWords^[1];
              DstWords^[2] := SrcWords^[2];
              DstWords^[3] := SrcWords^[3];
              DstWords^[4] := SrcWords^[4];
              DstWords^[5] := SrcWords^[5];
              DstWords^[6] := SrcWords^[6];
              DstWords^[7] := SrcWords^[7];
              Inc (SrcWords);
              Inc (DstWords);
              Dec (Words)
            end;
          Count := Count mod SizeOf (TWords)
        end
    end;
  while Count > 0 do
    begin
      pDst^ := pSrc^;
      Inc (pSrc);
      Inc (pDst);
      Dec (Count)
    end
end;

procedure MoveRight (const Source; var Dest; Count: SizeType);
var
  pSrc: PConstByte;
  pDst: PByte;
  SrcWord: PConstWord absolute pSrc;
  DstWord: PWord absolute pDst;
  SrcWords: PConstWords absolute pSrc;
  DstWords: PWords absolute pDst;
  Align, SrcAlign, Words: SizeType;
  Shift1, Shift2: Integer;
  LastVal, ThisVal: TWord;
begin
  pSrc := Succ (PConstByte (@Source), Count);
  pDst := Succ (PByte (@Dest), Count);
  if (Count >= SizeOf (LongestCard)) and not (pSrc - pDst in [0 .. 2 * SizeOf (TWord) - 1]) then
    begin
      Align := PtrCard (pDst) mod SizeOf (TWord);
      Dec (Count, Align);
      while Align > 0 do
        begin
          Dec (pSrc);
          Dec (pDst);
          pDst^ := pSrc^;
          Dec (Align)
        end;
      SrcAlign := PtrCard (pSrc) mod SizeOf (TWord);
      if NeedAlignment and (SrcAlign <> 0) then
        begin
          Dec (pSrc, SrcAlign);
          Shift1 := SrcAlign * BitSizeOf (Byte);
          Shift2 := BitSizeOf (TWord) - Shift1;
          LastVal := SrcWord^;
          Words := Count div SizeOf (TWord);
          while Words > 0 do
            begin
              Dec (SrcWord);
              Dec (DstWord);
              ThisVal := SrcWord^;
              DstWord^ := Merge (ThisVal, LastVal, Shift1, Shift2);
              LastVal := ThisVal;
              Dec (Words)
            end;
          Inc (pSrc, SrcAlign);
          Count := Count mod SizeOf (TWord)
        end
      else
        begin
          Words := Count div SizeOf (TWords);
          while Words > 0 do
            begin
              Dec (SrcWords);
              Dec (DstWords);
              DstWords^[7] := SrcWords^[7];
              DstWords^[6] := SrcWords^[6];
              DstWords^[5] := SrcWords^[5];
              DstWords^[4] := SrcWords^[4];
              DstWords^[3] := SrcWords^[3];
              DstWords^[2] := SrcWords^[2];
              DstWords^[1] := SrcWords^[1];
              DstWords^[0] := SrcWords^[0];
              Dec (Words)
            end;
          Count := Count mod SizeOf (TWords)
        end
    end;
  while Count > 0 do
    begin
      Dec (pSrc);
      Dec (pDst);
      pDst^ := pSrc^;
      Dec (Count)
    end
end;

procedure Move (const Source; var Dest; Count: SizeType);
begin
  if PtrCard (@Source) < PtrCard (@Dest) then
    MoveRight (Source, Dest, Count)
  else
    MoveLeft (Source, Dest, Count)
end;

end.
