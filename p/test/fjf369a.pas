program fjf369a;

type
  a = restricted void; p = ^a;

var
  u, v : p;

procedure foo (x : p);
begin
  if x = u then writeln ('OK') else writeln ('failed')
end;

begin
  u := v;
  foo (v)
end.
