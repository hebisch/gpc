{ GPC demo program to show how to include Pascal code in C programs.

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

program GPC_C_Pas;

uses GPC_C_U;

{ Tell the compiler not to create `main', but something else. }
{$gpc-main=Dummy}

{ We link the C code using a compiler directive. Although the C code
  contains the main program, the linker doesn't mind if we do it
  like this and compile the Pascal program. But you can just as well
  compile the Pascal code with `-c' and link it to the C code
  explicitly. }
{$L gpc_c_c.c}

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
  WriteLn ('PascalProgramVariable is now ', PascalProgramVariable, '.');

  WriteLn ('Decrementing CVariable.');
  Dec (CVariable);

  WriteLn ('Calling CRoutine.');
  Flush (Output);
  CRoutine;

  WriteLn ('Back in Pascal program''s routine');
  Flush (Output)
end;

{ This is not the main program in this setting! }
begin
  WriteLn ('This is never called.');
  Flush (Output)
end.
