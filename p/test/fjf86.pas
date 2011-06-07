program fjf86;
var
  a:-128..128;
  b:packed -128..128;
begin
  if (sizeof(a)=sizeof(Integer)) and (sizeof(b)=2) then
    writeln('OK')
  else
    writeln('failed: ',sizeof(a),' ',sizeof(b))
end.
