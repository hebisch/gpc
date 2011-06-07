{ GPC demo program for the GMP unit.
  Computing arbitrary integer factorials.

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

program Factorial;

uses GPC, GMP;

var
  n: Integer;
  r: mpz_t;
  s: CString;

begin
  case ParamCount of
    0: begin
         WriteLn ('Factorial computation.');
         Write ('Enter a number: ');
         ReadLn (n)
       end;
    1: ReadStr (ParamStr (1), n);
    else
      WriteLn (StdErr, 'Factorial computation.');
      WriteLn (StdErr, 'Usage: ', ParamStr (0), ' [n]');
      Halt (1)
  end;
  mpz_init (r);
  mpz_fac_ui (r, n);
  s := mpz_get_str (nil, 10, r);
  {$local cstrings-as-strings} WriteLn (n, '! = ', s); {$endlocal}
  WriteLn ('(', CStringLength (s), ' digits)');
  Dispose (s);
  mpz_clear (r)
end.
