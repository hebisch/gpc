program fjf306;

var
  s : string (10) = '42';
  v, e : integer;

begin
  Val (Copy (s, 1, 42), v, e);
  if (v = 42) and (e = 0) then writeln ('OK') else writeln ('failed')
end.
