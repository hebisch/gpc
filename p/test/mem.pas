Program Mem;

Var
  x, y: ^Char;

begin
  GetMem ( x, 1024 );
  x^:= 'O';
  y:= @x^;
  write ( y^ );
  FreeMem ( y, 1024 );
  GetMem ( x, 2048 );
  FreeMem ( x );
  writeln ( 'K' );
end.
