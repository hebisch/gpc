program David2;

uses David2u;

var
  List: ARRAY [1 .. 3] of DOUBLE = (4, 5, 6);

BEGIN
  Test_proc (List);
  WriteLn ('OK')
END.
