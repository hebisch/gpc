program az6(output);
(* FLAG --extended-pascal *)
begin
  if ord('')=32 then; (* WRONG - violation of 6.7.6.4 of ISO 10206 *)
  writeln('failed')
end.
