(* FLAG --classic-pascal -w *)
(*
az19.pas: In main program:
az19.pas:4: division by zero
*)
program az19(output);
begin
  if false then
    writeln('failed: ',1/0)
  else
    writeln('OK')
end.
