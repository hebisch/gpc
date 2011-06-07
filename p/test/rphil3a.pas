PROGRAM TestProgram;

USES TestUnit1 in 'rphil1.pas';

VAR
  MyWood: Wood;

BEGIN
  MyWood:= Apples;  { WRONG }
  WriteLn ('failed')
END.
