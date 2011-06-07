program fjf354;

type
  p = ^string;

function f : p;
var s : string (2) = 'OK'; attribute (static);
begin
  f := @s
end;

var
  v : p;

begin
  v := @f^;
  writeln (v^)
end.
