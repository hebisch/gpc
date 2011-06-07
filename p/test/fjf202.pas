program fjf202;
{ FLAG --borland-pascal }
var a:file of char;
begin
  writeln('Failed');
  append(a) { WRONG }
end.
