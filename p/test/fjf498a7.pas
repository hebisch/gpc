{$no-exact-compare-strings}
program fjf498a7;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln EQ (('', a) ) { WRONG }
end.
