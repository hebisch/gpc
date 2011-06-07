{ This file was generated automatically by make-rtsc-pas.
  DO NOT CHANGE THIS FILE MANUALLY! }

{ Pascal declarations of the GPC Run Time System routines that are
  implemented in C

  Note about the `GPC_' prefix:
  This is inserted so that some identifiers don't conflict with the
  built-in ones. In some cases, the built-in ones do exactly the
  same as the ones declared here, but often enough, they contain
  some "magic", so they should be used instead of the plain
  declarations here. In general, routines with a `GPC_' prefix
  should not be called from programs. They may change or disappear
  in future GPC versions.

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

{$gnu-pascal,I-}

unit RTSC; attribute (name = 'GPC');

interface

const
  { Maximum size of a variable }
  MaxVarSize = MaxInt div 8;

{ If set, characters >= #$80 are assumed to be letters even if the
  locale routines don't say so. This is a kludge because some
  systems don't have correct non-English locale tables. }
var
  FakeHighLetters: Boolean = False; attribute (name = '_p_FakeHighLetters');

type
  PCStrings = ^TCStrings;
  TCStrings = array [0 .. MaxVarSize div SizeOf (CString) - 1] of CString;

  Int64 = Integer attribute (Size = 64);
  UnixTimeType = LongInt;  { This is hard-coded in the compiler. Do not change here. }
  MicroSecondTimeType = LongInt;
  FileSizeType = LongInt;
  SignedSizeType = Integer attribute (Size = BitSizeOf (SizeType));
  TSignalHandler = procedure (Signal: CInteger);

  StatFSBuffer = record
    BlockSize, BlocksTotal, BlocksFree: LongInt;
    FilesTotal, FilesFree: CInteger
  end;

  InternalSelectType = record
    Handle: CInteger;
    Read, Write, Exception: Boolean
  end;

  PString = ^String;

  { `Max' so the range of the array does not become invalid for
    Count = 0 }
  PPStrings = ^TPStrings;
  TPStrings (Count: Cardinal) = array [1 .. Max (Count, 1)] of PString;

  GlobBuffer = record
    Result: PPStrings;
    Internal1: Pointer;
    Internal2: PCStrings;
    Internal3: CInteger
  end;

{@internal}
  TCPasswordEntry = record
    UserName, RealName, Password, HomeDirectory, Shell: CString;
    UID, GID: CInteger
  end;

  PCPasswordEntries = ^TCPasswordEntries;
  TCPasswordEntries = array [0 .. MaxVarSize div SizeOf (TCPasswordEntry) - 1] of TCPasswordEntry;

{$define SqRt InternalSqRt} {$define Exp InternalExp} {$define Ln InternalLn}  { @@ }
{@endinternal}

{ Mathematical routines }

{@internal}
function  Sin (x: Real): Real; attribute (const); external name '_p_Sin';
function  Cos (x: Real): Real; attribute (const); external name '_p_Cos';
function  ArcSin (x: Real): Real; attribute (const); external name '_p_ArcSin';
function  ArcCos (x: Real): Real; attribute (const); external name '_p_ArcCos';
function  ArcTan (x: Real): Real; attribute (const); external name '_p_ArcTan';
function  SqRt (x: Real): Real; attribute (const); external name '_p_SqRt';
function  Ln (x: Real): Real; attribute (const); external name '_p_Ln';
function  Exp (x: Real): Real; attribute (const); external name '_p_Exp';
function  Power (x: Real; y: Real): Real; attribute (const); external name '_p_Power';
function  InternalHypot (x: Real; y: Real): Real; attribute (const); external name '_p_InternalHypot';
function  InternalLn1Plus (x: Real): Real; attribute (const); external name '_p_InternalLn1Plus';
function  LongReal_Sin (x: LongReal): LongReal; attribute (const); external name '_p_LongReal_Sin';
function  LongReal_Cos (x: LongReal): LongReal; attribute (const); external name '_p_LongReal_Cos';
function  LongReal_ArcSin (x: LongReal): LongReal; attribute (const); external name '_p_LongReal_ArcSin';
function  LongReal_ArcCos (x: LongReal): LongReal; attribute (const); external name '_p_LongReal_ArcCos';
function  LongReal_ArcTan (x: LongReal): LongReal; attribute (const); external name '_p_LongReal_ArcTan';
function  LongReal_SqRt (x: LongReal): LongReal; attribute (const); external name '_p_LongReal_SqRt';
function  LongReal_Ln (x: LongReal): LongReal; attribute (const); external name '_p_LongReal_Ln';
function  LongReal_Exp (x: LongReal): LongReal; attribute (const); external name '_p_LongReal_Exp';
function  LongReal_Power (x: LongReal; y: LongReal): LongReal; attribute (const); external name '_p_LongReal_Power';
{@endinternal}

function  SinH (x: Real): Real; attribute (const); external name '_p_SinH';
function  CosH (x: Real): Real; attribute (const); external name '_p_CosH';
function  ArcTan2 (y: Real; x: Real): Real; attribute (const); external name '_p_ArcTan2';
function  IsInfinity (x: LongReal): Boolean; attribute (const); external name '_p_IsInfinity';
function  IsNotANumber (x: LongReal): Boolean; attribute (const); external name '_p_IsNotANumber';
procedure SplitReal (x: LongReal; var Exponent: CInteger; var Mantissa: LongReal); external name '_p_SplitReal';

{ Character routines }

{@internal}

{ Convert a character to upper case, according to the current
  locale.
  Except in `--borland-pascal' mode, `UpCase' does the same. }
function  UpCase (ch: Char): Char; attribute (const); external name '_p_UpCase';
{@endinternal}


{ Convert a character to lower case, according to the current
  locale. }
function  LoCase (ch: Char): Char; attribute (const); external name '_p_LoCase';
function  IsUpCase (ch: Char): Boolean; attribute (const); external name '_p_IsUpCase';
function  IsLoCase (ch: Char): Boolean; attribute (const); external name '_p_IsLoCase';
function  IsAlpha (ch: Char): Boolean; attribute (const); external name '_p_IsAlpha';
function  IsAlphaNum (ch: Char): Boolean; attribute (const); external name '_p_IsAlphaNum';
function  IsAlphaNumUnderscore (ch: Char): Boolean; attribute (const); external name '_p_IsAlphaNumUnderscore';
function  IsSpace (ch: Char): Boolean; attribute (const); external name '_p_IsSpace';
function  IsPrintable (ch: Char): Boolean; attribute (const); external name '_p_IsPrintable';

{ Time routines }

{ Sleep for a given number of seconds. }
procedure Sleep (Seconds: CInteger); external name '_p_Sleep';

{ Sleep for a given number of microseconds. }
procedure SleepMicroSeconds (MicroSeconds: CInteger); external name '_p_SleepMicroSeconds';

{ Set an alarm timer. }
function  Alarm (Seconds: CInteger): CInteger; external name '_p_Alarm';

{ Convert a Unix time value to broken-down local time.
  All parameters except Time may be Null. }
procedure UnixTimeToTime (Time: UnixTimeType; var Year: CInteger; var Month: CInteger; var Day: CInteger; var Hour: CInteger; var Minute: CInteger; var Second: CInteger;
                                var TimeZone: CInteger; var DST: Boolean; var TZName1: CString; var TZName2: CString); external name '_p_UnixTimeToTime';

{ Convert broken-down local time to a Unix time value. }
function  TimeToUnixTime (Year: CInteger; Month: CInteger; Day: CInteger; Hour: CInteger; Minute: CInteger; Second: CInteger): UnixTimeType; external name '_p_TimeToUnixTime';

{ Get the real time. MicroSecond can be Null and is ignored then. }
function  GetUnixTime (var MicroSecond: CInteger): UnixTimeType; external name '_p_GetUnixTime';

{ Get the CPU time used. MicroSecond can be Null and is ignored
  then. }
function  GetCPUTime (var MicroSecond: CInteger): CInteger; external name '_p_GetCPUTime';

{@internal}
procedure InitTime; external name '_p_InitTime';
function  CFormatTime (Time: UnixTimeType; Format: CString; Buf: CString; Size: CInteger): CInteger; external name '_p_CFormatTime';
{@endinternal}


{ Signal and process routines }

{ Extract information from the status returned by PWait }
function  StatusExited (Status: CInteger): Boolean; attribute (const); external name '_p_StatusExited';
function  StatusExitCode (Status: CInteger): CInteger; attribute (const); external name '_p_StatusExitCode';
function  StatusSignaled (Status: CInteger): Boolean; attribute (const); external name '_p_StatusSignaled';
function  StatusTermSignal (Status: CInteger): CInteger; attribute (const); external name '_p_StatusTermSignal';
function  StatusStopped (Status: CInteger): Boolean; attribute (const); external name '_p_StatusStopped';
function  StatusStopSignal (Status: CInteger): CInteger; attribute (const); external name '_p_StatusStopSignal';

{ Install a signal handler and optionally return the previous
  handler. OldHandler and OldRestart may be Null. }
function  InstallSignalHandler (Signal: CInteger; Handler: TSignalHandler; Restart: Boolean; UnlessIgnored: Boolean;
  var OldHandler: TSignalHandler; var OldRestart: Boolean): Boolean; external name '_p_InstallSignalHandler';

{ Block or unblock a signal. }
procedure BlockSignal (Signal: CInteger; Block: Boolean); external name '_p_BlockSignal';

{ Test whether a signal is blocked. }
function  SignalBlocked (Signal: CInteger): Boolean; external name '_p_SignalBlocked';

{ Sends a signal to a process. Returns True if successful. If Signal
  is 0, it doesn't send a signal, but still checks whether it would
  be possible to send a signal to the given process. }
function  Kill (PID: CInteger; Signal: CInteger): Boolean; external name '_p_Kill';

{ Constant for WaitPID }
const
  AnyChild = -1;

{ Waits for a child process with the given PID (or any child process
  if PID = AnyChild) to terminate or be stopped. Returns the PID of
  the process. WStatus will contain the status and can be evaluated
  with StatusExited etc.. If nothing happened, and Block is False,
  the function will return 0, and WStatus will be 0. If an error
  occurred (especially on single tasking systems where WaitPID is
  not possible), the function will return a negative value, and
  WStatus will be 0. }
function  WaitPID (PID: CInteger; var WStatus: CInteger; Block: Boolean): CInteger; external name '_p_WaitPID';

{ Returns the process ID. }
function  ProcessID: CInteger; external name '_p_ProcessID';

{ Returns the process group. }
function  ProcessGroup: CInteger; external name '_p_ProcessGroup';

{ Returns the real or effective user ID of the process. }
function  UserID (Effective: Boolean): CInteger; external name '_p_UserID';

{ Tries to change the real and/or effective user ID. }
function  SetUserID (Real: CInteger; Effective: CInteger): Boolean; external name '_p_SetUserID';

{ Returns the real or effective group ID of the process. }
function  GroupID (Effective: Boolean): CInteger; external name '_p_GroupID';

{ Tries to change the real and/or effective group ID. }
function  SetGroupID (Real: CInteger; Effective: CInteger): Boolean; external name '_p_SetGroupID';

{ Low-level file routines. Mostly for internal use. }

{ Get information about a file system. }
function  StatFS (Path: CString; var Buf: StatFSBuffer): Boolean; external name '_p_StatFS';
function  CStringOpenDir (DirName: CString): Pointer; external name '_p_CStringOpenDir';
function  CStringReadDir (Dir: Pointer): CString; external name '_p_CStringReadDir';
procedure CStringCloseDir (Dir: Pointer); external name '_p_CStringCloseDir';

{ Returns the value of the symlink FileName in a CString allocated
  from the heap. Returns nil if it is no symlink or the function
  is not supported. }
function  ReadLink (FileName: CString): CString; external name '_p_ReadLink';

{ Returns a pointer to a *static* buffer! }
function  CStringRealPath (Path: CString): CString; external name '_p_CStringRealPath';

{ File mode constants that are ORed for BindingType.Mode, ChMod,
  CStringChMod and Stat. The values below are valid for all OSs
  (as far as supported). If the OS uses different values, they're
  converted internally. }
const
  fm_SetUID           = 8#4000;
  fm_SetGID           = 8#2000;
  fm_Sticky           = 8#1000;
  fm_UserReadable     = 8#400;
  fm_UserWritable     = 8#200;
  fm_UserExecutable   = 8#100;
  fm_GroupReadable    = 8#40;
  fm_GroupWritable    = 8#20;
  fm_GroupExecutable  = 8#10;
  fm_OthersReadable   = 8#4;
  fm_OthersWritable   = 8#2;
  fm_OthersExecutable = 8#1;

{ Constants for Access and OpenHandle }
const
  MODE_EXEC     = 1 shl 0;
  MODE_WRITE    = 1 shl 1;
  MODE_READ     = 1 shl 2;
  MODE_FILE     = 1 shl 3;
  MODE_CREATE   = 1 shl 4;
  MODE_EXCL     = 1 shl 5;
  MODE_TRUNCATE = 1 shl 6;
  MODE_APPEND   = 1 shl 7;
  MODE_BINARY   = 1 shl 8;

{ Check if a file name is accessible. }
function  Access (FileName: CString; Request: CInteger): CInteger; external name '_p_Access';

{ Get information about a file. Any argument except FileName can
  be Null. }
function  Stat (FileName: CString; var Size: FileSizeType;
  var ATime: UnixTimeType; var MTime: UnixTimeType; var CTime: UnixTimeType;
  var User: CInteger; var Group: CInteger; var Mode: CInteger; var Device: CInteger; var INode: CInteger; var Links: CInteger;
  var SymLink: Boolean; var Dir: Boolean; var Special: Boolean): CInteger; external name '_p_Stat';
function  OpenHandle (FileName: CString; Mode: CInteger): CInteger; external name '_p_OpenHandle';
function  ReadHandle (Handle: CInteger; Buffer: Pointer; Size: SizeType): SignedSizeType; external name '_p_ReadHandle';
function  WriteHandle (Handle: CInteger; Buffer: Pointer; Size: SizeType): SignedSizeType; external name '_p_WriteHandle';
function  CloseHandle (Handle: CInteger): CInteger; external name '_p_CloseHandle';
procedure FlushHandle (Handle: CInteger); external name '_p_FlushHandle';
function  DupHandle (Src: CInteger; Dest: CInteger): CInteger; external name '_p_DupHandle';
function  SetFileMode (Handle: CInteger; Mode: CInteger; On: Boolean): CInteger; attribute (ignorable); external name '_p_SetFileMode';
function  CStringRename (OldName: CString; NewName: CString): CInteger; external name '_p_CStringRename';
function  CStringUnlink (FileName: CString): CInteger; external name '_p_CStringUnlink';
function  CStringChDir (FileName: CString): CInteger; external name '_p_CStringChDir';
function  CStringMkDir (FileName: CString): CInteger; external name '_p_CStringMkDir';
function  CStringRmDir (FileName: CString): CInteger; external name '_p_CStringRmDir';
function  UMask (Mask: CInteger): CInteger; attribute (ignorable); external name '_p_UMask';
function  CStringChMod (FileName: CString; Mode: CInteger): CInteger; external name '_p_CStringChMod';
function  CStringChOwn (FileName: CString; Owner: CInteger; Group: CInteger): CInteger; external name '_p_CStringChOwn';
function  CStringUTime (FileName: CString; AccessTime: UnixTimeType; ModificationTime: UnixTimeType): CInteger; external name '_p_CStringUTime';

{ Constants for SeekHandle }
const
  SeekAbsolute = 0;
  SeekRelative = 1;
  SeekFileEnd  = 2;

{ Seek to a position on a file handle. }
function  SeekHandle (Handle: CInteger; Offset: FileSizeType; Whence: CInteger): FileSizeType; external name '_p_SeekHandle';
function  TruncateHandle (Handle: CInteger; Size: FileSizeType): CInteger; external name '_p_TruncateHandle';
function  LockHandle (Handle: CInteger; WriteLock: Boolean; Block: Boolean): Boolean; external name '_p_LockHandle';
function  UnlockHandle (Handle: CInteger): Boolean; external name '_p_UnlockHandle';
function  SelectHandle (Count: CInteger; var Events: InternalSelectType; MicroSeconds: MicroSecondTimeType): CInteger; external name '_p_SelectHandle';

{ Constants for MMapHandle and MemoryMap }
const
  mm_Readable   = 1;
  mm_Writable   = 2;
  mm_Executable = 4;

{ Try to map (a part of) a file to memory. }
function  MMapHandle (Start: Pointer; Length: SizeType; Access: CInteger; Shared: Boolean; Handle: CInteger; Offset: FileSizeType): Pointer; external name '_p_MMapHandle';

{ Unmap a previous memory mapping. }
function  MUnMapHandle (Start: Pointer; Length: SizeType): CInteger; external name '_p_MUnMapHandle';

{ Returns the file name of the terminal device that is open on
  Handle. Returns nil if (and only if) Handle is not open or not
  connected to a terminal. If NeedName is False, it doesn't bother
  to search for the real name and just returns DefaultName if it
  is a terminal and nil otherwise. DefaultName is also returned if
  NeedName is True, Handle is connected to a terminal, but the
  system does not provide information about the real file name. }
function  GetTerminalNameHandle (Handle: CInteger; NeedName: Boolean; DefaultName: CString): CString; external name '_p_GetTerminalNameHandle';

{ System routines }

{ Sets the process group of Process (or the current one if Process
  is 0) to ProcessGroup (or its PID if ProcessGroup is 0). Returns
  True if successful. }
function  SetProcessGroup (Process: CInteger; ProcessGroup: CInteger): Boolean; external name '_p_SetProcessGroup';

{ Sets the process group of a terminal given by Terminal (as a file
  handle) to ProcessGroup. ProcessGroup must be the ID of a process
  group in the same session. Returns True if successful. }
function  SetTerminalProcessGroup (Handle: CInteger; ProcessGroup: CInteger): Boolean; external name '_p_SetTerminalProcessGroup';

{ Returns the process group of a terminal given by Terminal (as a
  file handle), or -1 on error. }
function  GetTerminalProcessGroup (Handle: CInteger): CInteger; external name '_p_GetTerminalProcessGroup';

{ Set the standard input's signal generation, if it is a terminal. }
procedure SetInputSignals (Signals: Boolean); external name '_p_SetInputSignals';

{ Get the standard input's signal generation, if it is a terminal. }
function  GetInputSignals: Boolean; external name '_p_GetInputSignals';

{ Internal routines }

{ Returns system information if available. Fields not available will
  be set to nil. }
procedure CStringSystemInfo (var SysName: CString; var NodeName: CString; var Release: CString; var Version: CString; var Machine: CString; var DomainName: CString); external name '_p_CStringSystemInfo';

{ Returns the path of the running executable *if possible*. }
function  CStringExecutablePath (Buffer: CString): CString; external name '_p_CStringExecutablePath';

{@internal}

{ Returns a temporary directory name *if possible*. }
function  CStringGetTempDirectory (Buffer: CString; Size: CInteger): CString; external name '_p_CStringGetTempDirectory';

{ Executes a command line. }
function  CSystem (CmdLine: CString): CInteger; external name '_p_CSystem';
function  GetStartEnvironment (ValueIfNotFound: PCStrings): PCStrings; external name '_p_GetStartEnvironment';
procedure CStringSetEnv (VarName: CString; Value: CString; NewEnvCString: CString; UnSet: Boolean); external name '_p_CStringSetEnv';
{@endinternal}


{ Sets ErrNo to the value of `errno' and returns the description
  for this error. May return nil if not supported! ErrNo may be
  Null (then only the description is returned). }
function  CStringStrError (var ErrNo: CInteger): CString; external name '_p_CStringStrError';

{@internal}

{ Returns a description for a signal. May return nil if not supported! }
function  CStringStrSignal (Signal: CInteger): CString; external name '_p_CStringStrSignal';
function  FNMatch (Pattern: CString; FileName: CString): CInteger; external name '_p_FNMatch';
procedure GlobInternal (var Buf: GlobBuffer; Pattern: CString); external name '_p_GlobInternal';
procedure GlobFreeInternal (var Buf: GlobBuffer); external name '_p_GlobFreeInternal';
function  CGetPwNam (UserName: CString; var Entry: TCPasswordEntry): Boolean; external name '_p_CGetPwNam';
function  CGetPwUID (UID: CInteger; var Entry: TCPasswordEntry): Boolean; external name '_p_CGetPwUID';
function  CGetPwEnt (var Entries: PCPasswordEntries): CInteger; external name '_p_CGetPwEnt';
procedure InitMisc; external name '_p_InitMisc';
procedure InitMalloc (procedure WarnProc (Msg: CString)); external name '_p_InitMalloc';
procedure ExitProgram (Status: CInteger; AbortFlag: Boolean); attribute (noreturn); external name '_p_ExitProgram';
{@endinternal}

{@internal}
{ rtsc.pas }
type
  PProcedure = ^procedure;
  PProcList = ^TProcList;
  TProcList = record
    Next, Prev: PProcList;
    Proc: PProcedure
  end;

procedure RunFinalizers (var AtExitProcs: PProcList); attribute (name = '_p_RunFinalizers');

{@endinternal}

implementation

{ @@ from files.pas }
procedure Initialize_Std_Files; attribute (iocritical); external name '_p_Initialize_Std_Files';

{ This file is always compiled with debug information (see
  Makefile.in), but the file name of the following routine is set to
  a magic name, so a debugger can recognize it automatically and
  step over it into the finalizers themselves. }
{$ifndef DEBUG}
#line 1 "<implicit code>"
{$endif}
procedure RunFinalizers (var AtExitProcs: PProcList);
var
  p: PProcList;
  Proc: PProcedure;
begin
  while AtExitProcs <> nil do
    begin
      p := AtExitProcs;
      AtExitProcs := AtExitProcs^.Next;
      Proc := p^.Proc;
      Dispose (p);
      Proc^
    end
end;

{$I+}

begin
  InitMisc;
  InitTime;
  Initialize_Std_Files  { Do this very early, so standard files are available for messages etc. }
end.
