{$no-exact-compare-strings}
program fjf498b6;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln NE ((a, '') ) { WRONG }
end.
