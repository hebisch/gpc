program fjf138;

var a:file;

procedure p(var b:file);
begin
  if @a=@b then writeln('OK') else writeln('Failed')
end;

begin
  p(a)
end.
