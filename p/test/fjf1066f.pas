program fjf1066g;

import fjf1066p;

operator Only (a, b: Integer) c: Integer;
begin
  c := a + 2 * b
end;

begin
  if 2 Only 5 = 12 then WriteLn ('OK') else WriteLn ('failed')
end.
