{$no-exact-compare-strings}
program fjf498d1;

var a : char = 'x';
    b : char = 'x';

begin
  if GE (a, b) then WriteLn ('OK') else WriteLn ('failed')
end.
