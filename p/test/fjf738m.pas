program fjf738m(output);
(* FLAG --classic-pascal *)
var a:^integer;
begin
  New (a);
  (a)^:=10; (* WRONG *)
  writeln('failed')
end.
