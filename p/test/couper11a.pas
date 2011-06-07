{ `Set Of Integer' doesn't work currently. It's not clear whether the
  range should be chosen so that it contains 1 (but that's no general
  solution), or cause a compile-time error as it does now. In the former
  case, remove the `WRONG'. Anyway, GPC shouldn't crash itself. }

Program SetBug2;

Procedure Try;
  Var
    X : Integer = 1;
    OneSet : Set Of Integer = [1];  { WRONG }
  Begin
    If X In OneSet Then WriteLn ('(OK)')
  End;

Begin
  Try
End.
