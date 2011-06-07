program fjf1013e;

var
  i: Integer = 42;
  a: array [1 .. i] of Integer;

begin
  Inc (i);
  if High (a) = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
