{$no-exact-compare-strings}
program fjf498e4;

var a : string (10) = 'vw    ';
    b : string (10) = 'vw  ';

begin
  if GT (a, b) then WriteLn ('OK') else WriteLn ('failed')
end.
