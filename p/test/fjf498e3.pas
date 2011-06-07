{$no-exact-compare-strings}
program fjf498e3;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if GT (b, a) then WriteLn ('failed') else WriteLn ('OK')
end.
