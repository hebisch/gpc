program fjf633c;

uses fjf633v;

type
  bar = b .. h;
  baz = c .. f;
  qux = d .. e;

var
  vfoo: foo = c;
  vqux: qux;

begin
  {$local R-} vqux := vfoo; {$endlocal}
  if vfoo = vqux then WriteLn ('OK') else WriteLn ('failed')
end.
