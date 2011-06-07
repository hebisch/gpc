{$no-exact-compare-strings}
program fjf498f1;

var a : char = 'x';
    b : char = 'x';

begin
  if LT (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
