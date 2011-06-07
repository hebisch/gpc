{$no-exact-compare-strings}
program fjf498c7;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln LE (('', a) ) { WRONG }
end.
