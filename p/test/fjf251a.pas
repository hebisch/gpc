program fjf251a;
var f:file;
begin
  writeln('failed');
  halt;
  reset(f,'foo',0); { WRONG }
end.
