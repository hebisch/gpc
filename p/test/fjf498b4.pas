{$no-exact-compare-strings}
program fjf498b4;

var a : string (10) = 'vw    ';
    b : string (10) = 'vw  ';

begin
  if NE (a, b) then WriteLn ('OK') else WriteLn ('failed')
end.
