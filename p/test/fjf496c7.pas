{$no-exact-compare-strings}
program fjf496c7;

var a : integer = 42;

begin
  writeln ('failed');
  halt;
  writeln ('' <= a)  { WRONG }
end.
