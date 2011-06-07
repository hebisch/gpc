(*
az20.pas: In main program:
az20.pas:7: warning: ISO Pascal forbids this use of packed array components
*)
program az20(output);
(* FLAG --classic-pascal -Werror *)
var t:packed array [1..1,1..1] of boolean;
    i:integer;
begin
  i:=1;
  t[1,i]:=false;
  writeln('OK')
end.
