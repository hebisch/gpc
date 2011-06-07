{$no-exact-compare-strings}
program fjf498a4;

var a : string (10) = 'vw    ';
    b : string (10) = 'vw  ';

begin
  if EQ (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
