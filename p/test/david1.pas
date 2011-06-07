program David1;

import David1m;

var
  List: ARRAY [1 .. 3] of DOUBLE = (4, 5, 6);

BEGIN
  Test_proc (List);
  WriteLn ('OK')
END.
