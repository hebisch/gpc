program fjf315b;

type
  foo (bar : integer) = array [1 .. bar] of integer;

procedure p (const baz : foo);
begin
  if @baz = nil then writeln ('OK') else writeln ('failed')
end;

begin
  p (null)
end.
