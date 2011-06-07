program chaput1;
var s : string (10);
begin
  writestr (s, round (3.14));
  if s = '3' then writeln ('OK') else writeln ('failed')
end.
