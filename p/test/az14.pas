program az14(output);
(* FLAG --classic-pascal *)
begin
  if 'ab'='abc' then; (* WRONG - violation of 6.7.2.5 of ISO 7185 *)
  writeln('failed')
end.
