{$no-exact-compare-strings}
program fjf496c1;

var a : char = 'x';
    b : char = 'x';

begin
  if a <= b then WriteLn ('OK') else WriteLn ('failed')
end.
