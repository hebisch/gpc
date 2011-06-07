{ Piping data from and to processes

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
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}

{ Keep this consistent with the one in pipesc.c }
{$if defined (MSDOS) or defined (__MINGW32__)}
{$define NOFORK}
{$endif}

unit Pipes;

interface

uses GPC;

const
  PipeForking = {$ifdef NOFORK} False {$else} True {$endif};

type
  TProcedure = procedure;

  PWaitPIDResult = ^TWaitPIDResult;
  TWaitPIDResult = (PIDNothing, PIDExited, PIDSignaled, PIDStopped, PIDUnknown);

  PPipeProcess = ^TPipeProcess;
  TPipeProcess = record
    PID      : Integer;         { Process ID of process forked }
    SignalPID: Integer;         { Process ID to send the signal to.
                                  Equals PID by default }
    OpenPipes: Integer;         { Number of pipes to/from the
                                  process, for internal use }
    Signal   : Integer;         { Send this signal (if not 0) to the
                                  process after all pipes have been
                                  closed after some time }
    Seconds  : Integer;         { Wait so many seconds before
                                  sending the signal if the process
                                  has not terminated by itself }
    Wait     : Boolean;         { Wait for the process, even longer
                                  than Seconds seconds, after
                                  sending the signal (if any) }
    Result   : PWaitPIDResult;  { Default nil. If a pointer to a
                                  variable is stored here, its
                                  destination will contain the
                                  information whether the process
                                  terminated by itself, or was
                                  terminated or stopped by a signal,
                                  when waiting after closing the
                                  pipes }
    Status   : ^Integer;        { Default nil. If a pointer to a
                                  variable is stored here, its
                                  destination will contain the exit
                                  status if the process terminated
                                  by itself, or the number of the
                                  signal otherwise, when waiting
                                  after closing the pipes }
  end;

var
  { Default values for TPipeProcess records created by Pipe }
  DefaultPipeSignal : Integer = 0;
  DefaultPipeSeconds: Integer = 0;
  DefaultPipeWait   : Boolean = True;

{ The procedure Pipe starts a process whose name is given by
  ProcessName, with the given parameters (can be Null if no
  parameters) and environment, and create pipes from and/or to the
  process' standard input/output/error. ProcessName is searched for
  in the PATH with FSearchExecutable. Any of ToInputFile,
  FromOutputFile and FromStdErrFile can be Null if the corresponding
  pipe is not wanted. FromOutputFile and FromStdErrFile may be
  identical, in which case standard output and standard error are
  redirected to the same pipe. The behaviour of other pairs of files
  being identical is undefined, and useless, anyway. The files are
  Assigned and Reset or Rewritten as appropriate. Errors are
  returned in IOResult. If Process is not Null, a pointer to a
  record is stored there, from which the PID of the process created
  can be read, and by writing to which the action after all pipes
  have been closed can be changed. (The record is automatically
  Dispose'd of after all pipes have been closed.) If automatic
  waiting is turned off, the caller should get the PID from the
  record before it's Dispose'd of, and wait for the process sometime
  in order to avoid zombies. If no redirections are performed (i.e.,
  all 3 files are Null), the caller should wait for the process with
  WaitPipeProcess. When an error occurs, Process is not assigned to,
  and the state of the files is undefined, so be sure to check
  IOResult before going on.

  ChildProc, if not nil, is called in the child process after
  forking and redirecting I/O, but before executing the new process.
  It can even be called instead of executing a new process
  (ProcessName can be empty then).

  The procedure even works under Dos, but, of course, in a limited
  sense: if ToInputFile is used, the process will not actually be
  started until ToInputFile is closed. Signal, Seconds and Wait of
  TPipeProcess are ignored, and PID and SignalPID do not contain a
  Process ID, but an internal value without any meaning to the
  caller. Result will always be PIDExited. So, Status is the only
  interesting field (but Result should also be checked). Since there
  is no forking under Dos, ChildProc, if not nil, is called in the
  main process before spawning the program. So, to be portable, it
  should not do any things that would influence the process after
  the return of the Pipe function.

  The only portable way to use "pipes" in both directions is to call
  `Pipe', write all the Input data to ToInputFile, close
  ToInputFile, and then read the Output and StdErr data from
  FromOutputFile and FromStdErrFile. However, since the capacity of
  pipes is limited, one should also check for Data from
  FromOutputFile and FromStdErrFile (using CanRead, IOSelect or
  IOSelectRead) while writing the Input data (under Dos, there
  simply won't be any data then, but checking for data doesn't do
  any harm). Please see pipedemo.pas for an example. }
procedure Pipe (var ToInputFile, FromOutputFile, FromStdErrFile: AnyFile; const ProcessName: String; protected var Parameters: TPStrings; ProcessEnvironment: PCStrings; var Process: PPipeProcess; ChildProc: TProcedure); attribute (iocritical);

{ Waits for a process created by Pipe as determined in the Process
  record. (Process is Dispose'd of afterwards.) Returns True if
  successful. }
function WaitPipeProcess (Process: PPipeProcess): Boolean; attribute (ignorable);

{ Alternative interface from PExecute }

const
  PExecute_First   = 1;
  PExecute_Last    = 2;
  PExecute_One     = PExecute_First or PExecute_Last;
  PExecute_Search  = 4;
  PExecute_Verbose = 8;

{ PExecute: execute a chain of processes.

  Program and Arguments are the arguments to execv/execvp.

  Flags and PExecute_Search is non-zero if $PATH should be searched.
  Flags and PExecute_First is nonzero for the first process in
  chain. Flags and PExecute_Last is nonzero for the last process in
  chain.

  The result is the pid on systems like Unix where we fork/exec and
  on systems like MS-Windows and OS2 where we use spawn. It is up to
  the caller to wait for the child.

  The result is the exit code on systems like MSDOS where we spawn
  and wait for the child here.

  Upon failure, ErrMsg is set to the text of the error message,
  and -1 is returned. `errno' is available to the caller to use.

  PWait: cover function for wait.

  PID is the process id of the task to wait for. Status is the
  `status' argument to wait. Flags is currently unused (allows
  future enhancement without breaking upward compatibility). Pass 0
  for now.

  The result is the process ID of the child reaped, or -1 for
  failure.

  On systems that don't support waiting for a particular child, PID
  is ignored. On systems like MSDOS that don't really multitask
  PWait is just a mechanism to provide a consistent interface for
  the caller. }
function  PExecute (ProgramName: CString; Arguments: PCStrings; var ErrMsg: String; Flags: Integer): Integer; attribute (ignorable);
function  PWait (PID: Integer; var Status: Integer; Flags: Integer): Integer; attribute (ignorable);

implementation

{$L pipesc.c}

{$ifndef NOFORK}

type
  PCInteger = ^CInteger;

  PFileProcess = ^TFileProcess;
  TFileProcess = record
    FilePtr: PAnyFile;
    OldCloseProc: TCloseProc;
    ProcessPtr: PPipeProcess
  end;

function CPipe (Path: CString; CProcessParameters, ProcessEnvironment: PCStrings; PPipeStdIn, PPipeStdOut, PPipeStdErr: PCInteger; ChildProc: TProcedure): CInteger; external name '_p_CPipe';

function WaitPipeProcess (Process: PPipeProcess): Boolean;

  function DoWaitPID (Block: Boolean) = WPID: Integer;
  var
    Result: TWaitPIDResult;
    WStatus: CInteger;
    Status: Integer;
  begin
    WPID := WaitPID (Process^.PID, WStatus, Block);
    if WPID <= 0 then
      begin
        Result := PIDNothing;
        Status := 0
      end
    else if StatusExited (WStatus) then
      begin
        Result := PIDExited;
        Status := StatusExitCode (WStatus)
      end
    else if StatusSignaled (WStatus) then
      begin
        Result := PIDSignaled;
        Status := StatusTermSignal (WStatus)
      end
    else if StatusStopped (WStatus) then
      begin
        Result := PIDStopped;
        Status := StatusStopSignal (WStatus)
      end
    else
      begin
        Result := PIDUnknown;
        Status := 0
      end;
    if Process^.Result <> nil then Process^.Result^ := Result;
    if Process^.Status <> nil then Process^.Status^ := Status
  end;

begin
  WaitPipeProcess := True;
  with Process^ do
    begin
      while Seconds <> 0 do
        begin
          if DoWaitPID (False) = PID then
            begin
              Dispose (Process);
              Exit
            end;
          Sleep (1);
          Dec (Seconds)
        end;
      if Signal <> 0 then Discard (Kill (SignalPID, Signal));
      if not Wait or (DoWaitPID (True) <= 0) then
        WaitPipeProcess := False
      else
        Dispose (Process)
    end
end;

procedure PipeTFDDClose (var PrivateData);
var
  FileProcess: TFileProcess absolute PrivateData;
  OpenProc: TOpenProc;
  SelectFunc: TSelectFunc;
  SelectProc: TSelectProc;
  ReadFunc: TReadFunc;
  WriteFunc: TWriteFunc;
  FlushProc: TFlushProc;
  DoneProc: TDoneProc;
  FPrivateData: Pointer;
begin
  with FileProcess do
    begin
      GetTFDD (FilePtr^, OpenProc, SelectFunc, SelectProc, ReadFunc, WriteFunc, FlushProc, Null, DoneProc, FPrivateData);
      SetTFDD (FilePtr^, OpenProc, SelectFunc, SelectProc, ReadFunc, WriteFunc, FlushProc, OldCloseProc, DoneProc, FPrivateData);
      Close (FilePtr^);
      Dec (ProcessPtr^.OpenPipes);
      if ProcessPtr^.OpenPipes = 0 then Discard (WaitPipeProcess (ProcessPtr))
    end;
  Dispose (@FileProcess)
end;

procedure SetCloseAction (var f: AnyFile; PProcess: PPipeProcess);
var
  p: PFileProcess;
  OpenProc: TOpenProc;
  SelectFunc: TSelectFunc;
  SelectProc: TSelectProc;
  ReadFunc: TReadFunc;
  WriteFunc: TWriteFunc;
  FlushProc: TFlushProc;
  DoneProc: TDoneProc;
  PrivateData: Pointer;
begin
  if InOutRes <> 0 then Exit;
  New (p);
  p^.FilePtr := @f;
  p^.ProcessPtr := PProcess;
  Inc (PProcess^.OpenPipes);
  GetTFDD (f, OpenProc, SelectFunc, SelectProc, ReadFunc, WriteFunc, FlushProc, p^.OldCloseProc, DoneProc, PrivateData);
  SetTFDD (f, OpenProc, SelectFunc, SelectProc, ReadFunc, WriteFunc, FlushProc, PipeTFDDClose, DoneProc, p)
end;

procedure Pipe (var ToInputFile, FromOutputFile, FromStdErrFile: AnyFile; const ProcessName: String; protected var Parameters: TPStrings; ProcessEnvironment: PCStrings; var Process: PPipeProcess; ChildProc: TProcedure);
var
  ParameterCount, i: Cardinal;
  PipeStdIn, PipeStdOut, PipeStdErr: CInteger;
  PPipeStdIn, PPipeStdOut, PPipeStdErr: PCInteger;
  PID: Integer;
  PProcess: PPipeProcess;
  ProcessPath: TString;
begin
  if @Process <> nil then Process := nil;
  if InOutRes <> 0 then Exit;
  if @Parameters = nil then ParameterCount := 0 else ParameterCount := Parameters.Count;
  if @ToInputFile = nil then PPipeStdIn := nil else PPipeStdIn := @PipeStdIn;
  if @FromOutputFile = nil then PPipeStdOut := nil else PPipeStdOut := @PipeStdOut;
  if @FromStdErrFile = nil then PPipeStdErr := nil else
    if @FromStdErrFile = @FromOutputFile then PPipeStdErr := @PipeStdOut else PPipeStdErr := @PipeStdErr;
  if ProcessName = '' then
    ProcessPath := ''
  else
    ProcessPath := FSearchExecutable (ProcessName, GetEnv (PathEnvVar));
  if (ProcessName <> '') and (ProcessPath = '') then
    begin
      IOErrorCString (EProgramNotFound, ProcessName, False);
      Exit
    end;
  var CProcessParameters: array [0 .. ParameterCount + 1] of CString;
  CProcessParameters[0] := ProcessName;
  for i := 1 to ParameterCount do CProcessParameters[i] := Parameters[i]^;
  CProcessParameters[ParameterCount + 1] := nil;
  PID := CPipe (ProcessPath, PCStrings (@CProcessParameters), ProcessEnvironment, PPipeStdIn, PPipeStdOut, PPipeStdErr, ChildProc);
  if PID <= 0 then
    begin
      case PID of
        -2:  IOErrorCString (EProgramNotExecutable, ProcessName, False);
        -3:  IOErrorCString (EPipe, ProcessName, True);
        -4:  IOErrorCString (ECannotFork, ProcessName, True);
        -5:  InternalError  (EExitReturned);
        else RuntimeError   (EAssert)
      end;
      Exit
    end;
  SetReturnAddress (ReturnAddress (0));
  New (PProcess);
  PProcess^.PID := PID;
  PProcess^.SignalPID := PID;
  PProcess^.Signal := DefaultPipeSignal;
  PProcess^.Seconds := DefaultPipeSeconds;
  PProcess^.Wait := DefaultPipeWait;
  PProcess^.OpenPipes := 0;
  PProcess^.Result := nil;
  PProcess^.Status := nil;
  if @Process <> nil then Process := PProcess;
  if @ToInputFile <> nil then
    begin
      AssignHandle (ToInputFile, PipeStdIn, True);
      Rewrite (ToInputFile);
      SetCloseAction (ToInputFile, PProcess)
    end;
  if @FromOutputFile <> nil then
    begin
      AssignHandle (FromOutputFile, PipeStdOut, True);
      Reset (FromOutputFile);
      SetCloseAction (FromOutputFile, PProcess)
    end;
  if (@FromStdErrFile <> nil) and (@FromStdErrFile <> @FromOutputFile) then
    begin
      AssignHandle (FromStdErrFile, PipeStdErr, True);
      Reset (FromStdErrFile);
      SetCloseAction (FromStdErrFile, PProcess)
    end;
  RestoreReturnAddress
end;

{$else}

{ NOTE: This emulation code is quite a mess! Be warned if you want
  to understand it, and don't make any quick changes here unless you
  fully understand it. }

function CPipe (Path: CString; CProcessParameters, ProcessEnvironment: PCStrings; NameStdIn, NameStdOut, NameStdErr: CString; ChildProc: TProcedure): CInteger; external name '_p_CPipe';

type
  PPipeData = ^TPipeData;
  TPipeData = record
    ProcName, Path: CString;
    ParameterCount: Cardinal;
    CProcessParameters, CProcessEnvironment: PCStrings;
    NameStdOut, NameStdErr, NameStdIn: TString;
    CNameStdOut, CNameStdErr, CNameStdIn: CString;
    PToInputFile, PFromOutputFile, PFromStdErrFile: ^AnyFile;
    InternalToInputFile: Text;
    aChildProc: TProcedure;
    PipeProcess: TPipeProcess
  end;

  PFileProcess = ^TFileProcess;
  TFileProcess = record
    FilePtr: PAnyFile;
    OldCloseProc: TCloseProc;
    PipeDataPtr: PPipeData
  end;

{ TPipeProcess.PID actually holds the exit status here }

function WaitPipeProcess (Process: PPipeProcess): Boolean;
begin
  if Process^.Result <> nil then Process^.Result^ := PIDExited;
  if Process^.Status <> nil then Process^.Status^ := Process^.PID;
  WaitPipeProcess := Process^.PID >= 0
end;

procedure DoPipe (var PipeData: TPipeData);
var i: Cardinal;
begin
  with PipeData do
    begin
      PipeProcess.PID := CPipe (Path, CProcessParameters, CProcessEnvironment, CNameStdIn, CNameStdOut, CNameStdErr, aChildProc);
      PipeProcess.SignalPID := PipeProcess.PID;
      if PToInputFile <> nil then Erase (InternalToInputFile);
      if PipeProcess.PID < 0 then
        if PipeProcess.PID = -2 then
          IOErrorCString (EProgramNotExecutable, ProcName, False)
        else
          IOErrorCString (ECannotSpawn, ProcName, False);
      Dispose (ProcName);
      Dispose (Path);
      for i := 0 to ParameterCount do Dispose (CProcessParameters^[i]);
      Dispose (CProcessParameters);
      Discard (WaitPipeProcess (@PipeProcess));
      if PipeProcess.PID < 0 then Exit;
      if PFromOutputFile <> nil then
        begin
          Reset (PFromOutputFile^, NameStdOut);
          Erase (PFromOutputFile^)
        end;
      if (PFromStdErrFile <> nil) and (PFromStdErrFile <> PFromOutputFile) then
        begin
          Reset (PFromStdErrFile^, NameStdErr);
          Erase (PFromStdErrFile^)
        end
    end
end;

function PipeInTFDDWrite (var PrivateData; const Buffer; Size: SizeType): SizeType;
var
  Data: TPipeData absolute PrivateData;
  CharBuffer: array [1 .. Size] of Char absolute Buffer;
begin
  with Data do
    Write (InternalToInputFile, CharBuffer);
  PipeInTFDDWrite := Size
end;

procedure PipeInTFDDClose (var PrivateData);
var Data: TPipeData absolute PrivateData;
begin
  with Data do
    begin
      Close (InternalToInputFile);
      if PFromOutputFile <> nil then Close (PFromOutputFile^);
      if (PFromStdErrFile <> nil) and (PFromStdErrFile <> PFromOutputFile) then Close (PFromStdErrFile^);
      Dec (Data.PipeProcess.OpenPipes);
      DoPipe (Data);
      Dispose (@Data)
    end
end;

procedure PipeOutTFDDClose (var PrivateData);
var
  FileProcess: TFileProcess absolute PrivateData;
  OpenProc: TOpenProc;
  SelectFunc: TSelectFunc;
  SelectProc: TSelectProc;
  ReadFunc: TReadFunc;
  WriteFunc: TWriteFunc;
  FlushProc: TFlushProc;
  DoneProc: TDoneProc;
  FPrivateData: Pointer;
begin
  with FileProcess do
    begin
      GetTFDD (FilePtr^, OpenProc, SelectFunc, SelectProc, ReadFunc, WriteFunc, FlushProc, Null, DoneProc, FPrivateData);
      SetTFDD (FilePtr^, OpenProc, SelectFunc, SelectProc, ReadFunc, WriteFunc, FlushProc, OldCloseProc, DoneProc, FPrivateData);
      Close (FilePtr^);
      Dec (PipeDataPtr^.PipeProcess.OpenPipes);
      if PipeDataPtr^.PipeProcess.OpenPipes = 0 then
        begin
          Discard (WaitPipeProcess (@PipeDataPtr^.PipeProcess));
          Dispose (PipeDataPtr)
        end
    end;
  Dispose (@FileProcess)
end;

procedure SetCloseAction (var f: AnyFile; PipeData: PPipeData);
var
  p: PFileProcess;
  OpenProc: TOpenProc;
  SelectFunc: TSelectFunc;
  SelectProc: TSelectProc;
  ReadFunc: TReadFunc;
  WriteFunc: TWriteFunc;
  FlushProc: TFlushProc;
  DoneProc: TDoneProc;
  PrivateData: Pointer;
begin
  if InOutRes <> 0 then Exit;
  New (p);
  p^.FilePtr := @f;
  p^.PipeDataPtr := PipeData;
  GetTFDD (f, OpenProc, SelectFunc, SelectProc, ReadFunc, WriteFunc, FlushProc, p^.OldCloseProc, DoneProc, PrivateData);
  SetTFDD (f, OpenProc, SelectFunc, SelectProc, ReadFunc, WriteFunc, FlushProc, PipeOutTFDDClose, DoneProc, p)
end;

{ The "pipes" that come from the process are reset to nothing until the
  process is started. Use a TFDD, not an empty file or the Null device,
  so that IOSelect will not select these files. }
procedure ResetNothing (var f: AnyFile);
begin
  AssignTFDD (f, nil, nil, nil, nil, nil, nil, nil, nil, nil);
  Reset (f)
end;

procedure Pipe (var ToInputFile, FromOutputFile, FromStdErrFile: AnyFile; const ProcessName: String; protected var Parameters: TPStrings; ProcessEnvironment: PCStrings; var Process: PPipeProcess; ChildProc: TProcedure);
var
  i: Cardinal;
  PipeData: PPipeData;
  ProcessPath: TString;
begin
  if @Process <> nil then Process := nil;
  if ProcessName = '' then
    ProcessPath := ''
  else
    ProcessPath := FSearchExecutable (ProcessName, GetEnv (PathEnvVar));
  if (ProcessName <> '') and (ProcessPath = '') then
    begin
      IOErrorCString (EProgramNotFound, ProcessName, False);
      Exit
    end;
  SetReturnAddress (ReturnAddress (0));
  New (PipeData);
  with PipeData^ do
    begin
      aChildProc := ChildProc;
      ProcName := NewCString (ProcessName);
      Path := NewCString (ProcessPath);
      if @Parameters = nil then ParameterCount := 0 else ParameterCount := Parameters.Count;
      GetMem (CProcessParameters, (ParameterCount + 2) * SizeOf (CString));
      CProcessParameters^[0] := NewCString (ProcessName);
      for i := 1 to ParameterCount do CProcessParameters^[i] := NewCString (Parameters[i]^);
      CProcessParameters^[ParameterCount + 1] := nil;
      CProcessEnvironment := ProcessEnvironment;
      PipeProcess.PID := -1;
      PipeProcess.SignalPID := -1;
      PipeProcess.Signal := DefaultPipeSignal;
      PipeProcess.Seconds := DefaultPipeSeconds;
      PipeProcess.Wait := DefaultPipeWait;
      PipeProcess.OpenPipes := 0;
      PipeProcess.Result := nil;
      PipeProcess.Status := nil;
      if @Process <> nil then Process := @PipeProcess;
      PToInputFile := @ToInputFile;
      PFromOutputFile := @FromOutputFile;
      PFromStdErrFile := @FromStdErrFile;
      if @FromOutputFile = nil then
        CNameStdOut := nil
      else
        begin
          Inc (PipeProcess.OpenPipes);
          NameStdOut := GetTempFileName;
          CNameStdOut := NameStdOut;
          if @ToInputFile <> nil then ResetNothing (FromOutputFile)
        end;
      if @FromStdErrFile = nil then
        CNameStdErr := nil
      else if @FromStdErrFile = @FromOutputFile then
        CNameStdErr := CNameStdOut
      else
        begin
          Inc (PipeProcess.OpenPipes);
          NameStdErr := GetTempFileName;
          CNameStdErr := NameStdErr;
          if @ToInputFile <> nil then ResetNothing (FromStdErrFile)
        end;
      if @ToInputFile = nil then
        begin
          CNameStdIn := nil;
          DoPipe (PipeData^);
          if @FromOutputFile <> nil then
            SetCloseAction (FromOutputFile, PipeData);
          if (@FromStdErrFile <> nil) and (@FromStdErrFile <> @FromOutputFile) then
            SetCloseAction (FromStdErrFile, PipeData)
        end
      else
        begin
          Inc (PipeProcess.OpenPipes);
          NameStdIn := GetTempFileName;
          CNameStdIn := NameStdIn;
          Rewrite (InternalToInputFile, NameStdIn);
          AssignTFDD (ToInputFile, nil, nil, nil, nil, PipeInTFDDWrite, nil, PipeInTFDDClose, nil, PipeData);
          Rewrite (ToInputFile)
        end
    end;
  RestoreReturnAddress
end;

{$endif}

{ PExecute }

function PExecuteC (ProgramName: CString; ArgV: PCStrings; This_PName, Temp_Base: CString;
                    var ErrMsg_Fmt, ErrMsg_Arg: CString; Flags: CInteger): CInteger; external name 'pexecute';
function PWaitC (PID: CInteger; var Status: CInteger; Flags: CInteger): CInteger; external name 'pwait';

function PExecute (ProgramName: CString; Arguments: PCStrings; var ErrMsg: String; Flags: Integer): Integer;
var
  ErrMsg_Fmt, ErrMsg_Arg: CString = nil;
  i: Integer;
begin
  SetReturnAddress (ReturnAddress (0));
  PExecute := PExecuteC (ProgramName, Arguments, CParameters^[0],
    GetTempDirectory + 'ccXXXXXX', ErrMsg_Fmt, ErrMsg_Arg, Flags);
  RestoreReturnAddress;
  if ErrMsg_Fmt = nil then
    ErrMsg := ''
  else
    begin
      ErrMsg := CString2String (ErrMsg_Fmt);
      i := Pos ('%s', ErrMsg);
      if (ErrMsg_Arg <> nil) and (i <> 0) then
        begin
          Delete (ErrMsg, i, 2);
          Insert (CString2String (ErrMsg_Arg), ErrMsg, i)
        end
    end
end;

function PWait (PID: Integer; var Status: Integer; Flags: Integer): Integer;
var CStatus: CInteger;
begin
  PWait := PWaitC (PID, CStatus, Flags);
  Status := CStatus
end;

end.
