Program Bill3;

{$W-}

Var
  p: Pointer value Nil;
  x: Integer;

begin
  x:= LongInt ( p );
  writeln ( 'OK' );
end.
