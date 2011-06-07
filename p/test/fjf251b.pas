program fjf251b;
var f:file;
begin
  writeln('failed');
  halt;
  reset(f,'foo',-1); { WRONG }
end.
