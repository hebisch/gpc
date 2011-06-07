{ Mathematical routines

  Copyright (C) 1997-2006 Free Software Foundation, Inc.

  Authors: Frank Heckenbach <frank@pascal.gnu.de>
           Jukka Virtanen <jtv@hut.fi>
           Emil Jerabek <jerabek@math.cas.cz>
           Maurice Lombardi <Maurice.Lombardi@ujf-grenoble.fr>

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published
  by the Free Software Foundation; either version 3, or (at your
  option) any later version.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with GNU Pascal; see the file COPYING. If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.

  As a special exception, if you link this file with files compiled
  with a GNU compiler to produce an executable, this does not cause
  the resulting executable to be covered by the GNU General Public
  License. This exception does not however invalidate any other
  reasons why the executable file might be covered by the GNU
  General Public License. }

{$gnu-pascal,I-}

unit Math; attribute (name = '_p__rts_Math');

interface

uses RTSC, Error;

{@internal}
const
  GPC_Pi = 3.1415926535897932384626433832795028841971693993751;

function GPC_Frac (x: LongestReal): LongestReal; attribute (const, name = '_p_Frac');
function GPC_Int  (x: LongestReal): LongestReal; attribute (const, name = '_p_Int');
{@endinternal}
function Ln1Plus  (x: Real) = y: Real; attribute (const, name = '_p_Ln1Plus');

{@internal}
function Integer_Pow  (x, y: LongestInt) = r: LongestInt;      attribute (const, name = '_p_Integer_Pow');
function Real_Pow     (x: Real    ; y: Integer) = r: Real;     attribute (const, name = '_p_Pow');
function LongReal_Pow (x: LongReal; y: Integer) = r: LongReal; attribute (const, name = '_p_LongReal_Pow');
function Complex_Abs    (z: Complex)            : Real;        attribute (const, name = '_p_Complex_Abs');
function Complex_Arg    (z: Complex)            : Real;        attribute (const, name = '_p_Arg');
function Complex_Polar  (Length, Theta: Real)   : Complex;     attribute (const, name = '_p_Polar');
function Complex_ArcSin (z: Complex)            : Complex;     attribute (const, name = '_p_Complex_ArcSin');
function Complex_ArcCos (z: Complex)            : Complex;     attribute (const, name = '_p_Complex_ArcCos');
function Complex_ArcTan (z: Complex)            : Complex;     attribute (const, name = '_p_Complex_ArcTan');
function Complex_SqRt   (z: Complex)            : Complex;     attribute (const, name = '_p_Complex_SqRt');
function Complex_Ln     (z: Complex)            : Complex;     attribute (const, name = '_p_Complex_Ln');
function Complex_Exp    (z: Complex)            : Complex;     attribute (const, name = '_p_Complex_Exp');
function Complex_Sin    (z: Complex)            : Complex;     attribute (const, name = '_p_Complex_Sin');
function Complex_Cos    (z: Complex)            : Complex;     attribute (const, name = '_p_Complex_Cos');
function Complex_Pow    (z: Complex; y: Integer) = r: Complex; attribute (const, name = '_p_Complex_Pow');
function Complex_Power  (z: Complex; y: Real)   : Complex;     attribute (const, name = '_p_Complex_Power');
{@endinternal}

implementation

{$ifndef HAVE_NO_RTS_CONFIG_H}
{$include "rts-config.inc"}
{$endif}

function GPC_Frac (x: LongestReal): LongestReal;
const f = 1 shl (BitSizeOf (LongestInt) div 2);
var
  Negative: Boolean;
  Exp: Integer;
  DigitVal: LongestReal;
begin
  if (Ord (x = 0) + Ord (x < 0) + Ord (x > 0) <> 1) or (x + x = x) then
    begin
      GPC_Frac := x;
      Exit
    end;
  Negative := x < 0;
  if Negative then x := - x;
  Exp := 0;
  DigitVal := 1;
  while x / DigitVal >= f do
    begin
      DigitVal := DigitVal * f;
      Inc (Exp)
    end;
  while (Exp >= 0) and (x <> 0) do
    begin
      x := x - Trunc (x / DigitVal) * DigitVal;
      DigitVal := DigitVal / f;
      Dec (Exp)
    end;
  if Negative then GPC_Frac := - x else GPC_Frac := x
end;

function GPC_Int (x: LongestReal): LongestReal;
var Temp: LongestReal;
begin
  if (Ord (x = 0) + Ord (x < 0) + Ord (x > 0) <> 1) or (x + x = x) then
    GPC_Int := 0
  else
    begin
      Temp := GPC_Frac (x);
      if Temp = 0 then
        GPC_Int := x
      else
        GPC_Int := x - Temp
    end
end;

function Ln1Plus (x: Real) = y: Real;
{$ifdef HAVE_LOG1P}
begin
  y := InternalLn1Plus (x)
end;
{$else}
const MaxExpEpsReal = BitSizeOf (Real);
var
  Inited: Boolean = False; attribute (static);
  ExpEpsReal: CInteger; attribute (static);
  Coefficients: array [0 .. MaxExpEpsReal div 3] of Real; attribute (static);
  DummyMantissa: LongReal;
  i, n: CInteger;
  z, u: Real;
begin
  if (x <= -0.5) or (x >= 1) then
    y := Ln (1 + x)
  else
    begin
      if not Inited then
        begin
          Inited := True;
          SplitReal (EpsReal, ExpEpsReal, DummyMantissa);
          Dec (ExpEpsReal);
          if Abs (ExpEpsReal) > MaxExpEpsReal then
            InternalErrorCString (900, 'Ln1Plus');  { internal error in `%' }
          for i := 0 to MaxExpEpsReal div 3 do Coefficients[i] := 2 / (i * 2 + 1)
        end;
      u := x / (2 + x);
      z := Sqr (u);
      if z <= MinReal then
        y := x
      else
        begin
          SplitReal (z, n, DummyMantissa);
          n := ExpEpsReal div n;
          y := 0;
          for i := n downto 0 do y := y * z + Coefficients[i];
          y := y * u
        end
    end
end;
{$endif}

{ Semantics according to EP 6.8.3.2 }
function Integer_Pow (x, y: LongestInt) = r: LongestInt;
begin
  if x = 0 then
    if y > 0 then
      r := 0
    else
      begin
        SetReturnAddress (ReturnAddress (0));
        RuntimeError (703);  { left argument of `pow' is 0 while right argument is <= 0 }
        RestoreReturnAddress
      end
  else if (y = 0) or (x = 1) then
    r := 1
  else if x = -1 then
    if Odd (y) then
      r := -1
    else
      r := 1
  else if y < 0 then
    r := 0
  else
    begin
      r := 1;
      while y <> 0 do
        begin
          if Odd (y) then r := r * x;
          y := y shr 1;
          if y <> 0 then x := Sqr (x)
        end
    end
end;

function Real_Pow (x: Real; y: Integer) = r: Real;
begin
  if x = 0 then
    if y > 0 then
      r := 0
    else
      begin
        SetReturnAddress (ReturnAddress (0));
        RuntimeError (703);  { left argument of `pow' is 0 while right argument is <= 0 }
        RestoreReturnAddress
      end
  else
    begin
      if y < 0 then
        begin
          x := 1 / x;
          y := -y
        end;
      r := 1;
      while y <> 0 do
        begin
          if Odd (y) then r := r * x;
          y := y shr 1;
          if y <> 0 then x := Sqr (x)
        end
    end
end;

function LongReal_Pow (x: LongReal; y: Integer) = r: LongReal;
begin
  if x = 0 then
    if y > 0 then
      r := 0
    else
      begin
        SetReturnAddress (ReturnAddress (0));
        RuntimeError (703);  { left argument of `pow' is 0 while right argument is <= 0 }
        RestoreReturnAddress
      end
  else
    begin
      if y < 0 then
        begin
          x := 1 / x;
          y := -y
        end;
      r := 1;
      while y <> 0 do
        begin
          if Odd (y) then r := r * x;
          y := y shr 1;
          if y <> 0 then x := Sqr (x)
        end
    end
end;

function Complex_Abs (z: Complex): Real;
{$ifdef HAVE_HYPOT}
begin
  Complex_Abs := InternalHypot (Re (z), Im (z))
end;
{$else}
var AbsX, AbsY: Real;
begin
  AbsX := Abs (Re (z));
  AbsY := Abs (Im (z));
  if AbsX > AbsY then
    Complex_Abs := AbsX * SqRt (1 + Sqr (AbsY / AbsX))
  else if AbsY = 0 then
    Complex_Abs := 0
  else
    Complex_Abs := AbsY * SqRt (1 + Sqr (AbsX / AbsY))
end;
{$endif}

function Complex_Arg (z: Complex): Real;
begin
  if z = 0 then
    begin
      SetReturnAddress (ReturnAddress (0));
      RuntimeError (704);  { Cannot take `Arg' of zero }
      RestoreReturnAddress
    end;
  Complex_Arg := ArcTan2 (Im (z), Re (z))
end;

function Complex_Polar (Length, Theta: Real): Complex;
begin
  Complex_Polar := Cmplx (Length * Cos (Theta), Length * Sin (Theta))
end;

function Complex_ArcSin (z: Complex): Complex;
var t: Complex;
begin
  t := Complex_Ln (Cmplx (-Im (z), Re (z)) + SqRt (1 - Sqr (z)));
  Complex_ArcSin := Cmplx (Im (t), -Re (t))
end;

function Complex_ArcCos (z: Complex): Complex;
var t: Complex;
begin
  t := Complex_Ln (z + SqRt (Sqr (z) - 1));
  Complex_ArcCos := Cmplx (Im (t), -Re (t))
end;

{ ArcTan (z) = -i / 2 * Ln ((1 + i * z) / (1 - i * z)) }
function Complex_ArcTan (z: Complex): Complex;
const Ln2 = 0.6931471805599453094172321214581765680755;
{$if False}
var a, b, c, x, y, AbsX, AbsY: Real;
begin
  x := Re (z);
  AbsX := Abs (x);
  c := x * 0.5 * x;
  y := Im (z);
  AbsY := Abs (y);
  a := 1 - AbsY;
  if c + a * 0.5 * a <= 2.5 / MaxReal then
    { b := (Ln2 - Ln (AbsX)) / 2 }
    { b := -Ln (Abs (Cmplx (x, a)) / (1 + AbsY)) / 2 }
    b := -Ln (Abs (Cmplx (x, a)) / Abs (Cmplx (x, 1 + AbsY))) / 2
  else if Abs (a) > AbsX then
    b := Ln1Plus (4 * (AbsY / a) / (a + x * (x / a))) / 4
  else
    b := Ln1Plus (4 * (AbsY / x) / (a * (a / x) + x)) / 4;
  if y < 0 then b := -b;
  Complex_ArcTan := Cmplx (ArcTan2 (x, (1 + AbsY) * 0.5 * a - c) / 2, b)
end;
{$else}
var
  x, y, a, b, c, d, AbsX, AbsY: Real;
  Inited: Boolean = False; attribute (static);
  FunnyNumber: Real; attribute (static);
begin
  if not Inited then
    begin
      Inited := True;
      FunnyNumber := 2.1 / SqRt (MaxReal)
    end;
  x := Re (z);
  AbsX := Abs (x);
  y := Im (z);
  AbsY := Abs (y);
  b := 1 - AbsY;
  d := (1 + AbsY) / 2;
  if b < 0 then d := -d;
  b := Abs (b);
  if AbsX >= b then
    begin
      c := b / AbsX;
      d := d * c - AbsX / 2;
      if AbsX <= FunnyNumber then
        b := Ln2 - Ln (4 * AbsX * SqRt (1 + Sqr (c)) / (1 + AbsY)) / 2
      else
        b := Ln1Plus (2 * (AbsY / AbsX) / (b * c / 2 + AbsX / 2)) / 4;
      c := 1
    end
  else
    begin
      c := AbsX / b;
      a := AbsX * c / 2;
      d := d - a;
      if b <= FunnyNumber then
        b := Ln2 - Ln (4 * b * SqRt (1 + Sqr (c)) / (1 + AbsY)) / 2
      else
        b := Ln1Plus (2 * (AbsY / b) / (b / 2 + a)) / 4
    end;
  d := ArcTan2 (c, d) / 2;
  if x < 0 then d := -d;
  if y < 0 then b := -b;
  Complex_ArcTan := Cmplx (d, b)
end;
{$endif}

function Complex_SqRt (z: Complex): Complex;
var a, b, c, ra, ia: Real;
begin
  { SqRt (x + yi) = +/- (SqRt ((a + x) / 2) + i * SqRt ((a - x) / 2))

    where
      a = Abs (x + yi)

    Principal value defined in the Extended Pascal standard: Exp (0.5 * Ln (z)),
    i.e. Sign (Re (SqRt (z)) := 1, Sign (Im (SqRt (z))) := Sign (Im (z)) }
  a := Abs (z);
  if a = 0 then
    Complex_SqRt := 0
  else
    begin
      ra := Abs (Re (z));
      ia := Abs (Im (z));
      b := SqRt ((a + ra) / 2);
      if ia > ra then
        a := SqRt ((a - ra) / 2)
      else
        a := ia / (2 * b);
      if Re (z) < 0 then
        begin
          c := a;
          a := b;
          b := c
        end;
      if Im (z) < 0 then
        Complex_SqRt := Cmplx (b, -a)
      else
        Complex_SqRt := Cmplx (b, a)
    end
end;

function Complex_Ln (z: Complex): Complex;
begin
  Complex_Ln := Cmplx (Ln (Abs (z)), ArcTan2 (Im (z), Re (z)))
end;

function Complex_Exp (z: Complex): Complex;
var ex: Real;
begin
  ex := Exp (Re (z));
  Complex_Exp := Cmplx (ex * Cos (Im (z)), ex * Sin (Im (z)))
end;

function Complex_Sin (z: Complex): Complex;
begin
  Complex_Sin := Cmplx (Sin (Re (z)) * CosH (Im (z)), Cos (Re (z)) * SinH (Im (z)))
end;

function Complex_Cos (z: Complex): Complex;
begin
  Complex_Cos := Cmplx (Cos (Re (z)) * CosH (Im (z)), -Sin (Re (z)) * SinH (Im (z)))
end;

function Complex_Pow (z: Complex; y: Integer) = r: Complex;
var a, b: Real;
begin
  if z = 0 then
    if y > 0 then
      r := 0
    else
      begin
        SetReturnAddress (ReturnAddress (0));
        RuntimeError (703);  { left argument of `pow' is 0 while right argument is <= 0 }
        RestoreReturnAddress
      end
  else
    begin
      if y < 0 then
        begin  { z := 1 / z }
          if Abs (Re (z)) > Abs (Im (z)) then
            begin
              a := Im (z) / Re (z);
              b := Re (z) + Im (z) * a;
              z := Cmplx (1 / b, -a / b)
            end
          else
            begin
              a := Re (z) / Im (z);
              b := Re (z) * a + Im (z);
              z := Cmplx (a / b, -1 / b);
            end;
          y := -y
        end;
      r := 1;
      while y <> 0 do
        begin
          if Odd (y) then r := r * z;
          y := y shr 1;
          if y <> 0 then z := Sqr (z)
        end
    end
end;

function Complex_Power (z: Complex; y: Real): Complex;
begin
  if z = 0 then
    if y > 0 then
      Complex_Power := 0
    else
      begin
        SetReturnAddress (ReturnAddress (0));
        RuntimeError (702);  { left argument of `**' is 0 while right argument is <= 0 }
        RestoreReturnAddress
      end
  else if y = 0 then
    Complex_Power := 1
  else
    Complex_Power := Exp (y * Complex_Ln (z))
end;

end.
