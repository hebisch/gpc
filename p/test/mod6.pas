program Test(output);

import
  ModT6B in 'mod6test.pas';


begin
  DoTest;  { WRONG }
  j := 6;
  writeln('failed');
end.
