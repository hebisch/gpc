{ Routines to handle endianness

  Copyright (C) 1998-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

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

unit Endian; attribute (name = '_p__rts_Endian');

interface

uses Error;

{ Boolean constants about endianness and alignment }

const
  BitsBigEndian  = {$ifdef __BITS_LITTLE_ENDIAN__}
                   False
                   {$elif defined (__BITS_BIG_ENDIAN__)}
                   True
                   {$else}
                   {$error Bit endianness is not defined!}
                   {$endif};

  BytesBigEndian = {$ifdef __BYTES_LITTLE_ENDIAN__}
                   False
                   {$elif defined (__BYTES_BIG_ENDIAN__)}
                   True
                   {$else}
                   {$error Byte endianness is not defined!}
                   {$endif};

  WordsBigEndian = {$ifdef __WORDS_LITTLE_ENDIAN__}
                   False
                   {$elif defined (__WORDS_BIG_ENDIAN__)}
                   True
                   {$else}
                   {$error Word endianness is not defined!}
                   {$endif};

  NeedAlignment  = {$ifdef __NEED_ALIGNMENT__}
                   True
                   {$elif defined (__NEED_NO_ALIGNMENT__)}
                   False
                   {$else}
                   {$error Alignment is not defined!}
                   {$endif};

{ Convert single variables from or to little or big endian format.
  This only works for a single variable or a plain array of a simple
  type. For more complicated structures, this has to be done for
  each component separately! Currently, ConvertFromFooEndian and
  ConvertToFooEndian are the same, but this might not be the case on
  middle-endian machines. Therefore, we provide different names. }
procedure ReverseBytes            (var Buf; ElementSize, Count: SizeType); attribute (name = '_p_ReverseBytes');
procedure ConvertFromLittleEndian (var Buf; ElementSize, Count: SizeType); attribute (name = '_p_ConvertLittleEndian');
procedure ConvertFromBigEndian    (var Buf; ElementSize, Count: SizeType); attribute (name = '_p_ConvertBigEndian');
procedure ConvertToLittleEndian   (var Buf; ElementSize, Count: SizeType); external name '_p_ConvertLittleEndian';
procedure ConvertToBigEndian      (var Buf; ElementSize, Count: SizeType); external name '_p_ConvertBigEndian';

{ Read a block from a file and convert it from little or
  big endian format. This only works for a single variable or a
  plain array of a simple type, note the comment for
  `ConvertFromLittleEndian' and `ConvertFromBigEndian'. }
procedure BlockReadLittleEndian   (var aFile: File; var   Buf; ElementSize, Count: SizeType); attribute (iocritical, name = '_p_BlockRead_LittleEndian');
procedure BlockReadBigEndian      (var aFile: File; var   Buf; ElementSize, Count: SizeType); attribute (iocritical, name = '_p_BlockRead_BigEndian');

{ Write a block variable to a file and convert it to little or big
  endian format before. This only works for a single variable or a
  plain array of a simple type. Apart from this, note the comment
  for `ConvertToLittleEndian' and `ConvertToBigEndian'. }
procedure BlockWriteLittleEndian  (var aFile: File; const Buf; ElementSize, Count: SizeType); attribute (iocritical, name = '_p_BlockWrite_LittleEndian');
procedure BlockWriteBigEndian     (var aFile: File; const Buf; ElementSize, Count: SizeType); attribute (iocritical, name = '_p_BlockWrite_BigEndian');

{ Read and write strings from/to binary files, where the length is
  stored in the given endianness and with a fixed size (64 bits),
  and therefore is independent of the system. }
procedure ReadStringLittleEndian  (var f: File; var s: String);   attribute (iocritical, name = '_p_ReadStringLittleEndian');
procedure ReadStringBigEndian     (var f: File; var s: String);   attribute (iocritical, name = '_p_ReadStringBigEndian');
procedure WriteStringLittleEndian (var f: File; const s: String); attribute (iocritical, name = '_p_WriteStringLittleEndian');
procedure WriteStringBigEndian    (var f: File; const s: String); attribute (iocritical, name = '_p_WriteStringBigEndian');

implementation

procedure ReverseBytes (var Buf; ElementSize, Count: SizeType);
var
  i, j, o1, o2: SizeType;
  b: Byte;
  ByteBuf: array [1 .. ElementSize * Count] of Byte absolute Buf;
begin
  for i := 0 to Count - 1 do
    for j := 1 to ElementSize div 2 do
      begin
        o1 := i * ElementSize + j;
        o2 := i * ElementSize + ElementSize + 1 - j;
        b := ByteBuf[o1];
        ByteBuf[o1] := ByteBuf[o2];
        ByteBuf[o2] := b
      end
end;

procedure ConvertFromLittleEndian (var Buf; ElementSize, Count: SizeType);
begin
  if BytesBigEndian then ReverseBytes (Buf, ElementSize, Count)
end;

procedure ConvertFromBigEndian (var Buf; ElementSize, Count: SizeType);
begin
  if not BytesBigEndian then ReverseBytes (Buf, ElementSize, Count)
end;

procedure BlockReadLittleEndian (var aFile: File; var Buf; ElementSize, Count: SizeType);
begin
  BlockRead (aFile, Buf, ElementSize * Count);
  if BytesBigEndian and (InOutRes = 0) then
    ConvertFromLittleEndian (Buf, ElementSize, Count)
end;

procedure BlockReadBigEndian (var aFile: File; var Buf; ElementSize, Count: SizeType);
begin
  BlockRead (aFile, Buf, ElementSize * Count);
  if not BytesBigEndian and (InOutRes = 0) then
    ConvertFromBigEndian (Buf, ElementSize, Count)
end;

procedure BlockWriteLittleEndian (var aFile: File; const Buf; ElementSize, Count: SizeType);
var TempBuf: array [1 .. ElementSize * Count] of Byte;
begin
  Move (Buf, TempBuf, ElementSize * Count);
  if BytesBigEndian then ConvertToLittleEndian (TempBuf, ElementSize, Count);
  BlockWrite (aFile, TempBuf, ElementSize * Count)
end;

procedure BlockWriteBigEndian (var aFile: File; const Buf; ElementSize, Count: SizeType);
var TempBuf: array [1 .. ElementSize * Count] of Byte;
begin
  Move (Buf, TempBuf, ElementSize * Count);
  if not BytesBigEndian then ConvertToBigEndian (TempBuf, ElementSize, Count);
  BlockWrite (aFile, TempBuf, ElementSize * Count)
end;

type
  StringLengthType = Cardinal attribute (Size = 64);

procedure ReadStringLittleEndian (var f: File; var s: String);
var StringLength: StringLengthType;
begin
  BlockRead (f, StringLength, SizeOf (StringLength));
  if InOutRes = 0 then
    begin
      if BytesBigEndian then ConvertFromLittleEndian (StringLength, SizeOf (StringLength), 1);
      SetLength (s, StringLength);
      if StringLength > 0 then BlockRead (f, s[1], StringLength)
    end
end;

procedure ReadStringBigEndian (var f: File; var s: String);
var StringLength: StringLengthType;
begin
  BlockRead (f, StringLength, SizeOf (StringLength));
  if InOutRes = 0 then
    begin
      if not BytesBigEndian then ConvertFromBigEndian (StringLength, SizeOf (StringLength), 1);
      SetLength (s, StringLength);
      if StringLength > 0 then BlockRead (f, s[1], StringLength)
    end
end;

procedure WriteStringLittleEndian (var f: File; const s: String);
var StringLength: StringLengthType;
begin
  StringLength := Length (s);
  if BytesBigEndian then ConvertToLittleEndian (StringLength, SizeOf (StringLength), 1);
  BlockWrite (f, StringLength, SizeOf (StringLength));
  if s <> '' then BlockWrite (f, s[1], Length (s))
end;

procedure WriteStringBigEndian (var f: File; const s: String);
var StringLength: StringLengthType;
begin
  StringLength := Length (s);
  if not BytesBigEndian then ConvertToBigEndian (StringLength, SizeOf (StringLength), 1);
  BlockWrite (f, StringLength, SizeOf (StringLength));
  if s <> '' then BlockWrite (f, s[1], Length (s))
end;

type
  Card8 = Cardinal attribute (Size = 8);
  Card16 = Cardinal attribute (Size = 16);

to begin do
  begin
    {$pack-struct}
    var a: array [1 .. 2] of Card8 = ($12, $34);
    if Card16 (a) <> {$ifdef __BYTES_LITTLE_ENDIAN__} $3412 {$else} $1234 {$endif} then
      InternalError (902)  { endianness incorrectly defined }
  end;

end.
