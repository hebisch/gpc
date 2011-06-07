program fjf108;

var a:^integer;

procedure p(var b:pointer);
begin
  if @b=pointer(@a) then writeln('OK') else writeln('Failed')
end;

begin
 p(pointer(a))
end.
