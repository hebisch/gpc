program fjf307c;
var a,b:integer;
begin
  {$I-}
  readln(a,b);
  {$I+}
  if IOResult <> 0 then writeln ('OK') else writeln ('Failed')
end.
