program fjf924;

var
  f: file of Integer;

begin
  Rewrite (f);
  Write (f, 99);
  Reset (f);
  if f^div 16 = 6 then WriteLn ('OK') else WriteLn ('failed')
end.
