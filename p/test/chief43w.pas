unit chief43w;

interface

type
tfooType = Array [0..15] of Char;
pfooType = ^tfooType;

Var
pfoo : pFooType;

implementation

Var
i : Byte;

Initialization
  New (pfoo);
  for i := 0 to 15 do pfoo^ [i] := Chr (i+65);
End;  { This line is illegal }

Finalization
  Dispose (pfoo);
  pfoo := Nil;
End;  { This line is illegal }

Begin  { This line is illegal }
End.
