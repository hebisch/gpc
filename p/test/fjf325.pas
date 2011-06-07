program fjf325;

var
  a : cardinal = 2;
  b : integer = 1;
  c : longint;

begin
  c := b - a;
  if c = - 1 then writeln ('OK') else writeln ('failed')
end.
