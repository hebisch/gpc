program az28(output);
var i:integer;
begin
  for i:=0 to nil do; (* WRONG - type of final value not compatible with integer *)
  writeln('failed')
end.
