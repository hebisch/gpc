program fjf133;
var
  a:string(2);
  t:Text;
begin
  rewrite(t);
  write(t,'OKx');
  reset(t);
  read(t,a);
  if length(a)=2 then writeln(a) else writeln('Failed')
end.
