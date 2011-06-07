program fjf85;
var
  a:0..$ffffffff;
  b:packed 0..$ffffffff;
begin
 if (sizeof(a)>=4) and (sizeof(b)=4) then writeln('OK') else writeln('Failed')
end.
