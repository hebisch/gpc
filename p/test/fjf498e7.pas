{$no-exact-compare-strings}
program fjf498e7;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln GT (('', a) ) { WRONG }
end.
