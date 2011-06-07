{$no-exact-compare-strings}
program fjf498e6;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln GT ((a, '') ) { WRONG }
end.
