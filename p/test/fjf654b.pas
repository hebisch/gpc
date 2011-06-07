program fjf654b;

var
  f: Text;

begin
  Rewrite (f);
  if EOF (f) then WriteLn ('OK') else WriteLn ('failed')
end.
