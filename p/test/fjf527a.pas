program fjf527a;

const
  a: array [1 .. 2] of Integer = (1, 2);

begin
  if a[1] < a[2] then WriteLn ('OK') else WriteLn ('failed')
end.
