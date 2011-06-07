{ GPC demo program for the binobj utility.

  Build it like this:

  binobj foo testobject TestObject
  gpc --executable-file-name binobjdemo.pas

  where `foo' is any (preferably text) file. The binobjdemo will
  then contain the contents of that file and print them to standard
  output. (Of course, a real program could do something more useful
  with them.)

  Note for BP compatiblity: BP only supports external procedures,
  not variables, and BP's binobj doesn't produce a variable
  containing the size of the object (and, of course, the size of the
  object is limited to 64KB in BP). So, this demo program won't work
  with BP, but GPC is upwardly compatible.

  Copyright (C) 2001-2006 Free Software Foundation, Inc.

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

program BinObjDemo;

{$L testobject.o}
var
  TestObject: array [1 .. MaxInt div 8] of Char; external name 'TestObject';
  TestObjectSize: Integer; external name 'TestObjectSize';

begin
  if TestObjectSize = 0 then
    WriteLn ('Test object is empty!')
  else
    Write (TestObject[1 .. TestObjectSize])
end.
