program fjf11;
var
  s:string[255];
  i:integer;
begin
  s:='0732';
  s:='07';
  readstr(s,i);
  if i = 7 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
