{ GPC demo program. Using internal files without worrying about
  creating temporary file names and erasing the files later. (This
  is a Standard Pascal feature missing in many popular Pascal
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

program InternalFilesDemo;

var
  f: Text;
  s: String (4096);

begin
  Rewrite (f);
  WriteLn ('Enter some text (an empty line when finished).');
  while not EOLn do
    begin
      ReadLn (s);
      WriteLn (f, s)
    end;
  Reset (f);
  WriteLn ('The text was:');
  while not EOF (f) do
    begin
      ReadLn (f, s);
      WriteLn (s)
    end
end.
