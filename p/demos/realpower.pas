{ GPC demo program for the GMP unit.
  Computing arbitrary real powers and roots.

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

program RealPower;

uses GPC, GMP;

const
  DefaultNumberOfDigits = 100;

procedure mpf_ReadStr (const s: String; var Dest: mpf_t);
begin
  mpf_init (Dest);
  if mpf_set_str (Dest, s, 10) <> 0 then
    begin
      WriteLn ('Invalid numeric format.');
      RunError
    end
end;

var
  d: MedCard;
  p_r, a_r, e_r: mpf_t;
  BaseStr, ExpStr, DigitsStr, TempStr: TString;
  RootFlag: Boolean;
  ex: mp_exp_t;
  s, q: CString;

begin
  case ParamCount of
    0   : begin
            WriteLn ('Real power/root computation.');
            Write ('Enter the base: ');
            ReadLn (BaseStr);
            Write ('Enter the exponent (or `1/n'' for a root): ');
            ReadLn (ExpStr);
            Write ('Enter the number of digits wanted (default: ', DefaultNumberOfDigits, '): ');
            ReadLn (DigitsStr);
          end;
    2, 3: begin
            BaseStr := ParamStr (1);
            ExpStr := ParamStr (2);
            DigitsStr := ParamStr (3)
          end;
    else
      WriteLn (StdErr, 'Real power/root computation.');
      WriteLn (StdErr, 'Usage: ', ParamStr (0), ' [base [1/]exponent [number_of_digits]]');
      Halt (1)
  end;
  if DigitsStr = '' then d := DefaultNumberOfDigits else ReadStr (DigitsStr, d);
  mpf_set_default_prec (Round (d * Ln (10) / Ln (2)) + 64);
  mpf_ReadStr (BaseStr, a_r);
  RootFlag := Copy (ExpStr, 1, 2) = '1/';
  TempStr := ExpStr;
  if RootFlag then Delete (TempStr, 1, 2);
  mpf_ReadStr (TempStr, e_r);
  if RootFlag then mpf_ui_div (e_r, 1, e_r);
  mpf_init (p_r);
  mpf_pow (p_r, a_r, e_r);
  Write (BaseStr, ' ^ ', ExpStr, ' ~ ');
  s := mpf_get_str (nil, ex, 10, d, p_r);
  {$local cstrings-as-strings,pointer-arithmetic}
  if s[0] = '-' then
    begin
      Write ('-');
      q := s + 1
    end
  else
    q := s;
  WriteLn ('0.', q, 'e', ex);
  {$endlocal}
  Dispose (s);
  mpf_clear (p_r)
end.
