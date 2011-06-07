{$no-exact-compare-strings}
program fjf498a6;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln EQ ((a, '') ) { WRONG }
end.
