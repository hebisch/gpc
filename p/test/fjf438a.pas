program fjf438a;

var
  f:text;
  s,t:string(10);

begin
  rewrite(f);
  writeln(f,42);
  reset(f);
  extend(f);
  writeln(f,'OK');
  reset(f);
  readln(f,t);
  readln(f,s);
  if t='42' then writeln(s) else writeln('failed ',t,', ',s)
end.
