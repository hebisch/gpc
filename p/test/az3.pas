program az3(output);
(* FLAG --classic-pascal *)
procedure q(x:integer);
const xx=x*x; (* WRONG - violation of 6.3 of ISO 7185 *)
begin
end;
begin
  writeln('failed')
end.
