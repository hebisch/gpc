{$no-exact-compare-strings}
program fjf498f7;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln LT (('', a) ) { WRONG }
end.
