program az16(output);
(* FLAG --classic-pascal *)
var r:record end;
begin
  with (r) do; (* WRONG - violation of 6.8.3.10 of ISO 7185 *)
  writeln('failed')
end.
