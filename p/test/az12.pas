program az12(output);
(* FLAG --classic-pascal *)
procedure q(procedure r);
begin
  r:=r (* WRONG - violation of 6.4.6 of ISO 7185 *)
end;
begin
  writeln('failed')
end.
