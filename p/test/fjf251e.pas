program fjf251e;
var f:file;
    i:integer=0;
begin
  {$I-} reset(f,paramstr(1),i); {$I+}
  if IOResult = 0 then writeln('failed') else writeln('OK')
end.
