{$no-exact-compare-strings}
program fjf498f2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if LT (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
