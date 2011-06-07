{ Some utility routines for compatibility to some units available
  for BP, like some `Turbo Power' units.

  @@NOTE - SOME OF THE ROUTINES IN THIS UNIT MAY NOT WORK CORRECTLY.
  TEST CAREFULLY AND USE WITH CARE!

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Authors: Prof. Abimbola A. Olowofoyeku <African_Chief@bigfoot.com>
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
{$if __GPC_RELEASE__ < 20030412}
{$error This unit requires GPC release 20030412 or newer.}
{$endif}

module GPCUtil;

export GPCUtil = all
       (
        { Return the current working directory }
        GetCurrentDirectory => ThisDirectory,

        { Does a directory exist? }
        DirectoryExists => IsDirectory,

        { Does file name s exist? }
        FileExists => ExistFile,

        { Return just the directory path of Path. Returns
          DirSelf + DirSeparator if Path contains no directory. }
        DirFromPath => JustPathName,

        { Return just the file name part without extension of Path.
          Empty if Path contains no file name. }
        NameFromPath => JustFileName,

        { Return just the extension of Path. Empty if Path contains
          no extension. }
        ExtFromPath => JustExtension,

        { Return the full pathname of Path }
        FExpand => FullPathName,

        { Add a DirSeparator to the end of s if there is not
          already one. }
        ForceAddDirSeparator => AddBackSlash,

        { Return a string stripped of leading spaces }
        TrimLeftStr => TrimLead,

        { Return a string stripped of trailing spaces }
        TrimRightStr => TrimTrail,

        { Return a string stripped of leading and trailing spaces }
        TrimBothStr => Trim,

        { Convert a string to lowercase }
        LoCaseStr => StLoCase,

        { Convert a string to uppercase }
        UpCaseStr => StUpCase
       );

import GPC;

{ Replace all occurences of OldC with NewC in s and return the
  result }
function  ReplaceChar (const s: String; OldC, NewC: Char) = Res: TString;

{ Break a string into 2 parts, using Ch as a marker }
function  BreakStr (const Src: String; var Dest1, Dest2: String; ch: Char): Boolean; attribute (ignorable);

{ Convert a CString to an Integer }
function  PChar2Int (s: CString) = i: Integer;

{ Convert a CString to a LongInt }
function  PChar2Long (s: CString) = i: LongInt;

{ Convert a CString to a Double }
function  PChar2Double (s: CString) = x: Double;

{ Search for s as an executable in the path and return its location
  (full pathname) }
function  PathLocate (const s: String): TString;

{ Copy file Src to Dest and return the number of bytes written }
function  CopyFile (const Src, Dest: String; BufSize: Integer): LongInt; attribute (ignorable);

{ Copy file Src to Dest and return the number of bytes written;
  report the number of bytes written versus total size of the source
  file }
function  CopyFileEx (const Src, Dest: String; BufSize: Integer;
  function Report (Reached, Total: LongInt): LongInt) = BytesCopied: LongInt; attribute (ignorable);

{ Turbo Power compatibility }

{ Execute the program prog. Dummy1 and Dummy2 are for compatibility
  only; they are ignored. }
function  ExecDos (const Prog: String; Dummy1: Boolean; Dummy2: Pointer): Integer; attribute (ignorable);

{ Return whether Src exists in the path as an executable -- if so
  return its full location in Dest }
function  ExistOnPath (const Src: String; var Dest: String) = Existing: Boolean;

{ Change the extension of s to Ext (do not include the dot!) }
function  ForceExtension (const s, Ext: String) = Res: TString;

{ Convert Integer to PChar; uses NewCString to allocate memory for
  the result, so you must call StrDispose to free the memory later }
function  Int2PChar (i: Integer): PChar;

{ Convert Integer to string }
function  Int2Str (i: Integer) = s: TString;

{ Convert string to Integer }
function  Str2Int (const s: String; var i: Integer): Boolean; attribute (ignorable);

{ Convert string to LongInt }
function  Str2Long (const s: String; var i: LongInt): Boolean; attribute (ignorable);

{ Convert string to Double }
function  Str2Real (const s: String; var i: Double): Boolean; attribute (ignorable);

{ Return a string right-padded to length Len with ch }
function  PadCh (const s: String; ch: Char; Len: Integer) = Padded: TString;

{ Return a string right-padded to length Len with spaces }
function  Pad (const s: String; Len: Integer): TString;

{ Return a string left-padded to length Len with ch }
function  LeftPadCh (const s: String; ch: Char; Len: Byte) = Padded: TString;

{ Return a string left-padded to length Len with blanks }
function  LeftPad (const s: String; Len: Integer): TString;

{ Uniform access to big memory blocks for GPC and BP. Of course, for
  programs that are meant only for GPC, you can use the usual
  New/Dispose routines. But for programs that should compile with
  GPC and BP, you can use the following routines for GPC. In the GPC
  unit for BP (gpc-bp.pas), you can find emulations for BP that try
  to provide access to as much memory as possible, despite the
  limitations of BP. The drawback is that this memory cannot be used
  freely, but only with the following moving routines. }

type
  PBigMem = ^TBigMem;
  TBigMem (MaxNumber: SizeType) = record
    { Public fields }
    Number, BlockSize: SizeType;
    Mappable: Boolean;
    { Private fields }
    Pointers: array [1 .. Max (1, MaxNumber)] of ^Byte
  end;

{ Note: the number of blocks actually allocated may be smaller than
  WantedNumber. Check the Number field of the result. }
function  AllocateBigMem (WantedNumber, aBlockSize: SizeType; WantMappable: Boolean) = p: PBigMem;
procedure DisposeBigMem (p: PBigMem);
procedure MoveToBigMem (var Source; p: PBigMem; BlockNumber: SizeType);
procedure MoveFromBigMem (p: PBigMem; BlockNumber: SizeType; var Dest);
{ Maps a big memory block into normal addressable memory and returns
  its address. The memory must have been allocated with
  WantMappable = True. The mapping is only valid until the next
  MapBigMem call. }
function  MapBigMem (p: PBigMem; BlockNumber: SizeType): Pointer;

end;

function PathLocate (const s: String): TString;
begin
  PathLocate := FSearchExecutable (s, GetEnv (PathEnvVar))
end;

function ExistOnPath (const Src: String; var Dest: String) = Existing: Boolean;
begin
  Dest := PathLocate (Src);
  Existing := Dest <> '';
  if Existing then Dest := FExpand (Dest)
end;

function ForceExtension (const s, Ext: String) = Res: TString;
var i: Integer;
begin
  i := LastPos (ExtSeparator, s);
  if (i = 0) or (CharPosFrom (DirSeparators, s, i) <> 0) then
    Res := s
  else
    Res := Copy (s, 1, i - 1);
  if (Ext <> '') and (Ext[1] <> ExtSeparator) then Res := Res + ExtSeparator;
  Res := Res + Ext
end;

function ExecDos (const Prog: String; Dummy1: Boolean; Dummy2: Pointer): Integer;
begin
  Discard (Dummy1);
  Discard (Dummy2);
  ExecDos := Execute (Prog)
end;

function PadCh (const s: String; ch: Char; Len: Integer) = Padded: TString;
begin
  Padded := s;
  if Length (Padded) < Len then Padded := Padded + StringOfChar (ch, Len - Length (Padded))
end;

function Pad (const s: String; Len: Integer): TString;
begin
  Pad := PadCh (s, ' ', Len)
end;

function LeftPadCh (const s: String; ch: Char; Len: Byte) = Padded: TString;
begin
  Padded := s;
  if Length (Padded) < Len then Padded := StringOfChar (ch, Len - Length (Padded)) + Padded
end;

function LeftPad (const s: String; Len: Integer): TString;
begin
  LeftPad := LeftPadCh (s, ' ', Len)
end;

function Int2PChar (i: Integer): PChar;
var s: TString;
begin
  Str (i, s);
  SetReturnAddress (ReturnAddress (0));
  Int2PChar := NewCString (s);
  RestoreReturnAddress
end;

function Int2Str (i: Integer) = s: TString;
begin
  Str (i, s)
end;

function Str2Int (const s: String; var i: Integer): Boolean;
var e: Integer;
begin
  Val (s, i, e);
  Str2Int := e = 0
end;

function Str2Long (const s: String; var i: LongInt): Boolean;
var e: Integer;
begin
  Val (s, i, e);
  Str2Long := e = 0
end;

function Str2Real (const s: String; var i: Double): Boolean;
var e: Integer;
begin
  Val (s, i, e);
  Str2Real := e = 0
end;

function CopyFile (const Src, Dest: String; BufSize: Integer): LongInt;
begin
  CopyFile := CopyFileEx (Src, Dest, BufSize, nil)
end;

function CopyFileEx (const Src, Dest: String; BufSize: Integer;
  function Report (Reached, Total: LongInt): LongInt) = BytesCopied: LongInt;
var
  Size: LongInt;
  Count: Integer;
  SrcFile, DestFile: File;
  Buf: ^Byte;
  b: BindingType;
begin
  Reset (SrcFile, Src, 1);
  if IOResult <> 0 then
    begin
      BytesCopied := -2;
      Exit
    end;
  Rewrite (DestFile, Dest, 1);
  if IOResult <> 0 then
    begin
      Close (SrcFile);
      BytesCopied := -3;
      Exit
    end;
  b := Binding (SrcFile);
  Size := FileSize (SrcFile);
  GetMem (Buf, BufSize);
  BytesCopied := 0;
  repeat
    BlockRead (SrcFile, Buf^, BufSize, Count);
    Inc (BytesCopied, Count);
    if IOResult <> 0 then
      BytesCopied := -100  { Read error }
    else if Count > 0 then
      begin
        BlockWrite (DestFile, Buf^, Count);
        if IOResult <> 0 then
          BytesCopied := -200  { Write error }
        else if Assigned (Report) and_then (Report (BytesCopied, Size) < 0) then
          BytesCopied := -300  { User Abort }
      end
  until (BytesCopied < 0) or (Count = 0);
  FreeMem (Buf);
  Close (SrcFile);
  if BytesCopied >= 0 then
    begin
      SetFileTime (DestFile, GetUnixTime (Null), b.ModificationTime);
      ChMod (DestFile, b.Mode)
    end;
  Close (DestFile)
end;

function BreakStr (const Src: String; var Dest1, Dest2: String; ch: Char): Boolean;
var i: Integer;
begin
  i := Pos (ch, Src);
  BreakStr := i <> 0;
  if i = 0 then i := Length (Src) + 1;
  Dest1 := Trim (Copy (Src, 1, i - 1));
  Dest2 := Trim (Copy (Src, i + 1))
end;

function PChar2Int (s: CString) = i: Integer;
begin
  ReadStr (CString2String (s), i)
end;

function PChar2Long (s: CString) = i: LongInt;
begin
  ReadStr (CString2String (s), i)
end;

function PChar2Double (s: CString) = x: Double;
begin
  ReadStr (CString2String (s), x)
end;

function ReplaceChar (const s: String; OldC, NewC: Char) = Res: TString;
var i: Integer;
begin
  Res := s;
  if OldC <> NewC then
    for i := 1 to Length (Res) do
      if Res[i] = OldC then Res[i] := NewC
end;

function AllocateBigMem (WantedNumber, aBlockSize: SizeType; WantMappable: Boolean) = p: PBigMem;
begin
  SetReturnAddress (ReturnAddress (0));
  New (p, WantedNumber);
  RestoreReturnAddress;
  with p^ do
    begin
      Mappable := WantMappable;
      BlockSize := aBlockSize;
      Number := 0;
      while Number < WantedNumber do
        begin
          Pointers[Number + 1] := CGetMem (BlockSize);
          if Pointers[Number + 1] = nil then Break;
          Inc (Number)
        end
    end
end;

procedure DisposeBigMem (p: PBigMem);
var i: Integer;
begin
  for i := 1 to p^.Number do CFreeMem (p^.Pointers[i]);
  Dispose (p)
end;

procedure MoveToBigMem (var Source; p: PBigMem; BlockNumber: SizeType);
begin
  Move (Source, p^.Pointers[BlockNumber]^, p^.BlockSize)
end;

procedure MoveFromBigMem (p: PBigMem; BlockNumber: SizeType; var Dest);
begin
  Move (p^.Pointers[BlockNumber]^, Dest, p^.BlockSize)
end;

function MapBigMem (p: PBigMem; BlockNumber: SizeType): Pointer;
begin
  if not p^.Mappable then RuntimeError (859);  { attempt to map unmappable memory }
  MapBigMem := p^.Pointers[BlockNumber]
end;

end.
