{$no-exact-compare-strings}
program fjf498a2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if EQ (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
