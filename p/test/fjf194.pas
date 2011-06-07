program fjf194;
var s:array [1..1] of ^string;
begin
  s[1]:=@'OK';
  writeln(s[1]^)
end.
