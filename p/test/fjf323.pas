program fjf323;

var
  s : string (10) = 'OK';
  a : LongInt;

begin
  a := - Length (s);
  if a = Integer (- 2) then writeln (s) else writeln ('failed')
end.
