{ GPC demo program for the RegEx unit.
  Regular expression matching and replacement.

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

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

program RegExDemo;

uses RegEx;

var
  a: String(100);
  r: RegExType;
  i, j, p, l, o: Integer;
  x, c, n, b, e: Boolean = False;

begin
  WriteLn ('Enter options: e(X)tended, (C)ase-insensitive, (N)ewlines,');
  Write ('no (B)eginning/(E)nd of line: ');
  ReadLn (a);
  for i := 1 to Length (a) do
    case UpCase (a[i]) of
      'X': x := True;
      'C': c := True;
      'N': n := True;
      'B': b := True;
      'E': e := True;
      else WriteLn ('Invalid option `', a[i], '''')
    end;
  Write ('Enter regular expression: ');
  ReadLn (a);
  NewRegEx (r, a, x, c, n);
  if r.Error <> nil then
    begin
      WriteLn (r.Error^);
      Halt
    end;
  WriteLn ('The regex contains ', r.SubExpressions, ' subexpressions.');
  repeat
    WriteLn ('Enter a string to match (empty string when finished):');
    ReadLn (a);
    if a = '' then Break;
    Write ('Search from position: ');
    ReadLn (o);
    WriteLn (a);
    if not MatchRegExFrom (r, a, b, e, o) then
      WriteLn ('No match.')
    else
      for i := 0 to r.SubExpressions do
        begin
          GetMatchRegEx (r, i, p, l);
          if p = 0 then
            WriteLn ('-')
          else
            begin
              Write ('' : p - 1);
              if l = 0 then
                Write ('0')
              else
                for j := 1 to l do Write ('^');
              WriteLn
            end
        end
  until False;
  DisposeRegEx (r)
end.
