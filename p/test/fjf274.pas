program fjf274;

var bar : integer;

procedure foo (const baz : Void);
begin
  if @bar = @baz then writeln ('OK') else writeln ('Failed')
end;

begin
  foo (bar)
end.
