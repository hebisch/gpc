program fjf738l(output);
(* FLAG --classic-pascal *)
var a:record b:integer end;
begin
  (a).b:=10; (* WRONG *)
  writeln('failed')
end.
