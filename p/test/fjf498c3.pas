{$no-exact-compare-strings}
program fjf498c3;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if LE (b, a) then WriteLn ('OK') else WriteLn ('failed')
end.
