{$no-exact-compare-strings}
program fjf498d3;

var a : char = 'x';
    b : string (10) = 'vwxy';

begin
  if GE (b, a) then WriteLn ('failed') else WriteLn ('OK')
end.
