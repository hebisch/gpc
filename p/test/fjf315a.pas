program fjf315a;

type
  foo (bar : integer) = array [1 .. bar] of integer;

procedure p (const baz : foo);
begin
  if @baz = nil then writeln ('OK') else writeln ('failed')
end;

var
  qux : ^foo = nil;

begin
  p (qux^)
end.
