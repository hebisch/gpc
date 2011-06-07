program az2(output);
(* FLAG --classic-pascal *)
const p=nil; (* WRONG - violation of 6.3 of ISO 7185 *)
begin
  writeln('failed')
end.
