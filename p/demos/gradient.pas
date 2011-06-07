{ GPC demo program to generate GPC's color gradient as a PPM file.
  The gradient is used as the background of the WWW pages, converted
  to PNG using `pnmtopng'. The program is not much more complicated
  than `Hello, world', thanks to the simplicity of the PNM format.

  Copyright (C) 2002-2006 Free Software Foundation, Inc.

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

program Gradient;

var
  Row, Col, n: Integer;

begin
  WriteLn ('P3');
  WriteLn ('16 1601 255');
  for Row := 0 to 1600 do
    begin
      n := Abs (Row div 16 - 50);
      for Col := 1 to 16 do
        Write (255, ' ', 155 + 4 * Min (n, 25), ' ', 55 + 4 * n, '  ');
      WriteLn
    end
end.
