{$no-exact-compare-strings}
program fjf496b1;

var a : char = 'x';
    b : char = 'x';

begin
  if a <> b then WriteLn ('failed') else WriteLn ('OK')
end.
