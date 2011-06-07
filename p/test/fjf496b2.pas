{$no-exact-compare-strings}
program fjf496b2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if a <> b then WriteLn ('OK') else WriteLn ('failed')
end.
