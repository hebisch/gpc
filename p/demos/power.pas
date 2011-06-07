{ GPC demo program for the GMP unit.
  Computing arbitrary integer powers.

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

program Power;

uses GPC, GMP;

var
  a, e: MedCard;
  p: mpz_t;
  s: CString;

begin
  case ParamCount of
    0: begin
         WriteLn ('Power computation.');
         Write ('Enter the base: ');
         ReadLn (a);
         Write ('Enter the exponent: ');
         ReadLn (e);
       end;
    2: begin
         ReadStr (ParamStr (1), a);
         ReadStr (ParamStr (2), e)
       end;
    else
      WriteLn (StdErr, 'Power computation.');
      WriteLn (StdErr, 'Usage: ', ParamStr (0), ' [base exponent]');
      Halt (1)
  end;
  mpz_init (p);
  mpz_ui_pow_ui (p, a, e);
  s := mpz_get_str (nil, 10, p);
  {$local cstrings-as-strings} WriteLn (a, ' ^ ', e, ' = ', s); {$endlocal}
  WriteLn ('(', CStringLength (s), ' digits)');
  Dispose (s);
  mpz_clear (p)
end.
