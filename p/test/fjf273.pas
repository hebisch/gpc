program fjf273;

uses fjf273u;

var
  bar : string (10); attribute (name = 'bar');

begin
  bar := 'OK';
  if bar = 'OK' then writeln (bar) else writeln ('failed')
end.
