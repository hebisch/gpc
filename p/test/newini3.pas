program newini3(output);
type t(i:integer) = array [1..i] of char value "OK";
var p : ^ t;
begin
  new(p, 2);
  writeln(p^)
end
.
