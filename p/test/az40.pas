program az40(output);
procedure q(x:integer);forward;
procedure q;
begin
end;
function r; (* WRONG *)
begin
  r:=1
end;
begin
  writeln('failed')
end.
