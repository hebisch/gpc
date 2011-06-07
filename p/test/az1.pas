program az1(output);
(* FLAG --classic-pascal *)
const c=2+2; (* WRONG - violation of 6.3 of ISO 7185 *)
begin
  writeln('failed')
end.
