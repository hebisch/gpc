{$no-exact-compare-strings}
program fjf498a1;

var a : char = 'x';
    b : char = 'x';

begin
  if EQ (a, b) then WriteLn ('OK') else WriteLn ('failed')
end.
