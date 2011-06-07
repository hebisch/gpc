{$no-exact-compare-strings}
program fjf496a4;

var a : string (10) = 'vw    ';
    b : string (10) = 'vw  ';

begin
  if a = b then WriteLn ('OK') else WriteLn ('failed')
end.
