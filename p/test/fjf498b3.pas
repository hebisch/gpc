{$no-exact-compare-strings}
program fjf498b3;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if NE (b, a) then WriteLn ('OK') else WriteLn ('failed')
end.
