{ Runtime error and signal handling routines

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

unit Error; attribute (name = '_p__rts_Error');

interface

uses RTSC, String1;

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
  ExitCode: Integer = 0; attribute (name = '_p_ExitCode');

  { Contains the address of the code where a runtime occurred, nil
    if no runtime error occurred. }
  ErrorAddr: Pointer = nil; attribute (name = '_p_ErrorAddr');

  { Error message }
  ErrorMessageString: TString; attribute (name = '_p_ErrorMessageString');

  { String parameter to some error messages, *not* the text of the
    error message (the latter can be obtained with
    GetErrorMessage). }
  InOutResString: PString = nil; attribute (name = '_p_InOutResString');

  { Optional libc error string to some error messages. }
  InOutResCErrorString: PString = nil; attribute (name = '_p_InOutResCErrorString');

  RTSErrorFD: Integer = -1;          attribute (name = '_p_ErrorFD');
  RTSErrorFileName: PString = nil;   attribute (name = '_p_ErrorFileName');

{@internal}
  { BP compatible InOutRes variable }
  GPC_InOutRes: Integer = 0; attribute (name = '_p_InOutRes');

  RTSOptions: Integer = 0; attribute (name = '_p_RTSOptions');
  RTSWarnFlag: Boolean = False; attribute (name = '_p_RTSWarnFlag');
  AbortOnError: Boolean = False; attribute (name = '_p_AbortOnError');

  CurrentReturnAddr: Pointer = nil; attribute (name = '_p_CurrentReturnAddr');
  CurrentReturnAddrCounter: Integer = 0; attribute (name = '_p_CurrentReturnAddrCounter');

procedure HeapWarning                     (s: CString);                            attribute (name = '_p_HeapWarning');  { For GNU malloc }
procedure GPC_RunError                    (n: Integer);                            attribute (noreturn, name = '_p_RunError');
procedure StartTempIOError;                                                        attribute (name = '_p_StartTempIOError');
function  EndTempIOError: Integer;                                                 attribute (name = '_p_EndTempIOError');
function  GPC_IOResult: Integer;                                                   attribute (inline, name = '_p_IOResult');
procedure GPC_Halt (aExitCode: Integer);                                           attribute (noreturn, name = '_p_Halt');
{@endinternal}

{ Finalize the GPC Run Time System. This is normally called
  automatically. Call it manually only in very special situations. }
procedure GPC_Finalize;
   attribute (name = '_p_finalize');
function  GetErrorMessage                 (n: Integer): CString;                   attribute (name = '_p_GetErrorMessage');
procedure RuntimeError                    (n: Integer);                            attribute (noreturn, name = '_p_RuntimeError');
procedure RuntimeErrorErrNo               (n: Integer);                            attribute (noreturn, name = '_p_RuntimeErrorErrNo');
procedure RuntimeErrorInteger             (n: Integer; i: MedInt);                 attribute (noreturn, name = '_p_RuntimeErrorInteger');
procedure RuntimeErrorCString             (n: Integer; s: CString);                attribute (noreturn, name = '_p_RuntimeErrorCString');
procedure InternalError                   (n: Integer);                            attribute (noreturn, name = '_p_InternalError');
procedure InternalErrorInteger            (n: Integer; i: MedInt);                 attribute (noreturn, name = '_p_InternalErrorInteger');
procedure InternalErrorCString            (n: Integer; s: CString);                attribute (noreturn, name = '_p_InternalErrorCString');
procedure RuntimeWarning                  (Message: CString);                      attribute (name = '_p_RuntimeWarning');
procedure RuntimeWarningInteger           (Message: CString; i: MedInt);           attribute (name = '_p_RuntimeWarningInteger');
procedure RuntimeWarningCString           (Message: CString; s: CString);          attribute (name = '_p_RuntimeWarningCString');

procedure IOError                         (n: Integer; ErrNoFlag: Boolean);                           attribute (iocritical, name = '_p_IOError');
procedure IOErrorInteger                  (n: Integer; i: MedInt; ErrNoFlag: Boolean);                attribute (iocritical, name = '_p_IOErrorInteger');
procedure IOErrorCString                  (n: Integer; s: CString; ErrNoFlag: Boolean);               attribute (iocritical, name = '_p_IOErrorCString');

function  GetIOErrorMessage = Res: TString;                                        attribute (name = '_p_GetIOErrorMessage');
procedure CheckInOutRes;                                                           attribute (name = '_p_CheckInOutRes');

{ Registers a procedure to be called to restore the terminal for
  another process that accesses the terminal, or back for the
  program itself. Used e.g. by the CRT unit. The procedures must
  allow for being called multiple times in any order, even at the
  end of the program (see the comment for RestoreTerminal). }
procedure RegisterRestoreTerminal (ForAnotherProcess: Boolean; procedure Proc); attribute (name = '_p_RegisterRestoreTerminal');

{ Unregisters a procedure registered with RegisterRestoreTerminal.
  Returns False if the procedure had not been registered, and True
  if it had been registered and was unregistered successfully. }
function  UnregisterRestoreTerminal (ForAnotherProcess: Boolean; procedure Proc): Boolean; attribute (name = '_p_UnregisterRestoreTerminal');

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
procedure RestoreTerminal (ForAnotherProcess: Boolean); attribute (name = '_p_RestoreTerminal');

procedure AtExit (procedure Proc); attribute (name = '_p_AtExit');

function  ReturnAddr2Hex (p: Pointer) = s: TString; attribute (name = '_p_ReturnAddr2Hex');

{ This function is used to write error messages etc. It does not use
  the Pascal I/O system here because it is usually called at the
  very end of a program after the Pascal I/O system has been shut
  down. }
function  WriteErrorMessage (const s: String; StdErrFlag: Boolean): Boolean; attribute (name = '_p_WriteErrorMessage');

procedure SetReturnAddress (Address: Pointer); attribute (name = '_p_SetReturnAddress');
procedure RestoreReturnAddress; attribute (name = '_p_RestoreReturnAddress');

{ Returns a description for a signal }
function  StrSignal (Signal: Integer) = Res: TString; attribute (name = '_p_StrSignal');

{ Installs some signal handlers that cause runtime errors on certain
  signals. This procedure runs only once, and returns immediately
  when called again (so you can't use it to set the signals again if
  you changed them meanwhile). @@Does not work on all systems (since
  the handler might have too little stack space). }
procedure InstallDefaultSignalHandlers; attribute (name = '_p_InstallDefaultSignalHandlers');

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
procedure GPC_Assert (Condition: Boolean; const Message: String); attribute (name = '_p_Assert');
function  ObjectTypeIs (Left, Right: PObjectType): Boolean; attribute (const, name = '_p_ObjectTypeIs');
procedure ObjectTypeAsError;                attribute (noreturn, name = '_p_ObjectTypeAsError');
procedure DisposeNilError;                  attribute (noreturn, name = '_p_DisposeNilError');
procedure CaseNoMatchError;                 attribute (noreturn, name = '_p_CaseNoMatchError');
procedure DiscriminantsMismatchError;       attribute (noreturn, name = '_p_DiscriminantsMismatchError');
procedure NilPointerError;                  attribute (noreturn, name = '_p_NilPointerError');
procedure InvalidPointerError (p: Pointer); attribute (noreturn, name = '_p_InvalidPointerError');
procedure InvalidObjectError;               attribute (noreturn, name = '_p_InvalidObjectError');
procedure RangeCheckError;                  attribute (noreturn, name = '_p_RangeCheckError');
procedure IORangeCheckError;                attribute (name = '_p_IORangeCheckError');
procedure SubrangeError;                    attribute (noreturn, name = '_p_SubrangeError');
procedure ModRangeError;                    attribute (noreturn, name = '_p_ModRangeError');

{ Pointer checking with `--pointer-checking-user-defined' }

procedure DefaultValidatePointer (p: Pointer); attribute (name = '_p_DefaultValidatePointer');

type
  ValidatePointerType = ^procedure (p: Pointer);

var
  ValidatePointerPtr: ValidatePointerType = @DefaultValidatePointer; attribute (name = '_p_ValidatePointerPtr');

implementation

{$ifndef HAVE_NO_RTS_CONFIG_H}
{$include "rts-config.inc"}
{$endif}

uses Heap;

{ @@ from files.pas }
function  FileHandle (protected var pf: AnyFile): Integer; external name '_p_FileHandle';
procedure FlushAllFiles; external name '_p_FlushAllFiles';
procedure Done_Files; external name '_p_Done_Files';

const
  InternalErrorString = 'internal error: ';

  ErrorMessages: array [1 .. 182] of record
    Number: Integer;
    Message: CString
  end =
  (
    { Note: use just `%' for the optional argument to the messages.
      The errors are not written using one of the `printf' functions
      anymore, but a more Pascalish formatting that gets knowledge
      about the type of the argument from its caller. Any character
      following the `%' becomes part of the actual error message! }

    { Leave the `Byte' range free for program specific errors. }

    { Signal handlers }
    (257, 'hangup signal received'),
    (258, 'interrupt signal received'),
    (259, 'quit signal received'),
    (260, 'invalid instruction signal received'),
    (261, 'trap signal received'),
    (262, 'I/O trap signal received'),
    (263, 'emulator trap signal received'),
    (264, 'floating point exception signal received'),
    (266, 'bus error signal received'),
    (267, 'segmentation fault signal received'),
    (268, 'bad system call signal received'),
    (269, 'broken pipe signal received'),
    (270, 'alarm signal received'),
    (271, 'termination signal received'),

    { Range/type checking errors and assertions }
    (300, 'value out of range'),
    (301, 'invalid subrange size'),
    (302, 'set element out of range'),
    (303, 'range error in set constructor'),
    (304, '`case'' selector value matches no case constant'),
    (305, 'left operand of `as'' is not of required type'),
    (306, 'assertion failed'),
    (307, 'assertion `%'' failed'),
    (308, 'actual schema discriminants do not match'),
  { (309, 'variant access error'),
    (310, 'attempt to use an undefined value'), }

    { I/O errors (range 400 .. 699) that are handled via InOutRes }

    { I/O errors: File and general I/O errors }
    { For errors raised with IOERROR_FILE, the "%" will be replaced by
      "file `foo.bar'" for external files or "internal file `foo'" for internal
      files, so don't include "file" or quotes in the error message. }
    (400, 'file buffer size of % must be > 0'),
    (401, 'cannot open directory `%'''),
    (402, '`Bind'' applied to non-bindable %'),
    (403, '`Binding'' applied to non-bindable %'),
    (404, '`Unbind'' applied to non-bindable %'),
    (405, 'cannot open `%'''),
    (406, 'attempt to read past end of random access %'),
    (407, '% has not been opened'),
    (408, 'cannot map % into memory'),
    (409, 'cannot unmap memory'),
    (410, 'attempt to access elements before beginning of random access %'),
    (413, 'read error'),
    (414, 'write error'),
    (415, 'cannot read all the data from % in `BlockRead'''),
    (416, '`Extend'' could not seek to end of %'),
    (417, '`Position'' or `FilePos'' could not get file position of %'),
    (418, 'error while closing %'),
    (419, 'cannot prompt user for external file name for %'),
    (420, 'cannot query user for external file name for %'),
    (421, 'EOT character given for query of file name for %'),
    (422, 'cannot write to read only %'),
    (425, 'truncation failed for %'),
    (427, '`SeekRead'' failed on %'),
    (428, '`SeekRead'' failed to reset position of %'),
    (429, '`SeekWrite'' failed on %'),
    (431, '`SeekUpdate'' failed on %'),
    (432, '`SeekUpdate'' failed to reset position of %'),
    (433, '`Update'' failed to reset the position of %'),
    (436, '`Reset'', `SeekUpdate'' or `SeekRead'' to nonexistent %'),
    (437, 'new file size in `DefineSize'' is < 0'),
    (438, '`Truncate'' or `DefineSize'' applied to read only %'),
    (439, '`Update'' with an undefined buffer in %'),
    (440, 'reference to buffer variable of % with undefined value'),
    (441, 'file already bound to `%'''),
    (442, 'cannot open % for reading'),
    (443, 'cannot open % for writing'),
    (444, 'cannot open % for updating'),
    (445, 'cannot extend %'),
    (446, 'cannot get the size of %'),
    (450, '% is not open for writing'),
    (452, '% is not open for reading'),
    (453, '% is not open'),
    (454, 'attempt to read past end of %'),
    (455, '`EOF'' tested for unopened %'),
    (456, '`EOLn'' tested for unopened %'),
    (457, '`EOLn'' tested for % when `EOF'' is True'),
    (458, '`EOLn'' applied to a non-text %'),
  { (460, '% not found'),
    (461, 'cannot access %'),
    (462, 'attempt to open % as external'),
    (463, '% is write protected'), }
    (464, 'error when reading from %'),
    (465, 'cannot read all the data from %'),
    (466, 'error when writing to %'),
    (467, 'cannot write all the data to %'),
    (468, 'cannot erase %'),
    (469, '`Erase'': external file `%'' has no external name'),
    (473, '`Erase'': cannot erase directory `%'''),
    (474, 'error when trying to erase %'),
    (475, 'cannot rename %'),
    (476, '`Rename/FileMove'': external file `%'' has no external name'),
    (477, 'cannot rename opened %'),
    (481, 'error when trying to rename %'),
    (482, '`Rename'': cannot overwrite file `%'''),
    (483, 'cannot change to directory `%'''),
    (484, 'cannot make directory `%'''),
    (485, 'cannot remove directory `%'''),
    (486, '`SetFTime'': file `%'' has no external name'),
    (487, 'cannot set time for %'),
    (488, '`Execute'': cannot execute program'),
    (491, '`ChMod'': file `%'' has no external name'),
    (494, 'error when trying to change mode of %'),
    (495, 'cannot open directory `%'''),
    (497, 'no temporary file name found'),
    (498, '`ChOwn'': file `%'' has no external name'),
    (499, 'error when trying to change owner of %'),

    { I/O errors: Read errors }
    (550, 'attempt to read past end of string in `ReadStr'''),
    (551, 'digit expected after sign'),
    (552, 'sign or digit expected'),
    (553, 'overflow while reading integer'),
    (554, 'digit expected after decimal point'),
    (555, 'digit expected while reading exponent'),
    (556, 'exponent out of range'),
    (557, 'digit expected after `$'' in integer constant'),
    (558, 'digit expected after `#'' in integer constant'),
    (559, 'only one base specifier allowed in integer constant'),
    (560, 'base out of range (2 .. 36)'),
    (561, 'invalid digit'),
    (562, 'digit or `.'' expected after sign'),
    (563, 'overflow while reading real number'),
    (564, 'underflow while reading real number'),
    (565, 'invalid Boolean value read'),
    (566, 'invalid enumaration value read'),
    (567, 'value read out of range'),

    { I/O errors: Write errors }
    (580, 'fixed field width cannot be negative'),
    (581, 'fixed field width must be positive'),  { CP }
    (582, 'fixed real fraction field width cannot be negative'),
    (583, 'fixed real fraction field width must be positive'),  { CP }
    (584, 'string capacity exceeded in `WriteStr'''),

    { I/O errors: device specific errors }
    (600, 'cannot fork program `%'''),
    (601, 'cannot spawn `%'''),
    (602, 'program `%'' not found'),
    (603, 'program `%'' not executable'),
    (604, 'cannot create pipe to program `%'''),

    (610, 'printer can only be opened for writing'),
    (620, 'unknown serial port #%'),
    (621, 'serial port #% cannot be opened'),
    (630, 'error % in ioctl'),

    { Mathematical errors }
    (700, 'error in exponentiation'),
    (701, 'left operand of `**'' is negative'),
    (702, 'left argument of `**'' is 0 while right argument is <= 0'),
    (703, 'left argument of `pow'' is 0 while right argument is <= 0'),
    (704, 'cannot take `Arg'' of zero'),
    (707, 'argument to `Ln'' is <= 0'),
    (708, 'argument to `SqRt'' is < 0'),
    (711, 'floating point division by zero'),
    (712, 'integer division by 0'),
    (713, 'integer overflow'),
    (714, 'second operand of `mod'' is <= 0'),
    (715, 'floating point overflow'),
    (716, 'floating point underflow'),
    (717, 'decimal overflow'),
    (718, 'subscript error'),

    { Time and date errors }
    (750, 'invalid date supplied to library function `Date'''),
    (751, 'invalid time supplied to library function `Time'''),

    { String errors (except string I/O errors) }
    (800, 'string too long in `Insert'''),
    (801, 'substring cannot start from a position less than 1'),
    (802, 'substring length cannot be negative'),
    (803, 'substring must terminate before end of string'),
    (806, 'string too long'),

    { Memory management errors }
    (850, 'stack overflow'),
    (851, 'heap overflow'),
    (852, 'address % is not valid for `Release'''),
    (853, 'out of heap when allocating % bytes'),
    (854, 'out of heap when reallocating % bytes'),
    (855, 'attempt to dereference nil pointer'),
    (856, 'attempt to dereference invalid pointer with address %'),
    (857, 'attempt to dispose nil pointer'),
    (858, 'attempt to dispose of invalid pointer with address %'),
  { (859, 'attempt to use disposed pointer'), }
    (860, 'attempt to map unmappable memory'),
    (861, 'object is invalid'),

    { Errors for units }
    (870, 'BP compatible 6 byte `Real'' type does not support NaN values'),
    (871, 'BP compatible 6 byte `Real'' type does not support infinity'),
    (872, 'underflow while converting to BP compatible 6 byte `Real'' type'),
    (873, 'overflow while converting to BP compatible 6 byte `Real'' type'),
    (874, 'cannot convert denormalized number to BP compatible 6 byte `Real'' type'),
    (875, 'cannot convert string to an integer'),

    (880, 'CRT was not initialized'),
    (881, 'CRT: error opening terminal'),
    (882, 'attempt to delete invalid CRT panel'),
    (883, 'attempt to delete last CRT panel'),
    (884, 'attempt to activate invalid CRT panel'),
    (885, 'CRT: input error'),

    { Internal errors }
    (900, 'internal error in `%'''),
    (901, 'string capacity cannot be negative'),
    (902, 'endianness incorrectly defined');
    (904, 'invalid file open mode');
    (905, 'file has no internal name'),
    (906, '`InitFDR'' has not been called for file'),

    { Internal errors for units }
    (950, 'CRT: cannot initialize curses'),
    (951, 'cannot create CRT window'),
    (952, 'library function `%'' missing'),
    (953, '`_exit'' returned')
  ); attribute (name = '_p_ErrorMessages');

  SignalTable: array [1 .. 21] of record
    Signal, Code: ^const Integer;
    ErrorNumber: Integer  { negative if warning }
  end =
  (
    (@SigHUp,  nil, 257),
    (@SigInt,  nil, 258),
    (@SigQuit, nil, 259),
    (@SigIll,  nil, 260),
    (@SigFPE,  @FPEIntegerOverflow,        713),
    (@SigFPE,  @FPEIntegerDivisionByZero,  712),
    (@SigFPE,  @FPESubscriptRange,         718),
    (@SigFPE,  @FPERealOverflow,           715),
    (@SigFPE,  @FPERealDivisionByZero,     711),
    (@SigFPE,  @FPERealUnderflow,         -716),
    (@SigFPE,  @FPEDecimalOverflow,        717),
    (@SigFPE,  nil, 264),
    (@SigSegV, nil, 267),
    (@SigPipe, nil, 269),
    (@SigAlrm, nil, 270),
    (@SigTerm, nil, 271),
    (@SigTrap, nil, 261),
    (@SigIOT,  nil, 262),
    (@SigEMT,  nil, 263),
    (@SigBus,  nil, 266),
    (@SigSys,  nil, 268)
  ); attribute (name = '_p_SignalTable');

var
  TempIOErrorFlag: Boolean = False; attribute (name = '_p_TempIOErrorFlag');
  TempInOutRes: Integer = 0; attribute (name = '_p_TempInOutRes');

procedure GPC_Assert (Condition: Boolean; const Message: String);
begin
  if not Condition then
    if Message = '' then
      RuntimeError (EAssert)
    else
      RuntimeErrorCString (EAssertString, Message)
end;

function ObjectTypeIs (Left, Right: PObjectType): Boolean;
begin
  while (Left <> nil) and (Left <> Right) do Left := Left^.Parent;
  ObjectTypeIs := Left <> nil
end;

procedure ObjectTypeAsError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (305);  { left operand of `as'' is not of required type }
  RestoreReturnAddress
end;

procedure DisposeNilError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (857);  { attempt to dispose nil pointer }
  RestoreReturnAddress
end;

procedure CaseNoMatchError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (304);  { `case'' selector value matches no case constant }
  RestoreReturnAddress
end;

procedure DiscriminantsMismatchError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (308);  { actual schema discriminants do not match }
  RestoreReturnAddress
end;

procedure NilPointerError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (855);  { attempt to dereference nil pointer }
  RestoreReturnAddress
end;

procedure InvalidPointerError (p: Pointer);
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeErrorInteger (856, PtrInt (p));  { attempt to dereference invalid pointer with address % }
  RestoreReturnAddress
end;

procedure DefaultValidatePointer (p: Pointer);
begin
  if p = nil then NilPointerError
end;

procedure InvalidObjectError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (861);  { object is invalid }
  RestoreReturnAddress
end;

procedure RangeCheckError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (300);  { value out of range }
  RestoreReturnAddress
end;

procedure IORangeCheckError;
begin
  IOError (567, False)  { value read out of range }
end;

procedure SubrangeError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (301);  { invalid subrange size }
  RestoreReturnAddress
end;

procedure ModRangeError;
begin
  SetReturnAddress (ReturnAddress (0));
  RuntimeError (714);  { second operand of `mod'' is <= 0 }
  RestoreReturnAddress
end;

function GetErrorMessage (n: Integer): CString;
var i: Integer;
begin
  for i := Low (ErrorMessages) to High (ErrorMessages) do
    if ErrorMessages[i].Number = n then Return ErrorMessages[i].Message;
  GetErrorMessage := 'internal error: unknown error code'
end;

{ Very simple replacement for `sprintf'. This function is probably
  not very useful for general purposes, and is therefore not
  exported. It's only here to format the error messages above. }
function FormatStr (Format: CString; const Argument: String) = s: TString;
var i: Integer;
begin
  s := CString2String (Format);
  i := Pos ('%', s);
  if i = 0 then
    s := 'internal error: error handling was called incorrectly: ' + s + ' (' + Argument + ')'
  else
    begin
      Delete (s, i, 1);
      Insert (Argument, s, i)
    end
end;

function StartRuntimeWarning = Result: Boolean;
begin
  Result := RTSWarnFlag;
  if Result then Write (StdErr, ParamStr (0), ': warning: ')
end;

procedure RuntimeWarning (Message: CString { @@ stack problem });
begin
{$local cstrings-as-strings}
  if StartRuntimeWarning then WriteLn (StdErr, Message)
{$endlocal}
end;

procedure RuntimeWarningInteger (Message: CString; i: MedInt);
begin
  if StartRuntimeWarning then
    WriteLn (StdErr, FormatStr (Message, Integer2String (i)))
end;

procedure RuntimeWarningCString (Message: CString; s: CString);
begin
  if StartRuntimeWarning then
    WriteLn (StdErr, FormatStr (Message, CString2String (s)))
end;

procedure HeapWarning (s: CString);
begin
  RuntimeWarningCString ('heap warning: %', s)
end;

var
  RestoreTerminalProcs: array [Boolean] of PProcList = (nil, nil); attribute (name = '_p_RestoreTerminalProcs');
  AtExitProcs: PProcList = nil; attribute (name = '_p_AtExitProcs');

procedure InsertProcList (var List: PProcList; procedure Proc);
var p: PProcList;
begin
  p := InternalNew (SizeOf (p^));
  p^.Proc := @Proc;
  p^.Prev := nil;
  p^.Next := List;
  if p^.Next <> nil then p^.Next^.Prev := p;
  List := p
end;

procedure RegisterRestoreTerminal (ForAnotherProcess: Boolean; procedure Proc);
begin
  InsertProcList (RestoreTerminalProcs[ForAnotherProcess], Proc)
end;

function UnregisterRestoreTerminal (ForAnotherProcess: Boolean; procedure Proc): Boolean;
var p: PProcList;
begin
  p := RestoreTerminalProcs[ForAnotherProcess];
  while (p <> nil) and (p^.Proc <> @Proc) do p := p^.Next;
  if p = nil then
    UnregisterRestoreTerminal := False
  else
    begin
      if p^.Next <> nil then p^.Next^.Prev := p^.Prev;
      if p^.Prev = nil then
        RestoreTerminalProcs[ForAnotherProcess] := p^.Next
      else
        p^.Prev^.Next := p^.Next;
      InternalDispose (p);
      UnregisterRestoreTerminal := True
    end
end;

procedure RestoreTerminal (ForAnotherProcess: Boolean);
var p: PProcList;
begin
  SetReturnAddress (ReturnAddress (0));
  p := RestoreTerminalProcs[ForAnotherProcess];
  if ForAnotherProcess then
    while p <> nil do
      begin
        p^.Proc^;
        p := p^.Next
      end
  else if p <> nil then
    begin
      while p^.Next <> nil do p := p^.Next;
      while p <> nil do
        begin
          p^.Proc^;
          p := p^.Prev
        end
    end;
  RestoreReturnAddress
end;

procedure AtExit (procedure Proc);
begin
  InsertProcList (AtExitProcs, Proc)
end;

function ReturnAddr2Hex (p: Pointer) = s: TString;
var i, j: PtrCard;
begin
  s := '';
  { Subtract 1 to get a pointer to the last byte of the corresponding call
    instruction. This might not be fool-proof, but perhaps the best we can do. }
  i := PtrCard (p) - 1;
  j := 1;
  while j <= i div $10 do
    j := $10 * j;
  while j > 0 do
    begin
      s := s + NumericBaseDigits[i div j];
      i := i mod j;
      j := j div $10
    end
end;

function WriteErrorMessage (const s: String; StdErrFlag: Boolean): Boolean;
var Handle: Integer;
begin
  if StdErrFlag then
    begin
      Handle := FileHandle (StdErr);
      if Handle < 0 then Handle := 2
    end
  else
    begin
      if (RTSErrorFD < 0) and (RTSErrorFileName <> nil) then
        begin
          RTSErrorFD := OpenHandle (RTSErrorFileName^, MODE_WRITE or MODE_CREATE or MODE_TRUNCATE);
          InternalDispose (RTSErrorFileName);
          RTSErrorFileName := nil
        end;
      Handle := RTSErrorFD
    end;
  WriteErrorMessage := (Handle >= 0) and ((s = '') or (WriteHandle (Handle, @s[1], Length (s)) >= 0))
end;

procedure WriteStackDump;
var
  i: Integer { @@false warning } = 0;
  a: Pointer { @@false warning } = nil;
begin
  Discard (WriteErrorMessage (ParamStr (0) + ': ' + ErrorMessageString + NewLine, True));
  i := 0;
  if WriteErrorMessage (ErrorMessageString + NewLine, False) and
     WriteErrorMessage (ReturnAddr2Hex (ErrorAddr) + NewLine, False) and
     WriteErrorMessage ('Routines called:' + NewLine, False) then
    repeat
      case i of
         0: a := ReturnAddress  (0);
        {$ifdef HAVE_RETURN_ADDRESS_NON_ZERO}
         1: a := ReturnAddress  (1);
         2: a := ReturnAddress  (2);
         3: a := ReturnAddress  (3);
         4: a := ReturnAddress  (4);
         5: a := ReturnAddress  (5);
         6: a := ReturnAddress  (6);
         7: a := ReturnAddress  (7);
         8: a := ReturnAddress  (8);
         9: a := ReturnAddress  (9);
        10: a := ReturnAddress (10);
        11: a := ReturnAddress (11);
        12: a := ReturnAddress (12);
        13: a := ReturnAddress (13);
        14: a := ReturnAddress (14);
        15: a := ReturnAddress (15);
        {$endif}
        else a := nil
      end;
      Inc (i)
    until (i = 16) or (a = nil) or not WriteErrorMessage (ReturnAddr2Hex (a) + NewLine, False)
end;

procedure Finalize1;
begin
  FlushAllFiles;
  RestoreTerminal (True);
  if ErrorMessageString <> '' then WriteStackDump;
  Done_Files
end;

procedure GPC_Finalize;
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := '';
  ExitCode := 0;
  ErrorAddr := nil;
  RunFinalizers (AtExitProcs);
  Finalize1;
  RestoreReturnAddress
end;

procedure GPC_Halt (aExitCode: Integer);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := '';
  ExitCode := aExitCode;
  ErrorAddr := nil;
  RunFinalizers (AtExitProcs);
  Finalize1;
  RestoreReturnAddress;
  ExitProgram (aExitCode, False)
end;

procedure SetReturnAddress (Address: Pointer);
begin
  if CurrentReturnAddrCounter = 0 then CurrentReturnAddr := Address;
  Inc (CurrentReturnAddrCounter)
end;

procedure RestoreReturnAddress;
begin
  Dec (CurrentReturnAddrCounter);
  if CurrentReturnAddrCounter = 0 then CurrentReturnAddr := nil
end;

procedure FinishErrorMessage (n: Integer);
var s: TString;
begin
  ExitCode := n;
  ErrorAddr := CurrentReturnAddr;
  CurrentReturnAddr := nil;
  CurrentReturnAddrCounter := 0;
  s := ReturnAddr2Hex (ErrorAddr);
{$local cstrings-as-strings}
  { @@ stack problem } var foo:CString;foo:=ErrorMessageString;WriteStr (ErrorMessageString, foo, ' (error #', n, ' at ', s, ')')
{$endlocal}
end;

procedure EndRuntimeError (n: Integer); attribute (noreturn, name = '_p_EndRuntimeError');
begin
  FinishErrorMessage (n);
  SetReturnAddress (ReturnAddress (0));
  RunFinalizers (AtExitProcs);
  Finalize1;
  RestoreReturnAddress;
  if (RTSErrorFD >= 0) then Discard (CloseHandle (RTSErrorFD));  { just to be sure }
  ExitProgram (RuntimeErrorExitValue, AbortOnError)
end;

procedure RuntimeError (n: Integer);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := CString2String (GetErrorMessage (n));
  EndRuntimeError (n)
end;

function StrError = Res: TString;
var
  ErrNo: CInteger;
  s: CString;
begin
  s := CStringStrError (ErrNo);
  if s <> nil then
    Res := CString2String (s)
  else
    WriteStr (Res, 'error #', ErrNo)
end;

function StrSignal (Signal: Integer) = Res: TString;
var s: CString;
begin
  s := CStringStrSignal (Signal);
  if s <> nil then
    Res := CString2String (s)
  else
    WriteStr (Res, 'signal #', Signal)
end;

procedure RuntimeErrorErrNo (n: Integer);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := CString2String (GetErrorMessage (n)) + ' (' + StrError + ')';
  EndRuntimeError (n)
end;

procedure RuntimeErrorInteger (n: Integer; i: MedInt);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := FormatStr (GetErrorMessage (n), Integer2String (i));
  EndRuntimeError (n)
end;

procedure RuntimeErrorCString (n: Integer; s: CString);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := FormatStr (GetErrorMessage (n), CString2String (s));
  EndRuntimeError (n)
end;

procedure InternalError (n: Integer);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := InternalErrorString + CString2String (GetErrorMessage (n));
  EndRuntimeError (n)
end;

procedure InternalErrorInteger (n: Integer; i: MedInt);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := InternalErrorString + FormatStr (GetErrorMessage (n), Integer2String (i));
  EndRuntimeError (n)
end;

procedure InternalErrorCString (n: Integer; s: CString);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := InternalErrorString + FormatStr (GetErrorMessage (n), CString2String (s));
  EndRuntimeError (n)
end;

procedure GPC_RunError (n: Integer);
begin
  SetReturnAddress (ReturnAddress (0));
  ErrorMessageString := 'runtime error';
  EndRuntimeError (n)
end;

function GPC_IOResult: Integer;
begin
  GPC_IOResult := GPC_InOutRes;
  GPC_InOutRes := 0
end;

procedure StartTempIOError;
begin
  TempInOutRes := GPC_IOResult;
  TempIOErrorFlag := True
end;

function EndTempIOError: Integer;
begin
  EndTempIOError := IOResult;
  GPC_InOutRes := TempInOutRes;
  TempIOErrorFlag := False
end;

procedure SetInOutResStrings (s: PString; ErrNoFlag: Boolean);
begin
  if InOutResString <> nil then Dispose (InOutResString);
  InOutResString := s;
  if InOutResCErrorString <> nil then Dispose (InOutResCErrorString);
  if ErrNoFlag then
    InOutResCErrorString := NewString (StrError)
  else
    InOutResCErrorString := nil
end;

procedure IOError (n: Integer; ErrNoFlag: Boolean);
var p: Pointer;
begin
  p := SuspendMark;
  GPC_InOutRes := n;
  if not TempIOErrorFlag then
    SetInOutResStrings (nil, ErrNoFlag);
  ResumeMark (p)
end;

procedure IOErrorInteger (n: Integer; i: MedInt; ErrNoFlag: Boolean);
var p: Pointer;
begin
  p := SuspendMark;
  GPC_InOutRes := n;
  if not TempIOErrorFlag then
    SetInOutResStrings (NewString (Integer2String (i)), ErrNoFlag);
  ResumeMark (p)
end;

procedure IOErrorCString (n: Integer; s: CString; ErrNoFlag: Boolean);
var p: Pointer;
begin
  p := SuspendMark;
  GPC_InOutRes := n;
  if not TempIOErrorFlag then
    SetInOutResStrings (NewString (CString2String (s)), ErrNoFlag);
  ResumeMark (p)
end;

function GetIOErrorMessage = Res: TString;
begin
  if InOutResString <> nil then
    Res := FormatStr (GetErrorMessage (GPC_IOResult), InOutResString^)
  else
    Res := CString2String (GetErrorMessage (GPC_IOResult));
  if InOutResCErrorString <> nil then
    Res := Res + ' (' + InOutResCErrorString^ + ')'
end;

procedure CheckInOutRes;
var n: Integer;
begin
  if GPC_InOutRes <> 0 then
    begin
      SetReturnAddress (ReturnAddress (0));
      n := GPC_InOutRes;
      ErrorMessageString := GetIOErrorMessage;
      EndRuntimeError (n)
    end
end;

procedure DefaultSignalHandler (Signal, Code: CInteger);
var
  i, n: Integer;
  HandlerReset: Boolean;
begin
  HandlerReset := InstallSignalHandler (Signal, SignalDefault, True, False, Null, Null);
  i := Low (SignalTable);
  while (i < High (SignalTable)) and not ((SignalTable[i].Signal^ = Signal) and
         ((SignalTable[i].Code = nil) or (SignalTable[i].Code^ = Code))) do Inc (i);
  n := SignalTable[i].ErrorNumber;
  if n < 0 then
    begin
      RuntimeWarning (GetErrorMessage (-n));  { @@ stack problem when using strings here }
      Discard (InstallSignalHandler (Signal, TSignalHandler (@DefaultSignalHandler), True, True, Null, Null))
    end
  else
    begin
{$local cstrings-as-strings}
      WriteStr (ErrorMessageString, { @@ stack problem } GetErrorMessage (n), ' (#', n, ')');
{$endlocal}
      { Return address not available or meaningful in a signal handler }
      SetReturnAddress (Pointer ($deadbeef));
      FinishErrorMessage (n);
{$local cstrings-as-strings}
      { @@ stack problem } var foo:CString;foo:=ErrorMessageString;WriteLn (StdErr, ParamStr (0), ': ', foo);
{$endlocal}
      ErrorMessageString := '';
      if HandlerReset then Discard (Kill (ProcessID, Signal))
    end
end;

procedure InstallDefaultSignalHandlers;
var Done: Boolean = False; attribute (static);
begin
  { Run only once. }
  if Done then Exit;
  Done := True;
  {$if False}  { @@ doesn't work because of limited sets -- signal ids can be > 255, e.g. on DJGPP }
  Signal: Integer;
  for Signal in [SigHUp, SigInt, { SigQuit, } SigIll, SigFPE, SigSegV, SigPipe,
                 SigAlrm, SigTerm, SigTrap, SigIOT, SigEMT, SigBus, SigSys] do
    Discard (InstallSignalHandler (Signal, TSignalHandler (@DefaultSignalHandler), True, True, Null, Null))
  {$else}
  {$define I(S) Discard (InstallSignalHandler (S, TSignalHandler (@DefaultSignalHandler), True, True, Null, Null))}
  I (SigHUp); I (SigInt); { I(SigQuit); } I (SigIll); I (SigFPE); I (SigSegV); I (SigPipe);
  I (SigAlrm); I (SigTerm); I (SigTrap); I (SigIOT); I (SigEMT); I (SigBus); I (SigSys);
  {$endif}
end;

begin
  ErrorMessageString := ''
end.
