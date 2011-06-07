program az18(output);
(* FLAG --classic-pascal *)
var a:array [1..1] of integer;
begin
  (a)[1]:=10; (* WRONG - violation 6.5.3.2 of ISO 7185 *)
  writeln('failed')
end.
