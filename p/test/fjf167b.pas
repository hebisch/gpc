program fjf167b;
var x:cardinal=$12345678;
begin
  if x div $100000000 = 0 then writeln('OK') else writeln('Failed')
end.
