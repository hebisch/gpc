{ GPC demo program for the PExecute functions.
  System-independent execution of processes with pipes (real or
  emulated ones) between them.

  Copyright (C) 1999-2006 Free Software Foundation, Inc.

  Authors: Frank Heckenbach <frank@pascal.gnu.de>
           Emil Jerabek <jerabek@math.cas.cz>

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

program PExecuteWithArgumentsDemo;

uses GPC, Pipes;

var
  PID, Status, NumberOfArguments, i: Integer;
  ProgramName, Argument, ErrMsg: TString;

begin
  Write ('Enter the name of the program to execute: ');
  ReadLn (ProgramName);
  Write ('Number of arguments: ');
  ReadLn (NumberOfArguments);
  var Arguments: array [0 .. NumberOfArguments + 1] of CString;
  Arguments[0] := ProgramName;
  for i := 1 to NumberOfArguments do
    begin
      Write ('Argument #', i, ': ');
      ReadLn (Argument);
      Arguments[i] := NewCString (Argument)
    end;
  Arguments[NumberOfArguments + 1] := nil;
  PID := PExecute (ProgramName, PCStrings (@Arguments), ErrMsg, PExecute_One or PExecute_Search or PExecute_Verbose);
  if PID < 0 then
    begin
      WriteLn ('Error in PExecute: ', ErrMsg);
      Halt
    end;
  WriteLn ('Spawned process #', PID);
  PID := PWait (PID, Status, 0);
  if PID < 0 then
    WriteLn ('Error in PWait')
  else
    begin
      if StatusSignaled (Status) then
        WriteLn ('Process #', PID, ' was terminated by signal ', StatusTermSignal (Status));
      if StatusExited (Status) then
        WriteLn ('Process #', PID, ' terminated with status ', StatusExitCode (Status))
    end
end.
