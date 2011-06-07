program fjf252;
var
  f:file;
  s1:MedInt;
  s2:SizeType;
  x:array[1..7] of char;
begin
  rewrite(f,1);
  x:='foo-bar';
  blockwrite(f,x,sizeof(x));
  x:='failed ';
  reset(f,1);
  blockread(f,x,2,s1);
  blockread(f,x[3],sizeof(x)-2,s2);
  if (s1=2) and (s2=sizeof(x)-2) and (x='foo-bar') then writeln('OK') else writeln('Failed')
end.
