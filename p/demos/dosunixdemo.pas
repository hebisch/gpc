{ GPC demo program for the DosUnix unit.
  Some routines to support writing programs portable between Dos and
  Unix.

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

program DosUnixDemo;

uses GPC, DosUnix;

const
  ExtraCR = {$ifdef __OS_DOS__} '' {$else} #13 {$endif};
  Command = 'foo &> bar';

var
  t: Text;
  s, n: TString;

begin
  WriteLn ('Demo of TranslateRedirections:');
  WriteLn;
  WriteLn ('A sample command line: `', Command, '''');
  WriteLn ('The command line with redirections translated: `',
    TranslateRedirections (Command), '''');
  WriteLn ('(You should only see a difference under Dos.)');
  WriteLn;
  WriteLn;
  WriteLn ('Demo of AssignDos:');
  WriteLn;
  WriteLn ('Creating a file with extra CRs (if not under Dos).');
  n := GetTempFileName;
  Assign (t, n);
  Rewrite (t);
  WriteLn (t, 'foo', ExtraCR);
  WriteLn (t, 'bar', ExtraCR);
  WriteLn (t, 'Hello world', ExtraCR);
  WriteLn ('Reading back the file in the normal way.');
  WriteLn ('The `.'' "after" each line will show the effect of the extra CR (not under Dos).');
  Assign (t, n);
  Reset (t);
  while not EOF (t) do
    begin
      ReadLn (t, s);
      WriteLn (s, '.')
    end;
  Close(t);
  WriteLn;
  WriteLn ('Now reading the file using AssignDos.');
  WriteLn ('This should work correctly whether under Dos or not.');
  AssignDos (t, n);
  Reset (t);
  while not EOF (t) do
    begin
      ReadLn (t, s);
      WriteLn (s, '.')
    end;
  Close (t);
  Assign (t, n);
  Erase (t)
end.
