{ GPC demo program for the Pipes unit.
  Inter-process communication using pipes on multi-tasking systems,
  emulated on single-tasking systems.

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA.

  As a special exception, if you incorporate even large parts of the
  code of this demo program into another program with substantially
  different functionality, this does not cause the other program to
  be covered by the GNU General Public License. This exception does
  not however invalidate any other reasons why it might be covered
  by the GNU General Public License. }

program PipeDemo;

uses GPC, Pipes;

const
  ResultMessage: array [TWaitPIDResult] of TString =
    ('did not terminate with status ',
     'terminated with status ',
     'was teminated by signal ',
     'was stopped by signal ',
     'did something unexpected with status ');

var
  ToInput: Text;
  FromOutput, FromStdErr: File;
  Process: PPipeProcess;
  WaitPIDResult: TWaitPIDResult;
  Status: Integer;
  Files: array [1 .. 2] of PAnyFile;

{ Check for output while reading input. }
procedure CheckProcessOutput (TimeOut: LongInt);
const Names: array [1 .. 2] of String [6] = ('Output', 'StdErr');
var
  Nr, BytesRead: Integer;
  LastNr: Integer = 0; attribute (static);
  Buffer: array [1 .. 256] of Char;
begin
  Nr := - 1;
  while (Nr <> 0) and ((Files[1] <> nil) or (Files[2] <> nil)) do
    begin
      Nr := IOSelectRead (Files, TimeOut);
      if Nr < 0 then
        begin
          WriteLn (StdErr, 'Error in `IOSelect''');
          Halt (1)
        end;
      if Nr > 0 then
        begin
          BlockRead (File (Files[Nr]^), Buffer, SizeOf (Buffer), BytesRead);
          if BytesRead = 0 then
            Files[Nr] := nil
          else
            begin
              if LastNr <> Nr then
                begin
                  LastNr := Nr;
                  Write ('[', Names[Nr], ']')
                end;
              Write (Buffer[1 .. BytesRead])
            end
        end
    end
end;

procedure DemoProcedure;
var s: TString;
begin
  WriteLn (StdErr, 'Forking, but not executing another process ...');
  while not EOF do
    begin
      ReadLn (s);
      WriteLn ('Writing `', s, ''' to Output.');
      WriteLn (StdErr, 'Writing `', s, ''' to Error.')
    end
end;

begin
  WriteLn ('Demo for using pipes and forking. By default, the program will fork');
  WriteLn ('and execute DemoProc as a separate executable, and emulate this on');
  WriteLn ('limited operating systems (e.g., Dos). If you give the command line');
  WriteLn ('parameter `-f'', the program will only fork, but not execute');
  WriteLn ('another process, but rather an internal procedure.');
  WriteLn;
  if PipeForking then
    WriteLn ('Using fork on this system.')
  else
    WriteLn ('Emulating fork on this system.');
  WriteLn;
  { Also search for demoproc in the directory of this executable, if available }
  SetEnv (PathEnvVar, DirFromPath (ExecutablePath) + PathSeparator + GetEnv (PathEnvVar));
  { Start a process with pipes }
  {$I-}
  if ParamStr (1) = '-f' then
    Pipe (ToInput, FromOutput, FromStdErr, '', Null, GetCEnvironment, Process, DemoProcedure)
  else
    Pipe (ToInput, FromOutput, FromStdErr, 'demoproc', Null, GetCEnvironment, Process, nil);
  {$I+}
  if IOResult <> 0 then
    begin
      WriteLn (StdErr, 'Could not create pipe to `demoproc''. Please compile `demoproc.pas''');
      WriteLn (StdErr, 'first, and make sure the resulting executable can be found in your');
      WriteLn (StdErr, 'PATH or in the same directory as this program.');
      Halt (1)
    end;

  { Set the variables where the process' status will be stored. }
  Process^.Result := @WaitPIDResult;
  Process^.Status := @Status;

  Files[1] := @FromOutput;
  Files[2] := @FromStdErr;

  { Pipe some input to the process }
  CheckProcessOutput (0);
  WriteLn (ToInput, 'foo');
  CheckProcessOutput (0);
  Sleep (1);
  WriteLn (ToInput, 'bar');
  CheckProcessOutput (0);

  Close (ToInput);  { It's important to close ToInput here, so the
                      process will terminate. However, the effects
                      of not closing ToInput are quite different
                      under Unix (waiting for more input from
                      FromOutput or FromStdErr) and Dos (never
                      starting the process in the first place and
                      therefore not getting any data from FromOutput
                      and FromStdErr!). }

  { Read all the remaining output }
  CheckProcessOutput (- 1);

  Close (FromOutput);
  Close (FromStdErr);
  WriteLn ('The process ', ResultMessage[WaitPIDResult], Status, '.');
  if (WaitPIDResult = PIDExited) and (Status = 0) then WriteLn ('This means success.')
end.
