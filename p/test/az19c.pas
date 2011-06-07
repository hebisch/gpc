(* FLAG --classic-pascal -w *)
program az19c(output);
begin
  if false then
    writeln('failed: ',1 mod 0)
  else
    writeln('OK')
end.
