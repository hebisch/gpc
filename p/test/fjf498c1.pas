{$no-exact-compare-strings}
program fjf498c1;

var a : char = 'x';
    b : char = 'x';

begin
  if LE (a, b) then WriteLn ('OK') else WriteLn ('failed')
end.
