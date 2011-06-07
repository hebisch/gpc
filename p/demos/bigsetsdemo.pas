{ GPC demo program for sets of arbitrarily big size and set
  iteration with `for'. Note, this is NOT an efficient sorting
  algorithm!

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

{$setlimit=100000}

program BigSetsDemo;

const
  m = 100000;

var
  a: Integer;
  s, s2: set of 1 .. m = [];

begin
  WriteLn ('Enter some numbers between 1 and ', m, ' (one or several per line).');
  WriteLn ('Enter an empty line when finished.');
  while not EOLn do
    begin
      repeat
        while not (Input^ in ['0' .. '9']) do
          begin
            if Input^ <> ' ' then WriteLn ('Invalid character `', Input^, '''');
            Get (Input)
          end;
        Read (a);
        if (a < 1) or (a > m)
          then WriteLn (a, ' is out of range.')
          else
            begin
              s2 := [a];
              s := s + s2
            end
      until EOLn;
      ReadLn
    end;
  WriteLn ('You entered the following numbers:');
  for a in s do Write (a : 8);
  WriteLn
end.
