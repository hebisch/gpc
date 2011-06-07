PROGRAM TestProgram;

USES TestUnit1 in 'rphil1.pas';

VAR
  MyWood: Wood;

BEGIN
  MyWood:= Chr (1);  { WRONG }
  WriteLn ('failed')
END.
