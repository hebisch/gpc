program fjf91c;

var
  s : ^String;

procedure p(var s : String);
begin
  writeln(s)
end;

begin
  New (s, 10);
  s^ := 'OK';
  p(s^)
end.
