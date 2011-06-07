program fjf813c;

var
  a: Integer = 2;

type
  t = 0 .. a;

begin
  if (Low (t) = 0) and (High (t) = 2) then WriteLn ('OK') else WriteLn ('failed')
end.
