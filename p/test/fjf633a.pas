program fjf633a;

type
  foo = (a, b, c, d, e, f, g, h, i);
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
