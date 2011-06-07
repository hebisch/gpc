{ GPC demo program. A recursive descent parser for mathematical
  expressions using real or complex numbers.

  The code is Extended Pascal, i.e., it can be compiled with the
  `--extended-pascal' option (but also in GPC's default mode).

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

program ParserDemo (Input, Output);

{ This parser understands the following grammar:

  CONSTANT = "e" | "pi" | "i" | POSITIVE_REAL_NUMBER | POSITIVE_REAL_NUMBER "°" | "$" POSITIVE_HEXADECIMAL_INTEGER_NUMBER
  FUNCTION = "abs" | "sqrt" | "sin" | "cos" | "tan" | "cot" | "arctan" | "exp" | "ln"
  ATOM1 = "(" EXPR ")" | CONSTANT | ATOM1 "!"
  ATOM = ATOM1 | FUNCTION ATOM
  FACTOR = ATOM | FACTOR "^" ATOM
  EXPR1 = FACTOR | EXPR1 "*" FACTOR | EXPR1 FACTOR (not starting with numeric constant) | EXPR1 "/" FACTOR
  EXPR = EXPR1 | EXPR "+" EXPR1 | EXPR "-" EXPR1 | "-" EXPR1 }

{ LoCase (even a version with NLS), Frac and Pi are built into GPC,
  but deactivated when compiling with `--extended-pascal'. }

type
  TString = String (4096);

const
  Pi = 3.1415926535897932384626433832795028841971693993751;

function LoCase (ch: Char): Char;
begin
  if ch in ['A' .. 'Z'] then
    LoCase := Succ (ch, Ord ('a') - Ord ('A'))
  else
    LoCase := ch
end;

function Frac (x: Real): Real;
var i: Real;
begin
  i := Round (x);
  if Abs (i) > Abs (x) then
    if i < 0 then
      i := i + 1
    else
      i := i - 1;
  Frac := x - i
end;

procedure ProcessExpr;

label 99;

  function Real2Integer (x: Real; var i: Integer): Boolean;
  const Delta = 1e-10;
  begin
    if (Abs (x) <= MaxInt) and (Abs (x - Round (x)) <= Delta * Abs (x)) then
      begin
        i := Round (x);
        Real2Integer := True
      end
    else
      Real2Integer := False
  end;

  function Real2String (x: Real) = s: TString;
  var i: Integer;
  begin
    if Real2Integer (x, i) then
      WriteStr (s, i)
    else
      WriteStr (s, x : 0 : 20)
  end;

  function Complex2String (z: Complex) = s: TString;
  begin
    s := Real2String (Re (z));
    if Im (z) > 0 then s := s + ' +';
    if Abs (Im (z)) >= MinReal then s := s + ' ' + Real2String (Im (z)) + ' * i'
  end;

  procedure Skip;
  begin
    while not EOF and not EOLn and (Input^ = ' ') do Get (Input);
    if EOF (Input) then Input^ := ' '
  end;

  procedure Expect (ch: Char);
  begin
    Skip;
    if Input^ <> ch then
      begin
        WriteLn ('`', ch, ''' expected');
        goto 99
      end;
    Get (Input)
  end;

  function Expr: Complex;

    function Atom: Complex;
    const
      MaxFactorial = 170;
      MaxFNames = 12;
    var
      FNames: array [1 .. MaxFNames] of String (6) value
        [1: 'e'; 2: 'pi'; 3: 'i';
         4: 'abs'; 5: 'sqrt'; 6: 'sin'; 7: 'cos'; 8: 'tan'; 9: 'cot';
         10: 'arctan'; 11: 'exp'; 12: 'ln'];
      f: TString;
      n, i: Integer;
      c: Integer;
      r: Real;
      z: Complex;
      FactorialAllowed: Boolean;
    begin
      Skip;
      FactorialAllowed := True;
      case LoCase (Input^) of
        '0' .. '9',
        '.'       : begin
                      Read (r);
                      z := r;
                      Skip;
                      if Input^ = '°' then
                        begin
                          z := z * Pi / 180;
                          Get (Input)
                        end
                    end;
        '$'       : begin
                      Read (c);
                      z := c
                    end;
        '('       : begin
                      Expect ('(');
                      z := Expr;
                      Expect (')')
                    end;
        'a' .. 'z': begin
                      f := '';
                      while not EOF (Input) and (LoCase (Input^) in ['a' .. 'z']) do
                        begin
                          f := f + LoCase (Input^);
                          Get (Input)
                        end;
                      i := MaxFNames;
                      while (i > 0) and (f <> FNames[i]) do i := i - 1;
                      if i = 0 then
                        begin
                          WriteLn ('Unknown function `', f, '''');
                          goto 99
                        end;
                      case i of
                        1: z := Exp (1);
                        2: z := Pi;
                        3: z := Cmplx (0, 1);
                        otherwise
                          FactorialAllowed := False;
                          z := Atom;
                          case i of
                             4: z := Abs (z);
                             5: z := SqRt (z);
                             6: z := Sin (z);
                             7: z := Cos (z);
                             8: z := Sin (z) / Cos (z);
                             9: z := Cos (z) / Sin (z);
                            10: z := ArcTan (z);
                            11: z := Exp (z);
                            12: z := Ln (z);
                          end
                      end
                    end;
        otherwise
          WriteLn ('Parse error.');
          goto 99
      end;
      if FactorialAllowed then
        begin
          Skip;
          while Input^ = '!' do
            begin
              if (Abs (Im (z)) < MinReal) and Real2Integer (Re (z), n) and (n >= 0) and (n <= MaxFactorial) then
                begin
                  r := 1;
                  for i := 2 to n do r := i * r;
                  z := r
                end
              else
                begin
                  WriteLn ('Argument of `!'' must be an integer between 0 and ', MaxFactorial, '.');
                  goto 99
                end;
              Get (Input);
              Skip
            end
        end;
      Atom := z
    end;

    function Factor: Complex;
    var
      z, z1: Complex;
      f: Boolean;
    begin
      z := Atom;
      repeat
        Skip;
        f := True;
        case Input^ of
          '^': begin
                 Get (Input);
                 z1 := Atom;
                 if z <> 0 then
                   z := Exp (z1 * Ln (z))
                 else if z1 = 0 then
                   z := 1
               end;
          otherwise f := False
        end
      until not f;
      Factor := z
    end;

    function Expr1: Complex;
    var
      z: Complex;
      f: Boolean;
    begin
      z := Factor;
      repeat
        Skip;
        f := True;
        case LoCase (Input^) of
          '*': begin
                 Get (Input);
                 z := z * Factor
               end;
          '/': begin
                 Get (Input);
                 z := z / Factor
               end;
          '(', 'a' .. 'z': z := z * Factor;
          otherwise f := False
        end
      until not f;
      Expr1 := z
    end;

  var
    z: Complex;
    s, f: Boolean;
  begin
    Skip;
    s := False;
    while Input^ in ['+', '-'] do
      begin
        if Input^ = '-' then s := not s;
        Get (Input);
        Skip
      end;
    z := Expr1;
    if s then z := - z;
    repeat
      Skip;
      f := True;
      case Input^ of
        '+': begin
               Get (Input);
               z := z + Expr1
             end;
        '-': begin
               Get (Input);
               z := z - Expr1
             end;
        otherwise f := False
      end
    until not f;
    Expr := z
  end;

begin
  WriteLn (Complex2String (Expr));
  if not EOLn then WriteLn ('Superfluous characters after the expression');
99:
  ReadLn
end;

begin
  WriteLn ('Enter expressions consisting of');
  WriteLn ('- real numbers, using the `e'' notation,');
  WriteLn ('- the constants `e'', `pi'', `i'',');
  WriteLn ('- the operators `+'', `-'', `*'', `/'', `^'',');
  WriteLn ('- the functions `abs'', `sqrt'', `sin'', `cos'', `tan'', `cot'', `arctan'', `exp'', `ln'',');
  WriteLn ('- parentheses.');
  WriteLn;
  WriteLn ('Note: Due to the `e'' notation, there is a problem with terms like `2e'' which');
  WriteLn ('will be interpreted as `2*10^...''. If you mean `2*e'', write it this way, or');
  WriteLn ('as `2 e''. Expressions like `3e+4+5'' can be confusing, but are interpreted');
  WriteLn ('according to the `e'' notation (i.e., this expression equals 30005).');
  WriteLn;
  WriteLn ('Enter an empty line when finished.');
  while not EOLn do ProcessExpr
end.
