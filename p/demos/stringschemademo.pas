{ GPC demo program about strings being schemata (Extended Pascal
  feature). This is similar to schemademo.pas.

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

program StringSchemaDemo;

{ A procedure taking a string (schema) parameter. A string is a built-in
  schema type with the following declaration:

  String (Capacity: Cardinal) = record
    Length: 0 .. Capacity;
    Chars: packed array [1 .. Capacity + 1] of Char
  end; }
procedure Test (var s: String);
begin
  WriteLn ('The procedure was called with a string of capacity ', s.Capacity, ', length ', Length (s));
  WriteLn ('and the value ''', s, '''.');
  WriteLn;
  WriteLn ('Now we append ''bar'' to the string. However, the routines know the');
  WriteLn ('capacity of the string, so if appending to it would make it longer than');
  WriteLn ('its capacity, they will not write beyond the capacity. This works simply');
  WriteLn ('because strings are schemata, without any work required by the programmer.');
  WriteLn;
  s := s + 'bar';
  WriteLn ('The string has now a capacity of ', s.Capacity, ' (still), a length of ', Length (s));
  WriteLn ('and the value ''', s, '''.');
  WriteLn
end;

var
  Foo: String (10) = 'foo';
  a: Integer;
  StrPtr: ^String;

begin
  Test (Foo);

  repeat
    Write ('Enter the capacity for a string: ');
    ReadLn (a)
  until a >= 1;

  { A schema array declared in the statement part (GPC extension) }
  var t: String (a);

  Write ('Enter the contents of the string: ');
  ReadLn (t);
  WriteLn;
  Test (t);

  WriteLn ('Now we dynamically allocate a string of the same capacity.');
  New (StrPtr, a);
  Write ('Enter the contents of the new string: ');
  ReadLn (StrPtr^);
  WriteLn;
  Test (StrPtr^);
  Dispose (StrPtr)
end.
