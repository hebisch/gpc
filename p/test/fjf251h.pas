program fjf251h;
var f:file;
    i:integer=-1;
begin
  assign(f,paramstr(1));
  {$I-} reset(f,i); {$I+}
  if IOResult = 0 then writeln('failed') else writeln('OK')
end.
