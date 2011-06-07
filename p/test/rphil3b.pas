PROGRAM TestProgram;

USES TestUnit1 in 'rphil1.pas';

VAR
  MyWood: Wood;

BEGIN
  CheckFruit (Oranges);  { WRONG }
  WriteLn ('failed')
END.
