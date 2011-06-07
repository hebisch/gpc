{$no-exact-compare-strings}
program fjf498c2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if LE (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
