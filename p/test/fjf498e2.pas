{$no-exact-compare-strings}
program fjf498e2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if GT (a, b) then WriteLn ('OK') else WriteLn ('failed')
end.
