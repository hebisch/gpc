{ GPC demo program for the endianness conversion routines.

  Copyright (C) 2000-2006 Free Software Foundation, Inc.

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

program EndianDemo;

uses GPC;

{ To get reproducible data sizes in the file }
type
  {$ifdef __GPC__}
  Int16 = Integer attribute (Size = 16);
  Int32 = Integer attribute (Size = 32);
  {$else}
  Int16 = Integer;
  Int32 = LongInt;
  {$endif}

var
  a, b, k, l: array [1 .. 10] of Int16;
  c, d, m, n: array [1 .. 10] of Int32;
  s, t, u, v: String [20];
  i: Int32;
  BytesRead: Integer;
  f: file;
  Buf: array [1 .. $1000] of Byte;

begin
  { Initialize the variables }
  s := 'foo';
  t := 'bar';
  u := '';
  v := '';
  for i := 1 to 10 do
    begin
      a[i] := 100 * i;
      b[i] := 0;
      c[i] := 10000 * i;
      d[i] := 0;
      k[i] := 42 * i;
      l[i] := 0;
      m[i] := $f00 * i;
      n[i] := 0
    end;

  { Create a file }
  Assign (f, 'tmpfile.dat');
  Rewrite (f, 1);
  { Write the first part of an array to the file in little endian format ... }
  BlockWriteLittleEndian (f, a, SizeOf (a[1]), 5);
  { ... and the rest in big endian format (probably quite pointless, but
    this is just a demo ;-) }
  BlockWriteBigEndian (f, a[6], SizeOf (a[1]), 5);
  { Again for an Int32 array }
  BlockWriteLittleEndian (f, c, SizeOf (c[1]), 5);
  BlockWriteBigEndian (f, c[6], SizeOf (c[1]), 5);
  { Now write a string in little endian format ... }
  WriteStringLittleEndian (f, s);
  { ... and another one in big endian format }
  WriteStringBigEndian (f, t);

  { Just a check (see below) }
  if (k[10] <> 420) or (m[10] <> $9600) then
    begin
      WriteLn (StdErr, 'internal error in variable initializtion');
      Halt (1)
    end;

  { Convert k and m in place, then write them to the file }
  ConvertToLittleEndian (k, SizeOf (k[1]), 10);
  ConvertToBigEndian (m, SizeOf (m[1]), 10);
  BlockWrite (f, k, SizeOf (k));
  BlockWrite (f, m, SizeOf (m));

  { Now, depending on the system's endianness, either k or m is in
    the wrong format and contains the wrong value for the system. }
  if (k[10] = 420) and (m[10] = $9600) then
    begin
      WriteLn (StdErr, 'internal error: endianness conversion not correct');
      Halt (1)
    end;

  { Read back the values in their respective endianness }
  Reset (f, 1);
  BlockReadLittleEndian (f, b, SizeOf (b[1]), 5);
  BlockReadBigEndian (f, b[6], SizeOf (b[1]), 5);
  BlockReadLittleEndian (f, d, SizeOf (d[1]), 5);
  BlockReadBigEndian (f, d[6], SizeOf (d[1]), 5);
  ReadStringLittleEndian (f, u);
  ReadStringBigEndian (f, v);
  BlockRead (f, l, SizeOf (l));
  BlockRead (f, n, SizeOf (n));
  ConvertFromLittleEndian (l, SizeOf (l[1]), 10);
  ConvertFromBigEndian (n, SizeOf (n[1]), 10);

  { Output the values read }
  WriteLn ('Values read:');
  for i := 1 to 10 do Write (b[i], ', ');
  WriteLn;
  for i := 1 to 10 do Write (d[i], ', ');
  WriteLn;
  WriteLn (u);
  WriteLn (v);
  for i := 1 to 10 do Write (l[i], ', ');
  WriteLn;
  for i := 1 to 10 do Write (n[i], ', ');
  WriteLn;
  WriteLn;

  { Dump the bytes of the file }
  Reset (f, 1);
  BlockRead (f, Buf, SizeOf (Buf), BytesRead);
  CloseFile (f);
  WriteLn ('Binary file dump:');
  for i := 1 to BytesRead do
    begin
      Write (Buf[i], ', ');
      if i mod 16 = 0 then WriteLn
    end;
  WriteLn
end.
