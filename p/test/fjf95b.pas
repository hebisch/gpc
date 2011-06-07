program fjf95b;
var
  a:file of integer;
  s1,s2:integer;
begin
  rewrite(a);
  write(a,7,8,9);
  seek(a,1);
  write(a,2);
  seek(a,0);
  write(a,1);
  reset(a);
  seek(a,0);
  read(a,s1);
  read(a,s2);
  if(s1=1)and(s2=2)then
    writeln('OK')
  else
    writeln('failed: ',s1,' ',s2);
  close(a)
end.
