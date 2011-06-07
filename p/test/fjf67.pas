program fjf67;
type
  a(c:integer)=array[1..c] of integer;
  b(d:integer)=a(d);
var v:b(5);
begin
  writeln ( 'OK' );
end.
