program fjf305;

type byte = 0 .. 255;

procedure foo (var b:byte);
begin
  writeln ('failed')
end;

var a:integer;

begin
  foo (a) { WRONG }
end.
