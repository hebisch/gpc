PROGRAM TestProgram;

USES TestUnit1 in 'rphil1.pas';

VAR
  MyWood: Wood;

BEGIN
  MyWood:= False;  { WRONG }
  WriteLn ('failed')
END.
