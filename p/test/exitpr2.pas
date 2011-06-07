Unit ExitPr2;

Interface

Var
  ExitProc: Pointer value Nil;

Implementation

Type
  ProcPtr = ^Procedure;

to end do
  while ExitProc <> Nil do
    ProcPtr ( ExitProc )^;

end.
