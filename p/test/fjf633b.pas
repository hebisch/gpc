program fjf633b;

uses fjf633u;

var
  vfoo: foo = c;
  vqux: qux;

begin
  {$local R-} vqux := vfoo; {$endlocal}
  if vfoo = vqux then WriteLn ('OK') else WriteLn ('failed')
end.
