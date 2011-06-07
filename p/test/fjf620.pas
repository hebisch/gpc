program fjf620;

type
  t (f: Integer) = array [1 .. f] of Integer;
  u (d, e: Integer) = array [1 .. e] of t (d);

var
  v: u (10, 10);

begin
  v[7][3] := 42;
  if v[7,3] = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
