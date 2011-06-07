program fjf307e;
var a,b:integer;
begin
  {$I-}
  readstr('-42',a,b);
  {$I+}
  if IOResult <> 0 then writeln ('OK') else writeln ('Failed')
end.
