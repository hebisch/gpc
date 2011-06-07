{$no-exact-compare-strings}
program fjf498b7;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln NE (('', a) ) { WRONG }
end.
