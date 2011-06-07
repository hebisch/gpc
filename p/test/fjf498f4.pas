{$no-exact-compare-strings}
program fjf498f4;

var a : string (10) = 'vw    ';
    b : string (10) = 'vw  ';

begin
  if LT (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
