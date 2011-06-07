program fjf67a;
type
  a(c:integer)=array[1..c] of integer;
  b(c:integer)=a(c);  { WRONG }
var v:b(5);
begin
  writeln ( 'failed' );
end.
