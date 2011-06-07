{ @@ Work-around for a problem with COFF debug info. Will hopefully
     disappear with qualified identifiers. }
{ FLAG -g0 }

(*
az22.pas: In procedure `P':
az22.pas:5: function definition does not match previous declaration
az22.pas: In function `X':
az22.pas:6: undeclared identifier `Y' (first use in this routine)
az22.pas:6:  (Each undeclared identifier is reported only once
az22.pas:6:  for each routine it appears in.)
az22.pas:7: warning: return value of function not assigned
*)
program az22(output);
function x:integer;forward;
procedure p;
function x(y:integer):integer;
begin
  x:=y
end;
begin
end;
function x;
begin
  x:=1
end;
begin
  writeln('OK')
end.
