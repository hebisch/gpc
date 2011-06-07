program fjf261;

procedure p (var x);
begin
  ptrint (x) := 42
end;

var
  v : procedure;
  i : ptrint absolute v;

begin
  i := 0;
  p (v);
  if i = 42 then writeln ('OK') else writeln ('Failed')
end.
