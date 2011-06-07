{$no-exact-compare-strings}
program fjf498c4;

var a : string (10) = 'vw    ';
    b : string (10) = 'vw  ';

begin
  if LE (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
