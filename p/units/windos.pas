{ Mostly BP compatible portable WinDos unit

  This unit supports most, but not all, of the routines and
  declarations of BP's WinDos unit.

  Notes:

  - The procedures GetIntVec and SetIntVec are not supported since
    they make only sense for Dos real-mode programs (and GPC
    compiled programs do not run in real-mode, even on IA32 under
    Dos). The procedures Intr and MsDos are only supported under
    DJGPP if `__BP_UNPORTABLE_ROUTINES__' is defined (with the
    `-D__BP_UNPORTABLE_ROUTINES__' option). A few other routines are
    also only supported with this define, but on all platforms (but
    they are crude hacks, that's why they are not supported without
    this define).

  - The internal structure of file variables (TFileRec and TTextRec)
    is different in GPC. However, as far as TFDDs are concerned,
    there are other ways to achieve the same in GPC, see the GPC
    unit.

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

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

{$gnu-pascal,I-,maximum-field-alignment 0}
{$if __GPC_RELEASE__ < 20030412}
{$error This unit requires GPC release 20030412 or newer.}
{$endif}

module WinDos;

export WinDos = all (FCarry, FParity, FAuxiliary, FZero, FSign, FOverflow,
                     DosError, GetDate, GetTime, GetCBreak, SetCBreak,
                     GetVerify, SetVerify, DiskFree, DiskSize,
                     GetFAttr, SetFAttr, GetFTime, SetFTime,
                     UnpackTime, PackTime,
                     {$ifdef __BP_UNPORTABLE_ROUTINES__}
                     {$ifdef __GO32__}
                     Intr, MsDos,
                     {$endif}
                     DosVersion, SetDate, SetTime,
                     {$endif}
                     CStringGetEnv => GetEnvVar);

import GPC (MaxLongInt => GPC_Orig_MaxLongInt);
       System;
       Dos (FindFirst => Dos_FindFirst,
            FindNext  => Dos_FindNext,
            FindClose => Dos_FindClose);

const
  { File attribute constants }
  faReadOnly  = ReadOnly;
  faHidden    = Hidden;    { set for dot files except `.' and `..' }
  faSysFile   = SysFile;   { not supported }
  faVolumeID  = VolumeID;  { not supported }
  faDirectory = Directory;
  faArchive   = Archive;   { means: not executable }
  faAnyFile   = AnyFile;

  { Maximum file name component string lengths }
  fsPathName  = 79;
  fsDirectory = 67;
  fsFileName  = 8;
  fsExtension = 4;

  { FileSplit return flags }
  fcExtension = 1;
  fcFileName  = 2;
  fcDirectory = 4;
  fcWildcards = 8;

type
  PTextBuf = ^TTextBuf;
  TTextBuf = TextBuf;

  { Search record used by FindFirst and FindNext }
  TSearchRec = record
    Fill: SearchRecFill;
    Attr: Byte8;
    Time, Size: LongInt;
    Name: {$ifdef __BP_TYPE_SIZES__}
          packed array [0 .. 12] of Char
          {$else}
          TStringBuf
          {$endif};
    Reserved: SearchRec
  end;

  { Date and time record used by PackTime and UnpackTime }
  TDateTime = DateTime;

  { 8086 CPU registers -- only used by the unportable Dos routines }
  TRegisters = Registers;

{ FindFirst and FindNext are quite inefficient since they emulate
  all the brain-dead Dos stuff. If at all possible, the standard
  routines OpenDir, ReadDir and CloseDir (in the GPC unit) should be
  used instead. }
procedure FindFirst (Path: PChar; Attr: Word; var SR: TSearchRec);
procedure FindNext  (var SR: TSearchRec);
procedure FindClose (var SR: TSearchRec);
function  FileSearch (Dest, FileName, List: PChar): PChar;
function  FileExpand (Dest, FileName: PChar): PChar;
function  FileSplit (Path, Dir, BaseName, Ext: PChar) = Res: Word;
function  GetCurDir (Dir: PChar; Drive: Byte): PChar;
procedure SetCurDir (Dir: PChar);
procedure CreateDir (Dir: PChar);
procedure RemoveDir (Dir: PChar);
function  GetArgCount: Integer;
function  GetArgStr (Dest: PChar; ArgIndex: Integer; MaxLen: Word): PChar;

end;

procedure ConvertSearchRec (var SR: TSearchRec);
begin
  SR.Attr := SR.Reserved.Attr;
  SR.Time := SR.Reserved.Time;
  SR.Size := SR.Reserved.Size;
  SR.Name := SR.Reserved.Name + #0
end;

procedure FindFirst (Path: PChar; Attr: Word; var SR: TSearchRec);
begin
  SetReturnAddress (ReturnAddress (0));
  Dos_FindFirst (CString2String (Path), Attr, SR.Reserved);
  RestoreReturnAddress;
  if DosError = 0 then ConvertSearchRec (SR)
end;

procedure FindNext (var SR: TSearchRec);
begin
  SetReturnAddress (ReturnAddress (0));
  Dos_FindNext (SR.Reserved);
  RestoreReturnAddress;
  if DosError = 0 then ConvertSearchRec (SR)
end;

procedure FindClose (var SR: TSearchRec);
begin
  Dos_FindClose (SR.Reserved)
end;

function FileSearch (Dest, FileName, List: PChar): PChar;
begin
  FileSearch := CStringLCopy (Dest, FSearch (CString2String (FileName), CString2String (List)), fsPathName)
end;

function FileExpand (Dest, FileName: PChar): PChar;
begin
  FileExpand := CStringLCopy (Dest, FExpand (CString2String (FileName)), fsPathName)
end;

function FileSplit (Path, Dir, BaseName, Ext: PChar) = Res: Word;
var
  d: DirStr;
  n: NameStr;
  e: ExtStr;
begin
  FSplit (CString2String (Path), d, n, e);
  if Dir      <> nil then Discard (CStringCopy (Dir, d));
  if BaseName <> nil then Discard (CStringCopy (BaseName, n));
  if Ext      <> nil then Discard (CStringCopy (Ext, e));
  Res := 0;
  if d <> '' then Inc (Res, fcDirectory);
  if n <> '' then Inc (Res, fcFileName);
  if e <> '' then Inc (Res, fcExtension);
  if HasWildCards (n + e) then Inc (Res, fcWildcards)
end;

function GetCurDir (Dir: PChar; Drive: Byte): PChar;
var Path: String (2);
begin
  if Drive = 0 then
    Path := DirSelf
  else
    Path := Succ ('a', Drive - 1) + ':';
  GetCurDir := CStringLCopy (Dir, FExpand (Path), fsDirectory)
end;

procedure SetCurDir (Dir: PChar);
begin
  ChDir (CString2String (Dir))
end;

procedure CreateDir (Dir: PChar);
begin
  MkDir (CString2String (Dir))
end;

procedure RemoveDir (Dir: PChar);
begin
  RmDir (CString2String (Dir))
end;

function GetArgCount: Integer;
begin
  GetArgCount := ParamCount
end;

function GetArgStr (Dest: PChar; ArgIndex: Integer; MaxLen: Word): PChar;
begin
  GetArgStr := CStringLCopy (Dest, ParamStr (ArgIndex), MaxLen)
end;

end.
