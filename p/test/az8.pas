program az8(output);
(* FLAG --classic-pascal *)
type t=set of char;
function f:t; (* WRONG - violation of 6.6.2 of ISO 7185 *)
begin
  f:=[]
end;
begin
  writeln('failed')
end.
