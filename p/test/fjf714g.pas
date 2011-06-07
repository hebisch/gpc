{ FLAG --borland-pascal }

program fjf714g (Output);

var
  x: Real;

begin
  Dec (x, 2.5);  { WRONG }
  WriteLn ('failed')
end.
