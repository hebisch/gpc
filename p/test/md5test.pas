{ Test of the MD5 unit }

program MD5Test;

uses MD5;

const
  TestString = '
Copyright (C) 2000 Free Software Foundation, Inc.

Author: Frank Heckenbach <frank@pascal.gnu.de>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, version 2.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING. If not, write to
the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.

As a special exception, if you incorporate even large parts of the
code of this demo program into another program with substantially
different functionality, this does not cause the other program to
be covered by the GNU General Public License. This exception does
not however invalidate any other reasons why it might be covered
by the GNU General Public License.';

var
  f: File;
  MD5Var: TMD5;

begin
  MD5Buffer (TestString, Length (TestString), MD5Var);
  if MD5Str (MD5Var) <> '1e37c94aaf405a945d8f7581a0b5d3cd' then
    begin
      WriteLn ('failed 1 ', MD5Str (MD5Var));
      Halt
    end;
  Assign (f, '-');
  MD5File (f, MD5Var);
  if MD5Str (MD5Var) <> '73685a9f7fe509c4ae0ca0f203737af7' then
    begin
      WriteLn ('failed 2 ', MD5Str (MD5Var));
      Halt
    end;
  WriteLn ('OK')
end.
