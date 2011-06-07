{ Type casts from integer to real not allowed anymore.
  Replaced by `ToReal' function. -- Frank, 20030317 }

program Couper1;

Const
  XValueMax = 125;
Type
  T_XValue = Packed 0..XValueMax;
Var
  X : T_XValue;
  I : Integer;
  OK : Boolean = True;

procedure Error (n : Integer);
Begin
  WriteLn ('error #', n, ', I = ', I);
  OK := False
End;

function ToReal (n : Integer) : Real;
Begin
  ToReal := n
End;

Begin
  for I := 0 to XValueMax do
    Begin
      X := I;
      if (X <> I) then Error (1);
      if (X > 63) <> (I > 63) then Error (2);
      if (X < 63) <> (I < 63) then Error (3);
      if (X = 63) <> (I = 63) then Error (4);
      if (X <> 63) <> (I <> 63) then Error (5);
      if (X <= 63) <> (I <= 63) then Error (6);
      if (X >= 63) <> (I >= 63) then Error (7);
      if (ToReal (X) > 63) <> (ToReal (I) > 63) then Error (8);
      if (ToReal (X) < 63) <> (ToReal (I) < 63) then Error (9);
      if (ToReal (X) = 63) <> (ToReal (I) = 63) then Error (10);
      if (ToReal (X) <> 63) <> (ToReal (I) <> 63) then Error (11);
      if (ToReal (X) <= 63) <> (ToReal (I) <= 63) then Error (12);
      if (ToReal (X) >= 63) <> (ToReal (I) >= 63) then Error (13);
      if (X > ToReal (63)) <> (I > ToReal (63)) then Error (14);
      if (X < ToReal (63)) <> (I < ToReal (63)) then Error (15);
      if (X = ToReal (63)) <> (I = ToReal (63)) then Error (16);
      if (X <> ToReal (63)) <> (I <> ToReal (63)) then Error (17);
      if (X <= ToReal (63)) <> (I <= ToReal (63)) then Error (18);
      if (X >= ToReal (63)) <> (I >= ToReal (63)) then Error (19);
      if (Integer (X) > 63) <> (I > 63) then Error (20);
      if (Integer (X) > 63) <> (Integer (I) > 63) then Error (21);
      if (X > Integer (63)) <> (I > 63) then Error (22);
      if (X > Integer (63)) <> (I > Integer (63)) then Error (23);
    End;
  if OK then WriteLn ('OK')
End.
