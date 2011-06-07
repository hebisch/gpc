{$no-exact-compare-strings}
program fjf498d2;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if GE (a, b) then WriteLn ('OK') else WriteLn ('failed')
end.
