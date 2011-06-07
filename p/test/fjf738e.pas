program fjf738e(output);
(* FLAG --classic-pascal *)
type t=array [1 .. 10] of Integer;
var x:t;
function f:t; (* WRONG - violation of 6.6.2 of ISO 7185 *)
begin
  f:=x
end;
begin
  writeln('failed')
end.
