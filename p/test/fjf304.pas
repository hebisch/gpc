program fjf304;

var a : file;

begin
  writeln ('failed');
  halt;
  reset (a, 42, 42) { WRONG }
end.
