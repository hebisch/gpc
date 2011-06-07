program az29(output);
var f:file of file of char; (* WRONG - file type is an illegal component type *)
begin
  writeln('failed')
end.
