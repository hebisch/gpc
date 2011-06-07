program fjf746(output);
(* FLAG --classic-pascal -Werror *)
var t:packed record a:packed array [1..1] of boolean end;
    i:integer;
begin
  i:=1;
  t.a[i]:=false;
  writeln('OK')
end.
