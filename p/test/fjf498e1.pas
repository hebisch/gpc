{$no-exact-compare-strings}
program fjf498e1;

var a : char = 'x';
    b : char = 'x';

begin
  if GT (a, b) then WriteLn ('failed') else WriteLn ('OK')
end.
