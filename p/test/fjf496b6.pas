{$no-exact-compare-strings}
program fjf496b6;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln (a <> '')  { WRONG }
end.
