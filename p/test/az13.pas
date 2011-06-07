program az13(output);
(* FLAG --classic-pascal *)
var t:array [boolean] of integer;
begin
  if t=t then; (* WRONG - violation of 6.7.2.5 of ISO 7185 *)
  writeln('failed')
end.
