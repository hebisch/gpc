{ Portable BP compatible Dos unit

  This unit supports most of the routines and declarations of BP's
  Dos unit.

  Notes:

  - The procedures Keep, GetIntVec, SetIntVec are not supported
    since they make only sense for Dos real-mode programs (and GPC
    compiled programs do not run in real-mode, even on IA32 under
    Dos). The procedures Intr and MsDos are only supported under
    DJGPP if `__BP_UNPORTABLE_ROUTINES__' is defined (with the
    `-D__BP_UNPORTABLE_ROUTINES__' option). A few other routines are
    also only supported with this define, but on all platforms (but
    they are crude hacks, that's why they are not supported without
    this define).

  - The internal structure of file variables (FileRec and TextRec)
    is different in GPC. However, as far as TFDDs are concerned,
    there are other ways to achieve the same in GPC, see the GPC
    unit.

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Authors: Frank Heckenbach <frank@pascal.gnu.de>
           Prof. Abimbola A. Olowofoyeku <African_Chief@bigfoot.com>

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

module Dos;

{ GPC and this unit use `AnyFile' for different meanings. Export
  renaming helps us to avoid a conflict here. If you use both units,
  the meaning of the latter one will be effective, but you always
  get the built-in meaning by using `GPC_AnyFile'. }
export Dos = all (DosAnyFile => AnyFile, FSearch, FExpand, FSplit, GetEnv);

import GPC (MaxLongInt => GPC_Orig_MaxLongInt); System;

type
  GPC_AnyFile = AnyFile;
  Byte8 = Cardinal attribute (Size = 8);
  Word16 = Cardinal attribute (Size = 16);
  Word32 = Cardinal attribute (Size = 32);
  TDosAttr = Word;

const
  { File attribute constants }
  ReadOnly   = $01;
  Hidden     = $02;  { set for dot files except '.' and '..' }
  SysFile    = $04;  { not supported }
  VolumeID   = $08;  { not supported }
  Directory  = $10;
  Archive    = $20;  { means: not executable }
  DosAnyFile = $3f;

  { Flag bit masks -- only used by the unportable Dos routines }
  FCarry     = 1;
  FParity    = 4;
  FAuxiliary = $10;
  FZero      = $40;
  FSign      = $80;
  FOverflow  = $800;

  { DosError codes }
  DosError_FileNotFound = 2;
  DosError_PathNotFound = 3;
  DosError_AccessDenied = 5;
  DosError_InvalidMem   = 9;
  DosErorr_InvalidEnv   = 10;
  DosError_NoMoreFiles  = 18;
  DosError_IOError      = 29;
  DosError_ReadFault    = 30;

type
  { String types. Not used in this unit, but declared for
    compatibility. }
  ComStr  = String [127];  { Command line string }
  PathStr = String [79];   { File pathname string }
  DirStr  = String [67];   { Drive and directory string }
  NameStr = String [8];    { File name string }
  ExtStr  = String [4];    { File extension string }

  TextBuf = array [0 .. 127] of Char;

  { Search record used by FindFirst and FindNext }
  SearchRecFill = packed array [1 .. 21] of Byte8;
  SearchRec = record
    Fill: SearchRecFill;
    Attr: Byte8;
    Time,
    Size: LongInt;
    Name: {$ifdef __BP_TYPE_SIZES__}
          String [12]
          {$else}
          TString
          {$endif}
  end;

  { Date and time record used by PackTime and UnpackTime }
  DateTime = record
    Year, Month, Day, Hour, Min, Sec: Word
  end;

  { 8086 CPU registers -- only used by the unportable Dos routines }
  Registers = record
  case Boolean of
    False: (ax, bx, cx, dx, bp, si, di, ds, es, Flags: Word16);
    True : (al, ah, bl, bh, cl, ch, dl, dh: Byte8)
  end;

var
  { Error status variable }
  DosError: Integer = 0;

procedure GetDate (var Year, Month, Day, DayOfWeek: Word);
procedure GetTime (var Hour, Minute, Second, Sec100: Word);
procedure GetCBreak (var BreakOn: Boolean);
procedure SetCBreak (BreakOn: Boolean);
{ GetVerify and SetVerify are dummies except for DJGPP (in the
  assumption that any real OS knows by itself when and how to verify
  its disks). }
procedure GetVerify (var VerifyOn: Boolean);
procedure SetVerify (VerifyOn: Boolean);
function  DiskFree (Drive: Byte): LongInt;
function  DiskSize (Drive: Byte): LongInt;
procedure GetFAttr (var f: GPC_AnyFile; var Attr: TDosAttr);
procedure SetFAttr (var f: GPC_AnyFile; Attr: TDosAttr);
procedure GetFTime (var f: GPC_AnyFile; var MTime: LongInt);
procedure SetFTime (var f: GPC_AnyFile; MTime: LongInt);

{ FindFirst and FindNext are quite inefficient since they emulate
  all the brain-dead Dos stuff. If at all possible, the standard
  routines OpenDir, ReadDir and CloseDir (in the GPC unit) should be
  used instead. }
procedure FindFirst (const Path: String; Attr: TDosAttr; var SR: SearchRec);
procedure FindNext  (var SR: SearchRec);

procedure FindClose (var SR: SearchRec);
procedure UnpackTime (p: LongInt; var t: DateTime);
procedure PackTime (const t: DateTime; var p: LongInt);
function  EnvCount: Integer;
function  EnvStr (EnvIndex: Integer): TString;
procedure SwapVectors;
{ Exec executes a process via Execute, so RestoreTerminal is called
  with the argument True before and False after executing the
  process. }
procedure Exec (const Path, Params: String);
function  DosExitCode: Word;

{ Unportable Dos-only routines and declarations }

{$ifdef __BP_UNPORTABLE_ROUTINES__}
{$ifdef __GO32__}
{ These are unportable Dos-only declarations and routines, since
  interrupts are Dos and CPU specific (and have no place in a
  high-level program, anyway). }
procedure Intr (IntNo: Byte; var Regs: Registers);
procedure MsDos (var Regs: Registers);
{$endif}

{ Though probably all non-Dos systems have versions numbers as well,
  returning them here would usually not do what is expected, e.g.
  testing if certain Dos features are present by comparing the
  version number. Therefore, this routine always returns 7 (i.e.,
  version 7.0) on non-Dos systems, in the assumption that any real
  OS has at least the features of Dos 7. }
function  DosVersion: Word;

{ Changing the system date and time is a system administration task,
  not allowed to a normal process. On non-Dos systems, these
  routines emulate the changed date/time, but only for GetTime and
  GetDate (not the RTS date/time routines), and only for this
  process, not for child processes or even the parent process or
  system-wide. }
procedure SetDate (Year, Month, Day: Word);
procedure SetTime (Hour, Minute, Second, Sec100: Word);
{$endif}

end;

type
  PLongInt = ^LongInt;

var
  DosExitCodeVar: Word = 0;
  TimeDelta: MicroSecondTimeType = 0;

procedure GetDate (var Year, Month, Day, DayOfWeek: Word);
var
  t: MicroSecondTimeType;
  ts: TimeStamp;
begin
  t := GetMicroSecondTime + TimeDelta;
  UnixTimeToTimeStamp (t div 1000000, ts);
  Year      := ts.Year;
  Month     := ts.Month;
  Day       := ts.Day;
  DayOfWeek := ts.DayOfWeek
end;

procedure GetTime (var Hour, Minute, Second, Sec100: Word);
var
  t: MicroSecondTimeType;
  ts: TimeStamp;
begin
  t := GetMicroSecondTime + TimeDelta;
  UnixTimeToTimeStamp (t div 1000000, ts);
  Hour   := ts.Hour;
  Minute := ts.Minute;
  Second := ts.Second;
  Sec100 := (t mod 1000000) div 10000
end;

function DiskFree (Drive: Byte): LongInt;
var
  Path: String (2);
  Buf: StatFSBuffer;
begin
  DiskFree := 0;  { @@ spurious gcc-2.95 warning on m68k, S390 }
  if Drive = 0 then
    Path := DirSelf
  else
    Path := Succ ('a', Drive - 1) + ':';
  if StatFS (Path, Buf) then
    DiskFree := Buf.BlockSize * Buf.BlocksFree
  else
    begin
      DosError := DosError_AccessDenied;
      DiskFree := -1
    end
end;

function DiskSize (Drive: Byte): LongInt;
var
  Path: String (2);
  Buf: StatFSBuffer;
begin
  DiskSize := 0;  { @@ spurious gcc-2.95 warning on m68k }
  if Drive = 0 then
    Path := DirSelf
  else
    Path := Succ ('a', Drive - 1) + ':';
  if StatFS (Path, Buf) then
    DiskSize := Buf.BlockSize * Buf.BlocksTotal
  else
    begin
      DosError := DosError_AccessDenied;
      DiskSize := -1
    end
end;

procedure GetFAttr (var f: GPC_AnyFile; var Attr: TDosAttr);
var
  b: BindingType;
  d: OrigInt;
begin
  b := Binding (f);
  Attr := 0;
  if not (b.Bound and (b.Existing or b.Directory or b.Special)) then
    DosError := DosError_FileNotFound
  else
    begin
      DosError := 0;
      if b.Directory      then Attr := Attr or Directory;
      if not b.Writable   then Attr := Attr or ReadOnly;
      if not b.Executable then Attr := Attr or Archive;
      d := Length (b.Name);
      while (d > 0) and not (b.Name[d] in DirSeparators) do Dec (d);
      if (Length (b.Name) > d + 1) and (b.Name[d + 1] =  '.') and
        ((Length (b.Name) > d + 2) or  (b.Name[d + 2] <> '.')) then
        Attr := Attr or Hidden
    end
end;

procedure SetFAttr (var f: GPC_AnyFile; Attr: TDosAttr);
var b: BindingType;
begin
  b := Binding (f);
  if not b.Bound then
    begin
      DosError := DosError_FileNotFound;
      Exit
    end;
  if (Attr and ReadOnly) = 0 then
    or (b.Mode, fm_UserWritable)  { Set only user write permissions, for reasons of safety! }
  else
    and (b.Mode, not (fm_UserWritable or fm_GroupWritable or fm_OthersWritable));
  if (Attr and Archive) = 0 then
    or (b.Mode, fm_UserExecutable or fm_GroupExecutable or fm_OthersExecutable)
  else
    and (b.Mode, not (fm_UserExecutable or fm_GroupExecutable or fm_OthersExecutable));
  ChMod (f, b.Mode);
  if IOResult <> 0 then DosError := DosError_AccessDenied
end;

procedure GetFTime (var f: GPC_AnyFile; var MTime: LongInt);
var
  b: BindingType;
  Year, Month, Day, Hour, Minute, Second: CInteger;
  dt: DateTime;
begin
  b := Binding (f);
  if not (b.Bound and (b.Existing or b.Directory or b.Special)) then
    DosError := DosError_FileNotFound
  else
    begin
      if b.ModificationTime >= 0 then
        begin
          UnixTimeToTime (b.ModificationTime, Year, Month, Day, Hour, Minute, Second, Null, Null, Null, Null);
          dt.Year  := Year;
          dt.Month := Month;
          dt.Day   := Day;
          dt.Hour  := Hour;
          dt.Min   := Minute;
          dt.Sec   := Second;
          PackTime (dt, MTime)
        end
      else
        MTime := 0;
      DosError := 0
    end
end;

procedure SetFTime (var f: GPC_AnyFile; MTime: LongInt);
var
  dt: DateTime;
  ut: UnixTimeType;
begin
  UnpackTime (MTime, dt);
  with dt do ut := TimeToUnixTime (Year, Month, Day, Hour, Min, Sec);
  DosError := DosError_AccessDenied;
  if ut >= 0 then
    begin
      SetFileTime (f, ut, ut);
      if IOResult = 0 then DosError := 0
    end
end;

{ Since there's no explicit closing of FindFirst/FindNext, FindList keeps
  tracks of all running searches so they can be closed automatically when
  necessary, and Magic indicates if a SearchRec is currently in use. }

const
  srOpened = $2424d00f;
  srDone   = $4242f00d;

type
  TSRFillInternal = packed record
    Magic: OrigInt;
    Unused: packed array [1 .. SizeOf (SearchRecFill) - SizeOf (OrigInt)] of Byte
  end;

  PPFindList = ^PFindList;
  PFindList  = ^TFindList;
  TFindList  = record
    Next: PFindList;
    SR  : ^SearchRec;
    Dir,
    BaseName,
    Ext : TString;
    Attr: TDosAttr;
    PDir: Pointer
  end;

var
  FindList: PFindList = nil;

procedure CloseFind (PTemp: PPFindList);
var Temp: PFindList;
begin
  Temp := PTemp^;
  CloseDir (Temp^.PDir);
  TSRFillInternal (Temp^.SR^.Fill).Magic := srDone;
  PTemp^ := Temp^.Next;
  Dispose (Temp)
end;

procedure FindFirst (const Path: String; Attr: TDosAttr; var SR: SearchRec);
var
  Temp: PFindList;
  PTemp: PPFindList;
begin
  { If SR was used before, close it first }
  PTemp := @FindList;
  while (PTemp^ <> nil) and (PTemp^^.SR <> @SR) do PTemp := @PTemp^^.Next;
  if PTemp^ <> nil then
    begin
      CloseFind (PTemp);
      if IOResult <> 0 then DosError := DosError_ReadFault
    end;
  if (Attr and not (ReadOnly or Archive)) = VolumeID then
    begin
      DosError := DosError_NoMoreFiles;
      Exit
    end;
  SetReturnAddress (ReturnAddress (0));
  New (Temp);
  RestoreReturnAddress;
  FSplit (Path, Temp^.Dir, Temp^.BaseName, Temp^.Ext);
  if Temp^.Dir = '' then Temp^.Dir := DirSelf + DirSeparator;
  if Temp^.Ext = '' then Temp^.Ext := ExtSeparator;
  Temp^.SR := @SR;
  Temp^.Attr := Attr;
  Temp^.PDir := OpenDir (Temp^.Dir);
  if IOResult <> 0 then
    begin
      TSRFillInternal (SR.Fill).Magic := srDone;
      Dispose (Temp);
      DosError := DosError_NoMoreFiles;
      Exit
    end;
  TSRFillInternal (SR.Fill).Magic := srOpened;
  Temp^.Next := FindList;
  FindList := Temp;
  SetReturnAddress (ReturnAddress (0));
  FindNext (SR);
  RestoreReturnAddress
end;

procedure FindNext (var SR: SearchRec);
var
  Temp: PFindList;
  PTemp: PPFindList;
  FileName, Dir, BaseName, Ext: TString;
  f: Text;
  TmpAttr: TDosAttr;
  TmpTime: LongInt;

  { Emulate Dos brain-damaged file name wildcard matching }
  function MatchPart (const aName, Mask: String): Boolean;
  var i: OrigInt;
  begin
    for i := 1 to Length (Mask) do
      case Mask[i] of
        '?': ;
        '*': Return True;
        else
          if (i > Length (aName)) or (FileNameLoCase (aName[i]) <> FileNameLoCase (Mask[i])) then Return False
      end;
    MatchPart := Length (Mask) >= Length (aName)
  end;

begin
  DosError := 0;
  { Check if SR is still valid }
  case TSRFillInternal (SR.Fill).Magic of
    srOpened: ;
    srDone: begin
              DosError := DosError_NoMoreFiles;
              Exit
            end;
    else
      DosError := DosError_InvalidMem;
      Exit
  end;
  PTemp := @FindList;
  while (PTemp^ <> nil) and (PTemp^^.SR <> @SR) do PTemp := @PTemp^^.Next;
  Temp := PTemp^;
  if Temp = nil then
    begin
      DosError := DosError_InvalidMem;
      Exit
    end;
  repeat
    FileName := ReadDir (Temp^.PDir);
    if FileName = '' then
      begin
        CloseFind (PTemp);
        if IOResult = 0 then
          DosError := DosError_NoMoreFiles
        else
          DosError := DosError_ReadFault;
        Exit
      end;
    SetReturnAddress (ReturnAddress (0));
    Assign (f, Temp^.Dir + FileName);
    RestoreReturnAddress;
    GetFAttr (f, TmpAttr);
    SR.Attr := TmpAttr;
    FSplit (FileName, Dir, BaseName, Ext);
    if Ext = '' then Ext := ExtSeparator
  until MatchPart (BaseName, Temp^.BaseName) and MatchPart (Ext, Temp^.Ext) and
        { Emulate Dos brain-damaged file attribute matching }
        (((Temp^.Attr and (Hidden or SysFile)) <> 0) or ((TmpAttr and Hidden)    = 0)) and
        (((Temp^.Attr and Directory)           <> 0) or ((TmpAttr and Directory) = 0));
  SR.Name := FileName;
  if DosError <> 0 then Exit;
  GetFTime (f, TmpTime);
  SR.Time := TmpTime;
  if Binding (f).Existing then
    begin
      Reset (f);
      SR.Size := FileSize (f);
      Close (f)
    end
  else
    SR.Size := 0
end;

procedure FindClose (var SR: SearchRec);
var PTemp: PPFindList;
begin
  PTemp := @FindList;
  while (PTemp^ <> nil) and (PTemp^^.SR <> @SR) do PTemp := @PTemp^^.Next;
  if PTemp^ <> nil then
    begin
      CloseFind (PTemp);
      if IOResult <> 0 then DosError := DosError_ReadFault
    end
end;

procedure UnpackTime (p: LongInt; var t: DateTime);
begin
  t.Year  := (p shr 25) and $7f + 1980;
  t.Month := (p shr 21) and $f;
  t.Day   := (p shr 16) and $1f;
  t.Hour  := (p shr 11) and $1f;
  t.Min   := (p shr 5) and $3f;
  t.Sec   := 2 * (p and $1f)
end;

procedure PackTime (const t: DateTime; var p: LongInt);
begin
  p := (LongInt (t.Year) - 1980) shl 25 + LongInt (t.Month) shl 21 + LongInt (t.Day) shl 16
       + t.Hour shl 11 + t.Min shl 5 + t.Sec div 2
end;

function EnvCount: Integer;
begin
  EnvCount := Environment^.Count
end;

function EnvStr (EnvIndex: Integer): TString;
begin
  if (EnvIndex < 1) or (EnvIndex > EnvCount) then
    EnvStr := ''
  else
    EnvStr := CString2String (Environment^.CStrings[EnvIndex])
end;

procedure SwapVectors;
begin
  { Nothing to be done }
end;

procedure Exec (const Path, Params: String);
begin
  DosExitCodeVar := Execute (Path + ' ' + Params);
  if IOResult <> 0 then DosError := DosError_FileNotFound
end;

function DosExitCode: Word;
begin
  DosExitCode := DosExitCodeVar
end;

{$ifdef __GO32__}

type
  TDPMIRegs = record
    edi, esi, ebp, Reserved, ebx, edx, ecx, eax: Word32;
    Flags, es, ds, fs, gs, ip, cs, sp, ss: Word16
  end;

procedure RealModeInterrupt (InterruptNumber: Integer; var Regs: TDPMIRegs); external name '__dpmi_int';

procedure Intr (IntNo: Byte; var Regs: Registers);
var DPMIRegs: TDPMIRegs;
begin
  FillChar (DPMIRegs, SizeOf (DPMIRegs), 0);
  with DPMIRegs do
    begin
      edi := Regs.di;
      esi := Regs.si;
      ebp := Regs.bp;
      ebx := Regs.bx;
      edx := Regs.dx;
      ecx := Regs.cx;
      eax := Regs.ax;
      Flags := Regs.Flags;
      es := Regs.es;
      ds := Regs.ds;
      RealModeInterrupt (IntNo, DPMIRegs);
      Regs.di := edi;
      Regs.si := esi;
      Regs.bp := ebp;
      Regs.bx := ebx;
      Regs.dx := edx;
      Regs.cx := ecx;
      Regs.ax := eax;
      Regs.Flags := Flags;
      Regs.es := es;
      Regs.ds := ds
    end
end;

procedure MsDos (var Regs: Registers);
begin
  Intr ($21, Regs)
end;

procedure GetCBreak (var BreakOn: Boolean);
var Regs: Registers;
begin
  Regs.ax := $3300;
  MsDos (Regs);
  BreakOn := Regs.dl <> 0
end;

procedure SetCBreak (BreakOn: Boolean);
var Regs: Registers;
begin
  Regs.ax := $3301;
  Regs.dx := Ord (BreakOn);
  MsDos (Regs)
end;

procedure GetVerify (var VerifyOn: Boolean);
var Regs: Registers;
begin
  Regs.ax := $5400;
  MsDos (Regs);
  VerifyOn := Regs.al <> 0
end;

procedure SetVerify (VerifyOn: Boolean);
var Regs: Registers;
begin
  Regs.ax := $2e00 + Ord (VerifyOn);
  MsDos (Regs)
end;

function DosVersion: Word;
var Regs: Registers;
begin
  Regs.ax := $3000;
  MsDos (Regs);
  DosVersion := Regs.ax
end;

{$else}

{$ifdef _WIN32}

{$define WINAPI(X) external name X; attribute (stdcall)}

const
  StdInputHandle = -10;
  EnableProcessedInput = 1;

function GetConsoleMode (ConsoleHandle: Integer; var Mode: Integer): Boolean; WINAPI ('GetConsoleMode');
function SetConsoleMode (ConsoleHandle: Integer; Mode: Integer): Boolean; WINAPI ('SetConsoleMode');
function GetStdHandle (StdHandle: Integer): Integer; WINAPI ('GetStdHandle');

procedure GetCBreak (var BreakOn: Boolean);
var Mode: Integer;
begin
  if GetConsoleMode (GetStdHandle (StdInputHandle), Mode) then
    BreakOn := (Mode and EnableProcessedInput) <> 0
  else
    BreakOn := True
end;

procedure SetCBreak (BreakOn: Boolean);
var i: Integer;
begin
  if GetConsoleMode (GetStdHandle (StdInputHandle), i) then
    begin
      if BreakOn then
        i := i or EnableProcessedInput
      else
        i := i and not EnableProcessedInput;
      Discard (SetConsoleMode (GetStdHandle (StdInputHandle), i))
    end
end;

{$else}

procedure GetCBreak (var BreakOn: Boolean);
begin
  BreakOn := GetInputSignals
end;

procedure SetCBreak (BreakOn: Boolean);
begin
  SetInputSignals (BreakOn)
end;

{$endif}

var
  LastVerify: Boolean = True;

procedure GetVerify (var VerifyOn: Boolean);
begin
  VerifyOn := LastVerify
end;

procedure SetVerify (VerifyOn: Boolean);
begin
  LastVerify := VerifyOn
end;

function DosVersion: Word;
begin
  DosVersion := 7
end;

{$endif}

{$ifdef __BP_UNPORTABLE_ROUTINES__}

{$ifdef __GO32__}

procedure SetDate (Year, Month, Day: Word);
var Regs: Registers;
begin
   Regs.ax := $2b00;
   Regs.cx := Year;
   Regs.dx := $100 * Month + Day;
   MsDos (Regs)
end;

procedure SetTime (Hour, Minute, Second, Sec100: Word);
var Regs: Registers;
begin
  Regs.ax := $2d00;
  Regs.cx := $100 * Hour + Minute;
  Regs.dx := $100 * Second + Sec100;
  MsDos (Regs)
end;

{$else}

{ We cannot easily set the date without the time or vice versa while
  treating DST correctly under all circumstances. }
procedure SetDateTime (Year, Month, Day, Hour, Minute, Second, Sec100: Word);
begin
  TimeDelta := MicroSecondTimeType (TimeToUnixTime (Year, Month, Day, Hour, Minute, Second)) * 1000000 + Sec100 * 10000 - GetMicroSecondTime
end;

procedure SetDate (Year, Month, Day: Word);
var Hour, Minute, Second, Sec100: Word;
begin
  GetTime (Hour, Minute, Second, Sec100);
  SetDateTime (Year, Month, Day, Hour, Minute, Second, Sec100)
end;

procedure SetTime (Hour, Minute, Second, Sec100: Word);
var Year, Month, Day, DayOfWeek: Word;
begin
  GetDate (Year, Month, Day, DayOfWeek);
  SetDateTime (Year, Month, Day, Hour, Minute, Second, Sec100)
end;

{$endif}

{$endif}

to end do
  while FindList <> nil do
    begin
      var i: OrigInt = IOResult;
      CloseFind (@FindList);
      InOutRes := i
    end;

end.
