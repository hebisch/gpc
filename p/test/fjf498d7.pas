{$no-exact-compare-strings}
program fjf498d7;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln GE (('', a) ) { WRONG }
end.
