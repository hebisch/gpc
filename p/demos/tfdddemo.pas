{ GPC demo program for the TFDD unit.
  Some text file tricks.

  Copyright (C) 2002-2006 Free Software Foundation, Inc.

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

program TFDDDemo;

uses TFDD;

const
  LogFileName = 'tfdddemo.log';

var
  LogFile, BothFiles: Text;

begin
  Rewrite (LogFile, LogFileName);
  MultiFileWrite (BothFiles, Output, LogFile);
  WriteLn ('This line appears only on standard output.');
  WriteLn (Output, 'This line as well.');
  WriteLn (LogFile, 'This line appears only in the log file.');
  WriteLn (BothFiles, 'But this line and the following one appear both on standard output');
  WriteLn (BothFiles, 'and in the log file (', LogFileName, '), with just one `WriteLn''.')
end.
