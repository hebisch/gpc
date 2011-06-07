program fjf251g;
var f:file;
    i:integer=0;
begin
  assign(f,paramstr(1));
  {$I-} reset(f,i); {$I+}
  if IOResult = 0 then writeln('failed') else writeln('OK')
end.
