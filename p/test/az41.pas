program az41(output);
var t:array [(a)] of integer;
begin
  t[char]:=1; (* WRONG *)
  writeln('failed')
end.
