{ GPC demo program. ASCII image of the Mandelbrot set using the
  Extended Pascal Complex type.

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

program MandelbrotDemo;

const
  x0 = - 2.1;
  x1 =   2.1;
  y0 = - 2.1;
  y1 =   2.1;

  xSize = 79;
  ySize = 23;

  MaxIter = 16;

  Chars: array [0 .. MaxIter] of Char = ' ._+/!":*$()%\=-#';

var
  x, y, i: Integer;
  z, t: Complex;

begin
  WriteLn ('The Mandelbrot set:');
  for y := 0 to ySize - 1 do
    begin
      for x := 0 to xSize - 1 do
        begin
          z := Cmplx (x0 + x / (xSize - 1) * (x1 - x0),
                      y0 + y / (ySize - 1) * (y1 - y0));
          t := z;
          i := 0;
          while (i < MaxIter) and (Abs (t) < 2) do
            begin
              t := Sqr (t) + z;
              Inc (i)
            end;
          Write (Chars[i])
        end;
      WriteLn
    end
end.
