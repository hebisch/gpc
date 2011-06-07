Program Miklos2;

{ FIXED: `Index' was not working if the pattern was a char. }

var c:char;
    d:string(1);
    s:string(80);
    i:integer;

begin
  c:= 'c';
  d:= 'd';
  s:= 'abcde';
  i:=index(s,c); { "i" always zero }
  if i = 3 then
    write ( 'O' )
  else
    write ( 'failed ' );
  i:=index(s,d);
  if i = 4 then
    write ( 'K' )
  else
    write ( 'failed' );
  writeln;
end.
