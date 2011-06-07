{ GPC demo program for the Trap unit.
  Trapping runtime errors.

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

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

program TrapDemo;

uses Trap;

procedure Test (Trapped: Boolean);
var
  a: Integer;
  s: String [1];
begin
  repeat
    if Trapped then
      begin
        { We know that `Ln (0)' is the only possible error in this
          program. In a more complex program, you could check the
          variables TrappedExitCode etc. }
        WriteLn ('- Infinity. The following runtime error was trapped:');
        WriteLn ('  `', TrappedErrorMessageString, '''');
        Trapped := False  { for subsequent loop cycles }
      end
    else
      begin
        a := Random (4);
        Write ('Ln (', a, ') = ');
        Flush (Output);
        Write (Ln (a) : 0 : 9, '.')  { Causes a runtime error if a = 0. }
      end;
    Write ('  Enter `q'' to quit, anthing else to continue. ');
    if EOF then Halt;
    ReadLn (s)
  until s = 'q'
end;

begin
  Randomize;
  WriteLn ('Demo of the Trap unit of GPC');
  WriteLn;
  TrapExec (Test)
end.
