{ Initialization

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

  Authors: Frank Heckenbach <frank@pascal.gnu.de>

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

unit Init; attribute (name = '_p__rts_Init');

interface

{@internal}

{ Use all RTS units, so their initializers are run from here.
  Note: RTSC should be first since it does some low-level initializations. }
uses RTSC, String1, Error, String2, Time, Random, FName, Files,
     GetOpt, Sets, Heap, Math, Endian, Move;

procedure InitDummy; attribute (name = '_p_InitDummy');
procedure DoInitProc; attribute (name = '_p_DoInitProc');
{@endinternal}

{ Initialize the GPC Run Time System. This is normally called
  automatically. Call it manually only in very special situations.
  ArgumentCount, Arguments are argc and argv in C; StartEnvironment
  is the environment variable pointer, and can be nil if other ways
  to obtain the environment are available. Options can be 0 or a
  combination of ro_* flags as defined in rts/constants.def. }
procedure GPC_Initialize (ArgumentCount: CInteger;
                          Arguments, StartEnvironment: PCStrings;
                          Options: CInteger);
                          attribute (name = '_p_initialize');

var
  InitProc: ^procedure = @InitDummy; attribute (name = '_p_InitProc');

implementation

{ Declare a variable which is accessed from util.c to ensure that
  the correct RTS version is linked. }
{$ifndef RTS_RELEASE_STRING}
{$error RTS_RELEASE_STRING not set! Please compile this file properly from
the Makefile, or define that symbol manually if you know what you are doing.}
{$endif}
var
  RTSReleaseCheck: Integer = $47525453; attribute (name = '_p_GPC_RTS_VERSION_' + RTS_RELEASE_STRING);

procedure InitDummy;
begin
end;

{ Handle options for the Run Time System from the command line.
  Since the normal use of the command line is passing arguments to
  the user program, passing arguments to the RTS is made somewhat
  complicated: The first argument has to be `--gpc-rts'. Other
  flags that the RTS recognizes (if the first argument is
  `--gpc-rts') are output with the `-h' option (see below).
  `--' indicates the end of RTS arguments. }
procedure InitArguments;
const
  Prefix = 'gpc-rts';
  PrefixOption = '--' + Prefix;
var
  ArgsDone: Boolean = False; attribute (static);
  SkipArgs, NoSkip, OK: Boolean;
  CParamCountSave, i: Integer;
  CParameter1Save: CString;
  p: Pointer;
  HasExtraInput: Boolean = False;

  procedure Help (Status: Integer);
  begin
    Write ('Run Time System (RTS) of GNU Pascal ' + RTS_RELEASE_STRING + ' (GCC version ' + GCC_VERSION + ')

Special command line options to the RTS:
[' + PrefixOption + '=OPTION ' + PrefixOption + '=OPTION ...] [' + PrefixOption + ' OPTION OPTION ... [--]]

OPTION may be:
-h, --help                Display this help and exit
-v, --version             Output RTS version information and exit
-a, --abort-on-error      Abort with SIGABRT on runtime error
-e, --eoln-hack           Toggle EOLn hack right after Reset for terminals
-i LINE, --input LINE     Implicitly add LINE to the beginning of Input
-n INTERNAL_NAME:EXTERNAL_NAME, --file-name[=]INTERNAL_NAME:EXTERNAL_NAME
                          Set an external file name
-S, --signal-handlers     Install signal handlers that cause runtime
                          errors on certain signals
                          @@ Note: This does not yet work on all systems
                                   (since the handler might have too
                                   little stack space).
-s, --show-rts-arguments  Let the program see RTS command line arguments
-w, --warn                Give runtime warning messages
-E FILENAME, --error-file[=]FILENAME
                          Write runtime error messages and stack dump to
                          FILENAME
-F FD, --error-fd[=]FD    Write runtime error messages and stack dump to
                          fd #FD
--                        Following arguments are not meant for the RTS
');
    Halt (Status)
  end;

  function DoOption: Boolean;
  const
    LongOptions: array [1 .. 12] of OptionType =
      ((Prefix,               NoArgument,       nil, '='),
       ('help',               NoArgument,       nil, 'h'),
       ('version',            NoArgument,       nil, 'v'),
       ('abort-on-error',     NoArgument,       nil, 'a'),
       ('eoln-hack',          NoArgument,       nil, 'e'),
       ('input',              RequiredArgument, nil, 'i'),
       ('file-name',          RequiredArgument, nil, 'n'),
       ('signal-handlers',    NoArgument,       nil, 'S'),
       ('show-rts-arguments', NoArgument,       nil, 's'),
       ('warn',               NoArgument,       nil, 'w'),
       ('error-file',         RequiredArgument, nil, 'E'),
       ('error-fd',           RequiredArgument, nil, 'F'));
  var
    c: Char;
    ap: PFileAssociation;
    fd, j: Integer;
    SaveGetOptErrorFlag: Boolean;
  begin
    DoOption := False;
    SaveGetOptErrorFlag := GetOptErrorFlag;
    GetOptErrorFlag := False;
    c := GetOptLong ('+-', LongOptions, Null, False);
    GetOptErrorFlag := SaveGetOptErrorFlag;
    if c = EndOfOptions then Exit;
    SkipArgs := True;
    case c of
      '=': ;  { Ignore multiple prefix arguments }
      'h': Help (0);
      'v': begin
             WriteLn ('GNU Pascal Run Time System (RTS) version ' + RTS_RELEASE_STRING + ' (GCC version ' + GCC_VERSION + ')
Copyright (C) 1987-2005 Free Software Foundation, Inc.

The GNU Pascal RTS comes with NO WARRANTY, to the extent permitted
by law. You may redistribute copies of the GNU Pascal RTS under the
terms of the GNU General Public License. For more information about
these matters, see the file named COPYING.

As a special exception, if the RTS is linked with files compiled
with a GNU compiler to produce an executable, this does not cause
the resulting executable to be covered by the GNU General Public
License. This exception does not however invalidate any other
reasons why the executable file might be covered by the GNU
General Public License.

Report bugs about GNU Pascal to <gpc@gnu.de>.
');
             Halt
           end;
      'a': AbortOnError := True;
      'e': EOLnResetHack := not EOLnResetHack;
      'i': begin
             { Strings written to CurrentStdIn, given as first standard input to user program }
             if not HasExtraInput then
               begin
                 HasExtraInput := True;
                 Initialize (CurrentStdIn);  { Until here, the C code leaves it NULL, i.e. uninitialized }
                 Rewrite (CurrentStdIn)
               end;
             WriteLn (CurrentStdIn, OptionArgument)
           end;
      'n': begin
             j := Pos (':', OptionArgument);
             if j = 0 then
               begin
                 WriteLn (StdErr, ParamStr (0), ': missing external file name for `', OptionArgument, '''' + NewLine);
                 Help (1)
               end
             else
               begin
                 New (ap);
                 ap^.Next := FileAssociation;
                 ap^.IntName := NewCString (Copy (OptionArgument, 1, j - 1));
                 ap^.ExtName := NewCString (Copy (OptionArgument, j + 1));
                 FileAssociation := ap
               end
           end;
      'S': InstallDefaultSignalHandlers;
      's': NoSkip := True;
      'w': RTSWarnFlag := True;
      'E': RTSErrorFileName := NewString (OptionArgument);
      'F': begin
             {$local I+} ReadStr (OptionArgument, fd); {$endlocal}
             RTSErrorFD := fd
           end;
      else
        Dec (FirstNonOption);
        Exit
    end;
    DoOption := True
  end;

begin
  if ArgsDone or (CParameters = nil) then Exit;
  p := SuspendMark;
  ArgsDone := True;
  NoSkip := False;
  SkipArgs := False;
  i := 1;
  while (CParamCount > i) and (CStringLComp (CParameters^[i], PrefixOption + '=', Length (PrefixOption) + 1) = 0) do
    begin
      CParamCountSave := CParamCount;
      CParameter1Save := CParameters^[1];
      CParamCount := 2;  { counts from 0! }
      CParameters^[1] := {$local pointer-arithmetic} CParameters^[i] + Length (PrefixOption) + 1 {$endlocal};
      ResetGetOpt (1);
      OK := DoOption;
      CParamCount := CParamCountSave;
      CParameters^[1] := CParameter1Save;
      if not OK then
        begin
          WriteLn (StdErr, ParamStr (0), ': invalid RTS option `', CString2String (CParameters^[i]) + '''' + NewLine);
          Help (1)
        end;
      Inc (i)
    end;
  ResetGetOpt (i);
  if (CParamCount > i) and (CStringComp (CParameters^[i], PrefixOption) = 0) then
    repeat
    until not DoOption
  else
    FirstNonOption := i;
  { Make RTS arguments invisible to the program unless the `-s' parameter was given. }
  if SkipArgs and not NoSkip then
    begin
      for i := 1 to CParamCount - FirstNonOption do  { Leave argument #0 as it is. }
        CParameters^[i] := CParameters^[i + FirstNonOption - 1];
      Dec (CParamCount, FirstNonOption - 1)
    end;
  ResetGetOpt (1);
  if HasExtraInput then
    begin
      Reset (CurrentStdIn);
      Close (Input);
      Reset (Input)  { This will note CurrentStdIn }
    end;
  ResumeMark (p)
end;

procedure DoInitProc;
begin
  if InitProc <> nil then InitProc^
end;

procedure InitInit; external name '_p__rts_Init_init';

procedure GPC_Initialize (ArgumentCount: CInteger; Arguments, StartEnvironment: PCStrings; Options: CInteger);
begin
  RTSOptions := Options;
  InitInit;  { @@ call our own initializer }
  CParamCount := ArgumentCount;
  CParameters := Arguments;
  GPC_Init_Environment (GetStartEnvironment (StartEnvironment));
  InitArguments
end;

end.
