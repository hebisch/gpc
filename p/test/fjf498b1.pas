{$no-exact-compare-strings}
program fjf498b1;

var a : char = 'x';
    b : char = 'x';

begin
  if NE (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
