unit chief43u;

interface

type
tfooType = Array [0..15] of Char;
pfooType = ^tfooType;

Var
pfoo : pfooType;

implementation

Var
i : Byte;

Initialization
  New (pfoo);
  for i := 0 to 15 do pfoo^ [i] := Chr (i+65);
Finalization
  Dispose (pfoo);
  pfoo := Nil;
  WriteLn ('K')
End.
