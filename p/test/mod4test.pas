module ModT4 interface;

export
  ModT4 = (i, DoTest);

var
  i: integer;


procedure DoTest;


end.


module ModT4 implementation;

import
  StandardOutput;


procedure DoTest;
begin
  i := -9;
end;


to end do
  writeln('OK');


end.
