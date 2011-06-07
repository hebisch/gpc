PROGRAM TestBits;
CONST kLastBit = $10000;
TYPE Bits = PACKED ARRAY[ 0..kLastBit] OF BOOLEAN;
VAR
   theBits: Bits;
 theIndex: LONGINT;
BEGIN
 WriteLn ('OK');
 Halt;
 FOR theIndex:= 1 TO kLastBit DO
  theBits[ theIndex]:= TRUE {GPC error, assignment of read-only location}
END.
