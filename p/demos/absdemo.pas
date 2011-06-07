{ GPC demo program for the portable use of `absolute' declarations
  and how to take care of type sizes and endianness in portable
  programs.

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

program AbsoluteDemo;

{ This is an actual example taken from GPC's CRT unit. Under normal
  circumstances, tricks like the following are *not* necessary.
  They're only meant for special situations that can't be solved
  otherwise.

  The situation here is the following: The writers of BP's CRT unit
  had the "brilliant" idea to stuff two values into one variable
  (the minimum x and y coordinates of the current window into
  WindMin and similarly the maximum coordinates into WindMax). The x
  coordinates reside in the lower 8 bits, and the y coordinates in
  the higher 8 bits of the `Word' variables which are 16 bit in BP.
  (They apparently thought this was necessary for their assembler
  code to be more efficient which is actually not true, but that's
  another story ...)

  Their recommended way to access the coordinates is to use bit
  manipulation like `shl', `shr', `and' and `or' (or, mostly
  equivalently, `*', `div' and `mod' by powers of 2). But, of
  course, that's not very comfortable for a language like Pascal.

  So we want to make the access easier by using fields of a record,
  without losing compatibility to the thoughtless BP interface.

  The way to do it is an `absolute' declaration to create record
  aliases for the `Word' variables. `absolute' declarations are
  supported by the GNU Pascal compiler, so far so good. However, in
  order to remain portable, there are two things to take care of:
  type sizes and endianness.

  Type sizes: as always when programming portably, one must not
  assume anything about type sizes except when explicitly requested.
  In particular, we must not assume that a `Word' is 16 bits (and in
  fact, it's usually bigger in GPC). Therefore, there might be
  unused bits in the `Word' variables which we cover with (dummy)
  `Fill' fields in the records. For the (interesting) `x' and `y'
  fields, we want exactly 8 bits, so we use
  `Cardinal attribute (Size = 8)' (and not `Byte', which is usually
  8 bits, but not guaranteed to be). To compute the size of the
  `Fill' field in bits, we can then simply subtract 16 (the size of
  the `x' and `y' fields) from the size of `Word' in bits which the
  `BitSizeOf' function tells us. But because we're really paranoid
  ;-), we add a (compile time) check to ensure that the size of our
  record is really the same as that of the `Word' variables. Compile
  time assertions are not directly supported by the compiler, but
  can be emulated with a little trick, see below.

  Endianness: on a little-endian system (e.g. IA32, Alpha), the
  lower valued parts of an integer variable come first in memory,
  but on a big-endian system (e.g. m68k, Sparc), the higher valued
  parts come first. We must take this into account in the order of
  the fields in our record. GPC gives us the define
  `__BYTES_LITTLE_ENDIAN__' or `__BYTES_BIG_ENDIAN__' in order to
  distinguish little- and big-endian systems.

  And last, but not least, of course, we must not forget to use a
  `packed' record, so the fields are really packed end to end. }

{ First of all, these are the `Word' variables we want to alias. }
var
  WindMin: Word;
  WindMax: Word;

{ Now our record type, taking into account type sizes and endianness. }
type
  TWindowXYInternalCard8 = Cardinal attribute (Size = 8);
  TWindowXYInternalFill = Integer attribute (Size = BitSizeOf (Word) - 16);
  TWindowXY = packed record
    {$ifdef __BYTES_BIG_ENDIAN__}
    Fill: TWindowXYInternalFill;
    y, x: TWindowXYInternalCard8
    {$elif defined (__BYTES_LITTLE_ENDIAN__)}
    x, y: TWindowXYInternalCard8;
    Fill: TWindowXYInternalFill
    {$else}
    {$error Endianness is not defined!}
    {$endif}
  end;

{ Make sure TWindowXY really has the same size as WindMin and
  WindMax. The value of the constant will always be True, and is of
  no further interest. }
const
  AssertTWindowXYSize = CompilerAssert ((SizeOf (TWindowXY) = SizeOf (WindMin)) and
                                        (SizeOf (TWindowXY) = SizeOf (WindMax)));

{ And now the aliased record variables via `absolute' declarations. }
var
  WindowMin: TWindowXY absolute WindMin;
  WindowMax: TWindowXY absolute WindMax;

begin
  WriteLn ('Setting the minimum coordinates (2, 4) the "dirty" way.');
  WindMin := 2 + $100 * 4;
  WriteLn ('Reading them back the easy way: (', WindowMin.x, ', ', WindowMin.y, ').');
  WriteLn;
  WriteLn ('And vice versa ...');
  WriteLn ('Setting the maximum coordinates to (42, 24) the easy way.');
  WindowMax.x := 42;
  WindowMax.y := 24;
  WriteLn ('Reading them back the "dirty" way: (', WindMax mod $100, ', ', WindMax div $100, ').')
end.
