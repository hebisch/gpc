{$no-exact-compare-strings}
program fjf496a2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if a = b then WriteLn ('failed') else WriteLn ('OK')
end.
