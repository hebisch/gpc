(*
az21.pas: In main program:
az21.pas:11: type mismatch in array index
az21.pas:11: array subscript is not of ordinal type
*)
program az21(output);
var t:array [1..1] of integer;
procedure r(x:integer);
begin
end;
function q:integer;
begin
  q:=1
end;
begin
  r(t[q]);
  writeln('OK')
end.
