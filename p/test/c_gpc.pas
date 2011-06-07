{ GPC demo program to show how to include C code in Pascal programs.

  Copyright (C) 2000-2006 Free Software Foundation, Inc.

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

program C_GPC;

{ Link the C code. }
{$L c_gpc_c.c}

{ External declarations we use from the C code }

var
  CVariable: CInteger; external name 'c_variable';

procedure CRoutine; external name 'c_routine';

{ Pascal code }

var
  PascalProgramVariable: CInteger = 17; attribute (name = 'pascal_program_variable');

procedure PascalProgramRoutine; attribute (name = 'pascal_program_routine');
begin
  WriteLn ('Routine in Pascal program called from C code.');
  WriteLn ('Decrementing CVariable.');
  Dec (CVariable);
  Flush (Output);
end;

begin
  WriteLn ('Starting in the Pascal main program.');
  WriteLn ('PascalProgramVariable is ', PascalProgramVariable, '.');
  WriteLn ('Calling CRoutine.');
  Flush (Output);
  CRoutine;
  WriteLn ('Back in the Pascal main program.');
  WriteLn ('PascalProgramVariable is now ', PascalProgramVariable, '.')
end.
