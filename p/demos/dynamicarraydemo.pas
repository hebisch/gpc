{ GPC demo program about dynamic arrays (Extended Pascal).

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

program DynamicArrayDemo;

procedure Test (n: Integer);
var
  { A dynamic array. You don't need pointers and `GetMem' to do this
    in GPC. }
  s, c: array [0 .. n - 1] of Real;
  i: Integer;
begin
  WriteLn ('Initializing the array with `sin'' and `cos'' values.');
  for i := 0 to n - 1 do
    begin
      s[i] := Sin (2 * Pi * i / n);
      c[i] := Cos (2 * Pi * i / n)
    end;
  WriteLn;
  WriteLn ('Outputting the values from the array. This could be used for fast');
  WriteLn ('lookups when the values are needed often.');
  WriteLn;
  WriteLn ('i' : 10, 'sin (2 pi i / n)' : 20, 'cos (2 pi i / n)' : 20);
  for i := 0 to n - 1 do
    WriteLn (i : 10, s[i] : 20 : 15, c[i] : 20 : 15)
  { At the end of the procedure the memory of the array is automatically
    freed, just like it is for variables of constant size. }
end;

var
  n: Integer;

begin
  repeat
    Write ('Enter the size for an array: ');
    ReadLn (n)
  until n > 0;
  Test (n)
end.
