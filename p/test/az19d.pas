(* FLAG --classic-pascal *)
program az19d(output);
begin
  if false then
    writeln('failed: ',1 mod 0)  { WARN }
  else
    writeln('failed')
end.
