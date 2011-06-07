program fjf229;
var i : integer = 42;
begin
  if {$W-} round (i) = 42 {$W+} then writeln ('OK') else writeln ('failed')
end.
