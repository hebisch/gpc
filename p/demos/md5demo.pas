{ GPC demo program for the MD5 unit.

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

program FindFilesDemo;

uses GPC, MD5;

var
  i: Integer;
  s: TString;
  f: File;
  MD5Var: TMD5;

begin
  if ParamCount = 0 then
    begin
      Write ('Enter a file name: ');
      ReadLn (s);
      Assign (f, s);
      MD5File (f, MD5Var);
      WriteLn ('The MD5 sum is ', MD5Str (MD5Var))
    end
  else
    for i := 1 to ParamCount do
      begin
        Assign (f, ParamStr (i));
        MD5File (f, MD5Var);
        WriteLn (MD5Str (MD5Var), '  ', ParamStr (i))
      end
end.
