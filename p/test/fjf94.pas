program fjf94;
var
  a:text;
  s:string(100);
begin
  reset(a,ParamStr (1));
  seek(a,0);
  readln(a,s);
  if s = 'program fjf94;' then
    writeln ( 'OK' )
  else
    writeln('failed: ', s);
  close(a)
end.
