program fjf179;
var
  a:real;
  b:integer=$40000000;
begin
  a:=b/$100000000;
  if a=0.25 then writeln('OK') else writeln('False: ',a:0:10)
end.
