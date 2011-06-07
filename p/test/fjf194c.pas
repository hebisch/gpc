program fjf194c;
var s: record
  x: ^string;
end { s };
begin
  with s do
    begin
      x:=@'OK';
      writeln(x^)
    end { with }
end.
