(* FLAG --classic-pascal *)
program az19b(output);
begin
  if false then
    writeln('failed: ',1/0)  { WARN }
  else
    writeln('failed')
end.
