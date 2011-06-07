{ GPC demo program. How to use procedural parameters and pass global
  and local procedures to them without the need for any dirty tricks
  (e.g. assembler code) that other compilers require. This demo
  program uses procedural parameters to implement a list iterator.

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

program IteratorDemo;

type
  PList = ^TList;
  TList = record
    Next: PList;
    Val: Integer
  end;

{ Define an iterator using a procedural parameter. The following is the
  Standard Pascal syntax. GPC also supports the BP syntax (defining a
  procedural type in advance), but that would be longer in this case. }
procedure ForEach (p: PList; procedure Proc (var Element: TList));
begin
  while p <> nil do
    begin
      Proc (p^);
      p := p^.Next
    end
end;

procedure ListDemo;
var
  List: PList;
  a: Integer;

  procedure ReadList;
  var
    pp: ^PList;
    i: Integer;
  begin
    pp := @List;
    WriteLn ('Enter some numbers. Enter an empty line when finished.');
    repeat
      Read (i);
      New (pp^);
      pp^^.Val := i;
      pp := @pp^^.Next;
      if EOLn then ReadLn
    until EOLn;
    pp^ := nil
  end;

  procedure WriteElement (var Element: TList);
  begin
    Write (Element.Val : 8)
  end;

  procedure AddToElement (var Element: TList);
  begin
    Inc (Element.Val, a)  { This procedure can access the variable a without
                           problems, even though it is called by ForEach,
                           and ForEach doesn't know about a. }
  end;

begin
  ReadList;
  WriteLn;
  WriteLn ('The values are:');
  ForEach (List, WriteElement);
  WriteLn;
  WriteLn;
  Write ('Enter a number to add to all elements in the list: ');
  ReadLn (a);
  ForEach (List, AddToElement);
  WriteLn;
  WriteLn ('The values are now:');
  ForEach (List, WriteElement);
  WriteLn
end;

begin
  ListDemo
end.
