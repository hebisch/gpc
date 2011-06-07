program az9(output);
(* FLAG --classic-pascal *)
type t=record end;
var x:t;
function f:t; (* WRONG - violation of 6.6.2 of ISO 7185 *)
begin
  f:=x
end;
begin
  writeln('failed')
end.
