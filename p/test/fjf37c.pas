Program fjf37c;

{$X+}

Type
  Int13 = Integer attribute ( Size = 13 );

Var
  x: packed array [ 1..42 ] of Int13;
  y: ^Int13;
  i: Integer;

begin
  i:= 10;
  y:= @x [ i ];  { WRONG }
  writeln ( 'failed: ', y - @x [ 1 ] );
end.
