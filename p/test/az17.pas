program az17(output);
(* FLAG --classic-pascal *)
var p:^integer;
begin
  new((p)); (* WRONG - violation of 6.6.5.3 of ISO 7185 *)
  writeln('failed')
end.
