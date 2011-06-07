program fjf45;
var a:array[10..1] of byte;  { WRONG }
begin
  writeln('failed: ', sizeof(a))
end.
