{ GPC demo program about conformant array parameters
  (Standard Pascal, level 1).

  This is similar to BP's "open array parameters" (which GPC also
  supports), but easier to use, since it doesn't require `High' to
  get the higher limit of the array, and it doesn't automatically
  change the lower limit of the array to 0.

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

program ConformantArrayDemo;

procedure Test (const Foo: array [m .. n: Integer] of Char);
var i: Integer;
begin
  WriteLn ('The procedure was called with an `array [', m, ' .. ', n, '] of Char'' with the value:');
  Write ('(');
  for i := m to n do
    begin
      Write ('''', Foo[i], '''');
      if i < n then Write (', ')
    end;
  WriteLn (')');
  WriteLn
end;

const
  Foo: array [3 .. 5] of Char = ('F', 'o', 'o');
  Bar: array [-1 .. 1] of Char = 'Bar';  { Initializing an array of char
                                           like a string (BP compatible) }

var
  a, b: Integer;

begin
  Test (Foo);
  Test (Bar);
  Test ('Baz');  { One can also pass a string constant }
  Test (Foo[3 .. 4]);  { array slice access }

  repeat
    Write ('Enter a lower and higher bound for an array: ');
    ReadLn (a, b)
  until a <= b;

  { A dynamic array (Extended Pascal) declared in the
    statement part (GPC extension) }
  var t: array [a .. b] of Char;

  Write ('Enter the content of the array: ');
  ReadLn (t);
  WriteLn;
  Test (t)
end.
