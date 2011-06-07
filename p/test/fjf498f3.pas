{$no-exact-compare-strings}
program fjf498f3;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if LT (b, a) then WriteLn ('OK') else WriteLn ('failed')
end.
