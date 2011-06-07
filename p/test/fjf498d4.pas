{$no-exact-compare-strings}
program fjf498d4;

var a : string (10) = 'vw    ';
    b : string (10) = 'vw  ';

begin
  if GE (a, b) then WriteLn ('OK') else WriteLn ('failed')
end.
