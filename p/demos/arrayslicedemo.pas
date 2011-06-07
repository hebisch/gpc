{ GPC demo program about array slice access (Extended Pascal).

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

program ArraySliceDemo;

procedure WriteArray (const a: array [m .. n: Integer] of Integer);
var i: Integer;
begin
  Write ('(');
  for i := m to n do
    begin
      Write ('''', a[i], '''');
      if i < n then Write (', ')
    end;
  WriteLn (')')
end;

procedure ModifyArray (var a: array [m .. n: Integer] of Integer);
var i: Integer;
begin
  for i := m to n do a[i] := Random (100)
end;

var
  s: String (60);
  a: array [1 .. 10] of Integer;
  i: Integer;

begin
  { String slice access is similar to the Copy and SubStr functions ... }
  s := 'With array slice access, you can access parts of an array.';
  WriteLn ('s = ''', s, '''');
  WriteLn ('s[6 .. 23] = ''', s[6 .. 23], '''');
  WriteLn;

  { ... but it can also be used to modify strings. }
  WriteLn ('Setting s[34 .. 39] := ''change''.');
  s[34 .. 39] := 'change';
  WriteLn ('Now s = ''', s, '''');
  WriteLn;

  { Array slice access also works for non-string arrays ... }
  Randomize;
  for i := 1 to 10 do a[i] := Random (100);
  Write ('a = ');
  WriteArray (a);
  Write ('a[3 .. 7] = ');
  WriteArray (a[3 .. 7]);
  WriteLn;

  { ... and, of course, also for modifying. }
  WriteLn ('Modifying a[2 .. 6].');
  ModifyArray (a[2 .. 6]);
  Write ('Now a = ');
  WriteArray (a)
end.
