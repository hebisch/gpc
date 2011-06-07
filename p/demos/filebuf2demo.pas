{ GPC demo program. You can check the next character of a text file
  without reading it. So you can read an integer after checking that
  really a digit is following, without having to read the integer
  into a string and convert it afterwards. (This is a Standard
  Pascal feature missing in many popular Pascal compilers.)

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

program FileBufferDemo2;

var
  n: Integer;
  s: String (4096);

begin
  Write ('Enter a (non-negative) number or a string: ');
  if Input^ in ['0' .. '9'] then
    begin
      ReadLn (n);
      WriteLn ('The number was ', n)
    end
  else
    begin
      ReadLn (s);
      WriteLn ('The string was `', s, '''')
    end
end.
