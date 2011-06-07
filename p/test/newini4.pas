program newini4(output);
type t(i:integer) = array [1..i] of char;
     t2 = t(2);
var a : t2;
begin
  a :=  t2['O'; 'K'];
  writeln(a)
end
.
