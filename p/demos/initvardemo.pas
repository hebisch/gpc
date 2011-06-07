{ GPC demo program about initialized variables and typed constants.

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

program InitVarDemo;

var
  Foo: Integer value 42;    { An initialized variable according to ISO 10206 }
  Bar: Integer = 17;        { GPC also supports this syntax }

type
  TBaz = Integer value 19;  { A type with an initialization }

var
  Baz: TBaz;                { A variable initialized from its type }

const
  Qux: Integer = 22;        { A typed *constant* }

procedure DemoGlobal;
begin
  WriteLn ('Initial values:             Foo = ', Foo, '  Bar = ', Bar, '  Baz = ', Baz, '  Qux = ', Qux);
  Inc (Foo);
  Dec (Bar);
  Baz := 2 * Baz;

  { A constant cannot be modified. GPC gives only a warning (which
    we turn off locally here) because many programs written for BP
    or similar compilers rely on the unfortunate behaviour of these
    compilers. Still, one should rather use an initialized variable
    when one wants a variable, and a typed constant only for real
    constants. }
  {$local W-} Qux := 0; {$endlocal}

  WriteLn ('Values after modification:  Foo = ', Foo, '  Bar = ', Bar, '  Baz = ', Baz, '  Qux = ', Qux);
  WriteLn
end;

procedure DemoLocal;
var
  { An initialized local variable. It is initialized whenever the
    procedure is entered. }
  Foo: Integer = 42;

  { A static initialized variable. It is only initialized once at
    the beginning of the program. `static' is a GNU Pascal extension. }
  Bar: Integer = 17; attribute (static);

const
  { A typed constant. Some people use them instead of static
    variables, because some compilers that don't know `static'
    automatically make typed constants static. GPC emulates this
    behaviour, but it is not recommended to make use of it. Better
    declare your variables `static' when that's what you mean. }
  Baz: Integer = 19;

begin
  WriteLn ('Initial values:             Foo = ', Foo, '  Bar = ', Bar, '  Baz = ', Baz);
  Inc (Foo);
  Dec (Bar);
  {$local W-} Baz := 2 * Baz; {$endlocal}  { Again, not recommended }
  WriteLn ('Values after modification:  Foo = ', Foo, '  Bar = ', Bar, '  Baz = ', Baz);
  WriteLn
end;

begin
  WriteLn ('Global variables:');
  DemoGlobal;
  WriteLn ('Local variables, first run:');
  DemoLocal;
  WriteLn ('Local variables, second run:');
  DemoLocal
end.
