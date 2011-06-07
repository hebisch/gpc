program fjf64;
type a(b:integer)=array[1..b] of text;
var b:a(3);
    i:integer;
begin
  for i:= 1 to b.b do
    rewrite ( b [ i ] );
  for i:= 1 to b.b do
    close ( b [ i ] );
  writeln ( 'OK' );
end.
