(*
az23.pas: In main program:
az23.pas:3: parse error before `..'
az23.pas:5: parse error before `Else'
*)
program az23(output);
begin
  if []=(..)
    then writeln('OK')
    else writeln('failed')
end.
