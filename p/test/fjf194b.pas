program fjf194b;
var s: record
  x: ^string;
end { s };
begin
  s.x:=@'OK';
  writeln(s.x^)
end.
