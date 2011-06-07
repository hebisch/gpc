PROGRAM TestProgram;

USES TestUnit1 in 'rphil1.pas';

VAR
  MyWood: Wood;

BEGIN
  MyWood:= 2;  { WRONG }
  WriteLn ('failed')
END.
