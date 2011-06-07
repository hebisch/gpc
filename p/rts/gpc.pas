{ This file was generated automatically by make-gpc-pas.
  DO NOT CHANGE THIS FILE MANUALLY! }

{ Pascal declarations of the GPC Run Time System that are visible to
  each program.

  This unit contains Pascal declarations of many RTS routines which
  are not built into the compiler and can be called from programs.
  Don't copy the declarations from this unit into your programs, but
  rather include this unit with a `uses' statement. The reason is
  that the internal declarations, e.g. the linker names, may change,
  and this unit will be changed accordingly. @@In the future, this
  unit might be included into every program automatically, so there
  will be no need for a `uses' statement to make the declarations
  here available.

  Note about `protected var' parameters:
  Since `const' parameters in GPC may be passed by value *or* by
  reference internally, possibly depending on the system,
  `const foo *' parameters to C functions *cannot* reliably be
  declared as `const' in Pascal. However, Extended Pascal's
  `protected var' can be used since this guarantees passing by
  reference.

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Authors: Jukka Virtanen <jtv@hut.fi>
           Peter Gerwinski <peter@gerwinski.de>
           Frank Heckenbach <frank@pascal.gnu.de>
           J.J. v.der Heijden <j.j.vanderheijden@student.utwente.nl>
           Nicola Girardi <nicola@g-n-u.de>
           Prof. Abimbola A. Olowofoyeku <African_Chief@bigfoot.com>
           Emil Jerabek <jerabek@math.cas.cz>
           Maurice Lombardi <Maurice.Lombardi@ujf-grenoble.fr>
           Toby Ewing <ewing@iastate.edu>
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
{$if __GPC_RELEASE__ <> 20070904}
{$error
Trying to compile gpc.pas with a non-matching GPC version is likely
to cause problems.

In case you are building the RTS separately from GPC, make sure you
install a current GPC version previously. If you are building GPC
now and this message appears, something is wrong -- if you are
overriding the GCC_FOR_TARGET or GPC_FOR_TARGET make variables, this
might be the problem. If you are cross-building GPC, build and
install a current GPC cross-compiler first, sorry. If that's not the
case, please report it as a bug.

If you are not building GPC or the RTS currently, you might have
installed things in the wrong place, so the compiler and RTS
versions do not match.}
{$endif}

{ Command-line options must not change the layout of RTS types
  declared here. }
{$no-pack-struct, maximum-field-alignment 0}

module GPC;

export
  GPC = all;
  GPC_CP = (ERead { @@ not really, but an empty export doesn't work } );
  GPC_EP = (ERead { @@ not really, but an empty export doesn't work } );
  GPC_BP = (MaxLongInt, ExitCode, ErrorAddr, FileMode, Pos);
  GPC_Delphi = (MaxLongInt, Int64, InitProc, EConvertError,
                ExitCode, ErrorAddr, FileMode, Pos, SetString, StringOfChar,
                TextFile, AssignFile, CloseFile);

type
  GPC_FDR = AnyFile;

{ Pascal declarations of the GPC Run Time System routines that are
  implemented in C, from rtsc.pas }

const
  { Maximum size of a variable }
  MaxVarSize = MaxInt div 8;

{ If set, characters >= #$80 are assumed to be letters even if the
  locale routines don't say so. This is a kludge because some
  systems don't have correct non-English locale tables. }
var
  FakeHighLetters: Boolean; attribute (name = '_p_FakeHighLetters'); external;

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

{ Mathematical routines }

function  SinH (x: Real): Real; attribute (const); external name '_p_SinH';
function  CosH (x: Real): Real; attribute (const); external name '_p_CosH';
function  ArcTan2 (y: Real; x: Real): Real; attribute (const); external name '_p_ArcTan2';
function  IsInfinity (x: LongReal): Boolean; attribute (const); external name '_p_IsInfinity';
function  IsNotANumber (x: LongReal): Boolean; attribute (const); external name '_p_IsNotANumber';
procedure SplitReal (x: LongReal; var Exponent: CInteger; var Mantissa: LongReal); external name '_p_SplitReal';

{ Character routines }

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

{ Sets ErrNo to the value of `errno' and returns the description
  for this error. May return nil if not supported! ErrNo may be
  Null (then only the description is returned). }
function  CStringStrError (var ErrNo: CInteger): CString; external name '_p_CStringStrError';

{ Mathematical routines, from math.pas }

function Ln1Plus  (x: Real) = y: Real; attribute (const, name = '_p_Ln1Plus'); external;

{ String handling routines (lower level), from string1.pas }

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
  NumericBaseDigits: array [0 .. 35] of Char; attribute (const, name = '_p_NumericBaseDigits'); external;
  NumericBaseDigitsUpper: array [0 .. 35] of Char; attribute (const, name = '_p_NumericBaseDigitsUpper'); external;

  CParamCount: Integer; attribute (name = '_p_CParamCount'); external;
  CParameters: PCStrings; attribute (name = '_p_CParameters'); external;

function  MemCmp      (const s1, s2; Size: SizeType): CInteger; external name 'memcmp';
function  MemComp     (const s1, s2; Size: SizeType): CInteger; external name 'memcmp';
function  MemCompCase (const s1, s2; Size: SizeType): Boolean; attribute (name = '_p_MemCompCase'); external;

procedure UpCaseString    (var s: String);                                        attribute (name = '_p_UpCaseString'); external;
procedure LoCaseString    (var s: String);                                        attribute (name = '_p_LoCaseString'); external;
function  UpCaseStr       (const s: String) = Result: TString;                    attribute (name = '_p_UpCaseStr'); external;
function  LoCaseStr       (const s: String) = Result: TString;                    attribute (name = '_p_LoCaseStr'); external;

function  StrEqualCase    (const s1: String; const s2: String): Boolean;                        attribute (name = '_p_StrEqualCase'); external;

function  Pos             (const SubString: String; const s: String): Integer;                  attribute (name = '_p_Pos'); external;
function  PosChar         (const ch: Char; const s: String): Integer;             attribute (name = '_p_PosChar'); external;
function  LastPos         (const SubString: String; const s: String): Integer;                  attribute (name = '_p_LastPos'); external;
function  PosCase         (const SubString: String; const s: String): Integer;                  attribute (name = '_p_PosCase'); external;
function  LastPosCase     (const SubString: String; const s: String): Integer;                  attribute (name = '_p_LastPosCase'); external;
function  CharPos         (const Chars: CharSet; const s: String): Integer;       attribute (name = '_p_CharPos'); external;
function  LastCharPos     (const Chars: CharSet; const s: String): Integer;       attribute (name = '_p_LastCharPos'); external;

function  PosFrom         (const SubString: String; const s: String; From: Integer): Integer;            attribute (name = '_p_PosFrom'); external;
function  LastPosTill     (const SubString: String; const s: String; Till: Integer): Integer;            attribute (name = '_p_LastPosTill'); external;
function  PosFromCase     (const SubString: String; const s: String; From: Integer): Integer;            attribute (name = '_p_PosFromCase'); external;
function  LastPosTillCase (const SubString: String; const s: String; Till: Integer): Integer;            attribute (name = '_p_LastPosTillCase'); external;
function  CharPosFrom     (const Chars: CharSet; const s: String; From: Integer): Integer; attribute (name = '_p_CharPosFrom'); external;
function  LastCharPosTill (const Chars: CharSet; const s: String; Till: Integer): Integer; attribute (name = '_p_LastCharPosTill'); external;

function  IsPrefix        (const Prefix: String; const s: String): Boolean;                    attribute (name = '_p_IsPrefix'); external;
function  IsSuffix        (const Suffix: String; const s: String): Boolean;                    attribute (name = '_p_IsSuffix'); external;
function  IsPrefixCase    (const Prefix: String; const s: String): Boolean;                    attribute (name = '_p_IsPrefixCase'); external;
function  IsSuffixCase    (const Suffix: String; const s: String): Boolean;                    attribute (name = '_p_IsSuffixCase'); external;

function  CStringLength      (Src: CString): SizeType;                           attribute (inline, name = '_p_CStringLength'); external;
function  CStringEnd         (Src: CString): CString;                            attribute (inline, name = '_p_CStringEnd'); external;
function  CStringNew         (Src: CString): CString;                            attribute (name = '_p_CStringNew'); external;
function  CStringComp        (s1, s2: CString): Integer;                         attribute (name = '_p_CStringComp'); external;
function  CStringCaseComp    (s1, s2: CString): Integer;                         attribute (name = '_p_CStringCaseComp'); external;
function  CStringLComp       (s1, s2: CString; MaxLen: SizeType): Integer;       attribute (name = '_p_CStringLComp'); external;
function  CStringLCaseComp   (s1, s2: CString; MaxLen: SizeType): Integer;       attribute (name = '_p_CStringLCaseComp'); external;
function  CStringCopy        (Dest, Source: CString): CString;                   attribute (ignorable, name = '_p_CStringCopy'); external;
function  CStringCopyEnd     (Dest, Source: CString): CString;                   attribute (ignorable, name = '_p_CStringCopyEnd'); external;
function  CStringLCopy       (Dest, Source: CString; MaxLen: SizeType): CString; attribute (ignorable, name = '_p_CStringLCopy'); external;
function  CStringMove        (Dest, Source: CString; Count: SizeType): CString;  attribute (ignorable, name = '_p_CStringMove'); external;
function  CStringCat         (Dest, Source: CString): CString;                   attribute (ignorable, name = '_p_CStringCat'); external;
function  CStringLCat        (Dest, Source: CString; MaxLen: SizeType): CString; attribute (ignorable, name = '_p_CStringLCat'); external;
function  CStringChPos       (Src: CString; ch: Char): CString;                  attribute (inline, name = '_p_CStringChPos'); external;
function  CStringLastChPos   (Src: CString; ch: Char): CString;                  attribute (inline, name = '_p_CStringLastChPos'); external;
function  CStringPos         (s, SubString: CString): CString;                   attribute (name = '_p_CStringPos'); external;
function  CStringLastPos     (s, SubString: CString): CString;                   attribute (name = '_p_CStringLastPos'); external;
function  CStringCasePos     (s, SubString: CString): CString;                   attribute (name = '_p_CStringCasePos'); external;
function  CStringLastCasePos (s, SubString: CString): CString;                   attribute (name = '_p_CStringLastCasePos'); external;
function  CStringUpCase      (s: CString): CString;                              attribute (name = '_p_CStringUpCase'); external;
function  CStringLoCase      (s: CString): CString;                              attribute (name = '_p_CStringLoCase'); external;
function  CStringIsEmpty     (s: CString): Boolean;                              attribute (name = '_p_CStringIsEmpty'); external;
function  NewCString         (const Source: String): CString;                    attribute (name = '_p_NewCString'); external;
function  CStringCopyString  (Dest: CString; const Source: String): CString;     attribute (name = '_p_CStringCopyString'); external;
procedure CopyCString        (Source: CString; var Dest: String);                attribute (name = '_p_CopyCString'); external;

function  NewString       (const s: String) = Result: PString;                   attribute (name = '_p_NewString'); external;
procedure DisposeString   (p: PString);                                          external name '_p_Dispose';

procedure SetString       (var s: String; Buffer: PChar; Count: Integer);        attribute (name = '_p_SetString'); external;
function  StringOfChar    (ch: Char; Count: Integer) = s: TString;               attribute (name = '_p_StringOfChar'); external;

procedure TrimLeft        (var s: String);                                       attribute (name = '_p_TrimLeft'); external;
procedure TrimRight       (var s: String);                                       attribute (name = '_p_TrimRight'); external;
procedure TrimBoth        (var s: String);                                       attribute (name = '_p_TrimBoth'); external;
function  TrimLeftStr     (const s: String) = Result: TString;                   attribute (name = '_p_TrimLeftStr'); external;
function  TrimRightStr    (const s: String) = Result: TString;                   attribute (name = '_p_TrimRightStr'); external;
function  TrimBothStr     (const s: String) = Result: TString;                   attribute (name = '_p_TrimBothStr'); external;
function  LTrim           (const s: String) = Result: TString;                   external name '_p_TrimLeftStr';

function  GetStringCapacity (const s: String): Integer;                          attribute (name = '_p_GetStringCapacity'); external;

{ A shortcut for a common use of WriteStr as a function }
function  Integer2String (i: Integer) = s: Str64;                                attribute (name = '_p_Integer2String'); external;

{ Convert integer n to string in base Base. }
function  Integer2StringBase (n: LongestInt; Base: TInteger2StringBase): TString;    attribute (name = '_p_Integer2StringBase'); external;

{ Convert integer n to string in base Base, with sign, optionally in
  uppercase representation and with printed base, padded with
  leading zeroes between `[<Sign>]<Base>#' and the actual digits to
  specified Width. }
function  Integer2StringBaseExt (n: LongestInt; Base: TInteger2StringBase; Width: TInteger2StringWidth; Upper: Boolean; PrintBase: Boolean): TString; attribute (name = '_p_Integer2StringBaseExt'); external;

{ String handling routines (higher level), from string2.pas }

type
  PChars0 = ^TChars0;
  TChars0 = array [0 .. MaxVarSize div SizeOf (Char) - 1] of Char;

  PPChars0 = ^TPChars0;
  TPChars0 = array [0 .. MaxVarSize div SizeOf (PChars0) - 1] of PChars0;

  PChars = ^TChars;
  TChars = packed array [1 .. MaxVarSize div SizeOf (Char)] of Char;

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
  Environment: PEnvironment; attribute (name = '_p_Environment'); external;

{ Get an environment variable. If it does not exist, GetEnv returns
  the empty string, which can't be distinguished from a variable
  with an empty value, while CStringGetEnv returns nil then. Note,
  Dos doesn't know empty environment variables, but treats them as
  non-existing, and does not distinguish case in the names of
  environment variables. However, even under Dos, empty environment
  variables and variable names with different case can now be set
  and used within GPC programs. }
function  GetEnv (const EnvVar: String): TString;                         attribute (name = '_p_GetEnv'); external;
function  CStringGetEnv (EnvVar: CString): CString;                       attribute (name = '_p_CStringGetEnv'); external;

{ Sets an environment variable with the name given in VarName to the
  value Value. A previous value, if any, is overwritten. }
procedure SetEnv (const VarName: String; const Value: String);                          attribute (name = '_p_SetEnv'); external;

{ Un-sets an environment variable with the name given in VarName. }
procedure UnSetEnv (const VarName: String);                               attribute (name = '_p_UnSetEnv'); external;

{ Returns @Environment^.CStrings, converted to PCStrings, to be
  passed to libc routines like execve which expect an environment. }
function  GetCEnvironment: PCStrings;                                     attribute (name = '_p_GetCEnvironment'); external;

type
  FormatStringTransformType = ^function (const Format: String): TString;

var
  FormatStringTransformPtr: FormatStringTransformType; attribute (name = '_p_FormatStringTransformPtr'); external;

{ Runtime error and signal handling routines, from error.pas }

const
  EAssert = 306;
  EAssertString = 307;
  EOpen = 405;
  EMMap = 408;
  ERead = 413;
  EWrite = 414;
  EWriteReadOnly = 422;
  ENonExistentFile = 436;
  EOpenRead = 442;
  EOpenWrite = 443;
  EOpenUpdate = 444;
  EReading = 464;
  EWriting = 466;
  ECannotWriteAll = 467;
  ECannotFork = 600;
  ECannotSpawn = 601;
  EProgramNotFound = 602;
  EProgramNotExecutable = 603;
  EPipe = 604;
  EPrinterRead = 610;
  EIOCtl = 630;
  EConvertError = 875;
  ELibraryFunction = 952;
  EExitReturned = 953;

  RuntimeErrorExitValue = 42;

var
  { Error number (after runtime error) or exit status (after Halt)
    or 0 (during program run and after succesful termination). }
  ExitCode: Integer; attribute (name = '_p_ExitCode'); external;

  { Contains the address of the code where a runtime occurred, nil
    if no runtime error occurred. }
  ErrorAddr: Pointer; attribute (name = '_p_ErrorAddr'); external;

  { Error message }
  ErrorMessageString: TString; attribute (name = '_p_ErrorMessageString'); external;

  { String parameter to some error messages, *not* the text of the
    error message (the latter can be obtained with
    GetErrorMessage). }
  InOutResString: PString; attribute (name = '_p_InOutResString'); external;

  { Optional libc error string to some error messages. }
  InOutResCErrorString: PString; attribute (name = '_p_InOutResCErrorString'); external;

  RTSErrorFD: Integer;          attribute (name = '_p_ErrorFD'); external;
  RTSErrorFileName: PString;   attribute (name = '_p_ErrorFileName'); external;

{ Finalize the GPC Run Time System. This is normally called
  automatically. Call it manually only in very special situations. }
procedure GPC_Finalize;
   attribute (name = '_p_finalize'); external;
function  GetErrorMessage                 (n: Integer): CString;                   attribute (name = '_p_GetErrorMessage'); external;
procedure RuntimeError                    (n: Integer);                            attribute (noreturn, name = '_p_RuntimeError'); external;
procedure RuntimeErrorErrNo               (n: Integer);                            attribute (noreturn, name = '_p_RuntimeErrorErrNo'); external;
procedure RuntimeErrorInteger             (n: Integer; i: MedInt);                 attribute (noreturn, name = '_p_RuntimeErrorInteger'); external;
procedure RuntimeErrorCString             (n: Integer; s: CString);                attribute (noreturn, name = '_p_RuntimeErrorCString'); external;
procedure InternalError                   (n: Integer);                            attribute (noreturn, name = '_p_InternalError'); external;
procedure InternalErrorInteger            (n: Integer; i: MedInt);                 attribute (noreturn, name = '_p_InternalErrorInteger'); external;
procedure InternalErrorCString            (n: Integer; s: CString);                attribute (noreturn, name = '_p_InternalErrorCString'); external;
procedure RuntimeWarning                  (Message: CString);                      attribute (name = '_p_RuntimeWarning'); external;
procedure RuntimeWarningInteger           (Message: CString; i: MedInt);           attribute (name = '_p_RuntimeWarningInteger'); external;
procedure RuntimeWarningCString           (Message: CString; s: CString);          attribute (name = '_p_RuntimeWarningCString'); external;

procedure IOError                         (n: Integer; ErrNoFlag: Boolean);                           attribute (iocritical, name = '_p_IOError'); external;
procedure IOErrorInteger                  (n: Integer; i: MedInt; ErrNoFlag: Boolean);                attribute (iocritical, name = '_p_IOErrorInteger'); external;
procedure IOErrorCString                  (n: Integer; s: CString; ErrNoFlag: Boolean);               attribute (iocritical, name = '_p_IOErrorCString'); external;

function  GetIOErrorMessage = Res: TString;                                        attribute (name = '_p_GetIOErrorMessage'); external;
procedure CheckInOutRes;                                                           attribute (name = '_p_CheckInOutRes'); external;

{ Registers a procedure to be called to restore the terminal for
  another process that accesses the terminal, or back for the
  program itself. Used e.g. by the CRT unit. The procedures must
  allow for being called multiple times in any order, even at the
  end of the program (see the comment for RestoreTerminal). }
procedure RegisterRestoreTerminal (ForAnotherProcess: Boolean; procedure Proc); attribute (name = '_p_RegisterRestoreTerminal'); external;

{ Unregisters a procedure registered with RegisterRestoreTerminal.
  Returns False if the procedure had not been registered, and True
  if it had been registered and was unregistered successfully. }
function  UnregisterRestoreTerminal (ForAnotherProcess: Boolean; procedure Proc): Boolean; attribute (name = '_p_UnregisterRestoreTerminal'); external;

{ Calls the procedures registered by RegisterRestoreTerminal. When
  restoring the terminal for another process, the procedures are
  called in the opposite order of registration. When restoring back
  for the program, they are called in the order of registration.

  `RestoreTerminal (True)' will also be called at the end of the
  program, before outputting any runtime error message. It can also
  be used if you want to write an error message and exit the program
  (especially when using e.g. the CRT unit). For this purpose, to
  avoid side effects, call RestoreTerminal immediately before
  writing the error message (to StdErr, not to Output!), and then
  exit the program (e.g. with Halt). }
procedure RestoreTerminal (ForAnotherProcess: Boolean); attribute (name = '_p_RestoreTerminal'); external;

procedure AtExit (procedure Proc); attribute (name = '_p_AtExit'); external;

function  ReturnAddr2Hex (p: Pointer) = s: TString; attribute (name = '_p_ReturnAddr2Hex'); external;

{ This function is used to write error messages etc. It does not use
  the Pascal I/O system here because it is usually called at the
  very end of a program after the Pascal I/O system has been shut
  down. }
function  WriteErrorMessage (const s: String; StdErrFlag: Boolean): Boolean; attribute (name = '_p_WriteErrorMessage'); external;

procedure SetReturnAddress (Address: Pointer); attribute (name = '_p_SetReturnAddress'); external;
procedure RestoreReturnAddress; attribute (name = '_p_RestoreReturnAddress'); external;

{ Returns a description for a signal }
function  StrSignal (Signal: Integer) = Res: TString; attribute (name = '_p_StrSignal'); external;

{ Installs some signal handlers that cause runtime errors on certain
  signals. This procedure runs only once, and returns immediately
  when called again (so you can't use it to set the signals again if
  you changed them meanwhile). @@Does not work on all systems (since
  the handler might have too little stack space). }
procedure InstallDefaultSignalHandlers; attribute (name = '_p_InstallDefaultSignalHandlers'); external;

var
  { Signal actions }
  SignalDefault: TSignalHandler; attribute (const); external name '_p_SIG_DFL';
  SignalIgnore : TSignalHandler; attribute (const); external name '_p_SIG_IGN';
  SignalError  : TSignalHandler; attribute (const); external name '_p_SIG_ERR';

  { Signals. The constants are set to the signal numbers, and
    are 0 for signals not defined. }
  { POSIX signals }
  SigHUp   : Integer; attribute (const); external name '_p_SIGHUP';
  SigInt   : Integer; attribute (const); external name '_p_SIGINT';
  SigQuit  : Integer; attribute (const); external name '_p_SIGQUIT';
  SigIll   : Integer; attribute (const); external name '_p_SIGILL';
  SigAbrt  : Integer; attribute (const); external name '_p_SIGABRT';
  SigFPE   : Integer; attribute (const); external name '_p_SIGFPE';
  SigKill  : Integer; attribute (const); external name '_p_SIGKILL';
  SigSegV  : Integer; attribute (const); external name '_p_SIGSEGV';
  SigPipe  : Integer; attribute (const); external name '_p_SIGPIPE';
  SigAlrm  : Integer; attribute (const); external name '_p_SIGALRM';
  SigTerm  : Integer; attribute (const); external name '_p_SIGTERM';
  SigUsr1  : Integer; attribute (const); external name '_p_SIGUSR1';
  SigUsr2  : Integer; attribute (const); external name '_p_SIGUSR2';
  SigChld  : Integer; attribute (const); external name '_p_SIGCHLD';
  SigCont  : Integer; attribute (const); external name '_p_SIGCONT';
  SigStop  : Integer; attribute (const); external name '_p_SIGSTOP';
  SigTStp  : Integer; attribute (const); external name '_p_SIGTSTP';
  SigTTIn  : Integer; attribute (const); external name '_p_SIGTTIN';
  SigTTOu  : Integer; attribute (const); external name '_p_SIGTTOU';

  { Non-POSIX signals }
  SigTrap  : Integer; attribute (const); external name '_p_SIGTRAP';
  SigIOT   : Integer; attribute (const); external name '_p_SIGIOT';
  SigEMT   : Integer; attribute (const); external name '_p_SIGEMT';
  SigBus   : Integer; attribute (const); external name '_p_SIGBUS';
  SigSys   : Integer; attribute (const); external name '_p_SIGSYS';
  SigStkFlt: Integer; attribute (const); external name '_p_SIGSTKFLT';
  SigUrg   : Integer; attribute (const); external name '_p_SIGURG';
  SigIO    : Integer; attribute (const); external name '_p_SIGIO';
  SigPoll  : Integer; attribute (const); external name '_p_SIGPOLL';
  SigXCPU  : Integer; attribute (const); external name '_p_SIGXCPU';
  SigXFSz  : Integer; attribute (const); external name '_p_SIGXFSZ';
  SigVTAlrm: Integer; attribute (const); external name '_p_SIGVTALRM';
  SigProf  : Integer; attribute (const); external name '_p_SIGPROF';
  SigPwr   : Integer; attribute (const); external name '_p_SIGPWR';
  SigInfo  : Integer; attribute (const); external name '_p_SIGINFO';
  SigLost  : Integer; attribute (const); external name '_p_SIGLOST';
  SigWinCh : Integer; attribute (const); external name '_p_SIGWINCH';

  { Signal subcodes (only used on some systems, -1 if not used) }
  FPEIntegerOverflow      : Integer; attribute (const); external name '_p_FPE_INTOVF_TRAP';
  FPEIntegerDivisionByZero: Integer; attribute (const); external name '_p_FPE_INTDIV_TRAP';
  FPESubscriptRange       : Integer; attribute (const); external name '_p_FPE_SUBRNG_TRAP';
  FPERealOverflow         : Integer; attribute (const); external name '_p_FPE_FLTOVF_TRAP';
  FPERealDivisionByZero   : Integer; attribute (const); external name '_p_FPE_FLTDIV_TRAP';
  FPERealUnderflow        : Integer; attribute (const); external name '_p_FPE_FLTUND_TRAP';
  FPEDecimalOverflow      : Integer; attribute (const); external name '_p_FPE_DECOVF_TRAP';

{ Routines called implicitly by the compiler. }
procedure GPC_Assert (Condition: Boolean; const Message: String); attribute (name = '_p_Assert'); external;
function  ObjectTypeIs (Left, Right: PObjectType): Boolean; attribute (const, name = '_p_ObjectTypeIs'); external;
procedure ObjectTypeAsError;                attribute (noreturn, name = '_p_ObjectTypeAsError'); external;
procedure DisposeNilError;                  attribute (noreturn, name = '_p_DisposeNilError'); external;
procedure CaseNoMatchError;                 attribute (noreturn, name = '_p_CaseNoMatchError'); external;
procedure DiscriminantsMismatchError;       attribute (noreturn, name = '_p_DiscriminantsMismatchError'); external;
procedure NilPointerError;                  attribute (noreturn, name = '_p_NilPointerError'); external;
procedure InvalidPointerError (p: Pointer); attribute (noreturn, name = '_p_InvalidPointerError'); external;
procedure InvalidObjectError;               attribute (noreturn, name = '_p_InvalidObjectError'); external;
procedure RangeCheckError;                  attribute (noreturn, name = '_p_RangeCheckError'); external;
procedure IORangeCheckError;                attribute (name = '_p_IORangeCheckError'); external;
procedure SubrangeError;                    attribute (noreturn, name = '_p_SubrangeError'); external;
procedure ModRangeError;                    attribute (noreturn, name = '_p_ModRangeError'); external;

{ Pointer checking with `--pointer-checking-user-defined' }

procedure DefaultValidatePointer (p: Pointer); attribute (name = '_p_DefaultValidatePointer'); external;

type
  ValidatePointerType = ^procedure (p: Pointer);

var
  ValidatePointerPtr: ValidatePointerType; attribute (name = '_p_ValidatePointerPtr'); external;

{ Time and date routines, from time.pas }

const
  InvalidYear = -MaxInt;

var
  { DayOfWeekName is a constant and therefore does not respect the
    locale. Therefore, it's recommended to use FormatTime instead. }
  DayOfWeekName: array [0 .. 6] of String [9]; attribute (const, name = '_p_DayOfWeekName'); external;

  { MonthName is a constant and therefore does not respect the
    locale. Therefore, it's recommended to use FormatTime instead. }
  MonthName: array [1 .. 12] of String [9]; attribute (const, name = '_p_MonthName'); external;

function  GetDayOfWeek (Day, Month, Year: Integer): Integer;                                            attribute (name = '_p_GetDayOfWeek'); external;
function  GetDayOfYear (Day, Month, Year: Integer): Integer;                                            attribute (name = '_p_GetDayOfYear'); external;
function  GetSundayWeekOfYear (Day, Month, Year: Integer): Integer;                                     attribute (name = '_p_GetSundayWeekOfYear'); external;
function  GetMondayWeekOfYear (Day, Month, Year: Integer): Integer;                                     attribute (name = '_p_GetMondayWeekOfYear'); external;
procedure GetISOWeekOfYear (Day, Month, Year: Integer; var ISOWeek, ISOWeekYear: Integer);              attribute (name = '_p_GetISOWeekOfYear'); external;
procedure UnixTimeToTimeStamp (UnixTime: UnixTimeType; var aTimeStamp: TimeStamp);                      attribute (name = '_p_UnixTimeToTimeStamp'); external;
function  TimeStampToUnixTime (protected var aTimeStamp: TimeStamp): UnixTimeType;                      attribute (name = '_p_TimeStampToUnixTime'); external;
function  GetMicroSecondTime: MicroSecondTimeType;                                                      attribute (name = '_p_GetMicroSecondTime'); external;

{ Is the year a leap year? }
function  IsLeapYear (Year: Integer): Boolean;                                                          attribute (name = '_p_IsLeapYear'); external;

{ Returns the length of the month, taking leap years into account. }
function  MonthLength (Month, Year: Integer): Integer;                                                  attribute (name = '_p_MonthLength'); external;

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
function  FormatTime (const Time: TimeStamp; const Format: String) = Res: TString; attribute (name = '_p_FormatTime'); external;

{ Pseudo random number generator, from random.pas }

type
  RandomSeedType = Cardinal attribute (Size = 32);
  RandomizeType  = ^procedure;
  SeedRandomType = ^procedure (Seed: RandomSeedType);
  RandRealType   = ^function: LongestReal;
  RandIntType    = ^function (MaxValue: LongestCard): LongestCard;

procedure SeedRandom (Seed: RandomSeedType); attribute (name = '_p_SeedRandom'); external;

var
  RandomizePtr : RandomizeType;   attribute (name = '_p_RandomizePtr'); external;
  SeedRandomPtr: SeedRandomType; attribute (name = '_p_SeedRandomPtr'); external;
  RandRealPtr  : RandRealType;     attribute (name = '_p_RandRealPtr'); external;
  RandIntPtr   : RandIntType;       attribute (name = '_p_RandIntPtr'); external;

{ File name routines, from fname.pas }

{ Define constants for different systems:

  OSDosFlag:         flag to indicate whether the target system is
                     Dos

  QuotingCharacter:  the character used to quote wild cards and
                     other special characters (#0 if not available)

  PathSeparator:     the separator of multiple paths, e.g. in the
                     PATH environment variable

  DirSeparator:      the separator of the directories within a full
                     file name

  DirSeparators:     a set of all possible directory and drive name
                     separators

  ExtSeparator:      the separator of a file name extension

  DirRoot:           the name of the root directory

  DirSelf:           the name of a directory in itself

  DirParent:         the name of the parent directory

  MaskNoStdDir:      a file name mask that matches all names except
                     the standard directories DirSelf and DirParent

  NullDeviceName:    the full file name of the null device

  TtyDeviceName:     the full file name of the current Tty

  ConsoleDeviceName: the full file name of the system console. On
                     Dos systems, this is the same as the Tty, but
                     on systems that allow remote login, this is a
                     different thing and may reach a completely
                     different user than the one running the
                     program, so use it with care.

  EnvVarCharsFirst:  the characters accepted at the beginning of the
                     name of an environment variable without quoting

  EnvVarChars:       the characters accepted in the name of an
                     environment variable without quoting

  PathEnvVar:        the name of the environment variable which
                     (usually) contains the executable search path

  ShellEnvVar:       the name of the environment variable which
                     (usually) contains the path of the shell
                     executable (see GetShellPath)

  ShellExecCommand:  the option to the (default) shell to execute
                     the command specified in the following argument
                     (see GetShellPath)

  ConfigFileMask:    a mask for the option file name as returned by
                     ConfigFileName

  FileNamesCaseSensitive:
                     flag to indicate whether file names are case
                     sensitive }

const
  UnixShellEnvVar        = 'SHELL';
  UnixShellExecCommand   = '-c';

{$ifdef __OS_DOS__}

{$if defined (__CYGWIN__) or defined(__MSYS__)}
  {$define __POSIX_WIN32__}
{$endif}

const
  OSDosFlag              = True;
  QuotingCharacter       = #0;
  PathSeparator          = {$ifdef __POSIX_WIN32__} ':' {$else} ';' {$endif};
  DirSeparator           = '\';
  DirSeparators          = [':', '\', '/'];
  ExtSeparator           = '.';
  DirRoot                = '\';
  DirSelf                = '.';
  DirParent              = '..';
  MaskNoStdDir           = '{*,.[^.]*,..?*}';
  NullDeviceName         = 'nul';
  TtyDeviceName          = 'con';
  ConsoleDeviceName      = 'con';
  EnvVarCharsFirst       = ['A' .. 'Z', 'a' .. 'z', '_'];
  EnvVarChars            = EnvVarCharsFirst + ['0' .. '9'];
  PathEnvVar             = 'PATH';
  ShellEnvVar            = 'COMSPEC';
  ShellExecCommand       = '/c';
  ConfigFileMask         = '*.cfg';
  FileNamesCaseSensitive = False;

{$else}

const
  OSDosFlag              = False;
  QuotingCharacter       = '\';
  PathSeparator          = ':';
  DirSeparator           = '/';
  DirSeparators          = ['/'];
  ExtSeparator           = '.';
  DirRoot                = '/';
  DirSelf                = '.';
  DirParent              = '..';
  MaskNoStdDir           = '{*,.[^.]*,..?*}';
  NullDeviceName         = '/dev/null';
  TtyDeviceName          = '/dev/tty';
  ConsoleDeviceName      = '/dev/console';
  EnvVarCharsFirst       = ['A' .. 'Z', 'a' .. 'z', '_'];
  EnvVarChars            = EnvVarCharsFirst + ['0' .. '9'];
  PathEnvVar             = 'PATH';
  ShellEnvVar            = UnixShellEnvVar;
  ShellExecCommand       = UnixShellExecCommand;
  ConfigFileMask         = '.*';
  FileNamesCaseSensitive = True;

{$endif}

const
  WildCardChars = ['*', '?', '[', ']'];
  FileNameSpecialChars = (WildCardChars + SpaceCharacters + ['{', '}', '$', QuotingCharacter]) - DirSeparators;

type
  DirPtr = Pointer;

{ Convert ch to lower case if FileNamesCaseSensitive is False, leave
  it unchanged otherwise. }
function  FileNameLoCase (ch: Char): Char;                               attribute (name = '_p_FileNameLoCase'); external;

{ Change a file name to use the OS dependent directory separator }
function  Slash2OSDirSeparator (const s: String) = Result: TString;      attribute (name = '_p_Slash2OSDirSeparator'); external;

{ Change a file name to use '/' as directory separator }
function  OSDirSeparator2Slash (const s: String) = Result: TString;      attribute (name = '_p_OSDirSeparator2Slash'); external;

{ Like Slash2OSDirSeparator for CStrings. *Note*: overwrites the
  CString }
function  Slash2OSDirSeparator_CString (s: CString): CString;            attribute (ignorable, name = '_p_Slash2OSDirSeparator_CString'); external;

{ Like OSDirSeparator2Slash for CStrings. *Note*: overwrites the
  CString }
function  OSDirSeparator2Slash_CString (s: CString): CString;            attribute (ignorable, name = '_p_OSDirSeparator2Slash_CString'); external;

{ Add a DirSeparator to the end of s, if there is not already one
  and s denotes an existing directory }
function  AddDirSeparator (const s: String) = Result: TString;           attribute (name = '_p_AddDirSeparator'); external;

{ Like AddDirSeparator, but also if the directory does not exist }
function  ForceAddDirSeparator (const s: String) = Result: TString;      attribute (name = '_p_ForceAddDirSeparator'); external;

{ Remove all trailing DirSeparators from s, if there are any, as
  long as removing them doesn't change the meaning (i.e., they don't
  denote the root directory. }
function  RemoveDirSeparator (const s: String) = Result: TString;        attribute (name = '_p_RemoveDirSeparator'); external;

{ Returns the current directory using OS dependent directory
  separators }
function  GetCurrentDirectory: TString;                                  attribute (name = '_p_GetCurrentDirectory'); external;

{ Returns a directory suitable for storing temporary files using OS
  dependent directory separators. If found, the result always ends
  in DirSeparator. If no suitable directory is found, an empty
  string is returned. }
function  GetTempDirectory: TString;                                     attribute (name = '_p_GetTempDirectory'); external;

{ Returns a non-existing file name in the directory given. If the
  directory doesn't exist or the Directory name is empty, an I/O
  error is raised, and GetTempFileNameInDirectory returns the empty
  string. }
function  GetTempFileNameInDirectory (const Directory: String) = Result: TString; attribute (iocritical, name = '_p_GetTempFileNameInDirectory'); external;

{ Returns a non-existing file name in GetTempDirectory. If no temp
  directory is found, i.e. GetTempDirectory returns the empty
  string, an I/O error is raised, and GetTempFileName returns the
  empty string as well. }
function  GetTempFileName: TString;                                      attribute (iocritical, name = '_p_GetTempFileName'); external;

{ The same as GetTempFileName, but returns a CString allocated from
  the heap. }
function  GetTempFileName_CString: CString;                              attribute (iocritical, name = '_p_GetTempFileName_CString'); external;

{ Returns True if the given file name is an existing plain file }
function  FileExists      (const aFileName: String): Boolean;            attribute (name = '_p_FileExists'); external;

{ Returns True if the given file name is an existing directory }
function  DirectoryExists (const aFileName: String): Boolean;            attribute (name = '_p_DirectoryExists'); external;

{ Returns True if the given file name is an existing file, directory
  or special file (device, pipe, socket, etc.) }
function  PathExists      (const aFileName: String): Boolean;            attribute (name = '_p_PathExists'); external;

{ If a file of the given name exists in one of the directories given
  in DirList (separated by PathSeparator), returns the full path,
  otherwise returns an empty string. If aFileName already contains
  an element of DirSeparators, returns Slash2OSDirSeparator
  (aFileName) if it exists. }
function  FSearch (const aFileName: String; const DirList: String): TString;           attribute (name = '_p_FSearch'); external;

{ Like FSearch, but only find executable files. Under Dos, if not
  found, the function tries appending '.com', '.exe', '.bat' and
  `.cmd' (the last one only if $COMSPEC points to a `cmd.exe'), so
  you don't have to specify these extensions in aFileName (and with
  respect to portability, it might be preferable not to do so). }
function  FSearchExecutable (const aFileName: String; const DirList: String) = Result: TString; attribute (name = '_p_FSearchExecutable'); external;

{ Replaces all occurrences of `$FOO' and `~' in s by the value of
  the environment variables FOO or HOME, respectively. If a variable
  is not defined, the function returns False, and s contains the
  name of the undefined variable (or the empty string if the
  variable name is invalid, i.e., doesn't start with a character
  from EnvVarCharsFirst). Otherwise, if all variables are found, s
  contains the replaced string, and True is returned. }
function  ExpandEnvironment (var s: String): Boolean;                    attribute (name = '_p_ExpandEnvironment'); external;

{ Expands the given path name to a full path name. Relative paths
  are expanded using the current directory, and occurrences of
  DirSelf and DirParent are resolved. Under Dos, the result is
  converted to lower case and a trailing ExtSeparator (except in a
  trailing DirSelf or DirParent) is removed, like Dos does. If the
  directory, i.e. the path without the file name, is invalid, the
  empty string is returned. }
function  FExpand       (const Path: String): TString;                   attribute (name = '_p_FExpand'); external;

{ Like FExpand, but unquotes the directory before expanding it, and
  quotes WildCardChars again afterwards. Does not check if the
  directory is valid (because it may contain wild card characters).
  Symlinks are expanded only in the directory part, not the file
  name. }
function  FExpandQuoted (const Path: String): TString;                   attribute (name = '_p_FExpandQuoted'); external;

{ FExpands Path, and then removes the current directory from it, if
  it is a prefix of it. If OnlyCurDir is set, the current directory
  will be removed only if Path denotes a file in, not below, it. }
function  RelativePath (const Path: String; OnlyCurDir, Quoted: Boolean) = Result: TString; attribute (name = '_p_RelativePath'); external;

{ Is aFileName a UNC filename? (Always returns False on non-Dos
  systems.) }
function  IsUNC (const aFileName: String): Boolean;                      attribute (name = '_p_IsUNC'); external;

{ Splits a file name into directory, name and extension. Each of
  Dir, BaseName and Ext may be Null. }
procedure FSplit (const Path: String; var Dir: String; var BaseName: String; var Ext: String);   attribute (name = '_p_FSplit'); external;

{ Functions that extract one or two of the parts from FSplit.
  DirFromPath returns DirSelf + DirSeparator if the path contains no
  directory. }
function  DirFromPath     (const Path: String) = Dir: TString;           attribute (name = '_p_DirFromPath'); external;
function  NameFromPath    (const Path: String) = BaseName: TString;      attribute (name = '_p_NameFromPath'); external;
function  ExtFromPath     (const Path: String) = Ext: TString;           attribute (name = '_p_ExtFromPath'); external;
function  NameExtFromPath (const Path: String): TString;                 attribute (name = '_p_NameExtFromPath'); external;

{ Start reading a directory. If successful, a pointer is returned
  that can be used for subsequent calls to ReadDir and finally
  CloseDir. On failure, an I/O error is raised and (in case it is
  ignored) nil is returned. }
function  OpenDir  (const DirName: String) = Res: DirPtr;                attribute (iocritical, name = '_p_OpenDir'); external;

{ Reads one entry from the directory Dir, and returns the file name.
  On errors or end of directory, the empty string is returned. }
function  ReadDir  (Dir: DirPtr): TString;                               attribute (name = '_p_ReadDir'); external;

{ Closes a directory opened with OpenDir. }
procedure CloseDir (Dir: DirPtr);                                        attribute (name = '_p_CloseDir'); external;

{ Returns the first position of a non-quoted character of CharSet in
  s, or 0 if no such character exists. }
function  FindNonQuotedChar (Chars: CharSet; const s: String; From: Integer): Integer; attribute (name = '_p_FindNonQuotedChar'); external;

{ Returns the first occurence of SubString in s that is not quoted
  at the beginning, or 0 if no such occurence exists. }
function  FindNonQuotedStr (const SubString: String; const s: String; From: Integer): Integer; attribute (name = '_p_FindNonQuotedStr'); external;

{ Does a string contain non-quoted wildcard characters? }
function  HasWildCards (const s: String): Boolean;                       attribute (name = '_p_HasWildCards'); external;

{ Does a string contain non-quoted wildcard characters, braces or
  spaces? }
function  HasWildCardsOrBraces (const s: String): Boolean;               attribute (name = '_p_HasWildCardsOrBraces'); external;

{ Insert QuotingCharacter into s before any special characters }
function  QuoteFileName (const s: String; const SpecialCharacters: CharSet) = Result: TString; attribute (name = '_p_QuoteFileName'); external;

{ Remove QuotingCharacter from s }
function  UnQuoteFileName (const s: String) = Result: TString;           attribute (name = '_p_UnQuoteFileName'); external;

{ Splits s at non-quoted spaces and expands non-quoted braces like
  bash does. The result and its entries should be disposed after
  usage, e.g. with DisposePPStrings. }
function  BraceExpand (const s: String) = Result: PPStrings;             attribute (name = '_p_BraceExpand'); external;

{ Dispose of a PPStrings array as well as the strings it contains.
  If you want to keep the strings (by assigning them to other string
  pointers), you should instead free the PPStrings array with
  `Dispose'. }
procedure DisposePPStrings (Strings: PPStrings);                         attribute (name = '_p_DisposePPStrings'); external;

{ Tests if a file name matches a shell wildcard pattern (?, *, []) }
function  FileNameMatch (const Pattern: String; const FileName: String): Boolean;      attribute (name = '_p_FileNameMatch'); external;

{ FileNameMatch with BraceExpand }
function  MultiFileNameMatch (const Pattern: String; const FileName: String): Boolean; attribute (name = '_p_MultiFileNameMatch'); external;

{ File name globbing }
{ GlobInit is implied by Glob and MultiGlob, not by GlobOn and
  MultiGlobOn. GlobOn and MultiGlobOn must be called after GlobInit,
  Glob or MultiGlob. MultiGlob and MultiGlobOn do brace expansion,
  Glob and GlobOn do not. GlobFree frees the memory allocated by the
  globbing functions and invalidates the results in Buf. It should
  be called after globbing. }
procedure GlobInit    (var Buf: GlobBuffer);                             attribute (name = '_p_GlobInit'); external;
procedure Glob        (var Buf: GlobBuffer; const Pattern: String);      attribute (name = '_p_Glob'); external;
procedure GlobOn      (var Buf: GlobBuffer; const Pattern: String);      attribute (name = '_p_GlobOn'); external;
procedure MultiGlob   (var Buf: GlobBuffer; const Pattern: String);      attribute (name = '_p_MultiGlob'); external;
procedure MultiGlobOn (var Buf: GlobBuffer; const Pattern: String);      attribute (name = '_p_MultiGlobOn'); external;
procedure GlobFree    (var Buf: GlobBuffer);                             attribute (name = '_p_GlobFree'); external;

type
  TPasswordEntry = record
    UserName, RealName, Password, HomeDirectory, Shell: PString;
    UID, GID: Integer
  end;

  PPasswordEntries = ^TPasswordEntries;
  TPasswordEntries (Count: Integer) = array [1 .. Max (1, Count)] of TPasswordEntry;

{ Finds a password entry by user name. Returns True if found, False
  otherwise. }
function  GetPasswordEntryByName (const UserName: String; var Entry: TPasswordEntry) = Res: Boolean; attribute (name = '_p_GetPasswordEntryByName'); external;

{ Finds a password entry by UID. Returns True if found, False
  otherwise. }
function  GetPasswordEntryByUID (UID: Integer; var Entry: TPasswordEntry) = Res: Boolean; attribute (name = '_p_GetPasswordEntryByUID'); external;

{ Returns all password entries, or nil if none found. }
function  GetPasswordEntries = Res: PPasswordEntries; attribute (name = '_p_GetPasswordEntries'); external;

{ Dispose of a TPasswordEntry. }
procedure DisposePasswordEntry (Entry: TPasswordEntry); attribute (name = '_p_DisposePasswordEntry'); external;

{ Dispose of a PPasswordEntries. }
procedure DisposePasswordEntries (Entries: PPasswordEntries); attribute (name = '_p_DisposePasswordEntries'); external;

{ Returns the mount point (Unix) or drive (Dos) which is part of the
  given path. If the path does not contain any (i.e., is a relative
  path), an empty string is returned. Therefore, if you want to get
  the mount point or drive in any case, apply `FExpand' or
  `RealPath' to the argument. }
function  GetMountPoint (const Path: String) = Result: TString; attribute (name = '_p_GetMountPoint'); external;

type
  TSystemInfo = record
    OSName,
    OSRelease,
    OSVersion,
    MachineType,
    HostName,
    DomainName: TString
  end;

{ Returns system information if available. Fields not available will
  be empty. }
function  SystemInfo = Res: TSystemInfo; attribute (name = '_p_SystemInfo'); external;

{ Returns the path to the shell (as the result) and the option that
  makes it execute the command specified in the following argument
  (in `Option'). Usually these are the environment value of
  ShellEnvVar, and ShellExecCommand, but on Dos systems, the
  function will first try UnixShellEnvVar, and UnixShellExecCommand
  because ShellEnvVar will usually point to command.com, but
  UnixShellEnvVar can point to bash which is usually a better choice
  when present. If UnixShellEnvVar is not set, or the shell given
  does not exist, it will use ShellEnvVar, and ShellExecCommand.
  Option may be Null (in case you want to invoke the shell
  interactively). }
function  GetShellPath (var Option: String) = Res: TString; attribute (name = '_p_GetShellPath'); external;

{ Returns the path of the running executable. *Note*: On most
  systems, this is *not* guaranteed to be the full path, but often
  just the same as `ParamStr (0)' which usually is the name given on
  the command line. Only on some systems with special support, it
  returns the full path when `ParamStr (0)' doesn't. }
function  ExecutablePath: TString; attribute (name = '_p_ExecutablePath'); external;

{ Returns a file name suitable for a global (system-wide) or local
  (user-specific) configuration file, depending on the Global
  parameter. The function does not guarantee that the file name
  returned exists or is readable or writable.

  In the following table, the base name `<base>' is given with the
  BaseName parameter. If it is empty, the base name is the name of
  the running program (as returned by ExecutablePath, without
  directory and extension. `<prefix>' (Unix only) stands for the
  value of the Prefix parameter (usual values include '', '/usr' and
  '/usr/local'). `<dir>' (Dos only) stands for the directory where
  the running program resides. `$foo' stands for the value of the
  environment variable `foo'.

          Global                    Local
  Unix:   <prefix>/etc/<base>.conf  $HOME/.<base>

  DJGPP:  $DJDIR\etc\<base>.ini     $HOME\<base>.cfg
          <dir>\<base>.ini          <dir>\<base>.cfg

  Other   $HOME\<base>.ini          $HOME\<base>.cfg
    Dos:  <dir>\<base>.ini          <dir>\<base>.cfg

  As you see, there are two possibilities under Dos. If the first
  file exists, it is returned. Otherwise, if the second file exists,
  that is returned. If none of them exists (but the program might
  want to create a file), if the environment variable (DJDIR or
  HOME, respectively) is set, the first file name is returned,
  otherwise the second one. This rather complicated scheme should
  give the most reasonable results for systems with or without DJGPP
  installed, and with or without already existing config files. Note
  that DJDIR is always set on systems with DJGPP installed, while
  HOME is not. However, it is easy for users to set it if they want
  their config files in a certain directory rather than with the
  executables. }
function  ConfigFileName (const Prefix: String; const BaseName: String; Global: Boolean): TString; attribute (name = '_p_ConfigFileName'); external;

{ Returns a directory name suitable for global, machine-independent
  data. The function garantees that the name returned ends with a
  DirSeparator, but does not guarantee that it exists or is
  readable or writable.

  Note: If the prefix is empty, it is assumed to be '/usr'. (If you
  really want /share, you could pass '/' as the prefix, but that's
  very uncommon.)

  Unix:   <prefix>/share/<base>/

  DJGPP:  $DJDIR\share\<base>\
          <dir>\

  Other   $HOME\<base>\
    Dos:  <dir>\

  About the symbols used above, and the two possibilities under Dos,
  see the comments for ConfigFileName. }
function  DataDirectoryName (const Prefix: String; const BaseName: String): TString; attribute (name = '_p_DataDirectoryName'); external;

{ Executes a command line. Reports execution errors via the IOResult
  mechanism and returns the exit status of the executed program.
  Execute calls RestoreTerminal with the argument True before and
  False after executing the process, ExecuteNoTerminal does not. }
function  Execute (const CmdLine: String): Integer; attribute (iocritical, name = '_p_Execute'); external;
function  ExecuteNoTerminal (const CmdLine: String): Integer; attribute (iocritical, name = '_p_ExecuteNoTerminal'); external;

{ File handling routines, from files.pas }

type
  TextFile = Text;
  TOpenMode = (fo_None, fo_Reset, fo_Rewrite, fo_Append, fo_SeekRead, fo_SeekWrite, fo_SeekUpdate);
  PAnyFile = ^AnyFile;

  TOpenProc   = procedure (var PrivateData; Mode: TOpenMode);
  TSelectFunc = function  (var PrivateData; Writing: Boolean): Integer;  { called before SelectHandle, must return a file handle }
  TSelectProc = procedure (var PrivateData; var ReadSelect, WriteSelect, ExceptSelect: Boolean);  { called before and after SelectHandle }
  TReadFunc   = function  (var PrivateData; var   Buffer; Size: SizeType): SizeType;
  TWriteFunc  = function  (var PrivateData; const Buffer; Size: SizeType): SizeType;
  TFileProc   = procedure (var PrivateData);
  TFlushProc  = TFileProc;
  TCloseProc  = TFileProc;
  TDoneProc   = TFileProc;

{ Flags that can be `or'ed into FileMode. The default value of
  FileMode is FileMode_Reset_ReadWrite. The somewhat confusing
  numeric values are meant to be compatible to BP (as far as
  BP supports them). }
const
  { Allow writing to binary files opened with Reset }
  FileMode_Reset_ReadWrite      = 2;

  { Do not allow reading from files opened with Rewrite }
  FileMode_Rewrite_WriteOnly    = 4;

  { Do not allow reading from files opened with Extend }
  FileMode_Extend_WriteOnly     = 8;

  { Allow writing to text files opened with Reset }
  FileMode_Text_Reset_ReadWrite = $100;

var
  FileMode: Integer; attribute (name = '_p_FileMode'); external;

{ Get the external name of a file }
function  FileName (protected var f: GPC_FDR): TString; attribute (name = '_p_FileName'); external;

procedure IOErrorFile (n: Integer; protected var f: GPC_FDR; ErrNoFlag: Boolean); attribute (iocritical, name = '_p_IOErrorFile'); external;

procedure GetBinding (protected var f: GPC_FDR; var b: BindingType); attribute (name = '_p_GetBinding'); external;
procedure ClearBinding (var b: BindingType); attribute (name = '_p_ClearBinding'); external;

{ TFDD interface @@ Subject to change! Use with caution! }
procedure AssignTFDD (var f: GPC_FDR;
                      aOpenProc:    TOpenProc;
                      aSelectFunc:  TSelectFunc;
                      aSelectProc:  TSelectProc;
                      aReadFunc:    TReadFunc;
                      aWriteFunc:   TWriteFunc;
                      aFlushProc:   TFlushProc;
                      aCloseProc:   TCloseProc;
                      aDoneProc:    TDoneProc;
                      aPrivateData: Pointer);     attribute (name = '_p_AssignTFDD'); external;

procedure SetTFDD    (var f: GPC_FDR;
                      aOpenProc:    TOpenProc;
                      aSelectFunc:  TSelectFunc;
                      aSelectProc:  TSelectProc;
                      aReadFunc:    TReadFunc;
                      aWriteFunc:   TWriteFunc;
                      aFlushProc:   TFlushProc;
                      aCloseProc:   TCloseProc;
                      aDoneProc:    TDoneProc;
                      aPrivateData: Pointer);     attribute (name = '_p_SetTFDD'); external;

{ Any parameter except f may be Null }
procedure GetTFDD    (var f: GPC_FDR;
                      var aOpenProc:    TOpenProc;
                      var aSelectFunc:  TSelectFunc;
                      var aSelectProc:  TSelectProc;
                      var aReadFunc:    TReadFunc;
                      var aWriteFunc:   TWriteFunc;
                      var aFlushProc:   TFlushProc;
                      var aCloseProc:   TCloseProc;
                      var aDoneProc:    TDoneProc;
                      var aPrivateData: Pointer); attribute (name = '_p_GetTFDD'); external;

procedure FileMove (var f: GPC_FDR; NewName: CString; Overwrite: Boolean); attribute (iocritical, name = '_p_FileMove'); external;

const
  NoChange = -1;  { can be passed to ChOwn for Owner and/or Group to not change that value }

procedure CloseFile (var f: GPC_FDR); attribute (name = '_p_CloseFile'); external;
procedure ChMod (var f: GPC_FDR; Mode: Integer); attribute (iocritical, name = '_p_ChMod'); external;
procedure ChOwn (var f: GPC_FDR; Owner, Group: Integer); attribute (iocritical, name = '_p_ChOwn'); external;

{ Checks if data are available to be read from f. This is
  similar to `not EOF (f)', but does not block on "files" that
  can grow, like Ttys or pipes. }
function  CanRead (var f: GPC_FDR): Boolean; attribute (name = '_p_CanRead'); external;

{ Checks if data can be written to f. }
function  CanWrite (var f: GPC_FDR): Boolean; attribute (name = '_p_CanWrite'); external;

{ Get the file handle. }
function  FileHandle (protected var f: GPC_FDR): Integer; attribute (name = '_p_FileHandle'); external;

{ Lock/unlock a file. }
function  FileLock (var f: GPC_FDR; WriteLock, Block: Boolean): Boolean; attribute (name = '_p_FileLock'); external;
function  FileUnlock (var f: GPC_FDR): Boolean; attribute (name = '_p_FileUnlock'); external;

{ Try to map (a part of) a file to memory. }
function  MemoryMap (Start: Pointer; Length: SizeType; Access: Integer; Shared: Boolean;
                     var f: GPC_FDR; Offset: FileSizeType): Pointer; attribute (name = '_p_MemoryMap'); external;

{ Unmap a previous memory mapping. }
procedure MemoryUnMap (Start: Pointer; Length: SizeType); attribute (name = '_p_MemoryUnMap'); external;

type
  Natural = 1 .. MaxInt;
  IOSelectEvents = (SelectReadOrEOF, SelectRead, SelectEOF, SelectWrite, SelectException, SelectAlways);

type
  IOSelectType = record
    f: PAnyFile;
    Wanted: set of IOSelectEvents;
    Occurred: set of Low (IOSelectEvents) .. Pred (SelectAlways)
  end;

{ Waits for one of several events to happen. Returns when one or
  more of the wanted events for one of the files occur. If they have
  already occurred before calling the function, it returns
  immediately. MicroSeconds can specify a timeout. If it is 0, the
  function will return immediately, whether or not an event has
  occurred. If it is negative, the function will wait forever until
  an event occurs. The Events parameter can be Null, in which case
  the function only waits for the timeout. If any of the file
  pointers (f) in Events are nil or the files pointed to are closed,
  they are simply ignored for convenience.

  It returns the index of one of the files for which any event has
  occurred. If events have occurred for several files, is it
  undefined which of these file's index is returned. If no event
  occurs until the timeout, 0 is returned. If an error occurs or the
  target system does not have a `select' system call and Events is
  not Null, a negative value is returned. In the Occurred field of
  the elements of Events, events that have occurred are set. The
  state of events not wanted is undefined.

  The possible events are:
  SelectReadOrEOF: the file is at EOF or data can be read now.
  SelectRead:      data can be read now.
  SelectEOF:       the file is at EOF.
  SelectWrite:     data can be written now.
  SelectException: an exception occurred on the file.
  SelectAlways:    if this is set, *all* requested events will be
                   checked for this file in any case. Otherwise,
                   checks may be skipped if already another event
                   for this or another file was found.

  Notes:
  Checking for EOF requires some reading ahead internally (just like
  the EOF function) which can be avoided by setting SelectReadOrEOF
  instead of SelectRead and SelectEOF. If this is followed by, e.g.,
  a BlockRead with 4 parameters, the last parameter will be 0 if and
  only the file is at EOF, and otherwise, data will be read directly
  from the file without reading ahead and buffering.

  SelectAlways should be set for files whose events are considered
  to be of higher priority than others. Otherwise, if one is
  interested in just any event, not setting SelectAlways may be a
  little faster. }
function  IOSelect (var Events: array [m .. n: Natural] of IOSelectType; MicroSeconds: MicroSecondTimeType): Integer; attribute (name = '_p_IOSelect'); external;

{ A simpler interface to SelectIO for the most common use. Waits for
  SelectReadOrEOF on all files and returns an index. }
function  IOSelectRead (const Files: array [m .. n: Natural] of PAnyFile; MicroSeconds: MicroSecondTimeType): Integer; attribute (name = '_p_IOSelectRead'); external;

{ Bind a filename to an external file }
procedure AssignFile   (var t: AnyFile; const FileName: String); attribute (name = '_p_AssignFile'); external;
procedure AssignBinary (var t: Text; const FileName: String); attribute (name = '_p_AssignBinary'); external;
procedure AssignHandle (var t: AnyFile; Handle: Integer; CloseFlag: Boolean); attribute (name = '_p_AssignHandle'); external;

{ Under development }
procedure AnyStringTFDD_Reset (var f: GPC_FDR; var Buf: ConstAnyString); attribute (name = '_p_AnyStringTFDD_Reset'); external;
{ @@ procedure AnyStringTFDD_Rewrite (var f: GPC_FDR; var Buf: VarAnyString); attribute (name = '_p_AnyStringTFDD_Rewrite'); }
procedure StringTFDD_Reset (var f: GPC_FDR; var Buf: ConstAnyString; var s: array [m .. n: Integer] of Char); attribute (name = '_p_StringTFDD_Reset'); external;
{ @@ procedure StringTFDD_Rewrite (var f: GPC_FDR; var Buf: VarAnyString; var s: String); attribute (name = '_p_StringTFDD_Rewrite'); }

{ Returns True is a terminal device is open on the file f, False if
  f is not open or not connected to a terminal. }
function  IsTerminal (protected var f: GPC_FDR): Boolean; attribute (name = '_p_IsTerminal'); external;

{ Returns the file name of the terminal device that is open on the
  file f. Returns the empty string if (and only if) f is not open or
  not connected to a terminal. }
function  GetTerminalName (protected var f: GPC_FDR): TString; attribute (name = '_p_GetTerminalName'); external;

{ Command line option parsing, from getopt.pas }

const
  EndOfOptions      = #255;
  NoOption          = #1;
  UnknownOption     = '?';
  LongOption        = #0;
  UnknownLongOption = '?';

var
  FirstNonOption        : Integer; attribute (name = '_p_FirstNonOption'); external;
  HasOptionArgument     : Boolean; attribute (name = '_p_HasOptionArgument'); external;
  OptionArgument        : TString; attribute (name = '_p_OptionArgument'); external;
  UnknownOptionCharacter: Char; attribute (name = '_p_UnknownOptionCharacter'); external;
  GetOptErrorFlag       : Boolean; attribute (name = '_p_GetOptErrorFlag'); external;

{ Parses command line arguments for options and returns the next
  one.

  If a command line argument starts with `-', and is not exactly `-'
  or `--', then it is an option element. The characters of this
  element (aside from the initial `-') are option characters. If
  `GetOpt' is called repeatedly, it returns successively each of the
  option characters from each of the option elements.

  If `GetOpt' finds another option character, it returns that
  character, updating `FirstNonOption' and internal variables so
  that the next call to `GetOpt' can resume the scan with the
  following option character or command line argument.

  If there are no more option characters, `GetOpt' returns
  EndOfOptions. Then `FirstNonOption' is the index of the first
  command line argument that is not an option. (The command line
  arguments have been permuted so that those that are not options
  now come last.)

  OptString must be of the form `[+|-]abcd:e:f:g::h::i::'.

  a, b, c are options without arguments
  d, e, f are options with required arguments
  g, h, i are options with optional arguments

  Arguments are text following the option character in the same
  command line argument, or the text of the following command line
  argument. They are returned in OptionArgument. If an option has no
  argument, OptionArgument is empty. The variable HasOptionArgument
  tells whether an option has an argument. This is mostly useful for
  options with optional arguments, if one wants to distinguish an
  empty argument from no argument.

  If the first character of OptString is `+', GetOpt stops at the
  first non-option argument.

  If it is `-', GetOpt treats non-option arguments as options and
  return NoOption for them.

  Otherwise, GetOpt permutes arguments and handles all options,
  leaving all non-options at the end. However, if the environment
  variable POSIXLY_CORRECT is set, the default behaviour is to stop
  at the first non-option argument, as with `+'.

  The special argument `--' forces an end of option-scanning
  regardless of the first character of OptString. In the case of
  `-', only `--' can cause GetOpt to return EndOfOptions with
  FirstNonOption <= ParamCount.

  If an option character is seen that is not listed in OptString,
  UnknownOption is returned. The unrecognized option character is
  stored in UnknownOptionCharacter. Unless GetOptErrorFlag is set to
  False, an error message is printed to StdErr automatically. }
function  GetOpt (const OptString: String): Char; attribute (name = '_p_GetOpt'); external;

type
  OptArgType = (NoArgument, RequiredArgument, OptionalArgument);

  OptionType = record
    OptionName: CString;
    Argument  : OptArgType;
    Flag      : ^Char;  { if nil, v is returned. Otherwise, Flag^ is ... }
    v         : Char    { ... set to v, and LongOption is returned }
  end;

{ Recognize short options, described by OptString as above, and long
  options, described by LongOptions.

  Long-named options begin with `--' instead of `-'. Their names may
  be abbreviated as long as the abbreviation is unique or is an
  exact match for some defined option. If they have an argument, it
  follows the option name in the same argument, separated from the
  option name by a `=', or else the in next argument. When GetOpt
  finds a long-named option, it returns LongOption if that option's
  `Flag' field is non-nil, and the value of the option's `v' field
  if the `Flag' field is nil.

  LongIndex, if not Null, returns the index in LongOptions of the
  long-named option found. It is only valid when a long-named option
  has been found by the most recent call.

  If LongOnly is set, `-' as well as `--' can indicate a long
  option. If an option that starts with `-' (not `--') doesn't match
  a long option, but does match a short option, it is parsed as a
  short option instead. If an argument has the form `-f', where f is
  a valid short option, don't consider it an abbreviated form of a
  long option that starts with `f'. Otherwise there would be no way
  to give the `-f' short option. On the other hand, if there's a
  long option `fubar' and the argument is `-fu', do consider that an
  abbreviation of the long option, just like `--fu', and not `-f'
  with argument `u'. This distinction seems to be the most useful
  approach.

  As an additional feature (not present in the C counterpart), if
  the last character of OptString is `-' (after a possible starting
  `+' or `-' character), or OptString is empty, all long options
  with a nil `Flag' field will automatically be recognized as short
  options with the character given by the `v' field. This means, in
  the common (and recommended) case that all short options have long
  equivalents, you can simply pass an empty OptString (or pass `+-'
  or `--' as OptString if you want this behaviour, see the comment
  for GetOpt), and you will only have to maintain the LongOptions
  array when you add or change options. }
function  GetOptLong (const OptString: String; const LongOptions: array [m .. n: Integer] of OptionType { can be Null };
                      var LongIndex: Integer { can be Null }; LongOnly: Boolean): Char; attribute (name = '_p_GetOptLong'); external;

{ Reset GetOpt's state and make the next GetOpt or GetOptLong start
  (again) with the StartArgument'th argument (may be 1). This is
  useful for special purposes only. It is *necessary* to do this
  after altering the contents of CParamCount/CParameters (which is
  not usually done, either). }
procedure ResetGetOpt (StartArgument: Integer); attribute (name = '_p_ResetGetOpt'); external;

{ Set operations, from sets.pas }

{ All set operations are built-in identifiers and not declared in
  gpc.pas. }

{ Heap management routines, from heap.pas }

{ GPC implements both Mark/Release and Dispose. Both can be mixed
  freely in the same program. Dispose should be preferred, since
  it's faster. }

{ C heap management routines. NOTE: if Release is used anywhere in
  the program, CFreeMem and CReAllocMem may not be used for pointers
  that were not allocated with CGetMem. }
function  CGetMem     (Size: SizeType): Pointer;                       external name 'malloc';
procedure CFreeMem    (aPointer: Pointer);                             external name 'free';
function  CReAllocMem (aPointer: Pointer; NewSize: SizeType): Pointer; external name 'realloc';

type
  GetMemType     = ^function (Size: SizeType): Pointer;
  FreeMemType    = ^procedure (aPointer: Pointer);
  ReAllocMemType = ^function (aPointer: Pointer; NewSize: SizeType): Pointer;

{ These variables can be set to user-defined routines for memory
  allocation/deallocation. GetMemPtr may return nil when
  insufficient memory is available. GetMem/New will produce a
  runtime error then. }
var
  GetMemPtr    : GetMemType;     attribute (name = '_p_GetMemPtr'); external;
  FreeMemPtr   : FreeMemType;    attribute (name = '_p_FreeMemPtr'); external;
  ReAllocMemPtr: ReAllocMemType; attribute (name = '_p_ReAllocMemPtr'); external;

  { Address of the lowest byte of heap used }
  HeapLow: PtrCard; attribute (name = '_p_HeapLow'); external;

  { Address of the highest byte of heap used }
  HeapHigh: PtrCard; attribute (name = '_p_HeapHigh'); external;

  { If set to true, `Dispose' etc. will raise a runtime error if
    given an invalid pointer. }
  HeapChecking: Boolean; attribute (name = '_p_HeapChecking'); external;

const
  UndocumentedReturnNil = Pointer (-1);

function  SuspendMark: Pointer;    attribute (name = '_p_SuspendMark'); external;
procedure ResumeMark (p: Pointer); attribute (name = '_p_ResumeMark'); external;

{ Calls the procedure Proc for each block that would be released
  with `Release (aMark)'. aMark must have been marked with Mark. For
  an example of its usage, see the HeapMon unit. }
procedure ForEachMarkedBlock (aMark: Pointer; procedure Proc (aPointer: Pointer; aSize: SizeType; aCaller: Pointer)); attribute (name = '_p_ForEachMarkedBlock'); external;

procedure ReAllocMem (var aPointer: Pointer; NewSize: SizeType); attribute (name = '_p_ReAllocMem'); external;

{ Memory transfer procedures, from move.pas }

{ The move operations are built-in identifiers and not declared in
  gpc.pas. }

{ Routines to handle endianness, from endian.pas }

{ Boolean constants about endianness and alignment }

const
  BitsBigEndian  = {$ifdef __BITS_LITTLE_ENDIAN__}
                   False
                   {$elif defined (__BITS_BIG_ENDIAN__)}
                   True
                   {$else}
                   {$error Bit endianness is not defined!}
                   {$endif};

  BytesBigEndian = {$ifdef __BYTES_LITTLE_ENDIAN__}
                   False
                   {$elif defined (__BYTES_BIG_ENDIAN__)}
                   True
                   {$else}
                   {$error Byte endianness is not defined!}
                   {$endif};

  WordsBigEndian = {$ifdef __WORDS_LITTLE_ENDIAN__}
                   False
                   {$elif defined (__WORDS_BIG_ENDIAN__)}
                   True
                   {$else}
                   {$error Word endianness is not defined!}
                   {$endif};

  NeedAlignment  = {$ifdef __NEED_ALIGNMENT__}
                   True
                   {$elif defined (__NEED_NO_ALIGNMENT__)}
                   False
                   {$else}
                   {$error Alignment is not defined!}
                   {$endif};

{ Convert single variables from or to little or big endian format.
  This only works for a single variable or a plain array of a simple
  type. For more complicated structures, this has to be done for
  each component separately! Currently, ConvertFromFooEndian and
  ConvertToFooEndian are the same, but this might not be the case on
  middle-endian machines. Therefore, we provide different names. }
procedure ReverseBytes            (var Buf; ElementSize, Count: SizeType); attribute (name = '_p_ReverseBytes'); external;
procedure ConvertFromLittleEndian (var Buf; ElementSize, Count: SizeType); attribute (name = '_p_ConvertLittleEndian'); external;
procedure ConvertFromBigEndian    (var Buf; ElementSize, Count: SizeType); attribute (name = '_p_ConvertBigEndian'); external;
procedure ConvertToLittleEndian   (var Buf; ElementSize, Count: SizeType); external name '_p_ConvertLittleEndian';
procedure ConvertToBigEndian      (var Buf; ElementSize, Count: SizeType); external name '_p_ConvertBigEndian';

{ Read a block from a file and convert it from little or
  big endian format. This only works for a single variable or a
  plain array of a simple type, note the comment for
  `ConvertFromLittleEndian' and `ConvertFromBigEndian'. }
procedure BlockReadLittleEndian   (var aFile: File; var   Buf; ElementSize, Count: SizeType); attribute (iocritical, name = '_p_BlockRead_LittleEndian'); external;
procedure BlockReadBigEndian      (var aFile: File; var   Buf; ElementSize, Count: SizeType); attribute (iocritical, name = '_p_BlockRead_BigEndian'); external;

{ Write a block variable to a file and convert it to little or big
  endian format before. This only works for a single variable or a
  plain array of a simple type. Apart from this, note the comment
  for `ConvertToLittleEndian' and `ConvertToBigEndian'. }
procedure BlockWriteLittleEndian  (var aFile: File; const Buf; ElementSize, Count: SizeType); attribute (iocritical, name = '_p_BlockWrite_LittleEndian'); external;
procedure BlockWriteBigEndian     (var aFile: File; const Buf; ElementSize, Count: SizeType); attribute (iocritical, name = '_p_BlockWrite_BigEndian'); external;

{ Read and write strings from/to binary files, where the length is
  stored in the given endianness and with a fixed size (64 bits),
  and therefore is independent of the system. }
procedure ReadStringLittleEndian  (var f: File; var s: String);   attribute (iocritical, name = '_p_ReadStringLittleEndian'); external;
procedure ReadStringBigEndian     (var f: File; var s: String);   attribute (iocritical, name = '_p_ReadStringBigEndian'); external;
procedure WriteStringLittleEndian (var f: File; const s: String); attribute (iocritical, name = '_p_WriteStringLittleEndian'); external;
procedure WriteStringBigEndian    (var f: File; const s: String); attribute (iocritical, name = '_p_WriteStringBigEndian'); external;

{ Initialization, from init.pas }

{ Initialize the GPC Run Time System. This is normally called
  automatically. Call it manually only in very special situations.
  ArgumentCount, Arguments are argc and argv in C; StartEnvironment
  is the environment variable pointer, and can be nil if other ways
  to obtain the environment are available. Options can be 0 or a
  combination of ro_* flags as defined in rts/constants.def. }
procedure GPC_Initialize (ArgumentCount: CInteger;
                          Arguments, StartEnvironment: PCStrings;
                          Options: CInteger);
                          attribute (name = '_p_initialize'); external;

var
  InitProc: ^procedure; attribute (name = '_p_InitProc'); external;

end;

{$ifndef HAVE_NO_RTS_CONFIG_H}
{$include "rts-config.inc"}
{$endif}
{$ifdef HAVE_LIBOS_HACKS}
{$L os-hacks}
{$endif}

end.
