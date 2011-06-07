{ GPC demo program for the StatFS function.

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

program StatFSDemo;

uses GPC;

var
  s: TString;
  Buf: StatFSBuffer;

begin
  Write ('Enter a path: ');
  ReadLn (s);
  if not StatFS (s, Buf) then
    WriteLn ('Could not stat file system. Probably the path given is invalid.')
  else
    with Buf do
      begin
        WriteLn ('The file system on which the given file resides has');
        WriteLn (BlockSize * BlocksTotal : 15, ' bytes total');
        WriteLn (BlockSize * BlocksFree  : 15, ' bytes available');
        WriteLn (FilesTotal              : 15, ' file nodes total');
        WriteLn (FilesFree               : 15, ' file nodes free')
      end
end.
