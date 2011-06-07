program fjf111;
var a:file of char;
begin
  rewrite(a);
  write(a,'too long'); { WARN }
  close(a);
  writeln('Failed')
end.
