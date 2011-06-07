program az10(output);
(* FLAG --classic-pascal *)
procedure q(procedure r);
begin
end;
begin
  q(nil); (* WRONG - violation of 6.6.3.4 of ISO 7185 *)
  writeln('failed')
end.
