{$no-exact-compare-strings}
program fjf498a3;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if EQ (b, a) then WriteLn ('failed') else WriteLn ('OK')
end.
