PROGRAM TestProgram;

USES TestUnit1 in 'rphil1.pas';

VAR
  MyWood: Integer;

BEGIN
  MyWood:= Apples;  { WRONG }
  WriteLn ('failed')
END.
