program ptrtest(Output);
type ta = (a);
     pa = ^ ta;
var p1, p2 : pa;
begin
  new(p1);
  new(p2);
  if p1 = p2 then
    writeln('failed')
  else
    writeln('OK')
end
.
