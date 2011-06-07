program fjf109;

procedure p(var a:integer);
begin
  writeln('Failed')
end;

var b:cardinal;
begin
  p(b) { WRONG }
end.
