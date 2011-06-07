program fjf251f;
var f:file;
    i:integer=-1;
begin
  {$I-} reset(f,paramstr(1),i); {$I+}
  if IOResult = 0 then writeln('failed') else writeln('OK')
end.
