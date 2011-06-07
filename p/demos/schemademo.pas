{ GPC demo program about schemata (Extended Pascal feature).
  Schemata are the Pascal way to get dynamic arrays without dirty
  tricks (like `GetMem' with computed sizes). Although GPC supports
  these dirty tricks, too, their use is not recommended.

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

program SchemaDemo;

type
  Natural = 1 .. MaxInt;

  { A schema type. `Count' is the discriminant which can influence the size
    of the type. Discriminants must be specified when declaring variables,
    function return types and when allocating a schema variable with `New',
    but parameters and pointer types can refer to undiscriminated schemata. }
  TIntegers (Size: Integer) = array [1 .. Size] of Integer;

  { A pointer to this schema type. }
  PIntegers = ^TIntegers;

{ A procedure taking a schema parameter }
procedure Test (const Foo: TIntegers);
var i: Integer;
begin
  WriteLn ('The procedure was called with a schema of size ', Foo.Size, ' with the value:');
  Write ('(');
  for i := 1 to Foo.Size do
    begin
      Write (Foo[i]);
      if i < Foo.Size then Write (', ')
    end;
  WriteLn (')');
  WriteLn
end;

const
  Foo: TIntegers (3) = (2, 3, 17);

var
  a, i: Integer;
  t: ^TIntegers;

begin
  Test (Foo);

  repeat
    Write ('Enter the size for a schema array: ');
    ReadLn (a)
  until a >= 1;

  { Allocate t dynamically }
  New (t, a);

  WriteLn ('Enter the contents of the schema array:');
  for i := 1 to a do Read (t^[i]);
  WriteLn;
  Test (t^);

  Dispose (t)
end.
