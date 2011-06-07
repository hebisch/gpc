program drf4;

var a : Pointer;

begin
  writeln ('failed');
  halt;
  goto *a { WRONG }
end.
