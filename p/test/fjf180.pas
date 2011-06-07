program fjf180;
var
  a:string(2);
  b:cstring;
begin
  a:='OK';
  {$local R-} a[3]:='X' {$endlocal};
  b:=a;
  {$x+}
  if b[2]=#0 then writeln(b) else writeln('Failed: ',b);
  {$x-}
end.
