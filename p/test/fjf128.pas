program fjf128;
type string42=string(42);
var a:^string42;
begin
  new(a);
  if a^.capacity=42 then writeln('OK') else writeln('Failed ',a^.capacity)
end.
