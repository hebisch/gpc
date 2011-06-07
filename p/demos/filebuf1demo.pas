{ GPC demo program. Reverse the characters of a string read from the
  input. The point is not that it's possible at all, but that it's
  possible without having to declare *any* variable -- of course,
  this recursive way is not the most efficient solution, it's just a
  nice little thing one can do with file buffers. (File buffers are
  a Standard Pascal feature missing in many popular Pascal
  compilers.)

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

program FileBufferDemo1;

procedure Reverse (ch: Char);
begin
  Get (Input);
  if not EOLn then Reverse (Input^);
  Write (ch)
end;

begin
  Write ('Enter a string: ');
  while EOLn do ReadLn;
  Write ('The reversed string is `');
  Reverse (Input^);
  WriteLn ('''')
end.
