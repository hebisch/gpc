{ Functions to compute MD5 message digest of files or memory blocks,
  according to the definition of MD5 in RFC 1321 from April 1992.

  Copyright (C) 1995, 1996, 2000-2006 Free Software Foundation, Inc.

  Author: Frank Heckenbach <frank@pascal.gnu.de>

  Based on the C code written by Ulrich Drepper
  <drepper@gnu.ai.mit.edu>, 1995 as part of glibc.

  This file is part of GNU Pascal.

  GNU Pascal is free software; you can redistribute it and/or modify
  it under the terms of the GNU Library General Public License as
  published by the Free Software Foundation, version 3.

  GNU Pascal is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; see the file COPYING.LIB. If not,
  write to the Free Software Foundation, Inc., 59 Temple Place -
  Suite 330, Boston, MA 02111-1307, USA. }

{$gnu-pascal,I-}
{$if __GPC_RELEASE__ < 20030303}
{$error This unit requires GPC release 20030303 or newer.}
{$endif}

unit MD5;

interface

uses GPC;

{ Representation of a MD5 value. It is always in little endian byte
  order and therefore portable. }
type
  Card8 = Cardinal attribute (Size = 8);
  TMD5 = array [1 .. 16] of Card8;

const
  MD5StrLength = 2 * High (TMD5);

type
  MD5String = String (MD5StrLength);

{ Computes MD5 message digest for Length bytes in Buffer. }
procedure MD5Buffer (const Buffer; Length: SizeType; var MD5: TMD5);

{ Computes MD5 message digest for the contents of the file f. }
procedure MD5File (var f: File; var MD5: TMD5); attribute (iocritical);

{ Initializes a MD5 value with zeros. }
procedure MD5Clear (var MD5: TMD5);

{ Compares two MD5 values for equality. }
function MD5Compare (const Value1, Value2: TMD5): Boolean;

{ Converts an MD5 value to a string. }
function MD5Str (const MD5: TMD5) = s: MD5String;

{ Converts a string to an MD5 value. Returns True if successful. }
function MD5Val (const s: String; var MD5: TMD5): Boolean;

{ Composes two MD5 values to a single one. }
function MD5Compose (const Value1, Value2: TMD5) = Dest: TMD5;

implementation

type
  Card32 = Cardinal attribute (Size = 32);
  Card64 = Cardinal attribute (Size = 64);
  TABCD = array [0 .. 3] of Card32;

  { Structure to save state of computation between the single steps. }
  TCtx = record
    ABCD: TABCD;
    Total: Card64;
    BufLen: Card32;
    Buffer: array [0 .. 127] of Card8
  end;

{ Initialize structure containing state of computation. (RFC 1321, 3.3: Step 3) }
procedure InitCtx (var Ctx: TCtx);
const InitABCD: TABCD = ($67452301, $efcdab89, $98badcfe, $10325476);
begin
  Ctx.ABCD := InitABCD;
  Ctx.Total := 0;
  Ctx.BufLen := 0
end;

{ Process Length bytes of Buffer, accumulating context into Ctx.
  It is necessary that Length is a multiple of 64! }
procedure ProcessBlock (const Buffer; Length: SizeType; var Ctx: TCtx);
var
  ABCD, Save: TABCD;
  i: Integer;
  WordsTotal: SizeType = Length div SizeOf (Card32);
  WordsDone: SizeType;
  WordBuffer: array [0 .. Max (0, WordsTotal - 1)] of Card32 absolute Buffer;
  CorrectWords: array [0 .. 15] of Card32;
  n: Card32;
begin
  Assert (Length mod 64 = 0);
  { First increment the byte count. RFC 1321 specifies the possible length
    of the file up to 2^64 bits. Here we only compute the number of bytes. }
  Inc (Ctx.Total, Length);
  { Process all bytes in the buffer with 64 bytes in each round of the loop. }
  ABCD := Ctx.ABCD;
  WordsDone := 0;
  while WordsDone < WordsTotal do
    begin
      Save := ABCD;
      i := 0;
      { These are the four functions used in the four steps of the MD5 algorithm
        and defined in the RFC 1321. The first function is a little bit optimized
        (as found in Colin Plumbs public domain implementation). }
      {.$define FF(b, c, d) ((b and c) or (not b and d))}
      {$define FF(b, c, d) (d xor (b and (c xor d)))}
      {$define FG(b, c, d) FF (d, b, c)}
      {$define FH(b, c, d) (b xor c xor d)}
      {$define FI(b, c, d) (c xor (b or not d))}
      {$define RotLeft(w, s) w := (w shl s) or (w shr (32 - s))}  { cyclic rotation }
      { First round: using the given function, the context and a constant
        the next context is computed. Because the algorithms processing
        unit is a 32-bit word and it is determined to work on words in
        little endian byte order we perhaps have to change the byte order
        before the computation. To reduce the work for the next steps
        we store the swapped words in the array CorrectWords. }
      {$ifdef __BYTES_BIG_ENDIAN__}
      {$define Swap(n)
        begin
          n := (n shl 16) or (n shr 16);
          n := ((n and $ff00ff) shl 8) or ((n and $ff00ff00) shr 8)
        end}
      {$elif defined (__BYTES_LITTLE_ENDIAN__)}
      {$define Swap(n)}
      {$else}
      {$error Endianness is not defined!}
      {$endif}
      {$define OP1(a, b, c, d, s, T)
        begin
          n := WordBuffer[WordsDone];
          Inc (WordsDone);
          Swap (n);
          CorrectWords[i] := n;
          Inc (i);
          Inc (a, FF (b, c, d) + n + T);
          RotLeft (a, s);
          Inc (a, b)
        end}
      {$define A ABCD[0]}
      {$define B ABCD[1]}
      {$define C ABCD[2]}
      {$define D ABCD[3]}
      { Before we start, one word to the strange constants. They are defined
        in RFC 1321 as T[i] = Trunc (4294967296 * Abs (Sin (i))), i = 1 .. 64 }
      { Round 1. }
      {$local R-}  { `Inc' is expected to wrap-around }
      OP1 (A, B, C, D,  7, $d76aa478);
      OP1 (D, A, B, C, 12, $e8c7b756);
      OP1 (C, D, A, B, 17, $242070db);
      OP1 (B, C, D, A, 22, $c1bdceee);
      OP1 (A, B, C, D,  7, $f57c0faf);
      OP1 (D, A, B, C, 12, $4787c62a);
      OP1 (C, D, A, B, 17, $a8304613);
      OP1 (B, C, D, A, 22, $fd469501);
      OP1 (A, B, C, D,  7, $698098d8);
      OP1 (D, A, B, C, 12, $8b44f7af);
      OP1 (C, D, A, B, 17, $ffff5bb1);
      OP1 (B, C, D, A, 22, $895cd7be);
      OP1 (A, B, C, D,  7, $6b901122);
      OP1 (D, A, B, C, 12, $fd987193);
      OP1 (C, D, A, B, 17, $a679438e);
      OP1 (B, C, D, A, 22, $49b40821);
      { For the second to fourth round we have the possibly swapped words
        in CorrectWords. Define a new macro to take an additional first
        argument specifying the function to use. }
      {$define OP(f, a, b, c, d, k, s, T)
        begin
          Inc (a, f (b, c, d) + CorrectWords[k] + T);
          RotLeft (a, s);
          Inc (a, b)
        end}
      { Round 2. }
      OP (FG, A, B, C, D,  1,  5, $f61e2562);
      OP (FG, D, A, B, C,  6,  9, $c040b340);
      OP (FG, C, D, A, B, 11, 14, $265e5a51);
      OP (FG, B, C, D, A,  0, 20, $e9b6c7aa);
      OP (FG, A, B, C, D,  5,  5, $d62f105d);
      OP (FG, D, A, B, C, 10,  9, $02441453);
      OP (FG, C, D, A, B, 15, 14, $d8a1e681);
      OP (FG, B, C, D, A,  4, 20, $e7d3fbc8);
      OP (FG, A, B, C, D,  9,  5, $21e1cde6);
      OP (FG, D, A, B, C, 14,  9, $c33707d6);
      OP (FG, C, D, A, B,  3, 14, $f4d50d87);
      OP (FG, B, C, D, A,  8, 20, $455a14ed);
      OP (FG, A, B, C, D, 13,  5, $a9e3e905);
      OP (FG, D, A, B, C,  2,  9, $fcefa3f8);
      OP (FG, C, D, A, B,  7, 14, $676f02d9);
      OP (FG, B, C, D, A, 12, 20, $8d2a4c8a);
      { Round 3. }
      OP (FH, A, B, C, D,  5,  4, $fffa3942);
      OP (FH, D, A, B, C,  8, 11, $8771f681);
      OP (FH, C, D, A, B, 11, 16, $6d9d6122);
      OP (FH, B, C, D, A, 14, 23, $fde5380c);
      OP (FH, A, B, C, D,  1,  4, $a4beea44);
      OP (FH, D, A, B, C,  4, 11, $4bdecfa9);
      OP (FH, C, D, A, B,  7, 16, $f6bb4b60);
      OP (FH, B, C, D, A, 10, 23, $bebfbc70);
      OP (FH, A, B, C, D, 13,  4, $289b7ec6);
      OP (FH, D, A, B, C,  0, 11, $eaa127fa);
      OP (FH, C, D, A, B,  3, 16, $d4ef3085);
      OP (FH, B, C, D, A,  6, 23, $04881d05);
      OP (FH, A, B, C, D,  9,  4, $d9d4d039);
      OP (FH, D, A, B, C, 12, 11, $e6db99e5);
      OP (FH, C, D, A, B, 15, 16, $1fa27cf8);
      OP (FH, B, C, D, A,  2, 23, $c4ac5665);
      { Round 4. }
      OP (FI, A, B, C, D,  0,  6, $f4292244);
      OP (FI, D, A, B, C,  7, 10, $432aff97);
      OP (FI, C, D, A, B, 14, 15, $ab9423a7);
      OP (FI, B, C, D, A,  5, 21, $fc93a039);
      OP (FI, A, B, C, D, 12,  6, $655b59c3);
      OP (FI, D, A, B, C,  3, 10, $8f0ccc92);
      OP (FI, C, D, A, B, 10, 15, $ffeff47d);
      OP (FI, B, C, D, A,  1, 21, $85845dd1);
      OP (FI, A, B, C, D,  8,  6, $6fa87e4f);
      OP (FI, D, A, B, C, 15, 10, $fe2ce6e0);
      OP (FI, C, D, A, B,  6, 15, $a3014314);
      OP (FI, B, C, D, A, 13, 21, $4e0811a1);
      OP (FI, A, B, C, D,  4,  6, $f7537e82);
      OP (FI, D, A, B, C, 11, 10, $bd3af235);
      OP (FI, C, D, A, B,  2, 15, $2ad7d2bb);
      OP (FI, B, C, D, A,  9, 21, $eb86d391);
      { Add the starting values of the context. }
      for i := 0 to 3 do
        Inc (ABCD[i], Save[i])
      {$endlocal}
      {$undef FF}
      {$undef FG}
      {$undef FH}
      {$undef FI}
      {$undef RotLeft}
      {$undef Swap}
      {$undef OP1}
      {$undef A}
      {$undef B}
      {$undef C}
      {$undef D}
      {$undef OP}
    end;
  Ctx.ABCD := ABCD
end;

{ Starting with the result of former calls to this function (or
  InitCtx) update the context for the next Length bytes in Buffer.
  It is not required that Length is a multiple of 64. }
procedure ProcessBytes (const aBuffer; Length: SizeType; var Ctx: TCtx);
var
  BytesDone, Block, LeftOver: SizeType;
  ByteBuffer: array [0 .. Max (0, Length - 1)] of Card8 absolute aBuffer;
begin
  BytesDone := 0;
  { When we already have some bits in our internal buffer concatenate both inputs first. }
  with Ctx do
    if BufLen <> 0 then
      begin
        LeftOver := BufLen;
        BytesDone := Min (128 - LeftOver, Length);
        Move (ByteBuffer, Buffer[LeftOver], BytesDone);
        Inc (BufLen, BytesDone);
        if BufLen > 64 then
          begin
            Block := BufLen div 64 * 64;
            ProcessBlock (Buffer, Block, Ctx);
            BufLen := BufLen mod 64;
            Move (Buffer[Block], Buffer, BufLen)  { source and destination cannot overlap }
          end;
        Dec (Length, BytesDone)
      end;
  { Process available complete blocks. }
  if Length > 64 then
    begin
      Block := Length div 64 * 64;
      ProcessBlock (ByteBuffer[BytesDone], Block, Ctx);
      Inc (BytesDone, Block);
      Dec (Length, Block)
    end;
  { Move remaining bytes into internal buffer. }
  if Length > 0 then
    begin
      Move (ByteBuffer[BytesDone], Ctx.Buffer, Length);
      Ctx.BufLen := Length
    end
end;

{ Process the remaining bytes in the buffer and put result from Ctx into MD5. }
procedure FinishCtx (var Ctx: TCtx; var MD5: TMD5);
var i, j, Pad: Integer;
begin
  with Ctx do
    begin
      Pad := 56 - BufLen;
      if Pad <= 0 then Inc (Pad, 64);
      if Pad > 0 then
        begin
          Buffer[BufLen] := $80;
          FillChar (Buffer[BufLen + 1], Pad - 1, 0)
        end;
      Inc (Total, BufLen);
      { Put the 64-bit total length in *bits* at the end of the buffer. }
      for j := 0 to 7 do
        Buffer[BufLen + Pad + j] := ((Total * BitSizeOf (Card8)) shr (8 * j)) and $ff;
      ProcessBlock (Buffer, BufLen + Pad + 8, Ctx);
      for i := 0 to 3 do
        for j := 0 to 3 do
          MD5[4 * i + j + 1] := (Ctx.ABCD[i] shr (8 * j)) and $ff
    end
end;

procedure MD5Buffer (const Buffer; Length: SizeType; var MD5: TMD5);
var Ctx: TCtx;
begin
  InitCtx (Ctx);
  ProcessBytes (Buffer, Length, Ctx);
  FinishCtx (Ctx, MD5)
end;

procedure MD5File (var f: File; var MD5: TMD5);
var
  Ctx: TCtx;
  Buffer: array [1 .. 4096] of Card8;
  BytesRead: SizeType;
begin
  InitCtx (Ctx);
  Reset (f, 1);
  repeat
    BlockRead (f, Buffer, SizeOf (Buffer), BytesRead);
    if InOutRes <> 0 then Exit;
    ProcessBytes (Buffer, BytesRead, Ctx)
  until EOF (f);
  FinishCtx (Ctx, MD5)
end;

procedure MD5Clear (var MD5: TMD5);
var i: Integer;
begin
  for i := Low (MD5) to High (MD5) do MD5[i] := 0
end;

function MD5Compare (const Value1, Value2: TMD5): Boolean;
var i: Integer;
begin
  MD5Compare := False;
  for i := Low (Value1) to High (Value1) do
    if Value1[i] <> Value2[i] then Exit;
  MD5Compare := True
end;

function MD5Str (const MD5: TMD5) = s: MD5String;
var i: Integer;
begin
  s := '';
  for i := Low (MD5) to High (MD5) do
    s := s + NumericBaseDigits[MD5[i] div $10] + NumericBaseDigits[MD5[i] mod $10]
end;

function MD5Val (const s: String; var MD5: TMD5): Boolean;
var i, d1, d2: Integer;

  function Char2Digit (ch: Char): Integer;
  begin
    case ch of
      '0' .. '9': Char2Digit := Ord (ch) - Ord ('0');
      'A' .. 'Z': Char2Digit := Ord (ch) - Ord ('A') + $a;
      'a' .. 'z': Char2Digit := Ord (ch) - Ord ('a') + $a;
      else        Char2Digit := -1
    end
  end;

begin
  MD5Val := False;
  if Length (s) <> 2 * (High (MD5) - Low (MD5) + 1) then Exit;
  for i := Low (MD5) to High (MD5) do
    begin
      d1 := Char2Digit (s[2 * (i - Low (MD5)) + 1]);
      d2 := Char2Digit (s[2 * (i - Low (MD5)) + 2]);
      if (d1 < 0) or (d1 >= $10) or (d2 < 0) or (d2 >= $10) then Exit;
      MD5[i] := $10 * d1 + d2
    end;
  MD5Val := True
end;

function MD5Compose (const Value1, Value2: TMD5) = Dest: TMD5;
var Buffer: array [1 .. 2] of TMD5;
begin
  Buffer[1] := Value1;
  Buffer[2] := Value2;
  MD5Buffer (Buffer, SizeOf (Buffer), Dest)
end;

end.
