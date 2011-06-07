program fjf258d;

type
  p = procedure;

procedure foo (a : p);
begin
  if @a = nil then writeln ('OK') else writeln ('failed')
end;

begin
  foo (nil)
end.
