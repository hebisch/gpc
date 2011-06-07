{ GPC demo program. How to find files in a directory tree using the
  FileUtils unit.

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

uses GPC, FileUtils;

var
  FoundAnything: Boolean = False;

procedure DoOutput (const s: String);
begin
  WriteLn (s);
  FoundAnything := True
end;

begin
  WriteLn ('This program lists all Pascal source files (extensions `.pas'', `.p'', `.pp'', `.dpr'')');
  WriteLn ('in the current directory and all subdirectories:');
  FindFiles (DirSelf, '*.{pas,p,pp,dpr}', False, DoOutput, nil);
  if not FoundAnything then WriteLn ('No matching files found.')
end.
