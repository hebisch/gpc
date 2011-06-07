program fjf152;
type a(b:integer)=integer;
var d:^a;
begin
  New(d,42);
  if d^.b=42 then writeln('OK') else writeln('Failed')
end.
