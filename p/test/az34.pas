program az34(output);
function f:integer;
begin
  f:=1
end;
procedure p(function f); (* WRONG - incorrect declaration of functional parameter *)
begin
end;
begin
  writeln('failed')
end.
