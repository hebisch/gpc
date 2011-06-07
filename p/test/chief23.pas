program Chief23;
var
  t:text;
  s:string(42);
begin
  rewrite(t,'test.dat');
  writeln(t,'OK');
  reset(t);
  readln(t,s);
  if length(s)=2 then writeln(s) else writeln('Failed: ',length(s),' ',s);
  close(t)
end.
