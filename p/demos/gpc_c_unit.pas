{ GPC demo unit to show how to include Pascal code in C programs.

  Copyright (C) 2000-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  This program is free software. You can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, version 2.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program, see the file COPYING. If not, write to
  the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA.

  As a special exception, if you incorporate even large parts of the
  code of this demo program into another program with substantially
  different functionality, this does not cause the other program to
  be covered by the GNU General Public License. This exception does
  not however invalidate any other reasons why it might be covered
  by the GNU General Public License. }

unit GPC_C_Unit;

interface

var
  PascalUnitVariable: CInteger = 42; attribute (name = 'pascal_unit_variable');

procedure PascalUnitRoutine; attribute (name = 'pascal_unit_routine');

implementation

procedure PascalUnitRoutine;
begin
  WriteLn ('Routine in Pascal unit called from C code.');
  WriteLn ('PascalUnitVariable is now ', PascalUnitVariable, '.');
  Flush (Output)
end;

to begin do
  begin
    WriteLn ('Initializer of Pascal unit called.');
    WriteLn ('PascalUnitVariable is now ', PascalUnitVariable, '.');
    Flush (Output)
  end;

to end do
  begin
    WriteLn ('Finalizer of Pascal unit called.');
    Flush (Output)
  end;

end.
