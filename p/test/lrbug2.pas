Program LRBug2;

Var
  A : LongReal;
  I : Byte;
  Dummy : Text;

Begin
  Rewrite (Dummy);
  A := 3.3621031431120935120e-4932; {biggest subnormal number}
  For I := 0 To 64 Do
    Begin
      WriteLn(Dummy, A);
      A := A/2;
    End;
  WriteLn('OK')
End.
