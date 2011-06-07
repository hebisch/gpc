program fjf87;
var
  a:-128..128;
  b:packed -128..129;
begin
  {writeln(sizeof(a));}
  if (sizeof(a)=sizeof(Integer)) and (sizeof(b)=2) then writeln('OK') else writeln('Failed')
end.
